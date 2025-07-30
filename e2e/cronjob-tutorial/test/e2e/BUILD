load("@io_github_janhicken_rules_kubebuilder//kubebuilder:defs.bzl", "kuttl_test")

package(default_testonly = True)

kuttl_test(
    name = "e2e",
    size = "medium",
    srcs = [
        "manager/00-assert.yaml",
        "manager/00-install.yaml",
    ],
    crds = ["//config/crd"],
    images = ["//:manager.tar"],
    kind_cluster_name = "cronjob-tutorial-e2e",
    manifests = ["//config/local"],
    tags = [
        "requires-network",
        "supports-graceful-termination",
    ],
)
