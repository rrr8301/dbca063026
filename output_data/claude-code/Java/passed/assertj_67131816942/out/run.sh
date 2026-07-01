#!/usr/bin/env bash
set -e

cd /app

export MAVEN_ARGS="-B -V -ntp -e -Djansi.passthrough=true -Dstyle.color=always"

echo "=========================================="
echo "Running tests with: ./mvnw $MAVEN_ARGS verify"
echo "=========================================="

./mvnw $MAVEN_ARGS verify

echo ""
echo "=========================================="
echo "FINAL_STATUS = SUCCESS"
echo "=========================================="
