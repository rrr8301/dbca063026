#!/bin/bash
cd /app/superset-frontend
npm run test -- --coverage --shard=3/8 --coverageReporters=json