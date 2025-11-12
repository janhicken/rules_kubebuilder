#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail

# ╔════════════════════════════════════════════════════════════════════════════╗
# ║                                 Functions                                  ║
# ╚════════════════════════════════════════════════════════════════════════════╝

usage() {
	cat <<EOF
Usage:
	$0 [options] path/to/base/kustomization.yaml

Options:
	-i image_ref=oci_image_digest	Configure image transformer to set the digest of the given image, can be given multiple times.
	-s stamp_var_file				Configure file with stamp variables to be interpolated, can be given multiple times.
	-o output_file					Where to write the output kustomization to (required).
EOF
}

oci_image_digest_transformer() {
	IFS='=' read -r image_ref image_digest_file <<<"$1"
	if [[ -z "$image_ref" || -z "$image_digest_file" ]]; then
		printf >&2 'Invalid image, must use format like "docker.io/my/img=path/to/index.json.sha256"\n\n'
		return 1
	fi

	read -r digest <"$image_digest_file"
	# shellcheck disable=SC2016
	"$JQ_BIN" --arg name "$image_ref" --arg digest "$digest" --null-input '{name: $name, digest: $digest}'
}

# ╔════════════════════════════════════════════════════════════════════════════╗
# ║                               Option Parsing                               ║
# ╚════════════════════════════════════════════════════════════════════════════╝

oci_images=()
stamp_var_files=()
declare output_file

while getopts ':i:ho:s:' opt; do
	case "$opt" in
	i)
		oci_images+=("$OPTARG")
		;;
	h)
		usage
		exit
		;;
	o)
		output_file="$OPTARG"
		;;
	s)
		stamp_var_files+=("$OPTARG")
		;;
	\?)
		printf >&2 'Invalid option -%s\n\n' "$OPTARG"
		usage
		exit 1
		;;
	:)
		printf >&2 'Option -%s requires an argument\n\n' "$OPTARG"
		usage
		exit 1
		;;
	esac
done
shift $((OPTIND - 1))

if [[ $# -ne 1 ]]; then
	printf >&2 'Missing kustomization.yaml positional argument.\n\n'
	usage
	exit 1
elif [[ -z "${output_file:-}" ]]; then
	printf >&2 'Output file (-o) option is mandatory.\n\n'
	usage
	exit 1
fi

readonly src_kustomization=$1

# ╔════════════════════════════════════════════════════════════════════════════╗
# ║                              Stamp Variables                               ║
# ╚════════════════════════════════════════════════════════════════════════════╝

# Export stamp variables as environment variables
if [[ ${#stamp_var_files[@]} -gt 0 ]]; then
	for stamp_var_file in "${stamp_var_files[@]}"; do
		while read -r key value; do
			declare -x "$key"="$value"
		done <"$stamp_var_file"
	done
fi

# ╔════════════════════════════════════════════════════════════════════════════╗
# ║                                 OCI Images                                 ║
# ╚════════════════════════════════════════════════════════════════════════════╝

if [[ ${#oci_images[@]} -gt 0 ]]; then
	for oci_image in "${oci_images[@]}"; do
		oci_image_digest_transformer "$oci_image"
	done
else
	echo
fi |
	"$JQ_BIN" --slurp |
	"$JQ_BIN" --slurp '.[0].images += .[1] | .[0]' "$src_kustomization" - |
	"$YQ_BIN" '(.. | select(tag == "!!str")) |= envsubst' \
		>"$output_file"
