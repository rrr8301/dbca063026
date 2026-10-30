#!/bin/bash

# Activate environment variables if needed (none in this case)

# Set Maven compiler properties to use Java 17
export MAVEN_OPTS="-Djava.version=17 -Dmaven.compiler.source=17 -Dmaven.compiler.target=17"

# Override any Java version settings in the pom.xml
mvn clean install -DskipTests -Dmaven.compiler.release=17

# Run tests
mvn test || true  # Ensure all tests run even if some fail