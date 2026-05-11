# Snyk → Trivy migration Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace Snyk container scanning with Trivy, producing HIGH/CRITICAL SARIF reports uploaded to GitHub Code Scanning, with path-based ignores configured per image family.

**Architecture:** A new Python wrapper `tools/trivy_bake_artifacts.py` mirrors the structure of the current `tools/snyk_bake_artifacts.py`: it reads the docker bake plan, expands a group target into child targets, runs `trivy image` per child with a per-image `trivy.yaml` config when present, merges per-target SARIFs into one `container.sarif`, and exits 0 regardless of findings. The bake-test-push composite action calls this via a new `trivy-test` Justfile recipe; the SARIF is uploaded to GitHub Code Scanning. Snyk inputs, secrets references, `.snyk` policy files, and the old Python wrapper are removed.

**Tech Stack:** Python 3 (no extra dependencies — uses stdlib `argparse`, `json`, `subprocess`, `tempfile`, `pathlib`), Trivy CLI (installed in CI via `aquasecurity/setup-trivy@v0.2`), `just` for task running, GitHub Actions composite action, `github/codeql-action/upload-sarif@v3`.

**Reference spec:** `docs/superpowers/specs/2026-05-11-trivy-migration-design.md`

---

## File Structure

**Create:**
- `tools/trivy_bake_artifacts.py` — Trivy invocation wrapper, mirrors existing snyk wrapper shape
- `connect/trivy.yaml`
- `connect-content-init/trivy.yaml`
- `package-manager/trivy.yaml`
- `workbench/trivy.yaml`
- `workbench-positron-init/trivy.yaml`
- `workbench-session/trivy.yaml`
- `workbench-session-init/trivy.yaml`

**Modify:**
- `Justfile` — remove all `snyk-*` and `preview-snyk-*` recipes, the `SNYK_ORG` variable, and the `snyk-code-test` recipe; add `trivy-test` and `preview-trivy-test`
- `.github/actions/bake-test-push/action.yml` — remove Snyk inputs/setup/auth steps, add Trivy setup step, rewrite Scan step, update SARIF upload category
- `.github/workflows/build-bake.yaml` — remove `snyk-org`/`snyk-token` inputs from all 10 jobs

**Delete:**
- `tools/snyk_bake_artifacts.py`
- `connect/.snyk`
- `package-manager/.snyk`
- `r-session-complete/.snyk`
- `workbench/.snyk`
- `workbench-session/.snyk`

**Testing approach:** This repo has no pytest setup and the existing `snyk_bake_artifacts.py` has no unit tests, so the plan uses functional verification (run `just trivy-test <target>` against a real built image, inspect SARIF) rather than introducing a pytest framework just for this glue script.

---

## Task 1: Add Trivy bake-artifacts wrapper script

**Files:**
- Create: `tools/trivy_bake_artifacts.py`

- [ ] **Step 1: Create `tools/trivy_bake_artifacts.py`**

