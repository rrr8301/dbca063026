#!/bin/bash

# Unset ANDROID_HOME if set
unset ANDROID_HOME

# Run Bazel tests with the flag to ignore direct dependency checks
# Ensure that the Bazel workspace is correctly set up
bazelisk clean --expunge
bazelisk fetch //...

# Correct the path for loading sh_test
# Ensure that the necessary Bazel rules are available
# Add the bazel_skylib repository to WORKSPACE if not already present
if ! grep -q "bazel_skylib" /app/WORKSPACE; then
    echo 'load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")' >> /app/WORKSPACE
    echo 'http_archive(' >> /app/WORKSPACE
    echo '    name = "bazel_skylib",' >> /app/WORKSPACE
    echo '    urls = ["https://github.com/bazelbuild/bazel-skylib/releases/download/1.0.3/bazel-skylib-1.0.3.tar.gz"],' >> /app/WORKSPACE
    echo '    strip_prefix = "bazel-skylib-1.0.3",' >> /app/WORKSPACE
    echo ')' >> /app/WORKSPACE
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