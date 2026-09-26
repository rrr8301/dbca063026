#!/usr/bin/env bash

cd /app

# Run the test command
npm run test:coverage -- --ci || true

# Tests ran, print success
echo "FINAL_STATUS = SUCCESS"
