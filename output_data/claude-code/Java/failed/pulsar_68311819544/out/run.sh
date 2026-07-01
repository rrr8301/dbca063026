#!/usr/bin/env bash
set -o pipefail

cd /app

echo "Starting Pulsar CI - Integration - Messaging test"
echo "Java version: $(java -version 2>&1)"
echo "Maven version: $(mvn -v)"

# Run the integration test group for MESSAGING
./build/run_integration_group.sh MESSAGING

TEST_EXIT_CODE=$?

if [ $TEST_EXIT_CODE -eq 0 ]; then
    echo "FINAL_STATUS = SUCCESS"
    exit 0
else
    echo "FINAL_STATUS = FAIL"
    exit 0
fi
