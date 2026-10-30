#!/bin/bash

set -e

# Start MySQL service
echo "Starting MySQL service..."
service mysql start

# Wait for MySQL to be ready
sleep 5

# Create database and load DDL
echo "Setting up MySQL database..."
mysql -u root -proot -e 'CREATE DATABASE IF NOT EXISTS AmbryRepairRequests;'
mysql -u root -proot AmbryRepairRequests < /workspace/ambry-mysql/src/main/resources/AmbryRepairRequests.ddl

# Create MySQL user
echo "Creating MySQL user 'travis'..."
mysql -u root -proot -e "CREATE USER IF NOT EXISTS 'travis'@'localhost';"
mysql -u root -proot -e "GRANT ALL PRIVILEGES ON * . * TO 'travis'@'localhost';"
mysql -u root -proot -e 'FLUSH PRIVILEGES;'

# Start Azurite in background
echo "Starting Azurite..."
killall azurite || true
azurite --silent &
sleep 3

# Run Gradle tests
echo "Running Gradle tests..."
cd /workspace
./gradlew --scan -x :ambry-store:test build codeCoverageReport

echo "Tests completed successfully!"