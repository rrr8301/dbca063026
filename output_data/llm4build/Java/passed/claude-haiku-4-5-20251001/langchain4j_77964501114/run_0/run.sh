#!/bin/bash

set -e

# Print Java and Maven versions for verification
echo "=== Java Version ==="
java -version

echo ""
echo "=== Maven Version ==="
mvn --version

echo ""
echo "=== Starting Compilation and Unit Tests ==="

# Run Maven compile and unit tests with the exact command from the workflow
set -o pipefail
mvn -B -U -DembeddingsSkipCache -T8C test javadoc:aggregate -Drat.skip=true -Dlicense.skip=true 2>&1 | tee maven-output.log

echo ""
echo "=== Build and Tests Completed Successfully ==="