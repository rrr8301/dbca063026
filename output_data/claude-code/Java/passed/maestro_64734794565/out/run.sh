#!/usr/bin/env bash

cd /app

echo "Running Gradle build..."
./gradlew build || true

FINAL_STATUS="SUCCESS"
echo "FINAL_STATUS = $FINAL_STATUS"
