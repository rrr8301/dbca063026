#!/bin/bash

# Build and test using Gradle
./gradlew build

# Run shellcheck
./gradlew shellcheck

# Aggregate Jacoco coverage
./gradlew codeCoverageReport || true

# Publish to Maven Local
ORG_GRADLE_PROJECT_VERSION_NAME='0.0.0.1-LOCAL' ORG_GRADLE_PROJECT_RELEASE_SIGNING_ENABLED='false' ./gradlew publishToMavenLocal

# Check Git tree cleanliness
./.buildscript/check_git_clean.sh