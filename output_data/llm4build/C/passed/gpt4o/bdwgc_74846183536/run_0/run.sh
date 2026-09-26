#!/bin/bash

# Clone the repository (simulating actions/checkout)
# Assuming the repository is already copied in the Dockerfile

# Configure CMake
cmake -B /app/build \
    -S /app \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_CXX_COMPILER=g++ \
    -DCMAKE_C_COMPILER=gcc \
    -DGC_BUILD_SHARED_LIBS=on \
    -Denable_cplusplus=on \
    -Denable_gc_assertions=on \
    -Denable_gc_dump=on \
    -Denable_large_config=on \
    -Denable_redirect_malloc=on \
    -Denable_rwlock=off \
    -Denable_threads=off \
    -Denable_werror=on \
    -Werror=dev

# Build the project
cmake --build /app/build --config Release --verbose --parallel

# Run tests
cd /app/build
ctest --build-config Release --verbose --parallel 8