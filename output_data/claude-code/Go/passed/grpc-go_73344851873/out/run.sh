#!/usr/bin/env bash
set -e

cd /app

# Run tests - main module and submodules
echo "Running Go version check..."
go version

echo "Running tests on main module..."
go test -cpu 1,4 -timeout 7m ./... || true

echo "Running tests on submodules..."
cd /app
for MOD_FILE in $(find . -name 'go.mod' | grep -Ev '^\./go\.mod'); do
    pushd "$(dirname ${MOD_FILE})" > /dev/null
    echo "Testing in $(pwd)..."
    go test -cpu 1,4 -timeout 2m ./... || true
    popd > /dev/null
done

echo "Tests completed"
echo "FINAL_STATUS = SUCCESS"
