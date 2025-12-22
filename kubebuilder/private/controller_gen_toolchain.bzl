"Setup controller-gen repositories and rules"

CONTROLLER_GEN_PLATFORMS = {
    "darwin-amd64": struct(
        compatible_with = [
            "@platforms//os:macos",
            "@platforms//cpu:x86_64",
        ],
    ),
    "darwin-arm64": struct(
        compatible_with = [
            "@platforms//os:macos",
            "@platforms//cpu:aarch64",
        ],
    ),
    "linux-amd64": struct(
        compatible_with = [
            "@platforms//os:linux",
            "@platforms//cpu:x86_64",
        ],
    ),
    "linux-arm64": struct(
        compatible_with = [
            "@platforms//os:linux",
            "@platforms//cpu:aarch64",
        ],
    ),
    "linux-ppc64le": struct(
        compatible_with = [
            "@platforms//os:linux",
            "@platforms//cpu:ppc",
        ],
    ),
    "linux-s390x": struct(
        compatible_with = [
            "@platforms//os:linux",
            "@platforms//cpu:s390x",
        ],
    ),
    "windows-amd64": struct(
        compatible_with = [
            "@platforms//os:windows",
            "@platforms//cpu:x86_64",
        ],
    ),
}

KUBERNETES_VERSION_MAPPING = {
    "1.32": "0.17.3",
    "1.33": "0.18.0",
    "1.34": "0.19.0",
    "1.35": "0.20.0",
}

