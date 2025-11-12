#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail

if [[ $# -eq 0 ]]; then
	printf 'Usage: %s VERSION...\n' "$0" >&2
	exit 1
fi

BASE_URI=https://github.com/kubernetes-sigs/controller-tools/releases/download
PLATFORMS=(darwin-amd64 darwin-arm64 linux-amd64 linux-arm64 linux-ppc64le linux-s390x windows-amd64)

printf 'Put this in kubebuilder/private/controller_gen_toolchain.bzl:\n\n' >&2

for version in "$@"; do
	printf '"%s": {\n' "$version"
	for platform in "${PLATFORMS[@]}"; do
		case "$platform" in
		windows*)
			ext=.exe
			;;
		*)
			ext=''
			;;
		esac
		sha384=$(
			curl --fail --silent --show-error --location "$BASE_URI/v${version}/controller-gen-${platform}${ext}" |
				openssl dgst -sha384 -binary |
				openssl base64 -A
		)
		printf '\t"%s": "sha384-%s",\n' "$platform" "$sha384"
	done
	printf '},\n'
done
