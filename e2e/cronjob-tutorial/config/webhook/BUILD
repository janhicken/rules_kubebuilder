load("@aspect_bazel_lib//lib:write_source_files.bzl", "write_source_files")
load("@io_github_janhicken_rules_kubebuilder//kubebuilder:defs.bzl", "controller_gen_webhooks")

filegroup(
    name = "webhook",
    srcs = [
        ":manifests.yaml",
        ":service.yaml",
    ],
    visibility = ["//visibility:public"],
)

controller_gen_webhooks(
    name = "webhooks.yaml",
    srcs = ["//internal/webhook/v1:webhook"],
)

write_source_files(
    name = "generate",
    files = {"manifests.yaml": ":webhooks.yaml"},
)
