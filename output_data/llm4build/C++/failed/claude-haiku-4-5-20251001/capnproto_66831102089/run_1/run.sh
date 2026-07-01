#!/bin/bash
set -e

# Clone the repository (simulating actions/checkout)
if [ ! -d "capnproto" ]; then
    git clone https://github.com/capnproto/capnproto.git .
fi

# Set compiler environment variables
export CC=clang-20
export CXX=clang++-20
export LD=lld-20
export AR=llvm-ar-20

# Run Bazel tests
cd c++ && bazel test --config=ci --config=opt //...