#!/usr/bin/env bash
set -o errexit
set -o nounset

# ╔════════════════════════════════════════════════════════════════════════════╗
# ║                             Template Variables                             ║
# ╚════════════════════════════════════════════════════════════════════════════╝

readonly image_archives=(%image_archives%)
readonly kustomization_apply_bin=%kustomization_apply_bin%

readonly kind_bin=%kind_bin%
readonly kind_cluster_name=%kind_cluster_name%
readonly kind_node_image=%kind_node_image%

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

kind_config_file=$(mktemp)
readonly kind_config_file
trap 'rm $kind_config_file' EXIT
cat >"$kind_config_file" <<EOF
apiVersion: kind.x-k8s.io/v1alpha4
kind: Cluster
name: "$kind_cluster_name"
nodes:
  - role: control-plane
    image: "$kind_node_image"
    extraMounts:
      - hostPath: $mountpoint
        containerPath: /var/lib/containerd
EOF

# ╔════════════════════════════════════════════════════════════════════════════╗
# ║                                    Run                                     ║
# ╚════════════════════════════════════════════════════════════════════════════╝

# Usage cluster_exists CLUSTER_NAME
cluster_exists() {
	local search cluster
	search=$1
	while read -r cluster; do
		if [[ "$cluster" == "$search" ]]; then
			return 0
		fi
	done < <("$kind_bin" get clusters)
	return 1
}

if cluster_exists "$kind_cluster_name"; then
	"$kind_bin" export kubeconfig --kubeconfig "$kubeconfig_path" --name "$kind_cluster_name"
else
	"$kind_bin" create cluster --config "$kind_config_file" --kubeconfig "$kubeconfig_path"
fi

for image_archive in "${image_archives[@]}"; do
	printf 'Loading image archive %s...\n' "$image_archive" >&2
	"$kind_bin" load image-archive --name "$kind_cluster_name" "$image_archive"
done

if [[ -n "$kustomization_apply_bin" ]]; then
	KUBECONFIG="$kubeconfig_path" "$kustomization_apply_bin"
fi
