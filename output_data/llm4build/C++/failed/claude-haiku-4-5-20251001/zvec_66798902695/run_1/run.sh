#!/bin/bash
set -e

# Determine number of processors
NPROC=$(nproc 2>/dev/null || echo 2)
echo "Using $NPROC parallel jobs for builds"

# Get Python user base and add to PATH
PYTHON_USER_BASE=$(python -c 'import site; print(site.USER_BASE)')
export PATH="$PYTHON_USER_BASE/bin:$PATH"

# Upgrade pip
python -m pip install --upgrade pip

# Install Python dependencies
python -m pip install --upgrade pip \
    pybind11==3.0 \
    cmake==3.30.0 \
    ninja==1.11.1 \
    pytest \
    scikit-build-core \
    setuptools_scm

# Build from source
cd /workspace

export CMAKE_GENERATOR="Unix Makefiles"
export CMAKE_BUILD_PARALLEL_LEVEL="$NPROC"

python -m pip install -v . \
    --no-build-isolation \
    --config-settings='cmake.define.BUILD_TOOLS="ON"'

# Run C++ Tests
cd /workspace/build
make unittest -j$NPROC

echo "All tests completed successfully!"