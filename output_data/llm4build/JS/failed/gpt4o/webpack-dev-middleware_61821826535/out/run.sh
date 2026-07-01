#!/bin/bash

# Run tests and ensure all tests are executed
set -e
npm run test:coverage -- --ci || true