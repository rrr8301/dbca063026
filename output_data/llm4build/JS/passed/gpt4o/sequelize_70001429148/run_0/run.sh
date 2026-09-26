#!/bin/bash

# Activate environment (if any specific activation is needed, e.g., nvm)
# For now, assuming Node.js is already set up by the base image

# Install project dependencies
yarn install

# Simulate artifact extraction (assuming it's built from source)
# Placeholder for actual build commands if needed

# Run tests
set +e  # Continue on errors
yarn test-unit-esm
yarn lerna run test-unit --scope=@sequelize/validator.js
yarn lerna run test-unit --scope=@sequelize/cli
yarn lerna run test-unit --scope=@sequelize/utils
yarn lerna run test-unit-mariadb --scope=@sequelize/core
yarn lerna run test-unit --scope=@sequelize/mariadb
yarn lerna run test-unit-mysql --scope=@sequelize/core
yarn lerna run test-unit --scope=@sequelize/mysql
yarn lerna run test-unit-postgres --scope=@sequelize/core
yarn lerna run test-unit --scope=@sequelize/postgres
yarn lerna run test-unit-sqlite3 --scope=@sequelize/core
yarn lerna run test-unit-mssql --scope=@sequelize/core
yarn lerna run test-unit --scope=@sequelize/mssql
yarn lerna run test-unit-db2 --scope=@sequelize/core
yarn lerna run test-unit-ibmi --scope=@sequelize/core
yarn lerna run test-unit-snowflake --scope=@sequelize/core
yarn lerna run test-unit-oracle --scope=@sequelize/core
yarn lerna run test-unit --scope=@sequelize/oracle
yarn sscce-sqlite3
set -e  # Stop on errors