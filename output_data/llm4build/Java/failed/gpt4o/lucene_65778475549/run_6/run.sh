#!/bin/bash

# Activate SDKMAN
source "$HOME/.sdkman/bin/sdkman-init.sh"

# Set Java version to 25
sdk use java 25.0.0-tem

# Set Gradle version
sdk use gradle 7.5 # Specify the same Gradle version as installed

# Run Gradle tests
./gradlew displayGradleDiagnostics allOptions test "-Ptask.times=true" "-Pvalidation.errorprone=false" || true

# List automatically-initialized gradle.properties
if [ -f gradle.properties ]; then
    cat gradle.properties
else
    echo "gradle.properties file not found."
fi