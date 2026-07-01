#!/bin/bash
set -e

# Set environment variables
export PERL_SKIP_TTY_TEST=1
export CONTINUOUS_INTEGRATION=1
export MALLOC_PERTURB_=254
export MALLOC_CHECK_=3
export TEST_JOBS=2

# Clone the repository (assuming it's passed as an argument or use current directory)
# If running in a pre-cloned repo, skip this step
if [ ! -f "Configure" ]; then
    echo "Repository not found. Assuming code will be mounted or pre-cloned."
    exit 1
fi

# Configure git
git config diff.renameLimit 999999

# Configure Perl
echo "Configuring Perl..."
./Configure -des -Dusedevel -Duseshrplib -Dusequadmath -Dusecbacktrace -Dusethreads -Dprefix="$HOME/perl-blead" -DDEBUGGING

# Build
echo "Building Perl..."
MALLOC_PERTURB_=254 MALLOC_CHECK_=3 make -j2 test_prep

# Show Config
echo "Showing Perl Config..."
LD_LIBRARY_PATH=`pwd` ./perl -Ilib -V
LD_LIBRARY_PATH=`pwd` ./perl -Ilib -e 'use Config; print Config::config_sh'

# Run Tests
echo "Running tests..."
LD_LIBRARY_PATH=`pwd` MALLOC_PERTURB_=254 MALLOC_CHECK_=3 TEST_JOBS=2 ./perl t/harness

echo "Tests completed successfully!"