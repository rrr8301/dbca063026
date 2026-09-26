#!/bin/bash
set -e

# Navigate to workspace
cd /workspace

# Install latest npm globally
npm install --global npm

# Install dependencies using npm ci (clean install from package-lock.json)
npm ci

# Run tests
npm test