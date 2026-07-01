#!/bin/bash

# Set Go environment
export PATH="/usr/local/go/bin:${PATH}"

# Navigate to the correct directory
if [ -d "/workspace/pebble" ]; then
    cd /workspace/pebble
else
    echo "Directory /workspace/pebble does not exist. Creating directory."
    mkdir -p /workspace/pebble
    cd /workspace/pebble
    # Clone the repository or copy necessary files here
    # Replace <repository-url> with the actual URL of the repository
    echo "Cloning repository..."
    git clone https://github.com/your-repo/pebble.git .
    if [ $? -ne 0 ]; then
        echo "Failed to clone repository. Please check your credentials or repository URL."
        exit 1
    fi
fi

# Check if Makefile exists and contains the target
if [ ! -f "Makefile" ]; then
    echo "Makefile not found in /workspace/pebble. Please ensure it is present."
    exit 1
fi

# Check if the target exists in the Makefile
if ! grep -q "testnocgo:" Makefile; then
    echo "Makefile target 'testnocgo' not found. Please ensure it is defined."
    exit 1
fi

# Run tests
GOTRACEBACK=all make testnocgo