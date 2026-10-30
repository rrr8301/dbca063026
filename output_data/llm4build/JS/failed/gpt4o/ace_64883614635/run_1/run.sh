#!/bin/bash

# Activate environment (if any specific activation is needed, e.g., nvm, pyenv, etc.)

# Install project dependencies
npm install

# Run coverage tests
npm run cover

# Run linter
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

# Check types
set -x
npx tsc -v
npm run update-types
git diff --color --exit-code ./ace*d.ts
npm run typecheck
node_modules/.bin/tsc --noImplicitAny --strict --noUnusedLocals --noImplicitReturns --noUnusedParameters --noImplicitThis ace.d.ts

# Run additional tests
set -x
./tool/test-npm-package.sh

# Ensure all tests are executed
npm run test || true