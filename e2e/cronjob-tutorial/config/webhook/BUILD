load("@bazel_skylib//rules:diff_test.bzl", "diff_test")
load("@io_github_janhicken_rules_kubebuilder//kubebuilder:defs.bzl", "controller_gen_webhooks")

filegroup(
    name = "webhook",
    srcs = [
        "service.yaml",
        ":webhooks.yaml",
    ],
    visibility = ["//visibility:public"],
)

controller_gen_webhooks(
    name = "webhooks.yaml",
    srcs = ["//internal/webhook/v1:webhook"],
)

diff_test(
    name = "webhook_test",
    file1 = ":webhooks.yaml",
    file2 = "manifests.yaml",
)
