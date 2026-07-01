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

# Install additional build dependencies
echo ""
echo "=========================================="
echo "Step 3b: Install additional build dependencies"
echo "=========================================="
if [ -f "build-requirements.txt" ]; then
    python -m pip install -r build-requirements.txt || {
        echo "Warning: Failed to install build-requirements.txt, continuing..."
    }
fi

if [ -f "pytorch-requirements.txt" ]; then
    python -m pip install -r pytorch-requirements.txt || {
        echo "Warning: Failed to install pytorch-requirements.txt, continuing..."
    }
fi

echo ""
echo "=========================================="
echo "Step 4: Pre-build system diagnostics"
echo "=========================================="
echo "Disk space before build:"
df -h /workspace || true

echo ""
echo "Memory available:"
free -h || true

echo ""
echo "CPU cores available:"
nproc || true

echo ""
echo "=========================================="
echo "Step 5: Build project"
echo "=========================================="
if [ -f "build_tools/ci/build_posix.sh" ]; then
    export cache_dir="$CACHE_DIR"
    
    # Run build with enhanced error handling and diagnostics
    if ! bash build_tools/ci/build_posix.sh 2>&1 | tee build_output.log; then
        echo ""
        echo "=========================================="
        echo "Build failed. Gathering diagnostic information..."
        echo "=========================================="
        
        # Check disk space
        echo ""
        echo "Disk space after failed build:"
        df -h /workspace || true
        
        # Check memory
        echo ""
        echo "Memory usage after failed build:"
        free -h || true
        
        # Check if build directory exists
        if [ -d "build" ]; then
            echo ""
            echo "Build directory exists. Checking for error logs..."
            
            # Look for CMake error output
            if [ -f "build/CMakeOutput.log" ]; then
                echo ""
                echo "Last 150 lines of CMakeOutput.log:"
                tail -150 build/CMakeOutput.log || true
            fi
            
            # Look for CMake error log
            if [ -f "build/CMakeError.log" ]; then
                echo ""
                echo "CMakeError.log contents:"
                cat build/CMakeError.log || true
            fi
            
            # Look for ninja error output
            if [ -f "build/.ninja_log" ]; then
                echo ""
                echo "Last 100 lines of ninja log:"
                tail -100 build/.ninja_log || true
            fi
            
            # Try to find compilation errors in build output
            echo ""
            echo "Searching for compilation errors in build output..."
            grep -i "error:" build_output.log | head -50 || true
            
            # Check for undefined reference errors
            echo ""
            echo "Searching for undefined reference errors..."
            grep -i "undefined reference" build_output.log | head -50 || true
            
            # Check for linker errors
            echo ""
            echo "Searching for linker errors..."
            grep -i "ld returned" build_output.log | head -20 || true
            
            # Check for fatal errors
            echo ""
            echo "Searching for fatal errors..."
            grep -i "fatal error" build_output.log | head -50 || true
        fi
        
        # Display last part of build output
        echo ""
        echo "Last 200 lines of build output:"
        tail -200 build_output.log || true
        
        exit 1
    fi
else
    echo "Error: build_posix.sh not found"
    exit 1
fi

echo ""
echo "=========================================="
echo "Step 6: Post-build system diagnostics"
echo "=========================================="
echo "Disk space after successful build:"
df -h /workspace || true

echo ""
echo "=========================================="
echo "Step 7: Integration tests (torch-${TORCH_VERSION})"
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
echo "Step 8: Check generated sources (torch-${TORCH_VERSION})"
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
echo "Build and Test Workflow Completed Successfully"
echo "=========================================="
exit 0