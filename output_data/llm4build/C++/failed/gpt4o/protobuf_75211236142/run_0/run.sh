#!/bin/bash

# Activate environment (if any)

# Install project dependencies (if any)

# Run tests
echo "Running Bazel tests"
bazel test //...

# Ensure all test cases are executed
echo "Post-processing after tests"

# Complete job
echo "Completing job"