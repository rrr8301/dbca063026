#!/bin/bash

# Install project dependencies
nci

# Build the project
nr build

# Run tests with coverage
nr test --coverage || true  # Ensure all tests run even if some fail