#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail

if [[ $# -eq 0 ]]; then
	printf 'Usage: %s VERSION...\n' "$0" >&2
	exit 1
fi

BASE_URI=https://github.com/kudobuilder/kuttl/releases/download
ARTIFACT_PATTERN='kubectl-kuttl_([^_]+)_([a-z]+)_([a-z0-9_]+)'

printf 'Put this in kubebuilder/private/kind_toolchain.bzl:\n\n' >&2

for version in "$@"; do
	printf '"%s": {\n' "$version"
	curl --fail --silent --show-error --location "$BASE_URI/v${version}/checksums.txt" |
		while read -r sha256 artifact; do
			if [[ "$artifact" =~ $ARTIFACT_PATTERN ]]; then
				os=${BASH_REMATCH[2]}
				arch=${BASH_REMATCH[3]}
				platform=${os}_${arch}
				printf '\t"%s": "%s",\n' "$platform" "$sha256"
			fi
		done
	printf '},\n'
done
