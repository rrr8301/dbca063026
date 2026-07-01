#!/bin/bash

set -e

# Print Java and Maven versions for debugging
echo "=== Java Version ==="
java -version

echo ""
echo "=== Maven Version ==="
mvn --version

echo ""
echo "=== Starting Compilation and Unit Tests ==="

# Run Maven compile and unit tests with the exact command from the workflow
# Capture output to both stdout and maven-output.log
set +e
mvn -B -U -DembeddingsSkipCache -T8C test javadoc:aggregate 2>&1 | tee maven-output.log
MAVEN_EXIT_CODE=$?
set -e

# Check if Maven failed
if [ $MAVEN_EXIT_CODE -ne 0 ]; then
    echo ""
    echo "## Build Errors (JDK 21)"
    echo ""
    
    # Extract and surface build errors from the log
    if [ -f maven-output.log ]; then
        echo "### Maven Output Log:"
        tail -100 maven-output.log
    fi
    
    exit $MAVEN_EXIT_CODE
fi

echo ""
echo "=== Build and Tests Completed Successfully ==="
exit 0