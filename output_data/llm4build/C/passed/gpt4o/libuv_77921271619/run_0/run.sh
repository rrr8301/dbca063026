#!/bin/bash

# Run autogen.sh
./autogen.sh

# Create build directory and configure
mkdir build
(cd build && ../configure)

# Run make distcheck
make -C build distcheck