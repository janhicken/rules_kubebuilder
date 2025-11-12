"""Declare runtime dependencies

These are needed for local dev, and users must install them as well.
See https://docs.bazel.build/versions/main/skylark/deploying.html#dependencies
"""

load(
    "//kubebuilder/private:chainsaw_toolchain.bzl",
    "CHAINSAW_PLATFORMS",
    "chainsaw_platform_repo",
    "chainsaw_toolchains_repo",
    _CHAINSAW_VERSIONS = "CHAINSAW_VERSIONS",
    _DEFAULT_CHAINSAW_VERSION = "DEFAULT_CHAINSAW_VERSION",
)
load(
    "//kubebuilder/private:controller_gen_toolchain.bzl",
    "CONTROLLER_GEN_PLATFORMS",
    "KUBERNETES_VERSION_MAPPING",
    "controller_gen_platform_repo",
    "controller_gen_toolchains_repo",
)
load(
    "//kubebuilder/private:docker_toolchain.bzl",
    "DOCKER_PLATFORMS",
    "docker_platform_repo",
    "docker_toolchains_repo",
    _DEFAULT_DOCKER_VERSION = "DEFAULT_DOCKER_VERSION",
    _DOCKER_VERSIONS = "DOCKER_VERSIONS",
)
load(
    "//kubebuilder/private:envtest_toolchain.bzl",
    "ENVTEST_PLATFORMS",
    "ENVTEST_VERSIONS",
    "envtest_host_alias_repo",
    "envtest_platform_repo",
    "envtest_toolchains_repo",
)
load(
    "//kubebuilder/private:kind_toolchain.bzl",
    "KIND_PLATFORMS",
    "kind_platform_repo",
    "kind_toolchains_repo",
    _DEFAULT_KIND_VERSION = "DEFAULT_KIND_VERSION",
    _KIND_VERSIONS = "KIND_VERSIONS",
)

KUBERNETES_VERSIONS = ENVTEST_VERSIONS.keys()
DEFAULT_KUBERNETES_VERSION = "1.31.0"
CHAINSAW_VERSIONS = _CHAINSAW_VERSIONS.keys()
DOCKER_VERSIONS = _DOCKER_VERSIONS.keys()
KIND_VERSIONS = _KIND_VERSIONS.keys()
DEFAULT_CHAINSAW_VERSION = _DEFAULT_CHAINSAW_VERSION
DEFAULT_DOCKER_VERSION = _DEFAULT_DOCKER_VERSION
DEFAULT_KIND_VERSION = _DEFAULT_KIND_VERSION

def register_kubebuilder_repositories_and_toolchains(
        name = "",
        kubernetes_version = DEFAULT_KUBERNETES_VERSION,
        chainsaw_version = _DEFAULT_CHAINSAW_VERSION,
        docker_version = DEFAULT_DOCKER_VERSION,
        kind_version = _DEFAULT_KIND_VERSION,
        register = True):
    """
    Registers Kubebuilder repositories and toolchain

    Args:
        name: a common prefix for all generated repositories
        kubernetes_version: the target Kubernetes version to pick toolchain versions for
        chainsaw_version: the Chainsaw version to use
        docker_version: the Docker version to use
        kind_version: the kind version to use
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
    register_chainsaw_toolchains(name + DEFAULT_CHAINSAW_REPOSITORY, chainsaw_version)
    register_controller_gen_toolchains(name + DEFAULT_CONTROLLER_GEN_REPOSITORY, controller_gen_version, register)
    register_docker_repositories(name + DEFAULT_DOCKER_REPOSITORY, docker_version)
    register_envtest_repositories(name + DEFAULT_ENVTEST_REPOSITORY, kubernetes_version)

    register_kind_repositories(name + DEFAULT_KIND_REPOSITORY, kind_version, k8s_version_major_minor)

# ╔════════════════════════════════════════════════════════════════════════════╗
# ║                                  Chainsaw                                  ║
# ╚════════════════════════════════════════════════════════════════════════════╝

DEFAULT_CHAINSAW_REPOSITORY = "chainsaw"

def register_chainsaw_toolchains(name, version):
    """Registers Chainsaw repositories

    Args:
        name: override the prefix for the generated repositories
        version: the version of Chainsaw to use (see https://github.com/kyverno/chainsaw/releases)
    """
    for platform in CHAINSAW_PLATFORMS.keys():
        chainsaw_platform_repo(
            name = "%s_%s" % (name, platform),
            platform = platform,
            version = version,
        )

    chainsaw_toolchains_repo(
        name = "%s_toolchains" % name,
        user_repository_name = name,
    )

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

    controller_gen_toolchains_repo(
        name = "%s_toolchains" % name,
        user_repository_name = name,
    )

# ╔════════════════════════════════════════════════════════════════════════════╗
# ║                                   Docker                                   ║
# ╚════════════════════════════════════════════════════════════════════════════╝

DEFAULT_DOCKER_REPOSITORY = "docker"

def register_docker_repositories(name, version):
    """Registers Docker repositories

    Args:
        name: override the prefix for the generated repositories
        version: the version of Docker to use (see https://docs.docker.com/engine/release-notes)
    """
    for platform in DOCKER_PLATFORMS.keys():
        docker_platform_repo(
            name = "%s_%s" % (name, platform),
            platform = platform,
            version = version,
        )

    docker_toolchains_repo(
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

# ╔════════════════════════════════════════════════════════════════════════════╗
# ║                                    kind                                    ║
# ╚════════════════════════════════════════════════════════════════════════════╝

DEFAULT_KIND_REPOSITORY = "kind"

def register_kind_repositories(name, version, kubernetes_version):
    """Registers kind repositories

    Args:
        name: override the prefix for the generated repositories
        version: the version of kind to use (see https://github.com/kubernetes-sigs/kind/releases)
        kubernetes_version: the target Kubernetes version (major.minor; without patch) to pick node images for
    """
    for platform in KIND_PLATFORMS.keys():
        kind_platform_repo(
            name = "%s_%s" % (name, platform),
            platform = platform,
            version = version,
            kubernetes_version = kubernetes_version,
        )

    kind_toolchains_repo(
        name = "%s_toolchains" % name,
        user_repository_name = name,
    )
