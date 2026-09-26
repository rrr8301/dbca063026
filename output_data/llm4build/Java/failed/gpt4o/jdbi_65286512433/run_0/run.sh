#!/bin/bash

# Print Java and Maven versions
java -version
mvn -version

# Build the project
make install-fast

# Run tests
make run-tests