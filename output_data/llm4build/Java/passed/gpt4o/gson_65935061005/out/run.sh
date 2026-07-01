#!/bin/bash

# Activate environment variables
export MAVEN_ARGS="--show-version --batch-mode --no-transfer-progress"

# Install project dependencies and build
mvn verify javadoc:jar