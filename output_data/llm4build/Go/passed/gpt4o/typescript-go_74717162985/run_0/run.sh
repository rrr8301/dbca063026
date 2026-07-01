#!/bin/bash

# Run tests
npx hereby test
npx hereby test:benchmarks
npx hereby test:tools
npx hereby test:api

# Check for uncommitted changes
git add .
git diff --staged --exit-code --stat