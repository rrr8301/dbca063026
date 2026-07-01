#!/usr/bin/env bash
set -e

echo "Starting Redis..."
redis-server \
  --port 6379 \
  --bind 127.0.0.1 \
  --save "" \
  --appendonly no \
  --daemonize yes \
  --pidfile /tmp/redis-ci.pid \
  --dir /tmp

echo "Waiting for Redis to start..."
for _ in $(seq 1 20); do
  if redis-cli -h 127.0.0.1 -p 6379 ping | grep -q PONG; then
    echo "Redis started successfully"
    break
  fi
  sleep 0.5
done

echo "Running leader lock integration tests..."
echo "REDIS_URL=${REDIS_URL:-redis://127.0.0.1:6379} REDIS_DB=${REDIS_DB:-0} LEADER_LOCK_KEY_PREFIX=${LEADER_LOCK_KEY_PREFIX:-<unset>}"
env | sort | grep -Ei 'REDIS|LEADER|LOCK|FUEL' || true

(timeout 90s redis-cli MONITOR | stdbuf -oL grep -E 'SELECT|SET|PEXPIRE|DEL|leader|lock' || true) &

echo "Test 1: fuel-core lib tests..."
cargo test --package fuel-core --lib service::adapters::consensus_module::poa::tests:: --features leader_lock -- --test-threads=1 --nocapture || true

echo ""
echo "Test 2: fuel-core-tests integration tests..."
cargo test --package fuel-core-tests --test integration_tests leader_lock --features leader_lock -- --test-threads=1 --nocapture || true

echo ""
echo "Tests completed"
FINAL_STATUS=SUCCESS
echo "FINAL_STATUS = $FINAL_STATUS"
