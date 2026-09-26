#!/bin/bash

set -e

# Enable error handling: continue on test failures but track exit status
OVERALL_EXIT_CODE=0

# Define matrix parameters
PROFILES=("mysql-ci" "mysql-ci-gtids" "mysql-ci-percona" "mysql-ci-ssl")
VERSIONS=("8.0" "8.4" "9.1")

# Define exclusions: profile and version combinations to skip
declare -A EXCLUSIONS
EXCLUSIONS["mysql-ci-gtids:8.0"]=1
EXCLUSIONS["mysql-ci-gtids:8.4"]=1
EXCLUSIONS["mysql-ci-ssl:8.0"]=1
EXCLUSIONS["mysql-ci-ssl:8.4"]=1

echo "=========================================="
echo "Debezium MySQL Connector Build"
echo "=========================================="
echo ""

# Verify Java installation
echo "Verifying Java installation..."
java -version
echo ""

# Verify Maven wrapper exists
if [ ! -f "./mvnw" ]; then
    echo "ERROR: Maven wrapper (./mvnw) not found!"
    exit 1
fi
echo "Maven wrapper found."
echo ""

# Iterate through matrix combinations
for PROFILE in "${PROFILES[@]}"; do
    for VERSION in "${VERSIONS[@]}"; do
        EXCLUSION_KEY="${PROFILE}:${VERSION}"
        
        # Check if this combination should be excluded
        if [ -n "${EXCLUSIONS[$EXCLUSION_KEY]}" ]; then
            echo "SKIPPING: MySQL $VERSION - $PROFILE (excluded)"
            continue
        fi
        
        echo "=========================================="
        echo "Building: MySQL $VERSION - $PROFILE"
        echo "=========================================="
        
        # Build command matching the GitHub Actions workflow
        BUILD_CMD="./mvnw clean install -B -pl debezium-connector-mysql -am \
            -P${PROFILE} \
            -Dcheckstyle.skip=true \
            -Dformat.skip=true \
            -Dversion.mysql.server=${VERSION} \
            -Dorg.slf4j.simpleLogger.log.org.apache.maven.cli.transfer.Slf4jMavenTransferListener=warn \
            -Dmaven.wagon.http.pool=false \
            -Dmaven.wagon.httpconnectionManager.ttlSeconds=120 \
            -DfailFlakyTests=false \
            -Ddebezium.test.mongo.replica.primary.startup.timeout.seconds=120"
        
        # Execute build; capture exit code but continue on failure
        if eval "$BUILD_CMD"; then
            echo "✓ Build succeeded: MySQL $VERSION - $PROFILE"
        else
            BUILD_EXIT_CODE=$?
            echo "✗ Build failed: MySQL $VERSION - $PROFILE (exit code: $BUILD_EXIT_CODE)"
            OVERALL_EXIT_CODE=$BUILD_EXIT_CODE
        fi
        
        echo ""
    done
done

echo "=========================================="
echo "Build Summary"
echo "=========================================="

if [ $OVERALL_EXIT_CODE -eq 0 ]; then
    echo "✓ All builds completed successfully!"
else
    echo "✗ Some builds failed (exit code: $OVERALL_EXIT_CODE)"
fi

exit $OVERALL_EXIT_CODE