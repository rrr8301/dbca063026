#!/bin/bash

# Activate environment variables
export JAVA_HOME=/usr/lib/jvm/zulu-17-amd64
export PATH=$JAVA_HOME/bin:$PATH

# Generate toolchains.xml
cat <<EOF > toolchains.xml
<toolchains>
  <toolchain>
    <type>jdk</type>
    <provides>
      <id>17</id>
      <version>17</version>
    </provides>
    <configuration>
      <jdkHome>$JAVA_HOME</jdkHome>
    </configuration>
  </toolchain>
</toolchains>
EOF

# Build the project
mvn -V -B -e --no-transfer-progress \
  verify -Djdk.version=17 -Dbytecode.version=17 \
  --toolchains=toolchains.xml -Drat.skip=true -Dlicense.skip=true