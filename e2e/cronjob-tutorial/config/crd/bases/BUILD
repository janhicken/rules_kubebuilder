load("@bazel_skylib//rules:diff_test.bzl", "diff_test")
load("@io_github_janhicken_rules_kubebuilder//kubebuilder:defs.bzl", "controller_gen_crds")

alias(
    name = "bases",
    actual = "bases.yaml",
    visibility = ["//visibility:public"],
)

controller_gen_crds(
    name = "bases.yaml",
    srcs = ["//api/v1:api"],
    max_description_length = 0,
)

diff_test(
    name = "bases_test",
    file1 = ":bases.yaml",
    file2 = ":batch.tutorial.kubebuilder.io_cronjobs.yaml",
)
