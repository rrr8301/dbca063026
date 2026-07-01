#!/bin/bash

# Unset ANDROID_HOME and run Bazel tests
unset ANDROID_HOME
bazelisk test //:all

# Unsymlink Bazel artifacts
mkdir -p "${UNSYMLINK_DIR}"
cp -t "${UNSYMLINK_DIR}" bazel-bin/compiler_uberjar_deploy.jar
cp -t "${UNSYMLINK_DIR}" bazel-bin/*_bundle.jar