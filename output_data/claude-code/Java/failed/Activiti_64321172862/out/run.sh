#!/usr/bin/env bash
set -e

cd /app

echo "Starting Maven verify..."
mvn verify --show-version --no-transfer-progress --settings settings.xml

echo "Finding longest tests..."
find . -name TEST-*.xml -exec grep -h testcase {} \; | awk -F '"' '{printf("%s#%s() - %.3f s\n", $4, $2, $6); }' | sort -n -k 3 | tail -20

echo "FINAL_STATUS = SUCCESS"
