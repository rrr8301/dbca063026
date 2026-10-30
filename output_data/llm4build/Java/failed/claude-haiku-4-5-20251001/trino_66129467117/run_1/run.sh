#!/bin/bash

set -euo pipefail

# Set environment variables from the workflow
export CONTINUOUS_INTEGRATION=true
export MAVEN_OPTS="-Xmx512M -XX:+ExitOnOutOfMemoryError"
export MAVEN_INSTALL_OPTS="-Xmx3G -XX:+ExitOnOutOfMemoryError"
export MAVEN_FAST_INSTALL="-B -V -T 1C -DskipTests -Dmaven.source.skip=true -Dair.check.skip-all -Drat.skip=true -Dlicense.skip=true"
export MAVEN_TEST="-B -Dmaven.source.skip=true -Dair.check.skip-all --fail-at-end -Drat.skip=true -Dlicense.skip=true"
export TESTCONTAINERS_PULL_PAUSE_TIMEOUT=600
export SEGMENT_DOWNLOAD_TIMEOUT_MINS=5

# Use system maven instead of ./mvnw
MAVEN="mvn"

echo "=== Maven Install ==="
export MAVEN_OPTS="${MAVEN_INSTALL_OPTS}"
$MAVEN clean install ${MAVEN_FAST_INSTALL} -am -pl "plugin/trino-redshift" || true

echo "=== Maven Tests ==="
TEST_RESULT=0
$MAVEN test ${MAVEN_TEST} -pl plugin/trino-redshift || TEST_RESULT=$?

# Cleanup S3 buckets (will fail gracefully if AWS credentials not provided)
echo "=== Cleanup ephemeral S3 buckets ==="
if [ -n "${AWS_REGION:-}" ] && [ -n "${AWS_ACCESS_KEY_ID:-}" ] && [ -n "${AWS_SECRET_ACCESS_KEY:-}" ]; then
    if [ -f ".github/bin/s3/delete-s3-bucket.sh" ]; then
        .github/bin/s3/delete-s3-bucket.sh || true
    fi
fi

# Cloud Redshift Tests (only run if secrets are present)
echo "=== Cloud Redshift Tests ==="
REDSHIFT_TEST_RESULT=0
if [ -n "${CI_SKIP_SECRETS_PRESENCE_CHECKS:-}" ] || \
   ([ -n "${AWS_ACCESS_KEY_ID:-}" ] && [ -n "${REDSHIFT_SUBNET_GROUP_NAME:-}" ]); then
    
    # Source the Redshift setup script if it exists
    if [ -f ".github/bin/redshift/setup-aws-redshift.sh" ]; then
        source .github/bin/redshift/setup-aws-redshift.sh
        
        $MAVEN test ${MAVEN_TEST} -pl plugin/trino-redshift -P fte-tests \
            -Dtest.redshift.jdbc.user="${REDSHIFT_USER:-}" \
            -Dtest.redshift.jdbc.password="${REDSHIFT_PASSWORD:-}" \
            -Dtest.redshift.jdbc.endpoint="${REDSHIFT_ENDPOINT:-}:${REDSHIFT_PORT:-5439}/" \
            -Dtest.redshift.s3.tpch.tables.root="${REDSHIFT_S3_TPCH_TABLES_ROOT:-}" \
            -Dtest.redshift.s3.unload.root="${REDSHIFT_S3_UNLOAD_ROOT:-}" \
            -Dtest.redshift.iam.role="${REDSHIFT_IAM_ROLES:-}" \
            -Dtest.redshift.aws.region="${AWS_REGION:-}" \
            -Dtest.redshift.aws.access-key="${AWS_ACCESS_KEY_ID:-}" \
            -Dtest.redshift.aws.secret-key="${AWS_SECRET_ACCESS_KEY:-}" || REDSHIFT_TEST_RESULT=$?
    fi
fi

# Cleanup Redshift cluster (will fail gracefully if AWS credentials not provided)
echo "=== Cleanup ephemeral Redshift Cluster ==="
if [ -n "${AWS_REGION:-}" ] && [ -n "${AWS_ACCESS_KEY_ID:-}" ] && [ -n "${AWS_SECRET_ACCESS_KEY:-}" ]; then
    if [ -f ".github/bin/redshift/delete-aws-redshift.sh" ]; then
        .github/bin/redshift/delete-aws-redshift.sh || true
    fi
fi

# Exit with failure if any test failed
if [ "${TEST_RESULT}" -ne 0 ] || [ "${REDSHIFT_TEST_RESULT}" -ne 0 ]; then
    exit 1
fi

exit 0