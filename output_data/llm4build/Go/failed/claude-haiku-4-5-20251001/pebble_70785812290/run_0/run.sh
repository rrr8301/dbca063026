#!/bin/bash
set -e

# Verify Go installation
go version

# Run the test targets
GOTRACEBACK=all make test testobjiotracing generate

# Assert workspace is clean
scripts/check-workspace-clean.sh