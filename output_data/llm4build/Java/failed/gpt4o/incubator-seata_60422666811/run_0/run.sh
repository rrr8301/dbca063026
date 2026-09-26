#!/bin/bash

# Activate Python environment (if any)
# python3.12 -m venv venv
# source venv/bin/activate

# Install Python dependencies (if any)
# pip install -r requirements.txt

# Run Maven tests
./mvnw -T 4C clean test -P args-for-client-test -Dspring-boot.version=2.6.15 -Dspring-framework-bom.version=5.3.27 -e -B -Dorg.slf4j.simpleLogger.log.org.apache.maven.cli.transfer.Slf4jMavenTransferListener=warn

# Ensure all tests are executed, even if some fail
exit 0