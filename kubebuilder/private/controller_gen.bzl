"Bazel Rules for controller-gen"

load("@rules_go//go:def.bzl", "GoInfo", "GoPath", "go_context", "go_path")

def _get_importpath(label):
    return label[GoInfo].importpath

def _controller_gen_impl(ctx, generator_name, generator_args_dict = None):
    output_file = ctx.actions.declare_file(ctx.label.name)
    controller_gen = ctx.toolchains["@io_github_janhicken_rules_kubebuilder//kubebuilder:controller_gen_toolchain"].controller_gen

    go = go_context(ctx)
    go_path_dir = ctx.attr.go_path[GoPath].gopath_file
    go_root_dirname = go.sdk.root_file.dirname

    # Configure environment
    go.env["GO111MODULE"] = "off"
    go.env["GODEBUG"] += ",execerrdot=0"  # allow relative path lookups
    go.env["PATH"] += ":{goroot}/bin".format(goroot = go_root_dirname)

    inputs = [go_path_dir]

    # Configure generator args
    generator_args_dict = generator_args_dict or {}
    if ctx.file.header_file:
        inputs.append(ctx.file.header_file)
        generator_args_dict["headerFile"] = ctx.file.header_file.path
    if ctx.attr.year:
        generator_args_dict["year"] = ctx.attr.year
    generator_args = _generator_args_from_dict(ctx, generator_name, generator_args_dict)

    args = ctx.actions.args()
    args.add_joined(ctx.attr.srcs, join_with = ",", map_each = _get_importpath)
    args.add(output_file.path)
    ctx.actions.run_shell(
        outputs = [output_file],
        inputs = depset(inputs, transitive = [go.sdk.srcs, go.stdlib.cache_dir]),
        tools = [controller_gen.bin, go.sdk.go, go.sdk.tools],
        mnemonic = "ControllerGen",
        command = """
GOCACHE="$PWD/{gocache}" \
GOPATH="$PWD/{gopath}" \
GOROOT="$PWD/{goroot}" \
"{controller_gen}" "$1" paths="$2" output:stdout >"$3"
""".format(
            gocache = go.stdlib.cache_dir.to_list()[0].path,
            gopath = go_path_dir.path,
            goroot = go_root_dirname,
            controller_gen = controller_gen.bin.path,
        ),
        arguments = [generator_args, args],
        env = go.env,
    )

    return DefaultInfo(files = depset([output_file]))

def _format_generator_arg(keyval):
    return "%s=%s" % keyval

def _generator_args_from_dict(ctx, generator_name, args_dict):
    args = ctx.actions.args()
    if args_dict:
        return args.add_joined(
            args_dict.items(),
            join_with = ",",
            format_joined = generator_name + ":%s",
            map_each = _format_generator_arg,
            omit_if_empty = False,
        )
    else:
        return args.add(generator_name)

def _controller_gen_crds_impl(ctx):
    generator_args = {}

    if ctx.attr.allow_dangerous_types:
        generator_args["allowDangerousTypes"] = "true"
    if ctx.attr.max_description_length >= 0:
        generator_args["maxDescLen"] = ctx.attr.max_description_length

    return _controller_gen_impl(ctx, "crd", generator_args)

def _controller_gen_objects_impl(ctx):
    return _controller_gen_impl(ctx, "object")

def _controller_gen_rbac_impl(ctx):
    generator_args = {"roleName": ctx.attr.role_name}

    return _controller_gen_impl(ctx, "rbac", generator_args)

def _controller_gen_webhooks_impl(ctx):
    return _controller_gen_impl(ctx, "webhook")

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
    "header_file": attr.label(
        allow_single_file = True,
        doc = "Specifies the header text (e.g. license) to prepend to generated files",
    ),
    "year": attr.int(
        doc = """Specifies the year to substitute for " YEAR" in the header file.""",
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
    attrs = _COMMON_ATTRS | {
        "allow_dangerous_types": attr.bool(
            default = False,
            doc = """Allows types which are usually omitted from CRD generation because they are not recommended.
Currently the following additional types are allowed when this is true:
    float32
    float64
""",
        ),
        "max_description_length": attr.int(
            default = -1,
            doc = """Specifies the maximum description length for fields in CRD's OpenAPI schema.
0 indicates drop the description for all fields completely.
n indicates limit the description to at most n characters and truncate the description to closest sentence boundary if it exceeds n characters.
""",
        ),
    },
    toolchains = _COMMON_TOOLCHAINS,
    doc = "generates CustomResourceDefinition objects",
)

