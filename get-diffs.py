#!/usr/bin/env python3

# A CLI to retrieve changed directories
#
# IMPORTANT:
#   All logging should go to stderr
#   ONLY the filtered output goes to stdout
#
# Example usage:
# echo "$MATRIX" | get-diffs.py
# get-diffs.py --input matrix-preview.json

import re
# import requests
import json
import argparse
import sys
import os
import typing
import subprocess


def uniq_list(input: typing.List[typing.Any]):
    output = []
    for item in input:
        if item in output:
            continue
        else:
            output.append(item)
    return output


def get_changed_dirs(commit : str, dirs : typing.List[str] = []):
    changed_files = get_changed_files(commit, dirs)
    changed_dirs = [os.path.dirname(f) for f in changed_files]
    return uniq_list(changed_dirs)


def get_changed_files(commit : str, dirs : typing.List[str] = []):
    dirs_arg = ' '.join(dirs)
    if len(dirs_arg) == 0:
        dirs_arg = '.'
    res = subprocess.check_output(['git', 'diff', '--name-only', '--find-renames',  commit, '--', dirs_arg])
    changed_files = res.decode('utf-8').split('\n')
    return [x for x in changed_files if len(x) > 0]


def get_current_commit():
    res = subprocess.check_output(['git', 'show', "--format='%H'", '-q'])
    return res.decode('utf-8').strip().replace("'",'')


def get_merge_base(commit1 : str, commit2 : str):
    res = subprocess.check_output(['git', 'merge-base', commit1, commit2])
    return res.decode('utf-8').strip()


def get_dirs_from_json(json_input: typing.List[typing.Dict]):
    base_data = [m['dir'] for m in json_input]
    uniq_list = []
    for item in base_data:
        if item not in uniq_list:
            uniq_list.append(item)
    return uniq_list


def get_dirs_from_find(base_dir):
    find_dockerfile = re.compile("Dockerfile$")

    dir_list = []
    for (root, dirs, file) in os.walk(base_dir):
        for f in file:
            if find_dockerfile.match(f):
                dir_list.append(root)

    return dir_list


if __name__ == "__main__":

    # ------------------------------------------
    # Argument definition
    # ------------------------------------------
    parser = argparse.ArgumentParser(description="Arguments to determine how diffs are detected")
    parser.add_argument(
        "--file",
        type=str,
        nargs=1,
        help="The input matrix.json file to parse"
    )
    parser.add_argument(
        "--all", "-a",
        action="store_true",
        help="Whether to bypass checks and return the input",
    )
    parser.add_argument(
        "--find", "-f",
        action="store_true",
        help="Whether to ignore input and find directories that have a Dockerfile",
    )
    parser.add_argument(
        "--dirs", "-d",
        type=str,
        action='extend',
        nargs="+",
        help="The directories to check for differences",
        default=[]
    )
    args = parser.parse_args()

    file = args.file
    find = args.find
    dirs = args.dirs
    return_all = args.all

    # ----------------------------------------------------------
    # Determine base directories to check
    # ----------------------------------------------------------
    directories_base = []
    if find:
        print("Finding directories with a Dockerfile present", file=sys.stderr)
        # TODO: figure out core directory in more savvy fashion...?
        directories_base = get_dirs_from_find(".")
    elif file:
        file = file[0]
        print(f"Reading configuration from file: {file}", file=sys.stderr)
        with open(file, 'r') as f:
            file_input = f.read()
            matrix_data = json.loads(file_input)
            directories_base = get_dirs_from_json(matrix_data)
    elif dirs:
        print("Using directories specified on command", file=sys.stderr)
        directories_base = dirs

    # TODO: standardize directory format to have leading ./ or not
    print(f"Base directories: {directories_base}", file=sys.stderr)

    print(f"All? {return_all}", file=sys.stderr)

    cc = get_current_commit()
    print(f'Current commit: {cc}', file=sys.stderr)
    print(f"Merge Base: {get_merge_base(cc, 'main')}", file=sys.stderr)
    print(f"Changed Directories: {get_changed_dirs('main')}")

    # ----------------------------------------------------------
    # Determine which base directories have diffs
    # ----------------------------------------------------------

    # output
    print("Done")
