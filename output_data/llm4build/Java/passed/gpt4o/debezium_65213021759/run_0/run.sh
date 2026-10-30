#!/bin/bash

# Activate environment variables if needed
# (none specified in the job, so this is a placeholder)

# Install project dependencies and build
./mvnw clean install -B -pl debezium-connector-mysql -am \
    -Pmysql-ci \
    -Dcheckstyle.skip=true \
    -Dformat.skip=true \
    -Dversion.mysql.server=8.4 \
    -Dorg.slf4j.simpleLogger.log.org.apache.maven.cli.transfer.Slf4jMavenTransferListener=warn \
    -Dmaven.wagon.http.pool=false \
    -Dmaven.wagon.httpconnectionManager.ttlSeconds=120 \
    -DfailFlakyTests=false \
    -Ddebezium.test.mongo.replica.primary.startup.timeout.seconds=120

# Run tests
# Ensure all tests are executed, even if some fail
set +e
./mvnw test
set -e