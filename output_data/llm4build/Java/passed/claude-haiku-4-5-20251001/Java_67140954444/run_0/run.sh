#!/bin/bash

set -e

# Print Java and Maven versions for debugging
echo "Java version:"
java -version
echo ""
echo "Maven version:"
mvn -version
echo ""

# Change to workspace directory
cd /workspace

# Run Maven verify (includes compilation and unit tests)
echo "Running Maven verify..."
mvn --batch-mode --update-snapshots verify

# Run Checkstyle
echo ""
echo "Running Checkstyle..."
mvn checkstyle:check

# Run SpotBugs
echo ""
echo "Running SpotBugs..."
mvn spotbugs:check

# Run PMD
echo ""
echo "Running PMD..."
mvn pmd:check

echo ""
echo "All checks completed successfully!"