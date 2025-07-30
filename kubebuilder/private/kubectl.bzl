"Bazel Rules for kubectl"

load("@aspect_bazel_lib//lib:paths.bzl", "relative_file")
load("@aspect_bazel_lib//lib:stamping.bzl", "STAMP_ATTRS", "maybe_stamp")
load("@bazel_skylib//lib:shell.bzl", "shell")
load(":utils.bzl", "use_runtime_toolchains")

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

# ╔════════════════════════════════════════════════════════════════════════════╗
# ║                               kustomization                                ║
# ╚════════════════════════════════════════════════════════════════════════════╝

KustomizeInfo = provider(
    "Info about kustomize configuration",
    fields = {
        "configurations": "depset of transformer configuration files.",
    },
)

def _kustomization_impl(ctx):
    coreutils_toolchain = ctx.toolchains["@aspect_bazel_lib//lib:coreutils_toolchain_type"]
    envtest_toolchain = ctx.toolchains["@io_github_janhicken_rules_kubebuilder//kubebuilder:envtest_toolchain"]
    yq_toolchain = ctx.toolchains["@aspect_bazel_lib//lib:yq_toolchain_type"]

    # Build depset of all transformer configurations
    transitive_configuration_deps = [
        resource[KustomizeInfo].configurations
        for resource in ctx.attr.resources
        if KustomizeInfo in resource
    ]
    configuration_deps = depset(
        ctx.files.configurations,
        transitive = transitive_configuration_deps,
    )

    # Create kustomization.yaml
    kustomization_yaml = ctx.actions.declare_file(ctx.label.name + "/kustomization.yaml")
    kustomization_spec = {
        "apiVersion": "kustomize.config.k8s.io/v1beta1",
        "commonAnnotations": ctx.attr.annotations,
        "configurations": [
            relative_file(configuration.path, kustomization_yaml.path)
            for configuration in configuration_deps.to_list()
        ],
        "images": [
            {"name": name, "newTag": new_tag}
            for name, new_tag in ctx.attr.image_tags.items()
        ],
        "kind": "Kustomization",
        "labels": [{"pairs": ctx.attr.labels}],
        "namePrefix": ctx.attr.name_prefix or None,
        "nameSuffix": ctx.attr.name_suffix or None,
        "namespace": ctx.attr.namespace or None,
        "patches": [
            {
                "path": relative_file(patch.path, kustomization_yaml.path),
                "target": json.decode(target_json),
            }
            for patch_target, target_json in ctx.attr.patches.items()
            for patch in patch_target.files.to_list()
        ],
        "replacements": [
            {"path": relative_file(replacement.path, kustomization_yaml.path)}
            for replacement in ctx.files.replacements
        ],
        "resources": [
            relative_file(resource.path, kustomization_yaml.path)
            for resource in ctx.files.resources
        ],
    }

    # Write raw version first
    raw_kustomization_yaml = ctx.actions.declare_file(ctx.label.name + "/raw.yaml")
    ctx.actions.write(
        output = raw_kustomization_yaml,
        content = json.encode(kustomization_spec),
    )

    # Expand stamp attributes
    expand_stamp_attrs_inputs = [raw_kustomization_yaml]
    expand_stamp_attrs_args = [raw_kustomization_yaml.path, kustomization_yaml.path]
    stamp = maybe_stamp(ctx)
    if stamp:
        expand_stamp_attrs_inputs += [stamp.stable_status_file, stamp.volatile_status_file]
        expand_stamp_attrs_args += [stamp.stable_status_file.path, stamp.volatile_status_file.path]
    ctx.actions.run(
        outputs = [kustomization_yaml],
        inputs = expand_stamp_attrs_inputs,
        executable = ctx.executable._expand_stamp_attrs,
        tools = [yq_toolchain.yqinfo.bin],
        arguments = expand_stamp_attrs_args,
        mnemonic = "ExpandStampAttrs",
        env = yq_toolchain.template_variables.variables,
        toolchain = "@aspect_bazel_lib//lib:yq_toolchain_type",
    )

    # Run kubectl kustomize
    output_file = ctx.actions.declare_file(ctx.label.name + ".yaml")
    args = ctx.actions.args()
    args.add("kustomize")
    args.add(kustomization_yaml.dirname)

    # Disallow network access to make it hermetic
    args.add("false", format = "--network=%s")

    # Enable resource loading from everywhere, we control the filesystem through the Bazel sandbox anyway
    args.add("LoadRestrictionsNone", format = "--load-restrictor=%s")

    args.add(output_file, format = "--output=%s")
    ctx.actions.run(
        outputs = [output_file],
        inputs = depset(
            direct = [kustomization_yaml] + ctx.files.resources + ctx.files.configurations + ctx.files.replacements,
            transitive = [patch_target.files for patch_target in ctx.attr.patches.keys()] + transitive_configuration_deps,
        ),
        executable = envtest_toolchain.envtest.kubectl,
        arguments = [args],
        mnemonic = "KustomizeBuild",
        toolchain = "@io_github_janhicken_rules_kubebuilder//kubebuilder:envtest_toolchain",
    )

    # Create runnable apply script
    apply_script = ctx.actions.declare_file(ctx.label.name + "_apply.sh")
    command_path, tools_runfiles = use_runtime_toolchains(ctx, [
        coreutils_toolchain,
        envtest_toolchain,
        yq_toolchain,
    ])
    ctx.actions.expand_template(
        template = ctx.file._apply,
        output = apply_script,
        substitutions = {
            "%PATH%": shell.quote(command_path),
            "%manifests_file%": shell.quote(output_file.short_path),
        },
        is_executable = True,
    )
    runfiles = ctx.runfiles(files = [output_file]).merge(tools_runfiles)

    return [
        DefaultInfo(
            files = depset([output_file]),
            executable = apply_script,
            runfiles = runfiles,
        ),
        KustomizeInfo(configurations = configuration_deps),
    ]

