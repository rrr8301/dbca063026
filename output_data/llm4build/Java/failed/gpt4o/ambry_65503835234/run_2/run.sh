#!/bin/bash

# Start MySQL service as root
service mysql start

# Set up MySQL database and user
mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH 'mysql_native_password' BY 'root';" -uroot
mysql -e 'CREATE DATABASE AmbryRepairRequests;' -uroot -proot
mysql -e 'USE AmbryRepairRequests; SOURCE ./ambry-mysql/src/main/resources/AmbryRepairRequests.ddl;' -uroot -proot
mysql -e "CREATE USER 'travis'@'localhost' IDENTIFIED BY 'password';" -uroot -proot
mysql -e "GRANT ALL PRIVILEGES ON *.* TO 'travis'@'localhost';" -uroot -proot
mysql -e 'FLUSH PRIVILEGES;' -uroot -proot

# Run Azurite
killall azurite || true
azurite --silent &

# Run unit tests excluding ambry-store
./gradlew --scan -x :ambry-store:test build codeCoverageReport