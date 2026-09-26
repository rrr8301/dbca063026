#!/usr/bin/env bash
set -e

# Source Nix environment
source /root/.nix-profile/etc/profile.d/nix.sh

# Run lints and tests using nix-shell
cd /app

# Export the nix environment variables for subshells
export NIX_PATH=nixpkgs=channel:nixos-unstable

# Run the lints and tests without --pure so that nix-shell is available for the justfile recipes
if nix-shell --cores 0 --run 'just lint test'; then
    echo "FINAL_STATUS = SUCCESS"
else
    echo "FINAL_STATUS = FAIL"
    exit 1
fi
