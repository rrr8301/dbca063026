#!/bin/bash

# Activate environment variables if needed (placeholder)
# source /path/to/env.sh

# Ensure project dependencies are installed
pnpm install

# Build the project to ensure test files are compiled
pnpm run build

# Run tests for each database type
for db_type in cockroachdb mongodb mssql mysql mariadb postgres oracle sap; do
    echo "Running tests for $db_type..."
    case $db_type in
        cockroachdb)
            jq 'map(select(.type == "cockroachdb"))' ormconfig.sample.json > ormconfig.json
            ;;
        mongodb)
            jq 'map(select(.type == "mongodb"))' ormconfig.sample.json > ormconfig.json
            ;;
        mssql)
            jq 'map(select(.type == "mssql"))' ormconfig.sample.json > ormconfig.json
            ;;
        mysql|mariadb)
            jq 'map(select(.type == "mysql" or .type == "mariadb"))' ormconfig.sample.json > ormconfig.json
            ;;
        postgres)
            jq 'map(select(.type == "postgres"))' ormconfig.sample.json > ormconfig.json
            ;;
        oracle)
            jq 'map(select(.type == "oracle"))' ormconfig.sample.json > ormconfig.json
            ;;
        sap)
            jq 'map(select(.type == "sap"))' ormconfig.sample.json > ormconfig.json
            ;;
        *)
            echo "Unknown database type: $db_type"
            continue
            ;;
    esac

    # Run tests and ensure all tests are executed
    pnpm exec c8 pnpm run test:ci || true
done