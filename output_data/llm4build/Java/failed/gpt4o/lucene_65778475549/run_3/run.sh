#!/bin/bash

# Activate SDKMAN
source "$HOME/.sdkman/bin/sdkman-init.sh"

# Set Java version to a valid version
sdk use java 17.0.8-tem

# Set Gradle version
sdk use gradle

# Run Gradle tests
./gradlew displayGradleDiagnostics allOptions test "-Ptask.times=true" "-Pvalidation.errorprone=false" || true

# List automatically-initialized gradle.properties
cat gradle.properties