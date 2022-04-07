#!/usr/bin/env python3

# A CLI to retrieve product versions
#
# IMPORTANT:
#   All logging should go to stderr
#   ONLY the version number goes to stdout
#
# Example usage:
# ./get-version.py workbench --type=daily
# ./get-version.py connect --type=daily
# ./get-version.py package-manager --type=release
#
# Some modifications are allowed (for simplicity in CI):
#   - rstudio- prefix is removed
#   - -preview suffix is removed
#   - r-session prefixed products are replaced with workbench
#   - workbench prefixed products are replaced with workbench
#   - connect- prefixed products are replaced with connect
#   - version latest == release

import re
import requests
import json
import argparse
import sys


def clean_product_version(version: str) -> str:
    """
    Replace / alias "latest" with "release"

    :type version: str
    :rtype: str
    :param version: The current version being used
    :return: The cleaned/replaced version
    """
    if version == 'latest':
        version = 'release'
    return version


def clean_product_selection(product: str) -> str:
    """
    Clean up / alias products together for version determination
    - Remove rstudio- prefix
    - Remove -preview suffix
    - Convert r-session prefixed products to workbench
    - Convert workbench prefixed products to workbench
    - Convert connect- prefixed products to connect
    - Convert rsw -> workbench, rsc -> connect, rspm -> package-manager

    :rtype: str
    :param product: The current product being requested
    :return: The cleaned/replaced product name
    """
    pref = re.compile('^rstudio-')
    product = pref.sub('', product)

    suffix = re.compile('-preview$')
    product = suffix.sub('', product)

    rsw = re.compile('^rsw$')
    if rsw.match(product):
        product = 'workbench'

    rsc = re.compile('^rsc$')
    if rsc.match(product):
        product = 'connect'

    rspm = re.compile('^rspm$')
    if rspm.match(product):
        product = 'package-manager'

    session_pref = re.compile('^r-session')
    if session_pref.match(product):
        print(f"Swapping product '{product}' for 'workbench'", file=sys.stderr)
        product = 'workbench'

    workbench_pref = re.compile('^workbench')
    if workbench_pref.match(product):
        print(f"Swapping product '{product}' for 'workbench'", file=sys.stderr)
        product = 'workbench'

    connect_pref = re.compile('^connect-')
    if connect_pref.match(product):
        print(f"Swapping product '{product}' for 'connect'", file=sys.stderr)
        product = 'connect'

    return product


def rstudio_workbench_daily():
    version_json = download_json("https://dailies.rstudio.com/rstudio/spotted-wakerobin/index.json")
    return version_json['workbench']['platforms']['bionic']['version']


def download_json(url):
    raw_json = requests.get(url).content
    downloaded_json = json.loads(raw_json)
    return downloaded_json


def get_downloads_json():
    return download_json("https://rstudio.com/wp-content/downloads.json")


def rstudio_workbench_preview():
    downloads_json = get_downloads_json()
    return downloads_json['rstudio']['pro']['preview']['version']


def get_release_version(product, local=False):
    if local:
        return get_local_release_version(product)
    else:
        return get_actual_release_version(product)


def get_local_release_version(product):
    if product == 'workbench':
        prefix = 'RSW'
    elif product == 'connect':
        prefix = 'RSC'
    elif product == 'package-manager':
        prefix = 'RSPM'
    else:
        raise ValueError(f'Invalid product {product}')

    with open('Makefile', 'r') as f:
        content = f.read()

    vers = re.compile(f'{prefix}_VERSION \?= (.*)')
    res = vers.search(content)
    # from the first capture group
    output_version = res[1]
    return output_version


def get_actual_release_version(product):
    downloads_json = get_downloads_json()
    print(f"Getting release version for '{product}' from downloads.json", file=sys.stderr)
    if product == 'workbench':
        return downloads_json['rstudio']['pro']['stable']['version']
    elif product == 'connect':
        return downloads_json['connect']['installer']['focal']['version']
    elif product == 'package-manager':
        return downloads_json['rspm']['installer']['focal']['version']
    else:
        raise ValueError(f'Invalid product {product}')


