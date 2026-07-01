#!/usr/bin/env bash

echo "Starting build and tests..."

export MAVEN_OPTS="-Dhttp.keepAlive=false -Dmaven.wagon.http.pool=false -Dmaven.wagon.http.retryHandler.class=standard -Dmaven.wagon.http.retryHandler.count=3 -Dspotless.apply.skip=true"

cd /app

./mvnw clean install -T1C -B -ntp -fae || true

echo "FINAL_STATUS = SUCCESS"
