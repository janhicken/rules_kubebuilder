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
    "kind_host_alias_repo",
    "kind_platform_repo",
    "kind_toolchains_repo",
    _DEFAULT_KIND_VERSION = "DEFAULT_KIND_VERSION",
    _KIND_VERSIONS = "KIND_VERSIONS",
)
load(
    "//kubebuilder/private:kuttl_toolchain.bzl",
    "KUTTL_PLATFORMS",
    "kuttl_platform_repo",
    "kuttl_toolchains_repo",
    _DEFAULT_KUTTL_VERSION = "DEFAULT_KUTTL_VERSION",
    _KUTTL_VERSIONS = "KUTTL_VERSIONS",
)

KUBERNETES_VERSIONS = ENVTEST_VERSIONS.keys()
DEFAULT_KUBERNETES_VERSION = "1.31.0"
DOCKER_VERSIONS = _DOCKER_VERSIONS.keys()
KIND_VERSIONS = _KIND_VERSIONS.keys()
KUTTL_VERSIONS = _KUTTL_VERSIONS.keys()
DEFAULT_DOCKER_VERSION = _DEFAULT_DOCKER_VERSION
DEFAULT_KIND_VERSION = _DEFAULT_KIND_VERSION
DEFAULT_KUTTL_VERSION = _DEFAULT_KUTTL_VERSION

def register_kubebuilder_repositories_and_toolchains(
        name = "",
        kubernetes_version = DEFAULT_KUBERNETES_VERSION,
        docker_version = DEFAULT_DOCKER_VERSION,
        kind_version = _DEFAULT_KIND_VERSION,
        kuttl_version = _DEFAULT_KUTTL_VERSION,
        register = True):
    """
    Registers Kubebuilder repositories and toolchain

    Args:
        name: a common prefix for all generated repositories
        kubernetes_version: the target Kubernetes version to pick toolchain versions for
        docker_version: the Docker version to use
        kind_version: the kind version to use
        kuttl_version: the kuttl version to use
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
    register_docker_repositories(name + DEFAULT_DOCKER_REPOSITORY, docker_version)
    register_envtest_repositories(name + DEFAULT_ENVTEST_REPOSITORY, kubernetes_version)

    register_kind_repositories(name + DEFAULT_KIND_REPOSITORY, kind_version, k8s_version_major_minor)
    register_kuttl_repositories(name + DEFAULT_KUTTL_REPOSITORY, kuttl_version)

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

    kind_host_alias_repo(name = name)

    kind_toolchains_repo(
        name = "%s_toolchains" % name,
        user_repository_name = name,
    )

# ╔════════════════════════════════════════════════════════════════════════════╗
# ║                                   kuttl                                    ║
# ╚════════════════════════════════════════════════════════════════════════════╝

DEFAULT_KUTTL_REPOSITORY = "kuttl"

def register_kuttl_repositories(name, version):
    """Registers kuttl repositories

    Args:
        name: override the prefix for the generated repositories
        version: the version of kind to use (see https://github.com/kudobuilder/kuttl/releases)
    """
    for platform in KUTTL_PLATFORMS.keys():
        kuttl_platform_repo(
            name = "%s_%s" % (name, platform),
            platform = platform,
            version = version,
        )

    kuttl_toolchains_repo(
        name = "%s_toolchains" % name,
        user_repository_name = name,
    )
