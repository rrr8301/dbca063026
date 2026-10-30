#!/bin/bash

# Activate environment variables
export JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64
export PATH=$JAVA_HOME/bin:$PATH

# Print Maven version
mvn --version

# Compile and unit test with JDK 21
set -o pipefail
mvn -B -U -DembeddingsSkipCache -T8C test javadoc:aggregate 2>&1 | tee maven-output.log