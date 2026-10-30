#!/usr/bin/env bash
set -e

cd /app

echo "Starting ShardingSphere CI build..."

./mvnw clean install -T1C -B -ntp -fae

if [ $? -eq 0 ]; then
    echo "FINAL_STATUS = SUCCESS"
else
    echo "FINAL_STATUS = FAIL"
    exit 1
fi
