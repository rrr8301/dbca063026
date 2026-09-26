#!/usr/bin/env bash
set -e

echo "Starting build for gson on JDK 17..."
cd /app

# Run the exact Maven command from the workflow
mvn verify javadoc:jar --show-version --batch-mode --no-transfer-progress

# If we get here, tests ran successfully
echo "Build completed successfully"
echo "FINAL_STATUS = SUCCESS"
