"""Extensions for bzlmod.

Installs kubebuilder toolchains.
Every module can define a toolchain version under the default name, e.g. "controller_gen".
Conflicting versions will result in build failures.

Additionally, the root module can define arbitrarily many more toolchain versions under different
names (the latest version will be picked for each name) and can register them as it sees fit,
effectively overriding the default named toolchain due to toolchain resolution precedence.
"""

load("@bazel_features//:features.bzl", "bazel_features")
load(
    ":repositories.bzl",
    "CHAINSAW_VERSIONS",
    "DEFAULT_CHAINSAW_VERSION",
    "DEFAULT_DOCKER_VERSION",
    "DEFAULT_KIND_VERSION",
    "DEFAULT_KUTTL_VERSION",
    "DOCKER_VERSIONS",
    "KIND_VERSIONS",
    "KUBERNETES_VERSIONS",
    "KUTTL_VERSIONS",
    "register_kubebuilder_repositories_and_toolchains",
)

kubernetes_target = tag_class(attrs = {
    "chainsaw_version": attr.string(
        doc = "The Chainsaw version to use",
        default = DEFAULT_CHAINSAW_VERSION,
        values = CHAINSAW_VERSIONS,
    ),
    "docker_version": attr.string(
        doc = "The Docker version to use",
        default = DEFAULT_DOCKER_VERSION,
        values = DOCKER_VERSIONS,
    ),
    "kind_version": attr.string(
        doc = "The kind version to use",
        default = DEFAULT_KIND_VERSION,
        values = KIND_VERSIONS,
    ),
    "kuttl_version": attr.string(
        doc = "The kuttl version to use",
        default = DEFAULT_KUTTL_VERSION,
        values = KUTTL_VERSIONS,
    ),
    "prefix": attr.string(
        default = "",
        doc = """\
Prefix for generated repositories, allowing more than one kubebuilder toolchain to be registered.
Overriding the default is only permitted in the root module.
""",
    ),
    "version": attr.string(
        mandatory = True,
        values = KUBERNETES_VERSIONS,
        doc = "The Kubernetes version to target.",
    ),
})

def _kubebuilder_impl(mctx):
    targets = {}
    for mod in mctx.modules:
        for k8s_target in mod.tags.for_kubernetes:
            prefix = k8s_target.prefix
            version = k8s_target.version
            chainsaw_version = k8s_target.chainsaw_version
            docker_version = k8s_target.docker_version
            kind_version = k8s_target.kind_version
            kuttl_version = k8s_target.kuttl_version
            if prefix and not mod.is_root:
                fail("Only the root module may provide a prefix for the kubernetes target.")

            if prefix in targets.keys():
                if not prefix:
                    # Prioritize the root-most registration of the default toolchain version and
                    # ignore any further registrations (modules are processed breadth-first)
                    continue
                if version == targets[prefix]:
                    # No problem to register a matching toolchain twice
                    continue
                fail("Multiple conflicting kubernetes targets declared for prefix {} ({} and {})".format(
                    prefix,
                    version,
                    targets[prefix],
                ))
            else:
                targets[prefix] = {
                    "chainsaw_version": chainsaw_version,
                    "docker_version": docker_version,
                    "kind_version": kind_version,
                    "kuttl_version": kuttl_version,
                    "version": version,
                }

    for prefix, versions in targets.items():
        register_kubebuilder_repositories_and_toolchains(
            prefix,
            versions["version"],
            versions["chainsaw_version"],
            versions["docker_version"],
            versions["kind_version"],
            versions["kuttl_version"],
            register = False,
        )

    if bazel_features.external_deps.extension_metadata_has_reproducible:
        return mctx.extension_metadata(reproducible = True)

    return mctx.extension_metadata()

kubebuilder = module_extension(
    implementation = _kubebuilder_impl,
    tag_classes = {"for_kubernetes": kubernetes_target},
)
