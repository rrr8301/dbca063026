#!/usr/bin/env bash

set -e

echo "Running Install step..."
mvn install -DskipTests=true -Dmaven.javadoc.skip=true -B -V

echo "Running Test step..."
mvn test -B

echo "Running Javadoc step..."
mvn -P '!examples' javadoc:javadoc

echo "FINAL_STATUS = SUCCESS"
