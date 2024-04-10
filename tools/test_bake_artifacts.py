import argparse
import json
import subprocess
from pathlib import Path

PROJECT_DIR = Path(__file__).resolve().parents[1]


parser = argparse.ArgumentParser(
    description="Extract a test command from a bake plan"
)
parser.add_argument("--file", default="docker-bake.hcl")


def get_bake_plan(bake_file="docker-bake.hcl"):
    cmd = ["docker", "buildx", "bake", "-f", str(PROJECT_DIR / bake_file), "--print"]
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


def build_test_command(target_name, target_spec):
    context_path = PROJECT_DIR / target_spec["context"]
    test_path = context_path / "test"
    cmd = [
        "docker",
        "run",
        "-t",
        "--rm",
        "--privileged",
        f"--mount=type=bind,source={test_path},destination=/test",
    ]
    for name, value in target_spec["args"].items():
        cmd.extend(["--env", f'{name}="{value}"'])
    cmd.append(target_spec["tags"][0])
    cmd.extend(["/test/run_tests.sh"])
    return cmd


def run_cmd(target_name, cmd):
    p = subprocess.run(" ".join(cmd), shell=True)
    if p.returncode != 0:
        print(f"{target_name} test failed with exit code {p.returncode}")
    return p.returncode


def main():
    args = parser.parse_args()
    plan = get_bake_plan(args.file)
    result = 0
    failed_targets = []
    for target_name, target_spec in plan["target"].items():
        cmd = build_test_command(target_name, target_spec)
        print(" ".join(cmd))
        return_code = run_cmd(target_name, cmd)
        if return_code != 0:
            failed_targets.append(target_name)
            result = 1
    print(f"Failed targets: {failed_targets}")
    exit(result)


if __name__ == "__main__":
    main()
