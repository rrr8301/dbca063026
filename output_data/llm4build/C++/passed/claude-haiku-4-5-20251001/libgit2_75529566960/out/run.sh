#!/bin/bash

set -e

# Set environment variables from matrix
export CC=gcc
export CMAKE_GENERATOR=Ninja
export CMAKE_OPTIONS="-DUSE_HTTPS=OpenSSL -DREGEX_BACKEND=builtin -DDEBUG_LEAK_CHECKER=valgrind -DUSE_GSSAPI=ON -DUSE_SSH=libssh2 -DDEBUG_STRICT_ALLOC=ON -DDEBUG_STRICT_OPEN=ON"

# Prepare build directory (if not already present)
mkdir -p /workspace/build

# Setup SSH environment for tests
mkdir -p /root/.ssh
chmod 700 /root/.ssh

# Generate SSH keys if they don't exist
if [ ! -f /root/.ssh/id_rsa ]; then
    ssh-keygen -t rsa -N "" -f /root/.ssh/id_rsa
fi

# Ensure SSH host keys exist
if [ ! -f /etc/ssh/ssh_host_rsa_key ]; then
    ssh-keygen -A
fi

# Configure SSH daemon to listen only on IPv4 and localhost
mkdir -p /run/sshd
cat > /etc/ssh/sshd_config.d/99-test.conf <<EOF
AddressFamily inet
ListenAddress 127.0.0.1
ListenAddress 0.0.0.0
Port 22
PermitRootLogin yes
StrictModes no
PubkeyAuthentication yes
PasswordAuthentication yes
PermitEmptyPasswords yes
EOF

# Start SSH daemon
/usr/sbin/sshd -D &
SSH_PID=$!

# Give SSH daemon time to start
sleep 2

# Verify SSH is running
if ! kill -0 $SSH_PID 2>/dev/null; then
    echo "ERROR: SSH daemon failed to start"
    exit 1
fi

# Add localhost to known_hosts
ssh-keyscan -t rsa localhost >> /root/.ssh/known_hosts 2>/dev/null || true
ssh-keyscan -t rsa 127.0.0.1 >> /root/.ssh/known_hosts 2>/dev/null || true

# Build
cd /workspace/build
/workspace/source/ci/build.sh

# Test
/workspace/source/ci/test.sh
TEST_RESULT=$?

# Cleanup
kill $SSH_PID 2>/dev/null || true
wait $SSH_PID 2>/dev/null || true

if [ $TEST_RESULT -eq 0 ]; then
    echo "Build and test completed successfully"
else
    echo "Build and test failed with exit code $TEST_RESULT"
    exit $TEST_RESULT
fi