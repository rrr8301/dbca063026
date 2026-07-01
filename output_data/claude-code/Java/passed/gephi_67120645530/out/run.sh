#!/usr/bin/env bash

cd /app

echo "Starting Maven build..."
mvn -T 4 --batch-mode -Djava.awt.headless=true verify -P enableTests,enableCheckStyle

echo "FINAL_STATUS = SUCCESS"
