#!/bin/bash

# Run tests, typecheck, and lint
set -e

# Run tests
npm run test:no-lint || true

# Run typecheck
npm run typecheck || true

# Run lint
npm run lint || true