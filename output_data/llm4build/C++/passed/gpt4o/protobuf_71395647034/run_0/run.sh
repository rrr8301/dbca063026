#!/bin/bash

set -e

# Activate environment variables if needed
# (Placeholder for any environment setup)

# Install project dependencies
# (Assuming dependencies are managed within the repository)

# Run tests
# Using Bazel for testing
bazel test //pkg/... //src/... //third_party/utf8_range/... //conformance:conformance_framework_tests || true

# Using CMake for testing
cmake . -Dprotobuf_BUILD_TESTS=ON
cmake --build . --parallel 20
ctest --no-tests=error --verbose --parallel 20 || true

# Ensure all tests are executed, even if some fail