#!/bin/bash

set -e

# Enable error handling: continue on test failures but track them
FAILED_TESTS=0

# Function to run a test and track failures
run_test() {
    local test_name="$1"
    local test_command="$2"
    
    echo "=========================================="
    echo "Running: $test_name"
    echo "=========================================="
    
    if eval "$test_command"; then
        echo "✓ $test_name passed"
    else
        echo "✗ $test_name failed"
        FAILED_TESTS=$((FAILED_TESTS + 1))
    fi
    echo ""
}

# Change to workspace directory
cd /workspace

# Install dependencies if artifact is not present
if [ ! -f "install-build-node-20.tar" ]; then
    echo "No pre-built artifact found. Installing dependencies with yarn..."
    yarn install --frozen-lockfile
else
    echo "Extracting pre-built artifact..."
    tar -xf install-build-node-20.tar
fi

# Run all unit tests
run_test "ESM / CJS export equivalence" "yarn test-unit-esm"

run_test "Unit tests (validator.js)" "yarn lerna run test-unit --scope=@sequelize/validator.js"

run_test "Unit tests (utils)" "yarn lerna run test-unit --scope=@sequelize/utils"

run_test "Unit tests (core - mariadb)" "yarn lerna run test-unit-mariadb --scope=@sequelize/core"

run_test "Unit tests (mariadb package)" "yarn lerna run test-unit --scope=@sequelize/mariadb"

run_test "Unit tests (core - mysql)" "yarn lerna run test-unit-mysql --scope=@sequelize/core"

run_test "Unit tests (mysql package)" "yarn lerna run test-unit --scope=@sequelize/mysql"

run_test "Unit tests (core - postgres)" "yarn lerna run test-unit-postgres --scope=@sequelize/core"

run_test "Unit tests (postgres package)" "yarn lerna run test-unit --scope=@sequelize/postgres"

run_test "Unit tests (core - sqlite3)" "yarn lerna run test-unit-sqlite3 --scope=@sequelize/core"

run_test "Unit tests (core - mssql)" "yarn lerna run test-unit-mssql --scope=@sequelize/core"

run_test "Unit tests (mssql package)" "yarn lerna run test-unit --scope=@sequelize/mssql"

run_test "Unit tests (core - db2)" "yarn lerna run test-unit-db2 --scope=@sequelize/core"

run_test "Unit tests (core - ibmi)" "yarn lerna run test-unit-ibmi --scope=@sequelize/core"

run_test "Unit tests (core - snowflake)" "yarn lerna run test-unit-snowflake --scope=@sequelize/core"

run_test "Unit tests (core - oracle)" "yarn lerna run test-unit-oracle --scope=@sequelize/core"

run_test "Unit tests (oracle package)" "yarn lerna run test-unit --scope=@sequelize/oracle"

run_test "Unit tests (cli)" "yarn lerna run test-unit --scope=@sequelize/cli"

run_test "SQLite SSCCE" "yarn sscce-sqlite3"

# Summary
echo "=========================================="
echo "Test Summary"
echo "=========================================="
if [ $FAILED_TESTS -eq 0 ]; then
    echo "✓ All tests passed!"
    exit 0
else
    echo "✗ $FAILED_TESTS test suite(s) failed"
    exit 1
fi