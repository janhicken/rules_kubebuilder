load("@rules_go//go:def.bzl", "go_test")

package(default_testonly = True)

go_test(
    name = "e2e_test",
    size = "large",
    srcs = [
        "e2e_suite_test.go",
        "e2e_test.go",
    ],
    data = [
        "//:manager.tar",
        "//config/local",
    ],
    env = {
        "CONFIG_FILE": "$(rootpath //config/local)",
        "CONTROLLER_IMAGE_TARBALL": "$(rootpath //:manager.tar)",
    },
    rundir = ".",
    deps = [
        "//test/utils",
        "@com_github_onsi_ginkgo_v2//:ginkgo",
        "@com_github_onsi_gomega//:gomega",
        "@io_k8s_api//admissionregistration/v1:admissionregistration",
        "@io_k8s_api//authentication/v1:authentication",
        "@io_k8s_api//core/v1:core",
        "@io_k8s_api//rbac/v1:rbac",
        "@io_k8s_apimachinery//pkg/apis/meta/v1:meta",
        "@io_k8s_apimachinery//pkg/types",
        "@io_k8s_sigs_controller_runtime//pkg/client",
        "@io_k8s_utils//ptr",
    ],
)
