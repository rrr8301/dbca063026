#!/bin/bash

set -e

# Get latest commit id of PostgreSQL 18
PG_COMMIT_HASH=$(git ls-remote https://git.postgresql.org/git/postgresql.git refs/heads/REL_18_STABLE | awk '{print $1}')

# Install PostgreSQL 18 and some extensions
git clone --depth 1 --branch REL_18_STABLE https://git.postgresql.org/git/postgresql.git ~/pg18source
cd ~/pg18source
./configure --prefix=$HOME/pg18 CFLAGS="-std=gnu99 -ggdb -O0" --enable-cassert
make install -j$(nproc)
cd contrib
cd fuzzystrmatch
make PG_CONFIG=$HOME/pg18/bin/pg_config install -j$(nproc)
cd ../pg_trgm
make PG_CONFIG=$HOME/pg18/bin/pg_config install -j$(nproc)

# Checkout the repository
cd /app

# Build AGE
make PG_CONFIG=$HOME/pg18/bin/pg_config install -j$(nproc)

# Pull and build pgvector
git clone https://github.com/pgvector/pgvector.git
cd pgvector
make PG_CONFIG=$HOME/pg18/bin/pg_config install -j$(nproc)

# Run regression tests
cd /app
make PG_CONFIG=$HOME/pg18/bin/pg_config installcheck EXTRA_TESTS="pgvector fuzzystrmatch pg_trgm" || true

# Dump regression test errors if any
if [ -f /app/regress/log/initdb.log ]; then
    echo "Dump section begin."
    cat /app/regress/log/initdb.log
    echo "Dump section end."
    exit 1
fi

if [ -f $HOME/work/age/age/regress/regression.diffs ]; then
    echo "Dump section begin."
    cat $HOME/work/age/age/regress/regression.diffs
    echo "Dump section end."
    exit 1
fi