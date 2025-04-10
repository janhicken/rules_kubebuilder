"Bazel Rules for controller-gen"

load("@rules_go//go:def.bzl", "GoInfo", "GoPath", "go_context", "go_path")

def _get_importpath(label):
    return label[GoInfo].importpath

def _controller_gen_impl(ctx, generator):
    controller_gen = ctx.toolchains["@io_github_janhicken_rules_kubebuilder//kubebuilder:controller_gen_toolchain"].controller_gen

    go = go_context(ctx)
    go_path_dir = ctx.attr.go_path[GoPath].gopath_file
    go_root_dirname = go.sdk.root_file.dirname

    # Configure environment
    go.env["GOTOOLCHAIN"] = "local"
    go.env["GO111MODULE"] = "off"
    go.env["GODEBUG"] = "execerrdot=0"  # allow relative path lookups
    go.env["PATH"] += ":{goroot}/bin".format(goroot = go_root_dirname)

    output_file = ctx.actions.declare_file(ctx.label.name + ".yaml")
    args = ctx.actions.args()
    args.add(generator)
    args.add_joined(ctx.attr.srcs, join_with = ",", map_each = _get_importpath)
    args.add(output_file.path)
    ctx.actions.run_shell(
        outputs = [output_file],
        inputs = depset([go_path_dir], transitive = [go.sdk.srcs]),
        tools = [controller_gen.bin, go.sdk.go, go.sdk.tools],
        mnemonic = "ControllerGen",
        command = """
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
GOCACHE="$tmpdir/gocache" \
GOPATH="$PWD/{gopath}" \
GOROOT="$PWD/{goroot}" \
GOTMPDIR="$tmpdir" \
"{controller_gen}" "$1" paths="$2" output:stdout >"$3"
""".format(
            gopath = go_path_dir.path,
            goroot = go_root_dirname,
            controller_gen = controller_gen.bin.path,
        ),
        arguments = [args],
        env = go.env,
    )

    return DefaultInfo(files = depset([output_file]))

def _controller_gen_crds_impl(ctx):
    return _controller_gen_impl(ctx, "crd")

def _controller_gen_rbac_impl(ctx):
    return _controller_gen_impl(ctx, "rbac:roleName=" + ctx.attr.role_name)

_COMMON_ATTRS = {
    "srcs": attr.label_list(
        allow_empty = False,
        mandatory = True,
        providers = [GoInfo],
        doc = "The input for the generator",
    ),
    "go_path": attr.label(
        mandatory = True,
        providers = [GoPath],
        doc = "A GoPath directory structure for all dependencies",
    ),
    "_go_context_data": attr.label(
        default = "@rules_go//:go_context_data",
    ),
}

_COMMON_TOOLCHAINS = [
    "@rules_go//go:toolchain",
    "@io_github_janhicken_rules_kubebuilder//kubebuilder:controller_gen_toolchain",
]

_controller_gen_crds = rule(
    implementation = _controller_gen_crds_impl,
    attrs = _COMMON_ATTRS,
    toolchains = _COMMON_TOOLCHAINS,
    doc = "generates CustomResourceDefinition objects",
)

_controller_gen_rbac = rule(
    implementation = _controller_gen_rbac_impl,
    attrs = _COMMON_ATTRS | {
        "role_name": attr.string(
            mandatory = True,
            doc = "sets the name of the generated ClusterRole",
        ),
    },
    toolchains = _COMMON_TOOLCHAINS,
    doc = "generates ClusterRole objects",
)

def controller_gen_crds(name, srcs, **kwargs):
    """Generates CustomResourceDefinition objects from Golang struct definitions.

    Args:
        name: Name of the rule.
        srcs: A list of targets that build Go packages used as a source for the generator.
        **kwargs: further keyword arguments, e.g. `visibility`
    """
    go_path_name = name + "_go_path"
    go_path(
        name = go_path_name,
        deps = srcs,
    )

    _controller_gen_crds(
        name = name,
        srcs = srcs,
        go_path = go_path_name,
        **kwargs
    )

def controller_gen_rbac(name, srcs, role_name, **kwargs):
    """Generates RBAC manifests from kubebuilder:rbac markers.

    Args:
        name: Name of the rule.
        srcs: A list of targets that build Go packages used as a source for the generator.
        role_name: sets the name of the generated ClusterRole
        **kwargs: further keyword arguments, e.g. `visibility`
    """
    go_path_name = name + "_go_path"
    go_path(
        name = go_path_name,
        deps = srcs,
        **kwargs
    )

    _controller_gen_rbac(
        name = name,
        srcs = srcs,
        go_path = go_path_name,
        role_name = role_name,
        **kwargs
    )
