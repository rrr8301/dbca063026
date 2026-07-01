#!/bin/bash

# Activate environment
export JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64
export PATH=$JAVA_HOME/bin:$PATH

# Install project dependencies
mvn install -DskipTests=true -Dmaven.javadoc.skip=true -B -V

# Run tests
mvn test -B

# Generate Javadoc
mvn -P '!examples' javadoc:javadoc