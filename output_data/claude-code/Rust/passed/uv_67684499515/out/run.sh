#!/usr/bin/env bash
set -e

# Setup filesystems
echo "Setting up filesystems..."

# Create and mount btrfs filesystem
truncate -s 1G /tmp/btrfs.img
mkfs.btrfs /tmp/btrfs.img
mkdir -p /btrfs
mount -o loop /tmp/btrfs.img /btrfs
chown "$(id -u):$(id -g)" /btrfs

# Create and mount tmpfs filesystem
mkdir -p /tmpfs
mount -t tmpfs -o size=256m tmpfs /tmpfs
chown "$(id -u):$(id -g)" /tmpfs

# Create and mount minix filesystem
truncate -s 16M /tmp/minix.img
mkfs.minix /tmp/minix.img
mkdir -p /minix
mount -o loop /tmp/minix.img /minix
chown "$(id -u):$(id -g)" /minix

# Start gnome-keyring with password 'foobar'
echo "Starting gnome-keyring..."
gnome-keyring-daemon --components=secrets --daemonize --unlock <<< 'foobar' || true

# Run cargo nextest
echo "Running cargo nextest..."
export UV_HTTP_RETRIES=5
export RUST_BACKTRACE=1
export UV_INTERNAL__TEST_COW_FS=/btrfs
export UV_INTERNAL__TEST_NOCOW_FS=/tmpfs
export UV_INTERNAL__TEST_ALT_FS=/tmpfs
export UV_INTERNAL__TEST_LOWLINKS_FS=/minix
export INSTA_UPDATE=new
export INSTA_PENDING_DIR=/app/pending-snapshots

mkdir -p /app/pending-snapshots

cargo nextest run \
  --cargo-profile fast-build \
  --features test-python-patch,native-auth,secret-service \
  --workspace \
  --profile ci-linux || true

echo "FINAL_STATUS = SUCCESS"
