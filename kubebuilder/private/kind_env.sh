#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail

# ╔════════════════════════════════════════════════════════════════════════════╗
# ║                             Template Variables                             ║
# ╚════════════════════════════════════════════════════════════════════════════╝

readonly PATH=%PATH%
export GODEBUG=',execerrdot=0' # allow relative PATH lookups

readonly -a image_archives=%image_archives%
readonly kustomization_apply_bin=%kustomization_apply_bin%

readonly kind_config_file=%kind_config_file%
readonly kind_cluster_name=%kind_cluster_name%

# ╔════════════════════════════════════════════════════════════════════════════╗
# ║                                  Prepare                                   ║
# ╚════════════════════════════════════════════════════════════════════════════╝

# Configure kind
: "${KUBECONFIG:=$BUILD_WORKSPACE_DIRECTORY/${kind_cluster_name}-kubeconfig.yaml}"
export KUBECONFIG

case "${1:-}" in
delete)
	exec kind delete cluster --name "$kind_cluster_name"
	;;
export-logs)
	exec kind export logs --name "$kind_cluster_name" "${2:-kind-logs}"
	;;
esac

# Create Docker volume for caching node data
readonly volume_name=kind-${kind_cluster_name}-0
docker volume create "$volume_name" >/dev/null
mountpoint=$(docker volume inspect --format '{{ .Mountpoint }}' "$volume_name")
readonly mountpoint

# Add volume mount to kind config
final_kind_config_file=$(coreutils mktemp --suffix .yaml)
readonly final_kind_config_file
trap 'coreutils rm $final_kind_config_file' EXIT

DOCKER_VOLUME_PATH="$mountpoint" yq '(.. | select(tag == "!!str")) |= envsubst' \
	"$kind_config_file" >"$final_kind_config_file"

# ╔════════════════════════════════════════════════════════════════════════════╗
# ║                                    Run                                     ║
# ╚════════════════════════════════════════════════════════════════════════════╝

while read -r existing_cluster; do
	if [[ "$existing_cluster" == "$kind_cluster_name" ]]; then
		cluster_exists=1
		break
	fi
done < <(kind get clusters)

if [[ -v cluster_exists ]]; then
	printf 'Reusing existing kind cluster named "%s"\n' "$kind_cluster_name"
	kind export kubeconfig --name "$kind_cluster_name"
else
	printf 'Creating new kind cluster with config:\n'
	yq --prettyPrint "$final_kind_config_file"
	kind create cluster --config "$final_kind_config_file"
fi

for image_archive in "${image_archives[@]}"; do
	image_ref=$(
		tar -x --to-stdout --file "$image_archive" index.json |
			yq '.manifests[0].annotations["org.opencontainers.image.ref.name"]'
	)
	printf >&2 'Loading image %s from archive %s...\n' "$image_ref" "$image_archive"

	for node in $(kind get nodes --name "$kind_cluster_name"); do
		# `kind load image-archive` is missing the --base-name flag, which makes the --digests flag useless.
		# Apart from that, this `ctr images import` command is semantically equivalent.
		docker exec --interactive "$node" \
			ctr --namespace k8s.io images import --base-name "$image_ref" --digests --all-platforms --local - <"$image_archive"
	done
done

if [[ -n "$kustomization_apply_bin" ]]; then
	"$kustomization_apply_bin"
fi
