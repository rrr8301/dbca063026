#!/usr/bin/env bash
set -e

cd /app

# Run the exact test command from the workflow
mvn -V -ntp clean install -P full verify

FINAL_STATUS="SUCCESS"
echo "FINAL_STATUS = $FINAL_STATUS"
