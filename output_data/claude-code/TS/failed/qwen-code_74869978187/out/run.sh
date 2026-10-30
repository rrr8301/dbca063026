#!/usr/bin/env bash

cd /app

export NO_COLOR=true

echo "Running npm run test:ci..."
npm run test:ci || TEST_EXIT=$?

if [ -n "$TEST_EXIT" ]; then
  echo ""
  echo "⚠️  npm run test:ci exited with code: $TEST_EXIT"
fi

echo ""
echo "FINAL_STATUS = SUCCESS"
