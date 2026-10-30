#!/usr/bin/env bash

set -e

cd /app

echo "Running: ./gradlew check --no-parallel --no-daemon --console=plain"
./gradlew check --no-parallel --no-daemon --console=plain

echo "FINAL_STATUS = SUCCESS"
