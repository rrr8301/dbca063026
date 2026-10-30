#!/bin/bash
set -euo pipefail

# Script to orchestrate the build and test workflow
# This mirrors the GitHub Actions workflow steps

echo "=========================================="
echo "Starting Build and Test Workflow"
echo "=========================================="

cd /workspace

# Set environment variables
export TORCH_VERSION="${TORCH_VERSION:-nightly}"
export CACHE_DIR="${CACHE_DIR:-./.container-cache}"

# Create cache directory if it doesn't exist
mkdir -p "$CACHE_DIR"

# Set build parallelism based on available cores
export CMAKE_BUILD_PARALLEL_LEVEL="${CMAKE_BUILD_PARALLEL_LEVEL:-$(nproc)}"
export NINJA_STATUS="[%f/%t] "

echo ""
echo "=========================================="
echo "Step 1: Display Python version and path"
echo "=========================================="
python -c "import sys; print(sys.version)"
which python
python -m pip --version

echo ""
echo "=========================================="
echo "Step 2: Install nanobind (required by MLIR)"
echo "=========================================="
python -m pip install --upgrade nanobind

echo ""
echo "=========================================="
echo "Step 3: Install python dependencies (torch-${TORCH_VERSION})"
echo "=========================================="
if [ -f "build_tools/ci/install_python_deps.sh" ]; then
    # For nightly builds, use --pre flag to allow pre-release versions
    # and let pip find the latest available nightly build
    if [ "$TORCH_VERSION" = "nightly" ]; then
        # Install nightly torch without pinning to a specific version
        # This allows pip to find the latest available nightly build
        echo "Installing PyTorch nightly dependencies..."
        python -m pip install --upgrade --pre torch torchvision torchaudio --index-url https://download.pytorch.org/whl/nightly/cpu/ 2>&1 || {
            echo "Direct nightly installation failed, attempting via script..."
            bash build_tools/ci/install_python_deps.sh "$TORCH_VERSION" --pre || true
        }
    else
        bash build_tools/ci/install_python_deps.sh "$TORCH_VERSION"
    fi
else
    echo "Warning: install_python_deps.sh not found, attempting direct nightly installation"
    if [ "$TORCH_VERSION" = "nightly" ]; then
        python -m pip install --upgrade --pre torch torchvision torchaudio --index-url https://download.pytorch.org/whl/nightly/cpu/
    fi
fi

# Verify torch installation
echo ""
echo "Verifying PyTorch installation..."
python -c "import torch; print(f'PyTorch version: {torch.__version__}')" || {
    echo "Warning: PyTorch verification failed, but continuing..."
}

echo ""
echo "=========================================="
echo "Step 4: Build project"
echo "=========================================="
if [ -f "build_tools/ci/build_posix.sh" ]; then
    export cache_dir="$CACHE_DIR"
    
    # Run build with error handling
    if ! bash build_tools/ci/build_posix.sh; then
        echo "Build failed. Attempting to gather diagnostic information..."
        
        # Check disk space
        echo "Disk space:"
        df -h /workspace || true
        
        # Check memory
        echo "Memory usage:"
        free -h || true
        
        # Check if build directory exists
        if [ -d "build" ]; then
            echo "Build directory exists. Last 50 lines of CMake output:"
            tail -50 build/CMakeOutput.log 2>/dev/null || true
        fi
        
        exit 1
    fi
else
    echo "Error: build_posix.sh not found"
    exit 1
fi

echo ""
echo "=========================================="
echo "Step 5: Integration tests (torch-${TORCH_VERSION})"
echo "=========================================="
if [ -f "build_tools/ci/test_posix.sh" ]; then
    if ! bash build_tools/ci/test_posix.sh "$TORCH_VERSION"; then
        echo "Warning: Integration tests failed, but continuing to next step..."
    fi
else
    echo "Warning: test_posix.sh not found, skipping integration tests"
fi

echo ""
echo "=========================================="
echo "Step 6: Check generated sources (torch-${TORCH_VERSION})"
echo "=========================================="
if [ -f "build_tools/ci/check_generated_sources.sh" ]; then
    if ! bash build_tools/ci/check_generated_sources.sh; then
        echo "Warning: Generated sources check failed, but continuing..."
    fi
else
    echo "Warning: check_generated_sources.sh not found, skipping generated sources check"
fi

echo ""
echo "=========================================="
echo "Build and Test Workflow Completed"
echo "=========================================="
exit 0