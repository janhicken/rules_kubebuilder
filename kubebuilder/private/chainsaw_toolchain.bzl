"Setup Chainsaw repositories and rules"

CHAINSAW_PLATFORMS = {
    "darwin_amd64": struct(
        compatible_with = [
            "@platforms//os:macos",
            "@platforms//cpu:x86_64",
        ],
    ),
    "darwin_arm64": struct(
        compatible_with = [
            "@platforms//os:macos",
            "@platforms//cpu:aarch64",
        ],
    ),
    "linux_386": struct(
        compatible_with = [
            "@platforms//os:linux",
            "@platforms//cpu:i386",
        ],
    ),
    "linux_amd64": struct(
        compatible_with = [
            "@platforms//os:linux",
            "@platforms//cpu:x86_64",
        ],
    ),
    "linux_arm64": struct(
        compatible_with = [
            "@platforms//os:linux",
            "@platforms//cpu:aarch64",
        ],
    ),
    "linux_ppc64le": struct(
        compatible_with = [
            "@platforms//os:linux",
            "@platforms//cpu:ppc64le",
        ],
    ),
    "linux_s390x": struct(
        compatible_with = [
            "@platforms//os:linux",
            "@platforms//cpu:s390x",
        ],
    ),
    "windows_386": struct(
        compatible_with = [
            "@platforms//os:windows",
            "@platforms//cpu:i386",
        ],
    ),
    "windows_amd64": struct(
        compatible_with = [
            "@platforms//os:windows",
            "@platforms//cpu:x86_64",
        ],
    ),
    "windows_arm64": struct(
        compatible_with = [
            "@platforms//os:windows",
            "@platforms//cpu:arm64",
        ],
    ),
}

DEFAULT_CHAINSAW_VERSION = "0.2.13"

CHAINSAW_VERSIONS = {
    "0.2.13": {
        "darwin_amd64": {
            "sha256": "265ff7cd8ff45295da91de3e1f31ebc4552e2b389bd5af137214d82ee99bbc2a",
            "url": "https://github.com/kyverno/chainsaw/releases/download/v0.2.13/chainsaw_darwin_amd64.tar.gz",
        },
        "darwin_arm64": {
            "sha256": "45ce392cece57a7db28760d5c73243acd59090805eb013a304e4ac9e52217092",
            "url": "https://github.com/kyverno/chainsaw/releases/download/v0.2.13/chainsaw_darwin_arm64.tar.gz",
        },
        "linux_386": {
            "sha256": "156cc6e63c8c956a461ea5d781b12cb521c265c3dbe90858c74b04c4c26ced08",
            "url": "https://github.com/kyverno/chainsaw/releases/download/v0.2.13/chainsaw_linux_386.tar.gz",
        },
        "linux_amd64": {
            "sha256": "6c8d4cdccacbea7100a8354893b3176d874eecfe70c930fbe0496b7967d61ca4",
            "url": "https://github.com/kyverno/chainsaw/releases/download/v0.2.13/chainsaw_linux_amd64.tar.gz",
        },
        "linux_arm64": {
            "sha256": "f0bbbd1d4b6090bec8ad82305251098b7e9e5069dc67b328d68aeb57dc2974f7",
            "url": "https://github.com/kyverno/chainsaw/releases/download/v0.2.13/chainsaw_linux_arm64.tar.gz",
        },
        "linux_ppc64le": {
            "sha256": "2dfab6b99ceb3f14912794feb7d0eb5725bb58d5f8c27e142761ca47e95ea64c",
            "url": "https://github.com/kyverno/chainsaw/releases/download/v0.2.13/chainsaw_linux_ppc64le.tar.gz",
        },
        "linux_s390x": {
            "sha256": "f5d401a3b3730301c5f8a554718340d455f60ce1f868df123e57806c66e535a3",
            "url": "https://github.com/kyverno/chainsaw/releases/download/v0.2.13/chainsaw_linux_s390x.tar.gz",
        },
        "windows_386": {
            "sha256": "35f980c01735eb6abe8f442962aec16f7819f27511e9c749c433878526428d47",
            "url": "https://github.com/kyverno/chainsaw/releases/download/v0.2.13/chainsaw_windows_386.tar.gz",
        },
        "windows_amd64": {
            "sha256": "fe0c4104d56ef951c8a938e8b5f0f603f4e7853cd8a1a9a54702c1ce85cc3564",
            "url": "https://github.com/kyverno/chainsaw/releases/download/v0.2.13/chainsaw_windows_amd64.tar.gz",
        },
        "windows_arm64": {
            "sha256": "4a0b43cd9a1055041a5b183352be68f2e17e5103f747cf497c583070e65c3439",
            "url": "https://github.com/kyverno/chainsaw/releases/download/v0.2.13/chainsaw_windows_arm64.tar.gz",
        },
    },
}

def _chainsaw_toolchains_repo_impl(rctx):
    build = ""

    for [platform, meta] in CHAINSAW_PLATFORMS.items():
        build += """
toolchain(
    name = "{platform}_toolchain",
    exec_compatible_with = {compatible_with},
    toolchain = "@{user_repository_name}_{platform}//:chainsaw_toolchain",
    toolchain_type = "@io_github_janhicken_rules_kubebuilder//kubebuilder:chainsaw_toolchain",
)
""".format(
            platform = platform,
            user_repository_name = rctx.attr.user_repository_name,
            compatible_with = meta.compatible_with,
        )

    # Base BUILD file for this repository
    rctx.file("BUILD", build)

chainsaw_toolchains_repo = repository_rule(
    _chainsaw_toolchains_repo_impl,
    doc = """Creates a repository with toolchain definitions for all known platforms
     which can be registered or selected.""",
    attrs = {
        "user_repository_name": attr.string(doc = "Base name for toolchains repository"),
    },
)

def _chainsaw_platform_repo_impl(rctx):
    asset = CHAINSAW_VERSIONS[rctx.attr.version][rctx.attr.platform]

    rctx.download_and_extract(
        url = asset["url"],
        sha256 = asset["sha256"],
    )
    build = """# @generated by @io_github_janhicken_rules_kubebuilder//kubebuilder/private:chainsaw_toolchain.bzl
load("@io_github_janhicken_rules_kubebuilder//kubebuilder:toolchain.bzl", "chainsaw_toolchain")
exports_files(["chainsaw"])
chainsaw_toolchain(
    name = "chainsaw_toolchain",
    bin = "chainsaw",
    visibility = ["//visibility:public"],
)
"""

    # Base BUILD file for this repository
    rctx.file("BUILD", build)

chainsaw_platform_repo = repository_rule(
    implementation = _chainsaw_platform_repo_impl,
    doc = "Fetch external tools needed for the Chainsaw toolchain",
    attrs = {
        "platform": attr.string(mandatory = True, values = CHAINSAW_PLATFORMS.keys()),
        "version": attr.string(mandatory = True, values = CHAINSAW_VERSIONS.keys()),
    },
)
