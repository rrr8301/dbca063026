#!/bin/bash

# Activate environment variables
export DATABASE_URL="postgresql://postgres:testpass@localhost:5432/hoppscotch"
export DATA_ENCRYPTION_KEY="12345678901234567890123456789012"

# Move .env.example to .env
mv .env.example .env

# Install dependencies
pnpm install

# Run tests and ensure all tests are executed
pnpm test || true