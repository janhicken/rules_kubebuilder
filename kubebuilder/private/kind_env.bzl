"Bazel Rules for creating a local dev environment with kind"

load(":kubectl.bzl", "KustomizeInfo")
load(":utils.bzl", "space_separated")

def _kind_env_impl(ctx):
    kind = ctx.toolchains["@io_github_janhicken_rules_kubebuilder//kubebuilder:kind_toolchain"].kind
    yq = ctx.toolchains["@aspect_bazel_lib//lib:yq_toolchain_type"].yqinfo

    # Configure kind Cluster
    cluster = {
        "apiVersion": "kind.x-k8s.io/v1alpha4",
        "kind": "Cluster",
        "name": ctx.attr.cluster_name,
        "nodes": [{
            "extraMounts": [{
                "containerPath": "/var/lib/containerd",
                "hostPath": "${DOCKER_VOLUME_PATH}",
            }],
            "image": kind.node_image,
            "role": "control-plane",
        }],
    }
    config_file = ctx.actions.declare_file(ctx.label.name + ".json")
    ctx.actions.write(
        output = config_file,
        content = json.encode(cluster),
    )

    # Configure runfiles
    runfiles = ctx.runfiles(ctx.files.images + [config_file, kind.bin, yq.bin])
    if ctx.executable.kustomization:
        runfiles = runfiles.merge(ctx.attr.kustomization[DefaultInfo].default_runfiles)
        kustomization_apply_bin = ctx.executable.kustomization.short_path
    else:
        kustomization_apply_bin = None

    # Prepare executable script
    executable = ctx.actions.declare_file(ctx.label.name + ".sh")
    ctx.actions.expand_template(
        template = ctx.file._kind_env,
        output = executable,
        substitutions = {
            "%image_archives%": space_separated(ctx.files.images),
            "%kind_bin%": kind.bin.short_path,
            "%kind_cluster_name%": ctx.attr.cluster_name,
            "%kind_config_file%": config_file.short_path,
            "%kustomization_apply_bin%": kustomization_apply_bin or "",
            "%yq_bin%": yq.bin.short_path,
        },
        is_executable = True,
    )

    return [DefaultInfo(
        files = depset([config_file, executable]),
        executable = executable,
        runfiles = runfiles,
    )]

kind_env = rule(
    implementation = _kind_env_impl,
    attrs = {
        "cluster_name": attr.string(
            doc = "The kind cluster name.",
            mandatory = True,
        ),
        "images": attr.label_list(
            doc = "OCI image tarballs to load into the kind cluster.",
            allow_files = [".tar"],
        ),
        "kustomization": attr.label(
            doc = "Kustomization to apply to the cluster.",
            executable = True,
            providers = [KustomizeInfo],
            cfg = "exec",
        ),
        "_kind_env": attr.label(
            default = Label(":kind_env.sh"),
            allow_single_file = True,
        ),
    },
    executable = True,
    toolchains = [
        "@aspect_bazel_lib//lib:yq_toolchain_type",
        "@io_github_janhicken_rules_kubebuilder//kubebuilder:kind_toolchain",
    ],
    doc = """Creates a local dev environment with kind using the given kustomization and images.

The container images downloaded by containerd will be stored in a dedicated Docker volume attached to the kind node.
All clusters with the same name created by this rule will share the same volume.
This way, container images do not have to be re-downloaded every time the cluster is started.

A kubeconfig for the cluster will be written to a filed named `${cluster_name}-kubeconfig.yaml` in the workspace root.

Running the rule multiple times is idempotent.""",
)
