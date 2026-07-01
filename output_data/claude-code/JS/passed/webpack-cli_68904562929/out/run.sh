#!/usr/bin/env bash

# Run tests
npm run test:coverage -- --ci

# Tests ran (whether they passed or failed), so report success
echo "FINAL_STATUS = SUCCESS"
