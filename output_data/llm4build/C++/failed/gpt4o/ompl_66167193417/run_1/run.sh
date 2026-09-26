#!/bin/bash

# Activate environment variables if needed (none specified)

# Build and test using CMake
mkdir -p build/Release
cd build/Release
cmake ../.. -DOMPL_BUILD_DEMOS=OFF -DVAMP_PORTABLE_BUILD=ON -DCMAKE_INSTALL_PREFIX=/app/install -DOMPL_PYTHON_INSTALL_DIR=/app/install/python
make -j$(nproc)

# Run tests
ctest --output-on-failure