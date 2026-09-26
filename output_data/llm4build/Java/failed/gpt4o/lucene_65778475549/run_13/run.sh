#!/bin/bash

# Activate SDKMAN
source "$HOME/.sdkman/bin/sdkman-init.sh"

# Set Java version to the valid version installed
sdk use java 17.0.8-tem

# Set Gradle version
sdk use gradle 7.5

# Run Gradle tests
./gradlew displayGradleDiagnostics allOptions test "-Ptask.times=true" "-Pvalidation.errorprone=false" || true

# List automatically-initialized gradle.properties
if [ -f gradle.properties ]; then
    cat gradle.properties
else
    echo "gradle.properties file not found."
fi