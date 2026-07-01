#!/bin/bash

# Run tests
npx hereby test

# On failure, print baseline diff
if [ $? -ne 0 ]; then
  npx hereby baseline-accept
  git add testdata/baselines/reference
  git diff --staged --exit-code
fi