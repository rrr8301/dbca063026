#!/bin/bash

# Clone the repository (simulating actions/checkout)
git clone <repository-url> .

# Set up Java environment
export JAVA_HOME=/usr/lib/jvm/java-25-openjdk-amd64
export PATH=$JAVA_HOME/bin:$PATH

# Run the build and test command
./gradlew build