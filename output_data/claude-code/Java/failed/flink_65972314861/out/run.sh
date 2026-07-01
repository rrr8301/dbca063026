#!/usr/bin/env bash
set -e

cd /app

export DEBUG_FILES_OUTPUT_DIR="/tmp/debug-files"
mkdir -p "$DEBUG_FILES_OUTPUT_DIR"

export MAVEN_OPTS="-Xmx4g -XX:+UseG1GC"
export JAVA_TOOL_OPTIONS="-XX:+HeapDumpOnOutOfMemoryError"
export IS_CI=true

# Run the test controller for the table module
echo "Starting Flink Table module tests..."
./tools/ci/test_controller.sh table

EXIT_CODE=$?

if [ $EXIT_CODE -eq 0 ]; then
    echo "FINAL_STATUS = SUCCESS"
else
    echo "FINAL_STATUS = FAIL"
fi

exit $EXIT_CODE
