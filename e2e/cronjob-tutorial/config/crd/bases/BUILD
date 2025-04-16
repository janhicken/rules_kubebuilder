load("@aspect_bazel_lib//lib:write_source_files.bzl", "write_source_files")
load("@io_github_janhicken_rules_kubebuilder//kubebuilder:defs.bzl", "controller_gen_crds")

filegroup(
    name = "bases",
    srcs = ["crds.yaml"],
    visibility = ["//visibility:public"],
)

controller_gen_crds(
    name = "crds.yaml",
    srcs = ["//api/v1:api"],
    max_description_length = 0,
)

write_source_files(
    name = "generate",
    files = {"batch.tutorial.kubebuilder.io_cronjobs.yaml": ":crds.yaml"},
)
