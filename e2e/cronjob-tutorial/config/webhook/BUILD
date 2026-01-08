load("@bazel_lib//lib:diff_test.bzl", "diff_test")
load("@io_github_janhicken_rules_kubebuilder//kubebuilder:defs.bzl", "controller_gen_webhooks", "kustomization")

kustomization(
    name = "webhook",
    configurations = [
        ":kustomizeconfig.yaml",
    ],
    resources = [
        ":service.yaml",
        ":webhooks.yaml",
    ],
    visibility = ["//visibility:public"],
)

diff_test(
    name = "webhook_diff",
    file1 = ":webhook",
    file2 = ":expected_kustomize_build.yaml",
)

controller_gen_webhooks(
    name = "webhooks.yaml",
    srcs = ["//internal/webhook/v1:webhook"],
)

diff_test(
    name = "webhooks_diff",
    file1 = ":webhooks.yaml",
    file2 = ":webhooks_expected.yaml",
)
