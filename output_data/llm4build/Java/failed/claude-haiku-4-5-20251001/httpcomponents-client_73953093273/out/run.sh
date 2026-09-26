#!/bin/bash

set -e

# Set JDK toolchain version based on matrix java version
HC_BUILD_TOOLCHAIN_VERSION=1.8

# Set TOOLCHAIN_JAVA_HOME to JDK 8
TOOLCHAIN_JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64

# Create Maven configuration directory
mkdir -p "${HOME}/.m2"

# Configure Maven toolchains
cat > "${HOME}/.m2/toolchains.xml" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<toolchains>
  <toolchain>
    <type>jdk</type>
    <provides>
      <version>${HC_BUILD_TOOLCHAIN_VERSION}</version>
    </provides>
    <configuration>
      <jdkHome>${TOOLCHAIN_JAVA_HOME}</jdkHome>
    </configuration>
  </toolchain>
</toolchains>
EOF

# Build with Maven using system mvn (avoids wrapper validation issues)
mvn -V --file pom.xml --no-transfer-progress -DtrimStackTrace=false -Djunit.jupiter.execution.parallel.enabled=false -Dhc.build.toolchain.version="${HC_BUILD_TOOLCHAIN_VERSION}" -Pdocker -Drat.skip=true -Dlicense.skip=true