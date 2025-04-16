#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail

cd "$(dirname "$0")"

SOURCE_URL='https://raw.githubusercontent.com/kubernetes-sigs/controller-tools/HEAD/envtest-releases.yaml'
readonly SOURCE_URL

printf 'Put this in kubebuilder/private/envtest_releases.bzl:\n\n' >&2

curl --fail --silent --show-error --location "$SOURCE_URL" |
	yq --output-format=json '.releases'
