#!/usr/bin/env bash
set -o errexit -o nounset -o pipefail

case $# in
3)
	info_file=$3
	;&
2)
	src_file=$1
	out_file=$2
	;;
*)
	printf 'Usage: %s SOURCE_FILE INFO_FILE OUTPUT_FILE\n' "$0" >&2
	exit 1
	;;
esac

# Export info pairs as environment variables
if [[ -n "${info_file:-}" ]]; then
	while read -r key value; do
		declare -x "$key"="$value"
	done <"$info_file"
fi

"$YQ_BIN" '(.. | select(tag == "!!str")) |= envsubst' "$src_file" >"$out_file"
