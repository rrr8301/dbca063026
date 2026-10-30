#!/bin/bash

set -e

# Enable error handling: continue on test failures but track exit code
TEST_FAILED=0

echo "=========================================="
echo "Maven Full Build Job"
echo "=========================================="

# Prepare Mimir configuration for Maven 4.x
echo "Preparing Mimir configuration..."
mkdir -p ~/.mimir
mkdir -p ~/.m2

if [ -f .github/ci-mimir-session.properties ]; then
    cp .github/ci-mimir-session.properties ~/.mimir/session.properties
fi

if [ -f .github/ci-mimir-daemon.properties ]; then
    cp .github/ci-mimir-daemon.properties ~/.mimir/daemon.properties
fi

if [ -f .github/ci-extensions.xml ]; then
    cp .github/ci-extensions.xml ~/.m2/extensions.xml
fi

# Create Mimir local directory
mkdir -p ~/.mimir/local

echo "=========================================="
echo "Verifying Maven installation"
echo "=========================================="

if ! command -v mvn &> /dev/null; then
    echo "ERROR: Maven is not installed."
    exit 1
fi

echo "Maven version:"
mvn --version

echo "=========================================="
echo "Running Maven verify (apache-release profile)"
echo "=========================================="

if mvn verify -Papache-release -Dgpg.skip=true -e -B -V; then
    echo "Maven verify succeeded"
else
    echo "Maven verify failed"
    TEST_FAILED=1
fi

echo "=========================================="
echo "Building site with Maven"
echo "=========================================="

if mvn site -e -B -V -Preporting -Drat.skip=true; then
    echo "Maven site build succeeded"
else
    echo "Maven site build failed"
    TEST_FAILED=1
fi

echo "=========================================="
echo "Test Summary"
echo "=========================================="

if [ $TEST_FAILED -eq 0 ]; then
    echo "All builds completed successfully"
    exit 0
else
    echo "Some builds failed. Check logs above."
    exit 1
fi