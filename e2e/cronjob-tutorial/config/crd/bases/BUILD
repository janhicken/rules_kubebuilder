load("@bazel_skylib//rules:diff_test.bzl", "diff_test")
load("@io_github_janhicken_rules_kubebuilder//kubebuilder:defs.bzl", "controller_gen_crds")

controller_gen_crds(
    name = "bases",
    srcs = ["//api/v1:api"],
    max_description_length = 0,
    visibility = ["//visibility:public"],
)

diff_test(
    name = "bases_test",
    file1 = ":bases",
    file2 = ":batch.tutorial.kubebuilder.io_cronjobs.yaml",
)
