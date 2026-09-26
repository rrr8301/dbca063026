#!/usr/bin/env bash
set -e

# Source environment variables from sample.env
export $(grep -v '^#' /app/sample.env | grep -v '^$' | xargs)

# Start MongoDB
mongod --replSet rs0 --fork --logpath /var/log/mongod.log --dbpath /data/db
sleep 3

# Initialize replica set
mongosh --eval 'var cfg = { _id: "rs0", members: [ { _id: 0, host: "127.0.0.1:27017" } ] }; rs.initiate(cfg);' || true
sleep 2

# Install Puppeteer Chrome dependencies and browser
pnpm -F=curriculum install-puppeteer

# Run tests
pnpm test || TEST_FAILED=true

# Stop MongoDB
mongod --shutdown || true

if [ "$TEST_FAILED" = true ]; then
    echo "FINAL_STATUS = FAIL"
    exit 1
else
    echo "FINAL_STATUS = SUCCESS"
fi
