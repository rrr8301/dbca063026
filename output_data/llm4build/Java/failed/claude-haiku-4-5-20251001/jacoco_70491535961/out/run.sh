#!/bin/bash
set -e

# Default values for matrix parameters
JDK_VERSION=${JDK_VERSION:-11}
ECJ_ENABLED=${ECJ_ENABLED:-false}

echo "=========================================="
echo "Building JacoCo with JDK $JDK_VERSION"
if [ "$ECJ_ENABLED" = "true" ]; then
    echo "ECJ compiler enabled"
fi
echo "=========================================="

# Navigate to the repository root
cd /workspace

# Generate toolchains.xml for Maven
JDK_HOME_VARIABLE_NAME="JAVA_HOME_${JDK_VERSION}_X64"
JDK_HOME_VALUE="${!JDK_HOME_VARIABLE_NAME}"

if [ -z "$JDK_HOME_VALUE" ]; then
    echo "ERROR: JDK home variable $JDK_HOME_VARIABLE_NAME is not set"
    exit 1
fi

echo "Using JDK home: $JDK_HOME_VALUE"

cat > toolchains.xml <<EOF
<toolchains>
  <toolchain>
    <type>jdk</type>
    <provides>
      <id>$JDK_VERSION</id>
      <version>$JDK_VERSION</version>
    </provides>
    <configuration>
      <jdkHome>$JDK_HOME_VALUE</jdkHome>
    </configuration>
  </toolchain>
</toolchains>
EOF

echo "Generated toolchains.xml:"
cat toolchains.xml

# Build with Maven
echo "=========================================="
echo "Running Maven build..."
echo "=========================================="

BUILD_ARGS="-V -B -e --no-transfer-progress verify -Djdk.version=$JDK_VERSION -Dbytecode.version=$JDK_VERSION"

if [ "$ECJ_ENABLED" = "true" ]; then
    BUILD_ARGS="$BUILD_ARGS -Decj"
fi

BUILD_ARGS="$BUILD_ARGS --toolchains=toolchains.xml -Drat.skip=true -Dlicense.skip=true"

mvn $BUILD_ARGS

echo "=========================================="
echo "Build completed successfully!"
echo "=========================================="