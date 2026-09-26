#!/bin/bash

set -e

# Navigate to workspace
cd /workspace

# Configure lib with --disable-openmp
cd lib
./configure --disable-openmp
cd ..

# Build lib
make -C lib lib

# Build bin (allow wget failure for model download)
make -C bin || true

# Build site source
make -C site source

# Build test
make -C test

# Run tests (continue even if tests fail to ensure all tests are executed)
make -C test test || TEST_FAILED=1

# Exit with failure if tests failed
if [ "$TEST_FAILED" = "1" ]; then
    exit 1
fi

exit 0