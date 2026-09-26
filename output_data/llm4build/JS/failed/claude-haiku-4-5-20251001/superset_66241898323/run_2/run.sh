#!/bin/bash
cd /app/superset-frontend
npm run test -- --coverage --shard=4/8 --coverageReporters=json