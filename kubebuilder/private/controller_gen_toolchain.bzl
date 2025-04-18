"Setup controller-gen repositories and rules"

load("@aspect_bazel_lib//lib:repo_utils.bzl", "repo_utils")

# Platform names follow the platform naming convention in @aspect_bazel_lib//lib:repo_utils.bzl
CONTROLLER_GEN_PLATFORMS = {
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

DEFAULT_CONTROLLER_GEN_VERSION = "0.17.3"

CONTROLLER_GEN_VERSIONS = {
    "0.16.0": {
        "darwin_amd64": "sha384-1GolNKX0qjngLeqdLBaODbpZv4GsBI0qeP8rXVI860CPEF3caDPkkbC79UrgnI2w",
        "darwin_arm64": "sha384-5NbaQi9u1hku0rHvPEP+NgTmSUx1Trn6ENjFMxauU73g516+Jqyib7ePT0lJk3+0",
        "linux_amd64": "sha384-TDpGGbimakbVttTRUxgNBs8H2ffrKIFnNCLtNT6pTSM/G4YmzS2j5uGgpUQhcDvo",
        "linux_arm64": "sha384-bvj3k76SgccJpLoi5uEJuhZRowAHEQC5TeM4WQKGSPBFIogQjoWIrtYtfB1ji68Z",
        "linux_ppc64le": "sha384-lhYH9nX9mxU3qYlcpkXY18QtiBYlZhUcnPkPHrxm6xOf2LOdoTMhAXmmtH0lm0NY",
        "linux_s390x": "sha384-BzDrP1TKhRrO4ATsr1q+5Ke71rGzMZsAID/hFrFqck5uDUasClkbMhClfdc8a/OW",
        "windows_amd64": "sha384-ZhGY74P3AKFDUuCCEB0w/xh/wrTO9fDMpTY6NqjWuVXqX0JKvY7O6g/77opzjQBm",
    },
    "0.16.1": {
        "darwin_amd64": "sha384-YDY52HhY9MNmFdpKHCPbD9MCCPqBSCCaW3M7VyaSiAFlximroKtqQLnLeRfuZoxr",
        "darwin_arm64": "sha384-sGxfSJVNzRoUtzI0OppeQ6sjS/E6RCtArPWBz3d3dEVdOt7+mPYbENbtpI2k+UnW",
        "linux_amd64": "sha384-GS3twpNXAoo1ntt+KLs8+7DrtV2cUM9oIevPQ081Werj1HYtf6hqtHDC8A4kDUsY",
        "linux_arm64": "sha384-1H/KBWyrHGjrs4jQok6Lo1nTWw6a32S5ywIDk3mwMFxcMxbquK8+JGJ1b8uEbzuC",
        "linux_ppc64le": "sha384-glnDElGpVoFMCcDyVf+JzDB/YB6r7tHCT6z7zuwBUykOWtCFItsgpf7/HLXF6b++",
        "linux_s390x": "sha384-pqNTYT1VW2III3x263yIb5hJ4RNbOnGXIYuZtiw1NuMz/5c20eHfWJPqE8QvvKgl",
        "windows_amd64": "sha384-lA60lndcgzeTFWsR0ic/tSoQhACfBuppJUs2e+jw40OjdtcP7Mgjl0VZ0VvWlIf7",
    },
    "0.16.2": {
        "darwin_amd64": "sha384-er+f8EpZ+pvRvmfOwif+uxyoyS6kaohxufclvUmgI4w4LuIIbluMAENgOTErPx/K",
        "darwin_arm64": "sha384-UIUcsW6BHZn6SihBeGuVhtH2UcoZZo1YXrM/FNgPfen45vORW8QcwXGh5mhmUvgs",
        "linux_amd64": "sha384-LUBDM5k+UB3bNg4nzEA4M7QW09pywWlJVOV3k+rE4b840wDHp38njLn/jEGE/7Qr",
        "linux_arm64": "sha384-dePqpwGEKYXlS5fG5n1DiURCbNw8W6ayBy+gCvR/eIaMFgSufOGkq8l0T6cXFvgQ",
        "linux_ppc64le": "sha384-i66PAT+ekzCvzxGtgkUvK81D2nF75cyeM/MnmRl0pZ2wXz9A4e0l9lEpPq8cbB0k",
        "linux_s390x": "sha384-DE54dXDviaxJKdmiczbfXUAQeJsAgX45H4L07z4yh+aiAEGYu35zQc5MRfrCafUL",
        "windows_amd64": "sha384-UxSO2p2R7b60n9ZOKVHP+3umNXQPWyDp7iH5CU50XCXApohZZjiPa0zIMERGMld/",
    },
    "0.16.3": {
        "darwin_amd64": "sha384-6j1c6darVyqiGtuHH/2IcORJJfEcP8368tkoJgZMbD+fFlQkIo00odcTj0jt/kOw",
        "darwin_arm64": "sha384-4CpO+dUBuxvlXbOZV+Ide/SqLTBzNfx0DANlBCKASvNeJRJku0HAQGv2d2Dtb/2p",
        "linux_amd64": "sha384-IJi0NsNaFLdjen5+7MWA3MWMFInoOgwAHip3gOe+bCl0Wh5kxDFjFjeoE3Gke75/",
        "linux_arm64": "sha384-Ts+f8CWbPSU7ODMOJCqHDnkl+OzZcq1P38wxDqdS8seHn0Z4Lo7Xvl2aa62V6a8x",
        "linux_ppc64le": "sha384-d1Q32ryw8aUS9jVljNr30btCvoxQgiARS5+iUla2RktsA/xHJBiJN5whdFwfJ9Kn",
        "linux_s390x": "sha384-ZMmNNRq74fNIvfJR4zpPGC5sl4FhXArrgQ+IHlWNeTXMroA0c2AjdwaUeLfcMgkP",
        "windows_amd64": "sha384-YrfIRriB2+Z8FZ/wGq8Ym+Gnjcq7Bz9rhP7cchsu44Pzvpr2iTulb6qqtOB0Y6Jl",
    },
    "0.16.4": {
        "darwin_amd64": "sha384-x6lLNgN7KL9zTw0meQCMbzpAWk3Jiubgcgf1yCkBWzu+BXt1kGB/adsCH4rnMe2v",
        "darwin_arm64": "sha384-O0bj+51vcQXlhXHuzJ8RXcMps34P6y9Ci42nFlBlIS18A1CyLRqN9x0HejlK4p+k",
        "linux_amd64": "sha384-AMi4b+NqyLLBSZvUHR0PiIRXVNcQ9hzzVVw0ebYZanwM0D6uSHGPBLZAoOaJAb9D",
        "linux_arm64": "sha384-72GbRXgMEL36ltNEwZ/8WJOfZKYx5RGPo8nEHzNXRc1dHIKJpmcbPNtS2G4EdQha",
        "linux_ppc64le": "sha384-ATIqFxtX6WQf5fWqL+vXBRRdQmRlVGGKtLDZNJLvjfrAV8NS+YknxOWL/z0CbwfG",
        "linux_s390x": "sha384-pjlPya4LCmvfoyZw378tWXfE95IrJ08ZUaxOuMsXPjCo7WnHhpryZmp/KJnCP9v0",
        "windows_amd64": "sha384-+SL+gvVDWTSsCz7PpboZWYWwnsbHq6FB2tXudxcsUVZh6qdI76RonFhk/DP/5qY3",
    },
    "0.16.5": {
        "darwin_amd64": "sha384-/9X/O3XMXLbYB1FO1XYT6UT+GfFLay9OO4dU1ZYRbc1OobBa3tflRSPGQUsnk+/y",
        "darwin_arm64": "sha384-q+yrD976MQwr57/0qvYqwtfiTyhfepfqE5fDCXZrYDdlZ1RuGhpWdmQFCTRpO0CH",
        "linux_amd64": "sha384-xV/oIYLKRSvR5BTj/zkigEix03tBKrECPw/PQzt5DkSBFgh0eK7N39zzBfUpAfbH",
        "linux_arm64": "sha384-Lrai+xyneYBGhruVb6m4frVKwReO5Ec1D/3BDF0x/4ntH8zIeMCmEvwa0aNXDX2c",
        "linux_ppc64le": "sha384-7iCXJZ4Szf0kQ3tn3CFPgld+r0wEtlQrbZIu3iBwl+jQbCLmZgdKMdo4+20uZ6CQ",
        "linux_s390x": "sha384-dm/3xzU1H9g2JwAak6ryOygclbyYfSGvCgHWUksNwjIqK7eXBRivAus4mKrogIWU",
        "windows_amd64": "sha384-sPlvok0ML9brrVXu6jLMy4hjBkNphmFN8zqOYJM8zCrnQ/zQCW/41Qn++0m5AMCs",
    },
    "0.17.0": {
        "darwin_amd64": "sha384-7MqW8VMm/BTuPpTD5tZQhMf0FhqPln86k7eGGA4D8gHli78rYA3TMugLioOj3iOP",
        "darwin_arm64": "sha384-5KvFlhvTW9DFjfjuYAboc8ZbCSEpza442N/72Id5rxttqADvB2zMmHGHUmWdfngF",
        "linux_amd64": "sha384-z4AEzgJggyUgp5JxEC5Q5cX7lWxCQcTkkOJ5krGv9f6agqcgRk9jz24t1B222ekk",
        "linux_arm64": "sha384-8ecAC3RVfRLyyXsrOurvcjgHVl7Z3qIgBjAHn8ycwz/eiy5As3g+/RG71TSkt03H",
        "linux_ppc64le": "sha384-uAh53LAKwCw2n21S+mXyEOZEJAGBDElbWVvf4l8LuYZmJ3NsGTE0e93lW7Mylzhg",
        "linux_s390x": "sha384-YT1m8Tr8CL1BLSqAtIeA8P3qrsqfttcDbnUTDU6/sRZHt/+8f68+/2dW9wH7vwpj",
        "windows_amd64": "sha384-hOfD4sHKXKzEaKR3V6cAcNpHeN9qCp3JVZKbkqGgWHAwSmuIwzDgRKvflCWNduIi",
    },
    "0.17.1": {
        "darwin_amd64": "sha384-K4cZ4dDhde3sPdALm6ge6NSDtd/73OHz2GnTpkJ5kwntgN2lJrW7qSTBE5wwrUBF",
        "darwin_arm64": "sha384-SlVD1PV4ezAUxvFschcvJpLuXgTrD3tCxv4rlsVPdq8rUe0oD0zoCreHAp9L6V9A",
        "linux_amd64": "sha384-y9faaFFYGRxjwxqs9sXoloevE8r3DGNDD6axIOq7b0PXoycYfTdaxGUEi+XJ4W+3",
        "linux_arm64": "sha384-1MDuYTK/481+o5/eyn9BF/Bf/UHIqwSUq6VA2HRU1gGKaUo5PDYUAaLuCYvggJjR",
        "linux_ppc64le": "sha384-0EBSVCMk/9g4I0BJMVUYYYdkWn6YdwPnMvcwPdRbcWRFcmLWhSCDdNq7MvuHVTHN",
        "linux_s390x": "sha384-vvbzVx7NclsEdwsjUYq7EUIuefmJCTeevFyUAhLoHfyJ5BZ1cEdghjouof08gcyW",
        "windows_amd64": "sha384-zQVvmtKDZ24cLryxABMrcAtdZGqbt2vpm/AzsAGOUUzh/MJoEQoVtnoXEpHkGluI",
    },
    "0.17.2": {
        "darwin_amd64": "sha384-8ZIH983FEpJBnasG4C6j9NSdCHOTRsVT2Y/5tDwoIIYrD3tIm2iPw9Wovr4vV1v2",
        "darwin_arm64": "sha384-pSX6hbJLkGxFVIqYYkyKvr543MWIh9ZII0o1wqW5xZE/ZGXfzsRR0sTb+QdoWivw",
        "linux_amd64": "sha384-3AzbJs3A85PGPP3uhQHEneza7w3hW+x3w2RyFVBkesBe41MrKbehoR2zHG93EUim",
        "linux_arm64": "sha384-j+hLD1ixY+cqsGTSytoocOoH3VtUUUztglGcONiRxst4Yr8L/bzgAMdI9bIu60qw",
        "linux_ppc64le": "sha384-W9Tesu0f+xIKhTtZbMhJMwwKLzAhRB9Fey31Ig12TdIaua8lXaJ0bWDbLPAJCgO2",
        "linux_s390x": "sha384-20oylTV6LvD3lE1WrtNlEw7upCylVU76GF6LcpsE8UubHE2wCQ7DnE4hh6oWDdpO",
        "windows_amd64": "sha384-0xlCi+r7yMGUHr6h58BxZAQDtbhzM5SW2ZRAiBOqrfiLJxixnvU1vbgL9K8Ez5+u",
    },
    "0.17.3": {
        "darwin_amd64": "sha384-pOrIi2qQw4zB6kYHjgcUExzxil8ao5JOrbrcNRClcEKDq/GsCz4IlPLmeCQT43yy",
        "darwin_arm64": "sha384-P5QaN4bmBnzjHZQliVfP3Gs3e5UwOP8gYCZDne5DvOCnOuiBWtxCM84/8DdLhBVy",
        "linux_amd64": "sha384-0JuGGoQAqE1xTB0y1A15dRs96ALUyC/vUbnG8QyYt2i9JoNo4I0ez4VWvns23VCG",
        "linux_arm64": "sha384-4GK3AjqlyEq0OJdE+n0jqvShjFL4pKGmerjqVHfzg8crWX+Z7In01vF60u0/gbGo",
        "linux_ppc64le": "sha384-uuPHUoAC1m63DvkaMfgGT+DBy+jvWeP7lWqAepE18UmZo7jqI8VNQekkrBjlbcja",
        "linux_s390x": "sha384-gAaq3mNGy3sAAOUkqCqqkMTiKlEy0d1+pqf+1bJOFnBy/0JwTsCNOkz7JnaPP0Fr",
        "windows_amd64": "sha384-QbtaGOdRbZ3xDsPGWCijUliLzOU7Z1aYfUfC+UqJWmgy+iXxqEEvw9r7EZB1eLQK",
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
        rctx.attr.platform.replace("_", "-"),
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

def _controller_gen_host_alias_repo(rctx):
    ext = ".exe" if repo_utils.is_windows(rctx) else ""

    # Base BUILD file for this repository
    rctx.file("BUILD", """# @generated by @io_github_janhicken_rules_kubebuilder//kubebuilder/private:controller_gen_toolchain.bzl
package(default_visibility = ["//visibility:public"])
exports_files(["controller-gen{ext}"])
""".format(
        ext = ext,
    ))

    rctx.symlink("../{name}_{platform}/controller-gen{ext}".format(
        name = rctx.attr.name,
        platform = repo_utils.platform(rctx),
        ext = ext,
    ), "controller-gen{ext}".format(ext = ext))

controller_gen_host_alias_repo = repository_rule(
    _controller_gen_host_alias_repo,
    doc = """Creates a repository with a shorter name meant for the host platform, which contains
    a BUILD file that exports symlinks to the host platform's binaries
    """,
)
