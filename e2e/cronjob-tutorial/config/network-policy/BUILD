load("@bazel_lib//lib:diff_test.bzl", "diff_test")
load("@io_github_janhicken_rules_kubebuilder//kubebuilder:defs.bzl", "kustomization")

kustomization(
    name = "network-policy",
    resources = [
        ":allow-metrics-traffic.yaml",
        ":allow-webhook-traffic.yaml",
    ],
    visibility = ["//visibility:public"],
)

diff_test(
    name = "network-policy_diff",
    file1 = ":network-policy",
    file2 = ":expected_kustomize_build.yaml",
)
