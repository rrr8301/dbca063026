#!/bin/bash
set -e

# Find the package file, if it exists
PKG_FILE=$(find dist -name "*.tar.gz" -type f 2>/dev/null | head -1)

# Build the tox command
TOX_CMD="tox run -e py311-coverage"

# Add installpkg flag only if package file exists
if [ -n "$PKG_FILE" ]; then
    TOX_CMD="$TOX_CMD --installpkg $PKG_FILE"
fi

# Execute tox
$TOX_CMD