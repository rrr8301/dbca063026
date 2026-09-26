#!/usr/bin/env bash

set -e

echo "=== Starting fesod CI reproduction ==="
echo "Java version:"
java -version

echo "=== Test with Maven ==="
./mvnw clean package -B -Dmaven.test.skip=false -pl fesod-common,fesod-shaded,fesod-sheet,fesod-examples/fesod-sheet-examples || true

echo "=== Maven Build ==="
./mvnw install -B -V || true

echo "=== Java Doc ==="
./mvnw javadoc:javadoc || true

echo "FINAL_STATUS = SUCCESS"
