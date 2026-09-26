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
python -m pip --version
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

# Upgrade pip, setuptools, wheel first
python -m pip install --upgrade pip setuptools wheel

# Install base requirements from build-requirements.txt if it exists
if [ -f "${GITHUB_WORKSPACE}/build-requirements.txt" ]; then
    echo "Installing build requirements..."
    python -m pip install -r "${GITHUB_WORKSPACE}/build-requirements.txt" || true
fi

# Install pytorch-requirements.txt if it exists
if [ -f "${GITHUB_WORKSPACE}/pytorch-requirements.txt" ]; then
    echo "Installing pytorch requirements..."
    python -m pip install -r "${GITHUB_WORKSPACE}/pytorch-requirements.txt" || true
fi

# Install torch nightly
echo "Installing torch nightly..."
python -m pip install --pre torch --index-url https://download.pytorch.org/whl/nightly/cpu/ || {
    echo "Warning: torch nightly installation had issues, trying stable version..."
    python -m pip install torch --index-url https://download.pytorch.org/whl/cpu/
}

# Install torchvision nightly
echo "Installing torchvision nightly..."
python -m pip install --pre torchvision --index-url https://download.pytorch.org/whl/nightly/cpu/ || {
    echo "Warning: torchvision nightly installation had issues, trying stable version..."
    python -m pip install torchvision --index-url https://download.pytorch.org/whl/cpu/ || {
        echo "Warning: torchvision installation failed, continuing anyway..."
    }
}

# Try the standard install script as additional step
if [ -f "${GITHUB_WORKSPACE}/build_tools/ci/install_python_deps.sh" ]; then
    echo "Running standard install script..."
    bash "${GITHUB_WORKSPACE}/build_tools/ci/install_python_deps.sh" nightly || {
        echo "Warning: Standard install script had issues, but continuing with manual installation..."
    }
fi

# Verify torch installation
echo "Verifying torch installation..."
python -c "import torch; print(f'PyTorch version: {torch.__version__}')" || {
    echo "Error: PyTorch installation verification failed"
    exit 1
}

echo ""

# Build project
echo "=== Building Project ==="
export cache_dir="${CACHE_DIR}"
bash "${GITHUB_WORKSPACE}/build_tools/ci/build_posix.sh"
echo ""

# Run integration tests (torch-nightly)
echo "=== Running Integration Tests (torch-nightly) ==="
bash "${GITHUB_WORKSPACE}/build_tools/ci/test_posix.sh" nightly || TEST_FAILED=1
echo ""

# Check generated sources (torch-nightly only)
echo "=== Checking Generated Sources ==="
bash "${GITHUB_WORKSPACE}/build_tools/ci/check_generated_sources.sh" || CHECK_FAILED=1
echo ""

# Report results
if [ -n "$TEST_FAILED" ] || [ -n "$CHECK_FAILED" ]; then
    echo "=== Some tests or checks failed ==="
    exit 1
fi

echo "=== All tests and checks passed ==="
exit 0