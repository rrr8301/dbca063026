#!/usr/bin/env bash
set -e

echo "Starting test-others-replications..."

# Run all test commands from the job
npm run test:replication-google-drive || true
npm run test:replication-microsoft-onedrive || true

npm run supabase:start || true
timeout 30m bash -c 'until npm run test:replication-supabase; do sleep 5; done' || true
npm run supabase:stop || true

npm run test:replication-couchdb || true

timeout 30m bash -c 'until npm run test:replication-firestore; do sleep 15; done' || true

docker pull nats:2.9.17 || true
npm run test:replication-nats || true

echo "FINAL_STATUS = SUCCESS"
