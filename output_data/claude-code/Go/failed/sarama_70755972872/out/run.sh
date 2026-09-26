#!/usr/bin/env bash
set -e

cd /app

export CI=true
export GOBIN=$PWD/bin

# Create test directory
mkdir -p _test

# Install gotestsum and teststat
echo "Installing test tools..."
go install gotest.tools/gotestsum@v1.13.0
go install github.com/vearutop/teststat@v0.1.27

# Run the tests
echo "Running tests..."
$GOBIN/gotestsum --format github-actions --jsonfile _test/unittests.json --junitfile _test/unittests.xml \
    --rerun-fails --packages="./..." \
    -- -v -race -coverprofile=profile.out -covermode=atomic -timeout 2m || TEST_FAILED=1

# Run teststat for summary
if [ -f _test/unittests.json ]; then
    echo "Test results summary:"
    $GOBIN/teststat _test/unittests.json || true
fi

# Run tparse for additional reporting
if [ -f _test/unittests.json ]; then
    echo "Running tparse..."
    go run github.com/mfridman/tparse@v0.18.0 -all -format markdown -file _test/unittests.json || true
fi

# Report coverage
if [ -f profile.out ]; then
    echo "Code coverage:"
    go tool cover -func=profile.out || true
fi

# Report final status
if [ "$TEST_FAILED" = "1" ]; then
    echo "FINAL_STATUS = FAIL"
else
    echo "FINAL_STATUS = SUCCESS"
fi
