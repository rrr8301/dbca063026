#!/bin/bash
set -e

# Initialize PostgreSQL cluster if not already done
if [ ! -d /var/lib/postgresql/17/main ]; then
    sudo -u postgres /usr/lib/postgresql/17/bin/initdb -D /var/lib/postgresql/17/main
fi

# Start PostgreSQL service
service postgresql start

# Wait for PostgreSQL to be ready
sleep 3

# Create root role for testing (needed for installcheck)
sudo -u postgres /usr/lib/postgresql/17/bin/psql -c "CREATE ROLE root WITH SUPERUSER CREATEDB CREATEROLE LOGIN;" || true

# Build with custom PG_CFLAGS
export PG_CFLAGS="-DUSE_ASSERT_CHECKING -Wall -Wextra -Werror -Wno-unused-parameter -Wno-sign-compare -Wno-missing-field-initializers"
make

# Install
export PG_CONFIG=$(which pg_config)
make install

# Run installcheck tests
make installcheck