```python
#!/usr/bin/env python3
"""
Run Trivy container vulnerability scanning against bake artifacts by group/target.

Reads `docker buildx bake --print <target>` to expand a group target into child
image targets, runs `trivy image` on each with a per-image `trivy.yaml` config
when present, and merges per-target SARIF outputs into one `container.sarif`
written to the current working directory.

Always exits 0 — vulnerability findings do not fail the workflow.

Usage:
    python3 tools/trivy_bake_artifacts.py --target <target> --file <bake-file>
"""

import argparse
import json
import logging
import os
import subprocess
import sys
import tempfile
from pathlib import Path

logging.basicConfig(stream=sys.stdout, level=logging.INFO)
LOGGER = logging.getLogger(__name__)

PROJECT_DIR = Path(__file__).resolve().parents[1]
SEVERITY = "HIGH,CRITICAL"
OUTPUT_SARIF = "container.sarif"

parser = argparse.ArgumentParser(
    description="Run Trivy against images defined in a docker buildx bake target"
)
parser.add_argument("--file", default="docker-bake.hcl")
parser.add_argument("--target", default="default")


def get_bake_plan(bake_file, target):
    cmd = ["docker", "buildx", "bake", "-f", str(PROJECT_DIR / bake_file), "--print", target]
    p = subprocess.run(cmd, capture_output=True, env=os.environ.copy())
    if p.returncode != 0:
        LOGGER.error(f"Failed to get bake plan: {p.stderr.decode('utf-8', errors='replace')}")
        sys.exit(1)
    return json.loads(p.stdout.decode("utf-8"))


def resolve_targets(plan, target):
    """Expand a target into child targets, mirroring the existing Snyk wrapper."""
    targets = {}
    group = plan.get("group", {}).get(target)
    if group:
        target_names = group["targets"]
    else:
        target_names = [target]
    for name in target_names:
        for tname, tspec in plan["target"].items():
            if tname.startswith(name):
                targets[tname] = tspec
    return targets


def build_trivy_command(target_spec, sarif_path):
    context = target_spec["context"]
    config_path = PROJECT_DIR / context / "trivy.yaml"
    image_ref = target_spec["tags"][0]
    cmd = [
        "trivy",
        "image",
        "--severity", SEVERITY,
        "--format", "sarif",
        "--output", str(sarif_path),
        "--exit-code", "0",
    ]
    if config_path.exists():
        cmd.extend(["--config", str(config_path)])
    cmd.append(image_ref)
    return cmd


def run_scan(target_name, target_spec, sarif_path):
    cmd = build_trivy_command(target_spec, sarif_path)
    LOGGER.info(f"Scanning {target_name}: {' '.join(cmd)}")
    p = subprocess.run(cmd)
    if p.returncode != 0:
        LOGGER.error(f"Trivy scan failed for {target_name} with exit code {p.returncode}")
        return False
    return True


def merge_sarifs(sarif_paths, output_path):
    """Merge per-target SARIFs by concatenating `runs[]` arrays."""
    merged = None
    for path in sarif_paths:
        if not path.exists() or path.stat().st_size == 0:
            LOGGER.warning(f"Skipping missing or empty SARIF: {path}")
            continue
        try:
            with open(path) as f:
                data = json.load(f)
        except json.JSONDecodeError as e:
            LOGGER.warning(f"Skipping unreadable SARIF {path}: {e}")
            continue
        if merged is None:
            merged = data
        else:
            merged.setdefault("runs", []).extend(data.get("runs", []))
    if merged is None:
        LOGGER.warning("No SARIF outputs to merge — writing empty SARIF")
        merged = {
            "version": "2.1.0",
            "$schema": "https://json.schemastore.org/sarif-2.1.0.json",
            "runs": [],
        }
    with open(output_path, "w") as f:
        json.dump(merged, f, indent=2)


def main():
    args = parser.parse_args()
    plan = get_bake_plan(args.file, args.target)
    targets = resolve_targets(plan, args.target)
    LOGGER.info(f"Scanning {len(targets)} target(s): {list(targets.keys())}")
    sarif_paths = []
    failed_targets = []
    with tempfile.TemporaryDirectory() as tmpdir:
        for target_name, target_spec in targets.items():
            sarif_path = Path(tmpdir) / f"{target_name}.sarif"
            if run_scan(target_name, target_spec, sarif_path):
                sarif_paths.append(sarif_path)
            else:
                failed_targets.append(target_name)
        merge_sarifs(sarif_paths, PROJECT_DIR / OUTPUT_SARIF)
    LOGGER.info(f"Merged SARIF written to {OUTPUT_SARIF}")
    if failed_targets:
        LOGGER.warning(f"Failed targets (non-fatal): {failed_targets}")
    sys.exit(0)


if __name__ == "__main__":
    main()
```

- [ ] **Step 2: Make the script executable**

Run: `chmod +x tools/trivy_bake_artifacts.py`

- [ ] **Step 3: Commit**

```bash
git add tools/trivy_bake_artifacts.py
git commit -m "Add Trivy bake artifacts wrapper script"
```

---

## Task 2: Add per-image `trivy.yaml` configs

**Files:**
- Create: `connect/trivy.yaml`
- Create: `connect-content-init/trivy.yaml`
- Create: `package-manager/trivy.yaml`
- Create: `workbench/trivy.yaml`
- Create: `workbench-positron-init/trivy.yaml`
- Create: `workbench-session/trivy.yaml`
- Create: `workbench-session-init/trivy.yaml`

