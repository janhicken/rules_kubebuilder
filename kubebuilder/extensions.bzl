"""Extensions for bzlmod.

Installs kubebuilder toolchains.
Every module can define a toolchain version under the default name, e.g. "controller_gen".
Conflicting versions will result in build failures.

Additionally, the root module can define arbitrarily many more toolchain versions under different
names (the latest version will be picked for each name) and can register them as it sees fit,
effectively overriding the default named toolchain due to toolchain resolution precedence.
"""

load("@bazel_features//:features.bzl", "bazel_features")
load("//kubebuilder/private:extension_utils.bzl", "extension_utils")
load(
    ":repositories.bzl",
    "DEFAULT_CONTROLLER_GEN_REPOSITORY",
    "DEFAULT_CONTROLLER_GEN_VERSION",
    "DEFAULT_ENVTEST_REPOSITORY",
    "DEFAULT_ENVTEST_VERSION",
    "register_controller_gen_toolchains",
    "register_envtest_repositories",
)

controller_gen_toolchain = tag_class(attrs = {
    "name": attr.string(doc = """\
Base name for generated repositories, allowing more than one controller-gen toolchain to be registered.
Overriding the default is only permitted in the root module.
""", default = DEFAULT_CONTROLLER_GEN_REPOSITORY),
    "version": attr.string(doc = "Explicit version of controller-gen.", default = DEFAULT_CONTROLLER_GEN_VERSION),
})

envtest_repositories = tag_class(attrs = {
    "name": attr.string(doc = """\
    Base name for generated repositories, allowing more than one envtest repositories to be registered.
    Overriding the default is only permitted in the root module.
    """, default = DEFAULT_ENVTEST_REPOSITORY),
    "version": attr.string(doc = "Explicit version of envtet", default = DEFAULT_ENVTEST_VERSION),
})

def _toolchains_impl(mctx):
    extension_utils.toolchain_repos_bfs(
        mctx = mctx,
        get_tag_fn = lambda tags: tags.controller_gen,
        toolchain_name = "controller_gen",
        toolchain_repos_fn = lambda name, version: register_controller_gen_toolchains(name, version, register = False),
    )

    extension_utils.toolchain_repos_bfs(
        mctx = mctx,
        get_tag_fn = lambda tags: tags.envtest,
        toolchain_name = "envtest",
        toolchain_repos_fn = lambda name, version: register_envtest_repositories(name, version),
    )

    if bazel_features.external_deps.extension_metadata_has_reproducible:
        return mctx.extension_metadata(reproducible = True)

    return mctx.extension_metadata()

kubebuilder = module_extension(
    implementation = _toolchains_impl,
    tag_classes = {
        "controller_gen": controller_gen_toolchain,
        "envtest": envtest_repositories,
    },
)
