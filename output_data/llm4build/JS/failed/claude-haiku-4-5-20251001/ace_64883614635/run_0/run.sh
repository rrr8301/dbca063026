#!/bin/bash

set -e

# Enable error handling: continue on test failures but track exit code
test_exit_code=0

echo "=========================================="
echo "Starting Ace Build and Test Suite"
echo "=========================================="

# Step 1: Install dependencies
echo ""
echo "Step 1: Installing npm dependencies..."
npm i

# Step 2: Run tests with coverage
echo ""
echo "Step 2: Running tests with coverage..."
npm run cover || test_exit_code=$?

# Step 3: Git setup for linting checks
echo ""
echo "Step 3: Setting up git for linting checks..."
git status
git checkout HEAD -- package.json

# Step 4: ESLint checks (conditional on changed files)
echo ""
echo "Step 4: Running ESLint checks..."
changes=$(git diff --name-only origin/HEAD --no-renames --diff-filter=ACMR 2>/dev/null || echo "")

if [ "$changes" == "" ]; then
    echo "Checking all files..."
    node node_modules/eslint/bin/eslint "lib/ace/**/*.js" || test_exit_code=$?
else
    jsChanges=$(echo "$changes" | grep -P '.js$' || :)
    if [ "$jsChanges" == "" ]; then
        echo "No JavaScript files changed, skipping ESLint..."
    else
        echo "Checking changed JavaScript files: $jsChanges"
        node node_modules/eslint/bin/eslint $jsChanges || test_exit_code=$?
    fi
fi

# Step 5: TypeScript checks
echo ""
echo "Step 5: Running TypeScript checks..."
set -x
npx tsc -v
npm run update-types || test_exit_code=$?
git diff --color --exit-code ./ace*d.ts || test_exit_code=$?
npm run typecheck || test_exit_code=$?
node_modules/.bin/tsc --noImplicitAny --strict --noUnusedLocals --noImplicitReturns --noUnusedParameters --noImplicitThis ace.d.ts || test_exit_code=$?
set +x

# Step 6: NPM package test
echo ""
echo "Step 6: Running NPM package tests..."
if [ -f "./tool/test-npm-package.sh" ]; then
    bash ./tool/test-npm-package.sh || test_exit_code=$?
else
    echo "Warning: ./tool/test-npm-package.sh not found, skipping..."
fi

# Step 7: Summary
echo ""
echo "=========================================="
echo "Test Suite Complete"
echo "=========================================="

if [ $test_exit_code -ne 0 ]; then
    echo "Some tests failed (exit code: $test_exit_code)"
    exit $test_exit_code
else
    echo "All tests passed!"
    exit 0
fi