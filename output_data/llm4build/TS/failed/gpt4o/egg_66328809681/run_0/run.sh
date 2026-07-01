#!/bin/bash

# Start Redis server
service redis-server start

# Start MySQL server
service mysql start

# Initialize the database
mysql -uroot -e "CREATE DATABASE IF NOT EXISTS test;"

# Run tests
pnpm run ci --shard=3/3