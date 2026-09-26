#!/usr/bin/env bash
set -e

echo "Ruby version:"
ruby -v

echo ""
echo "Compiler version:"
clang --version

echo ""
echo "Building and running tests..."
rake -m test:run:serial

echo ""
echo "FINAL_STATUS = SUCCESS"
