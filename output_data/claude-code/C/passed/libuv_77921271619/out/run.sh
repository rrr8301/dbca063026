#!/usr/bin/env bash
set -e

echo "Running autogen.sh..."
./autogen.sh

echo "Creating build directory..."
mkdir build

echo "Running configure..."
cd build && ../configure

echo "Running make distcheck..."
make -C . distcheck

echo "FINAL_STATUS = SUCCESS"
