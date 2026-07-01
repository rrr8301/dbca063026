#!/bin/bash

# Activate environment variables
export JAVA_OPTS="-XX:+TieredCompilation -XX:TieredStopAtLevel=1"

# Clone the repository (if needed, otherwise assume it's copied)
# git clone <repository-url> .
# git checkout <branch>
# git reset --hard <commit-sha>

# Install project dependencies and build
mvn -B -ff -ntp verify -Drat.skip=true -Dlicense.skip=true