#!/bin/bash
set -e

# Navigate to repository root
cd /workspace

# Install dependencies using npm ci (clean install from package-lock.json)
npm ci

# Run tests
npm test