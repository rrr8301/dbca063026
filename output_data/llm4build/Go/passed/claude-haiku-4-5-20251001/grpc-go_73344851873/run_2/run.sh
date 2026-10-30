#!/bin/bash

set -e

# Print Go version for verification
echo "=== Go Version ==="
go version

# Set error handling: continue on test failures but track exit code
EXIT_CODE=0

# Run tests on root module
echo "=== Running tests on root module ==="
if ! go test -cpu 1,4 -timeout 7m ./...; then
    EXIT_CODE=1
fi

# Run tests on all submodules
echo "=== Running tests on submodules ==="
cd /workspace
for MOD_FILE in $(find . -name 'go.mod' | grep -Ev '^\./go\.mod'); do
    MOD_DIR="$(dirname ${MOD_FILE})"
    echo "Testing module: ${MOD_DIR}"
    pushd "${MOD_DIR}" > /dev/null
    if ! go test -cpu 1,4 -timeout 2m ./...; then
        EXIT_CODE=1
    fi
    popd > /dev/null
done

# Exit with accumulated error code
exit $EXIT_CODE