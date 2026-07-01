#!/bin/bash

set -e

# Enable error handling: continue on test failures but track exit code
TEST_FAILED=0

echo "=========================================="
echo "Debezium MySQL Connector Build"
echo "=========================================="

# Verify Java installation
echo "Java version:"
java -version

# Verify Maven wrapper exists
if [ ! -f "./mvnw" ]; then
    echo "ERROR: Maven wrapper not found. Ensure mvnw is in the repository root."
    exit 1
fi

# Make Maven wrapper executable
chmod +x ./mvnw

echo "Maven version:"
./mvnw --version

# Define matrix combinations (excluding certain profiles for older versions)
declare -a PROFILES=("mysql-ci" "mysql-ci-gtids" "mysql-ci-percona" "mysql-ci-ssl")
declare -a VERSIONS=("8.0" "8.4" "9.1")

# Build matrix with exclusions
BUILDS=(
    # MySQL 8.0 - all profiles except gtids and ssl
    "mysql-ci:8.0"
    "mysql-ci-percona:8.0"
    
    # MySQL 8.4 - all profiles except gtids and ssl
    "mysql-ci:8.4"
    "mysql-ci-percona:8.4"
    
    # MySQL 9.1 - all profiles
    "mysql-ci:9.1"
    "mysql-ci-gtids:9.1"
    "mysql-ci-percona:9.1"
    "mysql-ci-ssl:9.1"
)

echo "=========================================="
echo "Starting MySQL Connector Builds"
echo "=========================================="

for BUILD in "${BUILDS[@]}"; do
    IFS=':' read -r PROFILE VERSION <<< "$BUILD"
    
    echo ""
    echo "=========================================="
    echo "Building: MySQL $VERSION - $PROFILE"
    echo "=========================================="
    
    BUILD_CMD="./mvnw clean install -B \
        -pl debezium-connector-mysql -am \
        -P$PROFILE \
        -Dcheckstyle.skip=true \
        -Dformat.skip=true \
        -Dversion.mysql.server=$VERSION \
        -Dorg.slf4j.simpleLogger.log.org.apache.maven.cli.transfer.Slf4jMavenTransferListener=warn \
        -Dmaven.wagon.http.pool=false \
        -Dmaven.wagon.httpconnectionManager.ttlSeconds=120 \
        -DfailFlakyTests=false \
        -Ddebezium.test.mongo.replica.primary.startup.timeout.seconds=120"
    
    if eval "$BUILD_CMD"; then
        echo "✓ Build successful: MySQL $VERSION - $PROFILE"
    else
        echo "✗ Build failed: MySQL $VERSION - $PROFILE"
        TEST_FAILED=1
    fi
done

echo ""
echo "=========================================="
echo "Build Summary"
echo "=========================================="

if [ $TEST_FAILED -eq 0 ]; then
    echo "✓ All builds completed successfully"
    exit 0
else
    echo "✗ Some builds failed (see above for details)"
    exit 1
fi