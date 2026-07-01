#!/usr/bin/env bash

set -e

cd /app

echo "Node.js version: $(node -v)"
echo "NPM version: $(npm -v)"

npm config set loglevel error

npm run test-ci

echo "FINAL_STATUS = SUCCESS"
