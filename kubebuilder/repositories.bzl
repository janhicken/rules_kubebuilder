"""Declare runtime dependencies

These are needed for local dev, and users must install them as well.
See https://docs.bazel.build/versions/main/skylark/deploying.html#dependencies
"""

load(
    "//kubebuilder/private:controller_gen_toolchain.bzl",
    "CONTROLLER_GEN_PLATFORMS",
    "KUBERNETES_VERSION_MAPPING",
    "controller_gen_host_alias_repo",
    "controller_gen_platform_repo",
    "controller_gen_toolchains_repo",
)
load(
    "//kubebuilder/private:envtest_toolchain.bzl",
    "ENVTEST_PLATFORMS",
    "ENVTEST_VERSIONS",
    "envtest_host_alias_repo",
    "envtest_platform_repo",
    "envtest_toolchains_repo",
)

KUBERNETES_VERSIONS = ENVTEST_VERSIONS.keys()
DEFAULT_KUBERNETES_VERSION = "1.31.0"

def register_kubebuilder_repositories_and_toolchains(name = "", kubernetes_version = DEFAULT_KUBERNETES_VERSION, register = True):
    """
    Registers Kubebuilder repositories and toolchain

    Args:
        name: a common prefix for all generated repositories
        kubernetes_version: the target Kubernetes version to pick toolchain versions for
        register: whether to call through to native.register_toolchains.
            Should be True for WORKSPACE users, but false when used under bzlmod extension
    """
    k8s_version_major_minor = kubernetes_version.rpartition(".")[0]

    if k8s_version_major_minor not in KUBERNETES_VERSION_MAPPING:
        fail("Unsupported Kubernetes version {k8s_version}, major.minor must match one of: {available}".format(
            k8s_version = kubernetes_version,
            available = KUBERNETES_VERSION_MAPPING.keys(),
        ))
    controller_gen_version = KUBERNETES_VERSION_MAPPING[k8s_version_major_minor]
    register_controller_gen_toolchains(name + DEFAULT_CONTROLLER_GEN_REPOSITORY, controller_gen_version, register)

    register_envtest_repositories(name + DEFAULT_ENVTEST_REPOSITORY, kubernetes_version)

# ╔════════════════════════════════════════════════════════════════════════════╗
# ║                               controller-gen                               ║
# ╚════════════════════════════════════════════════════════════════════════════╝

DEFAULT_CONTROLLER_GEN_REPOSITORY = "controller_gen"

def register_controller_gen_toolchains(name, version, register = True):
    """Registers controller-gen toolchain and repositories

    Args:
        name: override the prefix for the generated toolchain repositories
        version: the version of controller-gen to execute (see https://github.com/kubernetes-sigs/controller-tools/releases)
        register: whether to call through to native.register_toolchains.
            Should be True for WORKSPACE users, but false when used under bzlmod extension

    """
    for platform in CONTROLLER_GEN_PLATFORMS.keys():
        controller_gen_platform_repo(
            name = "%s_%s" % (name, platform),
            platform = platform,
            version = version,
        )
        if register:
            native.register_toolchains("@%s_toolchains//:%s_toolchain" % (name, platform))

    controller_gen_host_alias_repo(name = name)

    controller_gen_toolchains_repo(
        name = "%s_toolchains" % name,
        user_repository_name = name,
    )

# ╔════════════════════════════════════════════════════════════════════════════╗
# ║                                  envtest                                   ║
# ╚════════════════════════════════════════════════════════════════════════════╝

DEFAULT_ENVTEST_REPOSITORY = "envtest"

def register_envtest_repositories(name, version):
    """Registers envtest repositories

    Args:
        name: override the prefix for the generated repositories
        version: the version of controller-gen to execute (see https://github.com/kubernetes-sigs/controller-tools/releases)
    """
    for platform in ENVTEST_PLATFORMS.keys():
        envtest_platform_repo(
            name = "%s_%s" % (name, platform),
            platform = platform,
            version = version,
        )

    envtest_host_alias_repo(name = name)

    envtest_toolchains_repo(
        name = "%s_toolchains" % name,
        user_repository_name = name,
    )
