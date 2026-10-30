#!/bin/bash

# Start Redis server
service redis-server start

# Start MySQL server
service mysql start

# Wait for MySQL to be ready
until mysqladmin ping -h "localhost" --silent; do
    echo "Waiting for MySQL to be ready..."
    sleep 2
done

# Initialize the database with a passwordless root user
mysql -uroot -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH 'mysql_native_password' BY '';"
mysql -uroot -e "CREATE DATABASE IF NOT EXISTS test;"

# Run tests
pnpm run ci --shard=3/3