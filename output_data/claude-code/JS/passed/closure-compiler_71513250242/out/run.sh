#!/usr/bin/env bash
set -e

cd /app

echo "=== Starting Build and Test ==="
unset ANDROID_HOME
bazel test //:all

echo "=== Copying Artifacts ==="
mkdir -p $UNSYMLINK_DIR
cp -t $UNSYMLINK_DIR bazel-bin/compiler_uberjar_deploy.jar || true
cp -t $UNSYMLINK_DIR bazel-bin/*_bundle.jar || true

echo "=== Tests Completed Successfully ==="
echo "FINAL_STATUS = SUCCESS"
