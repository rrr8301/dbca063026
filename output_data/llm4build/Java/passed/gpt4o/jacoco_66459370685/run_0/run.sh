#!/bin/bash

# Activate environment variables
export JAVA_HOME=/opt/zulu18.0.0-linux_x64
export PATH=$JAVA_HOME/bin:$PATH

# Generate toolchains.xml
cat <<EOF > toolchains.xml
<toolchains>
  <toolchain>
    <type>jdk</type>
    <provides>
      <id>18</id>
      <version>18</version>
    </provides>
    <configuration>
      <jdkHome>$JAVA_HOME</jdkHome>
    </configuration>
  </toolchain>
</toolchains>
EOF

# Build the project
mvn -V -B -e --no-transfer-progress \
  verify -Djdk.version=18 -Dbytecode.version=18 \
  --toolchains=toolchains.xml -Drat.skip=true -Dlicense.skip=true