"Bazel Rules for kubectl"

# ╔════════════════════════════════════════════════════════════════════════════╗
# ║                                 config_map                                 ║
# ╚════════════════════════════════════════════════════════════════════════════╝

def _config_map_impl(ctx):
    envtest = ctx.toolchains["@io_github_janhicken_rules_kubebuilder//kubebuilder:envtest_toolchain"].envtest
    output_file = ctx.actions.declare_file(ctx.label.name + ".yaml")

    args = ctx.actions.args()
    args.add(output_file)
    args.add_all([ctx.attr.config_map_name, "--dry-run=client", "--output=yaml"])
    args.add(str(ctx.attr.append_hash).lower(), format = "--append-hash=%s")
    args.add_all(ctx.files.srcs, format_each = "--from-file=%s")
    if ctx.attr.namespace:
        args.add(ctx.attr.namespace, format = "--namespace=%s")

    ctx.actions.run_shell(
        outputs = [output_file],
        inputs = ctx.files.srcs,
        tools = [envtest.kubectl],
        command = """out=$1; shift; {kubectl} create configmap "$@" >"$out";""".format(kubectl = envtest.kubectl.path),
        arguments = [args],
        mnemonic = "CreateConfigMap",
    )

    return [DefaultInfo(files = depset([output_file]))]

config_map = rule(
    implementation = _config_map_impl,
    attrs = {
        "append_hash": attr.bool(
            default = False,
            doc = "Append a hash of the configmap to its name.",
        ),
        "config_map_name": attr.string(
            mandatory = True,
            doc = "The config map's name",
        ),
        "namespace": attr.string(
            doc = "The config map's namespace",
        ),
        "srcs": attr.label_list(
            allow_files = True,
            doc = "A list of source files for the config map. The files' basename will be used as key, using its content as value.",
        ),
    },
    toolchains = ["@io_github_janhicken_rules_kubebuilder//kubebuilder:envtest_toolchain"],
    doc = "Creates a ConfigMap manifest based on files.",
)

# ╔════════════════════════════════════════════════════════════════════════════╗
# ║                                   secret                                   ║
# ╚════════════════════════════════════════════════════════════════════════════╝

def _generic_secret_impl(ctx):
    envtest = ctx.toolchains["@io_github_janhicken_rules_kubebuilder//kubebuilder:envtest_toolchain"].envtest
    output_file = ctx.actions.declare_file(ctx.label.name + ".yaml")

    args = ctx.actions.args()
    args.add(output_file)
    args.add_all([ctx.attr.secret_name, "--dry-run=client", "--output=yaml"])
    args.add(str(ctx.attr.append_hash).lower(), format = "--append-hash=%s")
    args.add_all(ctx.files.srcs, format_each = "--from-file=%s")
    if ctx.attr.namespace:
        args.add(ctx.attr.namespace, format = "--namespace=%s")

    ctx.actions.run_shell(
        outputs = [output_file],
        inputs = ctx.files.srcs,
        tools = [envtest.kubectl],
        command = """out=$1; shift; {kubectl} create secret generic "$@" >"$out";""".format(kubectl = envtest.kubectl.path),
        arguments = [args],
        mnemonic = "CreateGenericSecret",
    )

    return [DefaultInfo(files = depset([output_file]))]

generic_secret = rule(
    implementation = _generic_secret_impl,
    attrs = {
        "append_hash": attr.bool(
            default = False,
            doc = "Append a hash of the secret to its name.",
        ),
        "namespace": attr.string(
            doc = "The secret's namespace",
        ),
        "secret_name": attr.string(
            mandatory = True,
            doc = "The secret's name",
        ),
        "srcs": attr.label_list(
            allow_files = True,
            doc = "A list of source files for the secret. The files' basename will be used as key, using its content as value.",
        ),
    },
    toolchains = ["@io_github_janhicken_rules_kubebuilder//kubebuilder:envtest_toolchain"],
    doc = "Creates a secret manifest based on files.",
)

def _tls_secret_impl(ctx):
    envtest = ctx.toolchains["@io_github_janhicken_rules_kubebuilder//kubebuilder:envtest_toolchain"].envtest
    output_file = ctx.actions.declare_file(ctx.label.name + ".yaml")

    args = ctx.actions.args()
    args.add(output_file)
    args.add_all([ctx.attr.secret_name, "--dry-run=client", "--output=yaml"])
    args.add(str(ctx.attr.append_hash).lower(), format = "--append-hash=%s")
    args.add(ctx.file.key, format = "--key=%s")
    args.add(ctx.file.cert, format = "--cert=%s")
    if ctx.attr.namespace:
        args.add(ctx.attr.namespace, format = "--namespace=%s")

    ctx.actions.run_shell(
        outputs = [output_file],
        inputs = [ctx.file.key, ctx.file.cert],
        tools = [envtest.kubectl],
        command = """out=$1; shift; {kubectl} create secret tls "$@" >"$out";""".format(kubectl = envtest.kubectl.path),
        arguments = [args],
        mnemonic = "CreateTLSSecret",
    )

    return [DefaultInfo(files = depset([output_file]))]

tls_secret = rule(
    implementation = _tls_secret_impl,
    attrs = {
        "append_hash": attr.bool(
            default = False,
            doc = "Append a hash of the secret to its name.",
        ),
        "cert": attr.label(
            doc = "Label to PEM-encoded public key certificate",
            mandatory = True,
            allow_single_file = True,
        ),
        "key": attr.label(
            doc = "Label to private key associated with the given certificate",
            mandatory = True,
            allow_single_file = True,
        ),
        "namespace": attr.string(
            doc = "The secret's namespace",
        ),
        "secret_name": attr.string(
            mandatory = True,
            doc = "The secret's name",
        ),
    },
    toolchains = ["@io_github_janhicken_rules_kubebuilder//kubebuilder:envtest_toolchain"],
    doc = """Creates a TLS secret manifest from the given public/private key pair.

The public/private key pair must exist beforehand. The public key certificate must be PEM-encoded and match the given
private key.
""",
)
