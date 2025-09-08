"# Kubebuilder Rules"

load(
    "//kubebuilder/private:chainsaw.bzl",
    _chainsaw_test = "chainsaw_test",
)
load(
    "//kubebuilder/private:controller_gen.bzl",
    _controller_gen_crds = "controller_gen_crds",
    _controller_gen_objects = "controller_gen_objects",
    _controller_gen_rbac = "controller_gen_rbac",
    _controller_gen_webhooks = "controller_gen_webhooks",
)
load(
    "//kubebuilder/private:envtest.bzl",
    _envtest_test = "envtest_test",
)
load("//kubebuilder/private:kind_env.bzl", _kind_env = "kind_env")
load(
    "//kubebuilder/private:kubectl.bzl",
    _config_map = "config_map",
    _generic_secret = "generic_secret",
    _tls_secret = "tls_secret",
)
load(
    "//kubebuilder/private:kustomize.bzl",
    _kustomization = "kustomization",
)

chainsaw_test = _chainsaw_test

controller_gen_crds = _controller_gen_crds
controller_gen_objects = _controller_gen_objects
controller_gen_rbac = _controller_gen_rbac
controller_gen_webhooks = _controller_gen_webhooks

envtest_test = _envtest_test

kind_env = _kind_env

config_map = _config_map
generic_secret = _generic_secret
kustomization = _kustomization
tls_secret = _tls_secret
