#!/bin/bash

set -e

# Enable error handling - continue on test failures but track exit code
test_exit_code=0

echo "=========================================="
echo "Starting Ace CI Build"
echo "=========================================="

# Clone the repository (assuming it's passed as an argument or use current directory)
if [ -z "$REPO_URL" ]; then
    echo "Using current directory as repository"
    cd /workspace
else
    echo "Cloning repository from $REPO_URL"
    git clone "$REPO_URL" /workspace
    cd /workspace
fi

echo "=========================================="
echo "Step 1: Fetch master branch"
echo "=========================================="
git fetch origin HEAD:refs/remotes/origin/HEAD --depth 1 || true

echo "=========================================="
echo "Step 2: Install npm dependencies"
echo "=========================================="
npm i

echo "=========================================="
echo "Step 3: Generate coverage report"
echo "=========================================="
npm run cover-json && mv ./coverage/coverage-final.json ./coverage/coverage.json || {
    echo "Warning: Coverage generation failed, continuing..."
    test_exit_code=1
}

echo "=========================================="
echo "Step 4: ESLint checks"
echo "=========================================="
set -x
git status
git checkout HEAD -- package.json || true
changes=$(git diff --name-only origin/HEAD --no-renames --diff-filter=ACMR 2>/dev/null || echo "")
if [ "$changes" == "" ]; then
    echo "checking all files"
    node node_modules/eslint/bin/eslint "lib/ace/**/*.js" || {
        echo "ESLint check failed"
        test_exit_code=1
    }
else
    jsChanges=$(echo "$changes" | grep -P '.js$' || :)
    if [ "$jsChanges" == "" ]; then
        echo "nothing to check"
    else
        echo "checking $jsChanges"
        node node_modules/eslint/bin/eslint $jsChanges || {
            echo "ESLint check failed"
            test_exit_code=1
        }
    fi
fi
set +x

echo "=========================================="
echo "Step 5: Type checking"
echo "=========================================="
set -x
npx tsc -v
npm run update-types || {
    echo "Type update failed"
    test_exit_code=1
}
git diff --color --exit-code ./ace*d.ts || {
    echo "Type definition changes detected"
    test_exit_code=1
}
npm run typecheck || {
    echo "Type checking failed"
    test_exit_code=1
}
node_modules/.bin/tsc --noImplicitAny --strict --noUnusedLocals --noImplicitReturns --noUnusedParameters --noImplicitThis ace.d.ts || {
    echo "Strict type checking failed"
    test_exit_code=1
}
set +x

echo "=========================================="
echo "Step 6: Test npm package"
echo "=========================================="
set -x
if [ -f "./tool/test-npm-package.sh" ]; then
    ./tool/test-npm-package.sh || {
        echo "NPM package test failed"
        test_exit_code=1
    }
else
    echo "Warning: test-npm-package.sh not found, skipping"
fi
set +x

echo "=========================================="
echo "Step 7: Run unit tests"
echo "=========================================="
npm run test || {
    echo "Unit tests failed"
    test_exit_code=1
}

echo "=========================================="
echo "CI Build Complete"
echo "=========================================="

if [ $test_exit_code -ne 0 ]; then
    echo "Some tests or checks failed. Exit code: $test_exit_code"
    exit $test_exit_code
fi

exit 0