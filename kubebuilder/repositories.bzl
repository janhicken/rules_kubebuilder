"""Declare runtime dependencies

These are needed for local dev, and users must install them as well.
See https://docs.bazel.build/versions/main/skylark/deploying.html#dependencies
"""

load("@bazel_tools//tools/build_defs/repo:http.bzl", _http_archive = "http_archive")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")
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

def http_archive(name, **kwargs):
    maybe(_http_archive, name = name, **kwargs)

# WARNING: any changes in this function may be BREAKING CHANGES for users
# because we'll fetch a dependency which may be different from one that
# they were previously fetching later in their WORKSPACE setup, and now
# ours took precedence. Such breakages are challenging for users, so any
# changes in this function should be marked as BREAKING in the commit message
# and released only in semver majors.
# This is all fixed by bzlmod, so we just tolerate it for now.
def rules_kubebuilder_dependencies():
    # The minimal version of bazel_skylib we require
    http_archive(
        name = "bazel_skylib",
        sha256 = "bc283cdfcd526a52c3201279cda4bc298652efa898b10b4db0837dc51652756f",
        urls = [
            "https://github.com/bazelbuild/bazel-skylib/releases/download/1.7.1/bazel-skylib-1.7.1.tar.gz",
            "https://mirror.bazel.build/github.com/bazelbuild/bazel-skylib/releases/download/1.7.1/bazel-skylib-1.7.1.tar.gz",
        ],
    )

def kubebuilder_register_toolchains(name):
    """Register all toolchains at their default versions.

    To be more selective about which toolchains and versions to register,
    call the individual registration macros.
    """
    register_controller_gen_toolchains()
    register_envtest_repositories()

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
