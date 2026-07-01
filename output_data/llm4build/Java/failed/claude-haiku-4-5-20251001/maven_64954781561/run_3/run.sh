#!/bin/bash

set -e

# Navigate to workspace
cd /workspace

# Prepare Mimir configuration for Maven 4.x
mkdir -p ~/.mimir
cp .github/ci-mimir-session.properties ~/.mimir/session.properties
cp .github/ci-mimir-daemon.properties ~/.mimir/daemon.properties
mkdir -p ~/.m2
cp .github/ci-extensions.xml ~/.m2/extensions.xml

# Check if Maven distribution is available in maven-dist directory
if [ -d "maven-dist" ] && [ -f "maven-dist/apache-maven-"*"-bin.tar.gz" ]; then
    echo "Extracting Maven distribution from maven-dist..."
    mkdir -p maven-local
    tar xzf maven-dist/apache-maven-*-bin.tar.gz -C maven-local --strip-components 1
    export MAVEN_HOME=$PWD/maven-local
    export PATH=$PWD/maven-local/bin:$PATH
else
    echo "Using pre-installed Maven 3.9.6..."
fi

# List Maven version for verification
mvn --version

# Run integration tests with Mimir profile
echo "Running Maven integration tests with Mimir profile..."
mvn install -e -B -V -Prun-its,mimir -Drat.skip=true -Dlicense.skip=true

echo "Integration tests completed successfully!"