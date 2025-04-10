load("@bazel_skylib//rules:diff_test.bzl", "diff_test")
load("@io_github_janhicken_rules_kubebuilder//kubebuilder:defs.bzl", "controller_gen_rbac")

controller_gen_rbac(
    name = "rbac",
    srcs = ["//internal/controller"],
    role_name = "manager-role",
)

diff_test(
    name = "rbac_test",
    file1 = ":rbac",
    file2 = ":role.yaml",
)
