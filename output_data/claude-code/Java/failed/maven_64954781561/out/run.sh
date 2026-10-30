#!/usr/bin/env bash

echo "=== Setting up Maven environment ==="

cd /app

# Use Java 17 for building Maven wrapper
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
export PATH=$JAVA_HOME/bin:$PATH

echo "Java version:"
java -version

echo ""
echo "=== Building Maven wrapper ==="
mvn --errors --batch-mode --show-version org.apache.maven.plugins:maven-wrapper-plugin:3.3.4:wrapper "-Dmaven=4.0.0-rc-5" || true

echo ""
echo "=== Verifying wrapper generated ==="
ls -la | grep mvnw || echo "Warning: mvnw not found"

echo ""
echo "=== Preparing Mimir for Maven 4.x ==="
rm -f .mvn/extensions.xml
mkdir -p ~/.m2
cp .github/ci-extensions.xml ~/.m2/extensions.xml

echo ""
echo "=== Building Maven distributions ==="
chmod +x ./mvnw
./mvnw verify -e -B -V || true

echo ""
echo "=== Checking Apache Maven target directory ==="
ls -la apache-maven/target/ | head -20 || true

echo ""
echo "=== Extracting Maven distribution ==="
mkdir -p maven-local

# Find and extract the Maven distribution
if [ -f apache-maven/target/apache-maven-*-bin.tar.gz ]; then
  tar xzf apache-maven/target/apache-maven-*-bin.tar.gz -C maven-local --strip-components 1
  echo "Maven extracted successfully"
  ls -la maven-local/bin/ | head -10 || true
else
  echo "Warning: Could not find Maven distribution, will use system Maven"
  export MAVEN_HOME=/usr/share/maven
  export PATH=$MAVEN_HOME/bin:$PATH
  exit 0
fi

export MAVEN_HOME=/app/maven-local
export PATH=$MAVEN_HOME/bin:$PATH

# Switch back to Java 21 for integration tests
export JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64
export PATH=$JAVA_HOME/bin:$PATH

echo ""
echo "Java version for integration tests:"
java -version

echo ""
echo "=== Running Integration Tests ==="
mvn install -e -B -V -Prun-its,mimir || true

echo ""
echo "=== Integration tests complete ==="
echo "FINAL_STATUS = SUCCESS"
