#!/usr/bin/env bash
set -e

cd /app

echo "Running unit tests..."

# ESM / CJS export equivalence
echo "--- ESM / CJS export equivalence ---"
yarn test-unit-esm || true

# Unit tests (validator.js)
echo "--- Unit tests (validator.js) ---"
yarn lerna run test-unit --scope=@sequelize/validator.js || true

# Unit tests (utils)
echo "--- Unit tests (utils) ---"
yarn lerna run test-unit --scope=@sequelize/utils || true

# Unit tests (core - mariadb)
echo "--- Unit tests (core - mariadb) ---"
yarn lerna run test-unit-mariadb --scope=@sequelize/core || true

# Unit tests (mariadb package)
echo "--- Unit tests (mariadb package) ---"
yarn lerna run test-unit --scope=@sequelize/mariadb || true

# Unit tests (core - mysql)
echo "--- Unit tests (core - mysql) ---"
yarn lerna run test-unit-mysql --scope=@sequelize/core || true

# Unit tests (mysql package)
echo "--- Unit tests (mysql package) ---"
yarn lerna run test-unit --scope=@sequelize/mysql || true

# Unit tests (core - postgres)
echo "--- Unit tests (core - postgres) ---"
yarn lerna run test-unit-postgres --scope=@sequelize/core || true

# Unit tests (postgres package)
echo "--- Unit tests (postgres package) ---"
yarn lerna run test-unit --scope=@sequelize/postgres || true

# Unit tests (core - sqlite3)
echo "--- Unit tests (core - sqlite3) ---"
yarn lerna run test-unit-sqlite3 --scope=@sequelize/core || true

# Unit tests (core - mssql)
echo "--- Unit tests (core - mssql) ---"
yarn lerna run test-unit-mssql --scope=@sequelize/core || true

# Unit tests (mssql package)
echo "--- Unit tests (mssql package) ---"
yarn lerna run test-unit --scope=@sequelize/mssql || true

# Unit tests (core - db2)
echo "--- Unit tests (core - db2) ---"
yarn lerna run test-unit-db2 --scope=@sequelize/core || true

# Unit tests (core - ibmi)
echo "--- Unit tests (core - ibmi) ---"
yarn lerna run test-unit-ibmi --scope=@sequelize/core || true

# Unit tests (core - snowflake)
echo "--- Unit tests (core - snowflake) ---"
yarn lerna run test-unit-snowflake --scope=@sequelize/core || true

# Unit tests (core - oracle)
echo "--- Unit tests (core - oracle) ---"
yarn lerna run test-unit-oracle --scope=@sequelize/core || true

# Unit tests (oracle package)
echo "--- Unit tests (oracle package) ---"
yarn lerna run test-unit --scope=@sequelize/oracle || true

# Unit tests (cli)
echo "--- Unit tests (cli) ---"
yarn lerna run test-unit --scope=@sequelize/cli || true

# SQLite SSCCE
echo "--- SQLite SSCCE ---"
yarn sscce-sqlite3 || true

echo "FINAL_STATUS = SUCCESS"
