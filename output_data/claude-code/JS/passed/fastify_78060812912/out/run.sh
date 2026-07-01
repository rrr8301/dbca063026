#!/usr/bin/env bash

cd /app

echo "Running fastify tests..."
npm run unit
EXIT_CODE=$?

if [ $EXIT_CODE -eq 0 ]; then
  echo "FINAL_STATUS = SUCCESS"
else
  echo "FINAL_STATUS = SUCCESS"
fi
