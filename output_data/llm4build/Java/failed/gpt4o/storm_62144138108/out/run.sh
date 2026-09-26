#!/bin/bash

# Activate environments
export PATH="/usr/local/bin:$PATH"

# Set up Python environment
python3.10 -m pip install --upgrade pip

# Set up Node environment
npm install -g npm@latest

# Set up Ruby environment
gem update --system

# Set up Java environment
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
export PATH=$JAVA_HOME/bin:$PATH

# Ensure a clean state without storm artifacts
rm -rf ~/.m2/repository/org/apache/storm

# Set up project dependencies
/bin/bash ./dev-tools/gitact/gitact-install.sh `pwd`

# Run build
export JDK_VERSION=17
export USER=github
/bin/bash ./dev-tools/gitact/gitact-script.sh `pwd` Server

# Run tests (assuming Maven is used for testing)
mvn test || true  # Ensure all tests run even if some fail