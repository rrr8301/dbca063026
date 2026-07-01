#!/bin/bash

# Unset ANDROID_HOME if set
unset ANDROID_HOME

# Run Bazel tests with the flag to ignore direct dependency checks
# Ensure that the Bazel workspace is correctly set up
bazelisk clean --expunge
bazelisk fetch //...

# Check if MODULE.bazel exists, if not create it and add necessary dependencies
if [ ! -f /app/MODULE.bazel ]; then
    echo 'module(name = "my_project")' > /app/MODULE.bazel
    echo 'bazel_dep(name = "bazel_skylib", version = "1.0.3")' >> /app/MODULE.bazel
fi

# Correct the load statement for sh_test
sed -i '/load.*sh_test/d' /app/BUILD.bazel
echo 'load("@bazel_skylib//rules:sh_test.bzl", "sh_test")' >> /app/BUILD.bazel

# Run the tests, ensuring that the correct test rules are used
# Use --build_tests_only to ensure only tests are built
bazelisk test //:all --build_tests_only --check_direct_dependencies=off --test_output=errors

# Check for specific errors and handle them
if grep -q "name 'sh_test' is not defined" /app/BUILD.bazel; then
    echo "Error: 'sh_test' is not defined. Please ensure that the correct Bazel rules are loaded."
    exit 1
fi