#!/bin/bash

set -e

# Set primary Java version to JDK 21
export JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64
export PATH=$JAVA_HOME/bin:$PATH

echo "=== Java Version ==="
java -version

echo "=== Maven Version ==="
mvn -version

echo "=== Installing dependencies ==="
mvn install -DskipTests=true -Dmaven.javadoc.skip=true -B -V -Drat.skip=true -Dlicense.skip=true

echo "=== Running tests ==="
mvn test -B -Drat.skip=true -Dlicense.skip=true

echo "=== Generating Javadoc ==="
mvn -P '!examples' javadoc:javadoc -Drat.skip=true -Dlicense.skip=true

echo "=== Build complete ==="