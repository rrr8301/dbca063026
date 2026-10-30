#!/usr/bin/env bash
set -e

cd /app

# Clean up any previous storm artifacts
rm -rf ~/.m2/repository/org/apache/storm

# Set up project dependencies
/bin/bash ./dev-tools/gitact/gitact-install.sh $(pwd)

# Run build with matrix variables
export JDK_VERSION=17
export USER=github
export STORM_TEST_TIMEOUT_MS=150000
export MAVEN_OPTS="-Xmx2048m"

/bin/bash ./dev-tools/gitact/gitact-script.sh $(pwd) Core

BUILD_RET_VAL=$?

if [ $BUILD_RET_VAL -eq 0 ]; then
    echo "FINAL_STATUS = SUCCESS"
    exit 0
else
    echo "FINAL_STATUS = FAIL"
    exit 1
fi
