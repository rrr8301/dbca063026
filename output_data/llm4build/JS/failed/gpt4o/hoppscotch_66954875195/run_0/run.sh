#!/bin/bash

# Clone the repository (simulating actions/checkout)
git clone https://github.com/your/repo.git /app
cd /app

# Setup environment
mv .env.example .env

# Set environment variables
export DATABASE_URL="postgresql://postgres:testpass@localhost:5432/hoppscotch"
export DATA_ENCRYPTION_KEY="12345678901234567890123456789012"

# Install dependencies
pnpm install

# Run tests
pnpm test