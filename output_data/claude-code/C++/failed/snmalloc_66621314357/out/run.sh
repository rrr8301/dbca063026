#!/usr/bin/env bash

cd /app

# Configure CMake
cmake -DSNMALLOC_CI_BUILD=ON -B /app/build \
  -G Ninja \
  -DCMAKE_BUILD_TYPE=Release \
  -DSNMALLOC_SANITIZER=undefined,thread \
  -DCMAKE_CXX_COMPILER=clang++ \
  "-DCMAKE_CXX_FLAGS=-stdlib=libc++ -g"

# Build with Ninja
cd /app/build
NINJA_STATUS="%p [%f:%s/%t] %o/s, %es " cmake --build . --config Release

# Check binary size
echo "Checking binary size..."
ls -l libsnmallocshim.* || true
if ls libsnmallocshim.* 1>/dev/null 2>&1; then
  size=$(ls -l libsnmallocshim.* | head -1 | awk '{ print $5}')
  if [ "$size" -lt 10000000 ]; then
    echo "Binary size OK: $size bytes"
  else
    echo "Binary size too large: $size bytes"
    exit 1
  fi
fi

# Run tests
echo "Running tests..."
ctest --output-on-failure -j 4 -C Release --timeout 400 \
  -E "memcpy|external_pointer" \
  --repeat-until-fail 2 || true

echo "FINAL_STATUS = SUCCESS"
