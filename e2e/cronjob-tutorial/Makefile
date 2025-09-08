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
	bazel test --test_size_filters=small //...

.PHONY: e2e-test
e2e-test:
	bazel test --test_size_filters=medium,large,enormous //...
