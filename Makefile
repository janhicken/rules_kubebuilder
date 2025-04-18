.DEFAULT_TARGET: build
.PHONY: build
build:
	bazel build //...

.PHONY: fmtcheck
fmtcheck:
	bazel run -- //tools:format.check 

.PHONY: fmt
fmt:
	bazel run -- //tools:format

.PHONY: lint
lint:
	bazel run -- //tools:buildifier.check

.PHONY: gazelle
gazelle:
	bazel run //tools:gazelle

.PHONY: test
test:
	bazel test //...
	cd e2e/cronjob-tutorial && bazel test //...

.PHONY: ci
ci: fmtcheck lint test
