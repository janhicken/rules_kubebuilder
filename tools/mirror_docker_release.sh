#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail

if [[ $# -eq 0 ]]; then
	printf 'Usage: %s VERSION\n' "$0" >&2
	exit 1
fi

BASE_URI=https://download.docker.com
PLATFORMS=(
	linux_aarch64 linux_x86_64 mac_aarch64 mac_x86_64 win_x86_64
)
version=$1

printf 'Put this in kubebuilder/private/docker_toolchain.bzl:\n\n' >&2

printf '{\n'
for platform in "${PLATFORMS[@]}"; do
	case "$platform" in
	win*)
		ext=.zip
		;;
	*)
		ext=.tgz
		;;
	esac
	os=$(cut -d_ -f1 <<<"$platform")
	arch=$(cut -d_ -f2- <<<"$platform")
	sha384=$(
		curl --fail --silent --show-error --location "$BASE_URI/$os/static/stable/$arch/docker-${version}${ext}" |
			openssl dgst -sha384 -binary |
			openssl base64 -A
	)
	printf '\t"%s": "sha384-%s",\n' "$platform" "$sha384"
done
printf '}\n'
