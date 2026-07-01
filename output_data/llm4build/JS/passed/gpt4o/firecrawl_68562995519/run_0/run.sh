#!/bin/bash

# Clone the repository (simulating actions/checkout)
git clone . /app

# Change to the working directory
cd /app/apps/js-sdk/firecrawl

# Install dependencies
pnpm install

# Build the project
pnpm run build

# Run tests
pnpm run test