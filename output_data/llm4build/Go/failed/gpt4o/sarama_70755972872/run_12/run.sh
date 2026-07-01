#!/bin/bash

# Activate Go environment
export PATH="/usr/local/go/bin:${PATH}"
export CGO_ENABLED=1

# Check if Makefile has 'install' target
if make -q install; then
    # Install project dependencies
    make install
else
    echo "No 'install' target in Makefile. Skipping installation step."
fi

# Run tests
if make -q test; then
    make test
else
    echo "No 'test' target in Makefile. Attempting to run tests directly with 'go test'."
    go test ./... -v -json > _test/unittests.json || echo "Tests failed or no tests found."
fi

# Report test results
if [ -f "_test/unittests.json" ]; then
    tparse -all -format markdown -file _test/unittests.json | tee -a /dev/null
else
    echo "Test results file '_test/unittests.json' not found."
fi

# Report per-function test coverage
if [ -f "profile.out" ]; then
    echo "<details>" >> /dev/null
    echo "<summary>Click for per-func code coverage</summary>" >> /dev/null
    echo "|Filename|Function|Coverage|" >> /dev/null
    echo "|--------|--------|--------|" >> /dev/null
    go tool cover -func=profile.out | sed -E -e 's/[[:space:]]+/|/g' -e 's/$/|/g' -e 's/^/|/g' >> /dev/null
    echo "</details>" >> /dev/null
else
    echo "Coverage file 'profile.out' not found."
fi