_controller_gen_objects = rule(
    implementation = _controller_gen_objects_impl,
    attrs = _COMMON_ATTRS,
    toolchains = _COMMON_TOOLCHAINS,
    doc = "Generates code containing DeepCopy, DeepCopyInto and DeepCopyObject method implementations",
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

_controller_gen_webhooks = rule(
    implementation = _controller_gen_webhooks_impl,
    attrs = _COMMON_ATTRS,
    toolchains = _COMMON_TOOLCHAINS,
    doc = "Generates (partial) {Mutating,Validating}WebhookConfiguration objects",
)

def controller_gen_crds(
        name,
        srcs,
        allow_dangerous_types = False,
        header_file = None,
        max_description_length = -1,
        year = 0,
        **kwargs):
    """Generates CustomResourceDefinition objects from Golang struct definitions.

    Args:
        name: Name of the rule.
        srcs: A list of targets that build Go packages used as a source for the generator.
        allow_dangerous_types: Allows types which are usually omitted from CRD generation because they are not recommended.
        header_file: Specifies the header text (e.g. license) to prepend to generated files
        year: Specifies the year to substitute for " YEAR" in the header file

            Currently the following additional types are allowed when this is true: `float32` and `float64`
        max_description_length: Specifies the maximum description length for fields in CRD's OpenAPI schema.

            `0` indicates drop the description for all fields completely.
            `n` indicates limit the description to at most `n` characters and truncate the description to closest sentence boundary if it exceeds `n` characters.
        **kwargs: further keyword arguments, e.g. `visibility`
    """
    go_path_name = name + "_go_path"
    go_path(
        name = go_path_name,
        deps = srcs,
        **kwargs
    )

    _controller_gen_crds(
        name = name,
        srcs = srcs,
        go_path = go_path_name,
        allow_dangerous_types = allow_dangerous_types,
        header_file = header_file,
        max_description_length = max_description_length,
        year = year,
        **kwargs
    )

def controller_gen_objects(
        name,
        srcs,
        header_file = None,
        year = 0,
        **kwargs):
    """Generates code containing DeepCopy, DeepCopyInto and DeepCopyObject method implementations.

    Args:
        name: Name of the rule
        srcs: A list of targets that build Go packages used as a source for the generator
        header_file: Specifies the header text (e.g. license) to prepend to generated files
        year: Specifies the year to substitute for " YEAR" in the header file
        **kwargs: further keyword arguments, e.g. `visibility`
    """
    go_path_name = name + "_go_path"
    go_path(
        name = go_path_name,
        deps = srcs,
        **kwargs
    )

    _controller_gen_objects(
        name = name,
        srcs = srcs,
        go_path = go_path_name,
        header_file = header_file,
        year = year,
        **kwargs
    )

def controller_gen_rbac(
        name,
        srcs,
        role_name,
        header_file = None,
        year = 0,
        **kwargs):
    """Generates RBAC manifests from kubebuilder:rbac markers.

    Args:
        name: Name of the rule.
        srcs: A list of targets that build Go packages used as a source for the generator.
        header_file: Specifies the header text (e.g. license) to prepend to generated files
        role_name: sets the name of the generated ClusterRole
        year: Specifies the year to substitute for " YEAR" in the header file
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
        header_file = header_file,
        year = year,
        role_name = role_name,
        **kwargs
    )

def controller_gen_webhooks(
        name,
        srcs,
        header_file = None,
        year = 0,
        **kwargs):
    """Generates (partial) {Mutating,Validating}WebhookConfiguration objects.

    Args:
        name: Name of the rule.
        srcs: A list of targets that build Go packages used as a source for the generator.
        header_file: Specifies the header text (e.g. license) to prepend to generated files
        year: Specifies the year to substitute for " YEAR" in the header file
        **kwargs: further keyword arguments, e.g. `visibility`
    """
    go_path_name = name + "_go_path"
    go_path(
        name = go_path_name,
        deps = srcs,
        **kwargs
    )

    _controller_gen_webhooks(
        name = name,
        srcs = srcs,
        go_path = go_path_name,
        header_file = header_file,
        year = year,
        **kwargs
    )
