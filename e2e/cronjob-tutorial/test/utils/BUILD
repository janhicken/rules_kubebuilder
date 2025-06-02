load("@rules_go//go:def.bzl", "go_library")

package(default_testonly = True)

go_library(
    name = "utils",
    srcs = [
        "kind.go",
        "utils.go",
    ],
    importpath = "tutorial.kubebuilder.io/project/test/utils",
    visibility = ["//visibility:public"],
    deps = [
        "@io_k8s_apimachinery//pkg/apis/meta/v1/unstructured",
        "@io_k8s_apimachinery//pkg/util/yaml",
        "@io_k8s_client_go//kubernetes/scheme",
        "@io_k8s_client_go//rest",
        "@io_k8s_client_go//tools/clientcmd",
        "@io_k8s_sigs_controller_runtime//:controller-runtime",
        "@io_k8s_sigs_controller_runtime//pkg/client",
        "@io_k8s_sigs_controller_runtime//pkg/envtest",
        "@io_k8s_sigs_kind//pkg/cluster",
        "@io_k8s_sigs_kind//pkg/cluster/nodeutils",
    ],
)
