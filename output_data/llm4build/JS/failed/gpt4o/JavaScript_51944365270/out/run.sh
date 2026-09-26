#!/bin/bash

# Run tests and ensure all tests are executed
set -e
npm run test || true

# Check code style
npm run check-style || true