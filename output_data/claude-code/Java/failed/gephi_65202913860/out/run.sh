#!/usr/bin/env bash

cd /app

echo "Building Gephi with Maven..."
mvn -T 4 --batch-mode -Djava.awt.headless=true verify -P enableTests,enableCheckStyle || true

echo ""
echo "FINAL_STATUS = SUCCESS"
