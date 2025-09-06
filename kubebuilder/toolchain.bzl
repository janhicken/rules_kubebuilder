"""This module implements the Kubebuilder toolchain rules.
"""

# ╔════════════════════════════════════════════════════════════════════════════╗
# ║                                  Chainsaw                                  ║
# ╚════════════════════════════════════════════════════════════════════════════╝

ChainsawInfo = provider(
    doc = "Information about the Chainsaw toolchain",
    fields = {"bin": "Executable chainsaw binary"},
)

def _chainsaw_toolchain_impl(ctx):
    default = DefaultInfo(
        files = ctx.attr.bin[DefaultInfo].files,
        runfiles = ctx.runfiles(files = [ctx.file.bin]),
    )

    toolchain_info = platform_common.ToolchainInfo(
        default = default,
        chainsaw = ChainsawInfo(
            bin = ctx.executable.bin,
        ),
    )

    return [default, toolchain_info]

chainsaw_toolchain = rule(
    implementation = _chainsaw_toolchain_impl,
    attrs = {
        "bin": attr.label(
            doc = "Executable Chainsaw binary",
            executable = True,
            allow_single_file = True,
            mandatory = True,
            cfg = "exec",
        ),
    },
    doc = "Defines a Chainsaw toolchain.",
    provides = [DefaultInfo, platform_common.ToolchainInfo],
)

# ╔════════════════════════════════════════════════════════════════════════════╗
# ║                               controller-gen                               ║
# ╚════════════════════════════════════════════════════════════════════════════╝

ControllerGenInfo = provider(
    doc = "Information about the controller-gen toolchain",
    fields = {"bin": "Executable controller-gen binary"},
)

def _controller_gen_toolchain_impl(ctx):
    default = DefaultInfo(
        files = ctx.attr.bin[DefaultInfo].files,
        runfiles = ctx.attr.bin[DefaultInfo].default_runfiles,
    )

    # Make the $(CONTROLLER_GEN_BIN) variable available in places like genrules.
    # See https://docs.bazel.build/versions/main/be/make-variables.html#custom_variables
    template_variables = platform_common.TemplateVariableInfo({
        "CONTROLLER_GEN_BIN": ctx.file.bin.path,
    })

    # Export all the providers inside our ToolchainInfo
    # so the resolved_toolchain rule can grab and re-export them.
    toolchain_info = platform_common.ToolchainInfo(
        default = default,
        template_variables = template_variables,
        controller_gen = ControllerGenInfo(
            bin = ctx.file.bin,
        ),
    )

    return [default, template_variables, toolchain_info]

controller_gen_toolchain = rule(
    implementation = _controller_gen_toolchain_impl,
    attrs = {
        "bin": attr.label(
            doc = "Executable controller-gen binary",
            executable = True,
            allow_single_file = True,
            mandatory = True,
            cfg = "exec",
        ),
    },
    doc = "Defines a controller-gen toolchain.",
    provides = [DefaultInfo, platform_common.ToolchainInfo, platform_common.TemplateVariableInfo],
)

# ╔════════════════════════════════════════════════════════════════════════════╗
# ║                                   Docker                                   ║
# ╚════════════════════════════════════════════════════════════════════════════╝

DockerInfo = provider(
    doc = "Information about the Docker toolchain",
    fields = {"docker": "Executable Docker CLI binary"},
)

def _docker_toolchain_impl(ctx):
    default = DefaultInfo(
        files = ctx.attr.docker[DefaultInfo].files,
        runfiles = ctx.runfiles(files = [ctx.file.docker]),
    )

    # Make the $(DOCKER_CLI_BIN) variable available in places like genrules.
    # See https://docs.bazel.build/versions/main/be/make-variables.html#custom_variables
    template_variables = platform_common.TemplateVariableInfo({
        "DOCKER_CLI_BIN": ctx.file.docker.path,
    })

    # Export all the providers inside our ToolchainInfo
    # so the resolved_toolchain rule can grab and re-export them.
    toolchain_info = platform_common.ToolchainInfo(
        default = default,
        template_variables = template_variables,
        docker = DockerInfo(
            docker = ctx.file.docker,
        ),
    )

    return [default, template_variables, toolchain_info]

docker_toolchain = rule(
    implementation = _docker_toolchain_impl,
    attrs = {
        "docker": attr.label(
            doc = "Executable Docker CLI binary",
            executable = True,
            allow_single_file = True,
            mandatory = True,
            cfg = "exec",
        ),
    },
    doc = "Defines a Docker toolchain.",
    provides = [DefaultInfo, platform_common.ToolchainInfo, platform_common.TemplateVariableInfo],
)

# ╔════════════════════════════════════════════════════════════════════════════╗
# ║                                  envtest                                   ║
# ╚════════════════════════════════════════════════════════════════════════════╝

