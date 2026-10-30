#!/bin/bash
set -e

# Initialize git submodules
git submodule update --init --recursive

# Configure CMake with libonly flag and ccache launcher
cmake -DLIBREDWG_LIBONLY=On -DCMAKE_C_COMPILER_LAUNCHER=ccache .

# Build with parallel jobs
make -j

# Run tests with parallel jobs
make -j test