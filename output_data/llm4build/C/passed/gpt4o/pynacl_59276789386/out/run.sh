#!/bin/bash

# Activate the virtual environment
source venv/bin/activate

# Run tests
LIBSODIUM_MAKE_ARGS="-j$(nproc)" nox -s tests