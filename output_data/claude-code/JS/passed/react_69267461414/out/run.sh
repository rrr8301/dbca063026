#!/usr/bin/env bash
set -e

cd /app

# Run the exact test command from the CI job
yarn test -r=stable --env=development --ci --shard=3/5

echo "FINAL_STATUS = SUCCESS"
