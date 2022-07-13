#!/usr/bin/env python3

import re
import json
import argparse
import sys

ALL_PACKAGES=["connect", "package-manager", "workbench"]
ALL_TYPES=["release", "preview", "daily"]
ALL_OS=["jammy", "bionic"]

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Arguments to generate matrix")
    parser.add_argument(
        "-p",
        "--packages",
        nargs="+",
        default=["all"]
    )
    parser.add_argument(
        "-o",
        "--os",
        nargs="+",
        default=["all"]
    )
    parser.add_argument(
        "-t",
        "--types",
        nargs="+",
        default=["all"]
    )
    args = parser.parse_args()

    selected_packages = ALL_PACKAGES if "all" in args.packages else args.packages
    selected_os = ALL_OS if "all" in args.os else args.os
    selected_types = ALL_TYPES if "all" in args.types else args.types

    matrix_conf = []

    for package in selected_packages:
        for oss in selected_os:
            for build_type in selected_types:
                if build_type == "preview" and package in ["connect", "package-manager"]:
                    continue
                matrix_conf.append({
                    "package": package,
                    "os": oss,
                    "type": build_type
                })
    
    print(f"Generated matrix conf: {json.dumps(matrix_conf)}", file=sys.stderr)
    print(json.dumps(matrix_conf))
