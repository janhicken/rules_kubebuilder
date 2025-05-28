#!/bin/sh
set -eu

printf 'STABLE_GIT_DESCRIPTION '
git describe --always --tags

printf 'STABLE_TEST_VERSION v1.2.3\n'