EnvtestInfo = provider(
    doc = "Information about the envtest toolchain",
    fields = {
        "etcd": "Executable etcd binary",
        "kube_apiserver": "Executable kube-apiserver binary",
        "kubectl": "Executable kubectl binary",
    },
)

def _envtest_toolchain_impl(ctx):
    default = DefaultInfo(
        files = depset(transitive = [
            ctx.attr.etcd[DefaultInfo].files,
            ctx.attr.kube_apiserver[DefaultInfo].files,
            ctx.attr.kubectl[DefaultInfo].files,
        ]),
        runfiles = ctx.runfiles().merge_all([
            ctx.attr.etcd[DefaultInfo].default_runfiles,
            ctx.attr.kube_apiserver[DefaultInfo].default_runfiles,
            ctx.attr.kubectl[DefaultInfo].default_runfiles,
        ]),
    )

    # Make the $(*_BIN) variables available in places like genrules.
    # See https://docs.bazel.build/versions/main/be/make-variables.html#custom_variables
    template_variables = platform_common.TemplateVariableInfo({
        "ETCD_BIN": ctx.executable.etcd.path,
        "KUBECTL_BIN": ctx.executable.kubectl.path,
        "KUBE_APISERVER_BIN": ctx.executable.kube_apiserver.path,
    })

    # Export all the providers inside our ToolchainInfo
    # so the resolved_toolchain rule can grab and re-export them.
    toolchain_info = platform_common.ToolchainInfo(
        default = default,
        template_variables = template_variables,
        envtest = EnvtestInfo(
            etcd = ctx.executable.etcd,
            kubectl = ctx.executable.kubectl,
            kube_apiserver = ctx.executable.kube_apiserver,
        ),
    )

    return [default, template_variables, toolchain_info]

envtest_toolchain = rule(
    implementation = _envtest_toolchain_impl,
    attrs = {
        "etcd": attr.label(
            doc = "The kube-apiserver binary",
            executable = True,
            allow_single_file = True,
            mandatory = True,
            cfg = "exec",
        ),
        "kube_apiserver": attr.label(
            doc = "The kube-apiserver binary",
            executable = True,
            allow_single_file = True,
            mandatory = True,
            cfg = "exec",
        ),
        "kubectl": attr.label(
            doc = "The kube-apiserver binary",
            executable = True,
            allow_single_file = True,
            mandatory = True,
            cfg = "exec",
        ),
    },
    doc = "Defines an envtest toolchain.",
    provides = [DefaultInfo, platform_common.ToolchainInfo, platform_common.TemplateVariableInfo],
)

# ╔════════════════════════════════════════════════════════════════════════════╗
# ║                                    kind                                    ║
# ╚════════════════════════════════════════════════════════════════════════════╝

KindInfo = provider(
    doc = "Information about the kind toolchain",
    fields = {
        "bin": "Executable kind binary",
        "node_image": "Node Docker image name to use",
    },
)

def _kind_toolchain_impl(ctx):
    default = DefaultInfo(
        files = ctx.attr.bin[DefaultInfo].files,
        runfiles = ctx.runfiles(files = [ctx.file.bin]),
    )

    toolchain_info = platform_common.ToolchainInfo(
        default = default,
        kind = KindInfo(
            bin = ctx.executable.bin,
            node_image = ctx.attr.node_image,
        ),
    )

    return [default, toolchain_info]

kind_toolchain = rule(
    implementation = _kind_toolchain_impl,
    attrs = {
        "bin": attr.label(
            doc = "Executable kind binary",
            executable = True,
            allow_single_file = True,
            mandatory = True,
            cfg = "exec",
        ),
        "node_image": attr.string(
            doc = "Node Docker image name to use",
            mandatory = True,
        ),
    },
    doc = "Defines a kind toolchain.",
    provides = [DefaultInfo, platform_common.ToolchainInfo],
)

# ╔════════════════════════════════════════════════════════════════════════════╗
# ║                                   kuttl                                    ║
# ╚════════════════════════════════════════════════════════════════════════════╝

KuttlInfo = provider(
    doc = "Information about the kuttl toolchain",
    fields = {"bin": "Executable kuttl binary"},
)

def _kuttl_toolchain_impl(ctx):
    default = DefaultInfo(
        files = ctx.attr.bin[DefaultInfo].files,
        runfiles = ctx.runfiles(files = [ctx.file.bin]),
    )

    toolchain_info = platform_common.ToolchainInfo(
        default = default,
        kuttl = KuttlInfo(
            bin = ctx.executable.bin,
        ),
    )

    return [default, toolchain_info]

kuttl_toolchain = rule(
    implementation = _kuttl_toolchain_impl,
    attrs = {
        "bin": attr.label(
            doc = "Executable kuttl binary",
            mandatory = True,
            allow_single_file = True,
            executable = True,
            cfg = "exec",
        ),
    },
    doc = "Defines a kuttl toolchain.",
    provides = [DefaultInfo, platform_common.ToolchainInfo],
)
