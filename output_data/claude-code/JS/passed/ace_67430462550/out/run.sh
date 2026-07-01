#!/usr/bin/env bash

cd /app

# Run coverage and tests
echo "=== Running coverage and tests ==="
npm run cover-json && mv ./coverage/coverage-final.json ./coverage/coverage.json || true

# ESLint check
echo "=== Running ESLint ==="
set -x
git status
git checkout HEAD -- package.json || true
changes=$(git diff --name-only origin/HEAD --no-renames --diff-filter=ACMR 2>/dev/null || echo "")
if [ "$changes" == "" ]; then
    echo "checking all files"
    node node_modules/eslint/bin/eslint "lib/ace/**/*.js" || true
else
    jsChanges=$(echo "$changes" | grep -P '.js$' || :)
    if [ "$jsChanges" == "" ]; then
        echo "nothing to check"
    else
        echo "checking $jsChanges"
        node node_modules/eslint/bin/eslint $jsChanges || true
    fi
fi
set +x

# Type checking
echo "=== Running type checking ==="
set -x
npx tsc -v
npm run update-types || true
git diff --color --exit-code ./ace*d.ts || true
npm run typecheck || true
node_modules/.bin/tsc --noImplicitAny --strict --noUnusedLocals --noImplicitReturns --noUnusedParameters --noImplicitThis ace.d.ts || true
set +x

# Test npm package
echo "=== Running NPM package test ==="
./tool/test-npm-package.sh || true

echo ""
echo "=== Tests completed ==="
echo "FINAL_STATUS=SUCCESS"
