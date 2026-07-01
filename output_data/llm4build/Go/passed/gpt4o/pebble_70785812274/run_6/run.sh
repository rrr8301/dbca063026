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
    # Example: git clone <repository-url> .
    echo "Cloning repository..."
    git clone <repository-url> .
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