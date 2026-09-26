#!/bin/bash

# Activate environment variables
export CMAKE_PREFIX_PATH=/usr/lib/x86_64-linux-gnu/cmake/Qt5

# Create build directory
cmake -E make_directory build

# Configure CMake
cd build
cmake .. -DCMAKE_BUILD_TYPE=${BUILD_TYPE:-Debug} -DZINT_TEST=ON -DZINT_STATIC=ON -DZINT_QT6=ON

# Build the project
cmake --build . -j8 --config ${BUILD_TYPE:-Debug}

# Run tests
LD_LIBRARY_PATH=$LD_LIBRARY_PATH:"$(pwd)/backend" PATH=$PATH:"$(pwd)/frontend" QT_QPA_PLATFORM=offscreen ctest -V -C ${BUILD_TYPE:-Debug}