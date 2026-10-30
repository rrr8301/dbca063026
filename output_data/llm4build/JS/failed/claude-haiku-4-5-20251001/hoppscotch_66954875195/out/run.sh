#!/bin/bash

set -e

# Set environment variables for pnpm install
export DATABASE_URL="postgresql://postgres:testpass@localhost:5432/hoppscotch"
export DATA_ENCRYPTION_KEY="12345678901234567890123456789012"

# Setup environment file
if [ -f .env.example ]; then
    cp .env.example .env
fi

# Install dependencies
pnpm install

# Run tests
pnpm test