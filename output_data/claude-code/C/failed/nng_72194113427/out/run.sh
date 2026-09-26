#!/usr/bin/env bash

set -e

cd /app

# Configure
mkdir -p build.wolf
cd build.wolf
cmake -G Ninja \
  -DCMAKE_BUILD_TYPE=Debug \
  -DNNG_ENABLE_TLS=ON \
  -DNNG_POLLQ_POLLER=poll \
  -DNNG_TLS_ENGINE=wolf \
  ..

# Build
ninja

# Test
ctest --output-on-failure

echo "FINAL_STATUS = SUCCESS"
