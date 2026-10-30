#!/bin/bash
set -e

# Start PostgreSQL service
service postgresql start

# Wait for PostgreSQL to be ready
sleep 2

# Build with custom PG_CFLAGS
export PG_CFLAGS="-DUSE_ASSERT_CHECKING -Wall -Wextra -Werror -Wno-unused-parameter -Wno-sign-compare -Wno-missing-field-initializers"
make

# Install
export PG_CONFIG=$(which pg_config)
make install

# Run installcheck tests
make installcheck