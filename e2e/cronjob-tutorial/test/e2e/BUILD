load("@io_github_janhicken_rules_kubebuilder//kubebuilder:defs.bzl", "chainsaw_test")
load("//config:const.bzl", "CONTROLLER_NAME")

package(default_testonly = True)

chainsaw_test(
    name = "e2e",
    size = "medium",
    srcs = glob(["manager/*.yaml"]),
    kind_env = "//:kind_env",
    tags = [
        "requires-network",
        "supports-graceful-termination",
    ],
)
