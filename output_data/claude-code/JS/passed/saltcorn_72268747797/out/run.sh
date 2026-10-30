#!/usr/bin/env bash
set -e

# Start PostgreSQL
service postgresql start
sleep 2

# Wait for PostgreSQL to be ready
until pg_isready -h localhost -U postgres; do
  echo "Waiting for PostgreSQL..."
  sleep 1
done

# Create the test database
createdb -U postgres -h localhost saltcorn_test || true

# Create uuid-ossp extension
psql -h localhost -U postgres -d saltcorn_test --command='create extension "uuid-ossp";' || true

# Set up hosts (for multi-tenant testing)
echo '127.0.0.1 example.com sub.example.com sub1.example.com sub2.example.com sub3.example.com sub4.example.com sub5.example.com' | tee -a /etc/hosts > /dev/null
echo '127.0.0.1 otherexample.com' | tee -a /etc/hosts > /dev/null

cd /app

# Run linting
echo "=== Running ESLint ==="
eslint .

# Run TypeScript compilation
echo "=== Running TypeScript compilation ==="
npm run tsc

# Run tests
export CI=true
export SALTCORN_MULTI_TENANT=true
export SALTCORN_SESSION_SECRET="rehjtyjrtjr"
export SALTCORN_JWT_SECRET="2f75ade09981d68f366a4e577025440d10b735cc270fc2092077140f98a41dab331589c79364601150816d9a3c6f34abf881019e2097e21a24963c56b9135bbb"
export SALTCORN_NWORKERS=1
export PUPPETEER_CHROMIUM_BIN="/usr/bin/google-chrome"
export PGHOST=localhost
export PGUSER=postgres
export PGDATABASE=saltcorn_test
export PGPASSWORD=postgres
export NODE_OPTIONS="--max-old-space-size=4096"

echo "=== Running test suite 1: main tests ==="
packages/saltcorn-cli/bin/saltcorn run-tests || TESTS_FAILED=1

echo "=== Running test suite 2: saltcorn-data ==="
export SQLITE_FILEPATH=/tmp/testdb.sqlite
packages/saltcorn-cli/bin/saltcorn run-tests saltcorn-data || TESTS_FAILED=1

echo "=== Running test suite 3: server ==="
packages/saltcorn-cli/bin/saltcorn run-tests server || TESTS_FAILED=1

echo "=== Running test suite 4: view-queries ==="
export SQLITE_FILEPATH=/tmp/sctestdb
export REMOTE_QUERIES=true
export JSON_WEB_TOKEN="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJhZG1pbkBmb28uY29tIiwicm9sZV9pZCI6MSwiaXNzIjoic2FsdGNvcm5Ac2FsdGNvcm4iLCJhdWQiOiJzYWx0Y29ybi1tb2JpbGUtYXBwIiwiaWF0IjoxOTI0OTA1NjAwMDAwLCJleHAiOjE5MjQ5MDU2MDAwMDB9.eE370EdQr90y9woWDzeDzZgGVsUSlfAmtykeAJ_gJjA"
packages/saltcorn-cli/bin/saltcorn run-tests view-queries || TESTS_FAILED=1

if [ -n "$TESTS_FAILED" ]; then
  echo "FINAL_STATUS = FAIL"
  exit 1
else
  echo "FINAL_STATUS = SUCCESS"
fi
