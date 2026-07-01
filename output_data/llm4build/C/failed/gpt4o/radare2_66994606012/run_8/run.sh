#!/bin/bash

# Activate environment variables
export LD_LIBRARY_PATH=/usr/local/lib

# Run tests
make tests || true