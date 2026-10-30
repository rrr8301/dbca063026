#!/usr/bin/env bash
set -e

cd /app

# Run the exact build command from the workflow
./mvnw -V --no-transfer-progress -pl core3 -am clean package

FINAL_STATUS=SUCCESS
echo "FINAL_STATUS=$FINAL_STATUS"
