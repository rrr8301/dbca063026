#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Build with Meson
./ci/build-tumbleweed.sh -Db_ndebug=true

# Ensure the build directory exists
if [ ! -d "build" ]; then
  echo "Build directory does not exist. Exiting."
  exit 1
fi

# Run Meson tests
meson test -C build

# Print Meson test log if tests fail
if [ $? -ne 0 ]; then
  if [ -f "./build/meson-logs/testlog.txt" ]; then
    cat ./build/meson-logs/testlog.txt
  else
    echo "Test log not found."
  fi
fi