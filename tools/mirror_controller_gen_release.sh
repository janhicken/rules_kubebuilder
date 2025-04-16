#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail

if [[ $# -eq 0 ]]; then
  printf 'Usage: %s VERSION...\n' "$0" >&2
  exit 1
fi

BASE_URI=https://github.com/kubernetes-sigs/controller-tools/releases/download
PLATFORMS=(darwin_amd64 darwin_arm64 linux_amd64 linux_arm64 linux_ppc64le linux_s390x windows_amd64)

printf 'Put this in kubebuilder/private/controller_gen_toolchain.bzl:\n\n' >&2

for version in "$@"; do
  printf '"%s": {\n' "$version"
  for platform in "${PLATFORMS[@]}"; do
    case "$platform" in
      windows*)
        ext=.exe;;
      *)
        ext='';;
    esac
    sha384=$(curl --fail --silent --show-error --location "$BASE_URI/v${version}/controller-gen-${platform//_/-}${ext}" |
      openssl dgst -sha384 -binary |
      openssl base64 -A
    )
    printf '\t"%s": "sha384-%s",\n' "$platform" "$sha384"
  done
  printf '},\n'
done