- [ ] **Step 1: Create `connect/trivy.yaml`**

```yaml
# Trivy scan configuration for the Connect image.
# Paths listed here are skipped during vulnerability scanning. Each entry has
# a corresponding row in the Posit security-ignores spreadsheet documenting
# why the path is excluded (e.g. covered upstream, awaiting upstream patch).
scan:
  skip-dirs:
    - /opt/connect
  skip-files:
    - /opt/quarto/**/bin/tools/x86_64/esbuild
```

- [ ] **Step 2: Create `connect-content-init/trivy.yaml`**

```yaml
scan:
  skip-dirs:
    - /opt/rstudio-connect-runtime
  skip-files:
    - /opt/quarto/**/bin/tools/x86_64/esbuild
```

- [ ] **Step 3: Create `package-manager/trivy.yaml`**

```yaml
scan:
  skip-dirs:
    - /opt/rstudio-pm
```

- [ ] **Step 4: Create `workbench/trivy.yaml`**

```yaml
scan:
  skip-dirs:
    - /usr/lib/rstudio-server
```

- [ ] **Step 5: Create `workbench-positron-init/trivy.yaml`**

```yaml
scan:
  skip-dirs:
    - /opt/positron
  skip-files:
    - /usr/local/bin/positron-session-init
```

- [ ] **Step 6: Create `workbench-session/trivy.yaml`**

```yaml
scan:
  skip-files:
    - /opt/quarto/**/bin/tools/x86_64/esbuild
```

- [ ] **Step 7: Create `workbench-session-init/trivy.yaml`**

```yaml
scan:
  skip-dirs:
    - /opt/session-components
```

- [ ] **Step 8: Commit**

```bash
git add connect/trivy.yaml connect-content-init/trivy.yaml package-manager/trivy.yaml \
        workbench/trivy.yaml workbench-positron-init/trivy.yaml \
        workbench-session/trivy.yaml workbench-session-init/trivy.yaml
git commit -m "Add per-image Trivy scan configs with path-based ignores"
```

---

## Task 3: Update Justfile (remove Snyk recipes, add Trivy recipes)

**Files:**
- Modify: `Justfile` — remove `SNYK_ORG` variable, remove all `snyk-*` and `preview-snyk-*` recipes, add `trivy-test` and `preview-trivy-test`

- [ ] **Step 1: Remove the `SNYK_ORG` variable**

In `Justfile`, delete the line:

```just
SNYK_ORG := env("SNYK_ORG", "")
```

(Currently around line 18.)

- [ ] **Step 2: Remove the `snyk-code-test` recipe**

Delete the recipe and its preceding `# just snyk-code-test` comment line:

```just
# just snyk-code-test
snyk-code-test:
  snyk code test --org="{{SNYK_ORG}}" --sarif-file-output=code.sarif {{justfile_directory()}}
```

- [ ] **Step 3: Replace `snyk-test`, `snyk-monitor`, `snyk-sbom`, `snyk-ignore` recipes with a single `trivy-test` recipe**

Replace this whole block (currently lines 114–134):

```just
# just snyk-test workbench
snyk-test target="default" file="docker-bake.hcl" *opts="":
  SNYK_ORG="{{SNYK_ORG}}" \
  GIT_SHA=$(git rev-parse --short HEAD) \
    python3 {{justfile_directory()}}/tools/snyk_bake_artifacts.py --target "{{target}}" --file "{{file}}" test {{opts}}

# just snyk-monitor workbench
snyk-monitor target="default" file="docker-bake.hcl" *opts="":
  SNYK_ORG="{{SNYK_ORG}}" \
  GIT_SHA=$(git rev-parse --short HEAD) \
    python3 {{justfile_directory()}}/tools/snyk_bake_artifacts.py --target "{{target}}" --file "{{file}}" monitor {{opts}}

# just snyk-sbom workbench
snyk-sbom target="default" file="docker-bake.hcl" *opts="":
  SNYK_ORG="{{SNYK_ORG}}" \
  GIT_SHA=$(git rev-parse --short HEAD) \
    python3 {{justfile_directory()}}/tools/snyk_bake_artifacts.py --target "{{target}}" --file "{{file}}" sbom {{opts}}

# just snyk-ignore workbench SNYK-XXXX-XXXX-XXXX "Reported upstream in <link>" 2024-08-31
snyk-ignore context snyk_id reason expiry:
  snyk ignore --id="{{snyk_id}}" --reason="{{reason}}" --expiry="{{expiry}}" --policy-path="{{context}}"
```