kustomization = rule(
    implementation = _kustomization_impl,
    executable = True,
    attrs = {
        "annotations": attr.string_dict(
            doc = "Add annotations to add all resources.",
        ),
        "configurations": attr.label_list(
            allow_files = [".yml", ".yaml"],
            doc = "A list of transformer configuration files.",
        ),
        "image_tags": attr.string_dict(
            doc = "Modify the tags and/or digest for certain images.",
        ),
        "labels": attr.string_dict(
            doc = "Add labels and optionally selectors to all resources.",
        ),
        "name_prefix": attr.string(
            doc = "Prepends the value to the names of all resources and references. As namePrefix is self explanatory, it helps adding prefix to names in the defined yaml files.",
        ),
        "name_suffix": attr.string(
            doc = "Appends the value to the names of all resources and references. As nameSuffix is self explanatory, it helps adding suffix to names in the defined yaml files.",
        ),
        "namespace": attr.string(
            doc = "Adds namespace to all resources. Will override the existing namespace if it is set on a resource, or add it if it is not set on a resource.",
        ),
        "patches": attr.label_keyed_string_dict(
            allow_files = [".yml", ".yaml", ".json"],
            doc = "Patches to be applied to resources. Expects a dictionary of patches to target specs. Keys must be a label to (a) patch file(s), values shall be a JSON string of a target spec.",
        ),
        "replacements": attr.label_list(
            allow_files = [".yml", ".yaml"],
            doc = "Substitute field(s) in N target(s) with a field from a source. Replacements are used to copy fields from one source into any number of specified targets.",
        ),
        "resources": attr.label_list(
            mandatory = True,
            allow_files = [".yml", ".yaml"],
            doc = "Resources to include. Each entry in this list must be a path to a YAML file.",
        ),
        "_apply": attr.label(
            default = Label(":apply.sh"),
            allow_single_file = True,
        ),
        "_expand_stamp_attrs": attr.label(
            default = Label(":expand_stamp_attrs"),
            executable = True,
            cfg = "exec",
        ),
    } | STAMP_ATTRS,
    toolchains = [
        "@aspect_bazel_lib//lib:coreutils_toolchain_type",
        "@aspect_bazel_lib//lib:yq_toolchain_type",
        "@io_github_janhicken_rules_kubebuilder//kubebuilder:envtest_toolchain",
    ],
    doc = """Build a set of KRM resources similar to a kustomization.yaml.

All attributes support interpolation of stamp variables, if stamping is enabled.
The stamp variable needs to be referenced using the syntax like `${STABLE_VAR_NAME}` or `${BUILD_TIMESTAMP}`.
""",
    provides = [DefaultInfo, KustomizeInfo],
)
