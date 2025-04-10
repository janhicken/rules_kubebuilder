"""This module implements the Kubebuilder toolchain rules.
"""

ControllerGenInfo = provider(
    doc = "Information about how to invoke the controller-gen executable",
    fields = {"bin": "Executable controller-gen binary"},
)

def _controller_gen_toolchain_impl(ctx):
    binary = ctx.file.bin

    # Make the $(CONTROLLER_GEN_BIN) variable available in places like genrules.
    # See https://docs.bazel.build/versions/main/be/make-variables.html#custom_variables
    template_variables = platform_common.TemplateVariableInfo({
        "CONTROLLER_GEN_BIN": binary.path,
    })
    default = DefaultInfo(
        files = depset([binary]),
        runfiles = ctx.runfiles(files = [binary]),
    )
    controller_gen_info = ControllerGenInfo(
        bin = binary,
    )

    # Export all the providers inside our ToolchainInfo
    # so the resolved_toolchain rule can grab and re-export them.
    toolchain_info = platform_common.ToolchainInfo(
        controller_gen = controller_gen_info,
        template_variables = template_variables,
        default = default,
    )
    return [
        default,
        toolchain_info,
        template_variables,
    ]

controller_gen_toolchain = rule(
    implementation = _controller_gen_toolchain_impl,
    attrs = {
        "bin": attr.label(
            doc = "A hermetically downloaded executable target for the target platform.",
            mandatory = True,
            allow_single_file = True,
        ),
    },
    doc = """Defines a controller-gen toolchain.

For usage see https://docs.bazel.build/versions/main/toolchains.html#defining-toolchains.
""",
)
