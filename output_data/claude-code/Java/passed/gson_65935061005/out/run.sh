#!/usr/bin/env bash
set -e

echo "=== Building Gson on JDK 21 ==="
echo ""

cd /app

echo "Running: mvn verify javadoc:jar"
mvn --show-version --batch-mode --no-transfer-progress verify javadoc:jar

echo ""
echo "=== Build completed successfully ==="
echo "FINAL_STATUS = SUCCESS"
