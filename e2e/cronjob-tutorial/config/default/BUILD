load("@bazel_lib//lib:diff_test.bzl", "diff_test")
load("@io_github_janhicken_rules_kubebuilder//kubebuilder:defs.bzl", "kustomization")

kustomization(
    name = "default",
    name_prefix = "project-",
    namespace = "project-system",
    patches = {
        ":cert_metrics_manager_patch.yaml": json.encode({"kind": "Deployment"}),
        ":manager_metrics_patch.yaml": json.encode({"kind": "Deployment"}),
        ":manager_webhook_patch.yaml": json.encode({"kind": "Deployment"}),
    },
    replacements = [
        ":metrics_service_namespace_replacement.yaml",
        ":metrics_service_name_replacement.yaml",
        ":webhook_cert_namespace_replacement.yaml",
        ":webhook_cert_name_replacement.yaml",
        ":webhook_service_namespace_replacement.yaml",
        ":webhook_service_name_replacement.yaml",
    ],
    resources = [
        ":metrics_service.yaml",
        "//config/certmanager",
        "//config/crd",
        "//config/manager",
        "//config/network-policy",
        "//config/prometheus",
        "//config/rbac",
        "//config/webhook",
    ],
    visibility = ["//visibility:public"],
)

diff_test(
    name = "default_diff",
    file1 = ":default",
    file2 = ":expected_kustomize_build.yaml",
)
