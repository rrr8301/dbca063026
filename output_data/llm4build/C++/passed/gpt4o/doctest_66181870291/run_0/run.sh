#!/bin/bash

# Activate environment variables
export CTEST_OUTPUT_ON_FAILURE=ON
export CTEST_PARALLEL_LEVEL=2
export CMAKE_GENERATOR=Ninja
export ASAN_OPTIONS=strict_string_checks=true:detect_odr_violation=2:detect_stack_use_after_return=true:check_initialization_order=true:strict_init_order=true
export TSAN_OPTIONS=force_seq_cst_atomics=1

# Install project dependencies
# Assuming dependencies are managed by a Python script or similar
# If there are specific dependencies, they should be installed here

# Run tests for X64
python3 .github/workflows/build_and_test.py ubuntu-22.04 x64 gcc 9

# Run tests for X86
python3 .github/workflows/build_and_test.py ubuntu-22.04 x86 gcc 9