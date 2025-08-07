load("@io_github_janhicken_rules_kubebuilder//kubebuilder:defs.bzl", "kuttl_test")
load("//config:const.bzl", "CONTROLLER_NAME")

package(default_testonly = True)

kuttl_test(
    name = "e2e",
    size = "medium",
    srcs = [
        "manager/00-assert.yaml",
        "manager/00-install.yaml",
    ],
    crds = ["//config/crd"],
    images = ["//:manager_index.tar"],
    kind_cluster_name = CONTROLLER_NAME + "-e2e",
    manifests = ["//config/local"],
    tags = [
        "requires-network",
        "supports-graceful-termination",
    ],
)
