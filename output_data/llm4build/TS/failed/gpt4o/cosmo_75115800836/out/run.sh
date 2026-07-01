#!/bin/bash

# Install project dependencies
pnpm install --frozen-lockfile

# Generate code
pnpm buf generate --template buf.ts.gen.yaml

# Install react-email globally
pnpm add -g react-email

# Generate email templates
pnpm run --filter ./controlplane/emails build

# Lint and format code
pnpm run --filter ./controlplane/ lint:fix

# Build the project
pnpm run --filter ./controlplane --filter ./connect --filter ./shared --filter ./composition --filter ./protographic build

# Check `dist` directory structure
if [ ! -f "controlplane/dist/index.js" ]; then
  exit 1
fi

# Setup Keycloak
nohup .github/scripts/setup-keycloak.sh &

# Run tests with coverage
DB_URL="postgresql://postgres:changeme@localhost:5432/controlplane" pnpm run --filter controlplane test:coverage

# Note: Coverage upload to Codecov is skipped