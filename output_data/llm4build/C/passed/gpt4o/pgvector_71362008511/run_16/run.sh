#!/bin/bash

# Start PostgreSQL service
service postgresql start

# Wait for PostgreSQL to start
until pg_isready -h localhost; do
  echo "Waiting for PostgreSQL to start..."
  sleep 1
done

# Create a PostgreSQL user and database
sudo -u postgres psql -c "ALTER USER postgres PASSWORD 'postgres';" || true
sudo -u postgres psql -c "CREATE USER docker WITH SUPERUSER PASSWORD 'docker';" || true
sudo -u postgres psql -c "CREATE DATABASE docker OWNER docker;" || true

# Set environment variables
export PG_CFLAGS="-DUSE_ASSERT_CHECKING -Wall -Wextra -Werror -Wno-unused-parameter -Wno-sign-compare -Wno-missing-field-initializers"
export PG_CONFIG=$(which pg_config)

# Build and install
make
sudo --preserve-env=PG_CONFIG make install

# Run tests with the correct user and password
PGPASSWORD=docker make installcheck PGUSER=docker PGDATABASE=docker