CONTROLLER_GEN_VERSIONS = {
    "0.17.0": {
        "darwin-amd64": "sha384-7MqW8VMm/BTuPpTD5tZQhMf0FhqPln86k7eGGA4D8gHli78rYA3TMugLioOj3iOP",
        "darwin-arm64": "sha384-5KvFlhvTW9DFjfjuYAboc8ZbCSEpza442N/72Id5rxttqADvB2zMmHGHUmWdfngF",
        "linux-amd64": "sha384-z4AEzgJggyUgp5JxEC5Q5cX7lWxCQcTkkOJ5krGv9f6agqcgRk9jz24t1B222ekk",
        "linux-arm64": "sha384-8ecAC3RVfRLyyXsrOurvcjgHVl7Z3qIgBjAHn8ycwz/eiy5As3g+/RG71TSkt03H",
        "linux-ppc64le": "sha384-uAh53LAKwCw2n21S+mXyEOZEJAGBDElbWVvf4l8LuYZmJ3NsGTE0e93lW7Mylzhg",
        "linux-s390x": "sha384-YT1m8Tr8CL1BLSqAtIeA8P3qrsqfttcDbnUTDU6/sRZHt/+8f68+/2dW9wH7vwpj",
        "windows-amd64": "sha384-hOfD4sHKXKzEaKR3V6cAcNpHeN9qCp3JVZKbkqGgWHAwSmuIwzDgRKvflCWNduIi",
    },
    "0.17.1": {
        "darwin-amd64": "sha384-K4cZ4dDhde3sPdALm6ge6NSDtd/73OHz2GnTpkJ5kwntgN2lJrW7qSTBE5wwrUBF",
        "darwin-arm64": "sha384-SlVD1PV4ezAUxvFschcvJpLuXgTrD3tCxv4rlsVPdq8rUe0oD0zoCreHAp9L6V9A",
        "linux-amd64": "sha384-y9faaFFYGRxjwxqs9sXoloevE8r3DGNDD6axIOq7b0PXoycYfTdaxGUEi+XJ4W+3",
        "linux-arm64": "sha384-1MDuYTK/481+o5/eyn9BF/Bf/UHIqwSUq6VA2HRU1gGKaUo5PDYUAaLuCYvggJjR",
        "linux-ppc64le": "sha384-0EBSVCMk/9g4I0BJMVUYYYdkWn6YdwPnMvcwPdRbcWRFcmLWhSCDdNq7MvuHVTHN",
        "linux-s390x": "sha384-vvbzVx7NclsEdwsjUYq7EUIuefmJCTeevFyUAhLoHfyJ5BZ1cEdghjouof08gcyW",
        "windows-amd64": "sha384-zQVvmtKDZ24cLryxABMrcAtdZGqbt2vpm/AzsAGOUUzh/MJoEQoVtnoXEpHkGluI",
    },
    "0.17.2": {
        "darwin-amd64": "sha384-8ZIH983FEpJBnasG4C6j9NSdCHOTRsVT2Y/5tDwoIIYrD3tIm2iPw9Wovr4vV1v2",
        "darwin-arm64": "sha384-pSX6hbJLkGxFVIqYYkyKvr543MWIh9ZII0o1wqW5xZE/ZGXfzsRR0sTb+QdoWivw",
        "linux-amd64": "sha384-3AzbJs3A85PGPP3uhQHEneza7w3hW+x3w2RyFVBkesBe41MrKbehoR2zHG93EUim",
        "linux-arm64": "sha384-j+hLD1ixY+cqsGTSytoocOoH3VtUUUztglGcONiRxst4Yr8L/bzgAMdI9bIu60qw",
        "linux-ppc64le": "sha384-W9Tesu0f+xIKhTtZbMhJMwwKLzAhRB9Fey31Ig12TdIaua8lXaJ0bWDbLPAJCgO2",
        "linux-s390x": "sha384-20oylTV6LvD3lE1WrtNlEw7upCylVU76GF6LcpsE8UubHE2wCQ7DnE4hh6oWDdpO",
        "windows-amd64": "sha384-0xlCi+r7yMGUHr6h58BxZAQDtbhzM5SW2ZRAiBOqrfiLJxixnvU1vbgL9K8Ez5+u",
    },
    "0.17.3": {
        "darwin-amd64": "sha384-pOrIi2qQw4zB6kYHjgcUExzxil8ao5JOrbrcNRClcEKDq/GsCz4IlPLmeCQT43yy",
        "darwin-arm64": "sha384-P5QaN4bmBnzjHZQliVfP3Gs3e5UwOP8gYCZDne5DvOCnOuiBWtxCM84/8DdLhBVy",
        "linux-amd64": "sha384-0JuGGoQAqE1xTB0y1A15dRs96ALUyC/vUbnG8QyYt2i9JoNo4I0ez4VWvns23VCG",
        "linux-arm64": "sha384-4GK3AjqlyEq0OJdE+n0jqvShjFL4pKGmerjqVHfzg8crWX+Z7In01vF60u0/gbGo",
        "linux-ppc64le": "sha384-uuPHUoAC1m63DvkaMfgGT+DBy+jvWeP7lWqAepE18UmZo7jqI8VNQekkrBjlbcja",
        "linux-s390x": "sha384-gAaq3mNGy3sAAOUkqCqqkMTiKlEy0d1+pqf+1bJOFnBy/0JwTsCNOkz7JnaPP0Fr",
        "windows-amd64": "sha384-QbtaGOdRbZ3xDsPGWCijUliLzOU7Z1aYfUfC+UqJWmgy+iXxqEEvw9r7EZB1eLQK",
    },
    "0.18.0": {
        "darwin-amd64": "sha384-bVVHwzMOh+lrzMpteNYSBV7Mq5MSYSPQ4M2j/adLV0rVxkqVV/nhpAvV48aQVS6V",
        "darwin-arm64": "sha384-Gjfse8ifYVHoqYIwh+OmQXN/KdOjQHr3O0e6gfgIBQXB50OtZntEs7JSHDLDReRj",
        "linux-amd64": "sha384-jMZzGpPYGU55fclPofAqHxyd37yXFAB4u5S/7yiH6VuBwFY22nMFY7kqfnsDoLXv",
        "linux-arm64": "sha384-NiC4boKh0iY8nFqIUdLpSJY4qwN5dXmWSPVWeMF2UJmj3HHGRA8fUnnjiZVQoTDT",
        "linux-ppc64le": "sha384-95LDfZKmZfmZK6pGYkC3aWTAVhk7PStDdAQrHcZTV6zivu9tdozOTmvQDOEtgZq/",
        "linux-s390x": "sha384-qA0zRT0NRmO6N8HhzTxbmTvx/t9SOCoIpxyalYKXIk1zvYFd8br8mJyUJ2XEbbRv",
        "windows-amd64": "sha384-NSGhVYQnN+BdgzvodcWr5fFmMfGUQdotb+4Xxexn8L1P2JJvTMKczLXIWT9ZdEDJ",
    },
    "0.19.0": {
        "darwin-amd64": "sha384-RWp3N0j++AFWbkpocYTXAIcvcFZ4M52rJNrGytiL5UKuSqyxmIiszxnHvJrKX/np",
        "darwin-arm64": "sha384-iQSDVVU9iiUeDlW1E0gi+EweyZKcCXVO3ABkmvpn7GLRPTmqwMEHILl6eLrwAoA6",
        "linux-amd64": "sha384-PmbZLpovXiraxmmokhNoZ9XITn2eYqSs2u8erFzq4eX8BJsA+QbBaETREuYP+15+",
        "linux-arm64": "sha384-GlPisQ9VwsIdZ4hqLSjl+fMRTJm+faUPgTWyyTPa5DNg7nCL1rDDVORn2/esluqG",
        "linux-ppc64le": "sha384-r50zeAnuCqCB8VgGy7i0LtxxzTSgNlA9lsayxcmNIV+5LMnuP3gqt9TgBHVxw0vz",
        "linux-s390x": "sha384-vj0KJQB16WsN/FcP9zyX8ucIzus8atuv2jRGnVD7a48BukGzfXMoxtHkF6QiYZBN",
        "windows-amd64": "sha384-J6ZjXXWtWleEGCokfJc9/JuaDNK/eMdkzeK/rQWvxYqxvwrTjJoBoPjmT3nl0w8C",
    },
    "0.20.0": {
        "darwin-amd64": "sha384-9/yeZSggLpKECGCfMfHsD38Yfu36py0sl/UOLePZHOqJDVkz80oNUP+r9cbiDf6N",
        "darwin-arm64": "sha384-GCgErBqDkQ8pF/UKnZR9L2P2ZeSEwIx4PiwAd4ZHasMkGAnvQfWAJuZtSXMWQvBR",
        "linux-amd64": "sha384-qrRBvv/fhcrGbDN6uPBozdhJ/V7KvlseJzRkAnfGMnOI7iywRhtxVZIymz7bucIL",
        "linux-arm64": "sha384-zQmuQ4CvbfU4oWAanhtbZ0uqs/5Az0EBMyuVwChCjAyhqJ6RxMvvzKk4aBFCuCZA",
        "linux-ppc64le": "sha384-F/AD3v1nRToFk8K4dgPKkefpUIN04SbqGEpJyBVkAUMD0pn3MZghLsE/v+0t6cZt",
        "linux-s390x": "sha384-pHmAPTbFmiUdu/gc55UYmugAgqPTcqt1+aiV64CZSlK4vEUvOOI6rwnoejPAwgj8",
        "windows-amd64": "sha384-v/mSIOIKedg/1Upa1VlWkg/hy/zG+ADTGeNm/JnJJbacKG611EwF0M/QQ/USiDI8",
    },
}

