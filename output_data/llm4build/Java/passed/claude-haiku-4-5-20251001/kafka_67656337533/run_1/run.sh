timeout ${TIMEOUT_MINUTES}m ./gradlew --build-cache --continue --no-scan \
  -PtestLoggingEvents=started,passed,skipped,failed \
  -PmaxParallelForks=4 \
  -PmaxTestRetries=$TEST_RETRIES -PmaxTestRetryFailures=10 \
  -Pkafka.test.catalog.file=$TEST_CATALOG \
  -Pkafka.test.run.new=$RUN_NEW_TESTS \
  -Pkafka.test.run.flaky=$RUN_FLAKY_TESTS \
  -Pkafka.test.xml.output.dir=$TEST_XML_OUTPUT_DIR \
  -Pkafka.cluster.test.repeat=$TEST_REPEAT \
  -Pkafka.test.verbose=$TEST_VERBOSE \
  -PcommitId=xxxxxxxxxxxxxxxx \
  -x spotbugsMain \
  -x spotbugsTest \
  $TEST_TASK