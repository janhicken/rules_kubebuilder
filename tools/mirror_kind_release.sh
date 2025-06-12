#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail

if [[ $# -eq 0 ]]; then
	printf 'Usage: %s VERSION...\n' "$0" >&2
	exit 1
fi

BASE_URI=https://github.com/kubernetes-sigs/kind/releases/download
PLATFORMS=(darwin_amd64 darwin_arm64 linux_amd64 linux_arm64 windows_amd64)

printf 'Put this in kubebuilder/private/kind_toolchain.bzl:\n\n' >&2

for version in "$@"; do
	printf '"%s": {\n' "$version"
	for platform in "${PLATFORMS[@]}"; do
		read -r sha256 _ < <(
			curl --fail --silent --show-error --location "$BASE_URI/v${version}/kind-${platform//_/-}.sha256sum"
		)
		printf '\t"%s": "%s",\n' "$platform" "$sha256"
	done
	printf '},\n'
done
