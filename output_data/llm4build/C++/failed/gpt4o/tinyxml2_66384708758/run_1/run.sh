#!/bin/bash

# Configure, build, and test using CMake and Ninja
cmake -G Ninja -S . -B build-static-dbg -DCMAKE_BUILD_TYPE=Debug "-DCMAKE_DEBUG_POSTFIX=d_static"
cmake --build build-static-dbg
ctest --output-on-failure --test-dir build-static-dbg