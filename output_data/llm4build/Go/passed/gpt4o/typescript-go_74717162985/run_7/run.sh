#!/bin/bash

# Ensure hereby is installed
npm install -g hereby

# Run tests
npx hereby test || exit 1
npx hereby test:benchmarks || exit 1
npx hereby test:tools || exit 1
npx hereby test:api || exit 1

# Check for uncommitted changes
git add .
git diff --staged --exit-code --stat