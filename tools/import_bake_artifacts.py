#!/usr/bin/env python3
"""
Run tests against bake artifacts by group/target and build definition.

./test_bake_artifacts.py --file <build definition> --target <build target or group>
"""

import argparse
import json
import subprocess
from pathlib import Path

PROJECT_DIR = Path(__file__).resolve().parents[1]


parser = argparse.ArgumentParser(
    description="Import one or more bake artifacts from tar files for reuse"
)
parser.add_argument("--archive-path", type=Path, default=PROJECT_DIR / ".out")


def main():
    args = parser.parse_args()
    if args.archive_path:
        for archive in args.archive_path.glob("*.tar"):
            print(f"Importing {archive}")
            cmd = ["docker", "image", "load", "--input", archive]
            p = subprocess.run(cmd)
            if p.returncode != 0:
                print(f"Failed to import {archive}: {p.returncode}")


if __name__ == "__main__":
    main()
