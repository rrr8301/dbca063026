#!/bin/bash

# Activate Rust environment
source $HOME/.cargo/env

# Update Rust
rustup update

# Install dependencies
cargo xtask install-tools --binstall

# Test format of vi translation
msgfmt --statistics -o /dev/null po/vi.po

# Build vi translation
.github/workflows/build.sh vi book/comprehensive-rust-vi

# Test code snippets
export MDBOOK_BOOK__LANGUAGE=vi
mdbook test