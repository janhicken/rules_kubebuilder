load("@aspect_bazel_lib//lib:diff_test.bzl", "diff_test")
load("@io_github_janhicken_rules_kubebuilder//kubebuilder:defs.bzl", "kustomization")

kustomization(
    name = "samples",
    resources = [
        ":batch_v1_cronjob.yaml",
    ],
    visibility = ["//visibility:public"],
)

diff_test(
    name = "samples_diff",
    file1 = ":samples",
    file2 = ":expected_kustomize_build.yaml",
)
