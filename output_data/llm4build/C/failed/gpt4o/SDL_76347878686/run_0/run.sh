#!/bin/bash

# Activate Python environment
# source /path/to/venv/bin/activate

# Install project dependencies
# Assuming dependencies are managed by a requirements.txt or similar
# pip install -r requirements.txt

# Configure and build using CMake
cmake -S . -B build -G "Unix Makefiles" \
    -Wdeprecated -Wdev -Werror \
    -DSDL_WERROR=ON \
    -DSDL_EXAMPLES=ON \
    -DSDL_TESTS=ON \
    -DSDLTEST_TRACKMEM=ON \
    -DSDL_INSTALL_TESTS=ON \
    -DSDL_CLANG_TIDY=OFF \
    -DSDL_INSTALL_DOCS=ON \
    -DSDL_INSTALL_CPACK=ON \
    -DSDL_SHARED=ON \
    -DSDL_STATIC=OFF \
    -DSDL_VENDOR_INFO="Github Workflow" \
    -DCMAKE_INSTALL_PREFIX=prefix \
    -DCMAKE_INSTALL_LIBDIR=lib \
    -DCMAKE_BUILD_TYPE=Release

# Build the project
cmake --build build --config Release --verbose

# Run build-time tests
export SDL_TESTS_QUICK=1
ctest --test-dir build/ -VV -j2

# Install the project
cmake --install build --config Release

# Package the project
cmake --build build/ --config Release --target package