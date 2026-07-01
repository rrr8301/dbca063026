#!/bin/bash

# Activate the virtual environment
source /app/venv/bin/activate

# Activate environment variables
export PYTHONPATH=/app/install/python

# Build and test using CMake
mkdir -p build
cd build
cmake .. -DOMPL_BUILD_DEMOS=OFF -DVAMP_PORTABLE_BUILD=ON -DCMAKE_INSTALL_PREFIX=/app/install -DOMPL_PYTHON_INSTALL_PREFIX=/app/install/python
make -j$(nproc)
ctest --output-on-failure

# Test CMake target linkage
cd /app/tests/cmake_export
cmake -B build -DCMAKE_INSTALL_PREFIX=/app/install
cmake --build build

# Run Python tests
cd /app
pytest tests/pytests --ignore=tests/pytests/deprecated || true

# Install Python wheel
pip install ./py-bindings

# Run additional Python tests
pytest tests/pytests --ignore=tests/pytests/deprecated || true