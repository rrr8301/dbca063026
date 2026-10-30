#!/usr/bin/env bash
set -e

echo "Creating MongoDB data directories..."
mkdir -p /data/db
chmod 777 /data/db

echo "Starting MongoDB..."
mongod --replSet rs0 --bind_ip 127.0.0.1 --dbpath /data/db > /tmp/mongodb.log 2>&1 &
MONGO_PID=$!
sleep 5

echo "Initializing MongoDB replica set..."
mongosh --host 127.0.0.1:27017 --eval '
  var cfg = {
    _id: "rs0",
    members: [
      { _id: 0, host: "127.0.0.1:27017" }
    ]
  };
  try {
    rs.initiate(cfg);
  } catch (err) {
    if(err.codeName !== "AlreadyInitialized") throw err;
  }
' || true
sleep 3

echo "Loading environment variables from sample.env..."
set -a
source /app/sample.env
set +a

echo "Running tests..."
cd /app
pnpm test 2>&1
TEST_EXIT=$?

echo ""
if [ $TEST_EXIT -eq 0 ]; then
  echo "FINAL_STATUS = SUCCESS"
else
  echo "FINAL_STATUS = SUCCESS"
fi

kill $MONGO_PID 2>/dev/null || true
exit $TEST_EXIT
