#!/bin/bash

set -e

# Enable error handling - continue on test failures but track them
TESTS_FAILED=0
BUILD_FAILED=0

# Setup environment variables
export GITHUB_WORKSPACE="/workspace"
export CACHE_DIR="${GITHUB_WORKSPACE}/.container-cache"
export TORCH_VERSION="nightly"

# Create cache directory
mkdir -p "${CACHE_DIR}"

# Configure ccache with optimized settings
echo "Configuring ccache..."
rm -rf "${GITHUB_WORKSPACE}/.ccache" || true
mkdir -p "${GITHUB_WORKSPACE}/.ccache"
ccache --set-config "cache_dir=${GITHUB_WORKSPACE}/.ccache"
ccache --set-config "compression=true"
ccache --set-config "max_size=5G"
ccache --set-config "sloppiness=time_macros"
ccache --zero-stats

# Display Python version and path
echo "=== Python Information ==="
python -c "import sys; print(sys.version)"
which python
echo ""

# Display system information
echo "=== System Information ==="
uname -a
df -h
free -h
echo ""

# Install Python dependencies for torch-nightly
echo "=== Installing Python Dependencies (torch-nightly) ==="
cd "${GITHUB_WORKSPACE}"

# Try to install using the standard script first
if [ -f "build_tools/ci/install_python_deps.sh" ]; then
    # Attempt to run the script, but if it fails due to version mismatch, 
    # fall back to installing latest nightly
    if ! bash build_tools/ci/install_python_deps.sh nightly; then
        echo "Warning: Standard install script failed, attempting to install latest PyTorch nightly..."
        python -m pip install --upgrade pip setuptools wheel
        python -m pip install --pre torch --index-url https://download.pytorch.org/whl/nightly/cpu/ || {
            echo "Error: Failed to install PyTorch nightly"
            exit 1
        }
        # Install other dependencies if requirements files exist
        if [ -f "pytorch-requirements.txt" ]; then
            python -m pip install -r pytorch-requirements.txt || true
        fi
        if [ -f "build-requirements.txt" ]; then
            python -m pip install -r build-requirements.txt || true
        fi
    fi
else
    echo "Error: install_python_deps.sh not found"
    exit 1
fi

# Install additional Python dependencies required for testing
echo "=== Installing Additional Test Dependencies ==="
python -m pip install --upgrade pip setuptools wheel
python -m pip install multiprocess || {
    echo "Warning: Failed to install multiprocess, attempting alternative..."
    python -m pip install multiprocessing-logging || true
}
echo ""

# Verify Python dependencies
echo "=== Verifying Python Dependencies ==="
python -c "import torch; print(f'PyTorch version: {torch.__version__}')" || {
    echo "Warning: PyTorch import failed, but continuing..."
}
python -c "import multiprocess; print('multiprocess module available')" || {
    echo "Warning: multiprocess module not available, tests may fail..."
}
echo ""

# Update generated sources BEFORE building
echo "=== Updating Generated Sources ==="
if [ -f "build_tools/update_abstract_interp_lib.sh" ]; then
    chmod +x "build_tools/update_abstract_interp_lib.sh"
    if ! bash build_tools/update_abstract_interp_lib.sh 2>&1 | tee update_sources.log; then
        echo "Warning: Failed to update abstract interp lib"
        tail -100 update_sources.log || true
    fi
else
    echo "Warning: update_abstract_interp_lib.sh not found, skipping source update"
fi
echo ""

# Build project with enhanced error reporting
echo "=== Building Project ==="
export cache_dir="${CACHE_DIR}"

if [ -f "build_tools/ci/build_posix.sh" ]; then
    # Ensure build script has execute permissions
    chmod +x "build_tools/ci/build_posix.sh"
    
    # Run build with verbose output and capture errors
    if ! bash build_tools/ci/build_posix.sh 2>&1 | tee build.log; then
        echo ""
        echo "ERROR: Build failed!"
        echo ""
        echo "=== Searching for actual compilation errors in build log ==="
        grep -i "error:" build.log | head -50 || true
        echo ""
        echo "=== Searching for undefined reference errors ==="
        grep -i "undefined reference\|cannot find" build.log | head -50 || true
        echo ""
        echo "=== Searching for linker errors ==="
        grep -i "ld returned\|collect2:" build.log | head -50 || true
        echo ""
        echo "=== Last 500 lines of build output ==="
        tail -500 build.log
        echo ""
        echo "=== Searching for ninja errors ==="
        grep -B 10 "ninja: build stopped" build.log | tail -50 || true
        echo ""
        echo "=== ccache Statistics at failure ==="
        ccache --show-stats || true
        BUILD_FAILED=1
        # Exit immediately on build failure
        exit 1
    fi
    
    # Additional check: verify build completed successfully
    if grep -q "ninja: build stopped" build.log; then
        echo ""
        echo "ERROR: Ninja build was interrupted!"
        echo ""
        echo "=== Searching for actual compilation errors ==="
        grep -i "error:" build.log | head -50 || true
        echo ""
        echo "=== Build log excerpt around failure ==="
        grep -B 30 "ninja: build stopped" build.log | tail -50
        echo ""
        BUILD_FAILED=1
        exit 1
    fi
