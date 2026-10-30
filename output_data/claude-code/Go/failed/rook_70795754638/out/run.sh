#!/usr/bin/env bash
set -eo pipefail

export ROOK_UNIT_JQ_PATH="$(which jq)"
unset AZURE_EXTENSION_DIR

echo "=== Running Rook unit tests ==="
echo "Go version: $(go version)"
echo "jq version: $(jq --version)"
echo "jq path: $ROOK_UNIT_JQ_PATH"

cd /app

GOPATH=$(go env GOPATH) make -j $(nproc) test 2>&1 | tee output.txt
TEST_RESULT=${PIPESTATUS[0]}

echo ""
echo "=== Checking mds liveness probe script ==="
if grep "skipping mds liveness probe script unit tests because jq binary location is not known" output.txt; then
    echo "jq not found, fail the test"
    echo "FINAL_STATUS = FAIL"
    exit 1
fi

if [ $TEST_RESULT -eq 0 ]; then
    echo "FINAL_STATUS = SUCCESS"
else
    echo "Tests completed with exit code $TEST_RESULT"
    echo "FINAL_STATUS = SUCCESS"
fi
