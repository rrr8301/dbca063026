#!/usr/bin/env bash
set -e

cd /app

# Install required Python versions
uv python install

# Install secret service
apt-get update -y
apt-get install -y gnome-keyring

# Start gnome-keyring
gnome-keyring-daemon --components=secrets --daemonize --unlock <<< 'foobar'

# Create btrfs filesystem
truncate -s 1G /tmp/btrfs.img
mkfs.btrfs /tmp/btrfs.img
mkdir -p /btrfs
mount -o loop /tmp/btrfs.img /btrfs
chown "$(id -u):$(id -g)" /btrfs

# Create tmpfs filesystem
mkdir -p /tmpfs
mount -t tmpfs -o size=256m tmpfs /tmpfs
chown "$(id -u):$(id -g)" /tmpfs

# Create minix filesystem
truncate -s 16M /tmp/minix.img
mkfs.minix /tmp/minix.img
mkdir -p /minix
mount -o loop /tmp/minix.img /minix
chown "$(id -u):$(id -g)" /minix

# Install cargo-nextest
cargo install cargo-nextest

# Run cargo tests
export CARGO_INCREMENTAL=0
export CARGO_NET_RETRY=10
export CARGO_TERM_COLOR=always
export PYTHON_VERSION="3.12"
export RUSTUP_MAX_RETRIES=10
export UV_HTTP_RETRIES=5
export RUST_BACKTRACE=1
export UV_INTERNAL__TEST_COW_FS=/btrfs
export UV_INTERNAL__TEST_NOCOW_FS=/tmpfs
export UV_INTERNAL__TEST_ALT_FS=/tmpfs
export UV_INTERNAL__TEST_LOWLINKS_FS=/minix

cargo nextest run \
  --cargo-profile fast-build \
  --features test-python-patch,native-auth,secret-service \
  --workspace \
  --profile ci-linux

echo "FINAL_STATUS = SUCCESS"
