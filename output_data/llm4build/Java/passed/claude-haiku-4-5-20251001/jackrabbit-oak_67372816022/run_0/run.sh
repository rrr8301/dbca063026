#!/bin/bash

set -e

# Print Java and Maven versions for verification
echo "=== Java Version ==="
java -version

echo "=== Maven Version ==="
mvn -version

# Set environment variables (non-deployment scenario)
echo "=== Setting Environment Variables ==="
export MVN_ADDITIONAL_OPTS=""
export MVN_GOAL="install"

# Build the project with Maven
echo "=== Building Project ==="
mvn -B ${MVN_GOAL} ${MVN_ADDITIONAL_OPTS} \
    -Pcoverage,integrationTesting,javadoc \
    -Dnsfixtures=SEGMENT_TAR,DOCUMENT_NS

# Verify build outputs
echo "=== Build Complete ==="
echo "Compiled classes and coverage reports are available in target/ directories"

# List coverage reports if they exist
if find . -path "*/target/site/jacoco*/*.xml" -type f 2>/dev/null | grep -q .; then
    echo "=== Coverage Reports Found ==="
    find . -path "*/target/site/jacoco*/*.xml" -type f
else
    echo "=== No Coverage Reports Found (may be expected depending on build configuration) ==="
fi

exit 0