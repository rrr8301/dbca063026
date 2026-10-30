#!/bin/bash

# Activate environment variables if needed (placeholder)
# source /path/to/env.sh

# Ensure project dependencies are installed
pnpm install

# Ensure the build script exists before running it
if [ -f package.json ] && grep -q '"build":' package.json; then
    pnpm run build
else
    echo "No build script found in package.json"
fi

# Check if the build directory exists and contains compiled files
# Adjust the path if the build output directory is different
if [ ! -d "./dist" ]; then
    echo "Error: Compiled directory does not exist. Please check the build process."
    exit 1
fi

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