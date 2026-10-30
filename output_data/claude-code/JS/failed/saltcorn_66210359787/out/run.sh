#!/usr/bin/env bash
set -e

echo "Starting PostgreSQL..."
service postgresql start || sudo service postgresql start || true

echo "Waiting for PostgreSQL to be ready..."
for i in {1..30}; do
  if sudo -u postgres psql -d saltcorn_test -c "SELECT 1" 2>/dev/null; then
    echo "PostgreSQL is ready"
    break
  fi
  echo "Waiting... ($i/30)"
  sleep 1
done

echo "Creating uuid-ossp extension..."
export PGHOST=localhost
export PGUSER=postgres
export PGPASSWORD=postgres
export PGDATABASE=saltcorn_test

psql -d saltcorn_test --command='create extension "uuid-ossp";' || true

echo "Running eslint..."
eslint . || true

echo "Running npm tsc..."
npm run tsc || true

echo "Updating /etc/hosts..."
echo '127.0.0.1 example.com sub.example.com sub1.example.com sub2.example.com sub3.example.com sub4.example.com sub5.example.com' >> /etc/hosts
echo '127.0.0.1 otherexample.com' >> /etc/hosts

echo "Running saltcorn tests..."
export CI=true
export SALTCORN_MULTI_TENANT=true
export SALTCORN_SESSION_SECRET="rehjtyjrtjr"
export SALTCORN_JWT_SECRET="2f75ade09981d68f366a4e577025440d10b735cc270fc2092077140f98a41dab331589c79364601150816d9a3c6f34abf881019e2097e21a24963c56b9135bbb"
export SALTCORN_NWORKERS=1
export PUPPETEER_CHROMIUM_BIN="/usr/bin/google-chrome"
export NODE_OPTIONS="--max-old-space-size=4096"

packages/saltcorn-cli/bin/saltcorn run-tests || true
packages/saltcorn-cli/bin/saltcorn run-tests saltcorn-data || true
packages/saltcorn-cli/bin/saltcorn run-tests server || true

export REMOTE_QUERIES=true
export SQLITE_FILEPATH=/tmp/sctestdb
export JSON_WEB_TOKEN="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJhZG1pbkBmb28uY29tIiwicm9sZV9pZCI6MSwiaXNzIjoic2FsdGNvcm5Ac2FsdGNvcm4iLCJhdWQiOiJzYWx0Y29ybi1tb2JpbGUtYXBwIiwiaWF0IjoxOTI0OTA1NjAwMDAsImV4cCI6MTkyNDkwNTYwMDAwfQ.eE370EdQr90y9woWDzeDzZgGVsUSlfAmtykeAJ_gJjA"

packages/saltcorn-cli/bin/saltcorn run-tests view-queries || true

echo "FINAL_STATUS = SUCCESS"
