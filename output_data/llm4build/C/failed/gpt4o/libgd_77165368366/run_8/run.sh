#!/bin/bash

# Add any additional commands you need to run here
echo "Running the application..."

# Example: Configure and build the project using CMake
cmake -DENABLE_PNG=1 -DENABLE_FREETYPE=1 -DENABLE_JPEG=1 -DENABLE_WEBP=1 \
      -DENABLE_TIFF=1 -DENABLE_XPM=1 -DENABLE_GD_FORMATS=1 -DENABLE_HEIF=1 \
      -DENABLE_RAQM=1 -DENABLE_AVIF=1 -DBUILD_TEST=1 -B /workspace/build \
      -DCMAKE_BUILD_TYPE=RelWithDebInfo

# Build the project
cmake --build /workspace/build --config RelWithDebInfo --parallel 4

# Run tests
cd /workspace/build
CTEST_OUTPUT_ON_FAILURE=1 ctest -C RelWithDebInfo