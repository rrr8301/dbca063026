#!/bin/bash

set +e

# Track exit codes
EXIT_CODE=0

# Install project dependencies
echo "Installing project dependencies..."
yarn install
if [ $? -ne 0 ]; then
    echo "Failed to install dependencies"
    EXIT_CODE=1
fi

# Extract build artifact if present
if [ -f "install-build-node-24.tar" ]; then
    echo "Extracting build artifact..."
    tar -xf install-build-node-24.tar
    if [ $? -ne 0 ]; then
        echo "Failed to extract artifact"
        EXIT_CODE=1
    fi
fi

# Run all test suites
echo "Running ESM / CJS export equivalence tests..."
yarn test-unit-esm
if [ $? -ne 0 ]; then
    echo "ESM / CJS export equivalence tests failed"
    EXIT_CODE=1
fi

echo "Running Unit tests (validator.js)..."
yarn lerna run test-unit --scope=@sequelize/validator.js
if [ $? -ne 0 ]; then
    echo "Unit tests (validator.js) failed"
    EXIT_CODE=1
fi

echo "Running Unit tests (cli)..."
yarn lerna run test-unit --scope=@sequelize/cli
if [ $? -ne 0 ]; then
    echo "Unit tests (cli) failed"
    EXIT_CODE=1
fi

echo "Running Unit tests (utils)..."
yarn lerna run test-unit --scope=@sequelize/utils
if [ $? -ne 0 ]; then
    echo "Unit tests (utils) failed"
    EXIT_CODE=1
fi

echo "Running Unit tests (core - mariadb)..."
yarn lerna run test-unit-mariadb --scope=@sequelize/core
if [ $? -ne 0 ]; then
    echo "Unit tests (core - mariadb) failed"
    EXIT_CODE=1
fi

echo "Running Unit tests (mariadb package)..."
yarn lerna run test-unit --scope=@sequelize/mariadb
if [ $? -ne 0 ]; then
    echo "Unit tests (mariadb package) failed"
    EXIT_CODE=1
fi

echo "Running Unit tests (core - mysql)..."
yarn lerna run test-unit-mysql --scope=@sequelize/core
if [ $? -ne 0 ]; then
    echo "Unit tests (core - mysql) failed"
    EXIT_CODE=1
fi

echo "Running Unit tests (mysql package)..."
yarn lerna run test-unit --scope=@sequelize/mysql
if [ $? -ne 0 ]; then
    echo "Unit tests (mysql package) failed"
    EXIT_CODE=1
fi

echo "Running Unit tests (core - postgres)..."
yarn lerna run test-unit-postgres --scope=@sequelize/core
if [ $? -ne 0 ]; then
    echo "Unit tests (core - postgres) failed"
    EXIT_CODE=1
fi

echo "Running Unit tests (postgres package)..."
yarn lerna run test-unit --scope=@sequelize/postgres
if [ $? -ne 0 ]; then
    echo "Unit tests (postgres package) failed"
    EXIT_CODE=1
fi

echo "Running Unit tests (core - sqlite3)..."
yarn lerna run test-unit-sqlite3 --scope=@sequelize/core
if [ $? -ne 0 ]; then
    echo "Unit tests (core - sqlite3) failed"
    EXIT_CODE=1
fi

echo "Running Unit tests (core - mssql)..."
yarn lerna run test-unit-mssql --scope=@sequelize/core
if [ $? -ne 0 ]; then
    echo "Unit tests (core - mssql) failed"
    EXIT_CODE=1
fi

echo "Running Unit tests (mssql package)..."
yarn lerna run test-unit --scope=@sequelize/mssql
if [ $? -ne 0 ]; then
    echo "Unit tests (mssql package) failed"
    EXIT_CODE=1
fi

echo "Running Unit tests (core - db2)..."
yarn lerna run test-unit-db2 --scope=@sequelize/core
if [ $? -ne 0 ]; then
    echo "Unit tests (core - db2) failed"
    EXIT_CODE=1
fi

echo "Running Unit tests (core - ibmi)..."
yarn lerna run test-unit-ibmi --scope=@sequelize/core
if [ $? -ne 0 ]; then
    echo "Unit tests (core - ibmi) failed"
    EXIT_CODE=1
fi

echo "Running Unit tests (core - snowflake)..."
yarn lerna run test-unit-snowflake --scope=@sequelize/core
if [ $? -ne 0 ]; then
    echo "Unit tests (core - snowflake) failed"
    EXIT_CODE=1
fi

echo "Running Unit tests (core - oracle)..."
yarn lerna run test-unit-oracle --scope=@sequelize/core
if [ $? -ne 0 ]; then
    echo "Unit tests (core - oracle) failed"
    EXIT_CODE=1
fi

echo "Running Unit tests (oracle package)..."
yarn lerna run test-unit --scope=@sequelize/oracle
if [ $? -ne 0 ]; then
    echo "Unit tests (oracle package) failed"
    EXIT_CODE=1
fi

echo "Running SQLite SSCCE..."
yarn sscce-sqlite3
if [ $? -ne 0 ]; then
    echo "SQLite SSCCE failed"
    EXIT_CODE=1
fi

# Exit with accumulated error code
if [ $EXIT_CODE -ne 0 ]; then
    echo "Some tests failed. Exit code: $EXIT_CODE"
    exit $EXIT_CODE
else
    echo "All tests passed!"
    exit 0
fi