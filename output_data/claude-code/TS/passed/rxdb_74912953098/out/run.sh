#!/usr/bin/env bash

set -e

cd /app

echo "Logging versions..."
node --version
npm -v

echo "Running test:typings..."
npm run test:typings

echo "Running test:react..."
npm run test:react

echo "FINAL_STATUS = SUCCESS"
