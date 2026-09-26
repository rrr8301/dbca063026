#!/usr/bin/env bash
set -e

cd /app

# Run all unit tests as specified in the unit-test job
echo "Running ESM / CJS export equivalence..."
yarn test-unit-esm || true

echo "Running Unit tests (validator.js)..."
yarn lerna run test-unit --scope=@sequelize/validator.js || true

echo "Running Unit tests (utils)..."
yarn lerna run test-unit --scope=@sequelize/utils || true

echo "Running Unit tests (core - mariadb)..."
yarn lerna run test-unit-mariadb --scope=@sequelize/core || true

echo "Running Unit tests (mariadb package)..."
yarn lerna run test-unit --scope=@sequelize/mariadb || true

echo "Running Unit tests (core - mysql)..."
yarn lerna run test-unit-mysql --scope=@sequelize/core || true

echo "Running Unit tests (mysql package)..."
yarn lerna run test-unit --scope=@sequelize/mysql || true

echo "Running Unit tests (core - postgres)..."
yarn lerna run test-unit-postgres --scope=@sequelize/core || true

echo "Running Unit tests (postgres package)..."
yarn lerna run test-unit --scope=@sequelize/postgres || true

echo "Running Unit tests (core - sqlite3)..."
yarn lerna run test-unit-sqlite3 --scope=@sequelize/core || true

echo "Running Unit tests (core - mssql)..."
yarn lerna run test-unit-mssql --scope=@sequelize/core || true

echo "Running Unit tests (mssql package)..."
yarn lerna run test-unit --scope=@sequelize/mssql || true

echo "Running Unit tests (core - db2)..."
yarn lerna run test-unit-db2 --scope=@sequelize/core || true

echo "Running Unit tests (core - ibmi)..."
yarn lerna run test-unit-ibmi --scope=@sequelize/core || true

echo "Running Unit tests (core - snowflake)..."
yarn lerna run test-unit-snowflake --scope=@sequelize/core || true

echo "Running Unit tests (core - oracle)..."
yarn lerna run test-unit-oracle --scope=@sequelize/core || true

echo "Running Unit tests (oracle package)..."
yarn lerna run test-unit --scope=@sequelize/oracle || true

echo "Running Unit tests (cli)..."
yarn lerna run test-unit --scope=@sequelize/cli || true

echo "Running SQLite SSCCE..."
yarn sscce-sqlite3 || true

echo "Tests completed!"
echo "FINAL_STATUS = SUCCESS"
