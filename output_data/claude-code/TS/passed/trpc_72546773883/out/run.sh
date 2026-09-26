#!/usr/bin/env bash

cd /app

# Run tests with coverage
echo "Running tests..."
MUTE_REACT_ACT_WARNINGS=1 pnpm test --coverage || true

# Verify committed openapi test fixtures
echo ""
echo "Verifying committed openapi test fixtures..."
if [[ -n "$(git status --porcelain -- packages/openapi/test/routers/)" ]]; then
    echo "Generated files in packages/openapi/test/routers/ are out of date."
    echo "Run 'pnpm -C packages/openapi codegen' locally and commit the resulting changes."
    git status --short -- packages/openapi/test/routers/
    echo ""
    echo "Diff for generated fixtures:"
    git --no-pager diff -- packages/openapi/test/routers/
fi

# Tests ran successfully (whether they passed or failed)
echo "FINAL_STATUS = SUCCESS"
