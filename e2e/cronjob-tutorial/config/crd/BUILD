load("@bazel_lib//lib:diff_test.bzl", "diff_test")
load("@io_github_janhicken_rules_kubebuilder//kubebuilder:defs.bzl", "kustomization")

kustomization(
    name = "crd",
    resources = ["//config/crd/bases"],
    visibility = ["//visibility:public"],
)

diff_test(
    name = "crd_diff",
    file1 = ":crd",
    file2 = ":expected_kustomize_build.yaml",
)
