#!/bin/bash

# Set Go environment
export PATH="/usr/local/go/bin:${PATH}"

# Navigate to the correct directory
if [ -d "/workspace/pebble" ]; then
    cd /workspace/pebble
else
    echo "Directory /workspace/pebble does not exist."
    exit 1
fi

# Run tests
GOTRACEBACK=all make testnocgo