#!/bin/bash
set -e

# Clone repository if not already present
if [ ! -d ".git" ]; then
    echo "Repository not found, cloning..."
    cd /workspace
    git clone https://github.com/QwenLM/qwen-code.git . || true
fi

# Configure npm for rate limiting
npm config set fetch-retry-mintimeout 20000
npm config set fetch-retry-maxtimeout 120000
npm config set fetch-retries 5
npm config set fetch-timeout 300000

# Install dependencies
npm ci --prefer-offline --no-audit --progress=false

# Build project
npm run build

# Run tests and generate reports
export NO_COLOR=true
npm run test:ci

echo "All tests completed successfully!"