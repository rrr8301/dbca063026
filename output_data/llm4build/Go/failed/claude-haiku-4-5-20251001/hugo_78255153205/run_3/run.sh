#!/bin/bash
set -e

# Navigate to workspace
cd /workspace

# Verify installations
echo "=== Verifying installations ==="
go version
node --version
ruby --version
python3 --version
pandoc --version
sass --version
mage -v

# Install Go dependencies
echo "=== Installing Go dependencies ==="
go mod download
go mod tidy

# Install Node dependencies (if package.json exists)
if [ -f "package.json" ]; then
    echo "=== Installing Node dependencies ==="
    npm install
fi

# Install Node dependencies in docs (if exists)
if [ -f "docs/package.json" ]; then
    echo "=== Installing Node dependencies in docs ==="
    cd docs
    npm install
    cd ..
fi

# Check embedded go template formatting
echo "=== Checking embedded go template formatting ==="
diff <(gotmplfmt -d tpl/tplimpl/embedded/templates) <(printf '')

# Run staticcheck
echo "=== Running staticcheck ==="
export STATICCHECK_CACHE="/tmp/staticcheck"
staticcheck ./...
rm -rf /tmp/staticcheck

# Run mage check with extended and withdeploy tags
echo "=== Running mage check ==="
export HUGO_BUILD_TAGS=extended,withdeploy
mage -v check

echo "=== All tests passed ==="