#!/bin/bash
set -e

# Start PostgreSQL service
echo "Starting PostgreSQL service..."
service postgresql start
sleep 2

# Wait for PostgreSQL to be ready
echo "Waiting for PostgreSQL to be ready..."
for i in {1..30}; do
  if pg_isready -h localhost -U postgres; then
    echo "PostgreSQL is ready"
    break
  fi
  echo "Attempt $i: PostgreSQL not ready yet, waiting..."
  sleep 1
done

# Create test database and extension
echo "Creating test database and uuid-ossp extension..."
psql -U postgres -h localhost -c "CREATE DATABASE saltcorn_test;" || true
psql -U postgres -h localhost -d saltcorn_test -c 'CREATE EXTENSION IF NOT EXISTS "uuid-ossp";'

# Update /etc/hosts for domain testing
echo "Updating /etc/hosts..."
echo '127.0.0.1 example.com sub.example.com sub1.example.com sub2.example.com sub3.example.com sub4.example.com sub5.example.com' >> /etc/hosts
echo '127.0.0.1 otherexample.com' >> /etc/hosts

# Install npm dependencies
echo "Installing npm dependencies..."
export PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
export SKIP_DOCKER_IMAGE_INSTALL=true
npm install --legacy-peer-deps

# Run TypeScript compiler
echo "Running TypeScript compiler..."
npm run tsc

# Run test suite 1: main tests with PostgreSQL
echo "Running main test suite..."
export CI=true
export SALTCORN_MULTI_TENANT=true
export SALTCORN_SESSION_SECRET="rehjtyjrtjr"
export SALTCORN_JWT_SECRET="2f75ade09981d68f366a4e577025440d10b735cc270fc2092077140f98a41dab331589c79364601150816d9a3c6f34abf881019e2097e21a24963c56b9135bbb"
export SALTCORN_NWORKERS=1
export PUPPETEER_CHROMIUM_BIN="/usr/bin/chromium-browser"
export PGHOST=localhost
export PGUSER=postgres
export PGDATABASE=saltcorn_test
export PGPASSWORD=postgres
export NODE_OPTIONS="--max-old-space-size=4096"

packages/saltcorn-cli/bin/saltcorn run-tests || TEST_FAILED=1

# Run test suite 2: saltcorn-data with SQLite
echo "Running saltcorn-data test suite..."
export SQLITE_FILEPATH=/tmp/testdb.sqlite
export CI=true
export SALTCORN_MULTI_TENANT=true
export SALTCORN_SESSION_SECRET="rehjtyjrtjr"
export SALTCORN_JWT_SECRET="2f75ade09981d68f366a4e577025440d10b735cc270fc2092077140f98a41dab331589c79364601150816d9a3c6f34abf881019e2097e21a24963c56b9135bbb"
export NODE_OPTIONS="--max-old-space-size=4096"

packages/saltcorn-cli/bin/saltcorn run-tests saltcorn-data || TEST_FAILED=1

# Run test suite 3: server with SQLite
echo "Running server test suite..."
export SQLITE_FILEPATH=/tmp/testdb.sqlite
export CI=true
export SALTCORN_MULTI_TENANT=true
export SALTCORN_SESSION_SECRET="rehjtyjrtjr"
export SALTCORN_JWT_SECRET="2f75ade09981d68f366a4e577025440d10b735cc270fc2092077140f98a41dab331589c79364601150816d9a3c6f34abf881019e2097e21a24963c56b9135bbb"
export NODE_OPTIONS="--max-old-space-size=4096"

packages/saltcorn-cli/bin/saltcorn run-tests server || TEST_FAILED=1

# Run test suite 4: view-queries with SQLite
echo "Running view-queries test suite..."
export REMOTE_QUERIES=true
export SQLITE_FILEPATH=/tmp/sctestdb
export CI=true
export SALTCORN_MULTI_TENANT=true
export SALTCORN_JWT_SECRET="2f75ade09981d68f366a4e577025440d10b735cc270fc2092077140f98a41dab331589c79364601150816d9a3c6f34abf881019e2097e21a24963c56b9135bbb"
export JSON_WEB_TOKEN="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJhZG1pbkBmb28uY29tIiwicm9sZV9pZCI6MSwiaXNzIjoic2FsdGNvcm5Ac2FsdGNvcm4iLCJhdWQiOiJzYWx0Y29ybi1tb2JpbGUtYXBwIiwiaWF0IjoxOTI0OTA1NjAwMDAwLCJleHAiOjE5MjQ5MDU2MDAwMDB9.eE370EdQr90y9woWDzeDzZgGVsUSlfAmtykeAJ_gJjA"
export NODE_OPTIONS="--max-old-space-size=4096"

packages/saltcorn-cli/bin/saltcorn run-tests view-queries || TEST_FAILED=1

# Exit with failure if any test suite failed
if [ "$TEST_FAILED" = "1" ]; then
  echo "One or more test suites failed"
  exit 1
fi

echo "All test suites completed successfully"
exit 0