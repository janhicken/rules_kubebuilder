#!/usr/bin/env python3
import base64
import json
import sys

from distutils.version import StrictVersion


def extract_platform(file_name: str) -> str:
    # envtest-v1.28.0-darwin-amd64.tar.gz
    without_ext = file_name.removesuffix(".tar.gz")
    name_parts = without_ext.split("-")
    os = name_parts[2]
    arch = name_parts[3]
    return f"{os}_{arch}"


def encode_sri(sha512_hex: str) -> str:
    sha512_bytes = bytes.fromhex(sha512_hex)
    sha512_base64 = str(base64.b64encode(sha512_bytes), "utf-8")
    return f"sha512-{sha512_base64}"


def transform_release(artifacts: dict) -> dict:
    return {
        extract_platform(file_name): encode_sri(details["hash"])
        for file_name, details in artifacts.items()
    }


if __name__ == "__main__":
    min_version = StrictVersion(sys.argv[1])
    releases = json.load(sys.stdin)

    versions = {
        version.removeprefix("v"): transform_release(artifacts)
        for version, artifacts in releases.items()
        if "alpha" not in version
        and "beta" not in version
        and StrictVersion(version.removeprefix("v")) >= min_version
    }

    json.dump(versions, sys.stdout)
