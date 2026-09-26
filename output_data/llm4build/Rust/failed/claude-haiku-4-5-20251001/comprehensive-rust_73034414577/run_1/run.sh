#!/bin/bash
set -e

# Update Rust toolchain
rustup update

# Install mdbook and tools via cargo xtask
cargo xtask install-tools --binstall

# Install Node.js dependencies for tests
cd /workspace/tests
npm install
cd /workspace

# Test format of vi translation
msgfmt --statistics -o /dev/null po/vi.po

# Build vi translation
.github/workflows/build.sh vi book/comprehensive-rust-vi

# Test code snippets with vi language
export MDBOOK_BOOK__LANGUAGE=vi
mdbook test

echo "All tests completed successfully!"