def rstudio_connect_daily():
    connect_build_info = download_json("https://cdn.rstudio.com/connect/latest-packages.json")

    # just grab the first... all we need is a version string... (for now)
    return connect_build_info['packages'][0]['version']


def rstudio_pm_daily():
    latest_url = "https://cdn.rstudio.com/package-manager/ubuntu/amd64/rstudio-pm-main-latest.txt"
    raw_version = requests.get(latest_url).content
    return raw_version.decode('utf-8').replace('\n','')


if __name__ == "__main__":

    # ------------------------------------------
    # Argument definition
    # ------------------------------------------
    parser = argparse.ArgumentParser(description="Arguments to determine product version")
    parser.add_argument(
        "product",
        type=str,
        nargs=1,
        help="The product to search. One of 'connect', 'workbench' or 'package-manager'"
    )
    parser.add_argument(
        "--type",
        type=str,
        nargs=1,
        help="The type of version to retrieve. One of 'daily', 'preview' or 'release' (default: 'release')",
        default=["release"]
    )
    parser.add_argument(
        "--local", "-l",
        action="store_true",
        help="Whether to use the 'local' version for 'release'. Parsed from the local Makefile",
    )
    parser.add_argument(
        "--override", "-o",
        type=str,
        nargs=1,
        help="Whether to override the version. If set to 'auto' then it has no effect. (default: 'auto')",
        default=["auto"]
    )
    args = parser.parse_args()

    selected_product = args.product[0]
    version_type = args.type[0]
    override = args.override[0]
    local = args.local

    # ------------------------------------------
    # Alias arguments
    # ------------------------------------------
    selected_product = clean_product_selection(selected_product)
    version_type = clean_product_version(version_type)

    # ------------------------------------------
    # Argument checking
    # (version checking is per-product)
    # ------------------------------------------
    if selected_product not in ['workbench', 'package-manager', 'connect']:
        print(
            f"ERROR: Please choose a product from 'connect', 'workbench' or 'package-manager'. "
            f"You provided '{selected_product}'",
            file=sys.stderr
        )
        exit(1)

    print(f"Providing version for product: '{selected_product}' and version type: '{version_type}'", file=sys.stderr)

    # set a default value - this should never make it all the way through
    version = 'UNDEFINED'

    # ------------------------------------------
    # Use override, if defined
    # ------------------------------------------
    if override != 'auto':
        print("The --override arg was set with a value other than 'auto'", file=sys.stderr)
        print("Overriding version_type with: 'manual'", file=sys.stderr)
        version_type = 'manual'
        print(f"Overriding version with override: '{override}'", file=sys.stderr)
        version = override
    # ------------------------------------------
    # Product "switch" statements
    # ------------------------------------------
    elif selected_product == 'workbench':
        if version_type == 'daily':
            version = rstudio_workbench_daily()
        elif version_type == 'preview':
            version = rstudio_workbench_preview()
        elif version_type == 'release':
            version = get_release_version(selected_product, local)
        else:
            print(
                f"ERROR: RStudio Workbench does not have the notion of a '{version_type}' version",
                file=sys.stderr
            )
            exit(1)
    elif selected_product == 'connect':
        if version_type == 'daily':
            version = rstudio_connect_daily()
        elif version_type == 'release':
            version = get_release_version(selected_product, local)
        else:
            print(
                f"ERROR: RStudio Connect does not have the notion of a '{version_type}' version",
                file=sys.stderr
            )
            exit(1)
    elif selected_product == 'package-manager':
        if version_type == 'release':
            version = get_release_version(selected_product, local)
        elif version_type == 'daily':
            version = rstudio_pm_daily()
        else:
            print(
                f"ERROR: RStudio Package Manager does not have the notion of a '{version_type}' version",
                file=sys.stderr
            )
            exit(1)
    else:
        print(
            f"ERROR: product '{selected_product}' with '{version_type}' version is not defined",
            file=sys.stderr
        )
        exit(1)

    print(f"Got {version_type} version: '{version}'", file=sys.stderr)
    print(version)
