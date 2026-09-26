#!/usr/bin/env bash
set -o pipefail

echo "Running chi tests..."
echo "====================="

cd $GOPATH/src/github.com/go-chi/chi

# Get dependencies
echo "Getting dependencies..."
go get -d -t ./...

# Run tests
echo "Running make test..."
make test
TEST_RESULT=$?

echo ""
echo "====================="
if [ $TEST_RESULT -eq 0 ]; then
    echo "FINAL_STATUS = SUCCESS"
else
    echo "FINAL_STATUS = FAIL"
fi
