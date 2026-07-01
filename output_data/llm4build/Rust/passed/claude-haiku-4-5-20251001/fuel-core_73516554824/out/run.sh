#!/bin/bash
set -e

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
for _ in $(seq 1 20); do
  if redis-cli -h 127.0.0.1 -p 6379 ping | grep -q PONG; then
    echo "Redis is ready"
    break
  fi
  sleep 0.5
done

# Verify Redis started
if ! redis-cli -h 127.0.0.1 -p 6379 ping | grep -q PONG; then
  echo "Redis failed to start"
  exit 1
fi

# Set environment variables for tests
export REDIS_URL="${REDIS_URL:-redis://127.0.0.1:6379}"
export REDIS_DB="${REDIS_DB:-0}"
export LEADER_LOCK_KEY_PREFIX="${LEADER_LOCK_KEY_PREFIX:-<unset>}"

# Log environment
echo "REDIS_URL=${REDIS_URL} REDIS_DB=${REDIS_DB} LEADER_LOCK_KEY_PREFIX=${LEADER_LOCK_KEY_PREFIX}"
env | sort | grep -Ei 'REDIS|LEADER|LOCK|FUEL' || true

# Start Redis MONITOR in background (for debugging)
(timeout 90s redis-cli MONITOR | stdbuf -oL grep -E 'SELECT|SET|PEXPIRE|DEL|leader|lock' || true) &

# Run leader lock integration tests
echo "Running leader lock integration tests..."

TEST1_FAILED=0
TEST2_FAILED=0

# Test 1: fuel-core lib tests
echo "Test 1: cargo test --package fuel-core --lib service::adapters::consensus_module::poa::tests:: --features leader_lock"
cargo test --package fuel-core --lib service::adapters::consensus_module::poa::tests:: --features leader_lock -- --test-threads=1 --nocapture || TEST1_FAILED=1

# Test 2: fuel-core-tests integration tests
echo "Test 2: cargo test --package fuel-core-tests --test integration_tests leader_lock --features leader_lock"
cargo test --package fuel-core-tests --test integration_tests leader_lock --features leader_lock -- --test-threads=1 --nocapture || TEST2_FAILED=1

# Check if any tests failed
if [ "$TEST1_FAILED" -eq 1 ] || [ "$TEST2_FAILED" -eq 1 ]; then
  echo "Some tests failed"
  exit 1
fi

echo "All tests passed"
exit 0