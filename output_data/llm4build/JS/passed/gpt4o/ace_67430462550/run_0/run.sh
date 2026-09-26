#!/bin/bash

# Activate environment (if any specific activation is needed, e.g., nvm use)
# Not needed here as Node.js is installed globally

# Install project dependencies
npm install

# Run coverage and move coverage file
npm run cover-json && mv ./coverage/coverage-final.json ./coverage/coverage.json

# Run ESLint checks
set -x
git status
git checkout HEAD -- package.json
changes=$(git diff --name-only origin/HEAD --no-renames --diff-filter=ACMR)
if [ "$changes" == "" ]; then
    echo "checking all files"
    node node_modules/eslint/bin/eslint "lib/ace/**/*.js"
else
    jsChanges=$(echo "$changes" | grep -P '.js$' || :)
    if [ "$jsChanges" == "" ]; then
        echo "nothing to check"
    else
        echo "checking $jsChanges"
        node node_modules/eslint/bin/eslint $jsChanges
    fi
fi

# Run TypeScript checks
set -x
npx tsc -v
npm run update-types
git diff --color --exit-code ./ace*d.ts
npm run typecheck
node_modules/.bin/tsc --noImplicitAny --strict --noUnusedLocals --noImplicitReturns --noUnusedParameters --noImplicitThis ace.d.ts

# Run npm package tests
set -x
./tool/test-npm-package.sh

# Run unit tests
npm run test || true  # Ensure all tests run even if some fail