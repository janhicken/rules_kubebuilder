.DEFAULT_TARGET: build
.PHONY: build
build:
	bazel build //...

# ╔════════════════════════════════════════════════════════════════════════════╗
# ║                                    Tidy                                    ║
# ╚════════════════════════════════════════════════════════════════════════════╝

.PHONY: tidy
tidy:
	bazel run @rules_go//go mod tidy
	bazel run //:gazelle
	bazel mod tidy

# ╔════════════════════════════════════════════════════════════════════════════╗
# ║                                    Test                                    ║
# ╚════════════════════════════════════════════════════════════════════════════╝

.PHONY: test
test:
	bazel test //...

.PHONY: e2e-test
e2e-test:
	bazel test //test/e2e
