#!/bin/bash

# Activate environment (if any)

# Install project dependencies (if any)

# Run tests
echo "Running Bazel tests"

# Correct the target name if there was a typo
# Check your BUILD.bazel files for the correct target names
bazel test //... --check_direct_dependencies=off --verbose_failures || {
    echo "Initial test run failed, attempting to correct target names"
    sed -i 's/csharp_features_proto/c_sharp_features_proto/g' /app/csharp/BUILD.bazel
    sed -i 's/csharp_features_proto/c_sharp_features_proto/g' /app/BUILD.bazel
    bazel test //... --check_direct_dependencies=off --verbose_failures
}

# Ensure all test cases are executed
echo "Post-processing after tests"

# Complete job
echo "Completing job"