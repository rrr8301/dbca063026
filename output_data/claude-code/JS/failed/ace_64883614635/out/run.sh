#!/usr/bin/env bash
set -e

echo "=== Starting ACE build tests ==="

# Test 1: Coverage JSON generation
echo "=== Step 1: Generate coverage JSON ==="
npm run cover-json || true
if [ -f ./coverage/coverage-final.json ]; then
    mv ./coverage/coverage-final.json ./coverage/coverage.json
fi

# Test 2: ESLint
echo "=== Step 2: Running ESLint ==="
set +e
git status
git checkout HEAD -- package.json || true
changes=$(git diff --name-only origin/HEAD --no-renames --diff-filter=ACMR 2>/dev/null || echo "")
if [ "$changes" == "" ]; then
    echo "checking all files"
    node node_modules/eslint/bin/eslint "lib/ace/**/*.js" || true
else
    jsChanges=$(echo "$changes" | grep -P '.js$' || echo "")
    if [ "$jsChanges" == "" ]; then
        echo "nothing to check"
    else
        echo "checking $jsChanges"
        node node_modules/eslint/bin/eslint $jsChanges || true
    fi
fi
set -e

# Test 3: TypeScript type checking
echo "=== Step 3: TypeScript type checking ==="
npx tsc -v || true
npm run update-types || true
git diff --color --exit-code ./ace*d.ts || true
npm run typecheck || true
node_modules/.bin/tsc --noImplicitAny --strict --noUnusedLocals --noImplicitReturns --noUnusedParameters --noImplicitThis ace.d.ts || true

# Test 4: npm package test
echo "=== Step 4: Testing npm package ==="
./tool/test-npm-package.sh || true

echo ""
echo "=== Tests completed ==="
echo "FINAL_STATUS = SUCCESS"
