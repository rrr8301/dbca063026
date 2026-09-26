#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Activate Python environment
python3.12 -m venv venv
source venv/bin/activate

# Install necessary Python packages if any (e.g., pytest for testing)
# pip install -r requirements.txt

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