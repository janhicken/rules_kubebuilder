"Bazel Rules for kuttl"

load(":utils.bzl", "join_path", "space_separated")

def _kuttl_test_impl(ctx):
    coreutils_toolchain = ctx.toolchains["@aspect_bazel_lib//lib:coreutils_toolchain_type"]
    docker_toolchain = ctx.toolchains["@io_github_janhicken_rules_kubebuilder//kubebuilder:docker_toolchain"]
    kind_toolchain = ctx.toolchains["@io_github_janhicken_rules_kubebuilder//kubebuilder:kind_toolchain"]
    kuttl_toolchain = ctx.toolchains["@io_github_janhicken_rules_kubebuilder//kubebuilder:kuttl_toolchain"]

    executable = ctx.actions.declare_file(ctx.label.name + ".sh")
    command_path = join_path(ctx, [
        coreutils_toolchain.coreutils_info.bin,
        docker_toolchain.docker.docker,
        kind_toolchain.kind.bin,
        kuttl_toolchain.kuttl.bin,
    ])
    ctx.actions.expand_template(
        template = ctx.file._kuttl_sh,
        output = executable,
        substitutions = {
            "%PATH%": command_path,
            "%crd_files%": space_separated(ctx.files.crds),
            "%image_archives%": space_separated(ctx.files.images),
            "%kind_node_image%": ctx.attr.kind_node_image or kind_toolchain.kind.node_image,
            "%manifest_files%": space_separated(ctx.files.manifests),
            "%test_dir%": ctx.label.package,
        },
        is_executable = True,
    )

    runfiles = ctx.runfiles(
        ctx.files.srcs + ctx.files.crds + ctx.files.manifests + ctx.files.images,
    ).merge_all([
        coreutils_toolchain.default.default_runfiles,
        docker_toolchain.default.default_runfiles,
        kind_toolchain.default.default_runfiles,
        kuttl_toolchain.default.default_runfiles,
    ])
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
        ),
    },
    toolchains = [
        "@aspect_bazel_lib//lib:coreutils_toolchain_type",
        "@io_github_janhicken_rules_kubebuilder//kubebuilder:docker_toolchain",
        "@io_github_janhicken_rules_kubebuilder//kubebuilder:kind_toolchain",
        "@io_github_janhicken_rules_kubebuilder//kubebuilder:kuttl_toolchain",
    ],
)
