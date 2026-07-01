#!/usr/bin/env bash
set -e

cd /app

# Generate toolchains.xml for JDK 18
JDK_VERSION=18
JDK_HOME_VARIABLE_NAME=JAVA_HOME_18_X64

echo "
<toolchains>
  <toolchain>
    <type>jdk</type>
    <provides>
      <id>$JDK_VERSION</id>
      <version>$JDK_VERSION</version>
    </provides>
    <configuration>
      <jdkHome>${!JDK_HOME_VARIABLE_NAME}</jdkHome>
    </configuration>
  </toolchain>
</toolchains>
" > toolchains.xml

echo "Generated toolchains.xml:"
cat toolchains.xml

# Run Maven build using installed Maven 3.9.12
echo "Starting Maven build..."
/opt/apache-maven-3.9.12/bin/mvn -V -B -e --no-transfer-progress \
  verify -Djdk.version=18 -Dbytecode.version=18 \
  --toolchains=toolchains.xml

echo "FINAL_STATUS = SUCCESS"
