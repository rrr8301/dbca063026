#!/bin/bash
set -e

# Set compiler environment variables
export CC=clang-20
export CXX=clang++-20
export LD=lld-20
export AR=llvm-ar-20

# Run Bazel tests
cd c++ && bazel test --config=ci --config=opt //...