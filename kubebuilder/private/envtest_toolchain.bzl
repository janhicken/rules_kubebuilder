"Setup envtest repositories and rules"

load("@aspect_bazel_lib//lib:repo_utils.bzl", "repo_utils")

# Platform names follow the platform naming convention in @aspect_bazel_lib//lib:repo_utils.bzl
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
    "1.30.0": {
        "darwin_amd64": "sha512-5wWzUYkFKICv7+rHJ5eDTSdQv8/Ilx3ZE8wrVXXqciLpz6Prs4peXe7I8GCJ7MZUvq+cT+mQrPQeV3WMJrPWKg==",
        "darwin_arm64": "sha512-SMH6VVXwIfiqNl+qqWsQaATOXjAiFCoqFmvJHs1bItp58BLSDBpJY+AjbfAKIU8zEc3YQt5KsZRCyhyDs7y4WQ==",
        "linux_amd64": "sha512-1Thw4abJs7UDZkiak4f04lTGZJVeky4+JeIIi7Q3snC/q3XSQbUISSM/mjS7Hwi0FWfruB6ik1IQSuD1scueiA==",
        "linux_arm64": "sha512-FAdI76o5RZj1AXXoCc1TiWiB7QRtk+vfvVRCEA9os9jVH9IvjPGuBqbkNHOJe3id8NtuCubEXIMgsADV7pAABQ==",
        "linux_ppc64le": "sha512-BONXA1QAFUfQTv8XZNDa2p9UUf6tVUTn8wRXh0tNFX/GK3aQJvTE/juN76UokrciUyIp4sbCetmMNYx2rQGEJg==",
        "linux_s390x": "sha512-GfLVFrW3dTr9q5kZAeaQzbcoNnt4OzIznL4tE4YZs1weWdEzaLeDprRVsw0ZCr3+t5l8SK4XEPZsabLcN8hDdQ==",
        "windows_amd64": "sha512-vwhGM30vuFuWdq5etHxnbpMVYS3Mui5Px0jWx2vBIoMhz6GCJ06Xc9ZJwimPYk9iJ4AyxUdzYVmoaVsXEt5k0A==",
    },
    "1.30.2": {
        "darwin_amd64": "sha512-v64zF+eqA5E9FDWgjNEQrEYwIkOJI08U8p0f81M3rLcDm/ZCEEHahJw+TMbChH0oXCnD61IY1Okh77Bz60E73A==",
        "darwin_arm64": "sha512-VZy3QPIigl9P0YkzMn1dBXYPD1X5CYzuD8qIgMbeEPZrcea7pYQaff8UOp7SJR4tiQTYivedXX47kB0hwcyMHA==",
        "linux_amd64": "sha512-vo2ntHB1R7fKDZoesZxWh/Ri/vipEvBtan/A5giO4cLmSyP7MwpbTp7zw1AKOwafFmReUBrkdfHpmAWl8w5XAA==",
        "linux_arm64": "sha512-ZIQGkKnXV6D1nwnxptm1TgJddA16HNwzeFpdBfuPXemaQO1shgi7hG09m4A9Tzk/lHTgF0/DleMZBCz/82JoxQ==",
        "linux_ppc64le": "sha512-qkEsGkDOOprGTE5CeMwkhdpICsJnUPNyISE59uk6XJmYWLiGYciDF0C8ChjOPAyjRzNsboHd86yLYMw2ZvJSzw==",
        "linux_s390x": "sha512-IxbO7/0BcMi018iKhustFMAS8vbxdEgFLA6JEVZwaUC5yN+LFosvRlBu/51uzfgHAS3cQwfoxVEXsU+GCjsbpQ==",
        "windows_amd64": "sha512-Ci1kBc1CEb+9q//iFG/Xjfr3Vi73/fXvkQ764gLeyUTyUUBT6Z3Kn5wzUqwgz/YogdzArbXz0iUb8BnEHpYF7w==",
    },
    "1.30.3": {
        "darwin_amd64": "sha512-VjW+tuCKIoMYpD2d8nupKHnIzlU6OW4YMwYyuFtHJLPyxJy0HFUMFimQb1g7szJvl3x0FFcmuHJ8hG0UNj0zcw==",
        "darwin_arm64": "sha512-h47tMBb7xQXKsxC0m+K62y24jqqgL6IcRIwP9ZbVz9KPlNspQyBQ6yfxp6/qcRV+3LT+YUjyjmO/RmirfV2LWw==",
        "linux_amd64": "sha512-DllIUR41FW6KuiY/2HiYOxGq2C0PdLVQepgEudEBWD8cSEKBaQxv8aNnjtA4yHSRVZJ1k3QIS3i1et490SZsHQ==",
        "linux_arm64": "sha512-slxF1HN5IuEjQzRLKCTSaBwAZvkiQtWbucovPRUlPxsOqoj1ZdmPxvyw3yTmeRae0OzcR3gqTiWH3edrGau7DQ==",
        "linux_ppc64le": "sha512-nHEgGW5nrAT08krCfvrXHSwThGcdcH7+XG5uAgMlMNyLjyREYuHv9SAoelC1E91ys4wsr5ejQDofVs8TyZdWSw==",
        "linux_s390x": "sha512-BkOi7IdcOG6KJSRR9oOS2WbFAnuK94ol9WYNf0NE7YqiXPjYBXRZ67GNA5xJThvjk1kqKXJLFUA148ZUHaPqbg==",
        "windows_amd64": "sha512-qvdWq7TiczXHkVU4ZXYa+BgJe0jGtgLwlsHguFD6m6CrPyNMtIfaP/dkb8mqu1KIJT0CEOuAcb4oSe7ynO0grw==",
    },
    "1.31.0": {
        "darwin_amd64": "sha512-1oGDhgmhsIVucxiI4NsKEZEAPhAhgBtZabfXCEEwB2swstmeU+Rg8cUgKzMINUohGL1KMw0G2XeX7wCd1W4lbg==",
        "darwin_arm64": "sha512-5Cwn4e6Q0T1WGJ5mXUx5t6NPY3WB/H4gsCijwWsiuFBgdg65HKeZAbwcItzQ1m70Gg92DC8a5lJl8FduQQnYfQ==",
        "linux_amd64": "sha512-XZauKEYQhjzll04DCuzS6q1pPzIQEDyneBB6oOoA9vHQp7GzSqdNclfLDX9xPC2jZb66ibHWCCPOVse4S5NUIw==",
        "linux_arm64": "sha512-cvXI/WFcnbYu62bjDt/aDzh5v/o1d8V3bsgzY8AY1/UcF0rF6oB0FAcqIfgVGnvfmCb0FFQ/aQaGVQ5J2yAsoA==",
        "linux_ppc64le": "sha512-N4v1RNWXay+YiE2IRSIA48xgqVHShrUlE2G9sa6aoTbhI1zbBo9Y4uQVPNkh2Kw2XRWk146FDdVweHrIm95GGw==",
        "linux_s390x": "sha512-J5yMA88G9twW0G4BTwX4jr7hu2T1yoh3M26+jbwARXMm0XZfIJNLIL5c4dO4T+tKBAZ1dj/16zYoSIE2Zndhcg==",
        "windows_amd64": "sha512-QwOoElx8w7LWiSQT9x9avB/iSQ+PUAwaK2f449k6oV6lzYkhL7NWr63nkDL2JqZrZ29DPwAn7k7BbzBJ2H4nvw==",
    },
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