else
    echo "Error: build_posix.sh not found"
    exit 1
fi
echo ""

# Verify build artifacts exist
echo "=== Verifying Build Artifacts ==="
if [ ! -d "${GITHUB_WORKSPACE}/build" ]; then
    echo "Error: Build directory not found at ${GITHUB_WORKSPACE}/build"
    exit 1
fi

# Check for critical MLIR libraries
MLIR_LIB_DIR="${GITHUB_WORKSPACE}/build/tools/torch-mlir/python_packages/torch_mlir/torch_mlir/_mlir_libs"
if [ ! -d "${MLIR_LIB_DIR}" ]; then
    echo "Error: MLIR libs directory not found at ${MLIR_LIB_DIR}"
    echo "Build artifacts may be incomplete"
    ls -la "${GITHUB_WORKSPACE}/build/tools/torch-mlir/python_packages/torch_mlir/torch_mlir/" || true
    exit 1
fi

# Verify critical MLIR library files exist
if [ ! -f "${MLIR_LIB_DIR}/_mlir.cpython-311-x86_64-linux-gnu.so" ] && \
   [ ! -f "${MLIR_LIB_DIR}/_mlir.so" ]; then
    echo "Error: MLIR core library (_mlir.so) not found in ${MLIR_LIB_DIR}"
    echo "Available files:"
    ls -la "${MLIR_LIB_DIR}/" || true
    exit 1
fi

echo "Build artifacts verified successfully"
echo ""

# Print ccache statistics after build
echo "=== ccache Statistics (Post-Build) ==="
ccache --show-stats
echo ""

# Integration tests (torch-nightly)
echo "=== Running Integration Tests (torch-nightly) ==="
if [ -f "build_tools/ci/test_posix.sh" ]; then
    # Ensure test script has execute permissions
    chmod +x "build_tools/ci/test_posix.sh"
    
    if ! bash build_tools/ci/test_posix.sh nightly 2>&1 | tee test.log; then
        echo "Warning: Integration tests failed"
        echo "Last 150 lines of test output:"
        tail -150 test.log
        TESTS_FAILED=1
    fi
else
    echo "Error: test_posix.sh not found"
    TESTS_FAILED=1
fi
echo ""

# Check generated sources (torch-nightly only) - verify they match after build
echo "=== Checking Generated Sources (torch-nightly) ==="
if [ -f "build_tools/ci/check_generated_sources.sh" ]; then
    # Ensure check script has execute permissions
    chmod +x "build_tools/ci/check_generated_sources.sh"
    
    # Also ensure the update script has execute permissions
    if [ -f "build_tools/update_abstract_interp_lib.sh" ]; then
        chmod +x "build_tools/update_abstract_interp_lib.sh"
    fi
    
    if ! bash build_tools/ci/check_generated_sources.sh 2>&1 | tee check_sources.log; then
        echo "Warning: Generated sources check failed"
        echo "Last 150 lines of check output:"
        tail -150 check_sources.log
        TESTS_FAILED=1
    fi
else
    echo "Error: check_generated_sources.sh not found"
    TESTS_FAILED=1
fi
echo ""

# Print final ccache statistics
echo "=== Final ccache Statistics ==="
ccache --show-stats
echo ""

# Print summary
echo "=== Build Summary ==="
echo "Build workspace: ${GITHUB_WORKSPACE}"
echo "Cache directory: ${CACHE_DIR}"
echo "Torch version: ${TORCH_VERSION}"
echo "Build status: $([ $BUILD_FAILED -eq 0 ] && echo 'SUCCESS' || echo 'FAILED')"
echo "Tests status: $([ $TESTS_FAILED -eq 0 ] && echo 'SUCCESS' || echo 'FAILED')"
echo ""

# Exit with appropriate code
if [ $BUILD_FAILED -eq 1 ]; then
    echo "Build failed. See output above for details."
    exit 1
fi

if [ $TESTS_FAILED -eq 1 ]; then
    echo "Some tests failed. See output above for details."
    exit 1
fi

echo "=== All tests completed successfully ==="
exit 0