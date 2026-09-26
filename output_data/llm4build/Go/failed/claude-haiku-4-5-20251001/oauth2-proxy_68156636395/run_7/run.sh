#!/bin/bash
set -e

GOWORK=off make verify-generate
GOWORK=off make lint
GOWORK=off make build
GOWORK=off make test