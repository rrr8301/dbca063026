#!/bin/bash

set -e

# Set JAVA_HOME to JDK 21 by default
export JAVA_HOME=/opt/jdk21
export PATH=$JAVA_HOME/bin:$PATH

echo "=== Java Version (JDK 21) ==="
java -version

echo ""
echo "=== Maven Version ==="
mvn -version

echo ""
echo "=== Installing Maven dependencies ==="
mvn install -DskipTests=true -Dmaven.javadoc.skip=true -B -V -Drat.skip=true -Dlicense.skip=true

echo ""
echo "=== Running Tests ==="
mvn test -B -Drat.skip=true -Dlicense.skip=true

echo ""
echo "=== Generating Javadoc ==="
mvn -P '!examples' javadoc:javadoc -Drat.skip=true -Dlicense.skip=true

echo ""
echo "=== All tasks completed successfully ==="