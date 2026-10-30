#!/bin/bash

# Start PostgreSQL service
service postgresql start

# Navigate to the app directory
cd /app

# Set environment variables for make
export PG_CFLAGS="-DUSE_ASSERT_CHECKING -Wall -Wextra -Werror -Wno-unused-parameter -Wno-sign-compare -Wno-missing-field-initializers"

# Run make
make

# Install using make install
export PG_CONFIG=$(which pg_config)
sudo --preserve-env=PG_CONFIG make install

# Run tests
make installcheck