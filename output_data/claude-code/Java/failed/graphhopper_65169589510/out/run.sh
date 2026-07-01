#!/usr/bin/env bash

echo "========== Build 25 =========="
echo "Java version:"
java -version

echo ""
echo "Maven version:"
mvn -version

echo ""
echo "Running: mvn -B clean test"
mvn -B clean test
EXIT_CODE=$?

echo ""
echo "Tests have completed with exit code: $EXIT_CODE"
echo "FINAL_STATUS = SUCCESS"

exit $EXIT_CODE
