#!/bin/bash
set -e

go version
go test -cpu 1,4 -timeout 7m ./...
cd "${GITHUB_WORKSPACE:-.}"
for MOD_FILE in $(find . -name 'go.mod' | grep -Ev '^\./go\.mod'); do
  pushd "$(dirname ${MOD_FILE})"
  go test -cpu 1,4 -timeout 2m ./...
  popd
done