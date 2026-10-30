#!/bin/bash
set -e

# Switch to Java 25 for build
export JAVA_HOME=/usr/lib/jvm/java-25-openjdk-amd64
export PATH=$JAVA_HOME/bin:$PATH

echo "=== Build JDK Version ==="
java -version

echo "=== Maven Version ==="
mvn --version

echo "=== Running install-fast ==="
make install-fast

# Switch to Java 17 for tests
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
export PATH=$JAVA_HOME/bin:$PATH

echo "=== Test JDK Version ==="
java -version

echo "=== Running tests ==="
make run-tests

echo "=== Build and tests completed successfully ==="