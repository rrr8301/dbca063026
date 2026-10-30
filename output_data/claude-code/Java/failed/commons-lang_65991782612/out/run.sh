#!/usr/bin/env bash

set -e

echo "=== Building with Maven ==="
mvn --errors --show-version --batch-mode --no-transfer-progress -Ddoclint=all

echo ""
echo "FINAL_STATUS = SUCCESS"
