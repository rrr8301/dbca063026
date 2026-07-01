#!/usr/bin/env bash

set -e

echo "=== Java version ==="
java -version

echo "=== Starting Maven build ==="
cd /app
./mvnw -V --no-transfer-progress -Dfastjson2.creator=reflect clean package

if [ $? -eq 0 ]; then
    echo "FINAL_STATUS = SUCCESS"
    exit 0
else
    echo "FINAL_STATUS = FAIL"
    exit 1
fi
