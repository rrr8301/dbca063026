#!/bin/bash

set -e

# Print Java versions for verification
echo "=== Java Version Information ==="
java -version
javac -version
echo "JAVA_HOME: $JAVA_HOME"
echo "JAVA_HOME_18_X64: $JAVA_HOME_18_X64"
echo "JAVA_HOME_17_X64: $JAVA_HOME_17_X64"
echo ""

# Generate toolchains.xml
echo "=== Generating toolchains.xml ==="
cat > toolchains.xml << 'EOF'
<toolchains>
  <toolchain>
    <type>jdk</type>
    <provides>
      <id>18</id>
      <version>18</version>
    </provides>
    <configuration>
      <jdkHome>${JAVA_HOME_18_X64}</jdkHome>
    </configuration>
  </toolchain>
</toolchains>
EOF
echo "toolchains.xml generated successfully"
echo ""

# Build with Maven
echo "=== Building with Maven ==="
./mvnw -V -B -e --no-transfer-progress \
  verify -Djdk.version=18 -Dbytecode.version=18 \
  --toolchains=toolchains.xml

echo ""
echo "=== Build completed successfully ==="