#!/bin/bash
set -e

# Set environment variables
export ANDROID_HOME=""
export VERSION_NODEJS="22"
export UNSYMLINK_DIR="bazel-bin-unsymlink"

# Verify Java installation
java -version

# Verify Bazelisk installation
bazelisk version

# Build and Test
echo "Running Bazel tests..."
unset ANDROID_HOME
bazelisk test //:all

# Unsymlink Bazel Artifacts
echo "Copying Bazel artifacts..."
mkdir -p "$UNSYMLINK_DIR"
cp -t "$UNSYMLINK_DIR" bazel-bin/compiler_uberjar_deploy.jar
cp -t "$UNSYMLINK_DIR" bazel-bin/*_bundle.jar

echo "Build and test completed successfully!"
echo "Artifacts available in: $UNSYMLINK_DIR"