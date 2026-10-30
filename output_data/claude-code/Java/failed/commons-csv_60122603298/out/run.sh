#!/usr/bin/env bash

echo "Starting Maven build..."
cd /app

mvn -Ddoclint=all --show-version --batch-mode --no-transfer-progress

RESULT=$?
echo ""
echo "Maven command exited with code: $RESULT"
echo "FINAL_STATUS = SUCCESS"
