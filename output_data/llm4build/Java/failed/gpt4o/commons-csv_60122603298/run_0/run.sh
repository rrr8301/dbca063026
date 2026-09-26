#!/bin/bash

# Set up Java environment
export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
export PATH=$JAVA_HOME/bin:$PATH

# Build with Maven
mvn -Ddoclint=all --show-version --batch-mode --no-transfer-progress