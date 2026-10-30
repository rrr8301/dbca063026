#!/bin/bash

# Activate environments
export GOPROXY=https://proxy.golang.org
export GO111MODULE=on

# Ensure Go tools are in the PATH
export PATH="/usr/local/go/bin:$PATH"

# Install project dependencies
go mod download

# Run staticcheck
export STATICCHECK_CACHE="/tmp/staticcheck"
staticcheck ./...
rm -rf /tmp/staticcheck

# Check embedded go template formatting
diff <(gotmplfmt -d tpl/tplimpl/embedded/templates) <(printf '')

# Run checks
sass --version
mage -v check