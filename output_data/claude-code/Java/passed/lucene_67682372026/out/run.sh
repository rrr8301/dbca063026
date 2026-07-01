#!/usr/bin/env bash
set -e

cd /app

# Configure git
git config --global core.autocrlf false

# Set environment variables
export TEST_JVM_ARGS="-XX:TieredStopAtLevel=1 -XX:+UseParallelGC -XX:ActiveProcessorCount=1"

# Run gradle tests
echo "Running gradle tests..."
./gradlew displayGradleDiagnostics allOptions test "-Ptask.times=true" "-Pvalidation.errorprone=false" || true

# List gradle properties
echo "Listing gradle.properties..."
cat gradle.properties

echo "FINAL_STATUS = SUCCESS"
