#!/bin/bash

# Set environment variables for Clang
export CC=clang-20
export CXX=clang++-20
export LD=lld-20
export AR=llvm-ar-20

# Change directory to c++ and run Bazel tests
cd c++
bazel test --config=ci --config=opt //...