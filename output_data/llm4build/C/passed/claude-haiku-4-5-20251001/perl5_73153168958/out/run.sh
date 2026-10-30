#!/bin/bash

set -e

# Environment variables for build and test
export PERL_SKIP_TTY_TEST=1
export CONTINUOUS_INTEGRATION=1
export MALLOC_PERTURB_=254
export MALLOC_CHECK_=3
export TEST_JOBS=2

cd /perl-build

# Verify we're in a git repository, if not initialize it
if [ ! -d .git ]; then
    echo "=== Initializing git repository ==="
    git init
    git config user.email "ci@example.com"
    git config user.name "CI User"
    git add .
    git commit -m "Initial commit"
fi

# Configure git
git config diff.renameLimit 999999

# Configure Perl with specified arguments
echo "=== Configuring Perl ==="
./Configure -des -Dusedevel -Dcc='g++' -Dprefix="$HOME/perl-blead" -DDEBUGGING

# Build test_prep
echo "=== Building test_prep ==="
MALLOC_PERTURB_=254 MALLOC_CHECK_=3 make -j2 test_prep

# Show config
echo "=== Showing Perl Config ==="
export LD_LIBRARY_PATH="$(pwd):$LD_LIBRARY_PATH"
./perl -Ilib -V
./perl -Ilib -e 'use Config; print Config::config_sh'

# Run tests
echo "=== Running Tests ==="
LD_LIBRARY_PATH="$(pwd):$LD_LIBRARY_PATH" MALLOC_PERTURB_=254 MALLOC_CHECK_=3 TEST_JOBS=2 ./perl t/harness || TEST_FAILED=1

# Git clean
echo "=== Git Clean ==="
git clean -dxf

# Run manicheck
echo "=== Running manicheck ==="
perl Porting/manicheck --exitstatus || MANICHECK_FAILED=1

# Report results
if [ -n "$TEST_FAILED" ] || [ -n "$MANICHECK_FAILED" ]; then
    echo "=== Some tests or checks failed ==="
    exit 1
fi

echo "=== All tests and checks passed ==="
exit 0