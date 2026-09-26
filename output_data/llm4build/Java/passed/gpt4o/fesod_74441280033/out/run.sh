#!/bin/bash

# Set up Java environment
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
export PATH=$JAVA_HOME/bin:$PATH

# Install project dependencies and run tests
./mvnw clean package -B -Dmaven.test.skip=false -pl fesod-common,fesod-shaded,fesod-sheet,fesod-examples/fesod-sheet-examples

# Build the project
./mvnw install -B -V

# Generate JavaDoc
./mvnw javadoc:javadoc