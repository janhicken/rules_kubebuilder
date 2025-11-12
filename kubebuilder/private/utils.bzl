"Utilities."

load("@bazel_skylib//lib:new_sets.bzl", "sets")
load("@bazel_skylib//lib:paths.bzl", "paths")
load("@bazel_skylib//lib:shell.bzl", "shell")

def runfiles_path_array_literal(files):
    return shell.array_literal([file.short_path for file in files])

def use_runtime_toolchains(ctx, toolchains):
    """Builds up a PATH and runfiles for a list of toolchains.

    Args:
        ctx: The Bazel rule context.
        toolchains: A list of toolchains.

    Returns:
        A tuple of a PATH string and a corresponding runfiles object.
    """
    binaries = depset(transitive = [
        toolchain.default.files
        for toolchain in toolchains
    ])
    path_entries = sets.make([
        paths.dirname(binary.short_path)
        for binary in binaries.to_list()
    ])
    command_path = ctx.configuration.host_path_separator.join(sets.to_list(path_entries))

    runfiles = ctx.runfiles(transitive_files = binaries).merge_all([
        toolchain.default.default_runfiles
        for toolchain in toolchains
        if toolchain.default.default_runfiles
    ])

    return command_path, runfiles
