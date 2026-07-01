#!/bin/bash

set -e

# Enable error handling - continue on test failures but track them
TESTS_FAILED=0

# Setup environment variables
export GITHUB_WORKSPACE="/workspace"
export CACHE_DIR="${GITHUB_WORKSPACE}/.container-cache"
export TORCH_VERSION="nightly"

# Create cache directory
mkdir -p "${CACHE_DIR}"

# Configure ccache
echo "Configuring ccache..."
rm -rf "${GITHUB_WORKSPACE}/.ccache" || true
mkdir -p "${GITHUB_WORKSPACE}/.ccache"
ccache --set-config "cache_dir=${GITHUB_WORKSPACE}/.ccache"
ccache --set-config "compression=true"
ccache --set-config "max_size=300M"
ccache --zero-stats

# Display Python version and path
echo "=== Python Information ==="
python -c "import sys; print(sys.version)"
which python
echo ""

# Install Python dependencies for torch-nightly
echo "=== Installing Python Dependencies (torch-nightly) ==="
cd "${GITHUB_WORKSPACE}"
if [ -f "build_tools/ci/install_python_deps.sh" ]; then
    bash build_tools/ci/install_python_deps.sh nightly
else
    echo "Warning: install_python_deps.sh not found, attempting manual installation"
    if [ -f "pytorch-requirements.txt" ]; then
        python -m pip install -r pytorch-requirements.txt
    fi
    if [ -f "build-requirements.txt" ]; then
        python -m pip install -r build-requirements.txt
    fi
fi
echo ""

# Build project
echo "=== Building Project ==="
export cache_dir="${CACHE_DIR}"
if [ -f "build_tools/ci/build_posix.sh" ]; then
    bash build_tools/ci/build_posix.sh
else
    echo "Error: build_posix.sh not found"
    exit 1
fi
echo ""

# Integration tests (torch-nightly)
echo "=== Running Integration Tests (torch-nightly) ==="
if [ -f "build_tools/ci/test_posix.sh" ]; then
    bash build_tools/ci/test_posix.sh nightly || TESTS_FAILED=1
else
    echo "Warning: test_posix.sh not found, skipping integration tests"
fi
echo ""

# Check generated sources (torch-nightly only)
echo "=== Checking Generated Sources (torch-nightly) ==="
if [ -f "build_tools/ci/check_generated_sources.sh" ]; then
    bash build_tools/ci/check_generated_sources.sh || TESTS_FAILED=1
else
    echo "Warning: check_generated_sources.sh not found, skipping source check"
fi
echo ""

# Print ccache statistics
echo "=== ccache Statistics ==="
ccache --show-stats
echo ""

# Exit with appropriate code
if [ $TESTS_FAILED -eq 1 ]; then
    echo "Some tests failed. See output above for details."
    exit 1
fi

echo "=== All tests completed successfully ==="
exit 0