"Bazel Rules for kuttl"

def _space_separated(files):
    return " ".join([file.short_path for file in files])

def _kuttl_test_impl(ctx):
    kind = ctx.toolchains["@io_github_janhicken_rules_kubebuilder//kubebuilder:kind_toolchain"].kind
    kuttl = ctx.toolchains["@io_github_janhicken_rules_kubebuilder//kubebuilder:kuttl_toolchain"].kuttl

    executable = ctx.actions.declare_file(ctx.label.name + ".sh")
    ctx.actions.expand_template(
        template = ctx.file._kuttl_sh,
        output = executable,
        substitutions = {
            "%crd_files%": _space_separated(ctx.files.crds),
            "%image_archives%": _space_separated(ctx.files.images),
            "%kind_bin%": kind.bin.short_path,
            "%kind_node_image%": ctx.attr.kind_node_image or kind.node_image,
            "%kuttl_bin%": kuttl.bin.short_path,
            "%manifest_files%": _space_separated(ctx.files.manifests),
            "%test_dir%": ctx.label.package,
        },
        is_executable = True,
    )

    runfiles = ctx.runfiles(
        ctx.files.srcs + ctx.files.crds + ctx.files.manifests + ctx.files.images +
        [kind.bin, kuttl.bin],
    )
    return [
        DefaultInfo(executable = executable, runfiles = runfiles),
    ]

kuttl_test = rule(
    implementation = _kuttl_test_impl,
    doc = """Define a KuTTL test suite that runs on a kind cluster.

Please remember to set the tag `supports-graceful-termination` on the target to allow the test runner to export the
kind cluster's logs and shut it down.
""",
    test = True,
    attrs = {
        "crds": attr.label_list(
            doc = "Custom resource definition manifests to install before running tests.",
            allow_files = [".yaml", ".yml"],
        ),
        "images": attr.label_list(
            doc = "OCI image tarballs to load into the kind cluster once it is started.",
            allow_files = [".tar"],
        ),
        "kind_node_image": attr.string(
            doc = "Override the node Docker image to use for booting the kind cluster",
        ),
        "manifests": attr.label_list(
            doc = "Manifests to install before running tests.",
            allow_files = [".yaml", ".yml"],
        ),
        "srcs": attr.label_list(
            doc = "Test suite files to run.",
            mandatory = True,
            allow_files = [".yaml", ".yml"],
        ),
        "_kuttl_sh": attr.label(
            default = Label(":kuttl.sh"),
            allow_single_file = True,
            executable = True,
            cfg = "exec",
        ),
    },
    toolchains = [
        "@io_github_janhicken_rules_kubebuilder//kubebuilder:kind_toolchain",
        "@io_github_janhicken_rules_kubebuilder//kubebuilder:kuttl_toolchain",
    ],
)
