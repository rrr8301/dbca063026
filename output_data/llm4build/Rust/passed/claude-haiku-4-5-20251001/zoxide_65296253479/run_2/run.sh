#!/bin/bash
set -e

# Navigate to workspace
cd /workspace

# Source nix profile to ensure nix-shell is available
if [ -f /root/.nix-profile/etc/profile.d/nix.sh ]; then
    . /root/.nix-profile/etc/profile.d/nix.sh
fi

# Run lints and tests using just
just lint test