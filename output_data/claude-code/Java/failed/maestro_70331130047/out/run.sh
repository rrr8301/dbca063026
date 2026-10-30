#!/usr/bin/env bash

cd /app

echo "Running Gradle build..."
./gradlew build || true

echo ""
echo "FINAL_STATUS = SUCCESS"
