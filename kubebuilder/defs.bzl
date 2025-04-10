"# Kubebuilder Rules"

load(
    "//kubebuilder/private:controller_gen.bzl",
    _controller_gen_crds = "controller_gen_crds",
    _controller_gen_rbac = "controller_gen_rbac",
)

controller_gen_crds = _controller_gen_crds
controller_gen_rbac = _controller_gen_rbac
