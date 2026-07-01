for i in $(seq 1 20); do
  if redis-cli -h 127.0.0.1 -p 6379 ping | grep -q PONG; then
    echo "Redis is ready"
    exit 0  # <-- THIS EXITS THE ENTIRE SCRIPT!
  fi
  sleep 0.5
done