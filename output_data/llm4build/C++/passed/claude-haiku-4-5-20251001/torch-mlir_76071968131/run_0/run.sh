#!/bin/bash
set -e

# Set up environment variables
export GITHUB_WORKSPACE="/workspace"
export CACHE_DIR="${GITHUB_WORKSPACE}/.container-cache"
mkdir -p "${CACHE_DIR}"

# Initialize git submodules (in case they weren't cloned)
cd "${GITHUB_WORKSPACE}"
git submodule update --init --recursive || true

# Display Python version and path
echo "=== Python Information ==="
python -c "import sys; print(sys.version)"
which python
echo ""

# Configure ccache
echo "=== Configuring ccache ==="
rm -rf "${GITHUB_WORKSPACE}/.ccache"
mkdir -p "${GITHUB_WORKSPACE}/.ccache"
ccache --set-config "cache_dir=${GITHUB_WORKSPACE}/.ccache"
ccache --set-config "compression=true"
ccache --set-config "max_size=300M"
ccache --zero-stats
echo ""

# Install Python dependencies (torch-nightly)
echo "=== Installing Python Dependencies (torch-nightly) ==="
cd "${GITHUB_WORKSPACE}"
bash build_tools/ci/install_python_deps.sh nightly
echo ""

# Build project
echo "=== Building Project ==="
export cache_dir="${CACHE_DIR}"
bash build_tools/ci/build_posix.sh
echo ""

# Run integration tests (torch-nightly)
echo "=== Running Integration Tests (torch-nightly) ==="
bash build_tools/ci/test_posix.sh nightly || TEST_FAILED=1
echo ""

# Check generated sources (torch-nightly only)
echo "=== Checking Generated Sources ==="
bash build_tools/ci/check_generated_sources.sh || CHECK_FAILED=1
echo ""

# Report results
if [ -n "$TEST_FAILED" ] || [ -n "$CHECK_FAILED" ]; then
    echo "=== Some tests or checks failed ==="
    exit 1
fi

echo "=== All tests and checks passed ==="
exit 0