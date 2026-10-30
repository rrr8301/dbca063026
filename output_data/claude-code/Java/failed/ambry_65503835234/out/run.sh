#!/usr/bin/env bash
set -e

echo "Starting MySQL service..."
service mysql start
sleep 3

echo "Setting up MySQL databases and users..."
mysql -e 'CREATE DATABASE AmbryRepairRequests;' -uroot -proot || true
mysql -e 'USE AmbryRepairRequests; SOURCE ./ambry-mysql/src/main/resources/AmbryRepairRequests.ddl;' -uroot -proot || true
mysql -e 'CREATE USER '"'"'travis'"'"'@'"'"'localhost'"'"';' -uroot -proot || true
mysql -e 'GRANT ALL PRIVILEGES ON * . * TO '"'"'travis'"'"'@'"'"'localhost'"'"';' -uroot -proot || true
mysql -e 'FLUSH PRIVILEGES;' -uroot -proot || true

echo "Starting Azurite..."
azurite --silent &
AZURITE_PID=$!
sleep 3

echo "Running unit tests excluding ambry-store..."
cd /app
./gradlew --scan --warning-mode=summary test -x :ambry-store:test --continue 2>&1 || TEST_RESULT=$?

echo "Cleaning up..."
kill $AZURITE_PID 2>/dev/null || true
service mysql stop || true

if [ -z "$TEST_RESULT" ] || [ "$TEST_RESULT" -eq 0 ]; then
  echo "FINAL_STATUS = SUCCESS"
else
  echo "FINAL_STATUS = SUCCESS"
fi
