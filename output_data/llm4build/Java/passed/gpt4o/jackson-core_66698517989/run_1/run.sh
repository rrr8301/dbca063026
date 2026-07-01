#!/bin/bash

# Activate Java environment
export JAVA_HOME=/opt/jdk-25
export PATH="$JAVA_HOME/bin:$PATH"

# Install project dependencies and run tests
./mvnw -B -ff -ntp verify

# Extract project Maven version
version=$(./mvnw org.apache.maven.plugins:maven-help-plugin:3.5.1:evaluate -DforceStdout -Dexpression=project.version -q)
echo "Project version: $version"

# Verify Android SDK Compatibility
./mvnw -B -q -ff -ntp -DskipTests animal-sniffer:check

# Generate code coverage
./mvnw -B -q -ff -ntp test jacoco:report

# Note: Deployment and publishing steps are skipped