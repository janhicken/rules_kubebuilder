load("@aspect_bazel_lib//lib:paths.bzl", "relative_file")

def _kustomization_impl(ctx):
    envtest = ctx.toolchains["@io_github_janhicken_rules_kubebuilder//kubebuilder:envtest_toolchain"].envtest

    # Create kustomization.yaml
    kustomization_yaml = ctx.actions.declare_file("kustomization.yaml")
    kustomization_spec = {
        "apiVersion": "kustomize.config.k8s.io/v1beta1",
        "configurations": [
            relative_file(configuration.path, kustomization_yaml.path)
            for configuration in ctx.files.configurations
        ],
        "kind": "Kustomization",
        "resources": [
            relative_file(resource.path, kustomization_yaml.path)
            for resource in ctx.files.resources
        ],
    }

    if ctx.attr.namespace:
        kustomization_spec["namespace"] = ctx.attr.namespace

    # Write kustomization
    ctx.actions.write(
        output = kustomization_yaml,
        content = json.encode(kustomization_spec),
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
        inputs = [kustomization_yaml] + ctx.files.resources + ctx.files.configurations,
        executable = envtest.kubectl,
        arguments = [args],
        mnemonic = "KustomizeBuild",
    )

    return DefaultInfo(
        files = depset([output_file]),
    )

kustomization = rule(
    implementation = _kustomization_impl,
    attrs = {
        "configurations": attr.label_list(
            allow_files = [".yml", ".yaml"],
            doc = "A list of transformer configuration files.",
        ),
        "namespace": attr.string(
            doc = "Adds namespace to all resources. Will override the existing namespace if it is set on a resource, or add it if it is not set on a resource.",
        ),
        "resources": attr.label_list(
            mandatory = True,
            allow_files = [".yml", ".yaml"],
            doc = "Resources to include. Each entry in this list must be a path to a YAML file.",
        ),
    },
    toolchains = [
        "@io_github_janhicken_rules_kubebuilder//kubebuilder:envtest_toolchain",
    ],
    doc = "Build a set of KRM resources similar to a kustomization.yaml",
)
