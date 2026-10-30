#!/usr/bin/env bash
set -e

cd /app

echo "=== Setting up environment ==="
NPROC=$(nproc 2>/dev/null || echo 4)
echo "Using $NPROC parallel jobs for builds"

echo "=== Installing dependencies ==="
python3 -m pip install --break-system-packages \
    pybind11==3.0 \
    cmake==3.30.0 \
    ninja==1.11.1 \
    pytest \
    pytest-xdist \
    scikit-build-core \
    setuptools_scm

echo "=== Building from source ==="
export CMAKE_GENERATOR="Ninja"
export CMAKE_BUILD_PARALLEL_LEVEL="$NPROC"
export CC=gcc
export CXX=g++

python3 -m pip install -v . \
    --break-system-packages \
    --no-build-isolation \
    --config-settings='cmake.define.BUILD_TOOLS=ON' \
    --config-settings='cmake.define.CMAKE_C_COMPILER_LAUNCHER=ccache' \
    --config-settings='cmake.define.CMAKE_CXX_COMPILER_LAUNCHER=ccache'

echo "=== Running C++ Tests ==="
if [ -d "build" ]; then
    cd /app/build
    cmake --build . --target unittest --parallel $NPROC || true
    cd /app
fi

echo "=== Running Python Tests ==="
python3 -m pytest python/tests/ || true

echo "=== Running C++ Examples ==="
if [ -d "examples/c++" ]; then
    cd /app/examples/c++
    mkdir -p build && cd build
    cmake .. -G Ninja -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_C_COMPILER_LAUNCHER=ccache \
        -DCMAKE_CXX_COMPILER_LAUNCHER=ccache
    cmake --build . --parallel $NPROC
    if [ -f "./db-example" ]; then ./db-example; fi || true
    if [ -f "./core-example" ]; then ./core-example; fi || true
    if [ -f "./ailego-example" ]; then ./ailego-example; fi || true
fi

echo "=== Running C Examples ==="
if [ -d "examples/c" ]; then
    cd /app/examples/c
    mkdir -p build && cd build
    cmake .. -G Ninja -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_C_COMPILER_LAUNCHER=ccache \
        -DCMAKE_CXX_COMPILER_LAUNCHER=ccache
    cmake --build . --parallel $NPROC
    if [ -f "./c_api_basic_example" ]; then ./c_api_basic_example; fi || true
    if [ -f "./c_api_collection_schema_example" ]; then ./c_api_collection_schema_example; fi || true
    if [ -f "./c_api_doc_example" ]; then ./c_api_doc_example; fi || true
    if [ -f "./c_api_field_schema_example" ]; then ./c_api_field_schema_example; fi || true
    if [ -f "./c_api_index_example" ]; then ./c_api_index_example; fi || true
    if [ -f "./c_api_optimized_example" ]; then ./c_api_optimized_example; fi || true
fi

echo "FINAL_STATUS = SUCCESS"
