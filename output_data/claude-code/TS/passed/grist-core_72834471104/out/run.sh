#!/usr/bin/env bash

set -e

# Change to app directory
cd /app

# Start minio service
echo "Starting MinIO..."
mkdir -p /tmp/minio-data
minio server /tmp/minio-data &
MINIO_PID=$!
sleep 3

# Create minio bucket
aws --region us-east-1 --endpoint-url http://localhost:9000 s3api create-bucket --bucket grist-docs-test || true
aws --region us-east-1 --endpoint-url http://localhost:9000 s3api put-bucket-versioning --bucket grist-docs-test --versioning-configuration Status=Enabled || true

# Start Redis
echo "Starting Redis..."
redis-server --port 6379 --daemonize yes

# Start PostgreSQL
echo "Starting PostgreSQL..."
su - postgres -c "pg_ctl -D /var/lib/postgresql/16/main -l /tmp/postgres.log start" || true
sleep 3

# Wait for PostgreSQL to be ready
for i in {1..30}; do
  if pg_isready -h localhost -U postgres; then
    echo "PostgreSQL is ready"
    break
  fi
  echo "Waiting for PostgreSQL... ($i/30)"
  sleep 1
done

# Create test database
PGPASSWORD=db_password psql -h localhost -U db_user -w db_name -c "SELECT 1;" || \
  PGPASSWORD=postgres psql -h localhost -U postgres -c "CREATE DATABASE db_name; CREATE USER db_user WITH PASSWORD 'db_password'; GRANT ALL PRIVILEGES ON DATABASE db_name TO db_user;" || true

# Set environment variables for tests
export MOCHA_WEBDRIVER_HEADLESS=1
export MOCHA_WEBDRIVER_LOGDIR=/tmp/test-logs/webdriver
export TESTDIR=/tmp/test-logs
export TESTS=':lint:python:client:common:smoke:stubs:pyodide:eslint-unit:'
export GRIST_DOCS_MINIO_ACCESS_KEY=administrator
export GRIST_DOCS_MINIO_SECRET_KEY=administrator
export TEST_REDIS_URL="redis://localhost/11"
export GVISOR_FLAGS="-unprivileged -ignore-cgroups"
export GVISOR_EXTRA_DIRS=/opt
export GRIST_DOCS_MINIO_USE_SSL=0
export GRIST_DOCS_MINIO_ENDPOINT=localhost
export GRIST_DOCS_MINIO_PORT=9000
export GRIST_DOCS_MINIO_BUCKET=grist-docs-test
export VERBOSE=1
export DEBUG=1
export TYPEORM_TYPE=postgres
export TYPEORM_HOST=localhost
export TYPEORM_DATABASE=db_name
export TYPEORM_USERNAME=db_user
export TYPEORM_PASSWORD=db_password
export GRIST_SANDBOX_FLAVOR=pyodide

mkdir -p $MOCHA_WEBDRIVER_LOGDIR
mkdir -p $TESTDIR

echo "Running tests..."
TEST_RESULT=0

# Run eslint
echo "Running ESLint..."
yarn run lint:ci || TEST_RESULT=$?

# Run python tests
echo "Running Python tests..."
. sandbox_venv3/bin/activate
yarn run test:python || TEST_RESULT=$?

# Run client tests
echo "Running Client tests..."
yarn run test:client || TEST_RESULT=$?

# Run common tests
echo "Running Common tests..."
yarn run test:common || TEST_RESULT=$?

# Run smoke tests
echo "Running Smoke tests..."
VERBOSE=1 DEBUG=1 MOCHA_WEBDRIVER_HEADLESS=1 yarn run test:smoke || TEST_RESULT=$?

# Run stubs tests
echo "Running Stubs tests..."
MOCHA_WEBDRIVER_HEADLESS=1 yarn run test:stubs || TEST_RESULT=$?

# Run pyodide setup and tests
echo "Running Pyodide tests..."
cd sandbox/pyodide
make setup || true
cd ../..
yarn run test:server -g 'ActiveDoc.useQuerySet|Sandbox' || TEST_RESULT=$?
yarn run test:nbrowser -g 'Importer.*should.show.correct.preview' || TEST_RESULT=$?

# Run eslint unit tests
echo "Running ESLint unit tests..."
yarn run test:eslint || TEST_RESULT=$?

# Cleanup
echo "Stopping services..."
kill $MINIO_PID 2>/dev/null || true
redis-cli shutdown 2>/dev/null || true
su - postgres -c "pg_ctl -D /var/lib/postgresql/16/main -m fast -l /tmp/postgres.log stop" 2>/dev/null || true

# Print final status
if [ $TEST_RESULT -eq 0 ]; then
    echo "FINAL_STATUS = SUCCESS"
    exit 0
else
    echo "FINAL_STATUS = FAIL"
    exit 1
fi
