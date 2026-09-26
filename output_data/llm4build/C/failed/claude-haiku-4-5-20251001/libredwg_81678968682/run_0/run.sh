#!/bin/bash
set -e

# Enable ccache
export PATH="/usr/lib/ccache:$PATH"

# Create ccache symlinks if not already present
if [ ! -L /usr/lib/ccache/gcc ]; then
    sudo ln -sf /usr/bin/gcc /usr/lib/ccache/gcc || true
fi
if [ ! -L /usr/lib/ccache/g++ ]; then
    sudo ln -sf /usr/bin/g++ /usr/lib/ccache/g++ || true
fi
if [ ! -L /usr/lib/ccache/cc ]; then
    sudo ln -sf /usr/bin/cc /usr/lib/ccache/cc || true
fi
if [ ! -L /usr/lib/ccache/c++ ]; then
    sudo ln -sf /usr/bin/c++ /usr/lib/ccache/c++ || true
fi

# Initialize submodules (in case they weren't cloned recursively)
cd /workspace
git submodule update --init --recursive || true

# Configure CMake with libonly flag and ccache compiler launcher
cmake -DLIBREDWG_LIBONLY=On -DCMAKE_C_COMPILER_LAUNCHER=ccache .

# Build with parallel jobs
make -j

# Run tests with parallel jobs
make -j test

# On failure, create debug tarball (for local inspection)
if [ $? -ne 0 ]; then
    tar cfz cmake-failure.tgz Testing/Temporary/LastTest.log src/config.h || true
    echo "Test failure detected. Debug tarball created at cmake-failure.tgz"
    exit 1
fi