#!/usr/bin/env bash

set -e

cd /app

echo "====== Running Maven Test with JDK 11 ======"

# Test with Maven (runs tests)
echo "Step 1: Running Maven clean package with tests..."
./mvnw clean package -B -Dmaven.test.skip=false -pl fesod-common,fesod-shaded,fesod-sheet,fesod-examples/fesod-sheet-examples

# Maven Build
echo "Step 2: Running Maven install..."
./mvnw install -B -V

# Java Doc
echo "Step 3: Running Java Doc..."
./mvnw javadoc:javadoc

echo "====== All steps completed successfully ======"
echo "FINAL_STATUS = SUCCESS"
