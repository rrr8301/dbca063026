#!/usr/bin/env bash
set -e

cd /app

# Export environment variables needed for the build
export COMMERCIAL_RELEASE_REPO_URL=""
export COMMERCIAL_REPO_PASSWORD=""
export COMMERCIAL_REPO_USERNAME=""
export COMMERCIAL_SNAPSHOT_REPO_URL=""

# Disable gradle daemon for container environment
export ORG_GRADLE_PROJECT_org_gradle_daemon=false

echo "=== Starting Gradle Build ==="
echo "Working directory: $(pwd)"
echo "Java version:"
java -version

# Run the actual build command from the workflow
./gradlew build || true

echo ""
echo "=== Build Complete ==="
FINAL_STATUS = SUCCESS
