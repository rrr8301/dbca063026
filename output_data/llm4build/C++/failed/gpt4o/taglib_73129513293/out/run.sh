#!/bin/bash

# Configure the build
cmake -B/app/build \
    -DBUILD_SHARED_LIBS=ON \
    -DVISIBILITY_HIDDEN=ON \
    -DBUILD_TESTING=ON \
    -DBUILD_EXAMPLES=ON \
    -DBUILD_BINDINGS=ON \
    -DCMAKE_BUILD_TYPE=Release

# Build the project
cmake --build /app/build --config Release --parallel

# Run tests
cd /app/build
ctest -C Release -V --no-tests=error