#!/bin/bash

# Activate Python environment (if any specific activation is needed)
# source /path/to/venv/bin/activate

# Install project dependencies (if any additional are needed)
# pip install -r requirements.txt

# Check available configure presets
cmake --list-presets

# Fast configure
cmake --preset=linux-gcc-ubsan-ootree-fast -DPython3_ROOT_DIR=$(python3 -c "import sys; print(sys.prefix)")

# Fast build
cmake --build --preset=linux-gcc-ubsan-ootree-fast -j$(nproc)

# Install
cmake --build --preset=linux-gcc-ubsan-ootree-fast --target install

# Minimal install test
cd ./install/bin
./re2c --version
cd -

# Full configure
cmake --preset=linux-gcc-ubsan-ootree-full -DPython3_ROOT_DIR=$(python3 -c "import sys; print(sys.prefix)")

# Full build
find src -name '*.re' | xargs touch
cmake --build --preset=linux-gcc-ubsan-ootree-full -j$(nproc)

# Run main test suite
ulimit -s 256
cmake --build --preset=linux-gcc-ubsan-ootree-full --target tests -j$(nproc)

# Ensure all tests are executed
set +e
# Add any additional test commands here
set -e