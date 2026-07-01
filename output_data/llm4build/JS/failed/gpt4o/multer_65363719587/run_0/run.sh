#!/bin/bash

# List environment
echo "node@$(node -v)"
echo "npm@$(npm -v)"
npm -s ls || true
(npm -s ls --depth=0 || true) | awk -F'[ @]' 'NR>1 && $2 { print $2 "=" $3 }'

# Lint code
npm run lint

# Run tests
if npm -ps ls nyc | grep -q nyc; then
  npm run test-ci
else
  npm test
fi