#!/bin/bash

# Unset ANDROID_HOME if set
unset ANDROID_HOME

# Run Bazel tests with the flag to ignore direct dependency checks
# Ensure that the Bazel workspace is correctly set up
bazelisk clean --expunge
bazelisk fetch //...

# Add --check_direct_dependencies=off to ignore direct dependency checks
# Ensure that the necessary Bazel rules are available
bazelisk sync --check_direct_dependencies=off

# Run the tests, ensuring that the correct test rules are used
# Use --build_tests_only to ensure only tests are built
bazelisk test //:all --build_tests_only --check_direct_dependencies=off --test_output=errors