with:

```just
# just trivy-test workbench
trivy-test target="default" file="docker-bake.hcl":
  GIT_SHA=$(git rev-parse --short HEAD) \
    python3 {{justfile_directory()}}/tools/trivy_bake_artifacts.py --target "{{target}}" --file "{{file}}"
```

- [ ] **Step 4: Replace the three `preview-snyk-*` recipes with a single `preview-trivy-test`**

Replace this whole block (currently lines 136–167):

```just
# just preview-snyk-test workbench
preview-snyk-test target="default" branch="$(git branch --show-current)" *opts="":
  WORKBENCH_DAILY_VERSION=$(just get-version workbench --type=daily --local) \
  WORKBENCH_PREVIEW_VERSION=$(just get-version workbench --type=preview --local) \
  PACKAGE_MANAGER_DAILY_VERSION=$(just get-version package-manager --type=daily --local) \
  CONNECT_DAILY_VERSION=$(just get-version connect --type=daily --local) \
  BRANCH="{{branch}}" \
  SNYK_ORG="{{SNYK_ORG}}" \
  GIT_SHA=$(git rev-parse --short HEAD) \
    python3 {{justfile_directory()}}/tools/snyk_bake_artifacts.py --target "{{target}}" --file "docker-bake.preview.hcl" test {{opts}}

# just snyk-monitor workbench
preview-snyk-monitor target="default" branch="$(git branch --show-current)" *opts="":
  WORKBENCH_DAILY_VERSION=$(just get-version workbench --type=daily --local) \
  WORKBENCH_PREVIEW_VERSION=$(just get-version workbench --type=preview --local) \
  PACKAGE_MANAGER_DAILY_VERSION=$(just get-version package-manager --type=daily --local) \
  CONNECT_DAILY_VERSION=$(just get-version connect --type=daily --local) \
  BRANCH="{{branch}}" \
  SNYK_ORG="{{SNYK_ORG}}" \
  GIT_SHA=$(git rev-parse --short HEAD) \
    python3 {{justfile_directory()}}/tools/snyk_bake_artifacts.py --target "{{target}}" --file "docker-bake.preview.hcl" monitor {{opts}}

# just snyk-sbom workbench
preview-snyk-sbom target="default" branch="$(git branch --show-current)" *opts="":
  WORKBENCH_DAILY_VERSION=$(just get-version workbench --type=daily --local) \
  WORKBENCH_PREVIEW_VERSION=$(just get-version workbench --type=preview --local) \
  PACKAGE_MANAGER_DAILY_VERSION=$(just get-version package-manager --type=daily --local) \
  CONNECT_DAILY_VERSION=$(just get-version connect --type=daily --local) \
  BRANCH="{{branch}}" \
  SNYK_ORG="{{SNYK_ORG}}" \
  GIT_SHA=$(git rev-parse --short HEAD) \
    python3 {{justfile_directory()}}/tools/snyk_bake_artifacts.py --target "{{target}}" --file "docker-bake.preview.hcl" sbom {{opts}}
```

with:

```just
# just preview-trivy-test workbench
preview-trivy-test target="default" branch="$(git branch --show-current)":
  WORKBENCH_DAILY_VERSION=$(just get-version workbench --type=daily --local) \
  WORKBENCH_PREVIEW_VERSION=$(just get-version workbench --type=preview --local) \
  PACKAGE_MANAGER_DAILY_VERSION=$(just get-version package-manager --type=daily --local) \
  CONNECT_DAILY_VERSION=$(just get-version connect --type=daily --local) \
  BRANCH="{{branch}}" \
  GIT_SHA=$(git rev-parse --short HEAD) \
    python3 {{justfile_directory()}}/tools/trivy_bake_artifacts.py --target "{{target}}" --file "docker-bake.preview.hcl"
```

- [ ] **Step 5: Verify Justfile parses**

