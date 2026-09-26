#!/bin/bash
set -e

# Ensure we're in the workspace directory for all operations
cd /workspace

GOWORK=off make verify-generate
GOWORK=off make lint
GOWORK=off make build
GOWORK=off make test