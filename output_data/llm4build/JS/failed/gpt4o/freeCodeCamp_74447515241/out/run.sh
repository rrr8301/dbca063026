#!/bin/bash

# Start MongoDB using Docker Compose
docker-compose -f docker/docker-compose.yml up -d

# Install dependencies
echo "Installing dependencies..."
pnpm install

# Install Chrome for Puppeteer
echo "Installing Chrome for Puppeteer..."
pnpm -F=curriculum install-puppeteer

# Run tests
echo "Running tests..."
pnpm test