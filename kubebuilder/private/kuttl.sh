#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o monitor

# ╔════════════════════════════════════════════════════════════════════════════╗
# ║                             Template Variables                             ║
# ╚════════════════════════════════════════════════════════════════════════════╝

readonly PATH=%PATH%
export GODEBUG=',execerrdot=0' # allow relative PATH lookups

readonly -a crd_files=%crd_files%
readonly -a manifest_files=%manifest_files%
readonly -a image_archives=%image_archives%
readonly test_dir=%test_dir%

readonly kind_cluster_name=%kind_cluster_name%
readonly kind_config_file=%kind_config_file%

# ╔════════════════════════════════════════════════════════════════════════════╗
# ║                                  Prepare                                   ║
# ╚════════════════════════════════════════════════════════════════════════════╝

# Copy all CRD manifests into a single directory
readonly crd_dir=$TEST_TMPDIR/crds
coreutils mkdir "$crd_dir"
coreutils ln -s "${crd_files[@]/#/$PWD/}" "$crd_dir"

# Copy all manifests into a single directory
readonly manifest_dir=$TEST_TMPDIR/manifests
coreutils mkdir "$manifest_dir"
coreutils ln -s "${manifest_files[@]/#/$PWD/}" "$manifest_dir"

# Configure kubeconfig
export KUBECONFIG=$TEST_TMPDIR/kubeconfig.yaml

# Create Docker volume for caching node data
readonly volume_name=kind-${kind_cluster_name}-0
docker volume create "$volume_name" >/dev/null
mountpoint=$(docker volume inspect --format '{{ .Mountpoint }}' "$volume_name")
readonly mountpoint

# Add volume mount to kind config
readonly final_kind_config_file=$TEST_TMPDIR/kind-config.yaml
DOCKER_VOLUME_PATH="$mountpoint" yq '(.. | select(tag == "!!str")) |= envsubst' \
	"$kind_config_file" >"$final_kind_config_file"

# Configure kuttl
readonly artifacts_dir=$TEST_LOGSPLITTER_OUTPUT_FILE
readonly kuttl_report_path=$artifacts_dir/kuttl-report.xml

# ╔════════════════════════════════════════════════════════════════════════════╗
# ║                                    Run                                     ║
# ╚════════════════════════════════════════════════════════════════════════════╝

shutdown_kind_cluster() {
	kind export logs "$TEST_LOGSPLITTER_OUTPUT_FILE" --name "$kind_cluster_name" || :
	if [[ -f "$kuttl_report_path" ]]; then
		coreutils mv "$kuttl_report_path" "$XML_OUTPUT_FILE"
	fi
	kind delete cluster --name "$kind_cluster_name"
}

trap shutdown_kind_cluster EXIT
kind create cluster --config "$kind_config_file"

for image_archive in "${image_archives[@]}"; do
	printf 'Loading image archive %s...\n' "$image_archive" >&2
	kind load image-archive --name "$kind_cluster_name" "$image_archive"
done

kubectl-kuttl test "$test_dir" \
	--artifacts-dir "$artifacts_dir" \
	--crd-dir "$crd_dir" \
	--kind-context "$kind_cluster_name" \
	--manifest-dir "$manifest_dir" \
	--report XML \
	--timeout $((TEST_TIMEOUT / 2)) &
readonly kuttl_pid=$!

interrupt_kuttl() {
	# kuttl does not handle SIGTERM, only SIGINT.
	# Also, make sure to send the interrupt to kuttl only, and not the whole process group.
	# Otherwise, the cleanup runs concurrently and causes problems.
	kill -SIGINT $kuttl_pid
}
trap interrupt_kuttl SIGINT SIGTERM

# Wait until kuttl exits or for an incoming trapped signal.
# See https://www.gnu.org/software/bash/manual/bash.html#Signals
wait $kuttl_pid
