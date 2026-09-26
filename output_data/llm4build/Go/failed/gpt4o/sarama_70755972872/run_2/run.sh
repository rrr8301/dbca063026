#!/bin/bash

# Activate Go environment
export PATH="/usr/local/go/bin:${PATH}"

# Install project dependencies
make install

# Run tests
make test

# Report test results
go run github.com/mfridman/tparse@v0.18.0 -all -format markdown -file _test/unittests.json | tee -a /dev/null

# Report per-function test coverage
echo "<details>" >> /dev/null
echo "<summary>Click for per-func code coverage</summary>" >> /dev/null
echo "|Filename|Function|Coverage|" >> /dev/null
echo "|--------|--------|--------|" >> /dev/null
go tool cover -func=profile.out | sed -E -e 's/[[:space:]]+/|/g' -e 's/$/|/g' -e 's/^/|/g' >> /dev/null
echo "</details>" >> /dev/null