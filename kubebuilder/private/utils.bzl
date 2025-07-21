"Utilities."

load("@bazel_skylib//lib:paths.bzl", "paths")

def join_path(ctx, binaries):
    return ctx.configuration.host_path_separator.join([
        paths.dirname(binary.short_path)
        for binary in binaries
    ])

def space_separated(files):
    for file in files:
        if " " in file.short_path:
            fail("File path must not contain spaces:", file.short_path)

    return " ".join([file.short_path for file in files])
