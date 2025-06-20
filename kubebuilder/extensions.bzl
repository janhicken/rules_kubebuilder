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
    "KUBERNETES_VERSIONS",
    "register_kubebuilder_repositories_and_toolchains",
)

kubernetes_target = tag_class(attrs = {
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
                targets[prefix] = version

    for prefix, version in targets.items():
        register_kubebuilder_repositories_and_toolchains(prefix, version, register = False)

    if bazel_features.external_deps.extension_metadata_has_reproducible:
        return mctx.extension_metadata(reproducible = True)

    return mctx.extension_metadata()

kubebuilder = module_extension(
    implementation = _kubebuilder_impl,
    tag_classes = {"for_kubernetes": kubernetes_target},
)
