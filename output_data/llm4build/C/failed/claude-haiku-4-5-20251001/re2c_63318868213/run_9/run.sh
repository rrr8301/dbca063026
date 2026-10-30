#!/bin/bash

set -e

# Clone the repository (simulating actions/checkout@v6)
if [ ! -d "re2c" ]; then
    git clone https://github.com/skvadrik/re2c.git
fi

cd re2c

# Get Python location for CMake
PYTHON_LOCATION=$(python3 -c "import sys; print(sys.prefix)")

echo "=========================================="
echo "Checking Available Configure Presets"
echo "=========================================="
cmake --list-presets

echo "=========================================="
echo "Fast Configure"
echo "=========================================="
cmake --preset=linux-gcc-ubsan-ootree-fast -DPython3_ROOT_DIR="$PYTHON_LOCATION"

echo "=========================================="
echo "Fast Build"
echo "=========================================="
cmake --build --preset=linux-gcc-ubsan-ootree-fast -j$(nproc)

echo "=========================================="
echo "Install"
echo "=========================================="
cmake --build --preset=linux-gcc-ubsan-ootree-fast --target install

echo "=========================================="
echo "Minimal Install Test"
echo "=========================================="
cd ./install/bin
./re2c --version
cd ../..

echo "=========================================="
echo "Full Configure"
echo "=========================================="
cmake --preset=linux-gcc-ubsan-ootree-full -DPython3_ROOT_DIR="$PYTHON_LOCATION"

echo "=========================================="
echo "Full Build"
echo "=========================================="
find src -name '*.re' | xargs touch
cmake --build --preset=linux-gcc-ubsan-ootree-full -j$(nproc)

echo "=========================================="
echo "Run Main Test Suite"
echo "=========================================="
# Run tests with stack limit
bash -c "ulimit -s 256; cmake --build --preset=linux-gcc-ubsan-ootree-full --target tests -j$(nproc)"

echo "=========================================="
echo "All tests passed!"
echo "=========================================="
exit 0