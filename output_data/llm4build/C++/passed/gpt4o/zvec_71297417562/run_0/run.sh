#!/bin/bash

# Activate Python environment
export PATH="/usr/local/bin:$PATH"

# Set number of processors for parallel builds
NPROC=$(nproc 2>/dev/null || echo 2)
echo "Using $NPROC parallel jobs for builds"

# Build from source
cd /app
CMAKE_GENERATOR="Unix Makefiles" \
CMAKE_BUILD_PARALLEL_LEVEL="$NPROC" \
python3.10 -m pip install -v . \
  --no-build-isolation \
  --config-settings='cmake.define.BUILD_TOOLS="ON"'

# Run C++ Tests
cd /app/build
make unittest -j$NPROC || true

# Run Python Tests
cd /app
python3.10 -m pytest python/tests/ || true

# Run C++ Examples
cd /app/examples/c++
mkdir build && cd build
cmake .. -DCMAKE_BUILD_TYPE=Release
make -j $NPROC
./db-example || true
./core-example || true
./ailego-example || true

# Run C Examples
cd /app/examples/c
mkdir build && cd build
cmake .. -DCMAKE_BUILD_TYPE=Release
make -j $NPROC
./c_api_basic_example || true
./c_api_collection_schema_example || true
./c_api_doc_example || true
./c_api_field_schema_example || true
./c_api_index_example || true
./c_api_optimized_example || true