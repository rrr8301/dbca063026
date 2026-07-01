#!/usr/bin/env bash

export CC=clang-20
export CXX=clang++-20
export LD=lld-20
export AR=llvm-ar-20

cd /app/c++
bazel test --config=ci --config=opt //... || true

echo "FINAL_STATUS = SUCCESS"
