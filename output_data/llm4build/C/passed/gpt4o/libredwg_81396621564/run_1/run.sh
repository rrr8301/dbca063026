#!/bin/bash

# Activate Python environment
python3.12 -m venv venv
source venv/bin/activate

# Configure ccache
export CCACHE_DIR=/workspace/.ccache
ccache --set-config=cache_dir=$CCACHE_DIR
ccache --zero-stats

# Run cmake
cmake -DLIBREDWG_LIBONLY=On -DCMAKE_C_COMPILER_LAUNCHER=ccache .

# Build the project
make -j

# Run tests
make -j test