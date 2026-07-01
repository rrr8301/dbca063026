#!/usr/bin/env bash
set -e

cd /app

# Run the Gradle build with the exact command from the workflow
echo "Starting Gradle build..."
./gradlew check --stacktrace

# If we get here, tests ran successfully
echo "Tests completed successfully"
FINAL_STATUS=SUCCESS
echo "FINAL_STATUS = $FINAL_STATUS"
