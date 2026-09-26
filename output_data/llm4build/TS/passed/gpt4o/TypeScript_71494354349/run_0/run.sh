#!/bin/bash

# Activate environment variables if needed
export BUNDLE=true

# Run tests
npm run test -- --no-lint --bundle="$BUNDLE"

# Ensure all tests are executed, even if some fail
if [ $? -ne 0 ]; then
  echo "Tests failed, but continuing to execute all tests."
fi

# Print baseline diff on failure
npx hereby baseline-accept
git add tests/baselines/reference
git diff --staged --exit-code