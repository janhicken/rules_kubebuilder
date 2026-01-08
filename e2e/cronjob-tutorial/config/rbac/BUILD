load("@bazel_lib//lib:diff_test.bzl", "diff_test")
load("@io_github_janhicken_rules_kubebuilder//kubebuilder:defs.bzl", "controller_gen_rbac", "kustomization")

kustomization(
    name = "rbac",
    resources = [
        "cronjob_admin_role.yaml",
        "cronjob_editor_role.yaml",
        "cronjob_viewer_role.yaml",
        "leader_election_role.yaml",
        "leader_election_role_binding.yaml",
        "manager_role.yaml",
        "metrics_auth_role.yaml",
        "metrics_auth_role_binding.yaml",
        "metrics_reader_role.yaml",
        "role_binding.yaml",
        "service_account.yaml",
    ],
    visibility = ["//visibility:public"],
)

diff_test(
    name = "rbac_test",
    file1 = ":rbac",
    file2 = ":expected_kustomize_build.yaml",
)

controller_gen_rbac(
    name = "manager_role.yaml",
    srcs = ["//internal/controller"],
    role_name = "manager-role",
)

diff_test(
    name = "manager_role_diff",
    file1 = ":manager_role.yaml",
    file2 = ":manager_role_expected.yaml",
)
