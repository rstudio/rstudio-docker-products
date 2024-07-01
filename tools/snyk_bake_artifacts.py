#!/usr/bin/env python3
"""
Run tests against bake artifacts by group/target and build definition.

./test_bake_artifacts.py --file <build definition> --target <build target or group>
"""

import argparse
import json
import logging
import os
import subprocess
import sys
from pathlib import Path

logging.basicConfig(stream=sys.stdout, level=logging.INFO)
LOGGER = logging.getLogger(__name__)
SNYK_ORG = os.getenv("SNYK_ORG")
SERVICE_IMAGES = ["workbench-for-microsoft-azure=ml", "workbench-for-google-cloud-workstations"]

PROJECT_DIR = Path(__file__).resolve().parents[1]


parser = argparse.ArgumentParser(
    description="Extract a snyk container command from a bake plan"
)
parser.add_argument("--file", default="docker-bake.hcl")
parser.add_argument("--target", default="default")
parser.add_argument("command", choices=["test", "monitor", "sbom"])
parser.add_argument(
    "opts",
    nargs="*",
    help="Additional options to pass to snyk container command in the format of 'option=value' with no leading '--'. If no options are provided, a default set of options will be used.",
)


def get_bake_plan(bake_file="docker-bake.hcl", target="default"):
    cmd = ["docker", "buildx", "bake", "-f", str(PROJECT_DIR / bake_file), "--print", target]
    run_env = os.environ.copy()
    p = subprocess.run(cmd, capture_output=True, env=run_env)
    if p.returncode != 0:
        LOGGER.error(f"Failed to get bake plan: {p.stderr}")
        exit(1)
    return json.loads(p.stdout.decode("utf-8"))


def render_options(opts):
    rendered = [f"--{opt}" for opt in opts]
    return rendered


def get_version(target_spec):
    version = target_spec["args"].get("RSW_VERSION") or target_spec["args"].get("RSC_VERSION") or target_spec["args"].get("RSPM_VERSION")
    return version


def get_image_type(target_spec):
    if target_spec["context"] in SERVICE_IMAGES:
        return "service"
    return "generic"


def build_snyk_command(target_name, target_spec, snyk_command, opts):
    context_path = PROJECT_DIR / target_spec["context"]
    docker_file_path = context_path / "Dockerfile.ubuntu2204"  # TODO: make operating system extension dynamic
    cmd = [
        "snyk",
        "container",
        snyk_command,
    ]
    if opts:
        cmd.extend(render_options(opts))
    else:
        if snyk_command == "test":
            cmd.extend([
                "--format=legacy",
                f"--org={SNYK_ORG}",
                f"--file={str(docker_file_path)}",
                "--platform=linux/amd64",
                f"--project-name={target_name}",
            ])
        elif snyk_command == "monitor":
            cmd.extend([
                "--format=legacy",
                f"--org={SNYK_ORG}",
                f"--file={str(docker_file_path)}",
                "--platform=linux/amd64",
                f"--project-name={target_name}",
                "--project-environment=distributed",
                "--project-lifecycle=production",
            ])
            tags = f"--project-tags=product={target_spec['context']},image_tag={target_spec['tags'][0]},os_distro=ubuntu,os_version=22.04"
            version = get_version(target_spec)
            if version:
                tags += f",version={version}"
            image_type = get_image_type(target_spec)
            tags += f",image_type={image_type}"
            cmd.append(tags)
    cmd.append(target_spec["tags"][0])
    return cmd


def run_cmd(target_name, cmd):
    LOGGER.info(f"Running tests for {target_name}")
    LOGGER.info(f"{' '.join(cmd)}")
    p = subprocess.run(" ".join(cmd), shell=True)
    if p.returncode != 0:
        LOGGER.error(f"{target_name} test failed with exit code {p.returncode}")
    return p.returncode


def main():
    args = parser.parse_args()
    plan = get_bake_plan(args.file, args.target)
    result = 0
    failed_targets = []
    targets = {}
    for k in plan["group"][args.target]["targets"]:
        for target_name, target_spec in plan["target"].items():
            if target_name.startswith(k):
                targets[target_name] = target_spec
    LOGGER.info(f"Testing {len(targets.keys())} targets: {targets.keys()}")
    for target_name, target_spec in targets.items():
        cmd = build_snyk_command(target_name, target_spec, args.command, args.opts)
        LOGGER.debug(" ".join(cmd))
        return_code = run_cmd(target_name, cmd)
        if return_code != 0:
            failed_targets.append(target_name)
            result = 1
    LOGGER.info(f"Failed targets: {failed_targets}")
    exit(result)


if __name__ == "__main__":
    main()
