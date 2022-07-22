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
import pathlib
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


def get_changed_dirs(commit: str, dirs: typing.List[str] = None) -> typing.List[str]:
    if dirs is None:
        dirs = []
    changed_files = get_changed_files(commit, dirs)
    changed_dirs = [os.path.dirname(f) for f in changed_files]
    return uniq_list(changed_dirs)


def get_changed_files(commit: str, dirs: typing.List[str] = None) -> typing.List[str]:
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


def get_parent_commit(n: int = 1) -> str:
    res = subprocess.check_output(['git', 'log', '-n', 1, '--pretty=%P', '|', 'cut', '-f', n])
    return res.decode('utf-8').strip().replace("'", '')


def get_merge_base(commit1: str, commit2: str) -> str:
    print(commit2, file=sys.stderr)
    res = subprocess.check_output(['git', 'merge-base', commit1, commit2])
    return res.decode('utf-8').strip()


def is_dir_changed(input_dir: str, changed_dirs: typing.List[str] = None, include_parent: bool = False) -> bool:
    # NOTE: python3.9+ feature only
    i = pathlib.PurePath(input_dir)
    if changed_dirs is None:
        return False
    else:
        for changed_dir in changed_dirs:
            # NOTE: python3.9+ feature only
            p = pathlib.PurePath(changed_dir)

            # if a subdirectory changed
            if p.is_relative_to(input_dir):
                return True

            # also if a parent directory changed
            if include_parent & i.is_relative_to(changed_dir):
                return True
    return False


def filter_json_by_dirs(json_input: typing.List[typing.Dict], dirs: typing.List[str] = None) -> typing.List[dict]:
    if dirs is None:
        dirs = []
    output_data = []
    for m in json_input:
        if is_dir_changed(m['dir'], dirs):
            output_data.append(m)
    return output_data


def get_dirs_from_json(json_input: typing.List[typing.Dict]) -> typing.List[str]:
    base_data = [m['dir'] for m in json_input]
    return uniq_list(base_data)


def any_important_changed_files(commit: str, important_files: typing.List[str]) -> bool:
    all_changed_files = get_changed_files(mb, ['.'])
    important_changed_files = []
    print(f"Changed files: {all_changed_files}", file=sys.stderr)
    for i_file in important_files:
        # any important_file sub-path of changed
        # NOTE: python3.9+ feature only
        if any([pathlib.PurePath(f).is_relative_to(i_file) for f in all_changed_files]):
            important_changed_files.append(i_file)
    if len(important_changed_files) > 0:
        print(f"Important changed files. Returning all diffs: {important_changed_files}", file=sys.stderr)
        return True
    return False


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
        type=str,
        nargs='?',
        default=['false'],
        const=['true'],
        help="Whether to bypass checks and return the input",
    )
    parser.add_argument(
        "--target", "-t",
        type=str,
        nargs=1,
        default=['main'],
        help="The merge target to reference",
    )
    # uses type "str" to look for "true" (and play nicely with GHA)
    parser.add_argument(
        "--use-parent", "-p",
        type=str,
        nargs='?',
        default=['false'],
        const=['true'],
        help="Whether to use the first parent commit as the target (when 'true')",
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
    target = args.target[0]
    return_all = len(args.all) == 0 or args.all[0].lower() == 'true'
    use_parent = len(args.use_parent) == 0 or args.use_parent[0].lower() == 'true'
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
        if len(directories_base) == 0:
            print(matrix_data)
        else:
            print(filter_json_by_dirs(matrix_data, directories_base))
        exit(0)

    # ----------------------------------------------------------
    # Determine which base directories have diffs
    # ----------------------------------------------------------

    if use_parent:
        target = get_parent_commit(1)
        print(f"Using parent commit to overwrite the `target` (-p / --parent): {target}")

    cc = get_current_commit()
    mb = get_merge_base(cc, target)
    print(f'Current commit: {cc}', file=sys.stderr)
    print(f"Merge Base: {mb}", file=sys.stderr)
    changed_directories = get_changed_dirs(mb, directories_base)

    # exclude the root directory...
    changed_directories_no_root = [d for d in changed_directories if len(d) > 0]
    print(f"Changed directories: {changed_directories_no_root}", file=sys.stderr)

    # ----------------------------------------------------------
    # Determine if any important diffs in the root directory (ci, etc.)
    # ----------------------------------------------------------

    # these are "shared resources" that get used in the build pipeline
    important_files = [
        '.github/workflows',
        'get-diffs.py', 'get-version.py',
        'matrix-preview.json', 'matrix-latest.json',
        'content/matrix.json'
    ]
    if any_important_changed_files(mb, important_files):
        print(matrix_data)
    else:
        print(filter_json_by_dirs(matrix_data, changed_directories))
    exit(0)
