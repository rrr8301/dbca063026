#!/usr/bin/env bash

set -e

cd /app

echo "Starting build process..."

echo "Step 1: Building with Maven..."
mvn --batch-mode --update-snapshots verify

echo "Step 2: Running Checkstyle..."
mvn checkstyle:check

echo "Step 3: Running SpotBugs..."
mvn spotbugs:check

echo "Step 4: Running PMD..."
mvn pmd:check

echo "All checks passed!"
FINAL_STATUS = SUCCESS
