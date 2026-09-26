#!/bin/bash
set -e

# Assume the repository is already checked out at /workspace
# If running standalone, clone it
if [ ! -d "/workspace/repo" ]; then
    git clone https://github.com/ivmai/bdwgc.git /workspace/repo
fi

cd /workspace/repo

# Configure CMake
cmake -B /workspace/repo/build \
  -S /workspace/repo \
  -DCMAKE_BUILD_TYPE=Debug \
  -DCMAKE_C_COMPILER=clang \
  -DGC_BUILD_SHARED_LIBS=on \
  -Denable_werror=on \
  -Werror=dev \
  -Denable_gc_assertions=on \
  -Denable_large_config=on \
  -Denable_redirect_malloc=on \
  -Denable_rwlock=on \
  -DCFLAGS_EXTRA=-DIGNORE_FREE

# Build
cmake --build /workspace/repo/build \
  --config Debug --verbose --parallel

# Test
cd /workspace/repo/build
ctest --build-config Debug --verbose --parallel 8

# Test enforcing mprotect-based VDB
GC_USE_GETWRITEWATCH=0 ctest --build-config Debug --verbose