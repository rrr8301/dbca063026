#!/bin/bash

# Configure, build, and test in various configurations

# Static Debug
cmake -G Ninja -S . -B build-static-dbg -DCMAKE_BUILD_TYPE=Debug
cmake --build build-static-dbg
ctest --output-on-failure --test-dir build-static-dbg

# Shared Debug
cmake -G Ninja -S . -B build-shared-dbg -DCMAKE_BUILD_TYPE=Debug -DBUILD_SHARED_LIBS=ON
cmake --build build-shared-dbg
ctest --output-on-failure --test-dir build-shared-dbg

# Static Release
cmake -G Ninja -S . -B build-static-rel -DCMAKE_BUILD_TYPE=Release
cmake --build build-static-rel
ctest --output-on-failure --test-dir build-static-rel

# Shared Release
cmake -G Ninja -S . -B build-shared-rel -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=ON
cmake --build build-shared-rel
ctest --output-on-failure --test-dir build-shared-rel

# Joint install
cmake --install build-shared-dbg --prefix install
cmake --install build-static-dbg --prefix install
cmake --install build-shared-rel --prefix install
cmake --install build-static-rel --prefix install

# List install tree
tree install

# Test find_package
ctest --build-and-test test test-static-dbg --build-generator Ninja --build-options -DCMAKE_BUILD_TYPE=Debug -Dtinyxml2_SHARED_LIBS=NO -DCMAKE_PREFIX_PATH=/app/install --test-command ctest --output-on-failure
ctest --build-and-test test test-static-rel --build-generator Ninja --build-options -DCMAKE_BUILD_TYPE=Release -Dtinyxml2_SHARED_LIBS=NO -DCMAKE_PREFIX_PATH=/app/install --test-command ctest --output-on-failure
ctest --build-and-test test test-shared-dbg --build-generator Ninja --build-options -DCMAKE_BUILD_TYPE=Debug -Dtinyxml2_SHARED_LIBS=YES -DCMAKE_PREFIX_PATH=/app/install --test-command ctest --output-on-failure
ctest --build-and-test test test-shared-rel --build-generator Ninja --build-options -DCMAKE_BUILD_TYPE=Release -Dtinyxml2_SHARED_LIBS=YES -DCMAKE_PREFIX_PATH=/app/install --test-command ctest --output-on-failure