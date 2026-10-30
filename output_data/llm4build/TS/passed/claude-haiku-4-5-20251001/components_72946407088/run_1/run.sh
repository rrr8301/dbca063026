#!/bin/bash

set -e

# Print commands for debugging
set -x

# Navigate to components directory if it exists
if [ -d "components" ]; then
    cd components
fi

# Install node modules with pnpm
echo "Installing dependencies with pnpm..."
pnpm install --frozen-lockfile

# Run Bazel tests
# Note: RBE is skipped; tests run locally
# Filters: exclude linker-integration-test and e2e tests
echo "Running Bazel tests..."
bazel test \
    --build_tests_only \
    --test_tag_filters=-linker-integration-test \
    --test_tag_filters=-e2e \
    -- //... \
    -//goldens/... \
    -//integration/... || TEST_FAILED=1

# Exit with appropriate code
if [ "${TEST_FAILED}" = "1" ]; then
    echo "Some tests failed, but continuing to completion..."
    exit 1
fi

exit 0