#!/usr/bin/env bash
set -e

cd /app/superset-frontend

# Run the exact jest test command from the workflow
npm run test -- --coverage --shard=4/8 --coverageReporters=json

echo "FINAL_STATUS = SUCCESS"
