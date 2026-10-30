#!/bin/bash

# Activate environment variables
export JAVA_HOME=/opt/jdk
export PATH="$JAVA_HOME/bin:$PATH"
export MAVEN_HOME=/opt/maven
export PATH="$MAVEN_HOME/bin:$PATH"

# Build the project
make install-fast

# Run tests
make run-tests