#!/bin/bash

set -e

# Print Go version for verification
echo "=== Go Version ==="
go version

# Initialize git if needed
echo "=== Initializing git repository ==="
if [ ! -d .git ]; then
    git init
    git config user.email "builder@local"
    git config user.name "Builder"
    git add .
    git commit -m "Initial commit" --allow-empty || true
fi

# Restore any patches (only if git has stashed changes)
echo "=== Restoring patches ==="
git stash pop 2>/dev/null || true

# Update git submodules - critical for replaced modules
echo "=== Updating git submodules ==="
git submodule update --init --recursive || true

# Verify that replaced module paths exist before downloading dependencies
echo "=== Verifying module paths ==="
if grep -q "replace.*=>" go.mod 2>/dev/null; then
    echo "Found replace directives in go.mod, verifying paths..."
    while IFS= read -r line; do
        if [[ $line =~ replace\ ([^\ ]+)\ \=\>\ \(([^)]+)\) ]]; then
            module="${BASH_REMATCH[1]}"
            path="${BASH_REMATCH[2]}"
            if [ ! -d "$path" ]; then
                echo "Warning: Replaced module path does not exist: $path"
            fi
        fi
    done < <(grep "replace.*=>" go.mod)
fi

# Install project dependencies
echo "=== Installing project dependencies ==="
go mod download

# Run coverage tests
echo "=== Running coverage tests ==="
GOPROXY="https://proxy.golang.org,direct" make go.test.coverage

# Print test completion message
echo "=== Coverage tests completed ==="
if [ -f ./coverage.xml ]; then
    echo "Coverage report generated: ./coverage.xml"
    ls -lh ./coverage.xml
elif [ -f ./coverage.out ]; then
    echo "Coverage report generated: ./coverage.out"
    ls -lh ./coverage.out
else
    echo "Error: coverage report not found"
    exit 1
fi

echo "=== All tests completed ==="