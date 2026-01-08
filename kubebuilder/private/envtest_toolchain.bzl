"Setup envtest repositories and rules"

load("@bazel_lib//lib:repo_utils.bzl", "repo_utils")

# Platform names follow the platform naming convention in @bazel_lib//lib:repo_utils.bzl
ENVTEST_PLATFORMS = {
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
            "@platforms//cpu:ppc",
        ],
    ),
    "linux_s390x": struct(
        compatible_with = [
            "@platforms//os:linux",
            "@platforms//cpu:s390x",
        ],
    ),
    "windows_amd64": struct(
        compatible_with = [
            "@platforms//os:windows",
            "@platforms//cpu:x86_64",
        ],
    ),
}

ENVTEST_VERSIONS = {
    "1.32.0": {
        "darwin_amd64": "sha512-p4JP+K6cUGK8veJDp6Ohx24C3gyS4rMy2vGVRAWu3thWAj8nfXQZeGLQ1ZCenh3KRRtfLoR5bkUa1gEeyY+EMw==",
        "darwin_arm64": "sha512-coxm75wlA90e2ho5j1egSCmrcDPhAHteI9bMhl6KxadT5JhoR8j1t2s0l65OPkaBIOJexd/jo7GQHT/yC5en+Q==",
        "linux_amd64": "sha512-OpWErzDQQcQok9j3qGCqQ0l21K7kec8umlCp5Wd9zIPTASohRqb+tbLpWns8b2V66cWRdFmBJi2osG5LYdzfFw==",
        "linux_arm64": "sha512-zm5ExaPpm1lROM3jlsGxeQldtHe+jM2fBcvRNbwVw5EADW4UaQeSKHLwGZucE6foq2tUAvjK41IlFPDvZZFAAA==",
        "linux_ppc64le": "sha512-9QZA/MDrTBx5QgBRaj75VCsxuUBHI0tWZ8PR/UZPvfom8Qtk/dxBtVtUZsIPoUGkOwUWT7wE6msq27FkknZxRQ==",
        "linux_s390x": "sha512-BuEGGB7aHfjUlmtRr1lcSNRIhFbh03BSAgpW9WhtCYpMMsfaEiqi65UGBU5oYQgaqOXJJXneYqbGlwblAPf+wg==",
        "windows_amd64": "sha512-uqrvprujXo6rNC0lpFvWQzHMXl1h/Qznixw2EON+wbCcPJ/t0ZUEHwlLvKy9ry4US/tS3DUdw26O+2D0ypyPJA==",
    },
    "1.33.0": {
        "darwin_amd64": "sha512-caOHpMrDKxfiIEbfWUCQtlA/wHS+jKrni8gO+DlJ4pKhKQ7v5yWs1Bzkvscw90QgBvKp6xnY4tTZ3y/rZ9oEug==",
        "darwin_arm64": "sha512-Yj3AJDKQXlhzjFYRuLCAhDd2J1UAPbruJm3tJ9/po31ade1leKxPuyYcfNGcAZmnQo3ne0Cy+IGRKkRoxNmNYQ==",
        "linux_amd64": "sha512-LLf1Ro7XzqFJL5cbcVvMJwaegkz31ZJ7fxJ/Hox1zwhu6gUFQ82195+u4KK/d18WCt8nRDqn7oRdli0E6dQ6yQ==",
        "linux_arm64": "sha512-NmujKyFUwW4M6VLtaXMf7v7Rh8iAMPdqFL2lkhpJjQqiVShin8QcIlz3jJH9SkJKRy447+yR6Py9JU+sDhUKVA==",
        "linux_ppc64le": "sha512-Xf8VnIkXaDPDxsWO08Tm5cy5oUtp0YAAOL02a6y98oo4LOqrF9Xu1XOVBI1FX09rN6r1oxos1bL+lnrYVZJ0Jg==",
        "linux_s390x": "sha512-ef9dvhPAUfoOnaMEPU9ws2CyItWFPCMAKYvklkrg3M10YJiL3dC1UrMjgsNobG674zVWZV+KqFdJVJfz8WAV/w==",
        "windows_amd64": "sha512-qQ3Wf6ypNGfms9PidZN2gePLUOAOIGpgmEui7nXIwjdiTuVXeuZHc6jurnJr2MixKkXnbZ2hgJ52+vl1/udxkQ==",
    },
    "1.34.0": {
        "darwin_amd64": "sha512-6S5BoYPoUE03Y71UhkGBZ85PYgRVbTpTx6vC5TjaY525QPihdkAw2L1cVljLw+yjXhwXSSkLdPwWU9puUX/JlQ==",
        "darwin_arm64": "sha512-uEHl/6NRsuoXSAk7YSvGPiOjY2LJAwTOxJjx7inChYtjwUYBKlYvOdkgMdumioGaOB1xw0i1Z8nemGwGnt/OBA==",
        "linux_amd64": "sha512-RFtN1UOWN0SSX//VIlQT2FKCFEKyRNtxAFerw6mM9aHhOaQ7S5eUkBA2Chmo/6tJcduX2rpg1y3fHMJgy/44RA==",
        "linux_arm64": "sha512-BvO3KxM1lfRjhJ2M3nw2MH4uUeFwm97RZZaUwb05SR0xM9U00zp8ON8RNsMU0eGtSDaExRnAaU9QW3A+0uRO+Q==",
        "linux_ppc64le": "sha512-U97krbcIsomNQJcykGk0UiGFiOeEhhPpFNQg0zqVD21ruL/MO4eck54pVSAtSq5WddgBvNyzOxpADQwJC82rAg==",
        "linux_s390x": "sha512-TbqG1KOeGpUG2w39Vij8Lx7ViiDdWizdNB0cRfEvLFLRwQM2R/4prXf4KuIlCFvRGY0nPCnO4uts69Yt41IS2A==",
        "windows_amd64": "sha512-yM7YP8bQbS5gknsIBhQqhpfcL9PSJeMzdrZdmRNE0JDeFqh6QORJwpJs/Q4ZgaNQXzpTTdtxkPXSbQV2XWozzg==",
    },
    "1.34.1": {
        "darwin_amd64": "sha512-2eBGTcFwjDarQRR7XjZMi44gHq/BTCmdy+WOvqqCxlG46DRkcWepUd7YxtCMYWqtuuFnOlR0P5yPoVonjHjAwA==",
        "darwin_arm64": "sha512-Q9fBC3QQDSAETffHO+A+JvgkOpy3wdMDXlge57sMf/yvdZueGCGGtbsvR9FgiDVBTKRDGBoC2ey2yc8EtD44CQ==",
        "linux_amd64": "sha512-xefCN64YqMZdDfEhS4ZOzRmqn/TxOD29R3wgJUbXeMD3Tv4VdQ7Dj1fY3ia6F81i9AREbN08l1OZpdRYneNc3Q==",
        "linux_arm64": "sha512-vxPSRWGD5m0ITijhye7WpAj7d6BtjR/QRhp9m8DJC2PSnqZ4cLKPgNH5kqywJgB9b0OYd1PIWcgdani8HKLJAw==",
        "linux_ppc64le": "sha512-wDF4Uyyv9RyY8j9kdEiJQQ/CAg67pBPGE+VEnqCJWG4CnuqHiayLXd8qlrvLv2vOf48+30UtPqik8WzJjbMD5w==",
        "linux_s390x": "sha512-Iiu8Of7XJqMeqJu7tnhF5Y/tSspaMAle7cJSPpKNKVFEWRl3auEuCO3dy8SJdwtT/0hRI3VyF20J5y9ujeHrCQ==",
        "windows_amd64": "sha512-VL++KWCgpHpMJsD/WiKxsMccsDxIYI9ozdF//DavTnBHn8eyJItcWoKGWmKkc8xGvm+4MLbqu/XjAccVT98rCw==",
    },
    "1.35.0": {
        "darwin_amd64": "sha512-/MxYO6bTIsiKjFb3h2CQp61jRgBGpLyuQUCTsjzminXxcsp0hLfHR1twdlfspRCKitP9heG09wpsmcovItvWsg==",
        "darwin_arm64": "sha512-u10Ls5dZVjMbCqDAOZVbTE3GxcKI5a82k2TH0vvqwRoCUifauxJ1aQgLJZ3Sm2l8x3+ner0nriZyHdsj6O4GEw==",
        "linux_amd64": "sha512-EwNpwW8HbnJNCJGJr67elgMW9fXeps9XvnpPxvCcdzQokxklCXkOQFbhFuIy3/gy7YY/W9Vdy1XTjzq4NIKKEQ==",
        "linux_arm64": "sha512-5T4riDmPW5UD4/B02CotywkMcIs0lAhIYHzmWBOKXUolli4EKraDzMAmqKbJDAvn9ljkLd4Ihzadc8O2ji/IbA==",
        "linux_ppc64le": "sha512-4yqnSx/W3OdU14iWuAea1w1d3PR2AHOdK+cfWRCJnQkRt9HkcI/qgrPaojNg83J5OIJ1q/AUHeQkIHsiyRwqUQ==",
        "linux_s390x": "sha512-87tOXEAi4dXdgoe5EbvQ8xHoI66E5kO9Y3nEy1W3D3mGg+iUm9D1QhSW95G1x+PAQed36F+33zbQ2kCzZ2oXBQ==",
        "windows_amd64": "sha512-dZhDBZUEzpu4IEALIlFroNq2vJJ4unLbyYq4oZprCetlU9ZT1AD3leGjLSQWLQlsZ7u/fxIA5DZhiXtlcs9lIg==",
        "windows_arm64": "sha512-YknsZA+GUjpwjFSisW2AbUMSJtks61ou64rL8SKxgsMYMHwsS2Ex7irwoVwY+vshuaHOla5AVh608j15zxdU1A==",
    },
}

