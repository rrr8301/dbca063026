#!/bin/bash

# Activate any necessary environments (none needed for Java)

# Install project dependencies (none needed as Maven handles it)

# Build the project with Maven
mvn --batch-mode --update-snapshots verify

# Run Checkstyle
mvn checkstyle:check

# Run SpotBugs
mvn spotbugs:check

# Run PMD
mvn pmd:check

# Ensure all tests are executed, even if some fail
set +e
mvn test
set -e