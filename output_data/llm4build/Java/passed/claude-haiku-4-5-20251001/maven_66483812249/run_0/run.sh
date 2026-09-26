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
echo "Building Maven distribution from source"
echo "=========================================="

# Bootstrap Maven using the embedded Maven wrapper or build from source
# This simulates the artifact download from the initial-build job
if [ -f mvnw ]; then
    echo "Using Maven wrapper..."
    ./mvnw -DdistributionTargetDir="$PWD/maven-dist" clean package -DskipTests -B -V || true
else
    echo "Maven wrapper not found, attempting to build with system Maven..."
    # Fallback: assume Maven 3.9.0+ is available or build manually
    if command -v mvn &> /dev/null; then
        mvn -DdistributionTargetDir="$PWD/maven-dist" clean package -DskipTests -B -V || true
    else
        echo "WARNING: No Maven found. Attempting to download and extract Maven manually..."
        mkdir -p maven-dist
        # This is a fallback; in practice, the artifact should be available
    fi
fi

# Extract Maven distribution if tar.gz exists
if ls maven-dist/apache-maven-*-bin.tar.gz 1> /dev/null 2>&1; then
    echo "Extracting Maven distribution..."
    mkdir -p maven-local
    tar xzf maven-dist/apache-maven-*-bin.tar.gz -C maven-local --strip-components 1
    export MAVEN_HOME=$PWD/maven-local
    export PATH=$PWD/maven-local/bin:$PATH
else
    echo "Maven distribution not found in maven-dist/. Using system Maven."
    if ! command -v mvn &> /dev/null; then
        echo "ERROR: Maven not available and distribution not found."
        exit 1
    fi
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

if mvn site -e -B -V -Preporting; then
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