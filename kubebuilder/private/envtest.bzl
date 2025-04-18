"Bazel rules for envtest"

load("@rules_go//go:def.bzl", "go_test")

def envtest_test(name, envtest_repo = "@envtest", **kwargs):
    """Configures a go_test with envtest binaries

    The envtest binaries will be available at runtime.
    The path to the binary directory will be available through the environment variable KUBEBUILDER_ASSETS.

    Args:
        name: Name of the rule
        envtest_repo: Name of the envtest repository to use
        **kwargs: further keyword arguments forwarded to go_test
    """
    envtest = "%s//:envtest" % envtest_repo
    go_test(
        name = name,
        data = kwargs.pop("data", []) + [envtest],
        env = kwargs.pop("env", {}) | {
            "KUBEBUILDER_ASSETS": "/".join([
                ".."
                for _ in native.package_name().split("/")
            ]) + "/$(rootpath %s)" % envtest,
        },
        **kwargs
    )
