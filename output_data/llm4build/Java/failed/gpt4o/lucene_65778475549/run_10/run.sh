#!/bin/bash

# Activate SDKMAN
source "$HOME/.sdkman/bin/sdkman-init.sh"

# Set Java version to 21 (assuming Java 21 is available as 21.0.0-zulu)
sdk use java 21.0.0-zulu

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