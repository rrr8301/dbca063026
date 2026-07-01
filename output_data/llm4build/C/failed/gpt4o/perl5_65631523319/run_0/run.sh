#!/bin/bash

# Configure the build
./Configure -des -Dusedevel -Duseshrplib -Dusequadmath -Dusecbacktrace -Dusethreads -Dprefix="$HOME/perl-blead" -DDEBUGGING

# Build the project
MALLOC_PERTURB_=254 MALLOC_CHECK_=3 make -j2 test_prep

# Show configuration
LD_LIBRARY_PATH=`pwd` ./perl -Ilib -V
LD_LIBRARY_PATH=`pwd` ./perl -Ilib -e 'use Config; print Config::config_sh'

# Run tests
LD_LIBRARY_PATH=`pwd` MALLOC_PERTURB_=254 MALLOC_CHECK_=3 TEST_JOBS=2 ./perl t/harness