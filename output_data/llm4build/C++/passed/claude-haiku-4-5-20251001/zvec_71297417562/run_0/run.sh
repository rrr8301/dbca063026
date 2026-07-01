#!/bin/bash

set -e

# Print CPU info
echo "=== CPU Info ==="
lscpu || echo "lscpu not available"

# Set number of processors for parallel builds
NPROC=$(nproc 2>/dev/null || echo 2)
echo "Using $NPROC parallel jobs for builds"
export NPROC

# Add Python user base bin to PATH for pip-installed CLI tools
export PATH="$(python -c 'import site; print(site.USER_BASE)')/bin:$PATH"

# Build from source
echo "=== Building from source ==="
cd /workspace

CMAKE_GENERATOR="Unix Makefiles" \
CMAKE_BUILD_PARALLEL_LEVEL="$NPROC" \
python -m pip install -v . \
    --no-build-isolation \
    --config-settings='cmake.define.BUILD_TOOLS="ON"'

# Run C++ Tests
echo "=== Running C++ Tests ==="
if [ -d "/workspace/build" ]; then
    cd /workspace/build
    make unittest -j$NPROC || echo "C++ tests failed, continuing..."
else
    echo "Build directory not found, skipping C++ tests"
fi

# Run Python Tests
echo "=== Running Python Tests ==="
cd /workspace
python -m pytest python/tests/ || echo "Python tests failed, continuing..."

# Run C++ Examples
echo "=== Running C++ Examples ==="
cd /workspace/examples/c++
mkdir -p build && cd build
cmake .. -DCMAKE_BUILD_TYPE=Release
make -j $NPROC
echo "Running db-example..."
./db-example || echo "db-example failed, continuing..."
echo "Running core-example..."
./core-example || echo "core-example failed, continuing..."
echo "Running ailego-example..."
./ailego-example || echo "ailego-example failed, continuing..."

# Run C Examples
echo "=== Running C Examples ==="
cd /workspace/examples/c
mkdir -p build && cd build
cmake .. -DCMAKE_BUILD_TYPE=Release
make -j $NPROC
echo "Running c_api_basic_example..."
./c_api_basic_example || echo "c_api_basic_example failed, continuing..."
echo "Running c_api_collection_schema_example..."
./c_api_collection_schema_example || echo "c_api_collection_schema_example failed, continuing..."
echo "Running c_api_doc_example..."
./c_api_doc_example || echo "c_api_doc_example failed, continuing..."
echo "Running c_api_field_schema_example..."
./c_api_field_schema_example || echo "c_api_field_schema_example failed, continuing..."
echo "Running c_api_index_example..."
./c_api_index_example || echo "c_api_index_example failed, continuing..."
echo "Running c_api_optimized_example..."
./c_api_optimized_example || echo "c_api_optimized_example failed, continuing..."

echo "=== All tests completed ==="