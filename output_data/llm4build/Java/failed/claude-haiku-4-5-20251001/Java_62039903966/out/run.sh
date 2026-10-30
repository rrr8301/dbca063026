#!/bin/bash

set -e

cd /workspace

echo "=== Building with Maven ==="
mvn --batch-mode --update-snapshots verify

echo "=== Running Checkstyle ==="
mvn checkstyle:check

echo "=== Running SpotBugs ==="
mvn spotbugs:check

echo "=== Running PMD ==="
mvn pmd:check

echo "=== All checks passed ==="