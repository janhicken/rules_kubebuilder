#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail

# ╔════════════════════════════════════════════════════════════════════════════╗
# ║                             Template Variables                             ║
# ╚════════════════════════════════════════════════════════════════════════════╝

readonly kubectl_bin=%kubectl_bin%
readonly manifests_file=%manifests_file%
readonly yq_bin=%yq_bin%

# ╔════════════════════════════════════════════════════════════════════════════╗
# ║                                    Run                                     ║
# ╚════════════════════════════════════════════════════════════════════════════╝
crd_resources=$(mktemp)
non_crd_resources=$(mktemp)
trap 'rm -f "$crd_resources" "$non_crd_resources"' EXIT

# Apply CRDs first and wait for them to be established
"$yq_bin" 'select(.kind == "CustomResourceDefinition")' "$manifests_file" >"$crd_resources"
if [[ -s "$crd_resources" ]]; then
	"$kubectl_bin" apply --filename="$crd_resources" --output=json --server-side=true |
		"$yq_bin" '.items[].metadata.name // .metadata.name' |
		xargs -I '{crdname}' "$kubectl_bin" wait --for=condition=Established crd/'{crdname}'
fi

# Apply other non-CRD resources
"$yq_bin" 'select(.kind != "CustomResourceDefinition")' "$manifests_file" >"$non_crd_resources"
if [[ -s "$non_crd_resources" ]]; then
	"$kubectl_bin" apply --filename="$non_crd_resources"
fi
