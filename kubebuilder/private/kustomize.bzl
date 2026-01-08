"Bazel Rules for kustomize"

load("@bazel_lib//lib:paths.bzl", "relative_file")
load("@bazel_lib//lib:stamping.bzl", "STAMP_ATTRS", "maybe_stamp")
load("@bazel_skylib//lib:shell.bzl", "shell")
load(":utils.bzl", "use_runtime_toolchains")

KustomizeInfo = provider(
    "Info about kustomize configuration",
    fields = {
        "configurations": "depset of transformer configuration files.",
    },
)

def _kustomization_impl(ctx):
    coreutils_toolchain = ctx.toolchains["@bazel_lib//lib:coreutils_toolchain_type"]
    envtest_toolchain = ctx.toolchains["@io_github_janhicken_rules_kubebuilder//kubebuilder:envtest_toolchain"]
    jq_toolchain = ctx.toolchains["@jq.bzl//jq/toolchain:type"]
    sh_toolchain = ctx.toolchains["@rules_shell//shell:toolchain_type"]
    yq_toolchain = ctx.toolchains["@yq.bzl//yq/toolchain:type"]

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
        "configMapGenerator": [
            {
                "files": [
                    relative_file(file.path, kustomization_yaml.path)
                    for file in files_target.files.to_list()
                ],
                "name": name,
            }
            for name, files_target in ctx.attr.config_maps.items()
        ],
        "configurations": [
            relative_file(configuration.path, kustomization_yaml.path)
            for configuration in configuration_deps.to_list()
        ],
        "images": [
            {
                "name": name,
                "newName": ctx.attr.image_names.get(name),
                "newTag": ctx.attr.image_tags.get(name),
            }
            for name in (ctx.attr.image_names | ctx.attr.image_tags).keys()
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

    # Configure kustomization
    configure_direct_inputs = [raw_kustomization_yaml]
    configure_transitive_inputs = []
    configure_args = ctx.actions.args()
    configure_args.add("-o", kustomization_yaml.path)

    for image_ref, image_digest_target in ctx.attr.image_digests.items():
        configure_args.add_all("-i", image_digest_target.files, format_each = image_ref + "=%s")
        configure_transitive_inputs.append(image_digest_target.files)

    stamp = maybe_stamp(ctx)
    if stamp:
        configure_direct_inputs += [stamp.stable_status_file, stamp.volatile_status_file]
        configure_args.add("-s", stamp.stable_status_file)
        configure_args.add("-s", stamp.volatile_status_file)
    configure_args.add(raw_kustomization_yaml)

    ctx.actions.run(
        outputs = [kustomization_yaml],
        inputs = depset(configure_direct_inputs, transitive = configure_transitive_inputs),
        executable = ctx.executable._configure_kustomization,
        tools = [jq_toolchain.jqinfo.bin, yq_toolchain.yqinfo.bin],
        arguments = [configure_args],
        mnemonic = "ConfigureKustomization",
        env = jq_toolchain.template_variables.variables | yq_toolchain.template_variables.variables,
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
            transitive = transitive_configuration_deps +
                         [patch_target.files for patch_target in ctx.attr.patches.keys()] +
                         [config_map_files_target.files for config_map_files_target in ctx.attr.config_maps.values()],
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
            "#!/usr/bin/env bash": "#!" + sh_toolchain.path,
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
        "config_maps": attr.string_keyed_label_dict(
            allow_files = True,
            doc = "Create ConfigMaps from files. The key will be the config map's name, the value is a set of files from which the data shall be sourced.",
        ),
        "configurations": attr.label_list(
            allow_files = [".yml", ".yaml"],
            doc = "A list of transformer configuration files.",
        ),
        "image_digests": attr.string_keyed_label_dict(
            allow_files = [".json.sha256"],
            doc = """Inject digest references for images (key) based on the OCI image digests (value).
Values must be labels to a `.digest` target created by _rules_oci_'s `oci_image` or `oci_image_index` macros.""",
        ),
        "image_names": attr.string_dict(
            doc = "Modify the names for certain images.",
        ),
        "image_tags": attr.string_dict(
            doc = "Modify the tags for certain images.",
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
        "_configure_kustomization": attr.label(
            default = Label(":configure_kustomization"),
            executable = True,
            cfg = "exec",
        ),
    } | STAMP_ATTRS,
    toolchains = [
        "@bazel_lib//lib:coreutils_toolchain_type",
        "@jq.bzl//jq/toolchain:type",
        "@yq.bzl//yq/toolchain:type",
        "@io_github_janhicken_rules_kubebuilder//kubebuilder:envtest_toolchain",
        "@rules_shell//shell:toolchain_type",
    ],
    doc = """Build a set of KRM resources similar to a kustomization.yaml.

All attributes support interpolation of stamp variables, if stamping is enabled.
The stamp variable needs to be referenced using the syntax like `${STABLE_VAR_NAME}` or `${BUILD_TIMESTAMP}`.
""",
    provides = [DefaultInfo, KustomizeInfo],
)
