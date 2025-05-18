load("@aspect_bazel_lib//lib:diff_test.bzl", "diff_test")
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

diff_test(
    name = "crds_diff",
    file1 = ":crds.yaml",
    file2 = ":crds_expected.yaml",
)
