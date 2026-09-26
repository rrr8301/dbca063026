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

echo ""
echo "=========================================="
echo "Step 1: Display Python version and path"
echo "=========================================="
python -c "import sys; print(sys.version)"
which python

echo ""
echo "=========================================="
echo "Step 2: Install python dependencies (torch-${TORCH_VERSION})"
echo "=========================================="
if [ -f "build_tools/ci/install_python_deps.sh" ]; then
    # For nightly builds, use --pre flag to allow pre-release versions
    # and let pip find the latest available nightly build
    if [ "$TORCH_VERSION" = "nightly" ]; then
        # Install nightly torch without pinning to a specific version
        # This allows pip to find the latest available nightly build
        python -m pip install --upgrade --pre torch torchvision torchaudio --index-url https://download.pytorch.org/whl/nightly/cpu/ || \
        bash build_tools/ci/install_python_deps.sh "$TORCH_VERSION" --pre
    else
        bash build_tools/ci/install_python_deps.sh "$TORCH_VERSION"
    fi
else
    echo "Warning: install_python_deps.sh not found, attempting direct nightly installation"
    if [ "$TORCH_VERSION" = "nightly" ]; then
        python -m pip install --upgrade --pre torch torchvision torchaudio --index-url https://download.pytorch.org/whl/nightly/cpu/
    fi
fi

echo ""
echo "=========================================="
echo "Step 3: Build project"
echo "=========================================="
if [ -f "build_tools/ci/build_posix.sh" ]; then
    export cache_dir="$CACHE_DIR"
    bash build_tools/ci/build_posix.sh
else
    echo "Error: build_posix.sh not found"
    exit 1
fi

echo ""
echo "=========================================="
echo "Step 4: Integration tests (torch-${TORCH_VERSION})"
echo "=========================================="
if [ -f "build_tools/ci/test_posix.sh" ]; then
    bash build_tools/ci/test_posix.sh "$TORCH_VERSION"
else
    echo "Warning: test_posix.sh not found, skipping integration tests"
fi

echo ""
echo "=========================================="
echo "Step 5: Check generated sources (torch-${TORCH_VERSION})"
echo "=========================================="
if [ -f "build_tools/ci/check_generated_sources.sh" ]; then
    bash build_tools/ci/check_generated_sources.sh
else
    echo "Warning: check_generated_sources.sh not found, skipping generated sources check"
fi

echo ""
echo "=========================================="
echo "Build and Test Workflow Completed Successfully"
echo "=========================================="
exit 0