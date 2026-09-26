#!/usr/bin/env bash
set -e

cd /app

echo "=== Go Version ==="
go version

echo "=== Running Coverage Tests ==="
GOPROXY="https://proxy.golang.org,direct" make go.test.coverage

if [ -f ./coverage.xml ]; then
    echo "=== Coverage Report Generated ==="
    ls -lh ./coverage.xml
    echo "FINAL_STATUS = SUCCESS"
else
    echo "Coverage file not generated"
    echo "FINAL_STATUS = FAIL"
    exit 1
fi
