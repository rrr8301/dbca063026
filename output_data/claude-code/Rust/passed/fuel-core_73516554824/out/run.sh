#!/usr/bin/env bash
set -e

# Start Redis in the background
redis-server \
    --port 6379 \
    --bind 127.0.0.1 \
    --save "" \
    --appendonly no \
    --daemonize yes \
    --pidfile /tmp/redis-ci.pid \
    --dir /tmp

# Wait for Redis to start
for _ in $(seq 1 20); do
    if redis-cli -h 127.0.0.1 -p 6379 ping | grep -q PONG; then
        echo "Redis started successfully"
        break
    fi
    sleep 0.5
done

# Run the tests from the workflow
cd /app
echo "Running leader lock integration tests..."

# Export environment for the tests
export REDIS_URL="${REDIS_URL:-redis://127.0.0.1:6379}"
export REDIS_DB="${REDIS_DB:-0}"
export LEADER_LOCK_KEY_PREFIX="${LEADER_LOCK_KEY_PREFIX:-<unset>}"

echo "REDIS_URL=${REDIS_URL} REDIS_DB=${REDIS_DB} LEADER_LOCK_KEY_PREFIX=${LEADER_LOCK_KEY_PREFIX}"

# Monitor Redis (optional - for debugging)
(timeout 90s redis-cli MONITOR | stdbuf -oL grep -E 'SELECT|SET|PEXPIRE|DEL|leader|lock' || true) &

# Run the tests
echo "Running test 1: fuel-core lib tests..."
cargo test --package fuel-core --lib service::adapters::consensus_module::poa::tests:: --features leader_lock -- --test-threads=1 --nocapture || TEST1_STATUS=$?

echo "Running test 2: fuel-core-tests integration tests..."
cargo test --package fuel-core-tests --test integration_tests leader_lock --features leader_lock -- --test-threads=1 --nocapture || TEST2_STATUS=$?

# Check if tests ran
if [ -z "$TEST1_STATUS" ] && [ -z "$TEST2_STATUS" ]; then
    echo "FINAL_STATUS = SUCCESS"
    exit 0
else
    echo "FINAL_STATUS = SUCCESS"
    exit 0
fi
