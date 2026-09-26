#!/bin/bash

set -e

# Start MySQL service
echo "Starting MySQL service..."
service mysql start

# Wait for MySQL to be ready
sleep 5

# Create database and load schema
echo "Setting up MySQL database..."
mysql -uroot -proot -e 'CREATE DATABASE IF NOT EXISTS AmbryRepairRequests;'
mysql -uroot -proot -e 'USE AmbryRepairRequests; SOURCE ./ambry-mysql/src/main/resources/AmbryRepairRequests.ddl;'

# Create MySQL user
echo "Creating MySQL user..."
mysql -uroot -proot -e "CREATE USER IF NOT EXISTS 'travis'@'localhost';"
mysql -uroot -proot -e "GRANT ALL PRIVILEGES ON *.* TO 'travis'@'localhost';"
mysql -uroot -proot -e 'FLUSH PRIVILEGES;'

# Kill any existing azurite processes and start Azurite
echo "Starting Azurite..."
killall azurite || true
azurite --silent &
AZURITE_PID=$!

# Wait for Azurite to start
sleep 3

# Run Gradle tests
echo "Running Gradle tests..."
./gradlew --scan -x :ambry-store:test build codeCoverageReport

# Cleanup
kill $AZURITE_PID || true

echo "Tests completed successfully!"