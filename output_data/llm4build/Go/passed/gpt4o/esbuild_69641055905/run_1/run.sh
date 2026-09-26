#!/bin/bash

# Activate environments
export PATH="/usr/local/go/bin:${PATH}"
export PATH="${DENO_INSTALL}/bin:${PATH}"

# Install project dependencies
cd scripts && npm ci && cd ..

# Run tests
go test -race ./internal/...
go vet ./cmd/... ./internal/... ./pkg/...
make test-deno
make no-filepath
make check-go-version
ESBUILD_WORKER_THREADS=0 node scripts/register-test.js
node scripts/register-test.js
node scripts/verify-source-map.js
node scripts/end-to-end-tests.js
ESBUILD_WORKER_THREADS=0 node scripts/js-api-tests.js
node scripts/js-api-tests.js
node scripts/node-unref-tests.js
node scripts/plugin-tests.js
node scripts/ts-type-tests.js
make lib-typecheck
make decorator-tests
make test-wasm-browser
make test-wasm-node
make test-sucrase
make test-esprima
make test-preact-splitting
cd scripts && node gen-unicode-table.js && cd ..
corepack enable
make test-yarnpnp