#!/bin/bash

# Activate environment variables
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
export PATH=$JAVA_HOME/bin:$PATH

# Install project dependencies and build
mvn clean install

# Run tests
mvn test || true

# Ensure all test cases are executed
mvn verify || true

# Echo longest tests run
find . -name TEST-*.xml -exec grep -h testcase {} \; | awk -F '"' '{printf("%s#%s() - %.3f s\n", $4, $2, $6); }' | sort -n -k 3 | tail -20