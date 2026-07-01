#!/bin/bash

set -e

echo "=========================================="
echo "Maven Build and Test Execution"
echo "=========================================="

# Set environment variables (non-deployment scenario)
echo "Setting environment variables..."
export MVN_ADDITIONAL_OPTS=""
export MVN_GOAL="install"

# Display Java and Maven versions
echo "Java version:"
java -version
echo ""
echo "Maven version:"
mvn -version
echo ""

# Navigate to workspace
cd /workspace

# Clean previous builds
echo "Cleaning previous builds..."
mvn clean

# Build with Maven
# Profiles: coverage (JaCoCo), integrationTesting (JCR TCK and integration tests), javadoc
# Properties: nsfixtures for segment tar and document namespace tests
echo "Building with Maven..."
echo "Goal: $MVN_GOAL"
echo "Additional options: $MVN_ADDITIONAL_OPTS"
echo ""

mvn -B $MVN_GOAL $MVN_ADDITIONAL_OPTS \
    -Pcoverage,integrationTesting,javadoc \
    -Dnsfixtures=SEGMENT_TAR,DOCUMENT_NS

BUILD_STATUS=$?

echo ""
echo "=========================================="
if [ $BUILD_STATUS -eq 0 ]; then
    echo "Build completed successfully!"
    echo "Compiled classes and coverage reports available in target/ directories"
else
    echo "Build failed with exit code: $BUILD_STATUS"
fi
echo "=========================================="

exit $BUILD_STATUS