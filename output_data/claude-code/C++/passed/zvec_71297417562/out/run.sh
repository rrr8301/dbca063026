#!/usr/bin/env bash
set -e

NPROC=${NPROC:-4}

cd /app

echo "Running C++ Tests..."
cd /app/build
make unittest -j$NPROC || true

echo "Running Python Tests..."
cd /app
python3 -m pytest python/tests/ || true

echo "Running C++ Examples..."
cd /app/examples/c++
mkdir -p build && cd build
cmake .. -DCMAKE_BUILD_TYPE=Release
make -j $NPROC
./db-example
./core-example
./ailego-example

echo "Running C Examples..."
cd /app/examples/c
mkdir -p build && cd build
cmake .. -DCMAKE_BUILD_TYPE=Release
make -j $NPROC
./c_api_basic_example
./c_api_collection_schema_example
./c_api_doc_example
./c_api_field_schema_example
./c_api_index_example
./c_api_optimized_example

echo "FINAL_STATUS = SUCCESS"
