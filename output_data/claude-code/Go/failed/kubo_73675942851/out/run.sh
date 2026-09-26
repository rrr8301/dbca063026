#!/usr/bin/env bash

echo "Starting unit tests..."

cd /app

# Run unit tests - don't exit on failure, we need to check if tests actually ran
make test_unit
TEST_RESULT=$?

# Check if tests actually ran by looking for the output JSON file
if [ ! -f "test/unit/gotest.json" ]; then
    echo "Test output file not found - tests did not run"
    echo "FINAL_STATUS = FAIL"
    exit 1
fi

# Check if the JSON file has content
if [ ! -s "test/unit/gotest.json" ]; then
    echo "Test output file is empty - tests did not run"
    echo "FINAL_STATUS = FAIL"
    exit 1
fi

# If we get here, tests ran (even if some failed)
# Count the number of test results to confirm
TEST_COUNT=$(jq -s 'length' test/unit/gotest.json)
echo "Tests completed. Total test events: $TEST_COUNT"

# Print the summary
echo "FINAL_STATUS = SUCCESS"
