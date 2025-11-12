#!/usr/bin/env bash
set -o errexit
set -o nounset

# ╔════════════════════════════════════════════════════════════════════════════╗
# ║                             Template Variables                             ║
# ╚════════════════════════════════════════════════════════════════════════════╝

readonly PATH=%PATH%

readonly -a srcs=%srcs%
readonly kind_env=./%kind_env%

dirname() {
	case "$1" in
	*/*)
		printf '%s\n' "${1%/*}"
		;;
	*)
		printf '%s\n' .
		;;
	esac
}

basename() {
	local filename="${1##*/}"
	if [[ -n "${2:-}" ]]; then
		printf '%s\n' "${filename%"$2"}"
	else
		printf '%s\n' "$filename"
	fi
}

# ╔════════════════════════════════════════════════════════════════════════════╗
# ║                                  Prepare                                   ║
# ╚════════════════════════════════════════════════════════════════════════════╝

# Find the first 'chainsaw-test.yaml' to determine the test directories
declare -a test_dirs
for src in "${srcs[@]}"; do
	if [[ "$(basename "$src")" == chainsaw-test.yaml ]]; then
		test_dirs+=("$(dirname "$src")")
	fi
done
if [[ ${#test_dirs[@]} -eq 0 ]]; then
	printf >&2 'ERROR: No chainsaw-test.yaml found among srcs.\n'
	exit 1
fi

# Configure kubeconfig
declare -rx KUBECONFIG=$TEST_TMPDIR/kubeconfig.yaml

# Configure chainsaw
readonly chainsaw_opts=(
	--report-format XML
	--report-path "$(dirname "$XML_OUTPUT_FILE")"
	--report-name "$(basename "$XML_OUTPUT_FILE" .xml)"
)

# ╔════════════════════════════════════════════════════════════════════════════╗
# ║                                    Run                                     ║
# ╚════════════════════════════════════════════════════════════════════════════╝

shutdown_kind_cluster() {
	"$kind_env" export-logs "$TEST_LOGSPLITTER_OUTPUT_FILE" || :
	"$kind_env" delete
}

trap shutdown_kind_cluster EXIT
"$kind_env"

chainsaw test "${chainsaw_opts[@]}" "${test_dirs[@]}"
