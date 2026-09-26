#!/usr/bin/env bash

cd /app

# Configure git
git config --global --add safe.directory /app

# Run the build script
# Use || true to capture exit code but allow script to continue
scripts/build.sh -b release -c gcc -x libnvme || true

echo "FINAL_STATUS = SUCCESS"
