#!/bin/bash
set -e

# Navigate to workspace
cd /workspace

# Install dependencies using ni
nci

# Build the project
nr build

# Run tests with coverage
nr test --coverage