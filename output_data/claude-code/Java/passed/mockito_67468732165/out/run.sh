#!/usr/bin/env bash
set -e

cd /app

echo "=== Step 6. Build on Java 11 with mock-maker-inline and member-accessor-module ==="
./gradlew \
  -Pmockito.test.java=11 \
  build \
  --stacktrace \
  --scan

echo ""
echo "=== Step 7. Generate coverage report ==="
./gradlew \
  -Pmockito.test.java=11 \
  coverageReport \
  --stacktrace \
  --scan

echo ""
echo "FINAL_STATUS = SUCCESS"
