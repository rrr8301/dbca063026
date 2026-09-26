#!/bin/bash
set -e

# Activate Rust environment
export PATH="/root/.cargo/bin:${PATH}"

# Verify Rust installation
rustc --version
cargo --version

# Start Redis server
echo "Starting Redis server..."
redis-server \
  --port 6379 \
  --bind 127.0.0.1 \
  --save "" \
  --appendonly no \
  --daemonize yes \
  --pidfile /tmp/redis-ci.pid \
  --dir /tmp

# Wait for Redis to be ready
echo "Waiting for Redis to be ready..."
for i in $(seq 1 20); do
  if redis-cli -h 127.0.0.1 -p 6379 ping | grep -q PONG; then
    echo "Redis is ready"
    exit 0
  fi
  sleep 0.5
done

echo "Redis failed to start"
exit 1

# Set Redis environment variables (defaults if not set)
export REDIS_URL="${REDIS_URL:-redis://127.0.0.1:6379}"
export REDIS_DB="${REDIS_DB:-0}"
export LEADER_LOCK_KEY_PREFIX="${LEADER_LOCK_KEY_PREFIX:-<unset>}"

echo "REDIS_URL=${REDIS_URL} REDIS_DB=${REDIS_DB} LEADER_LOCK_KEY_PREFIX=${LEADER_LOCK_KEY_PREFIX}"
env | sort | grep -Ei 'REDIS|LEADER|LOCK|FUEL' || true

# Start Redis monitor in background (optional, for debugging)
(timeout 90s redis-cli MONITOR | stdbuf -oL grep -E 'SELECT|SET|PEXPIRE|DEL|leader|lock' || true) &

# Run leader lock integration tests
echo "Running leader lock unit tests..."
cargo test --package fuel-core --lib service::adapters::consensus_module::poa::tests:: --features leader_lock -- --test-threads=1 --nocapture

echo "Running leader lock integration tests..."
cargo test --package fuel-core-tests --test integration_tests leader_lock --features leader_lock -- --test-threads=1 --nocapture

echo "All tests completed successfully"