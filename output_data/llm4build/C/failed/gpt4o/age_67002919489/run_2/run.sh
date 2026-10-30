#!/bin/bash

# Activate environment variables if any

# Install project dependencies
echo "Installing PostgreSQL 18 and extensions..."
git clone --depth 1 --branch REL_18_STABLE https://git.postgresql.org/git/postgresql.git ~/pg18source
cd ~/pg18source
./configure --prefix=$HOME/pg18 CFLAGS="-std=gnu99 -ggdb -O0" --enable-cassert
make install -j$(nproc)
cd contrib
cd fuzzystrmatch
make PG_CONFIG=$HOME/pg18/bin/pg_config install -j$(nproc)
cd ../pg_trgm
make PG_CONFIG=$HOME/pg18/bin/pg_config install -j$(nproc)

# Build AGE
echo "Building AGE..."
cd /app
make PG_CONFIG=$HOME/pg18/bin/pg_config install -j$(nproc)

# Pull and build pgvector
echo "Building pgvector..."
git clone https://github.com/pgvector/pgvector.git
cd pgvector
make PG_CONFIG=$HOME/pg18/bin/pg_config install -j$(nproc)

# Run regression tests
echo "Running regression tests..."
cd /app
make PG_CONFIG=$HOME/pg18/bin/pg_config installcheck EXTRA_TESTS="pgvector fuzzystrmatch pg_trgm" || true

# Dump regression test errors if any
if [ $? -ne 0 ]; then
  echo "Dump section begin."
  cat /app/regress/log/initdb.log
  echo "Dump section end."
  exit 1
fi