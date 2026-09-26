#!/bin/bash
set -e

# Verify FFmpeg installation
echo "Verifying FFmpeg installation..."
ffmpeg -version

# Run Gradle tests
echo "Running Gradle tests..."
chmod +x ./gradlew
./gradlew check --no-parallel --no-daemon --console=plain

echo "Tests completed successfully!"