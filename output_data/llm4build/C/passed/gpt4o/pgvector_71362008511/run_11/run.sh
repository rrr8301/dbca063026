#!/bin/bash

# Initialize PostgreSQL data directory if not already initialized
if [ ! -f /var/lib/postgresql/15/main/PG_VERSION ]; then
  su - postgres -c "/usr/lib/postgresql/15/bin/initdb -D /var/lib/postgresql/15/main"
fi

# Start PostgreSQL service
service postgresql start

# Wait for PostgreSQL to start
until pg_isready -h localhost -p 5432 -U postgres; do
  echo "Waiting for PostgreSQL to start..."
  sleep 1
done

# Create a PostgreSQL user and database
su - postgres -c "psql -c \"CREATE USER docker WITH SUPERUSER PASSWORD 'docker';\""
su - postgres -c "psql -c \"CREATE DATABASE docker OWNER docker;\""

# Navigate to the app directory
cd /app

# Set environment variables for make
export PG_CFLAGS="-DUSE_ASSERT_CHECKING -Wall -Wextra -Werror -Wno-unused-parameter -Wno-sign-compare -Wno-missing-field-initializers"

# Run make
make

# Install using make install
export PG_CONFIG=$(which pg_config)
sudo --preserve-env=PG_CONFIG make install

# Check if the Makefile has an installcheck target before running it
if make -q installcheck; then
  # Run tests with the correct user
  su - postgres -c "make installcheck"
else
  echo "No installcheck target in Makefile, skipping tests."
fi