#!/bin/bash

# Clone the repository (simulating actions/checkout)
git clone https://github.com/your/repo.git /app
cd /app

# Simulate downloading the Python wheel (assume it's available locally)
# Normally, you would use the following command:
# python3 ops/pipeline/manage-artifacts.py download --s3-bucket $RUNS_ON_S3_BUCKET_CACHE --prefix cache/$GITHUB_RUN_ID/audit-cuda12-wheel-x86_64 --dest-dir wheelhouse *.whl

# Run Python tests
bash ops/pipeline/test-python-wheel.sh --suite cpu