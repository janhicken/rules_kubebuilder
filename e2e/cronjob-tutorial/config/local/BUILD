load("@io_github_janhicken_rules_kubebuilder//kubebuilder:defs.bzl", "kustomization")

kustomization(
    name = "metrics-server",
    patches = {
        ":metrics_server_patch.yaml": json.encode({
            "kind": "Deployment",
            "name": "metrics-server",
        }),
    },
    resources = ["@metrics-server//file"],
)

kustomization(
    name = "local",
    image_tags = {"controller": "local"},
    patches = {
        ":ns_patch.yaml": json.encode({
            "kind": "Namespace",
            "name": "project-system",
        }),
    },
    resources = [
        ":metrics-server",
        "//config/default",
        "@cert-manager//file",
        "@prometheus//file",
    ],
    visibility = ["//visibility:public"],
)
