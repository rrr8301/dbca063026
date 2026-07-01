#!/bin/bash

set -e

# Enable error handling but continue on test failures
REGRESSION_TEST_FAILED=0

echo "=========================================="
echo "Step 1: Fetch PostgreSQL 18 commit hash"
echo "=========================================="
PG_COMMIT_HASH=$(git ls-remote https://git.postgresql.org/git/postgresql.git refs/heads/REL_18_STABLE | awk '{print $1}')
echo "PostgreSQL 18 commit hash: $PG_COMMIT_HASH"

echo ""
echo "=========================================="
echo "Step 2: Install PostgreSQL 18 from source"
echo "=========================================="
if [ ! -d "$HOME/pg18" ]; then
    echo "Building PostgreSQL 18..."
    git clone --depth 1 --branch REL_18_STABLE https://git.postgresql.org/git/postgresql.git ~/pg18source
    cd ~/pg18source
    ./configure --prefix=$HOME/pg18 CFLAGS="-std=gnu99 -ggdb -O0" --enable-cassert
    make install -j$(nproc) > /dev/null
    echo "PostgreSQL 18 installed successfully"
else
    echo "PostgreSQL 18 already exists, skipping build"
fi

echo ""
echo "=========================================="
echo "Step 3: Install PostgreSQL extensions"
echo "=========================================="
cd ~/pg18source/contrib

echo "Installing fuzzystrmatch..."
cd fuzzystrmatch
make PG_CONFIG=$HOME/pg18/bin/pg_config install -j$(nproc) > /dev/null
cd ..

echo "Installing pg_trgm..."
cd pg_trgm
make PG_CONFIG=$HOME/pg18/bin/pg_config install -j$(nproc) > /dev/null
cd ..

echo "Extensions installed successfully"

echo ""
echo "=========================================="
echo "Step 4: Build AGE extension"
echo "=========================================="
cd /workspace/age
make PG_CONFIG=$HOME/pg18/bin/pg_config install -j$(nproc)
echo "AGE built successfully"

echo ""
echo "=========================================="
echo "Step 5: Clone and build pgvector"
echo "=========================================="
cd /workspace
git clone https://github.com/pgvector/pgvector.git
cd pgvector
make PG_CONFIG=$HOME/pg18/bin/pg_config install -j$(nproc) > /dev/null
echo "pgvector built successfully"

echo ""
echo "=========================================="
echo "Step 6: Run regression tests"
echo "=========================================="
cd /workspace/age

# Set locale for regression tests
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

if make PG_CONFIG=$HOME/pg18/bin/pg_config installcheck EXTRA_TESTS="pgvector fuzzystrmatch pg_trgm"; then
    echo "Regression tests passed"
else
    REGRESSION_TEST_FAILED=1
    echo "Regression tests failed, dumping errors..."
fi

echo ""
echo "=========================================="
echo "Step 7: Dump regression test errors (if any)"
echo "=========================================="
if [ $REGRESSION_TEST_FAILED -eq 1 ]; then
    # Check initdb log first to diagnose the issue
    if [ -f "/workspace/age/regress/log/initdb.log" ]; then
        echo "=== initdb.log content ==="
        cat /workspace/age/regress/log/initdb.log
        echo "=== end initdb.log ==="
    fi
    
    if [ -f "$HOME/work/age/age/regress/regression.diffs" ]; then
        echo "Dump section begin."
        cat $HOME/work/age/age/regress/regression.diffs
        echo "Dump section end."
    elif [ -f "/workspace/age/regress/regression.diffs" ]; then
        echo "Dump section begin."
        cat /workspace/age/regress/regression.diffs
        echo "Dump section end."
    else
        echo "regression.diffs file not found at expected locations"
        find /workspace -name "regression.diffs" -type f 2>/dev/null || echo "No regression.diffs found"
    fi
    exit 1
fi

echo ""
echo "=========================================="
echo "All tests completed successfully!"
echo "=========================================="
exit 0