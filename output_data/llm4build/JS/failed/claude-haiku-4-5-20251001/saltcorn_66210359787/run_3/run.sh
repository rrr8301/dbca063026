#!/bin/bash
set -e

# Wait for PostgreSQL to be ready
echo "Waiting for PostgreSQL to be ready..."
PGHOST=${PGHOST:-localhost}
PGUSER=${PGUSER:-postgres}
PGDATABASE=${PGDATABASE:-saltcorn_test}

for i in {1..30}; do
  if pg_isready -h "$PGHOST" -U "$PGUSER" > /dev/null 2>&1; then
    echo "PostgreSQL is ready"
    break
  fi
  echo "Attempt $i: PostgreSQL not ready yet, waiting..."
  sleep 2
done

# Create test database and extension
echo "Creating test database and extension..."
psql -U "$PGUSER" -h "$PGHOST" -c "CREATE DATABASE $PGDATABASE;" 2>/dev/null || true
psql -U "$PGUSER" -h "$PGHOST" -d "$PGDATABASE" -c 'CREATE EXTENSION IF NOT EXISTS "uuid-ossp";' 2>/dev/null || true

# Update /etc/hosts with test domains
echo "Updating /etc/hosts..."
echo '127.0.0.1 example.com sub.example.com sub1.example.com sub2.example.com sub3.example.com sub4.example.com sub5.example.com' >> /etc/hosts
echo '127.0.0.1 otherexample.com' >> /etc/hosts

# Install npm dependencies
echo "Installing npm dependencies..."
npm install --legacy-peer-deps

# Run TypeScript compiler
echo "Running TypeScript compiler..."
npm run tsc

# Run linting
echo "Running ESLint..."
eslint .

# Run tests
echo "Running tests..."
export CI=true
export SALTCORN_MULTI_TENANT=true
export SALTCORN_SESSION_SECRET="rehjtyjrtjr"
export SALTCORN_JWT_SECRET="2f75ade09981d68f366a4e577025440d10b735cc270fc2092077140f98a41dab331589c79364601150816d9a3c6f34abf881019e2097e21a24963c56b9135bbb"
export SALTCORN_NWORKERS=1
export PUPPETEER_CHROMIUM_BIN="/usr/bin/chromium-browser"
export PGHOST="$PGHOST"
export PGUSER="$PGUSER"
export PGDATABASE="$PGDATABASE"
export PGPASSWORD=${PGPASSWORD:-postgres}
export NODE_OPTIONS="--max-old-space-size=4096"
export PUPPETEER_SKIP_CHROMIUM_DOWNLOAD="true"
export SKIP_DOCKER_IMAGE_INSTALL="true"

packages/saltcorn-cli/bin/saltcorn run-tests

echo "All tests completed successfully!"