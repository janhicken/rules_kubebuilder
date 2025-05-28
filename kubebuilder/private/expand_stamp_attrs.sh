#!/usr/bin/env bash
set -o errexit -o nounset -o pipefail

if [[ "$#" -lt 2 ]]; then
	printf 'Usage: %s SOURCE_FILE OUTPUT_FILE [INFO_FILE]... \n' "$0" >&2
	exit 1
fi
src_file=$1
out_file=$2
shift 2

# Export info pairs as environment variables
for info_file in "$@"; do
	while read -r key value; do
		declare -x "$key"="$value"
	done <"$info_file"
done

"$YQ_BIN" '(.. | select(tag == "!!str")) |= envsubst' "$src_file" >"$out_file"
