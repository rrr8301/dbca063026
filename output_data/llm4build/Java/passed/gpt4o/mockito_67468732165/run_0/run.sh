#!/bin/bash

# Set Java environment variables
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
export PATH=$JAVA_HOME/bin:$PATH

# Build the project
./gradlew -Pmockito.test.java=11 build --stacktrace --scan

# Generate coverage report
./gradlew -Pmockito.test.java=11 coverageReport --stacktrace --scan

# Note: Test failures will not stop the execution of subsequent commands