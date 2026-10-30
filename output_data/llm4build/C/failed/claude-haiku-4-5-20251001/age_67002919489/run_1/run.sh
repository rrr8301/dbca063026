#!/bin/bash

set -e

# Enable error handling but continue on test failures
TESTS_FAILED=0

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
    
    echo ""
    echo "=========================================="
    echo "Step 3: Install PostgreSQL extensions"
    echo "=========================================="
    cd contrib
    
    echo "Installing fuzzystrmatch..."
    cd fuzzystrmatch
    make PG_CONFIG=$HOME/pg18/bin/pg_config install -j$(nproc) > /dev/null
    cd ..
    
    echo "Installing pg_trgm..."
    cd pg_trgm
    make PG_CONFIG=$HOME/pg18/bin/pg_config install -j$(nproc) > /dev/null
    cd ..
else
    echo "PostgreSQL 18 cache found, skipping build"
fi

echo ""
echo "=========================================="
echo "Step 4: Build AGE extension"
echo "=========================================="
cd /workspace/age
make PG_CONFIG=$HOME/pg18/bin/pg_config install -j$(nproc)
echo "AGE extension built successfully"

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
if make PG_CONFIG=$HOME/pg18/bin/pg_config installcheck EXTRA_TESTS="pgvector fuzzystrmatch pg_trgm"; then
    echo "Regression tests passed"
else
    echo "Regression tests failed"
    TESTS_FAILED=1
fi

echo ""
echo "=========================================="
echo "Step 7: Check for regression test errors"
echo "=========================================="
if [ $TESTS_FAILED -eq 1 ]; then
    echo "Dumping regression test errors..."
    echo "Dump section begin."
    if [ -f "$HOME/work/age/age/regress/regression.diffs" ]; then
        cat $HOME/work/age/age/regress/regression.diffs
    elif [ -f "/workspace/age/regress/regression.diffs" ]; then
        cat /workspace/age/regress/regression.diffs
    else
        echo "Warning: regression.diffs file not found at expected locations"
        echo "Searching for regression.diffs..."
        find /workspace -name "regression.diffs" -type f 2>/dev/null || echo "No regression.diffs found"
    fi
    echo "Dump section end."
    exit 1
fi

echo ""
echo "=========================================="
echo "All tests completed successfully!"
echo "=========================================="
exit 0