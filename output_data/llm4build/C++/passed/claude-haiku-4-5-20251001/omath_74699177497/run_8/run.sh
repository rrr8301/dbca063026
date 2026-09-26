#!/bin/bash
set -e

# Set environment variables
export VCPKG_ROOT="${VCPKG_ROOT:-/workspace/vcpkg}"
export WORKSPACE="${WORKSPACE:-/workspace}"

# Determine if repository is already checked out
REPO_DIR=""

# Check multiple possible locations for the repository
if [ -d "/workspace/.git" ]; then
    echo "Found repository at /workspace"
    REPO_DIR="/workspace"
elif [ -d "/workspace/repo/.git" ]; then
    echo "Found repository at /workspace/repo"
    REPO_DIR="/workspace/repo"
elif [ -d ".git" ]; then
    echo "Repository already checked out at $(pwd)"
    REPO_DIR="$(pwd)"
else
    # If no repository found, check for CMake project files
    if [ -f "/workspace/CMakeLists.txt" ] || [ -f "/workspace/CMakePresets.json" ]; then
        echo "Found CMake project files in /workspace, assuming repository is mounted here"
        REPO_DIR="/workspace"
    elif [ -f "CMakeLists.txt" ] || [ -f "CMakePresets.json" ]; then
        echo "Found CMake project files in current directory"
        REPO_DIR="$(pwd)"
    else
        echo "Error: Repository not found and no CMake project files detected."
        echo "Expected one of:"
        echo "  - Repository mounted at /workspace with .git directory"
        echo "  - Repository mounted at /workspace/repo with .git directory"
        echo "  - Repository in current working directory with .git"
        echo "  - CMake project files (CMakeLists.txt or CMakePresets.json) in /workspace or current directory"
        echo ""
        echo "Current directory: $(pwd)"
        echo "Contents of /workspace:"
        ls -la /workspace/ || echo "  (directory not accessible)"
        exit 1
    fi
fi

# Change to repository directory
cd "$REPO_DIR"
echo "Working directory: $(pwd)"

# Verify we have the necessary files
if [ ! -f "CMakeLists.txt" ] && [ ! -f "CMakePresets.json" ]; then
    echo "Error: CMakeLists.txt or CMakePresets.json not found in $REPO_DIR"
    echo "Contents of $REPO_DIR:"
    ls -la "$REPO_DIR"
    exit 1
fi

# Set up vcpkg
if [ ! -d "$VCPKG_ROOT" ]; then
    echo "Setting up vcpkg..."
    git clone https://github.com/microsoft/vcpkg "$VCPKG_ROOT"
    cd "$VCPKG_ROOT"
    ./bootstrap-vcpkg.sh
    cd "$REPO_DIR"
else
    echo "vcpkg already set up at $VCPKG_ROOT"
fi

# Configure with CMake preset
echo "Configuring CMake..."
cmake --preset linux-release-vcpkg-x86 \
    -DVCPKG_INSTALL_OPTIONS="--allow-unsupported" \
    -DOMATH_BUILD_TESTS=ON \
    -DOMATH_BUILD_BENCHMARK=OFF \
    -DOMATH_ENABLE_COVERAGE=OFF \
    -DVCPKG_MANIFEST_FEATURES="imgui;avx2;tests;lua"

# Build
echo "Building..."
cmake --build cmake-build/build/linux-release-vcpkg-x86 --target unit_tests omath

# Run unit tests
echo "Running unit tests..."
./out/Release/unit_tests

echo "All tests completed successfully!"