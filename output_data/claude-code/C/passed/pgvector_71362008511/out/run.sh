#!/usr/bin/env bash
set -e

# Switch to postgres user and start PostgreSQL
su - postgres -c "
  /usr/local/pgsql/bin/initdb -D /usr/local/pgsql/data &&
  /usr/local/pgsql/bin/pg_ctl -D /usr/local/pgsql/data -l /tmp/postgres.log start &&
  sleep 2
" || true

# Build the extension
export PG_CFLAGS="-DUSE_ASSERT_CHECKING -Wall -Wextra -Werror -Wno-unused-parameter -Wno-sign-compare -Wno-missing-field-initializers"
make

# Install the extension
export PG_CONFIG=$(which pg_config)
make install

# Run installcheck as postgres user
su - postgres -c "
  cd /app &&
  make installcheck
" || true

# Print final status
if [ -f regression.diffs ]; then
    echo "FINAL_STATUS = FAIL"
    exit 1
else
    echo "FINAL_STATUS = SUCCESS"
    exit 0
fi
