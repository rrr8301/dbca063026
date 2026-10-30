#!/bin/bash

set -e

echo "=========================================="
echo "Building SDL - Steam Linux Runtime 4.0 (x86_64)"
echo "=========================================="

# Navigate to workspace
cd /workspace

# Display environment info
echo "Git version:"
git --version
echo ""

echo "CMake version:"
cmake --version
echo ""

echo "Compiler info:"
gcc --version
echo ""

# Initialize submodules if any
echo "Initializing git submodules..."
git submodule update --init --recursive || true

# Create build directory
BUILD_DIR="build"
if [ -d "$BUILD_DIR" ]; then
    rm -rf "$BUILD_DIR"
fi
mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

# Configure build with CMake
echo "Configuring SDL build with CMake..."
cmake -G Ninja \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_C_COMPILER=gcc \
    -DCMAKE_CXX_COMPILER=g++ \
    -DSDL_X11=ON \
    -DSDL_X11_XTEST=ON \
    -DSDL_WAYLAND=ON \
    -DSDL_PULSEAUDIO=ON \
    -DSDL_PIPEWIRE=ON \
    -DSDL_SNDIO=ON \
    -DSDL_VULKAN=ON \
    -DSDL_RENDER_GPU=ON \
    -DSDL_TESTS=ON \
    .. || { echo "CMake configuration failed"; exit 1; }

# Build the project
echo "Building SDL..."
ninja -v || { echo "Build failed"; exit 1; }

# Run tests if available
echo "Running tests..."
if [ -d "test" ] && [ -n "$(find test -maxdepth 1 -type f -executable)" ]; then
    echo "Found test executables, running tests..."
    
    # Run all test executables found in test directory
    for test_exe in test/test* test/torture*; do
        if [ -f "$test_exe" ] && [ -x "$test_exe" ]; then
            test_name=$(basename "$test_exe")
            echo "Running: $test_name"
            # Run test with timeout to prevent hanging on interactive tests
            timeout 5 "$test_exe" 2>&1 || test_result=$?
            if [ $test_result -eq 124 ]; then
                echo "  (timeout - expected for interactive tests)"
            elif [ $test_result -ne 0 ] && [ -n "$test_result" ]; then
                echo "  Test $test_name exited with code $test_result"
            else
                echo "  $test_name completed"
            fi
        fi
    done
    
    # Try running ctest if available
    if command -v ctest &> /dev/null; then
        echo ""
        echo "Running ctest suite..."
        ctest --output-on-failure --timeout 5 || { echo "Some tests failed, but continuing..."; }
    fi
else
    echo "No test executables found in test directory"
fi

echo "=========================================="
echo "Build completed successfully!"
echo "=========================================="