Run: `just --list`
Expected: command lists recipes including `trivy-test` and `preview-trivy-test`, and no longer lists any `snyk-*` recipes. Should exit 0.

- [ ] **Step 6: Commit**

```bash
git add Justfile
git commit -m "Replace Snyk recipes with Trivy in Justfile"
```

---

## Task 4: Update `bake-test-push` composite action

**Files:**
- Modify: `.github/actions/bake-test-push/action.yml`

- [ ] **Step 1: Remove Snyk inputs from the `inputs:` block**

Delete these lines (currently lines 44–51):

```yaml
  snyk-org:
    description: Organization ID for Snyk
    default: ""
    type: string
  snyk-token:
    description: Token for authenticating with Snyk
    default: ""
    type: string
```

- [ ] **Step 2: Replace the Snyk setup/auth steps with Trivy setup**

Delete (currently lines 66–71):

```yaml
    - uses: snyk/actions/setup@master

    - name: Snyk auth
      shell: bash
      run: |
        snyk auth ${{ inputs.snyk-token }}
```

and insert in their place:

```yaml
    - name: Set up Trivy
      uses: aquasecurity/setup-trivy@v0.2.3
      with:
        cache: true
```

- [ ] **Step 3: Rewrite the `Scan` step to call `just trivy-test`**

Replace (currently lines 158–170):

```yaml
    - name: Scan
      continue-on-error: true
      env:
        SNYK_ORG: ${{ inputs.snyk-org }}
      shell: bash
      run: |
        if [[ "${{ inputs.scan-image }}" == "true" ]]; then
          if [[ "${{ inputs.push-image }}" == "true" ]]; then
            just snyk-monitor "${{ inputs.target }}" "${{ inputs.bakefile }}"
          else
            just snyk-test "${{ inputs.target }}" "${{ inputs.bakefile }}"
          fi
        fi
```

with:

```yaml
    - name: Scan
      continue-on-error: true
      shell: bash
      run: |
        if [[ "${{ inputs.scan-image }}" == "true" ]]; then
          just trivy-test "${{ inputs.target }}" "${{ inputs.bakefile }}"
        fi
```

- [ ] **Step 4: Update the SARIF upload category**

Change (currently lines 172–177):

```yaml
    - name: Upload results
      uses: github/codeql-action/upload-sarif@v3
      continue-on-error: true
      with:
          sarif_file: "container.sarif"
          category: "${{ inputs.target }}-snyk-vulnerabilities"
```

to:

```yaml
    - name: Upload results
      uses: github/codeql-action/upload-sarif@v3
      continue-on-error: true
      with:
          sarif_file: "container.sarif"
          category: "${{ inputs.target }}-trivy-vulnerabilities"
```

- [ ] **Step 5: Validate the YAML parses**

Run: `python3 -c "import yaml; yaml.safe_load(open('.github/actions/bake-test-push/action.yml'))"`
Expected: exits 0 with no output.

- [ ] **Step 6: Commit**

```bash
git add .github/actions/bake-test-push/action.yml
git commit -m "Switch bake-test-push action from Snyk to Trivy"
```

---

## Task 5: Update `build-bake.yaml` workflow

**Files:**
- Modify: `.github/workflows/build-bake.yaml` — remove `snyk-org` and `snyk-token` inputs from all 10 `bake-test-push` action invocations

- [ ] **Step 1: Remove the two Snyk input lines from every job**

In `.github/workflows/build-bake.yaml`, delete every occurrence of these two consecutive lines (they appear 10 times — once for each of the `base`, `connect`, `connect-content-init`, `content`, `package-manager`, `r-session-complete`, `workbench-session`, `workbench-session-init`, `workbench-positron-init`, and `workbench` jobs):

```yaml
          snyk-org: ${{ secrets.SNYK_ORG }}
          snyk-token: '${{ secrets.SNYK_TOKEN }}'
```

After removal, the trailing `bake-test-push` `with:` block for each job should end at `gcp-json: '${{ secrets.GCP_ARTIFACT_REGISTRY_JSON }}'` (or `soci-index: true` for the `workbench-session-init` job).

- [ ] **Step 2: Verify all Snyk references are gone from the workflow**

Run: `grep -n -i snyk .github/workflows/build-bake.yaml`
Expected: no output (exit code 1).

