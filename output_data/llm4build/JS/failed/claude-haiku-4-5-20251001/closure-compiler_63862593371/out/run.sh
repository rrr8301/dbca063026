#!/bin/bash
set -e

# Unset ANDROID_HOME as per the workflow
unset ANDROID_HOME

# Build and test using Bazel
bazelisk test //:all

# Unsymlink Bazel artifacts
mkdir -p bazel-bin-unsymlink
cp -t bazel-bin-unsymlink bazel-bin/compiler_uberjar_deploy.jar
cp -t bazel-bin-unsymlink bazel-bin/*_bundle.jar

echo "Build and test completed successfully!"