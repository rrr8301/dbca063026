#!/bin/bash

# Activate Rust environment
source $HOME/.cargo/env

# Install Redis
REDIS_VERSION=8.6.0
curl -fsSL "https://download.redis.io/releases/redis-${REDIS_VERSION}.tar.gz" -o /tmp/redis.tar.gz
tar -xzf /tmp/redis.tar.gz -C /tmp
cd "/tmp/redis-${REDIS_VERSION}"
make -j"$(nproc)"
make install
redis-server --version

# Start Redis
redis-server \
  --port 6379 \
  --bind 127.0.0.1 \
  --save "" \
  --appendonly no \
  --daemonize yes \
  --pidfile /tmp/redis-ci.pid \
  --dir /tmp

for _ in $(seq 1 20); do
  if redis-cli -h 127.0.0.1 -p 6379 ping | grep -q PONG; then
    break
  fi
  sleep 0.5
done

# Run integration tests
echo "REDIS_URL=${REDIS_URL:-redis://127.0.0.1:6379} REDIS_DB=${REDIS_DB:-0} LEADER_LOCK_KEY_PREFIX=${LEADER_LOCK_KEY_PREFIX:-<unset>}"
env | sort | grep -Ei 'REDIS|LEADER|LOCK|FUEL' || true
(timeout 90s redis-cli MONITOR | stdbuf -oL grep -E 'SELECT|SET|PEXPIRE|DEL|leader|lock' || true) &
cargo test --package fuel-core --lib service::adapters::consensus_module::poa::tests:: --features leader_lock -- --test-threads=1 --nocapture
cargo test --package fuel-core-tests --test integration_tests leader_lock --features leader_lock -- --test-threads=1 --nocapture