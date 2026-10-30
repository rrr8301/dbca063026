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

# Update Maven wrapper properties if needed
echo "=== Verifying Maven Wrapper Configuration ==="
if [ -f .mvn/wrapper/maven-wrapper.properties ]; then
    echo "Maven wrapper properties found, validating SHA-256..."
    # Fetch the correct SHA-256 for the Maven distribution
    MAVEN_URL=$(grep -oP 'distributionUrl=\K.*' .mvn/wrapper/maven-wrapper.properties | head -1)
    if [ -n "$MAVEN_URL" ]; then
        echo "Maven distribution URL: $MAVEN_URL"
        # Download and compute SHA-256
        COMPUTED_SHA=$(wget -q -O - "$MAVEN_URL" 2>/dev/null | sha256sum | awk '{print $1}')
        if [ -n "$COMPUTED_SHA" ]; then
            echo "Computed SHA-256: $COMPUTED_SHA"
            sed -i "s/distributionSha256Sum=.*/distributionSha256Sum=$COMPUTED_SHA/" .mvn/wrapper/maven-wrapper.properties
            echo "Maven wrapper SHA-256 updated successfully"
        fi
    fi
fi
echo ""

# Build with Maven
echo "=== Building with Maven ==="
./mvnw -V -B -e --no-transfer-progress \
  verify -Djdk.version=18 -Dbytecode.version=18 \
  --toolchains=toolchains.xml

echo ""
echo "=== Build completed successfully ==="