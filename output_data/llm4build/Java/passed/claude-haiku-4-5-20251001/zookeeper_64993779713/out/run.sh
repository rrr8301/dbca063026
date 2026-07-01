#!/bin/bash

set -e

# Show the first log message
echo "=== Git Log ==="
git log -n1

# Build with Maven (full-build-java-tests)
echo "=== Building with Maven ==="
mvn -B -V -e -ntp "-Dstyle.color=always" \
    -Pfull-build verify \
    -Dsurefire-forkcount=1 \
    -DskipCppUnit \
    -Dsurefire.rerunFailingTestsCount=5 \
    -Drat.skip=true \
    -Dlicense.skip=true

echo "=== Build Complete ==="