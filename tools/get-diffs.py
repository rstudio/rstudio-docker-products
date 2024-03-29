#!/usr/bin/env python3

# A CLI to retrieve changed directories
#
# IMPORTANT:
#   All logging should go to stderr
#   ONLY the filtered output goes to stdout
#
# Example usage:
# echo "$MATRIX" | get-diffs.py -i
# get-diffs.py -f matrix-preview.json
# get-diffs.py -f matrix-preview.json -a
#
# Help:
# usage: get-diffs.py [-h] [--file FILE] [--stdin] [--all] [--dirs DIRS [DIRS ...]]
#
# Arguments to determine how diffs are detected
#
# optional arguments:
# -h, --help            show this help message and exit
# --file FILE, -f FILE  The input matrix.json file to parse
# --stdin, -i           Read matrix.json from stdin
# --all, -a             Whether to bypass checks and return the input
# --dirs DIRS [DIRS ...], -d DIRS [DIRS ...]
#                       A subset of directories to check for differences

import re
import json
import argparse
import sys
import os
import typing
import subprocess


def uniq_list(input: typing.List[typing.Any]) -> typing.List:
    output = []
    for item in input:
        if item not in output:
            output.append(item)
    return output


def get_changed_dirs(commit : str, dirs=None) -> typing.List[str]:
    if dirs is None:
        dirs = []
    changed_files = get_changed_files(commit, dirs)
    changed_dirs = [os.path.dirname(f) for f in changed_files]
    return uniq_list(changed_dirs)


def get_changed_files(commit : str, dirs=None) -> typing.List[str]:
    if dirs is None:
        dirs = []
    command = ['git', 'diff', '--name-only', '--find-renames',  commit, '--'] + dirs
    # print(f"Command: {command}", file=sys.stderr)
    res = subprocess.check_output(command)
    changed_files = res.decode('utf-8').split('\n')
    return [x for x in changed_files if len(x) > 0]


def get_current_commit() -> str:
    res = subprocess.check_output(['git', 'show', "--format='%H'", '-q'])
    return res.decode('utf-8').strip().replace("'", '')


def get_merge_base(commit1 : str, commit2 : str) -> str:
    res = subprocess.check_output(['git', 'merge-base', commit1, commit2])
    return res.decode('utf-8').strip()


def filter_json_by_dirs(json_input: typing.List[typing.Dict], dirs=None) -> typing.List[dict]:
    if dirs is None:
        dirs = []
    output_data = []
    for m in json_input:
        if m['dir'] in dirs:
            output_data.append(m)
    return output_data


def get_dirs_from_json(json_input: typing.List[typing.Dict]) -> typing.List[str]:
    base_data = [m['dir'] for m in json_input]
    return uniq_list(base_data)


if __name__ == "__main__":

    # ------------------------------------------
    # Argument definition
    # ------------------------------------------
    parser = argparse.ArgumentParser(description="Arguments to determine how diffs are detected")
    parser.add_argument(
        "--file", "-f",
        type=str,
        nargs=1,
        help="The input matrix.json file to parse"
    )
    parser.add_argument(
        "--stdin", "-i",
        action="store_true",
        help="Read matrix.json from stdin"
    )
    parser.add_argument(
        "--all", "-a",
        action="store_true",
        help="Whether to bypass checks and return the input",
    )
    parser.add_argument(
        "--dirs", "-d",
        type=str,
        action='extend',
        nargs="+",
        help="A subset of directories to check for differences",
        default=[]
    )
    args = parser.parse_args()

    file = args.file
    dirs = args.dirs
    return_all = args.all
    read_stdin = args.stdin

    # ----------------------------------------------------------
    # Read in base matrix.json data
    # ----------------------------------------------------------
    matrix_data = []
    if read_stdin:
        print("Reading configuration from stdin, due to -i/--stdin", file=sys.stderr)
        file_input = sys.stdin.read()
        stripped_input = file_input.strip()
        if len(stripped_input) == 0:
            print("WARNING: input was empty", file=sys.stderr)
        else:
            # TODO: invalid JSON input returns a nasty error we should catch
            matrix_data = json.loads(file_input)
    elif file:
        file = file[0]
        print(f"Reading configuration from file: {file}", file=sys.stderr)
        with open(file, 'r') as f:
            file_input = f.read()
            matrix_data = json.loads(file_input)
    else:
        print("ERROR: no -f/--file parameter provided. matrix.json input is needed", file=sys.stderr)
        exit(2)

    # ----------------------------------------------------------
    # Determine base directories to check
    # ----------------------------------------------------------
    directories_base = []
    if dirs:
        print("Using directories specified on command", file=sys.stderr)
        directories_base = dirs

    # standardize paths to not have ./
    directories_base = [os.path.relpath(d) for d in directories_base]

    print(f"Base directories: {directories_base}", file=sys.stderr)

    if return_all:
        print('Returning input plus filters, not computing diff, due to -a/--all', file=sys.stderr)
        print(filter_json_by_dirs(matrix_data, directories_base))
        exit(0)

    # ----------------------------------------------------------
    # Determine which base directories have diffs
    # ----------------------------------------------------------

    cc = get_current_commit()
    mb = get_merge_base(cc, 'main')
    print(f'Current commit: {cc}', file=sys.stderr)
    print(f"Merge Base: {mb}", file=sys.stderr)
    changed_directories = get_changed_dirs(mb, directories_base)

    # exclude the root directory...
    changed_directories_no_root = [d for d in changed_directories if len(d) > 0]
    print(f"Changed directories: {changed_directories_no_root}", file=sys.stderr)

    output_structure = []
    print(filter_json_by_dirs(matrix_data, changed_directories_no_root))
    exit(0)
