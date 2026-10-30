#!/bin/bash
set -e

# Clone the repository (assuming it's passed as an environment variable or argument)
# For local testing, we assume the repo is already mounted or copied
if [ ! -d ".git" ]; then
    echo "Repository not found. Assuming repo is mounted at /workspace"
fi

# Install dependencies
npm ci --ignore-scripts

# Build project
npm run build

# Run tests
npm run test