#!/bin/bash

echo "Running the application..."

# Define directories and names for the scripts
OUTPUT_DIR="/app/output"
PCSX2_DIR="/app/pcsx2"
BUILD_DIR="/app/build"
DEPS_PREFIX="/app/deps"
OUTPUT_NAME="PCSX2-AppImage"

# Create necessary directories
mkdir -p "$OUTPUT_DIR" "$PCSX2_DIR" "$BUILD_DIR" "$DEPS_PREFIX"

# Check if the necessary scripts are present and executable
if [[ ! -x /app/scripts/build-dependencies-qt.sh ]]; then
    echo "Error: build-dependencies-qt.sh is not executable or not found."
    exit 1
fi

if [[ ! -x /app/scripts/appimage-qt.sh ]]; then
    echo "Error: appimage-qt.sh is not executable or not found."
    exit 1
fi

# Execute the scripts with the required arguments
/app/scripts/build-dependencies-qt.sh "$OUTPUT_DIR"
/app/scripts/appimage-qt.sh "$PCSX2_DIR" "$BUILD_DIR" "$DEPS_PREFIX" "$OUTPUT_NAME"

# Add any additional commands needed to start your application