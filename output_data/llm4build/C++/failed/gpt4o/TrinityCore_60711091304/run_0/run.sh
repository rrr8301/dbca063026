#!/bin/bash

# Set environment variables
export CMAKE_BUILD_TYPE=Debug
export CMAKE_C_COMPILER_LAUNCHER=ccache
export CMAKE_CXX_COMPILER_LAUNCHER=ccache
export CC=/usr/bin/clang-17
export CXX=/usr/bin/clang++-17

# Set reusable strings
BUILD_OUTPUT_DIR=/app/bin
CCACHE_KEY_PREFIX=ubuntu-clang-17-main

# Install dependencies
sudo apt-get update && sudo apt-get install -yq ccache libboost-dev libboost-filesystem-dev libboost-locale-dev libboost-program-options-dev libboost-regex-dev libboost-thread-dev libssl-dev libreadline-dev zlib1g-dev libbz2-dev

# Setup build environment
cmake -GNinja -S /app -B $BUILD_OUTPUT_DIR \
    -DWITH_WARNINGS=1 -DWITH_WARNINGS_AS_ERRORS=1 -DWITH_COREDEBUG=0 -DUSE_COREPCH=0 -DUSE_SCRIPTPCH=0 -DTOOLS=1 -DSCRIPTS=dynamic -DSERVERS=1 -DNOJEM=0 \
    -DCMAKE_C_FLAGS_DEBUG="-DNDEBUG -g0" -DCMAKE_CXX_FLAGS_DEBUG="-DNDEBUG -g0" \
    -DCMAKE_INSTALL_PREFIX=check_install -DBUILD_TESTING=1

# Build the project
ccache -z
cmake --build $BUILD_OUTPUT_DIR
ccache -s

# Run unit tests
cmake --build $BUILD_OUTPUT_DIR --target test

# Check executables
cmake --install $BUILD_OUTPUT_DIR
cd /app/check_install/bin
./bnetserver --version
./worldserver --version