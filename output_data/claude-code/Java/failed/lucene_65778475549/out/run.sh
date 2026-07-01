#!/usr/bin/env bash

set -e

cd /app

export TEST_JVM_ARGS="-XX:TieredStopAtLevel=1 -XX:+UseParallelGC -XX:ActiveProcessorCount=1"

echo "Running gradle tests..."
./gradlew displayGradleDiagnostics allOptions test "-Ptask.times=true" "-Pvalidation.errorprone=false" || {
  echo "Tests completed (with failures)"
  echo "FINAL_STATUS = FAIL"
  exit 1
}

echo "FINAL_STATUS = SUCCESS"
