#!/usr/bin/env bash
set -e

cd /app

echo "=== Starting Maven build ==="
echo "Java version:"
java -version

echo ""
echo "Maven version:"
mvn --version

echo ""
echo "=== Running: mvn -B package --file pom.xml ==="
mvn -B package --file pom.xml

MAVEN_EXIT=$?

if [ $MAVEN_EXIT -eq 0 ]; then
    echo ""
    echo "=== Build successful ==="
    echo "FINAL_STATUS = SUCCESS"
else
    echo ""
    echo "=== Build failed ==="
    echo "FINAL_STATUS = FAIL"
    exit 1
fi
