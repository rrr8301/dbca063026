#!/usr/bin/env bash
set -e

cd /app

echo "=== Java Version ==="
java -version

echo ""
echo "=== Maven Version ==="
./mvnw --version

echo ""
echo "=== Building code ==="
./mvnw clean install -Pfast -B -ff

echo ""
echo "=== Running tests ==="
./mvnw surefire:test invoker:integration-test invoker:verify -B -ff

echo ""
echo "FINAL_STATUS = SUCCESS"
