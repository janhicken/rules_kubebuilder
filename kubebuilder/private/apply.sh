#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail

# ╔════════════════════════════════════════════════════════════════════════════╗
# ║                             Template Variables                             ║
# ╚════════════════════════════════════════════════════════════════════════════╝

readonly PATH=%PATH%
readonly manifests_file=%manifests_file%

# ╔════════════════════════════════════════════════════════════════════════════╗
# ║                                    Run                                     ║
# ╚════════════════════════════════════════════════════════════════════════════╝
crd_resources=$(coreutils mktemp --suffix .yaml)
non_crd_resources=$(coreutils mktemp --suffix .yaml)
trap 'coreutils rm -f "$crd_resources" "$non_crd_resources"' EXIT

# Apply CRDs first and wait for them to be established
yq 'select(.apiVersion == "apiextensions.k8s.io/v1" and .kind == "CustomResourceDefinition")' "$manifests_file" >"$crd_resources"
if [[ -s "$crd_resources" ]]; then
	kubectl apply --filename="$crd_resources" --output=json --server-side=true |
		yq '.items[].metadata.name // .metadata.name' |
		while read -r crdname; do
			kubectl wait --for=condition=Established crd/"$crdname"
		done
fi

# Apply other non-CRD resources
yq 'select(.apiVersion != "apiextensions.k8s.io/v1" and .kind != "CustomResourceDefinition")' "$manifests_file" >"$non_crd_resources"
if [[ -s "$non_crd_resources" ]]; then
	kubectl apply --filename="$non_crd_resources"
fi
