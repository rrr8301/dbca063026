#!/bin/bash

# Activate environment variables
export MAVEN_OPTS="-Xmx512M -XX:+ExitOnOutOfMemoryError"
export MAVEN_INSTALL_OPTS="-Xmx3G -XX:+ExitOnOutOfMemoryError"
export MAVEN_FAST_INSTALL="-B -V -T 1C -DskipTests -Dmaven.source.skip=true -Dair.check.skip-all"
export MAVEN_TEST="-B -Dmaven.source.skip=true -Dair.check.skip-all --fail-at-end -P gib -Dgib.referenceBranch=refs/remotes/origin/master"

# Install project dependencies
mvn clean install ${MAVEN_FAST_INSTALL} -am -pl "plugin/trino-redshift" -Drat.skip=true -Dlicense.skip=true

# Run tests
mvn test ${MAVEN_TEST} -pl "plugin/trino-redshift" -P "fte-tests" \
  -Dtest.redshift.jdbc.user="${REDSHIFT_USER}" \
  -Dtest.redshift.jdbc.password="${REDSHIFT_PASSWORD}" \
  -Dtest.redshift.jdbc.endpoint="${REDSHIFT_ENDPOINT}:${REDSHIFT_PORT}/" \
  -Dtest.redshift.s3.tpch.tables.root="${REDSHIFT_S3_TPCH_TABLES_ROOT}" \
  -Dtest.redshift.s3.unload.root="${REDSHIFT_S3_UNLOAD_ROOT}" \
  -Dtest.redshift.iam.role="${REDSHIFT_IAM_ROLES}" \
  -Dtest.redshift.aws.region="${AWS_REGION}" \
  -Dtest.redshift.aws.access-key="${AWS_ACCESS_KEY_ID}" \
  -Dtest.redshift.aws.secret-key="${AWS_SECRET_ACCESS_KEY}" \
  -Drat.skip=true -Dlicense.skip=true