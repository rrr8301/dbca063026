#!/usr/bin/env bash

set -e

echo "Running: GOTRACEBACK=all make test testobjiotracing generate"

GOTRACEBACK=all make test testobjiotracing generate

echo ""
echo "FINAL_STATUS = SUCCESS"
