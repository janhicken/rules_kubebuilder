#!/usr/bin/env bash
set -o errexit
set -o nounset

if [[ $# -eq 0 ]]; then
	printf 'Usage: %s VERSION\n' "$0" >&2
	exit 1
fi

JQ_EXPR='
[
	.assets[]
	| select(.name | test("^chainsaw_(\\w+)\\.tar\\.gz$"; ""))
	| (.name | capture("^chainsaw_(?<key>\\w+)\\.tar\\.gz$")) + {value: {url, sha256: (.digest | ltrimstr("sha256:"))}}
] | from_entries'

printf 'Put this in kubebuilder/private/chainsaw_toolchain.bzl:\n\n' >&2

gh release view "v$1" --repo kyverno/chainsaw --json assets --jq "$JQ_EXPR"
