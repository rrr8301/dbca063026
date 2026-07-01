#!/bin/bash

# Unset ANDROID_HOME and run Bazel tests
unset ANDROID_HOME
bazelisk test //:all --check_direct_dependencies=off

# Unsymlink Bazel artifacts
UNSYMLINK_DIR=${UNSYMLINK_DIR:-bazel-bin-unsymlink}
mkdir -p "${UNSYMLINK_DIR}"
cp -t "${UNSYMLINK_DIR}" bazel-bin/compiler_uberjar_deploy.jar || echo "compiler_uberjar_deploy.jar not found"
cp -t "${UNSYMLINK_DIR}" bazel-bin/*_bundle.jar || echo "No bundle jars found"