load("@aspect_bazel_lib//lib:diff_test.bzl", "diff_test")
load("@io_github_janhicken_rules_kubebuilder//kubebuilder:defs.bzl", "kustomization")

kustomization(
    name = "manager",
    labels = {
        "app.kubernetes.io/managed-by": "kustomize",
        "app.kubernetes.io/name": "project",
        "control-plane": "controller-manager",
    },
    resources = [
        ":deployment.yaml",
        ":ns.yaml",
    ],
    visibility = ["//visibility:public"],
)

diff_test(
    name = "manager_diff",
    file1 = ":manager",
    file2 = ":expected_kustomize_build.yaml",
)
