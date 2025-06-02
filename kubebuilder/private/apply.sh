#!/usr/bin/env bash
set -o errexit -o nounset -o pipefail

KUBECTL_BIN={kubectl_bin_path}
MANIFESTS_FILE={manifests_file_path}
YQ_BIN={yq_bin_path}
readonly KUBECTL_BIN MANIFESTS_FILE YQ_BIN

# Apply CRDs first and wait for them to be established
"$YQ_BIN" 'select(.kind == "CustomResourceDefinition")' "$MANIFESTS_FILE" |
	"$KUBECTL_BIN" apply --filename=- --output=json --server-side=true |
	"$YQ_BIN" '.items[].metadata.name' |
	xargs -r -I '{crdname}' "$KUBECTL_BIN" wait --for=condition=Established crd/'{crdname}'

# Apply other non-CRD resources
"$YQ_BIN" 'select(.kind != "CustomResourceDefinition")' "$MANIFESTS_FILE" |
	"$KUBECTL_BIN" apply --filename=-
