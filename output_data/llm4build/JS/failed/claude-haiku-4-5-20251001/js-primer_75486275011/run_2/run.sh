#!/bin/bash
set -e

# Verify Node.js is available
node --version
npm --version

# Install dependencies
npm ci

# Run tests
npm test