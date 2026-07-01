#!/bin/bash

# Activate environment (if any specific activation is needed, add here)

# Install utoo (assuming it's a Node.js package)
npm install -g utoo

# Run the initial setup command
ut

# Run tests with all test cases executed
set +e  # Continue on error
ut test -- --maxWorkers=2 --shard=2/2 --coverage