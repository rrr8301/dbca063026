#!/bin/bash
set -e

# Clone repository if not already present
if [ ! -f "package.json" ]; then
    echo "Repository not found, cloning..."
    # Clone into a temporary directory first, then move contents
    git clone https://github.com/QwenLM/qwen-code.git /tmp/qwen-code || true
    # Move all contents (including hidden files) to /workspace
    shopt -s dotglob
    mv /tmp/qwen-code/* /workspace/
    shopt -u dotglob
    rm -rf /tmp/qwen-code
fi

# Configure npm for rate limiting
npm config set fetch-retry-mintimeout 20000
npm config set fetch-retry-maxtimeout 120000
npm config set fetch-retries 5
npm config set fetch-timeout 300000

# Install dependencies
# Use npm install if package-lock.json doesn't exist, otherwise use npm ci
if [ -f "package-lock.json" ]; then
    npm ci --prefer-offline --no-audit --progress=false
else
    npm install --prefer-offline --no-audit --progress=false
fi

# Build project
npm run build

# Run tests and generate reports
export NO_COLOR=true
npm run test:ci

echo "All tests completed successfully!"