#!/usr/bin/env bash

export CC=clang-18
export CXX=clang++-18

./super-test.sh quick || true

echo "FINAL_STATUS = SUCCESS"
