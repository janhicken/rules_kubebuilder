load("@aspect_bazel_lib//lib:diff_test.bzl", "diff_test")
load("@io_github_janhicken_rules_kubebuilder//kubebuilder:defs.bzl", "kustomization")

kustomization(
    name = "prometheus",
    patches = {
        ":monitor_tls_patch.yaml": json.encode({
            "kind": "ServiceMonitor",
        }),
    },
    resources = [
        ":monitor.yaml",
    ],
    visibility = ["//visibility:public"],
)

diff_test(
    name = "prometheus_diff",
    file1 = ":prometheus",
    file2 = ":expected_kustomize_build.yaml",
)
