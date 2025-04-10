"""Declare runtime dependencies

These are needed for local dev, and users must install them as well.
See https://docs.bazel.build/versions/main/skylark/deploying.html#dependencies
"""

load(
    "//kubebuilder/private:controller_gen_toolchain.bzl",
    "CONTROLLER_GEN_PLATFORMS",
    "controller_gen_host_alias_repo",
    "controller_gen_platform_repo",
    "controller_gen_toolchains_repo",
    _DEFAULT_CONTROLLER_GEN_VERSION = "DEFAULT_CONTROLLER_GEN_VERSION",
)
load(
    "//kubebuilder/private:envtest_toolchain.bzl",
    "ENVTEST_PLATFORMS",
    "envtest_host_alias_repo",
    "envtest_platform_repo",
    _DEFAULT_ENVTEST_VERSION = "DEFAULT_ENVTEST_VERSION",
)

# ╔════════════════════════════════════════════════════════════════════════════╗
# ║                               controller-gen                               ║
# ╚════════════════════════════════════════════════════════════════════════════╝

DEFAULT_CONTROLLER_GEN_REPOSITORY = "controller_gen"
DEFAULT_CONTROLLER_GEN_VERSION = _DEFAULT_CONTROLLER_GEN_VERSION

def register_controller_gen_toolchains(name = DEFAULT_CONTROLLER_GEN_REPOSITORY, version = DEFAULT_CONTROLLER_GEN_VERSION, register = True):
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
DEFAULT_ENVTEST_VERSION = _DEFAULT_ENVTEST_VERSION

def register_envtest_repositories(name = DEFAULT_ENVTEST_REPOSITORY, version = DEFAULT_ENVTEST_VERSION):
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
