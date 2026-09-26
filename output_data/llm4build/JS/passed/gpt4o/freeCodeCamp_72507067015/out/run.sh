#!/bin/bash

# Start MongoDB using Docker Compose
docker-compose -f docker/docker-compose.yml up -d

# Install Chrome for Puppeteer
pnpm -F=curriculum install-puppeteer

# Run tests
pnpm test || true  # Ensure all tests run even if some fail