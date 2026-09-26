#!/bin/bash
set -e

# Verify FFmpeg installation
echo "Verifying FFmpeg installation..."
ffmpeg -version

# Verify Java installation
echo "Verifying Java installation..."
java -version

# Run Gradle tests with exact command from workflow
echo "Running Gradle tests..."
./gradlew check --no-parallel --no-daemon --console=plain

echo "Tests completed successfully!"