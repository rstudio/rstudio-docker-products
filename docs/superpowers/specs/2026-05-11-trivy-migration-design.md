# Snyk → Trivy migration design

**Date:** 2026-05-11
**Status:** Approved (pending implementation plan)

## Context

The repository uses Snyk to scan built container images for vulnerabilities.
Container scanning under our Snyk contract has expired, so Snyk must be
replaced. Trivy is the chosen replacement.

Constraints stated by the requester:

- Scan must not fail the workflow on findings (matches current Snyk behavior).
- Severity filtered to `HIGH` and `CRITICAL` only.
- SARIF results uploaded to the GitHub Security tab (Code Scanning).
- A set of image paths must be ignored per image family (see "Ignore paths"
  below). These come from a curated spreadsheet maintained by the security
  reviewers and represent components that are either covered upstream or
  cannot be patched in our image.

Out of scope:

- SBOM generation (Snyk's `snyk-sbom`).
- Ongoing vulnerability tracking equivalent to `snyk monitor` (no Trivy SaaS;
  GitHub Code Scanning already provides ongoing tracking via SARIF uploads).
- Source-code SAST (Snyk's `snyk code test`). Can be added later via
  `trivy fs --scanners vuln,misconfig,secret` if desired.
- Carrying forward existing `.snyk` ignore IDs. The current ignores are
  Snyk-ID-keyed (e.g. `SNYK-JS-SEMVER-3247795`) and most expired in 2025-03;
  they do not translate to Trivy, which keys on CVE/GHSA IDs.

## Architecture

```
.github/actions/bake-test-push/action.yml
  └─ Scan step → just trivy-test <target> <bakefile>
                  └─ python3 tools/trivy_bake_artifacts.py
                       ├─ reads docker buildx bake --print
                       ├─ expands group target → child targets
                       ├─ for each target: trivy image
                       │    --severity HIGH,CRITICAL
                       │    --format sarif --output <tmp>.sarif
                       │    --config <ctx>/trivy.yaml (when present)
                       │    <image-ref>
                       └─ merges all per-target SARIFs → container.sarif
  └─ Upload step → github/codeql-action/upload-sarif
                    sarif_file: container.sarif
                    category: <target>-trivy-vulnerabilities
```

## Components

### `tools/trivy_bake_artifacts.py`

Slim replacement for `tools/snyk_bake_artifacts.py`. Same overall shape
(read bake plan, iterate child targets, run scanner per image, write SARIF),
simpler internals.

Responsibilities:

- Run `docker buildx bake -f <bakefile> --print <target>` and parse JSON.
- Resolve the group's child targets the same way the existing script does.
- For each child target, run Trivy with:
  - `image` subcommand
  - `--severity HIGH,CRITICAL`
  - `--format sarif --output <per-target>.sarif`
  - `--config <target_spec.context>/trivy.yaml` when the file exists
  - Image reference = `target_spec["tags"][0]`
- Merge each per-target SARIF's `runs[]` into a combined `container.sarif`
  in the working directory (matches the upload step's expected filename).
- Always exit 0. Per-target Trivy failures are logged but do not fail the
  step (matches `continue-on-error: true` behavior of the current Snyk step,
  and the user requirement that scans not fail the workflow).

Interface: `python3 tools/trivy_bake_artifacts.py --target <t> --file <f>`.
No environment variables required (Trivy needs no auth for the public
vulnerability DB).

### Per-image `trivy.yaml` files

One per image family with ignores. Trivy auto-merges this when passed via
`--config`. Format used:

```yaml
scan:
  skip-dirs:
    - <path>
  skip-files:
    - <glob>
```

`skip-dirs` is used for prefix-style ignores (entire trees). `skip-files`
is used when glob patterns are required (e.g. `**/esbuild`).

| File | skip-dirs | skip-files |
|---|---|---|
| `connect/trivy.yaml` | `/opt/connect` | `/opt/quarto/**/bin/tools/x86_64/esbuild` |
| `connect-content-init/trivy.yaml` | `/opt/rstudio-connect-runtime` | `/opt/quarto/**/bin/tools/x86_64/esbuild` |
| `package-manager/trivy.yaml` | `/opt/rstudio-pm` | — |
| `workbench/trivy.yaml` | `/usr/lib/rstudio-server` | — |
| `workbench-positron-init/trivy.yaml` | `/opt/positron` | `/usr/local/bin/positron-session-init` |
| `workbench-session/trivy.yaml` | — | `/opt/quarto/**/bin/tools/x86_64/esbuild` |
| `workbench-session-init/trivy.yaml` | `/opt/session-components` | — |

Notes:

- The spreadsheet row for `connect-content` (Quarto esbuild) is folded into
  `connect-content-init/trivy.yaml`. There is no separate `connect-content`
  top-level image directory.
- Images without any rows in the spreadsheet (e.g. `r-session-complete`,
  `workbench-for-microsoft-azure-ml`, `workbench-for-google-cloud-workstations`,
  base images) do not get a `trivy.yaml`. Trivy runs with default scanning
  for them.

### `Justfile` changes

Remove:

- `SNYK_ORG` variable
- `snyk-code-test`
- `snyk-test`
- `snyk-monitor`
- `snyk-sbom`
- `snyk-ignore`
- `preview-snyk-test`
- `preview-snyk-monitor`
- `preview-snyk-sbom`

Add:

- `trivy-test target="default" file="docker-bake.hcl"` — wraps
  `python3 tools/trivy_bake_artifacts.py`. Mirrors the shape of `snyk-test`.
- `preview-trivy-test target="default" branch="$(git branch --show-current)"`
  — mirrors `preview-snyk-test`, sets the same daily/preview version
  environment variables, calls the Python wrapper with
  `--file docker-bake.preview.hcl`.

### `.github/actions/bake-test-push/action.yml` changes

Remove:

- `snyk-org` input
- `snyk-token` input
- `snyk/actions/setup@master` step
- `Snyk auth` step

Add:

- `aquasecurity/setup-trivy@v0.2` (or current pinned tag) step. Installs
  the Trivy CLI and handles vulnerability DB caching via `actions/cache`.

Modify:

- `Scan` step: shell now invokes `just trivy-test "${{ inputs.target }}" "${{ inputs.bakefile }}"`. Remove the push-vs-test branch (no `monitor` equivalent).
  Keep `continue-on-error: true`.
- `Upload results` step: change category to `${{ inputs.target }}-trivy-vulnerabilities`. `sarif_file` stays `container.sarif`.

### `.github/workflows/build-bake.yaml` changes

Remove `snyk-org` and `snyk-token` inputs from all 10 job invocations of the
`bake-test-push` action (`base`, `connect`, `connect-content-init`, `content`,
`package-manager`, `r-session-complete`, `workbench-session`,
`workbench-session-init`, `workbench-positron-init`, `workbench`).

The `SNYK_ORG` and `SNYK_TOKEN` repository secrets can be left in place or
removed by a repo admin; either is fine. The workflow stops referencing them
either way.

### Files to delete

- `tools/snyk_bake_artifacts.py`
- `connect/.snyk`
- `package-manager/.snyk`
- `r-session-complete/.snyk`
- `workbench/.snyk`
- `workbench-session/.snyk`
- `workbench-for-microsoft-azure-ml/.snyk`

## Data flow

1. `docker bake` builds image(s) and loads them into the local Docker daemon
   (existing `load: true` behavior, unchanged).
2. `just trivy-test` runs the Python wrapper, which expands the bake target
   into child image references and invokes `trivy image` per reference.
3. Each scan reads `<image-dir>/trivy.yaml` for per-image skip rules and
   emits a per-target SARIF.
4. The wrapper merges all SARIFs into `container.sarif` at the working
   directory root.
5. `github/codeql-action/upload-sarif` uploads `container.sarif` to GitHub
   Code Scanning, tagged with `<target>-trivy-vulnerabilities`.
6. Findings appear under repository **Security → Code scanning**, filtered
   to HIGH/CRITICAL by the scanner.

## Error handling

- Trivy DB download failures: rely on `aquasecurity/setup-trivy` retry/cache
  behavior. If the DB is unavailable, the scan step logs the error and the
  workflow continues (the step is `continue-on-error: true`).
- Per-target scan failures: logged, do not abort sibling target scans, do
  not fail the workflow step.
- SARIF merge: if Trivy produces no SARIF for a target (e.g. scan failed),
  that target is skipped in the merge. The merged file still uploads.
- SARIF upload failure: existing `continue-on-error: true` on the upload
  step is preserved.

## Testing

Manual verification post-implementation:

- Run `just trivy-test base-images` locally — confirms wrapper, config
  discovery, SARIF merge work end-to-end.
- Run `just trivy-test connect` locally — confirms `connect/trivy.yaml`
  skip rules are honored (vulnerabilities under `/opt/connect` should be
  absent from the SARIF).
- Open a draft PR — confirm the `Scan` and `Upload results` steps run, and
  that findings appear in the PR's Security tab when there are any.
- After merge to `main` — confirm scheduled and push workflows still
  succeed.

No automated test additions. The scanner integration is exercised by every
CI run.

## Trade-offs

- **No per-CVE snoozing.** All ignores are path-based. If future needs
  require `ignore CVE-XXXX-YYYY for 30 days`, add a `.trivyignore.yaml` per
  image. Deferred until needed.
- **DB cache on cold start.** First Trivy run downloads ~500MB. Cached
  thereafter by `aquasecurity/setup-trivy`. Acceptable.
- **Wrapper retained.** Could have inlined Trivy invocation in `action.yml`
  shell, but the existing pattern (bake-plan-aware Python wrapper used by
  both CI and `just`) is preserved so local developers run the same command
  CI runs.
