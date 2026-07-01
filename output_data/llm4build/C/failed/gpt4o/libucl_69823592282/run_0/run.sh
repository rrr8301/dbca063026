#!/bin/bash

# Configure the project
./autogen.sh && ./configure --enable-lua

# Install dependencies
make

# Run tests
make check