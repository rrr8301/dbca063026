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
    # Optionally, you can clone a specific repository or copy necessary files here
fi

# Run tests
GOTRACEBACK=all make testnocgo