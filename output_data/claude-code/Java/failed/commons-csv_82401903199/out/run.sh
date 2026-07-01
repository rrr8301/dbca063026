#!/usr/bin/env bash
set -e

cd /app
mvn -Ddoclint=all --show-version --batch-mode --no-transfer-progress

echo "FINAL_STATUS = SUCCESS"
