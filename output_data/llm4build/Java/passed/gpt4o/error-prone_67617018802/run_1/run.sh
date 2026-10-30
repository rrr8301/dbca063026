#!/bin/bash

# Activate environment
export JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64
export PATH=$JAVA_HOME/bin:$PATH

# Install project dependencies
mvn install -DskipTests=true -Dmaven.javadoc.skip=true -B -V -Drat.skip=true -Dlicense.skip=true

# Run tests
mvn test -B -Drat.skip=true -Dlicense.skip=true

# Generate Javadoc
mvn -P '!examples' javadoc:javadoc -Drat.skip=true -Dlicense.skip=true