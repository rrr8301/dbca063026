#!/bin/bash

# Set Go environment
export PATH="/usr/local/go/bin:${PATH}"

# Navigate to the pebble directory
cd /workspace/pebble

# Run tests
GOTRACEBACK=all make testnocgo