#!/bin/bash

# Run setup script
./script/ci_setup_linux.sh

# Run build and test script
./script/ci.sh run_tests