def _controller_gen_toolchains_repo_impl(rctx):
    # Expose a concrete toolchain which is the result of Bazel resolving the toolchain
    # for the execution or target platform.
    # Workaround for https://github.com/bazelbuild/bazel/issues/14009
    defs_bzl = """# @generated by @io_github_janhicken_rules_kubebuilder//kubebuilder/private:controller_gen_toolchain.bzl

# Forward all the providers
def _resolved_toolchain_impl(ctx):
    toolchain_info = ctx.toolchains["@io_github_janhicken_rules_kubebuilder//kubebuilder:controller_gen_toolchain"]
    return [
        toolchain_info,
        toolchain_info.default,
        toolchain_info.controller_gen,
        toolchain_info.template_variables,
    ]

# Copied from java_toolchain_alias
# https://cs.opensource.google/bazel/bazel/+/master:tools/jdk/java_toolchain_alias.bzl
resolved_toolchain = rule(
    implementation = _resolved_toolchain_impl,
    toolchains = ["@io_github_janhicken_rules_kubebuilder//kubebuilder:controller_gen_toolchain"],
    incompatible_use_toolchain_transition = True,
)
"""
    rctx.file("defs.bzl", defs_bzl)

    build = """# @generated by @io_github_janhicken_rules_kubebuilder//kubebuilder/private:controller_gen_toolchain.bzl
#
# These can be registered in the workspace file or passed to --extra_toolchains flag.
# By default all these toolchains are registered by the controller_gen_register_toolchains macro
# so you don't normally need to interact with these targets.

load(":defs.bzl", "resolved_toolchain")

resolved_toolchain(name = "resolved_toolchain", visibility = ["//visibility:public"])

"""

    for [platform, meta] in CONTROLLER_GEN_PLATFORMS.items():
        build += """
toolchain(
    name = "{platform}_toolchain",
    exec_compatible_with = {compatible_with},
    toolchain = "@{user_repository_name}_{platform}//:controller_gen_toolchain",
    toolchain_type = "@io_github_janhicken_rules_kubebuilder//kubebuilder:controller_gen_toolchain",
)
""".format(
            platform = platform,
            user_repository_name = rctx.attr.user_repository_name,
            compatible_with = meta.compatible_with,
        )

    # Base BUILD file for this repository
    rctx.file("BUILD", build)

