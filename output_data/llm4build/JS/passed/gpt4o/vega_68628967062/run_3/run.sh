#!/bin/bash

# Run tests, typecheck, and lint
set -e

# Run tests
npm run test:no-lint

# Run typecheck
npm run typecheck

# Run lint
npm run lint