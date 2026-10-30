#!/bin/bash
set -e

# Navigate to workspace
cd /workspace

# Verify Go is available
go version

# The matrix.package.group is passed as an environment variable or argument
# If not provided, default to "./..." (all packages)
PACKAGE_GROUP="${PACKAGE_GROUP:-./.../}"

# Run tests with the exact command from the YAML
# -v: verbose output
# -parallel 8: run tests in parallel with 8 workers
go test -v -parallel 8 ${PACKAGE_GROUP}

echo "Tests completed successfully!"