controller_gen_toolchains_repo = repository_rule(
    _controller_gen_toolchains_repo_impl,
    doc = """Creates a repository with toolchain definitions for all known platforms
     which can be registered or selected.""",
    attrs = {
        "user_repository_name": attr.string(doc = "Base name for toolchains repository"),
    },
)

def _controller_gen_platform_repo_impl(rctx):
    ext = ".exe" if "windows" in rctx.attr.platform else ""

    # https://github.com/kubernetes-sigs/controller-tools/releases/download/v0.17.2/controller-gen-darwin-arm64
    url = "https://github.com/kubernetes-sigs/controller-tools/releases/download/v{0}/controller-gen-{1}{2}".format(
        rctx.attr.version,
        rctx.attr.platform,
        ext,
    )

    rctx.download(
        url = url,
        output = "controller-gen" + ext,
        executable = True,
        integrity = CONTROLLER_GEN_VERSIONS[rctx.attr.version][rctx.attr.platform],
    )
    build = """# @generated by @io_github_janhicken_rules_kubebuilder//kubebuilder/private:controller_gen_toolchain.bzl
load("@io_github_janhicken_rules_kubebuilder//kubebuilder:toolchain.bzl", "controller_gen_toolchain")
exports_files(["{0}"])
controller_gen_toolchain(name = "controller_gen_toolchain", bin = "{0}", visibility = ["//visibility:public"])
""".format("controller-gen" + ext)

    # Base BUILD file for this repository
    rctx.file("BUILD", build)

controller_gen_platform_repo = repository_rule(
    implementation = _controller_gen_platform_repo_impl,
    doc = "Fetch external tools needed for controller_gen toolchain",
    attrs = {
        "platform": attr.string(mandatory = True, values = CONTROLLER_GEN_PLATFORMS.keys()),
        "version": attr.string(mandatory = True, values = CONTROLLER_GEN_VERSIONS.keys()),
    },
)
