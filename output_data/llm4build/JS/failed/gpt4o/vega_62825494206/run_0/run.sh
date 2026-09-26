#!/bin/bash

# Run tests
npm run test:no-lint || true

# Run typecheck
npm run typecheck || true

# Lint the code
npm run lint || true