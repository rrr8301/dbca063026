#!/usr/bin/env bash
set -e

cd /app/build

# Prepare ccache
ccache -p
ccache -z

# Build
ninja

# Save ccache stats
ccache -s

# Run tests
ninja unittests

echo "FINAL_STATUS = SUCCESS"
