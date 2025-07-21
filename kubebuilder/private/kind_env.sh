#!/usr/bin/env bash
set -o errexit
set -o nounset

# ╔════════════════════════════════════════════════════════════════════════════╗
# ║                             Template Variables                             ║
# ╚════════════════════════════════════════════════════════════════════════════╝

readonly PATH=%PATH%:$PATH

readonly image_archives=(%image_archives%)
readonly kustomization_apply_bin=%kustomization_apply_bin%

readonly kind_config_file=%kind_config_file%
readonly kind_cluster_name=%kind_cluster_name%

# ╔════════════════════════════════════════════════════════════════════════════╗
# ║                                  Prepare                                   ║
# ╚════════════════════════════════════════════════════════════════════════════╝

# Configure kind
readonly kubeconfig_path=$BUILD_WORKSPACE_DIRECTORY/${kind_cluster_name}-kubeconfig.yaml

# Create Docker volume for caching node data
readonly volume_name=kind-${kind_cluster_name}-0
docker volume create "$volume_name" >/dev/null
mountpoint=$(docker volume inspect --format '{{ .Mountpoint }}' "$volume_name")
readonly mountpoint

# Add volume mount to kind config
final_kind_config_file=$(coreutils mktemp --suffix .yaml)
readonly final_kind_config_file
trap 'rm $final_kind_config_file' EXIT

DOCKER_VOLUME_PATH="$mountpoint" yq '(.. | select(tag == "!!str")) |= envsubst' \
	"$kind_config_file" >"$final_kind_config_file"

# ╔════════════════════════════════════════════════════════════════════════════╗
# ║                                    Run                                     ║
# ╚════════════════════════════════════════════════════════════════════════════╝

declare -A existing_clusters
while read -r existing_cluster; do
	existing_clusters[$existing_cluster]=""
done < <(kind get clusters)

if [[ -v existing_clusters[$kind_cluster_name] ]]; then
	printf 'Reusing existing kind cluster named "%s"\n' "$kind_cluster_name"
	kind export kubeconfig --kubeconfig "$kubeconfig_path" --name "$kind_cluster_name"
else
	printf 'Creating new kind cluster with config:\n'
	yq --prettyPrint "$final_kind_config_file"
	kind create cluster --config "$final_kind_config_file" --kubeconfig "$kubeconfig_path"
fi

for image_archive in "${image_archives[@]}"; do
	printf 'Loading image archive %s...\n' "$image_archive" >&2
	kind load image-archive --name "$kind_cluster_name" "$image_archive"
done

if [[ -n "$kustomization_apply_bin" ]]; then
	KUBECONFIG="$kubeconfig_path" "$kustomization_apply_bin"
fi
