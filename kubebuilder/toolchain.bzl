"""This module implements the Kubebuilder toolchain rules.
"""

ControllerGenInfo = provider(
    doc = "Information about how to invoke the controller-gen executable",
    fields = {"bin": "Executable controller-gen binary"},
)

EnvtestInfo = provider(
    doc = "Information about the envtest executables",
    fields = {
        "etcd": "Executable etcd binary",
        "kube_apiserver": "Executable kube-apiserver binary",
        "kubectl": "Executable kubectl binary",
    },
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

def _envtest_toolchain_impl(ctx):
    binaries = [ctx.executable.etcd, ctx.executable.kube_apiserver, ctx.executable.kubectl]

    # Make the $(*_BIN) variables available in places like genrules.
    # See https://docs.bazel.build/versions/main/be/make-variables.html#custom_variables
    template_variables = platform_common.TemplateVariableInfo({
        "ETCD_BIN": ctx.executable.etcd.path,
        "KUBECTL_BIN": ctx.executable.kubectl.path,
        "KUBE_APISERVER_BIN": ctx.executable.kube_apiserver.path,
    })
    default = DefaultInfo(
        files = depset(binaries),
        runfiles = ctx.runfiles(files = binaries),
    )
    envtest_info = EnvtestInfo(
        etcd = ctx.executable.etcd,
        kubectl = ctx.executable.kubectl,
        kube_apiserver = ctx.executable.kube_apiserver,
    )

    # Export all the providers inside our ToolchainInfo
    # so the resolved_toolchain rule can grab and re-export them.
    toolchain_info = platform_common.ToolchainInfo(
        envtest = envtest_info,
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
envtest_toolchain = rule(
    implementation = _envtest_toolchain_impl,
    attrs = {
        "etcd": attr.label(
            doc = "The kube-apiserver binary",
            mandatory = True,
            allow_single_file = True,
            executable = True,
            cfg = "exec",
        ),
        "kube_apiserver": attr.label(
            doc = "The kube-apiserver binary",
            mandatory = True,
            allow_single_file = True,
            executable = True,
            cfg = "exec",
        ),
        "kubectl": attr.label(
            doc = "The kube-apiserver binary",
            mandatory = True,
            allow_single_file = True,
            executable = True,
            cfg = "exec",
        ),
    },
    doc = """Defines an envtest toolchain.

For usage see https://docs.bazel.build/versions/main/toolchains.html#defining-toolchains.
""",
)
