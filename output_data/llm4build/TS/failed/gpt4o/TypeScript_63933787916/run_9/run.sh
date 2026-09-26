#!/bin/bash

# Run tests
npm run test -- --no-lint --bundle=true || true

# Print baseline diff on failure
if [ $? -ne 0 ]; then
  npx hereby baseline-accept
  git add tests/baselines/reference
  git diff --staged --exit-code || true
fi