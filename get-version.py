import re
import requests
import json
import argparse


# rstudio-workbench daily
def rstudio_workbench_daily():
    daily_url = "https://dailies.rstudio.com/rstudioserver/pro/bionic/x86_64/"
    raw_daily = requests.get(daily_url).content

    version_regex = re.compile('rstudio-workbench-([0-9\.\-]*)-amd64.deb')
    version_match = version_regex.search(str(raw_daily))

    # group 0 = whole match, group 1 = first capture group
    return version_match.group(1)


def rstudio_workbench_preview():
    downloads_json_url = "https://rstudio.com/wp-content/downloads.json"
    raw_downloads_json = requests.get(downloads_json_url).content

    downloads_json = json.loads(raw_downloads_json)

    return downloads_json['rstudio']['pro']['preview']['version']


def rstudio_connect_daily():
    latest_url = "https://cdn.rstudio.com/connect/latest-packages.json"

    raw_content = requests.get(latest_url).content
    connect_build_info = json.loads(raw_content)

    # just grab the first... all we need is a version string... (for now)
    return connect_build_info['packages'][0]['version']


if __name__ == "__main__":
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
        default='release'
    )
    args = parser.parse_args()

    selected_product = args.product[0]
    version_type = args.type[0]

    if selected_product not in ['workbench', 'package-manager', 'connect']:
        print(
            f"ERROR: Please choose a product from 'connect', 'workbench' or 'package-manager'. "
            f"You provided '{selected_product}'"
        )
        exit(1)

    if version_type not in ['daily', 'preview', 'release']:
        print(
            f"ERROR: Please choose a version type from 'daily', 'preview' or 'release'. "
            f"You provided '{version_type}'"
        )
        exit(1)

    print(f"Providing version for product: '{selected_product}' and version type: '{version_type}'")
