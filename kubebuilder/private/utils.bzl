"Utilities."

load("@bazel_skylib//lib:paths.bzl", "paths")
load("@bazel_skylib//lib:shell.bzl", "shell")

def runfiles_path_array_literal(files):
    return shell.array_literal([file.short_path for file in files])

def use_runtime_toolchains(ctx, toolchains):
    binaries = depset(transitive = [
        toolchain.default.files
        for toolchain in toolchains
    ])
    command_path = ctx.configuration.host_path_separator.join([
        paths.dirname(binary.short_path)
        for binary in binaries.to_list()
    ])

    runfiles = ctx.runfiles(transitive_files = binaries).merge_all([
        toolchain.default.default_runfiles
        for toolchain in toolchains
        if toolchain.default.default_runfiles
    ])

    return command_path, runfiles
