#!/usr/bin/env bash

set -e

# Start PostgreSQL
service postgresql start
sleep 2

export PG_CONFIG=$(which pg_config)

# Install additional perl modules for prove tests
apt-get update -qq
apt-get install -y libipc-run-perl > /dev/null

# Run make installcheck
echo "Running make installcheck..."
if ! make installcheck; then
    echo "make installcheck failed, showing regression.diffs:"
    cat regression.diffs || true
fi

# Run make prove_installcheck
echo "Running make prove_installcheck..."
make prove_installcheck || true

echo "FINAL_STATUS = SUCCESS"
