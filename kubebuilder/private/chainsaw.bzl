"Bazel Rules for Chainsaw"

load("@bazel_skylib//lib:shell.bzl", "shell")
load(":kind_env.bzl", "KindEnvironmentInfo")
load(":utils.bzl", "runfiles_path_array_literal", "use_runtime_toolchains")

def _chainsaw_test_impl(ctx):
    chainsaw_toolchain = ctx.toolchains["@io_github_janhicken_rules_kubebuilder//kubebuilder:chainsaw_toolchain"]

    # Configure runfiles
    command_path, tools_runfiles = use_runtime_toolchains(ctx, [chainsaw_toolchain])
    runfiles = ctx.runfiles(ctx.files.srcs).merge_all([
        tools_runfiles,
        ctx.attr.kind_env[DefaultInfo].default_runfiles,
    ])

    # Prepare executable script
    executable = ctx.actions.declare_file(ctx.label.name + ".sh")
    ctx.actions.expand_template(
        template = ctx.file._chainsaw_test_sh,
        output = executable,
        substitutions = {
            "%PATH%": shell.quote(command_path),
            "%kind_env%": shell.quote(ctx.executable.kind_env.short_path),
            "%srcs%": runfiles_path_array_literal(ctx.files.srcs),
        },
        is_executable = True,
    )

    return [DefaultInfo(
        files = depset([executable]),
        executable = executable,
        runfiles = runfiles,
    )]

chainsaw_test = rule(
    implementation = _chainsaw_test_impl,
    doc = """Define a Chainsaw test that runs on a kind cluster.

Please remember to set the tag `supports-graceful-termination` on the target to allow the test runner to export the
kind cluster's logs and shut it down.
    """,
    test = True,
    attrs = {
        "kind_env": attr.label(
            doc = "The kind environment to run the tests in.",
            executable = True,
            mandatory = True,
            providers = [KindEnvironmentInfo],
            cfg = "exec",
        ),
        "srcs": attr.label_list(
            doc = "YAML file(s) that make(s) up the Chainsaw test.",
            mandatory = True,
            allow_files = [".yaml", ".yml"],
        ),
        "_chainsaw_test_sh": attr.label(
            default = Label(":chainsaw_test.sh"),
            allow_single_file = True,
        ),
    },
    toolchains = [
        "@io_github_janhicken_rules_kubebuilder//kubebuilder:chainsaw_toolchain",
    ],
)
