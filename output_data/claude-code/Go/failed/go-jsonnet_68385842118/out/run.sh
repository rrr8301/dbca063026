#!/usr/bin/env bash

set +e  # Continue on errors

echo "Starting tests..."

# Set up environment variables as in the CI workflow
export GOARCH=amd64
export CGO_ENABLED=1
export SKIP_PYTHON_BINDINGS_TESTS=0

cd /app

# Run the tests (same as make test, which calls tests.sh)
bash tests.sh
TEST_RESULT=$?

if [ $TEST_RESULT -eq 0 ]; then
    echo "FINAL_STATUS = SUCCESS"
else
    echo "Tests failed with exit code $TEST_RESULT"
    echo "FINAL_STATUS = FAIL"
fi

exit $TEST_RESULT
