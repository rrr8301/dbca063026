#!/usr/bin/env bash
set -e

# Start MySQL service
service mysql start
sleep 3

# Verify MySQL is running and database is set up
mysql -e "USE AmbryRepairRequests; SELECT 1;" -uroot -proot

# Start Azurite in the background
killall azurite || true
azurite --silent &
AZURITE_PID=$!
sleep 2

# Run the unit tests (same command as in the workflow)
cd /app
./gradlew --scan -x :ambry-store:test build codeCoverageReport
TEST_RESULT=$?

# Kill Azurite
kill $AZURITE_PID || true

# Check test result
if [ $TEST_RESULT -eq 0 ]; then
    echo "FINAL_STATUS = SUCCESS"
    exit 0
else
    echo "FINAL_STATUS = FAIL"
    exit 1
fi
