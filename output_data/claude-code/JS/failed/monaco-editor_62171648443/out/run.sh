#!/usr/bin/env bash
set -e

echo "=== Build ==="
npm run build

echo "=== Run unit tests ==="
npm test

echo "=== Compile webpack plugin ==="
npm run compile --prefix webpack-plugin

echo "=== Package using webpack plugin ==="
npm run package-for-smoketest

echo "=== Run smoke test ==="
npm run smoketest

echo "=== Install website node modules ==="
cd website
npm ci

echo "=== Install most recent version of monaco-editor ==="
npm install monaco-editor

echo "=== Build website ==="
npm run build

echo "=== Test website ==="
npm run test

echo "FINAL_STATUS = SUCCESS"
