#!/usr/bin/env bash
set -e

cd /app

# Run the Maven build command exactly as in the workflow
mvn -V -ntp clean install -P full verify

if [ $? -eq 0 ]; then
    echo "FINAL_STATUS = SUCCESS"
else
    echo "FINAL_STATUS = FAIL"
    exit 1
fi
