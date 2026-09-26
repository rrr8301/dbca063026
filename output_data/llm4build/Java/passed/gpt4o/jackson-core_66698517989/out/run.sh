#!/bin/bash

# Activate Java environment
# Comment out JAVA_HOME as JDK 25 is not installed
# export JAVA_HOME=/opt/jdk-25
# export PATH="$JAVA_HOME/bin:$PATH"

# Ensure Maven wrapper is executable
chmod +x ./mvnw

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