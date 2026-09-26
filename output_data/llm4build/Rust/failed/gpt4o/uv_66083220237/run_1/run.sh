#!/bin/bash

# Activate Rust environment
source $HOME/.cargo/env

# Install Python versions using uv
uv python install

# Start gnome-keyring
echo 'foobar' | gnome-keyring-daemon --components=secrets --daemonize --unlock

# Create filesystems
truncate -s 1G /tmp/btrfs.img
mkfs.btrfs /tmp/btrfs.img
sudo mkdir /btrfs
sudo mount -o loop /tmp/btrfs.img /btrfs
sudo chown "$(id -u):$(id -g)" /btrfs

sudo mkdir /tmpfs
sudo mount -t tmpfs -o size=256m tmpfs /tmpfs
sudo chown "$(id -u):$(id -g)" /tmpfs

truncate -s 16M /tmp/minix.img
mkfs.minix /tmp/minix.img
sudo mkdir /minix
sudo mount -o loop /tmp/minix.img /minix
sudo chown "$(id -u):$(id -g)" /minix

# Run cargo tests
cargo nextest run \
  --cargo-profile fast-build \
  --features test-python-patch,native-auth,secret-service \
  --workspace \
  --profile ci-linux || true