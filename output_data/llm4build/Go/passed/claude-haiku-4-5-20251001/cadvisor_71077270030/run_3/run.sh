#!/bin/bash

# Print Go version for verification
echo "Go version:"
go version

# Change to workspace directory
cd /workspace

# Source the environment configuration
if [[ -f "build/config/plain.sh" ]]; then
    source build/config/plain.sh
    echo "Sourced build/config/plain.sh"
else
    echo "Warning: build/config/plain.sh not found"
fi

# Install BUILD_PACKAGES if defined
if [[ -n "${BUILD_PACKAGES}" ]]; then
    echo "Installing BUILD_PACKAGES: ${BUILD_PACKAGES}"
    apt-get update
    apt-get install -y ${BUILD_PACKAGES}
    rm -rf /var/lib/apt/lists/*
fi

# Run presubmit checks
echo "Running presubmit checks..."
PRESUBMIT_FAILED=0
make -e presubmit || PRESUBMIT_FAILED=1

# Run tests
echo "Running tests..."
export GOLANG_VERSION=$(go version | awk '{print $3}' | sed 's/go//')
TEST_FAILED=0
make test || TEST_FAILED=1

# Report results
echo ""
echo "========== Test Summary =========="
if [[ ${PRESUBMIT_FAILED} -eq 0 ]]; then
    echo "✓ Presubmit checks passed"
else
    echo "✗ Presubmit checks failed"
fi

if [[ ${TEST_FAILED} -eq 0 ]]; then
    echo "✓ Tests passed"
else
    echo "✗ Tests failed"
fi

# Exit with failure if any test suite failed
if [[ ${PRESUBMIT_FAILED} -eq 1 ]] || [[ ${TEST_FAILED} -eq 1 ]]; then
    exit 1
fi

exit 0