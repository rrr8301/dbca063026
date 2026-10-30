#!/usr/bin/env bash
set -e

cd /app

echo "=== Listing Java toolchains ==="
./gradlew javaToolchains || true

echo "=== Building and testing ==="
./gradlew build || BUILD_FAILED=true

echo "=== Running shellcheck ==="
./gradlew shellcheck || true

echo "=== Aggregating jacoco coverage ==="
./gradlew codeCoverageReport || true

echo "=== Testing publishToMavenLocal flow ==="
ORG_GRADLE_PROJECT_VERSION_NAME='0.0.0.1-LOCAL' \
ORG_GRADLE_PROJECT_RELEASE_SIGNING_ENABLED='false' \
./gradlew publishToMavenLocal || true

echo "=== Checking Git tree is clean ==="
./.buildscript/check_git_clean.sh || true

if [ "$BUILD_FAILED" = true ]; then
  echo "FINAL_STATUS = FAIL"
  exit 1
else
  echo "FINAL_STATUS = SUCCESS"
  exit 0
fi
