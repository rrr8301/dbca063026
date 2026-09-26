#!/bin/bash

# Unset ANDROID_HOME if set
unset ANDROID_HOME

# Run Bazel tests with the flag to ignore direct dependency checks
# Ensure that the Bazel workspace is correctly set up
bazelisk clean --expunge
bazelisk fetch //...

# Correct the path for loading sh_test
# Ensure that the necessary Bazel rules are available
# Note: The error log suggests that the path was incorrect. Let's fix it.
echo "load('@bazel_tools//tools/bash/runfiles:runfiles.bzl', 'sh_test')" >> /app/BUILD.bazel

# Run the tests, ensuring that the correct test rules are used
# Use --build_tests_only to ensure only tests are built
bazelisk test //:all --build_tests_only --check_direct_dependencies=off --test_output=errors

# Check for specific errors and handle them
if grep -q "name 'sh_test' is not defined" /app/BUILD.bazel; then
    echo "Error: 'sh_test' is not defined. Please ensure that the correct Bazel rules are loaded."
    exit 1
fi