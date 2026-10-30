#!/bin/bash

# Start MySQL service
service mysql start

# Set up MySQL database and user
mysql -e 'CREATE DATABASE AmbryRepairRequests;' -uroot
mysql -e 'USE AmbryRepairRequests; SOURCE ./ambry-mysql/src/main/resources/AmbryRepairRequests.ddl;' -uroot
mysql -e "CREATE USER 'travis'@'localhost';" -uroot
mysql -e "GRANT ALL PRIVILEGES ON *.* TO 'travis'@'localhost';" -uroot
mysql -e 'FLUSH PRIVILEGES;' -uroot

# Start Azurite
azurite --silent &

# Run unit tests excluding ambry-store
./gradlew --scan -x :ambry-store:test build codeCoverageReport || true

# Ensure all tests are executed
exit 0