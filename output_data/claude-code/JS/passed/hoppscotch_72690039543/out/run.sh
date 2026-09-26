#!/usr/bin/env bash
set -e

cd /app

# Setup environment
mv .env.example .env

# Run tests
export DATABASE_URL="postgresql://postgres:testpass@localhost:5432/hoppscotch"
export DATA_ENCRYPTION_KEY="12345678901234567890123456789012"

pnpm test

FINAL_STATUS=SUCCESS
echo "FINAL_STATUS = $FINAL_STATUS"
