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

# First, try the standard install script
if bash build_tools/ci/install_python_deps.sh nightly 2>&1 | tee /tmp/install.log; then
    echo "Standard installation succeeded"
else
    echo "Standard installation failed, attempting flexible nightly installation..."
    
    # Install base requirements
    python -m pip install --upgrade pip setuptools wheel
    
    # Install from build-requirements.txt if it exists
    if [ -f "${GITHUB_WORKSPACE}/build-requirements.txt" ]; then
        python -m pip install -r "${GITHUB_WORKSPACE}/build-requirements.txt"
    fi
    
    # Install torch nightly with flexible torchvision version
    python -m pip install --pre torch --index-url https://download.pytorch.org/whl/nightly/cpu/
    
    # Install torchvision nightly (allow any compatible version)
    python -m pip install --pre torchvision --index-url https://download.pytorch.org/whl/nightly/cpu/ || \
    python -m pip install torchvision --index-url https://download.pytorch.org/whl/nightly/cpu/ || \
    echo "Warning: torchvision installation had issues, continuing anyway..."
    
    # Install pytorch-requirements.txt if it exists
    if [ -f "${GITHUB_WORKSPACE}/pytorch-requirements.txt" ]; then
        python -m pip install -r "${GITHUB_WORKSPACE}/pytorch-requirements.txt" || true
    fi
fi
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