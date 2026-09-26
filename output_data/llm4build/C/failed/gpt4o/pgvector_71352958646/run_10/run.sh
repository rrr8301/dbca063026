#!/bin/bash

# Start PostgreSQL service
service postgresql start

# Activate environment variables
export PG_CFLAGS="-DUSE_ASSERT_CHECKING -Wall -Wextra -Werror -Wno-unused-parameter -Wno-sign-compare -Wno-missing-field-initializers"

# Install project dependencies
make

# Install PostgreSQL
export PG_CONFIG=$(which pg_config)
sudo --preserve-env=PG_CONFIG make install

# Run tests as the 'docker' user
sudo -u docker psql -c "CREATE DATABASE contrib_regression;" -U docker
make installcheck

# If there is a failure, output regression.diffs
if [ $? -ne 0 ]; then
  cat regression.diffs
fi