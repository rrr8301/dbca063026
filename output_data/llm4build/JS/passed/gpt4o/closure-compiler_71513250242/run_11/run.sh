#!/bin/bash

# Unset ANDROID_HOME and run Bazel tests
unset ANDROID_HOME

# Ensure Bazel is using the correct version
bazelisk version

# Run Bazel tests
bazelisk test //:all --check_direct_dependencies=off || {
    echo "Bazel tests failed. Please check the BUILD.bazel file for errors."
    exit 1
}

# Unsymlink Bazel artifacts
UNSYMLINK_DIR=${UNSYMLINK_DIR:-bazel-bin-unsymlink}
mkdir -p "${UNSYMLINK_DIR}"
cp -t "${UNSYMLINK_DIR}" bazel-bin/compiler_uberjar_deploy.jar || echo "compiler_uberjar_deploy.jar not found"
cp -t "${UNSYMLINK_DIR}" bazel-bin/*_bundle.jar || echo "No bundle jars found"