#!/bin/bash

# Clone the repository (simulating actions/checkout)
git clone https://github.com/your/repo.git /workspace
cd /workspace

# Install project dependencies
sudo apt install -y ninja-build libc++-dev

# Configure CMake
cmake -DSNMALLOC_CI_BUILD=ON -B build -G Ninja \
      -DSNMALLOC_SANITIZER=undefined,thread \
      -DCMAKE_CXX_COMPILER=clang++ \
      -DCMAKE_CXX_FLAGS=-stdlib="libc++ -g" \
      -DCMAKE_BUILD_TYPE=Release

# Build using Ninja
cmake --build build --config Release

# Check binary size
cd build
ls -l libsnmallocshim.* || true
if ls libsnmallocshim.* 1>/dev/null 2>&1; then
  [ $(ls -l libsnmallocshim.* | head -1 | awk '{ print $5}') -lt 10000000 ]
fi

# Run tests using ctest
ctest --output-on-failure -j 4 -C Release --timeout 400 \
      -E "memcpy|external_pointer" \
      --repeat-until-fail 2