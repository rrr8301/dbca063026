#!/bin/bash

# Activate Java environment
export JAVA_HOME=/usr/lib/jvm/java-25-openjdk-amd64
export PATH=$JAVA_HOME/bin:$PATH

# Install project dependencies
mvn install -DskipTests

# Run tests
mvn package -pl quarkus/server/,quarkus/dist/
mvn package -f tests/pom.xml -Dtest=Base1TestSuite -Drat.skip=true -Dlicense.skip=true