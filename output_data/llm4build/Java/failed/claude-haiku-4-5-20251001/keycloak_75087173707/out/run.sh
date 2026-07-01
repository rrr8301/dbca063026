#!/bin/bash
set -e

# Build the Quarkus distribution
mvn package -pl quarkus/server/,quarkus/dist/ -Drat.skip=true -Dlicense.skip=true -B -nsu

# Run the integration tests
mvn package -f tests/pom.xml -Dtest=Base1TestSuite -Drat.skip=true -Dlicense.skip=true -B -nsu