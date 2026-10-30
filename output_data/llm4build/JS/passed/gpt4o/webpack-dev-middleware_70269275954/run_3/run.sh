#!/bin/bash

# Navigate to the workspace
cd /workspace

# Install project dependencies
npm ci --unsafe-perm

# Run tests
npm run test:coverage -- --ci