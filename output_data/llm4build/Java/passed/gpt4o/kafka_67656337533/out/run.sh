#!/bin/bash

# Activate environments if needed (none specified)

# Install project dependencies
# Assuming Gradle and Java are already set up in the Dockerfile

# Run tests using the exact command from the YAML
set +e
./.github/scripts/thread-dump.sh &
timeout 180m ./gradlew --build-cache --continue --no-scan \
-PtestLoggingEvents=started,passed,skipped,failed \
-PmaxParallelForks=4 \
-PmaxTestRetries=3 -PmaxTestRetryFailures=10 \
-Pkafka.test.catalog.file=combined-test-catalog.txt \
-Pkafka.test.run.new=true \
-Pkafka.test.run.flaky=true \
-Pkafka.test.xml.output.dir=25-flaky-new \
-Pkafka.cluster.test.repeat=3 \
-Pkafka.test.verbose=false \
-PcommitId=xxxxxxxxxxxxxxxx \
-x spotbugsMain \
-x spotbugsTest \
test
exitcode="$?"
echo "exitcode=$exitcode"