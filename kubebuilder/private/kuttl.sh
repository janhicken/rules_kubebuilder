#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o monitor

# ╔════════════════════════════════════════════════════════════════════════════╗
# ║                             Template Variables                             ║
# ╚════════════════════════════════════════════════════════════════════════════╝

readonly crd_files=(%crd_files%)
readonly manifest_files=(%manifest_files%)
readonly image_archives=(%image_archives%)
readonly test_dir=%test_dir%

readonly kind_bin=%kind_bin%
readonly kind_node_image=%kind_node_image%
readonly kuttl_bin=%kuttl_bin%

# ╔════════════════════════════════════════════════════════════════════════════╗
# ║                                  Prepare                                   ║
# ╚════════════════════════════════════════════════════════════════════════════╝

# Copy all CRD manifests into a single directory
crd_dir="$TEST_TMPDIR"/crds
mkdir "$crd_dir"
cp -t "$crd_dir" "${crd_files[@]}"

# Copy all manifests into a single directory
manifest_dir="$TEST_TMPDIR"/manifests
mkdir "$manifest_dir"
cp -t "$manifest_dir" "${manifest_files[@]}"

# Configure kind
readonly kind_cluster_name=${TEST_WORKSPACE//[^a-z0-9.-]/}${TEST_TARGET//[^a-z0-9.-]/}
readonly kubeconfig_path=$TEST_TMPDIR/kubeconfig.yaml

# ╔════════════════════════════════════════════════════════════════════════════╗
# ║                                    Run                                     ║
# ╚════════════════════════════════════════════════════════════════════════════╝

shutdown_kind_cluster() {
	"$kind_bin" export logs "$TEST_LOGSPLITTER_OUTPUT_FILE" --name "$kind_cluster_name" || :
	"$kind_bin" delete cluster --name "$kind_cluster_name" --kubeconfig "$kubeconfig_path"
}

trap shutdown_kind_cluster EXIT
"$kind_bin" create cluster \
	--name "$kind_cluster_name" \
	--kubeconfig "$kubeconfig_path" \
	--image "$kind_node_image"

for image_archive in "${image_archives[@]}"; do
	printf 'Loading image archive %s...\n' "$image_archive" >&2
	"$kind_bin" load image-archive --name "$kind_cluster_name" "$image_archive"
done

KUBECONFIG="$kubeconfig_path" "$kuttl_bin" test "$test_dir" \
	--artifacts-dir "$TEST_LOGSPLITTER_OUTPUT_FILE" \
	--crd-dir "$crd_dir" \
	--kind-context "$kind_cluster_name" \
	--manifest-dir "$manifest_dir" \
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
