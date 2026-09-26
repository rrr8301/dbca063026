#!/bin/bash
set -e

# Navigate to workspace
cd /workspace

# Install dependencies (exact command from YAML)
npm install --ignore-scripts

# Run unit tests (exact command from YAML)
npm run unit