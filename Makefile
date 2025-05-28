.DEFAULT_TARGET: build
.PHONY: build
build:
	bazel build //...

# ╔════════════════════════════════════════════════════════════════════════════╗
# ║                                   Check                                    ║
# ╚════════════════════════════════════════════════════════════════════════════╝

.PHONY: fmtcheck
fmtcheck:
	bazel run -- //tools:format.check

.PHONY: lint
lint:
	bazel run -- //tools:buildifier.check

.PHONY: check
check: fmtcheck lint

# ╔════════════════════════════════════════════════════════════════════════════╗
# ║                                    Tidy                                    ║
# ╚════════════════════════════════════════════════════════════════════════════╝

.PHONY: fmt
fmt:
	bazel run -- //tools:format

.PHONY: lintfix
lintfix:
	bazel run -- //tools:buildifier

.PHONY: gazelle
gazelle:
	bazel run //tools:gazelle

.PHONY: tidy
tidy: fmt lintfix gazelle

# ╔════════════════════════════════════════════════════════════════════════════╗
# ║                                    Test                                    ║
# ╚════════════════════════════════════════════════════════════════════════════╝

.PHONY: test
test:
	bazel test //...

.PHONY: e2e-test
e2e-test:
	cd e2e/cronjob-tutorial && bazel test //...

.PHONY: ci
ci: check test e2e-test
