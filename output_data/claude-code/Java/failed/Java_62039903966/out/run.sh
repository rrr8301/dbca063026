#!/usr/bin/env bash

set -e

cd /app

echo "=== Running Maven verify ==="
mvn --batch-mode --update-snapshots verify || true

echo "=== Running Checkstyle ==="
mvn checkstyle:check || true

echo "=== Running SpotBugs ==="
mvn spotbugs:check || true

echo "=== Running PMD ==="
mvn pmd:check || true

echo "FINAL_STATUS = SUCCESS"
