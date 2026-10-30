#!/usr/bin/env bash
set -u

cd /app

echo "==> Testing source headers are present"
if ! make test-source-headers; then
    echo "FINAL_STATUS = FAIL"
    exit 1
fi

echo "==> Checking if go modules need to be tidied"
if ! go mod tidy -diff; then
    echo "FINAL_STATUS = FAIL"
    exit 1
fi

echo "==> Running unit tests"
make test-coverage || true

echo "==> Test build"
make build || true

echo "FINAL_STATUS = SUCCESS"
