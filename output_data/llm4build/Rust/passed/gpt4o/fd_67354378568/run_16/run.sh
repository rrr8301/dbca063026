#!/bin/bash

# Basic script to run the Rust application
echo "Running the application..."

# Read the binary name from the file
BINARY_NAME=$(cat /app/binary_name.txt)

# Check if the binary exists
if [ ! -f /app/target/release/$BINARY_NAME ]; then
    echo "Error: Binary $BINARY_NAME not found in /app/target/release/"
    exit 1
fi

# Execute the Rust application
exec /app/target/release/$BINARY_NAME