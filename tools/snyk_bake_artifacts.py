#!/usr/bin/env python3
"""
Run Snyk vulnerability scanning against bake artifacts by group/target and build definition.

./snyk_bake_artifacts.py --file <build definition> --target <build target or group> <snyk command> <snyk options (no leading --)>
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
SARIF_PATH_FILTERS = {
    "connect": ["/opt/rstudio-connect/examples"],
    "workbench-for-google-cloud-workstations": [
        "/usr/lib/google-cloud-sdk",
        "/usr/share",
        "/usr/bin",
        "/usr/local/go",
    ],
}

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
                f"--project-name={target_spec['tags'][-1]}",
                "--sarif-file-output=container.sarif",
                "--json-file-output=container.json",
                "--severity-threshold=high",
                f"--policy-path={target_spec['context']}",
            ])
            if "product" not in target_spec["context"]:
                cmd.append("--exclude-base-image-vulns")
        elif snyk_command == "monitor":
            cmd.extend([
                "--format=legacy",
                f"--org={SNYK_ORG}",
                f"--file={str(docker_file_path)}",
                "--platform=linux/amd64",
                f"--project-name={target_spec['tags'][-1]}",
                "--project-environment=distributed",
                "--project-lifecycle=production",
                f"--policy-path={target_spec['context']}",
            ])
            if "product" not in target_spec["context"]:
                cmd.append("--exclude-base-image-vulns")
            tags = f"--project-tags=product={target_spec['context']},image_tag={target_spec['tags'][1]},os_distro=ubuntu,os_version=22.04"
            version = get_version(target_spec)
            if version:
                tags += f",version={version}"
            image_type = get_image_type(target_spec)
            tags += f",image_type={image_type}"
            cmd.append(tags)
        elif snyk_command == "sbom":
            cmd.append("--format=cyclonedx1.4+json")
    cmd.append(target_spec["tags"][0])
    if snyk_command == "sbom":
        cmd.append(f"> {target_name}_sbom.json")
    return cmd


def filter_sarif_file(target_spec):
    with open("container.sarif", "r") as f:
        c_sarif = json.load(f)
    with open("container.json", "r") as f:
        c_json = json.load(f)
    c_sarif_paths = c_sarif["runs"]
    c_sarif_root = c_sarif_paths.pop(0)
    c_json_paths = c_json["applications"]
    filter_paths = SARIF_PATH_FILTERS.get(target_spec["context"], [])
    filtered_c_sarif_paths = [c_sarif_root]
    if len(c_sarif_paths) != len(c_json_paths):
        LOGGER.error("SARIF and JSON number of discovered paths do not match")
        return
    for i in range(len(c_sarif_paths)):
        if c_json_paths[i]["dependencyCount"] != c_sarif_paths[i]["tool"]["driver"]["properties"]["artifactsScanned"]:
            LOGGER.warning(
                f"Artifact count in JSON, {c_json_paths[i]['dependencyCount']}, "
                f"differs from artifact count in SARIF, "
                f"{c_sarif_paths[i]['tool']['driver']['properties']['artifactsScanned']}, for "
                f"{c_json_paths[i]['displayTargetFile']}. This may cause incorrect filtering in the SARIF file."
            )
        if not any(p in c_json_paths[i]["targetFile"] for p in filter_paths):
            filtered_c_sarif_paths.append(c_sarif_paths[i])
    c_sarif["runs"] = filtered_c_sarif_paths
    num_filtered_paths = len(c_sarif_paths) - len(filtered_c_sarif_paths)
    LOGGER.info(f"Filtered {num_filtered_paths} paths from SARIF file")
    with open("container.sarif", "w") as f:
        json.dump(c_sarif, f, indent=2)


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
        if target_spec["context"] in SARIF_PATH_FILTERS and args.command == "test":
            LOGGER.info("Filtering SARIF output file for excluded paths...")
            filter_sarif_file(target_spec)
    LOGGER.info(f"Failed targets: {failed_targets}")
    exit(result)


if __name__ == "__main__":
    main()
