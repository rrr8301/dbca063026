#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Configure the build
./Configure -des -Dusedevel -Duseshrplib -Dusequadmath -Dusecbacktrace -Dusethreads -Dprefix="$HOME/perl-blead" -DDEBUGGING

# Build the project
MALLOC_PERTURB_=254 MALLOC_CHECK_=3 make -j2

# Show configuration
LD_LIBRARY_PATH=`pwd` ./perl -Ilib -V
LD_LIBRARY_PATH=`pwd` ./perl -Ilib -e 'use Config; print Config::config_sh'

# Run tests
# Ensure the correct path to the test files
LD_LIBRARY_PATH=`pwd` MALLOC_PERTURB_=254 MALLOC_CHECK_=3 TEST_JOBS=2 ./perl -Ilib t/harness

# Check if the test directory exists and contains test files
if [ -d "t" ] && [ "$(ls -A t)" ]; then
    # Run tests
    LD_LIBRARY_PATH=`pwd` MALLOC_PERTURB_=254 MALLOC_CHECK_=3 TEST_JOBS=2 ./perl -Ilib t/harness
else
    echo "Test directory 't' is missing or empty. Please ensure test files are present."
    exit 1
fi