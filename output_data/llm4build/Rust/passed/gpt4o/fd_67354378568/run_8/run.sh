#!/bin/bash

# Basic script to run the Rust application
echo "Running the application..."

# Read the binary name from the file
BINARY_NAME=$(cat /app/binary_name.txt)

# Execute the Rust application
./target/release/$BINARY_NAME