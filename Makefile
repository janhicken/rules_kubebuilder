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

.PHONY: lock
lock:
	bazel mod deps --lockfile_mode=update

.PHONY: tidy
tidy: fmt lintfix gazelle lock

# ╔════════════════════════════════════════════════════════════════════════════╗
# ║                                    Test                                    ║
# ╚════════════════════════════════════════════════════════════════════════════╝

.PHONY: test
test:
	bazel test //...

.PHONY: e2e-test
e2e-test:
	make -C e2e/cronjob-tutorial test

.PHONY: ci
ci: check test e2e-test
