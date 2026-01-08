load("@bazel_lib//lib:diff_test.bzl", "diff_test")
load("@io_github_janhicken_rules_kubebuilder//kubebuilder:defs.bzl", "kustomization")

kustomization(
    name = "certmanager",
    configurations = [":kustomizeconfig.yaml"],
    resources = [
        ":certificate-metrics.yaml",
        ":certificate-webhook.yaml",
        ":issuer.yaml",
    ],
    visibility = ["//visibility:public"],
)

diff_test(
    name = "certmanager_diff",
    file1 = ":certmanager",
    file2 = ":expected_kustomize_build.yaml",
)
