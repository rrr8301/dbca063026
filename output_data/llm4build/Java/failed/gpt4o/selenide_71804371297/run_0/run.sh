#!/bin/bash

# Ensure Gradle is available
export PATH=$PATH:/opt/gradle/gradle-7.5/bin

# Run tests
./gradlew check --no-parallel --no-daemon --console=plain