#!/bin/bash

set -e

# Set environment variables
export MY_VAR="PATH"
export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
export PATH=$PATH:$JAVA_HOME/bin

# Verify Java installation
java -version

# Verify Python installation
python3.8 --version

# Verify Maven installation
mvn --version

# Run the CI script
python3.8 ./ci/run_ci.py java --version 8

echo "CI job completed successfully"