def _envtest_toolchains_repo_impl(rctx):
    # Expose a concrete toolchain which is the result of Bazel resolving the toolchain
    # for the execution or target platform.
    # Workaround for https://github.com/bazelbuild/bazel/issues/14009
    defs_bzl = """# @generated by @io_github_janhicken_rules_kubebuilder//kubebuilder/private:envtest_toolchain.bzl

# Forward all the providers
def _resolved_toolchain_impl(ctx):
    toolchain_info = ctx.toolchains["@io_github_janhicken_rules_kubebuilder//kubebuilder:envtest_toolchain"]
    return [
        toolchain_info,
        toolchain_info.default,
        toolchain_info.envtest,
        toolchain_info.template_variables,
    ]

# Copied from java_toolchain_alias
# https://cs.opensource.google/bazel/bazel/+/master:tools/jdk/java_toolchain_alias.bzl
resolved_toolchain = rule(
    implementation = _resolved_toolchain_impl,
    toolchains = ["@io_github_janhicken_rules_kubebuilder//kubebuilder:envtest_toolchain"],
    incompatible_use_toolchain_transition = True,
)
"""
    rctx.file("defs.bzl", defs_bzl)

    build = """# @generated by @io_github_janhicken_rules_kubebuilder//kubebuilder/private:envtest_toolchain.bzl
#
# These can be registered in the workspace file or passed to --extra_toolchains flag.
# By default all these toolchains are registered by the envtest_register_toolchains macro
# so you don't normally need to interact with these targets.

load(":defs.bzl", "resolved_toolchain")

resolved_toolchain(name = "resolved_toolchain", visibility = ["//visibility:public"])

"""

    for [platform, meta] in ENVTEST_PLATFORMS.items():
        build += """
toolchain(
    name = "{platform}_toolchain",
    exec_compatible_with = {compatible_with},
    toolchain = "@{user_repository_name}_{platform}//:envtest_toolchain",
    toolchain_type = "@io_github_janhicken_rules_kubebuilder//kubebuilder:envtest_toolchain",
)
""".format(
            platform = platform,
            user_repository_name = rctx.attr.user_repository_name,
            compatible_with = meta.compatible_with,
        )

    # Base BUILD file for this repository
    rctx.file("BUILD", build)

