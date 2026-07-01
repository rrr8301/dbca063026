#!/usr/bin/env bash
set -e

echo "Starting test run..."

# Run the test command from the workflow
pnpm test

# If we get here, tests passed
echo "FINAL_STATUS = SUCCESS"
