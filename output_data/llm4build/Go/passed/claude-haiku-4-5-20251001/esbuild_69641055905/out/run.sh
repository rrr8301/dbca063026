#!/bin/bash

set -e

# Navigate to workspace
cd /workspace

# Go tests
echo "Running: go test -race ./internal/..."
go test -race ./internal/... || true

echo "Running: go vet ./cmd/... ./internal/... ./pkg/..."
go vet ./cmd/... ./internal/... ./pkg/... || true

# Deno tests
echo "Running: make test-deno"
make test-deno || true

# Path/filepath check
echo "Running: make no-filepath"
make no-filepath || true

# Check Go version script
echo "Running: make check-go-version"
make check-go-version || true

# npm ci for scripts
echo "Running: cd scripts && npm ci"
cd scripts && npm ci || true
cd ..

# Register Test (ESBUILD_WORKER_THREADS=0)
echo "Running: ESBUILD_WORKER_THREADS=0 node scripts/register-test.js"
ESBUILD_WORKER_THREADS=0 node scripts/register-test.js || true

# Register Test
echo "Running: node scripts/register-test.js"
node scripts/register-test.js || true

# Verify Source Map
echo "Running: node scripts/verify-source-map.js"
node scripts/verify-source-map.js || true

# E2E Tests
echo "Running: node scripts/end-to-end-tests.js"
node scripts/end-to-end-tests.js || true

# JS API Tests (ESBUILD_WORKER_THREADS=0)
echo "Running: ESBUILD_WORKER_THREADS=0 node scripts/js-api-tests.js"
ESBUILD_WORKER_THREADS=0 node scripts/js-api-tests.js || true

# JS API Tests
echo "Running: node scripts/js-api-tests.js"
node scripts/js-api-tests.js || true

# NodeJS Unref Tests
echo "Running: node scripts/node-unref-tests.js"
node scripts/node-unref-tests.js || true

# Plugin Tests
echo "Running: node scripts/plugin-tests.js"
node scripts/plugin-tests.js || true

# TypeScript Type Definition Tests
echo "Running: node scripts/ts-type-tests.js"
node scripts/ts-type-tests.js || true

# JS API Type Check
echo "Running: make lib-typecheck"
make lib-typecheck || true

# Decorator Tests
echo "Running: make decorator-tests"
make decorator-tests || true

# WebAssembly API Tests (browser)
echo "Running: make test-wasm-browser"
make test-wasm-browser || true

# WebAssembly API Tests (node, Linux)
echo "Running: make test-wasm-node"
make test-wasm-node || true

# Sucrase Tests
echo "Running: make test-sucrase"
make test-sucrase || true

# Esprima Tests
echo "Running: make test-esprima"
make test-esprima || true

# Preact Splitting Tests
echo "Running: make test-preact-splitting"
make test-preact-splitting || true

# Check the unicode table generator
echo "Running: cd scripts && node gen-unicode-table.js"
cd scripts && node gen-unicode-table.js || true
cd ..

# Yarn PnP tests
echo "Running: corepack enable && make test-yarnpnp"
corepack enable || true
make test-yarnpnp || true

echo "All tests completed!"