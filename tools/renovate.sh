#!/usr/bin/env bash
set -o errexit
set -o nounset

RENOVATE_ALLOWED_COMMANDS='.*'
RENOVATE_ALLOWED_UNSAFE_EXECUTIONS=bazelModDeps
RENOVATE_GITHUB_COM_TOKEN=$(gh auth token)
RENOVATE_GIT_AUTHOR="$(git config user.name) <$(git config user.email)>"
RENOVATE_TOKEN=$(gh auth token)
export RENOVATE_ALLOWED_COMMANDS RENOVATE_ALLOWED_UNSAFE_EXECUTIONS RENOVATE_GITHUB_COM_TOKEN RENOVATE_GIT_AUTHOR \
	RENOVATE_TOKEN

repo=$(gh repo view --json nameWithOwner --jq .nameWithOwner)
exec renovate "$repo" "$@"
