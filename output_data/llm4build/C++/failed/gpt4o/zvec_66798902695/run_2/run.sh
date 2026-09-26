#!/bin/bash

# Set up environment variables
NPROC=$(nproc 2>/dev/null || echo 2)
echo "Using $NPROC parallel jobs for builds"

# Build from source
cd /app
CMAKE_GENERATOR="Unix Makefiles" \
CMAKE_BUILD_PARALLEL_LEVEL="$NPROC" \
python3 -m pip install -v . \
  --no-build-isolation \
  --config-settings='cmake.define.BUILD_TOOLS="ON"'

# Run C++ Tests
cd /app/build
make unittest -j$NPROC || true

# Run Python Tests
cd /app
python3 -m pytest python/tests/ || true

# Run C++ Examples
cd /app/examples/c++
mkdir build && cd build
cmake .. -DCMAKE_BUILD_TYPE=Release
make -j $NPROC || true
./db-example || true
./core-example || true
./ailego-example || true