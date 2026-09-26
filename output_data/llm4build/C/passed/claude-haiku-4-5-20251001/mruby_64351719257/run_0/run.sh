#!/bin/bash

set -e

# Display versions for debugging
echo "=== Ruby version ==="
ruby -v

echo "=== Clang version ==="
clang --version

echo "=== Build and test ==="
# Run the test suite using rake
# The -m flag allows multiple jobs; serial runs tests sequentially
rake -m test:run:serial

echo "=== All tests completed ==="