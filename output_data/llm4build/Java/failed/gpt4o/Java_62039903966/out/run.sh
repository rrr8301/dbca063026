#!/bin/bash

# Run Maven build
mvn --batch-mode --update-snapshots verify

# Run Checkstyle
mvn checkstyle:check

# Run SpotBugs
mvn spotbugs:check

# Run PMD
mvn pmd:check