load("@io_github_janhicken_rules_kubebuilder//kubebuilder:defs.bzl", "chainsaw_test", "kuttl_test")
load("//config:const.bzl", "CONTROLLER_NAME")

package(default_testonly = True)

kuttl_test(
    name = "kuttl",
    size = "medium",
    srcs = [
        "manager/00-assert.yaml",
        "manager/00-install.yaml",
    ],
    crds = ["//config/crd"],
    images = ["//:manager_index.tar"],
    kind_cluster_name = CONTROLLER_NAME + "-kuttl",
    manifests = ["//config/local"],
    tags = [
        "requires-network",
        "supports-graceful-termination",
    ],
)

chainsaw_test(
    name = "chainsaw",
    size = "medium",
    srcs = glob(["manager/*.yaml"]),
    kind_env = "//:kind_env",
    tags = [
        "requires-network",
        "supports-graceful-termination",
    ],
)
