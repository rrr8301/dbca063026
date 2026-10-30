#!/bin/bash

# Start PostgreSQL service
service postgresql start

# Activate environment variables
export PG_CFLAGS="-DUSE_ASSERT_CHECKING -Wall -Wextra -Werror -Wno-unused-parameter -Wno-sign-compare -Wno-missing-field-initializers"

# Install project dependencies
make

# Install PostgreSQL
export PG_CONFIG=$(which pg_config)
make install

# Run tests as the 'docker' user
su - postgres -c "psql -U docker -c \"DROP DATABASE IF EXISTS contrib_regression;\" -d postgres"
su - postgres -c "psql -U docker -c \"CREATE DATABASE contrib_regression;\" -d postgres"
su - postgres -c "make installcheck"

# If there is a failure, output regression.diffs
if [ $? -ne 0 ]; then
  cat regression.diffs
fi

# Stop PostgreSQL service
service postgresql stop