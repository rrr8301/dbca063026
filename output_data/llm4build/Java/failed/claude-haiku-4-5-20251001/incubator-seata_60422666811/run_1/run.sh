#!/bin/bash
set -e
mvn -T 4C clean test -P args-for-client-test -Dspring-boot.version=2.6.15 -Dspring-framework-bom.version=5.3.27 -e -B -Dorg.slf4j.simpleLogger.log.org.apache.maven.cli.transfer.Slf4jMavenTransferListener=warn -Drat.skip=true -Dlicense.skip=true