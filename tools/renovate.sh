#!/usr/bin/env bash
set -o errexit
set -o nounset

RENOVATE_ALLOWED_COMMANDS='.*'
RENOVATE_GITHUB_COM_TOKEN=$(gh auth token)
RENOVATE_TOKEN=$(gh auth token)
export RENOVATE_ALLOWED_COMMANDS RENOVATE_GITHUB_COM_TOKEN RENOVATE_TOKEN

repo=$(gh repo view --json nameWithOwner --jq .nameWithOwner)
exec renovate "$repo"
