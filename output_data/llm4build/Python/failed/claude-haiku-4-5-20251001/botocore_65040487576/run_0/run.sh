#!/bin/bash
set -e

# Install dependencies and CRT
python scripts/ci/install --extras crt

# Run CRT tests with coverage and xdist
python scripts/ci/run-crt-tests --with-cov --with-xdist