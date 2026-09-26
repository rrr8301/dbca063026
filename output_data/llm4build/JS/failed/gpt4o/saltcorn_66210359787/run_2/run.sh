#!/bin/bash

# Start PostgreSQL service
service postgresql start

# Wait for PostgreSQL to start
until pg_isready -h localhost -p 5432; do
  echo "Waiting for PostgreSQL to start..."
  sleep 1
done

# Create the database and user if they don't exist
sudo -u postgres psql -c "CREATE DATABASE saltcorn_test;" || true
sudo -u postgres psql -c "CREATE USER postgres WITH PASSWORD 'postgres';" || true
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE saltcorn_test TO postgres;" || true

# Install project dependencies
export PUPPETEER_SKIP_CHROMIUM_DOWNLOAD="true"
export SKIP_DOCKER_IMAGE_INSTALL="true"
npm install --legacy-peer-deps

# Run TypeScript compiler
npm run tsc

# Modify /etc/hosts
echo '127.0.0.1 example.com sub.example.com sub1.example.com sub2.example.com sub3.example.com sub4.example.com sub5.example.com' | sudo tee -a /etc/hosts
echo '127.0.0.1 otherexample.com' | sudo tee -a /etc/hosts

# Set environment variables for tests
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

# Run ESLint
eslint .

# Create PostgreSQL extension
psql -d saltcorn_test --command='create extension if not exists "uuid-ossp";'

# Run tests
packages/saltcorn-cli/bin/saltcorn run-tests