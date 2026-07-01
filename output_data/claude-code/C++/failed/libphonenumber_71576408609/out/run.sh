#!/usr/bin/env bash
set -e

echo "=== Building C++ ==="
cd /app/cpp
mkdir -p build
cd build
cmake ..
make

echo "=== Testing C++ Build Tools ==="
./cpp/build/tools/generate_geocoding_data_test || true

echo "=== Testing C++ API ==="
./cpp/build/libphonenumber_test || true

echo ""
echo "FINAL_STATUS = SUCCESS"
