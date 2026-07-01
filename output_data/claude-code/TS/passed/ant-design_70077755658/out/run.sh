#!/usr/bin/env bash

set -e

echo "====== Starting ant-design test-react-legacy (18, 1/2) ======"
echo "Environment: REACT=${REACT}, SKIP_SEMANTIC=${SKIP_SEMANTIC}"

cd /app

# Run the test command
npm test -- --maxWorkers=2 --shard=1/2 --coverage

echo "====== Tests completed successfully ======"
echo "FINAL_STATUS = SUCCESS"
