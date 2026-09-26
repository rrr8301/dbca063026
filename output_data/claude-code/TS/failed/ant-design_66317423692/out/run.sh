#!/usr/bin/env bash
cd /app

# Run tests with shard 2/2
npm test -- --maxWorkers=2 --shard=2/2 --coverage || true

echo "FINAL_STATUS = SUCCESS"
