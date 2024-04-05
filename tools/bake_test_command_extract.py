import argparse
import json
import subprocess
from pathlib import Path

PROJECT_DIR = Path(__file__).resolve().parents[1]


parser = argparse.ArgumentParser(
    description="Extract a test command from a bake plan"
)
parser.add_argument("image_name")
parser.add_argument("operating_system")
parser.add_argument("--builder", default="posit-builder")


def get_bake_plan():
    cmd = ["docker", "buildx", "bake", "-f", str(PROJECT_DIR / "docker-bake.hcl"), "--print"]
    p = subprocess.run(cmd, capture_output=True)
    if p.returncode != 0:
        print(f"Failed to get bake plan: {p.stderr}")
        exit(1)
    return json.loads(p.stdout.decode("utf-8"))


def get_targets(plan, image_name, operating_system):
    targets = {}
    for target_name, target_spec in plan["target"].items():
        if target_name.startswith(f"{image_name}-{operating_system}"):
            targets[target_name] = target_spec
    return targets


def build_test_command(target_name, target_spec, builder):
    cmd = [
        "docker",
        "buildx",
        "--builder",
        builder,
        "build",
        "--allow",
        "security.insecure",
        "--target",
        "test",
    ]
    cmd.extend(["--build-context", f"build=oci-layout://{PROJECT_DIR / '.out' / target_name}"])
    for name, value in target_spec["args"].items():
        cmd.extend(["--build-arg", f'{name}="{value}"'])
    cmd.extend(["--file", str(PROJECT_DIR / target_spec["context"] / target_spec["dockerfile"])])
    cmd.append(str(PROJECT_DIR / target_spec["context"]))
    return cmd


def main():
    args = parser.parse_args()
    plan = get_bake_plan()
    targets = get_targets(plan, args.image_name, args.operating_system)
    for target_name, target_spec in targets.items():
        cmd = build_test_command(target_name, target_spec, args.builder)
        print(" ".join(cmd))


if __name__ == "__main__":
    main()
