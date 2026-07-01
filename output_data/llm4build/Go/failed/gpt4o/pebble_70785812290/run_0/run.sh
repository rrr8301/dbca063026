#!/bin/bash

# Set Go environment variables
export PATH="/usr/local/go/bin:${PATH}"

# Install project dependencies and run tests
GOTRACEBACK=all make test testobjiotracing generate