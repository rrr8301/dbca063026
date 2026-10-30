#!/usr/bin/env bash

set -e

cd /app

# Clean up any existing storm artifacts
rm -rf ~/.m2/repository/org/apache/storm

# Run the build script
echo "=== Running Maven build ==="
/bin/bash ./dev-tools/gitact/gitact-install.sh /app || BUILD_RET_VAL=$?

if [[ "${BUILD_RET_VAL:-0}" != "0" ]]; then
    echo "Build failed"
    echo "FINAL_STATUS = FAIL"
    exit 1
fi

# Run RAT license check
echo "=== Running RAT license check ==="
rm -f install.txt storm-shaded-deps/install-shade.txt
mvn --batch-mode apache-rat:check -Prat || RAT_RET_VAL=$?

if [[ "${RAT_RET_VAL:-0}" != "0" ]]; then
    echo "RAT check failed"
    echo "FINAL_STATUS = FAIL"
    exit 1
fi

echo "=== Build successful ==="
echo "FINAL_STATUS = SUCCESS"
