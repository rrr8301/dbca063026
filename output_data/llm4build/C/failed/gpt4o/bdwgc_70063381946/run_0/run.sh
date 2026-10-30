#!/bin/bash

# Clone the repository (assuming the repo URL is known)
# git clone <repository-url> /app

# Configure CMake
cmake -B /app/build \
    -S /app \
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

# Build with CMake
cmake --build /app/build --config Debug --verbose --parallel

# Run tests
cd /app/build
ctest --build-config Debug --verbose --parallel 8

# Test enforcing mprotect-based VDB
GC_USE_GETWRITEWATCH=0 ctest --build-config Debug --verbose