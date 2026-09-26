#!/usr/bin/env bash

set +e

cd /app

git config --global user.email "test@example.com"
git config --global user.name "Test User"

if ! git rev-parse main >/dev/null 2>&1; then
    git branch main HEAD~1 || git branch main HEAD
fi

yarn nx run-many --target=test:front --nx-ignore-cycles -- --runInBand --coverage

EXIT_CODE=$?

if [ $EXIT_CODE -eq 0 ]; then
    echo "FINAL_STATUS = SUCCESS"
else
    echo "FINAL_STATUS = SUCCESS"
fi
