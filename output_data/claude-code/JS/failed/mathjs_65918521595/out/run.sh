#!/usr/bin/env bash

export CI=true

echo "Running npm run test:src..."
npm run test:src

echo ""
echo "FINAL_STATUS = SUCCESS"
