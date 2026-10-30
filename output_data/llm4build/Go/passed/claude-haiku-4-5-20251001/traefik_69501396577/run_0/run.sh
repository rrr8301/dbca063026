#!/bin/bash

set -e

# Navigate to workspace
cd /workspace

# Display Go version for debugging
echo "Go version:"
go version

# Display Go environment
echo "Go environment:"
go env

# Define the packages to test (matching the matrix from the workflow)
packages=(
    "github.com/traefik/traefik/v3/pkg/config/label"
    "github.com/traefik/traefik/v3/pkg/config"
)

# Track test results
test_failed=0

# Run tests for each package
for package in "${packages[@]}"; do
    echo "=========================================="
    echo "Testing package: $package"
    echo "=========================================="
    
    if ! go test -v -parallel 8 "$package"; then
        echo "FAILED: Tests failed for package $package"
        test_failed=1
    else
        echo "PASSED: Tests passed for package $package"
    fi
    echo ""
done

# Exit with failure code if any tests failed
if [ $test_failed -eq 1 ]; then
    echo "=========================================="
    echo "Some tests failed!"
    echo "=========================================="
    exit 1
fi

echo "=========================================="
echo "All tests passed!"
echo "=========================================="
exit 0