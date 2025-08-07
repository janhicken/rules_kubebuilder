# Bazel Rules for Kubebuilder

This repository provides Bazel rules for the ecosystem of Kubebuilder-style Kubernetes controllers.

## Features

* Code & manifest generation
  using [controller-gen](https://github.com/kubernetes-sigs/kubebuilder/blob/master/docs/book/src/reference/controller-gen.md)
* Testing with [envtest](https://pkg.go.dev/sigs.k8s.io/controller-runtime/pkg/envtest)
* Configuration management using [kustomize](https://kustomize.io/)
* Creating local dev environments using [kind](https://kind.sigs.k8s.io/)
* Testing with [kuttl](https://kuttl.dev/) on [kind](https://kind.sigs.k8s.io/) clusters

## Installation

At the moment, only Bzlmod is supported. Add this to your `MODULE.bazel`:

```starlark
bazel_dep(name = "io_github_janhicken_rules_kubebuilder", version = "0.0.0")
```

The module is not yet published in the Bazel Central Registry.
As a result, you will need to configure an override to source the module from GitHub like this:

```starlark
git_override(
    module_name = "io_github_janhicken_rules_kubebuilder",
    remote = "https://github.com/janhicken/rules_kubebuilder.git",
    commit = "<desired ref>",
)
```

Next, load the kubebuilder extension and configure it for the desired Kubernetes API version:

```starlark
kubebuilder = use_extension("@io_github_janhicken_rules_kubebuilder//kubebuilder:extensions.bzl", "kubebuilder")
kubebuilder.for_kubernetes(version = "1.32.0")
```

For envtest support, making the `@envtest` repository visible is required:

```starlark
use_repo(kubebuilder, "envtest")
```

You will probably also need to set up [rules_go](https://github.com/bazel-contrib/rules_go) for Go development.
Please make sure to _not_ use an alias for the `rules_go` module.

## Usage

[This repository](./e2e/cronjob-tutorial) contains exemplary usages of most of the features.

### `controller-gen`

The `controller-gen` targets are based on `go_library` targets that are scanned for the Kubebuilder markers.

These rules are available:

* `controller_gen_crds`: generate CRD YAMLs based on API type specs
* `controller_gen_objects`: generate code containing DeepCopy and DeepCopyInto
* `controller_gen_rbac`: generate ClusterRole objects
* `controller_gen_webhooks`: generate (partial) {Mutating,Validating}WebhookConfiguration objects.

As there is a circular dependency between API types and its `zz_generated.deepcopy.go`, committing the generated file is
recommended.

The [`write_source_file`](https://github.com/bazel-contrib/bazel-lib/blob/main/docs/write_source_files.md) rule can be
used to achieve that and have a diff test for the file:

```starlark
load("@aspect_bazel_lib//lib:write_source_files.bzl", "write_source_files")
load("@io_github_janhicken_rules_kubebuilder//kubebuilder:defs.bzl", "controller_gen_objects")
load("@rules_go//go:def.bzl", "go_library")

go_library(
    name = "api",
    srcs = [
        "types.go",
        "groupversion_info.go",
        "zz_generated.deepcopy.go",
    ],
    # [...]
)

controller_gen_objects(
    name = "deepcopy.go",
    srcs = [":api"],
)

write_source_files(
    name = "generate",
    files = {"zz_generated.deepcopy.go": ":deepcopy.go"},
)
```

### `envtest_test`

The `envtest_test` rule is a wrapper around a simple `go_test` that makes the envtest toolchain available to the test.
It is convenient to use `envtest_test` as a replacement for the `go_test` rule like this:

```starlark
load("@io_github_janhicken_rules_kubebuilder//kubebuilder:defs.bzl", go_test = "envtest_test")

go_test(...)
```

When running [`env.Start()`](https://pkg.go.dev/sigs.k8s.io/controller-runtime/pkg/envtest#Environment.Start) in the Go
test implementation, the envtest toolchain is detected through the `KUBEBUILDER_ASSETS` environment variable that the
`envtest_test` rule sets up.

### `kustomization`

The [`kustomization`](./docs/rules.md#kustomization) rule works like calling `kustomize build`. Instead of writing a
`kustomization.yaml` spec, the directives are specified in your build. This way, dependencies to other rules'
outputs can be specified easily. For example, the output of the `controller_gen_rbac` rule can be included into a full
set of manifests.

Furthermore, config maps can be created based on other file targets using the [`config_map`](./docs/rules.md#config_map)
rule. Similarly, generic or TLS secrets can be created using the rules
[`generic_secret`](./docs/rules.md#generic_secret) and [`tls_secret`](./docs/rules.md#tls_secret), respectively.

The following example creates a config map with the file contents of `config_a.txt` and `context_b.txt`. The resulting
config and the `deployment.yaml` is then grouped to a set of manifests. The namespace for all resources is set to
`my-project`.

```starlark
load("@io_github_janhicken_rules_kubebuilder//kubebuilder:defs.bzl", "config_map", "kustomization")

config_map(
    name = "my_config",
    srcs = [
        "config_a.txt",
        "config_b.txt",
    ]
    config_map_name: "my-config",
)

kustomization(
    name = "my_project",
    resources = [
        ":my_config",
        "deployment.yaml"
    ],
    namespace = "my-project",
)
```

See the `kustomization` rule's [documentation](./docs/rules.md#kustomization) for the full set of supported directives.

`kustomization` targets are runnable, causing the manifest to be applied to the currently selected `kubectl` context.
When applying, CRDs are applied first and awaited to be `Established`, before all other resources get applied.

#### Container Image Digest Pinning

When building container images using [rules_oci](https://github.com/bazel-contrib/rules_oci), building reproducible
container images for Go applications is easily achievable. The resulting digest of such an image or multi-platform image
index is static.

_rules_kubebuilder_ provides support for injecting digest references for images in Kubernetes pod specs as part of the
`kustomization` rule. Using this feature, image references can be pinned to a certain version of an image.

As software development is conducted both on `x86_64` and `aarch64` CPU architectures due to the prevalence of Apple
Silicon nowadays, it is recommended to always create multi-platform image index for at least those two architectures.

The following example creates such an index for a controller manager as well as a target for creating a tarball of it.

```starlark
load("@aspect_bazel_lib//lib:tar.bzl", "tar")
load("@rules_oci//oci:defs.bzl", "oci_image", "oci_image_index", "oci_load")

tar(
    name = "cmd_layer",
    srcs = ["//cmd"],
    compress = "zstd",
    mtree = ["manager uid=0 gid=0 mode=0755 time=0 type=file content=$(location //cmd)"],
)

oci_image(
    name = "manager",
    base = "@distroless_static",
    entrypoint = ["/manager"],
    tars = [":cmd_layer"],
)

oci_image_index(
    name = "manager_index",
    images = [":manager"],
    platforms = [
        "@rules_go//go/toolchain:linux_amd64",
        "@rules_go//go/toolchain:linux_arm64",
    ],
)

oci_load(
    name = "oci_load",
    format = "oci",
    image = "//:manager_index",
    repo_tags = ["myrepo.org/manager"],
)

filegroup(
    name = "manager_index.tar",
    srcs = [":oci_load"],
    output_group = "tarball",
)
```

The tarball built with `manager_index.tar` can be easily referenced in `kind_env` and `kuttl_test` targets.

In order to pin an image reference to a specific digest, use the `kustomization` rule's `image_digests` attribute.
This example pins the image `myrepo.org/manager` to the digest of the index built by `:manager_index`.

> [!NOTE]
> The `.digest`-suffixed target is created automatically by the `oci_image_index` macro.

```starlark
kustomization(
    name = "manager",
    image_digests = {"myrepo.org/manager": ":manager_index.digest"},
    resources = ["deployment.yaml"],
)
```

See the cronjob tutorial for an example on how to [build the container image](./e2e/cronjob-tutorial/BUILD.bazel)
and [pin images with digests](./e2e/cronjob-tutorial/config/manager/BUILD).

### `kind_env`

The [`kind_env`](./docs/rules.md#kind_env) rule can be used to define a local dev environment.

When running the rule with `bazel run`, it will

1. create a kind cluster with the given name, if not existing yet,
2. write a [kubeconfig](https://kubernetes.io/docs/concepts/configuration/organize-cluster-access-kubeconfig/) file named `${cluster}-kubeconfig.yaml` to the repository root,
3. load all OCI container image tarballs specified into the cluster and
4. apply a kustomization, if given.

Running the rule multiple times is idempotent.

```starlark
load("@io_github_janhicken_rules_kubebuilder//kubebuilder:defs.bzl", "kind_env")

kind_env(
    name = "kind_env",
    cluster_name = "my-project",
    images = ["//:my-image.tar"],
    kustomization = "//config/local",
)
```

The kind cluster can be deleted by giving `delete` as an argument, for example:

```shell
bazel run :kind_env delete
```

### `kuttl_test`

The `kuttl_test` rule runs [kuttl](https://kuttl.dev/) tests hermetically.
Tests are run on a kind cluster created for each `kuttl_test`.

OCI container image tarballs can be loaded into the Kind cluster before test execution.
[rules_oci](https://github.com/bazel-contrib/rules_oci) is a good fit for building OCI images using Bazel.

**IMPORTANT**: The tag `supports-graceful-termination` is required on the target in order to have Bazel allow the test
to terminate gracefully and clean up the kind cluster when interrupted.
Pressing Ctrl+C might be a source for such an interruption. See the example below on how to set the tag.

The rule currently requires the test suite directory structure to be relative to the package containing the `kuttl_test`
rule, like this:

```
test/e2e
├── BUILD <- contains kuttl_test target
├── case-1
│   ├── 00-assert.yaml
│   ├── 00-install.yaml
│   ├── 01-assert.yaml
│   └── 01-install.yaml
└── case-2
    ├── 00-assert.yaml
    └── 00-install.yaml
```

For this directory structure, the `kuttl_test` target might look like this:

```starlark
load("@io_github_janhicken_rules_kubebuilder//kubebuilder:defs.bzl", "kuttl_test")

kuttl_test(
    name = "e2e",
    size = "large",
    srcs = [
        "case-1/00-assert.yaml",
        "case-1/00-install.yaml",
        "case-1/01-assert.yaml",
        "case-1/01-install.yaml",
        "case-2/00-assert.yaml",
        "case-2/00-install.yaml",
    ],
    crds = ["//config/crd"],
    images = ["//:image.tar"],
    manifests = ["//config/local"],
    tags = ["supports-graceful-termination"],
)
```
