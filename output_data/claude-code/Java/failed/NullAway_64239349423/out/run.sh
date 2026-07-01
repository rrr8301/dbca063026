#!/usr/bin/env bash

set -e

cd /app

echo "==== Listing Java toolchains ===="
./gradlew javaToolchains

echo "==== Building and testing ===="
./gradlew build

echo "==== Running shellcheck ===="
./gradlew shellcheck

echo "==== Aggregating jacoco coverage ===="
./gradlew codeCoverageReport || true

echo "==== Testing publishToMavenLocal ===="
export ORG_GRADLE_PROJECT_VERSION_NAME='0.0.0.1-LOCAL'
export ORG_GRADLE_PROJECT_RELEASE_SIGNING_ENABLED='false'
./gradlew publishToMavenLocal

echo "==== Checking git tree is clean ===="
./.buildscript/check_git_clean.sh

echo "==== BUILD COMPLETED SUCCESSFULLY ===="
echo "FINAL_STATUS = SUCCESS"
