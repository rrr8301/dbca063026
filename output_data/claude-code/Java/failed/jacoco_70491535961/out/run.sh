#!/usr/bin/env bash
set -e

# Use JDK 21 to run Maven (enforcer requires 21+)
export JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64
export PATH=$JAVA_HOME/bin:$PATH

# Verify Java is available
java -version

# Generate toolchains.xml - use JDK 11 for compilation
cat > toolchains.xml << 'EOF'
<toolchains>
  <toolchain>
    <type>jdk</type>
    <provides>
      <id>11</id>
      <version>11</version>
    </provides>
    <configuration>
      <jdkHome>/usr/lib/jvm/java-11-openjdk-amd64</jdkHome>
    </configuration>
  </toolchain>
</toolchains>
EOF

# Run Maven verify with JDK 11 as target
./mvnw -V -B -e --no-transfer-progress \
  verify -Djdk.version=11 -Dbytecode.version=11 \
  --toolchains=toolchains.xml

# If we got here, tests ran
FINAL_STATUS=SUCCESS
echo "FINAL_STATUS = $FINAL_STATUS"
