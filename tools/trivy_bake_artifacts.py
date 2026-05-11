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
