#!/usr/bin/env python3
"""
Export bake artifacts as tar files for later reuse.

./export_bake_artifacts.py --file <build definition> --target <build target or group> --output-path <output path>
"""

import argparse
import json
import logging
import subprocess
from pathlib import Path

LOGGER = logging.getLogger(__name__)
PROJECT_DIR = Path(__file__).resolve().parents[1]


parser = argparse.ArgumentParser(
    description="Export one or more bake artifacts to tar files for reuse"
)
parser.add_argument("--file", default="docker-bake.hcl")
parser.add_argument("--target", default="default")
parser.add_argument("--output-path", default=PROJECT_DIR / ".out")


def get_bake_plan(bake_file="docker-bake.hcl", target="default"):
    cmd = ["docker", "buildx", "bake", "-f", str(PROJECT_DIR / bake_file), "--print", target]
    p = subprocess.run(cmd, capture_output=True)
    if p.returncode != 0:
        LOGGER.error(f"Failed to get bake plan: {p.stderr}")
        exit(1)
    return json.loads(p.stdout.decode("utf-8"))


def build_export_command(target_name, target_spec, output_path):
    output_file = Path(output_path) / f"{target_name}.tar"
    cmd = [
        "docker",
        "image",
        "save",
        "--output",
        f"{output_file}",
        " ".join(target_spec["tags"]),
    ]
    return cmd


def run_cmd(target_name, cmd):
    p = subprocess.run(" ".join(cmd), shell=True)
    if p.returncode != 0:
        LOGGER.error(f"{target_name} failed to export: {p.returncode}")
    return p.returncode


def main():
    args = parser.parse_args()
    plan = get_bake_plan(args.file, args.target)
    output = args.output_path
    if not Path(output).exists():
        Path(output).mkdir(parents=True)
    LOGGER.info(f"Exporting {len(plan['target'].keys())} targets: {plan['target'].keys()}")
    for target_name, target_spec in plan["target"].items():
        LOGGER.info(f"Exporting {target_name}")
        cmd = build_export_command(target_name, target_spec, output)
        run_cmd(target_name, cmd)


if __name__ == "__main__":
    main()