envtest_toolchains_repo = repository_rule(
    _envtest_toolchains_repo_impl,
    doc = """Creates a repository with toolchain definitions for all known platforms
     which can be registered or selected.""",
    attrs = {
        "user_repository_name": attr.string(doc = "Base name for toolchains repository"),
    },
)

def _envtest_platform_repo_impl(rctx):
    # https://github.com/kubernetes-sigs/controller-tools/releases/download/envtest-v1.28.0/envtest-v1.28.0-darwin-amd64.tar.gz
    url = "https://github.com/kubernetes-sigs/controller-tools/releases/download/envtest-v{0}/envtest-v{0}-{1}.tar.gz".format(
        rctx.attr.version,
        rctx.attr.platform.replace("_", "-"),
    )

    rctx.download_and_extract(
        url = url,
        integrity = ENVTEST_VERSIONS[rctx.attr.version][rctx.attr.platform],
        stripPrefix = "controller-tools",
    )

    rctx.file("BUILD", """# generated by @io_github_janhicken_rules_kubebuilder//kubebuilder/private:envtest_toolchain.bzl
load("@io_github_janhicken_rules_kubebuilder//kubebuilder:toolchain.bzl", "envtest_toolchain")
exports_files(
    ["envtest"],
    visibility = ["//visibility:public"],
)
envtest_toolchain(
    name = "envtest_toolchain",
    etcd = "envtest/etcd",
    kube_apiserver = "envtest/kube-apiserver",
    kubectl = "envtest/kubectl",
    visibility = ["//visibility:public"]
)
""")

envtest_platform_repo = repository_rule(
    implementation = _envtest_platform_repo_impl,
    doc = "Fetch external tools needed for envtest toolchain",
    attrs = {
        "platform": attr.string(mandatory = True, values = ENVTEST_PLATFORMS.keys()),
        "version": attr.string(mandatory = True, values = ENVTEST_VERSIONS.keys()),
    },
)

def _envtest_host_alias_repo(rctx):
    rctx.file(
        "BUILD",
        """# generated by @io_github_janhicken_rules_kubebuilder//kubebuilder/private:envtest_toolchain.bzl
exports_files(
    ["envtest"],
    visibility = ["//visibility:public"],
)
""",
    )

    rctx.symlink("../{name}_{platform}/envtest".format(
        name = rctx.attr.name,
        platform = repo_utils.platform(rctx),
    ), "envtest")

envtest_host_alias_repo = repository_rule(
    implementation = _envtest_host_alias_repo,
)
