#!/bin/bash

# Install project dependencies
mvn install -DskipTests=true -Dmaven.javadoc.skip=true -B -V

# Run tests
mvn test -B || true  # Continue even if some tests fail

# Generate Javadoc
mvn -P '!examples' javadoc:javadoc || true  # Continue even if Javadoc generation fails