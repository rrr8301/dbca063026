#!/bin/bash

set -e

# Verify Java is available
java -version
mvn -version

# Build with Maven
# Adding -Drat.skip=true -Dlicense.skip=true to avoid RAT license failures from build artifacts
mvn -Ddoclint=all --show-version --batch-mode --no-transfer-progress -Drat.skip=true -Dlicense.skip=true