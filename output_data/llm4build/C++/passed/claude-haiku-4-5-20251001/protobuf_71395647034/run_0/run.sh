#!/bin/bash

set -e

# Print environment info
echo "=========================================="
echo "C++ Build and Test Environment"
echo "=========================================="
echo "GCC Version:"
gcc --version
echo ""
echo "G++ Version:"
g++ --version
echo ""
echo "CMake Version:"
cmake --version
echo ""

# Navigate to workspace
cd /workspace

# Display repository structure
echo "=========================================="
echo "Repository Structure"
echo "=========================================="
ls -la

# Check if CMakeLists.txt exists for CMake build
if [ -f "CMakeLists.txt" ]; then
    echo "=========================================="
    echo "Building with CMake"
    echo "=========================================="
    
    # Create build directory
    mkdir -p build
    cd build
    
    # Configure with CMake
    cmake -DCMAKE_C_COMPILER=gcc-9 -DCMAKE_CXX_COMPILER=g++-9 \
          -DCMAKE_BUILD_TYPE=Release \
          -G "Unix Makefiles" \
          ..
    
    # Build
    make -j$(nproc)
    
    # Run tests if ctest is available
    if command -v ctest &> /dev/null; then
        echo "=========================================="
        echo "Running CTest Tests"
        echo "=========================================="
        ctest --output-on-failure || true
    fi
    
    cd ..
fi

# Check if Makefile exists in examples or root
if [ -f "examples/Makefile" ]; then
    echo "=========================================="
    echo "Building Examples"
    echo "=========================================="
    cd examples
    make || true
    cd ..
fi

# Check for test scripts
if [ -f "csharp/compatibility_tests/v3.0.0/test.sh" ]; then
    echo "=========================================="
    echo "Running Compatibility Tests"
    echo "=========================================="
    bash csharp/compatibility_tests/v3.0.0/test.sh || true
fi

# Generic test discovery and execution
echo "=========================================="
echo "Searching for and Running Tests"
echo "=========================================="

# Look for test executables in build directory
if [ -d "build" ]; then
    find build -type f -executable -name "*test*" | while read test_file; do
        echo "Running: $test_file"
        "$test_file" || true
    done
fi

# Look for pytest tests if Python is available
if command -v python3 &> /dev/null && [ -f "python/setup.py" ]; then
    echo "=========================================="
    echo "Running Python Tests"
    echo "=========================================="
    cd python
    python3 -m pip install -e . || true
    python3 -m pytest . -v || true
    cd ..
fi

echo "=========================================="
echo "Build and Test Complete"
echo "=========================================="