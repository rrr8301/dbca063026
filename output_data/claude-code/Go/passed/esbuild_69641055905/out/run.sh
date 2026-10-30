#!/usr/bin/env bash
set -e

cd /app

# Read go.version
GO_VERSION=$(cat go.version)

# Verify Go version
go version | grep -F " go$GO_VERSION " || (echo "Please install Go version $GO_VERSION" && false)

# go test with -race flag
echo "Running: go test -race ./internal/..."
go test -race ./internal/... || exit 1

# go vet
echo "Running: go vet ./cmd/... ./internal/... ./pkg/..."
go vet ./cmd/... ./internal/... ./pkg/... || exit 1

# Test for path/filepath
echo "Running: make no-filepath"
make no-filepath || exit 1

# Make sure "check-go-version" works
echo "Running: make check-go-version"
make check-go-version || exit 1

# Deno Tests
echo "Running: make test-deno"
make test-deno || exit 1

# Register Test (ESBUILD_WORKER_THREADS=0)
echo "Running: ESBUILD_WORKER_THREADS=0 node scripts/register-test.js"
ESBUILD_WORKER_THREADS=0 node scripts/register-test.js || exit 1

# Register Test
echo "Running: node scripts/register-test.js"
node scripts/register-test.js || exit 1

# Verify Source Map
echo "Running: node scripts/verify-source-map.js"
node scripts/verify-source-map.js || exit 1

# E2E Tests
echo "Running: node scripts/end-to-end-tests.js"
node scripts/end-to-end-tests.js || exit 1

# JS API Tests (ESBUILD_WORKER_THREADS=0)
echo "Running: ESBUILD_WORKER_THREADS=0 node scripts/js-api-tests.js"
ESBUILD_WORKER_THREADS=0 node scripts/js-api-tests.js || exit 1

# JS API Tests
echo "Running: node scripts/js-api-tests.js"
node scripts/js-api-tests.js || exit 1

# NodeJS Unref Tests
echo "Running: node scripts/node-unref-tests.js"
node scripts/node-unref-tests.js || exit 1

# Plugin Tests
echo "Running: node scripts/plugin-tests.js"
node scripts/plugin-tests.js || exit 1

# TypeScript Type Definition Tests
echo "Running: node scripts/ts-type-tests.js"
node scripts/ts-type-tests.js || exit 1

# JS API Type Check
echo "Running: make lib-typecheck"
make lib-typecheck || exit 1

# Decorator Tests
echo "Running: make decorator-tests"
make decorator-tests || exit 1

# WebAssembly API Tests (browser)
echo "Running: make test-wasm-browser"
make test-wasm-browser || exit 1

# WebAssembly API Tests (node, Linux)
echo "Running: make test-wasm-node"
make test-wasm-node || exit 1

# Sucrase Tests
echo "Running: make test-sucrase"
make test-sucrase || exit 1

# Esprima Tests
echo "Running: make test-esprima"
make test-esprima || exit 1

# Preact Splitting Tests
echo "Running: make test-preact-splitting"
make test-preact-splitting || exit 1

# Check the unicode table generator
echo "Running: cd scripts && node gen-unicode-table.js"
cd scripts && node gen-unicode-table.js || exit 1
cd /app

# Yarn PnP tests
echo "Running: corepack enable && make test-yarnpnp"
corepack enable
make test-yarnpnp || exit 1

echo "FINAL_STATUS = SUCCESS"