- [ ] **Step 3: Validate the YAML parses**

Run: `python3 -c "import yaml; yaml.safe_load(open('.github/workflows/build-bake.yaml'))"`
Expected: exits 0 with no output.

- [ ] **Step 4: Commit**

```bash
git add .github/workflows/build-bake.yaml
git commit -m "Remove Snyk inputs from build-bake workflow"
```

---

## Task 6: Delete obsolete Snyk files

**Files:**
- Delete: `tools/snyk_bake_artifacts.py`
- Delete: `connect/.snyk`
- Delete: `package-manager/.snyk`
- Delete: `r-session-complete/.snyk`
- Delete: `workbench/.snyk`
- Delete: `workbench-session/.snyk`

- [ ] **Step 1: Remove the Python wrapper and all `.snyk` policy files**

Run:

```bash
git rm tools/snyk_bake_artifacts.py \
       connect/.snyk \
       package-manager/.snyk \
       r-session-complete/.snyk \
       workbench/.snyk \
       workbench-session/.snyk
```

- [ ] **Step 2: Verify no Snyk references remain anywhere in the repo**

Run: `grep -r -i -l snyk . --exclude-dir=.git --exclude-dir=docs --exclude-dir=node_modules`
Expected: no output (exit code 1). The `--exclude-dir=docs` keeps the design spec, which mentions Snyk in historical context.

- [ ] **Step 3: Commit**

```bash
git commit -m "Remove obsolete Snyk wrapper and policy files"
```

---

## Task 7: Functional verification of Trivy wrapper

**Files:**
- None modified. This task verifies prior tasks against real built images.

This step requires Docker, the `trivy` CLI, and `just` installed locally. If the engineer cannot install Trivy locally (`brew install trivy` on macOS, or the script from `https://aquasecurity.github.io/trivy/latest/getting-started/installation/` on Linux), they should skip this task and let CI exercise the new wrapper on the next PR push.

- [ ] **Step 1: Build a small target locally**

Run: `just bake connect`
Expected: produces a local Docker image tagged `ghcr.io/rstudio/connect:<version>-ubuntu2204` (and aliases). May take several minutes.

- [ ] **Step 2: Run the new Trivy wrapper against it**

Run: `just trivy-test connect`
Expected:
- Exits 0
- Log line `Scanning N target(s): [...]`
- A file `container.sarif` is created in the repo root.

- [ ] **Step 3: Confirm the SARIF is valid JSON with at least one run**

Run: `python3 -c "import json; d=json.load(open('container.sarif')); print('runs:', len(d.get('runs', [])))"`
Expected: prints `runs: N` where N ≥ 1.

- [ ] **Step 4: Confirm the `connect/trivy.yaml` skip rules were applied**

Run: `python3 -c "import json; d=json.load(open('container.sarif')); locations=[loc for run in d['runs'] for res in run.get('results', []) for loc in res.get('locations', [])]; print([l for l in locations if '/opt/connect' in str(l)])"`
Expected: prints `[]` — no findings under `/opt/connect` because that path is in `skip-dirs`.

- [ ] **Step 5: Clean up local artifact**

Run: `rm container.sarif`
Expected: file removed.

- [ ] **Step 6: No commit needed**

Functional verification produces no new files to commit.

---

## Self-review notes

- **Spec coverage:** Tasks 1–6 cover every component in the spec (new wrapper, 7 trivy.yamls, Justfile, action.yml, workflow, deletions). Task 7 covers the "Testing" section. The "Trade-offs" section is informational — no implementation tasks needed.
- **Method consistency:** The wrapper uses `resolve_targets()` and `build_trivy_command()` consistently across Task 1's code blocks. SARIF output filename `container.sarif` is consistent between the wrapper (`OUTPUT_SARIF`), the upload step (Task 4 Step 4), and verification (Task 7 Step 3).
- **Trivy CLI flags used:** `image`, `--severity HIGH,CRITICAL`, `--format sarif`, `--output`, `--exit-code 0`, `--config`. All standard Trivy CLI v0.50+ flags; pinned action `aquasecurity/setup-trivy@v0.2.3` installs a compatible version.
- **No CVE-snoozing path:** matches spec — deferred until needed.