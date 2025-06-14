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

# Apply CRDs first and wait for them to be established
"$yq_bin" 'select(.kind == "CustomResourceDefinition")' "$manifests_file" |
	"$kubectl_bin" apply --filename=- --output=json --server-side=true |
	"$yq_bin" '.items[].metadata.name' |
	xargs -r -I '{crdname}' "$kubectl_bin" wait --for=condition=Established crd/'{crdname}'

# Apply other non-CRD resources
"$yq_bin" 'select(.kind != "CustomResourceDefinition")' "$manifests_file" |
	"$kubectl_bin" apply --filename=-
