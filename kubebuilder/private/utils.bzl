"Utilities."

load("@bazel_skylib//lib:paths.bzl", "paths")
load("@bazel_skylib//lib:shell.bzl", "shell")

def join_path(ctx, binaries):
    return ctx.configuration.host_path_separator.join([
        paths.dirname(binary.short_path)
        for binary in binaries
    ])

def runfiles_path_array_literal(files):
    return shell.array_literal([file.short_path for file in files])
