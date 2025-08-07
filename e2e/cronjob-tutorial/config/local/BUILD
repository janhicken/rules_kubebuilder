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
    patches = {
        ":ns_patch.yaml": json.encode({
            "kind": "Namespace",
            "name": "project-system",
        }),
        ":never_pull_patch.yaml": json.encode({
            "kind": "Deployment",
            "namespace": "project-system",
            "name": "project-controller-manager",
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
