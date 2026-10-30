#!/usr/bin/env bash

set -e

# Set up environment variables
export HC_BUILD_TOOLCHAIN_VERSION="21"
export JAVA_HOME_21="/usr/lib/jvm/java-21-openjdk-amd64"
export JAVA_HOME_17="/usr/lib/jvm/java-17-openjdk-amd64"

# Set up Maven to use JDK 17 runtime
export JAVA_HOME=$JAVA_HOME_17

# Configure Maven toolchains
mkdir -p "${HOME}/.m2"
cat > "${HOME}/.m2/toolchains.xml" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<toolchains>
  <toolchain>
    <type>jdk</type>
    <provides>
      <version>${HC_BUILD_TOOLCHAIN_VERSION}</version>
    </provides>
    <configuration>
      <jdkHome>${JAVA_HOME_21}</jdkHome>
    </configuration>
  </toolchain>
</toolchains>
EOF

# Run Maven build using system Maven instead of mvnw
cd /app
mvn -V --file pom.xml --no-transfer-progress -DtrimStackTrace=false -Djunit.jupiter.execution.parallel.enabled=false -Dhc.build.toolchain.version="${HC_BUILD_TOOLCHAIN_VERSION}" -Pdocker

if [ $? -eq 0 ]; then
    echo "FINAL_STATUS = SUCCESS"
else
    echo "FINAL_STATUS = FAIL"
    exit 1
fi
