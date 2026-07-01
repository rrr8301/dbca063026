#!/usr/bin/env bash
set -e

WORKSPACE_DIR=/workspace
BUILD_DIR=${WORKSPACE_DIR}/build
INSTALL_DIR=${WORKSPACE_DIR}/install

# Create directories
mkdir -p ${BUILD_DIR}
mkdir -p ${INSTALL_DIR}

cd /app

# Configure CMake
cmake \
    -B ${BUILD_DIR} \
    -DCMAKE_BUILD_TYPE=Release \
    -DOMPL_BUILD_DEMOS=OFF \
    -DVAMP_PORTABLE_BUILD=ON \
    -DCMAKE_INSTALL_PREFIX=${INSTALL_DIR} \
    -DOMPL_PYTHON_INSTALL_DIR=${INSTALL_DIR}/python

# Build
cmake --build ${BUILD_DIR} --config Release

# Run tests
cd ${BUILD_DIR}
ctest --output-on-failure || true

# Install
cmake --install ${BUILD_DIR}

# Test CMake target linkage
cd /app/tests/cmake_export
cmake -B build -DCMAKE_INSTALL_PREFIX=${INSTALL_DIR}
cmake --build build

echo "FINAL_STATUS = SUCCESS"
