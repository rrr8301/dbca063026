#!/usr/bin/env bash
set -eo pipefail

export ROOK_UNIT_JQ_PATH="$(which jq)"
unset AZURE_EXTENSION_DIR

GOPATH=$(go env GOPATH) make -j $(nproc) test | tee output.txt

# Check mds liveness probe script ran successfully
if grep "skipping mds liveness probe script unit tests because jq binary location is not known" output.txt
then
    echo "jq not found, fail the test"
    exit 1
fi

echo "FINAL_STATUS = SUCCESS"
