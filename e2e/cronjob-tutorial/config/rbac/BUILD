load("@aspect_bazel_lib//lib:write_source_files.bzl", "write_source_files")
load("@io_github_janhicken_rules_kubebuilder//kubebuilder:defs.bzl", "controller_gen_rbac")

filegroup(
    name = "rbac",
    srcs = glob(["*.yaml"]),
    visibility = ["//visibility:public"],
)

controller_gen_rbac(
    name = "rbac.yaml",
    srcs = ["//internal/controller"],
    role_name = "manager-role",
)

write_source_files(
    name = "generate",
    files = {"role.yaml": ":rbac.yaml"},
)
