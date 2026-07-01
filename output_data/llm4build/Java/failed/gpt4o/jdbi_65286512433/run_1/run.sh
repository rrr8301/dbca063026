#!/bin/bash

# Print Java and Maven versions
java -version
mvn -version

# Build the project
mvn clean install -Drat.skip=true -Dlicense.skip=true

# Run tests
mvn test -Drat.skip=true -Dlicense.skip=true