#!/usr/bin/env bash
export GITHUB_WORKSPACE=/home/github/build/apache/pulsar

if [[ ! -z "$ACTIONS_RUNNER_HOOK_JOB_STARTED" ]]; then
   echo "A job started hook has been configured by the self-hosted runner administrator"
   echo "##[group]Run '$ACTIONS_RUNNER_HOOK_JOB_STARTED'"
   echo "##[endgroup]"
   bash -e $ACTIONS_RUNNER_HOOK_JOB_STARTED 68311819544 failed
   EXIT_CODE=$?
   if [[ $EXIT_CODE != 0 ]]; then
       echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."
       exit $EXIT_CODE
   fi
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

set -o allexport
source /etc/environment
set +o allexport

export _GITHUB_JOB_STATUS=success

cd ${GITHUB_WORKSPACE}

echo "##[group]Operating System"
echo "Ubuntu"
echo "22.04"
echo "LTS"
echo "##[endgroup]"

mkdir -p /home/github/workflow/

cp /home/github/68311819544/event.json /home/github/workflow/event.json
echo -n > /home/github/workflow/envs.txt
echo -n > /home/github/workflow/paths.txt
echo -n > /home/github/workflow/output.txt
echo -n > /home/github/workflow/state.txt

CURRENT_ENV=()
LAST_JOB_NAME=UNKNOWN
declare -gA STEP_OUTPUTS_ENV_MAP
update_current_env() {
  LAST_JOB_NAME=$1
  CURRENT_ENV=()
  unset CURRENT_ENV_MAP
  declare -gA CURRENT_ENV_MAP
  if [ -f /home/github/workflow/envs.txt ]; then
    local KEY=""
    local VALUE=""
    local DELIMITER=""
    local regex="(.*)<<(.*)"
    local regex2="(.*)=(.*)"

    while read line; do
      if [[ "$KEY" = "" && "$line" =~ $regex ]]; then
        KEY="${BASH_REMATCH[1]}"
        DELIMITER="${BASH_REMATCH[2]}"
      elif [[ "$KEY" != "" && "$line" = "$DELIMITER" ]]; then
        CURRENT_ENV_MAP["$KEY"]="$VALUE"
        KEY=""
        VALUE=""
        DELIMITER=""
      elif [[ "$KEY" != "" ]]; then
        if [[ $VALUE = "" ]]; then
          VALUE="$line"
        else
          VALUE="$VALUE
$line"
        fi
      elif [[ "$line" =~ $regex2 ]]; then
        CURRENT_ENV_MAP["${BASH_REMATCH[1]}"]="${BASH_REMATCH[2]}"
      fi
    done < /home/github/workflow/envs.txt

  else
    echo -n "" > /home/github/workflow/envs.txt
  fi

  if [ -f /home/github/workflow/output.txt ]; then
    local KEY=""
    local VALUE=""
    local DELIMITER=""
    local regex="(.*)<<(.*)"
    local regex2="(.*)=(.*)"

    while read line; do
      if [[ "$KEY" = "" && "$line" =~ $regex ]]; then
        KEY="${BASH_REMATCH[1]^^}"
        KEY=${KEY//-/_}
        DELIMITER="${BASH_REMATCH[2]}"
      elif [[ "$KEY" != "" && "$line" = "$DELIMITER" ]]; then
        STEP_OUTPUTS_ENV_MAP["_CONTEXT_STEPS_"$LAST_JOB_NAME"_OUTPUTS_$KEY"]="${VALUE}"
        KEY=""
        VALUE=""
        DELIMITER=""
      elif [[ "$KEY" != "" ]]; then
        if [[ $VALUE = "" ]]; then
          VALUE="$line"
        else
          VALUE="$VALUE
$line"
        fi
      elif [[ "$line" =~ $regex2 ]]; then
        KEY="${BASH_REMATCH[1]^^}"
        KEY=${KEY//-/_}
        VALUE="${BASH_REMATCH[2]}"
        STEP_OUTPUTS_ENV_MAP["_CONTEXT_STEPS_"$LAST_JOB_NAME"_OUTPUTS_$KEY"]="${VALUE}"
        KEY=""
        VALUE=""
      fi
    done < /home/github/workflow/output.txt
    echo -n "" > /home/github/workflow/output.txt

  else
    echo -n "" > /home/github/workflow/output.txt
  fi

  for key in "${!CURRENT_ENV_MAP[@]}"; do
    val="${CURRENT_ENV_MAP["$key"]}"
    CURRENT_ENV+=("${key}=${val}")
  done
}

update_current_env "$LAST_JOB_NAME"
LAST_JOB_NAME="UNKNOWN"
if [ -f /home/github/workflow/paths.txt ]; then
   while read NEW_PATH 
   do
      PATH="$(eval echo "$NEW_PATH"):$PATH"
   done <<< "$(cat /home/github/workflow/paths.txt)"
else
  echo -n "" > /home/github/workflow/paths.txt
fi

if [ ! -f /home/github/workflow/event.json ]; then
  echo -n "{}" > /home/github/workflow/event.json
fi

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=1 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=apache/pulsar GITHUB_ACTIONS=true GITHUB_ACTOR=lhotari GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/pulsar GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=08d89a2ea1a2a566197f5db004881c4e222bb3ac GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Pulsar CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 MAVEN_OPTS='-Xss1500k -Xmx2048m -XX:+UnlockDiagnosticVMOptions -XX:+IgnoreUnrecognizedVMOptions -XX:GCLockerRetryAllocationCount=100 -Daether.connector.http.reuseConnections=false -Daether.connector.requestTimeout=60000 -Dhttp.keepAlive=false -Dmaven.wagon.http.pool=false -Dmaven.wagon.http.retryHandler.class=standard -Dmaven.wagon.http.retryHandler.count=3 -Dmaven.wagon.http.retryHandler.requestSentEnabled=true -Dmaven.wagon.http.serviceUnavailableRetryStrategy.class=standard -Dmaven.wagon.rto=60000' ARTIFACT_RETENTION_DAYS=3 JDK_DISTRIBUTION=corretto GITHUB_ACTION_PATH=/home/github/68311819544/actions/apache-pulsar/./.github/actions/tune-runner-vm JOB_NAME='CI - Integration - Messaging' PULSAR_TEST_IMAGE_NAME=apachepulsar/java-test-image:latest DEVELOCITY_ACCESS_KEY= CI_JDK_MAJOR_VERSION= NETTY_LEAK_DETECTION= NETTY_LEAK_DUMP_DIR=${GITHUB_WORKSPACE}/target/netty-leak-dumps "${CURRENT_ENV[@]}" \
echo $(test "$_GITHUB_JOB_STATUS" = "success" && echo true || echo false))
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=1 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=apache/pulsar GITHUB_ACTIONS=true GITHUB_ACTOR=lhotari GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/pulsar GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=08d89a2ea1a2a566197f5db004881c4e222bb3ac GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Pulsar CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 MAVEN_OPTS='-Xss1500k -Xmx2048m -XX:+UnlockDiagnosticVMOptions -XX:+IgnoreUnrecognizedVMOptions -XX:GCLockerRetryAllocationCount=100 -Daether.connector.http.reuseConnections=false -Daether.connector.requestTimeout=60000 -Dhttp.keepAlive=false -Dmaven.wagon.http.pool=false -Dmaven.wagon.http.retryHandler.class=standard -Dmaven.wagon.http.retryHandler.count=3 -Dmaven.wagon.http.retryHandler.requestSentEnabled=true -Dmaven.wagon.http.serviceUnavailableRetryStrategy.class=standard -Dmaven.wagon.rto=60000' ARTIFACT_RETENTION_DAYS=3 JDK_DISTRIBUTION=corretto GITHUB_ACTION_PATH=/home/github/68311819544/actions/apache-pulsar/./.github/actions/tune-runner-vm JOB_NAME='CI - Integration - Messaging' PULSAR_TEST_IMAGE_NAME=apachepulsar/java-test-image:latest DEVELOCITY_ACCESS_KEY= CI_JDK_MAJOR_VERSION= NETTY_LEAK_DETECTION= NETTY_LEAK_DUMP_DIR=${GITHUB_WORKSPACE}/target/netty-leak-dumps "${CURRENT_ENV[@]}" \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run ./.github/actions/tune-runner-vm
echo "##[endgroup]"
echo /home/github/68311819544/steps/bugswarm_1_composite.sh > /home/github/68311819544/steps/bugswarm_1.sh
chmod u+x /home/github/68311819544/steps/bugswarm_1.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=1 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=apache/pulsar GITHUB_ACTIONS=true GITHUB_ACTOR=lhotari GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/pulsar GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=08d89a2ea1a2a566197f5db004881c4e222bb3ac GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Pulsar CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 MAVEN_OPTS='-Xss1500k -Xmx2048m -XX:+UnlockDiagnosticVMOptions -XX:+IgnoreUnrecognizedVMOptions -XX:GCLockerRetryAllocationCount=100 -Daether.connector.http.reuseConnections=false -Daether.connector.requestTimeout=60000 -Dhttp.keepAlive=false -Dmaven.wagon.http.pool=false -Dmaven.wagon.http.retryHandler.class=standard -Dmaven.wagon.http.retryHandler.count=3 -Dmaven.wagon.http.retryHandler.requestSentEnabled=true -Dmaven.wagon.http.serviceUnavailableRetryStrategy.class=standard -Dmaven.wagon.rto=60000' ARTIFACT_RETENTION_DAYS=3 JDK_DISTRIBUTION=corretto GITHUB_ACTION_PATH=/home/github/68311819544/actions/apache-pulsar/./.github/actions/tune-runner-vm JOB_NAME='CI - Integration - Messaging' PULSAR_TEST_IMAGE_NAME=apachepulsar/java-test-image:latest DEVELOCITY_ACCESS_KEY= CI_JDK_MAJOR_VERSION= NETTY_LEAK_DETECTION= NETTY_LEAK_DUMP_DIR=${GITHUB_WORKSPACE}/target/netty-leak-dumps "${CURRENT_ENV[@]}" \
bash -e /home/github/68311819544/steps/bugswarm_1.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=1 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=apache/pulsar GITHUB_ACTIONS=true GITHUB_ACTOR=lhotari GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/pulsar GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=08d89a2ea1a2a566197f5db004881c4e222bb3ac GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Pulsar CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 MAVEN_OPTS='-Xss1500k -Xmx2048m -XX:+UnlockDiagnosticVMOptions -XX:+IgnoreUnrecognizedVMOptions -XX:GCLockerRetryAllocationCount=100 -Daether.connector.http.reuseConnections=false -Daether.connector.requestTimeout=60000 -Dhttp.keepAlive=false -Dmaven.wagon.http.pool=false -Dmaven.wagon.http.retryHandler.class=standard -Dmaven.wagon.http.retryHandler.count=3 -Dmaven.wagon.http.retryHandler.requestSentEnabled=true -Dmaven.wagon.http.serviceUnavailableRetryStrategy.class=standard -Dmaven.wagon.rto=60000' ARTIFACT_RETENTION_DAYS=3 JDK_DISTRIBUTION=corretto GITHUB_ACTION_PATH=/home/github/68311819544/actions/apache-pulsar/./.github/actions/tune-runner-vm JOB_NAME='CI - Integration - Messaging' PULSAR_TEST_IMAGE_NAME=apachepulsar/java-test-image:latest DEVELOCITY_ACCESS_KEY= CI_JDK_MAJOR_VERSION= NETTY_LEAK_DETECTION= NETTY_LEAK_DUMP_DIR=${GITHUB_WORKSPACE}/target/netty-leak-dumps "${CURRENT_ENV[@]}" \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=1 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=apache/pulsar GITHUB_ACTIONS=true GITHUB_ACTOR=lhotari GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/pulsar GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=08d89a2ea1a2a566197f5db004881c4e222bb3ac GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Pulsar CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 MAVEN_OPTS='-Xss1500k -Xmx2048m -XX:+UnlockDiagnosticVMOptions -XX:+IgnoreUnrecognizedVMOptions -XX:GCLockerRetryAllocationCount=100 -Daether.connector.http.reuseConnections=false -Daether.connector.requestTimeout=60000 -Dhttp.keepAlive=false -Dmaven.wagon.http.pool=false -Dmaven.wagon.http.retryHandler.class=standard -Dmaven.wagon.http.retryHandler.count=3 -Dmaven.wagon.http.retryHandler.requestSentEnabled=true -Dmaven.wagon.http.serviceUnavailableRetryStrategy.class=standard -Dmaven.wagon.rto=60000' ARTIFACT_RETENTION_DAYS=3 JDK_DISTRIBUTION=corretto GITHUB_ACTION_PATH=/home/github/68311819544/actions/apache-pulsar/./.github/actions/tune-runner-vm JOB_NAME='CI - Integration - Messaging' PULSAR_TEST_IMAGE_NAME=apachepulsar/java-test-image:latest DEVELOCITY_ACCESS_KEY= CI_JDK_MAJOR_VERSION= NETTY_LEAK_DETECTION= NETTY_LEAK_DUMP_DIR=${GITHUB_WORKSPACE}/target/netty-leak-dumps "${CURRENT_ENV[@]}" \
bash -e $ACTIONS_RUNNER_HOOK_STEP_COMPLETED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

fi

update_current_env "$LAST_JOB_NAME"
LAST_JOB_NAME="UNKNOWN"
if [ -f /home/github/workflow/paths.txt ]; then
   while read NEW_PATH 
   do
      PATH="$(eval echo "$NEW_PATH"):$PATH"
   done <<< "$(cat /home/github/workflow/paths.txt)"
else
  echo -n "" > /home/github/workflow/paths.txt
fi

if [ ! -f /home/github/workflow/event.json ]; then
  echo -n "{}" > /home/github/workflow/event.json
fi

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=2 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=apache/pulsar GITHUB_ACTIONS=true GITHUB_ACTOR=lhotari GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/pulsar GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=08d89a2ea1a2a566197f5db004881c4e222bb3ac GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Pulsar CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 MAVEN_OPTS='-Xss1500k -Xmx2048m -XX:+UnlockDiagnosticVMOptions -XX:+IgnoreUnrecognizedVMOptions -XX:GCLockerRetryAllocationCount=100 -Daether.connector.http.reuseConnections=false -Daether.connector.requestTimeout=60000 -Dhttp.keepAlive=false -Dmaven.wagon.http.pool=false -Dmaven.wagon.http.retryHandler.class=standard -Dmaven.wagon.http.retryHandler.count=3 -Dmaven.wagon.http.retryHandler.requestSentEnabled=true -Dmaven.wagon.http.serviceUnavailableRetryStrategy.class=standard -Dmaven.wagon.rto=60000' ARTIFACT_RETENTION_DAYS=3 JDK_DISTRIBUTION=corretto GITHUB_ACTION_PATH=/home/github/68311819544/actions/apache-pulsar/./.github/actions/ssh-access JOB_NAME='CI - Integration - Messaging' PULSAR_TEST_IMAGE_NAME=apachepulsar/java-test-image:latest DEVELOCITY_ACCESS_KEY= CI_JDK_MAJOR_VERSION= NETTY_LEAK_DETECTION= NETTY_LEAK_DUMP_DIR=${GITHUB_WORKSPACE}/target/netty-leak-dumps "${CURRENT_ENV[@]}" INPUT_LIMIT-ACCESS-TO-ACTOR=true INPUT_ACTION=start INPUT_LIMIT-ACCESS-TO-USERS= INPUT_SECURE-ACCESS=true INPUT_TIMEOUT=300 \
echo "$(/home/github/68311819544/helpers/eval_expression p:'(' f:success p:'(' p:')' p:')' o:'&&' p:'(' p:'(' s:apache/pulsar o:'!=' s:apache/pulsar p:')' o:'&&' p:'(' s:push o:== s:pull_request p:')' p:')')")
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=2 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=apache/pulsar GITHUB_ACTIONS=true GITHUB_ACTOR=lhotari GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/pulsar GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=08d89a2ea1a2a566197f5db004881c4e222bb3ac GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Pulsar CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 MAVEN_OPTS='-Xss1500k -Xmx2048m -XX:+UnlockDiagnosticVMOptions -XX:+IgnoreUnrecognizedVMOptions -XX:GCLockerRetryAllocationCount=100 -Daether.connector.http.reuseConnections=false -Daether.connector.requestTimeout=60000 -Dhttp.keepAlive=false -Dmaven.wagon.http.pool=false -Dmaven.wagon.http.retryHandler.class=standard -Dmaven.wagon.http.retryHandler.count=3 -Dmaven.wagon.http.retryHandler.requestSentEnabled=true -Dmaven.wagon.http.serviceUnavailableRetryStrategy.class=standard -Dmaven.wagon.rto=60000' ARTIFACT_RETENTION_DAYS=3 JDK_DISTRIBUTION=corretto GITHUB_ACTION_PATH=/home/github/68311819544/actions/apache-pulsar/./.github/actions/ssh-access JOB_NAME='CI - Integration - Messaging' PULSAR_TEST_IMAGE_NAME=apachepulsar/java-test-image:latest DEVELOCITY_ACCESS_KEY= CI_JDK_MAJOR_VERSION= NETTY_LEAK_DETECTION= NETTY_LEAK_DUMP_DIR=${GITHUB_WORKSPACE}/target/netty-leak-dumps "${CURRENT_ENV[@]}" INPUT_LIMIT-ACCESS-TO-ACTOR=true INPUT_ACTION=start INPUT_LIMIT-ACCESS-TO-USERS= INPUT_SECURE-ACCESS=true INPUT_TIMEOUT=300 \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run ./.github/actions/ssh-access
echo "##[endgroup]"
echo /home/github/68311819544/steps/bugswarm_2_composite.sh > /home/github/68311819544/steps/bugswarm_2.sh
chmod u+x /home/github/68311819544/steps/bugswarm_2.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=2 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=apache/pulsar GITHUB_ACTIONS=true GITHUB_ACTOR=lhotari GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/pulsar GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=08d89a2ea1a2a566197f5db004881c4e222bb3ac GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Pulsar CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 MAVEN_OPTS='-Xss1500k -Xmx2048m -XX:+UnlockDiagnosticVMOptions -XX:+IgnoreUnrecognizedVMOptions -XX:GCLockerRetryAllocationCount=100 -Daether.connector.http.reuseConnections=false -Daether.connector.requestTimeout=60000 -Dhttp.keepAlive=false -Dmaven.wagon.http.pool=false -Dmaven.wagon.http.retryHandler.class=standard -Dmaven.wagon.http.retryHandler.count=3 -Dmaven.wagon.http.retryHandler.requestSentEnabled=true -Dmaven.wagon.http.serviceUnavailableRetryStrategy.class=standard -Dmaven.wagon.rto=60000' ARTIFACT_RETENTION_DAYS=3 JDK_DISTRIBUTION=corretto GITHUB_ACTION_PATH=/home/github/68311819544/actions/apache-pulsar/./.github/actions/ssh-access JOB_NAME='CI - Integration - Messaging' PULSAR_TEST_IMAGE_NAME=apachepulsar/java-test-image:latest DEVELOCITY_ACCESS_KEY= CI_JDK_MAJOR_VERSION= NETTY_LEAK_DETECTION= NETTY_LEAK_DUMP_DIR=${GITHUB_WORKSPACE}/target/netty-leak-dumps "${CURRENT_ENV[@]}" INPUT_LIMIT-ACCESS-TO-ACTOR=true INPUT_ACTION=start INPUT_LIMIT-ACCESS-TO-USERS= INPUT_SECURE-ACCESS=true INPUT_TIMEOUT=300 \
bash -e /home/github/68311819544/steps/bugswarm_2.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=2 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=apache/pulsar GITHUB_ACTIONS=true GITHUB_ACTOR=lhotari GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/pulsar GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=08d89a2ea1a2a566197f5db004881c4e222bb3ac GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Pulsar CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 MAVEN_OPTS='-Xss1500k -Xmx2048m -XX:+UnlockDiagnosticVMOptions -XX:+IgnoreUnrecognizedVMOptions -XX:GCLockerRetryAllocationCount=100 -Daether.connector.http.reuseConnections=false -Daether.connector.requestTimeout=60000 -Dhttp.keepAlive=false -Dmaven.wagon.http.pool=false -Dmaven.wagon.http.retryHandler.class=standard -Dmaven.wagon.http.retryHandler.count=3 -Dmaven.wagon.http.retryHandler.requestSentEnabled=true -Dmaven.wagon.http.serviceUnavailableRetryStrategy.class=standard -Dmaven.wagon.rto=60000' ARTIFACT_RETENTION_DAYS=3 JDK_DISTRIBUTION=corretto GITHUB_ACTION_PATH=/home/github/68311819544/actions/apache-pulsar/./.github/actions/ssh-access JOB_NAME='CI - Integration - Messaging' PULSAR_TEST_IMAGE_NAME=apachepulsar/java-test-image:latest DEVELOCITY_ACCESS_KEY= CI_JDK_MAJOR_VERSION= NETTY_LEAK_DETECTION= NETTY_LEAK_DUMP_DIR=${GITHUB_WORKSPACE}/target/netty-leak-dumps "${CURRENT_ENV[@]}" INPUT_LIMIT-ACCESS-TO-ACTOR=true INPUT_ACTION=start INPUT_LIMIT-ACCESS-TO-USERS= INPUT_SECURE-ACCESS=true INPUT_TIMEOUT=300 \
echo true)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=2 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=apache/pulsar GITHUB_ACTIONS=true GITHUB_ACTOR=lhotari GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/pulsar GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=08d89a2ea1a2a566197f5db004881c4e222bb3ac GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Pulsar CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 MAVEN_OPTS='-Xss1500k -Xmx2048m -XX:+UnlockDiagnosticVMOptions -XX:+IgnoreUnrecognizedVMOptions -XX:GCLockerRetryAllocationCount=100 -Daether.connector.http.reuseConnections=false -Daether.connector.requestTimeout=60000 -Dhttp.keepAlive=false -Dmaven.wagon.http.pool=false -Dmaven.wagon.http.retryHandler.class=standard -Dmaven.wagon.http.retryHandler.count=3 -Dmaven.wagon.http.retryHandler.requestSentEnabled=true -Dmaven.wagon.http.serviceUnavailableRetryStrategy.class=standard -Dmaven.wagon.rto=60000' ARTIFACT_RETENTION_DAYS=3 JDK_DISTRIBUTION=corretto GITHUB_ACTION_PATH=/home/github/68311819544/actions/apache-pulsar/./.github/actions/ssh-access JOB_NAME='CI - Integration - Messaging' PULSAR_TEST_IMAGE_NAME=apachepulsar/java-test-image:latest DEVELOCITY_ACCESS_KEY= CI_JDK_MAJOR_VERSION= NETTY_LEAK_DETECTION= NETTY_LEAK_DUMP_DIR=${GITHUB_WORKSPACE}/target/netty-leak-dumps "${CURRENT_ENV[@]}" INPUT_LIMIT-ACCESS-TO-ACTOR=true INPUT_ACTION=start INPUT_LIMIT-ACCESS-TO-USERS= INPUT_SECURE-ACCESS=true INPUT_TIMEOUT=300 \
bash -e $ACTIONS_RUNNER_HOOK_STEP_COMPLETED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

fi

update_current_env "$LAST_JOB_NAME"
LAST_JOB_NAME="UNKNOWN"
if [ -f /home/github/workflow/paths.txt ]; then
   while read NEW_PATH 
   do
      PATH="$(eval echo "$NEW_PATH"):$PATH"
   done <<< "$(cat /home/github/workflow/paths.txt)"
else
  echo -n "" > /home/github/workflow/paths.txt
fi

if [ ! -f /home/github/workflow/event.json ]; then
  echo -n "{}" > /home/github/workflow/event.json
fi

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=4 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=actions/setup-java GITHUB_ACTIONS=true GITHUB_ACTOR=lhotari GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/pulsar GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=08d89a2ea1a2a566197f5db004881c4e222bb3ac GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Pulsar CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 MAVEN_OPTS='-Xss1500k -Xmx2048m -XX:+UnlockDiagnosticVMOptions -XX:+IgnoreUnrecognizedVMOptions -XX:GCLockerRetryAllocationCount=100 -Daether.connector.http.reuseConnections=false -Daether.connector.requestTimeout=60000 -Dhttp.keepAlive=false -Dmaven.wagon.http.pool=false -Dmaven.wagon.http.retryHandler.class=standard -Dmaven.wagon.http.retryHandler.count=3 -Dmaven.wagon.http.retryHandler.requestSentEnabled=true -Dmaven.wagon.http.serviceUnavailableRetryStrategy.class=standard -Dmaven.wagon.rto=60000' ARTIFACT_RETENTION_DAYS=3 JDK_DISTRIBUTION=corretto GITHUB_ACTION_PATH=/home/github/68311819544/actions/actions-setup-java@v4 JOB_NAME='CI - Integration - Messaging' PULSAR_TEST_IMAGE_NAME=apachepulsar/java-test-image:latest DEVELOCITY_ACCESS_KEY= CI_JDK_MAJOR_VERSION= NETTY_LEAK_DETECTION= NETTY_LEAK_DUMP_DIR=${GITHUB_WORKSPACE}/target/netty-leak-dumps "${CURRENT_ENV[@]}" INPUT_DISTRIBUTION="$(test -v "CURRENT_ENV_MAP[JDK_DISTRIBUTION]" && echo "${CURRENT_ENV_MAP[JDK_DISTRIBUTION]}" || echo corretto)" INPUT_JAVA-VERSION="$(test -v "CURRENT_ENV_MAP[CI_JDK_MAJOR_VERSION]" && echo "${CURRENT_ENV_MAP[CI_JDK_MAJOR_VERSION]}" || echo )" INPUT_OVERWRITE-SETTINGS=False INPUT_TOKEN= INPUT_JAVA-PACKAGE=jdk INPUT_CHECK-LATEST=false INPUT_SERVER-ID=github INPUT_SERVER-USERNAME=GITHUB_ACTOR INPUT_SERVER-PASSWORD=GITHUB_TOKEN INPUT_JOB-STATUS="${_GITHUB_JOB_STATUS}" \
echo $(test "$_GITHUB_JOB_STATUS" = "success" && echo true || echo false))
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=4 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=actions/setup-java GITHUB_ACTIONS=true GITHUB_ACTOR=lhotari GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/pulsar GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=08d89a2ea1a2a566197f5db004881c4e222bb3ac GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Pulsar CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 MAVEN_OPTS='-Xss1500k -Xmx2048m -XX:+UnlockDiagnosticVMOptions -XX:+IgnoreUnrecognizedVMOptions -XX:GCLockerRetryAllocationCount=100 -Daether.connector.http.reuseConnections=false -Daether.connector.requestTimeout=60000 -Dhttp.keepAlive=false -Dmaven.wagon.http.pool=false -Dmaven.wagon.http.retryHandler.class=standard -Dmaven.wagon.http.retryHandler.count=3 -Dmaven.wagon.http.retryHandler.requestSentEnabled=true -Dmaven.wagon.http.serviceUnavailableRetryStrategy.class=standard -Dmaven.wagon.rto=60000' ARTIFACT_RETENTION_DAYS=3 JDK_DISTRIBUTION=corretto GITHUB_ACTION_PATH=/home/github/68311819544/actions/actions-setup-java@v4 JOB_NAME='CI - Integration - Messaging' PULSAR_TEST_IMAGE_NAME=apachepulsar/java-test-image:latest DEVELOCITY_ACCESS_KEY= CI_JDK_MAJOR_VERSION= NETTY_LEAK_DETECTION= NETTY_LEAK_DUMP_DIR=${GITHUB_WORKSPACE}/target/netty-leak-dumps "${CURRENT_ENV[@]}" INPUT_DISTRIBUTION="$(test -v "CURRENT_ENV_MAP[JDK_DISTRIBUTION]" && echo "${CURRENT_ENV_MAP[JDK_DISTRIBUTION]}" || echo corretto)" INPUT_JAVA-VERSION="$(test -v "CURRENT_ENV_MAP[CI_JDK_MAJOR_VERSION]" && echo "${CURRENT_ENV_MAP[CI_JDK_MAJOR_VERSION]}" || echo )" INPUT_OVERWRITE-SETTINGS=False INPUT_TOKEN= INPUT_JAVA-PACKAGE=jdk INPUT_CHECK-LATEST=false INPUT_SERVER-ID=github INPUT_SERVER-USERNAME=GITHUB_ACTOR INPUT_SERVER-PASSWORD=GITHUB_TOKEN INPUT_JOB-STATUS="${_GITHUB_JOB_STATUS}" \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run actions/setup-java@v4
echo "##[endgroup]"
echo node /home/github/68311819544/actions/actions-setup-java@v4/dist/setup/index.js > /home/github/68311819544/steps/bugswarm_cmd.sh
chmod u+x /home/github/68311819544/steps/bugswarm_cmd.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=4 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=actions/setup-java GITHUB_ACTIONS=true GITHUB_ACTOR=lhotari GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/pulsar GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=08d89a2ea1a2a566197f5db004881c4e222bb3ac GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Pulsar CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 MAVEN_OPTS='-Xss1500k -Xmx2048m -XX:+UnlockDiagnosticVMOptions -XX:+IgnoreUnrecognizedVMOptions -XX:GCLockerRetryAllocationCount=100 -Daether.connector.http.reuseConnections=false -Daether.connector.requestTimeout=60000 -Dhttp.keepAlive=false -Dmaven.wagon.http.pool=false -Dmaven.wagon.http.retryHandler.class=standard -Dmaven.wagon.http.retryHandler.count=3 -Dmaven.wagon.http.retryHandler.requestSentEnabled=true -Dmaven.wagon.http.serviceUnavailableRetryStrategy.class=standard -Dmaven.wagon.rto=60000' ARTIFACT_RETENTION_DAYS=3 JDK_DISTRIBUTION=corretto GITHUB_ACTION_PATH=/home/github/68311819544/actions/actions-setup-java@v4 JOB_NAME='CI - Integration - Messaging' PULSAR_TEST_IMAGE_NAME=apachepulsar/java-test-image:latest DEVELOCITY_ACCESS_KEY= CI_JDK_MAJOR_VERSION= NETTY_LEAK_DETECTION= NETTY_LEAK_DUMP_DIR=${GITHUB_WORKSPACE}/target/netty-leak-dumps "${CURRENT_ENV[@]}" INPUT_DISTRIBUTION="$(test -v "CURRENT_ENV_MAP[JDK_DISTRIBUTION]" && echo "${CURRENT_ENV_MAP[JDK_DISTRIBUTION]}" || echo corretto)" INPUT_JAVA-VERSION="$(test -v "CURRENT_ENV_MAP[CI_JDK_MAJOR_VERSION]" && echo "${CURRENT_ENV_MAP[CI_JDK_MAJOR_VERSION]}" || echo )" INPUT_OVERWRITE-SETTINGS=False INPUT_TOKEN= INPUT_JAVA-PACKAGE=jdk INPUT_CHECK-LATEST=false INPUT_SERVER-ID=github INPUT_SERVER-USERNAME=GITHUB_ACTOR INPUT_SERVER-PASSWORD=GITHUB_TOKEN INPUT_JOB-STATUS="${_GITHUB_JOB_STATUS}" \
bash -e /home/github/68311819544/steps/bugswarm_cmd.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=4 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=actions/setup-java GITHUB_ACTIONS=true GITHUB_ACTOR=lhotari GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/pulsar GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=08d89a2ea1a2a566197f5db004881c4e222bb3ac GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Pulsar CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 MAVEN_OPTS='-Xss1500k -Xmx2048m -XX:+UnlockDiagnosticVMOptions -XX:+IgnoreUnrecognizedVMOptions -XX:GCLockerRetryAllocationCount=100 -Daether.connector.http.reuseConnections=false -Daether.connector.requestTimeout=60000 -Dhttp.keepAlive=false -Dmaven.wagon.http.pool=false -Dmaven.wagon.http.retryHandler.class=standard -Dmaven.wagon.http.retryHandler.count=3 -Dmaven.wagon.http.retryHandler.requestSentEnabled=true -Dmaven.wagon.http.serviceUnavailableRetryStrategy.class=standard -Dmaven.wagon.rto=60000' ARTIFACT_RETENTION_DAYS=3 JDK_DISTRIBUTION=corretto GITHUB_ACTION_PATH=/home/github/68311819544/actions/actions-setup-java@v4 JOB_NAME='CI - Integration - Messaging' PULSAR_TEST_IMAGE_NAME=apachepulsar/java-test-image:latest DEVELOCITY_ACCESS_KEY= CI_JDK_MAJOR_VERSION= NETTY_LEAK_DETECTION= NETTY_LEAK_DUMP_DIR=${GITHUB_WORKSPACE}/target/netty-leak-dumps "${CURRENT_ENV[@]}" INPUT_DISTRIBUTION="$(test -v "CURRENT_ENV_MAP[JDK_DISTRIBUTION]" && echo "${CURRENT_ENV_MAP[JDK_DISTRIBUTION]}" || echo corretto)" INPUT_JAVA-VERSION="$(test -v "CURRENT_ENV_MAP[CI_JDK_MAJOR_VERSION]" && echo "${CURRENT_ENV_MAP[CI_JDK_MAJOR_VERSION]}" || echo )" INPUT_OVERWRITE-SETTINGS=False INPUT_TOKEN= INPUT_JAVA-PACKAGE=jdk INPUT_CHECK-LATEST=false INPUT_SERVER-ID=github INPUT_SERVER-USERNAME=GITHUB_ACTOR INPUT_SERVER-PASSWORD=GITHUB_TOKEN INPUT_JOB-STATUS="${_GITHUB_JOB_STATUS}" \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=4 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=actions/setup-java GITHUB_ACTIONS=true GITHUB_ACTOR=lhotari GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/pulsar GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=08d89a2ea1a2a566197f5db004881c4e222bb3ac GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Pulsar CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 MAVEN_OPTS='-Xss1500k -Xmx2048m -XX:+UnlockDiagnosticVMOptions -XX:+IgnoreUnrecognizedVMOptions -XX:GCLockerRetryAllocationCount=100 -Daether.connector.http.reuseConnections=false -Daether.connector.requestTimeout=60000 -Dhttp.keepAlive=false -Dmaven.wagon.http.pool=false -Dmaven.wagon.http.retryHandler.class=standard -Dmaven.wagon.http.retryHandler.count=3 -Dmaven.wagon.http.retryHandler.requestSentEnabled=true -Dmaven.wagon.http.serviceUnavailableRetryStrategy.class=standard -Dmaven.wagon.rto=60000' ARTIFACT_RETENTION_DAYS=3 JDK_DISTRIBUTION=corretto GITHUB_ACTION_PATH=/home/github/68311819544/actions/actions-setup-java@v4 JOB_NAME='CI - Integration - Messaging' PULSAR_TEST_IMAGE_NAME=apachepulsar/java-test-image:latest DEVELOCITY_ACCESS_KEY= CI_JDK_MAJOR_VERSION= NETTY_LEAK_DETECTION= NETTY_LEAK_DUMP_DIR=${GITHUB_WORKSPACE}/target/netty-leak-dumps "${CURRENT_ENV[@]}" INPUT_DISTRIBUTION="$(test -v "CURRENT_ENV_MAP[JDK_DISTRIBUTION]" && echo "${CURRENT_ENV_MAP[JDK_DISTRIBUTION]}" || echo corretto)" INPUT_JAVA-VERSION="$(test -v "CURRENT_ENV_MAP[CI_JDK_MAJOR_VERSION]" && echo "${CURRENT_ENV_MAP[CI_JDK_MAJOR_VERSION]}" || echo )" INPUT_OVERWRITE-SETTINGS=False INPUT_TOKEN= INPUT_JAVA-PACKAGE=jdk INPUT_CHECK-LATEST=false INPUT_SERVER-ID=github INPUT_SERVER-USERNAME=GITHUB_ACTOR INPUT_SERVER-PASSWORD=GITHUB_TOKEN INPUT_JOB-STATUS="${_GITHUB_JOB_STATUS}" \
bash -e $ACTIONS_RUNNER_HOOK_STEP_COMPLETED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

fi

update_current_env "$LAST_JOB_NAME"
LAST_JOB_NAME="UNKNOWN"
if [ -f /home/github/workflow/paths.txt ]; then
   while read NEW_PATH 
   do
      PATH="$(eval echo "$NEW_PATH"):$PATH"
   done <<< "$(cat /home/github/workflow/paths.txt)"
else
  echo -n "" > /home/github/workflow/paths.txt
fi

if [ ! -f /home/github/workflow/event.json ]; then
  echo -n "{}" > /home/github/workflow/event.json
fi

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=5 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=apache/pulsar-test-infra GITHUB_ACTIONS=true GITHUB_ACTOR=lhotari GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/pulsar GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=08d89a2ea1a2a566197f5db004881c4e222bb3ac GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Pulsar CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 MAVEN_OPTS='-Xss1500k -Xmx2048m -XX:+UnlockDiagnosticVMOptions -XX:+IgnoreUnrecognizedVMOptions -XX:GCLockerRetryAllocationCount=100 -Daether.connector.http.reuseConnections=false -Daether.connector.requestTimeout=60000 -Dhttp.keepAlive=false -Dmaven.wagon.http.pool=false -Dmaven.wagon.http.retryHandler.class=standard -Dmaven.wagon.http.retryHandler.count=3 -Dmaven.wagon.http.retryHandler.requestSentEnabled=true -Dmaven.wagon.http.serviceUnavailableRetryStrategy.class=standard -Dmaven.wagon.rto=60000' ARTIFACT_RETENTION_DAYS=3 JDK_DISTRIBUTION=corretto GITHUB_ACTION_PATH=/home/github/68311819544/actions/apache-pulsar-test-infra@master/gh-actions-artifact-client/dist JOB_NAME='CI - Integration - Messaging' PULSAR_TEST_IMAGE_NAME=apachepulsar/java-test-image:latest DEVELOCITY_ACCESS_KEY= CI_JDK_MAJOR_VERSION= NETTY_LEAK_DETECTION= NETTY_LEAK_DUMP_DIR=${GITHUB_WORKSPACE}/target/netty-leak-dumps "${CURRENT_ENV[@]}" \
echo $(test "$_GITHUB_JOB_STATUS" = "success" && echo true || echo false))
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=5 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=apache/pulsar-test-infra GITHUB_ACTIONS=true GITHUB_ACTOR=lhotari GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/pulsar GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=08d89a2ea1a2a566197f5db004881c4e222bb3ac GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Pulsar CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 MAVEN_OPTS='-Xss1500k -Xmx2048m -XX:+UnlockDiagnosticVMOptions -XX:+IgnoreUnrecognizedVMOptions -XX:GCLockerRetryAllocationCount=100 -Daether.connector.http.reuseConnections=false -Daether.connector.requestTimeout=60000 -Dhttp.keepAlive=false -Dmaven.wagon.http.pool=false -Dmaven.wagon.http.retryHandler.class=standard -Dmaven.wagon.http.retryHandler.count=3 -Dmaven.wagon.http.retryHandler.requestSentEnabled=true -Dmaven.wagon.http.serviceUnavailableRetryStrategy.class=standard -Dmaven.wagon.rto=60000' ARTIFACT_RETENTION_DAYS=3 JDK_DISTRIBUTION=corretto GITHUB_ACTION_PATH=/home/github/68311819544/actions/apache-pulsar-test-infra@master/gh-actions-artifact-client/dist JOB_NAME='CI - Integration - Messaging' PULSAR_TEST_IMAGE_NAME=apachepulsar/java-test-image:latest DEVELOCITY_ACCESS_KEY= CI_JDK_MAJOR_VERSION= NETTY_LEAK_DETECTION= NETTY_LEAK_DUMP_DIR=${GITHUB_WORKSPACE}/target/netty-leak-dumps "${CURRENT_ENV[@]}" \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run apache/pulsar-test-infra/gh-actions-artifact-client/dist@master
echo "##[endgroup]"
echo node /home/github/68311819544/actions/apache-pulsar-test-infra@master/gh-actions-artifact-client/dist/install.js > /home/github/68311819544/steps/bugswarm_cmd.sh
chmod u+x /home/github/68311819544/steps/bugswarm_cmd.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=5 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=apache/pulsar-test-infra GITHUB_ACTIONS=true GITHUB_ACTOR=lhotari GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/pulsar GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=08d89a2ea1a2a566197f5db004881c4e222bb3ac GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Pulsar CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 MAVEN_OPTS='-Xss1500k -Xmx2048m -XX:+UnlockDiagnosticVMOptions -XX:+IgnoreUnrecognizedVMOptions -XX:GCLockerRetryAllocationCount=100 -Daether.connector.http.reuseConnections=false -Daether.connector.requestTimeout=60000 -Dhttp.keepAlive=false -Dmaven.wagon.http.pool=false -Dmaven.wagon.http.retryHandler.class=standard -Dmaven.wagon.http.retryHandler.count=3 -Dmaven.wagon.http.retryHandler.requestSentEnabled=true -Dmaven.wagon.http.serviceUnavailableRetryStrategy.class=standard -Dmaven.wagon.rto=60000' ARTIFACT_RETENTION_DAYS=3 JDK_DISTRIBUTION=corretto GITHUB_ACTION_PATH=/home/github/68311819544/actions/apache-pulsar-test-infra@master/gh-actions-artifact-client/dist JOB_NAME='CI - Integration - Messaging' PULSAR_TEST_IMAGE_NAME=apachepulsar/java-test-image:latest DEVELOCITY_ACCESS_KEY= CI_JDK_MAJOR_VERSION= NETTY_LEAK_DETECTION= NETTY_LEAK_DUMP_DIR=${GITHUB_WORKSPACE}/target/netty-leak-dumps "${CURRENT_ENV[@]}" \
bash -e /home/github/68311819544/steps/bugswarm_cmd.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=5 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=apache/pulsar-test-infra GITHUB_ACTIONS=true GITHUB_ACTOR=lhotari GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/pulsar GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=08d89a2ea1a2a566197f5db004881c4e222bb3ac GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Pulsar CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 MAVEN_OPTS='-Xss1500k -Xmx2048m -XX:+UnlockDiagnosticVMOptions -XX:+IgnoreUnrecognizedVMOptions -XX:GCLockerRetryAllocationCount=100 -Daether.connector.http.reuseConnections=false -Daether.connector.requestTimeout=60000 -Dhttp.keepAlive=false -Dmaven.wagon.http.pool=false -Dmaven.wagon.http.retryHandler.class=standard -Dmaven.wagon.http.retryHandler.count=3 -Dmaven.wagon.http.retryHandler.requestSentEnabled=true -Dmaven.wagon.http.serviceUnavailableRetryStrategy.class=standard -Dmaven.wagon.rto=60000' ARTIFACT_RETENTION_DAYS=3 JDK_DISTRIBUTION=corretto GITHUB_ACTION_PATH=/home/github/68311819544/actions/apache-pulsar-test-infra@master/gh-actions-artifact-client/dist JOB_NAME='CI - Integration - Messaging' PULSAR_TEST_IMAGE_NAME=apachepulsar/java-test-image:latest DEVELOCITY_ACCESS_KEY= CI_JDK_MAJOR_VERSION= NETTY_LEAK_DETECTION= NETTY_LEAK_DUMP_DIR=${GITHUB_WORKSPACE}/target/netty-leak-dumps "${CURRENT_ENV[@]}" \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=5 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=apache/pulsar-test-infra GITHUB_ACTIONS=true GITHUB_ACTOR=lhotari GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/pulsar GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=08d89a2ea1a2a566197f5db004881c4e222bb3ac GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Pulsar CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 MAVEN_OPTS='-Xss1500k -Xmx2048m -XX:+UnlockDiagnosticVMOptions -XX:+IgnoreUnrecognizedVMOptions -XX:GCLockerRetryAllocationCount=100 -Daether.connector.http.reuseConnections=false -Daether.connector.requestTimeout=60000 -Dhttp.keepAlive=false -Dmaven.wagon.http.pool=false -Dmaven.wagon.http.retryHandler.class=standard -Dmaven.wagon.http.retryHandler.count=3 -Dmaven.wagon.http.retryHandler.requestSentEnabled=true -Dmaven.wagon.http.serviceUnavailableRetryStrategy.class=standard -Dmaven.wagon.rto=60000' ARTIFACT_RETENTION_DAYS=3 JDK_DISTRIBUTION=corretto GITHUB_ACTION_PATH=/home/github/68311819544/actions/apache-pulsar-test-infra@master/gh-actions-artifact-client/dist JOB_NAME='CI - Integration - Messaging' PULSAR_TEST_IMAGE_NAME=apachepulsar/java-test-image:latest DEVELOCITY_ACCESS_KEY= CI_JDK_MAJOR_VERSION= NETTY_LEAK_DETECTION= NETTY_LEAK_DUMP_DIR=${GITHUB_WORKSPACE}/target/netty-leak-dumps "${CURRENT_ENV[@]}" \
bash -e $ACTIONS_RUNNER_HOOK_STEP_COMPLETED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

fi

update_current_env "$LAST_JOB_NAME"
LAST_JOB_NAME="UNKNOWN"
if [ -f /home/github/workflow/paths.txt ]; then
   while read NEW_PATH 
   do
      PATH="$(eval echo "$NEW_PATH"):$PATH"
   done <<< "$(cat /home/github/workflow/paths.txt)"
else
  echo -n "" > /home/github/workflow/paths.txt
fi

if [ ! -f /home/github/workflow/event.json ]; then
  echo -n "{}" > /home/github/workflow/event.json
fi

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=6 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=lhotari GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/pulsar GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=08d89a2ea1a2a566197f5db004881c4e222bb3ac GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Pulsar CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 MAVEN_OPTS='-Xss1500k -Xmx2048m -XX:+UnlockDiagnosticVMOptions -XX:+IgnoreUnrecognizedVMOptions -XX:GCLockerRetryAllocationCount=100 -Daether.connector.http.reuseConnections=false -Daether.connector.requestTimeout=60000 -Dhttp.keepAlive=false -Dmaven.wagon.http.pool=false -Dmaven.wagon.http.retryHandler.class=standard -Dmaven.wagon.http.retryHandler.count=3 -Dmaven.wagon.http.retryHandler.requestSentEnabled=true -Dmaven.wagon.http.serviceUnavailableRetryStrategy.class=standard -Dmaven.wagon.rto=60000' ARTIFACT_RETENTION_DAYS=3 JDK_DISTRIBUTION=corretto JOB_NAME='CI - Integration - Messaging' PULSAR_TEST_IMAGE_NAME=apachepulsar/java-test-image:latest DEVELOCITY_ACCESS_KEY= CI_JDK_MAJOR_VERSION= NETTY_LEAK_DETECTION= NETTY_LEAK_DUMP_DIR=${GITHUB_WORKSPACE}/target/netty-leak-dumps "${CURRENT_ENV[@]}" \
echo $(test "$_GITHUB_JOB_STATUS" = "success" && echo true || echo false))
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=6 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=lhotari GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/pulsar GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=08d89a2ea1a2a566197f5db004881c4e222bb3ac GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Pulsar CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 MAVEN_OPTS='-Xss1500k -Xmx2048m -XX:+UnlockDiagnosticVMOptions -XX:+IgnoreUnrecognizedVMOptions -XX:GCLockerRetryAllocationCount=100 -Daether.connector.http.reuseConnections=false -Daether.connector.requestTimeout=60000 -Dhttp.keepAlive=false -Dmaven.wagon.http.pool=false -Dmaven.wagon.http.retryHandler.class=standard -Dmaven.wagon.http.retryHandler.count=3 -Dmaven.wagon.http.retryHandler.requestSentEnabled=true -Dmaven.wagon.http.serviceUnavailableRetryStrategy.class=standard -Dmaven.wagon.rto=60000' ARTIFACT_RETENTION_DAYS=3 JDK_DISTRIBUTION=corretto JOB_NAME='CI - Integration - Messaging' PULSAR_TEST_IMAGE_NAME=apachepulsar/java-test-image:latest DEVELOCITY_ACCESS_KEY= CI_JDK_MAJOR_VERSION= NETTY_LEAK_DETECTION= NETTY_LEAK_DUMP_DIR=${GITHUB_WORKSPACE}/target/netty-leak-dumps "${CURRENT_ENV[@]}" \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run 'cd $HOME'
echo "##[endgroup]"
echo 'cd $HOME
$GITHUB_WORKSPACE/build/pulsar_ci_tool.sh restore_tar_from_github_actions_artifacts pulsar-maven-repository-binaries
$GITHUB_WORKSPACE/build/pulsar_ci_tool.sh snapshot_pulsar_maven_artifacts
' > /home/github/68311819544/steps/bugswarm_6.sh
chmod u+x /home/github/68311819544/steps/bugswarm_6.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=6 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=lhotari GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/pulsar GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=08d89a2ea1a2a566197f5db004881c4e222bb3ac GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Pulsar CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 MAVEN_OPTS='-Xss1500k -Xmx2048m -XX:+UnlockDiagnosticVMOptions -XX:+IgnoreUnrecognizedVMOptions -XX:GCLockerRetryAllocationCount=100 -Daether.connector.http.reuseConnections=false -Daether.connector.requestTimeout=60000 -Dhttp.keepAlive=false -Dmaven.wagon.http.pool=false -Dmaven.wagon.http.retryHandler.class=standard -Dmaven.wagon.http.retryHandler.count=3 -Dmaven.wagon.http.retryHandler.requestSentEnabled=true -Dmaven.wagon.http.serviceUnavailableRetryStrategy.class=standard -Dmaven.wagon.rto=60000' ARTIFACT_RETENTION_DAYS=3 JDK_DISTRIBUTION=corretto JOB_NAME='CI - Integration - Messaging' PULSAR_TEST_IMAGE_NAME=apachepulsar/java-test-image:latest DEVELOCITY_ACCESS_KEY= CI_JDK_MAJOR_VERSION= NETTY_LEAK_DETECTION= NETTY_LEAK_DUMP_DIR=${GITHUB_WORKSPACE}/target/netty-leak-dumps "${CURRENT_ENV[@]}" \
bash -e /home/github/68311819544/steps/bugswarm_6.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=6 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=lhotari GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/pulsar GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=08d89a2ea1a2a566197f5db004881c4e222bb3ac GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Pulsar CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 MAVEN_OPTS='-Xss1500k -Xmx2048m -XX:+UnlockDiagnosticVMOptions -XX:+IgnoreUnrecognizedVMOptions -XX:GCLockerRetryAllocationCount=100 -Daether.connector.http.reuseConnections=false -Daether.connector.requestTimeout=60000 -Dhttp.keepAlive=false -Dmaven.wagon.http.pool=false -Dmaven.wagon.http.retryHandler.class=standard -Dmaven.wagon.http.retryHandler.count=3 -Dmaven.wagon.http.retryHandler.requestSentEnabled=true -Dmaven.wagon.http.serviceUnavailableRetryStrategy.class=standard -Dmaven.wagon.rto=60000' ARTIFACT_RETENTION_DAYS=3 JDK_DISTRIBUTION=corretto JOB_NAME='CI - Integration - Messaging' PULSAR_TEST_IMAGE_NAME=apachepulsar/java-test-image:latest DEVELOCITY_ACCESS_KEY= CI_JDK_MAJOR_VERSION= NETTY_LEAK_DETECTION= NETTY_LEAK_DUMP_DIR=${GITHUB_WORKSPACE}/target/netty-leak-dumps "${CURRENT_ENV[@]}" \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=6 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=lhotari GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/pulsar GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=08d89a2ea1a2a566197f5db004881c4e222bb3ac GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Pulsar CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 MAVEN_OPTS='-Xss1500k -Xmx2048m -XX:+UnlockDiagnosticVMOptions -XX:+IgnoreUnrecognizedVMOptions -XX:GCLockerRetryAllocationCount=100 -Daether.connector.http.reuseConnections=false -Daether.connector.requestTimeout=60000 -Dhttp.keepAlive=false -Dmaven.wagon.http.pool=false -Dmaven.wagon.http.retryHandler.class=standard -Dmaven.wagon.http.retryHandler.count=3 -Dmaven.wagon.http.retryHandler.requestSentEnabled=true -Dmaven.wagon.http.serviceUnavailableRetryStrategy.class=standard -Dmaven.wagon.rto=60000' ARTIFACT_RETENTION_DAYS=3 JDK_DISTRIBUTION=corretto JOB_NAME='CI - Integration - Messaging' PULSAR_TEST_IMAGE_NAME=apachepulsar/java-test-image:latest DEVELOCITY_ACCESS_KEY= CI_JDK_MAJOR_VERSION= NETTY_LEAK_DETECTION= NETTY_LEAK_DUMP_DIR=${GITHUB_WORKSPACE}/target/netty-leak-dumps "${CURRENT_ENV[@]}" \
bash -e $ACTIONS_RUNNER_HOOK_STEP_COMPLETED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

fi

update_current_env "$LAST_JOB_NAME"
LAST_JOB_NAME="UNKNOWN"
if [ -f /home/github/workflow/paths.txt ]; then
   while read NEW_PATH 
   do
      PATH="$(eval echo "$NEW_PATH"):$PATH"
   done <<< "$(cat /home/github/workflow/paths.txt)"
else
  echo -n "" > /home/github/workflow/paths.txt
fi

if [ ! -f /home/github/workflow/event.json ]; then
  echo -n "{}" > /home/github/workflow/event.json
fi

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=7 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=lhotari GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/pulsar GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=08d89a2ea1a2a566197f5db004881c4e222bb3ac GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Pulsar CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 MAVEN_OPTS='-Xss1500k -Xmx2048m -XX:+UnlockDiagnosticVMOptions -XX:+IgnoreUnrecognizedVMOptions -XX:GCLockerRetryAllocationCount=100 -Daether.connector.http.reuseConnections=false -Daether.connector.requestTimeout=60000 -Dhttp.keepAlive=false -Dmaven.wagon.http.pool=false -Dmaven.wagon.http.retryHandler.class=standard -Dmaven.wagon.http.retryHandler.count=3 -Dmaven.wagon.http.retryHandler.requestSentEnabled=true -Dmaven.wagon.http.serviceUnavailableRetryStrategy.class=standard -Dmaven.wagon.rto=60000' ARTIFACT_RETENTION_DAYS=3 JDK_DISTRIBUTION=corretto JOB_NAME='CI - Integration - Messaging' PULSAR_TEST_IMAGE_NAME=apachepulsar/java-test-image:latest DEVELOCITY_ACCESS_KEY= CI_JDK_MAJOR_VERSION= NETTY_LEAK_DETECTION= NETTY_LEAK_DUMP_DIR=${GITHUB_WORKSPACE}/target/netty-leak-dumps "${CURRENT_ENV[@]}" \
echo $(test "$_GITHUB_JOB_STATUS" = "success" && echo true || echo false))
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=7 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=lhotari GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/pulsar GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=08d89a2ea1a2a566197f5db004881c4e222bb3ac GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Pulsar CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 MAVEN_OPTS='-Xss1500k -Xmx2048m -XX:+UnlockDiagnosticVMOptions -XX:+IgnoreUnrecognizedVMOptions -XX:GCLockerRetryAllocationCount=100 -Daether.connector.http.reuseConnections=false -Daether.connector.requestTimeout=60000 -Dhttp.keepAlive=false -Dmaven.wagon.http.pool=false -Dmaven.wagon.http.retryHandler.class=standard -Dmaven.wagon.http.retryHandler.count=3 -Dmaven.wagon.http.retryHandler.requestSentEnabled=true -Dmaven.wagon.http.serviceUnavailableRetryStrategy.class=standard -Dmaven.wagon.rto=60000' ARTIFACT_RETENTION_DAYS=3 JDK_DISTRIBUTION=corretto JOB_NAME='CI - Integration - Messaging' PULSAR_TEST_IMAGE_NAME=apachepulsar/java-test-image:latest DEVELOCITY_ACCESS_KEY= CI_JDK_MAJOR_VERSION= NETTY_LEAK_DETECTION= NETTY_LEAK_DUMP_DIR=${GITHUB_WORKSPACE}/target/netty-leak-dumps "${CURRENT_ENV[@]}" \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run '$GITHUB_WORKSPACE/build/pulsar_ci_tool.sh docker_load_image_from_github_actions_artifacts pulsar-java-test-image'
echo "##[endgroup]"
echo '$GITHUB_WORKSPACE/build/pulsar_ci_tool.sh docker_load_image_from_github_actions_artifacts pulsar-java-test-image
' > /home/github/68311819544/steps/bugswarm_7.sh
chmod u+x /home/github/68311819544/steps/bugswarm_7.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=7 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=lhotari GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/pulsar GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=08d89a2ea1a2a566197f5db004881c4e222bb3ac GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Pulsar CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 MAVEN_OPTS='-Xss1500k -Xmx2048m -XX:+UnlockDiagnosticVMOptions -XX:+IgnoreUnrecognizedVMOptions -XX:GCLockerRetryAllocationCount=100 -Daether.connector.http.reuseConnections=false -Daether.connector.requestTimeout=60000 -Dhttp.keepAlive=false -Dmaven.wagon.http.pool=false -Dmaven.wagon.http.retryHandler.class=standard -Dmaven.wagon.http.retryHandler.count=3 -Dmaven.wagon.http.retryHandler.requestSentEnabled=true -Dmaven.wagon.http.serviceUnavailableRetryStrategy.class=standard -Dmaven.wagon.rto=60000' ARTIFACT_RETENTION_DAYS=3 JDK_DISTRIBUTION=corretto JOB_NAME='CI - Integration - Messaging' PULSAR_TEST_IMAGE_NAME=apachepulsar/java-test-image:latest DEVELOCITY_ACCESS_KEY= CI_JDK_MAJOR_VERSION= NETTY_LEAK_DETECTION= NETTY_LEAK_DUMP_DIR=${GITHUB_WORKSPACE}/target/netty-leak-dumps "${CURRENT_ENV[@]}" \
bash -e /home/github/68311819544/steps/bugswarm_7.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=7 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=lhotari GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/pulsar GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=08d89a2ea1a2a566197f5db004881c4e222bb3ac GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Pulsar CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 MAVEN_OPTS='-Xss1500k -Xmx2048m -XX:+UnlockDiagnosticVMOptions -XX:+IgnoreUnrecognizedVMOptions -XX:GCLockerRetryAllocationCount=100 -Daether.connector.http.reuseConnections=false -Daether.connector.requestTimeout=60000 -Dhttp.keepAlive=false -Dmaven.wagon.http.pool=false -Dmaven.wagon.http.retryHandler.class=standard -Dmaven.wagon.http.retryHandler.count=3 -Dmaven.wagon.http.retryHandler.requestSentEnabled=true -Dmaven.wagon.http.serviceUnavailableRetryStrategy.class=standard -Dmaven.wagon.rto=60000' ARTIFACT_RETENTION_DAYS=3 JDK_DISTRIBUTION=corretto JOB_NAME='CI - Integration - Messaging' PULSAR_TEST_IMAGE_NAME=apachepulsar/java-test-image:latest DEVELOCITY_ACCESS_KEY= CI_JDK_MAJOR_VERSION= NETTY_LEAK_DETECTION= NETTY_LEAK_DUMP_DIR=${GITHUB_WORKSPACE}/target/netty-leak-dumps "${CURRENT_ENV[@]}" \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=7 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=lhotari GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/pulsar GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=08d89a2ea1a2a566197f5db004881c4e222bb3ac GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Pulsar CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 MAVEN_OPTS='-Xss1500k -Xmx2048m -XX:+UnlockDiagnosticVMOptions -XX:+IgnoreUnrecognizedVMOptions -XX:GCLockerRetryAllocationCount=100 -Daether.connector.http.reuseConnections=false -Daether.connector.requestTimeout=60000 -Dhttp.keepAlive=false -Dmaven.wagon.http.pool=false -Dmaven.wagon.http.retryHandler.class=standard -Dmaven.wagon.http.retryHandler.count=3 -Dmaven.wagon.http.retryHandler.requestSentEnabled=true -Dmaven.wagon.http.serviceUnavailableRetryStrategy.class=standard -Dmaven.wagon.rto=60000' ARTIFACT_RETENTION_DAYS=3 JDK_DISTRIBUTION=corretto JOB_NAME='CI - Integration - Messaging' PULSAR_TEST_IMAGE_NAME=apachepulsar/java-test-image:latest DEVELOCITY_ACCESS_KEY= CI_JDK_MAJOR_VERSION= NETTY_LEAK_DETECTION= NETTY_LEAK_DUMP_DIR=${GITHUB_WORKSPACE}/target/netty-leak-dumps "${CURRENT_ENV[@]}" \
bash -e $ACTIONS_RUNNER_HOOK_STEP_COMPLETED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

fi

update_current_env "$LAST_JOB_NAME"
LAST_JOB_NAME="UNKNOWN"
if [ -f /home/github/workflow/paths.txt ]; then
   while read NEW_PATH 
   do
      PATH="$(eval echo "$NEW_PATH"):$PATH"
   done <<< "$(cat /home/github/workflow/paths.txt)"
else
  echo -n "" > /home/github/workflow/paths.txt
fi

if [ ! -f /home/github/workflow/event.json ]; then
  echo -n "{}" > /home/github/workflow/event.json
fi

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=8 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=lhotari GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/pulsar GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=08d89a2ea1a2a566197f5db004881c4e222bb3ac GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Pulsar CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 MAVEN_OPTS='-Xss1500k -Xmx2048m -XX:+UnlockDiagnosticVMOptions -XX:+IgnoreUnrecognizedVMOptions -XX:GCLockerRetryAllocationCount=100 -Daether.connector.http.reuseConnections=false -Daether.connector.requestTimeout=60000 -Dhttp.keepAlive=false -Dmaven.wagon.http.pool=false -Dmaven.wagon.http.retryHandler.class=standard -Dmaven.wagon.http.retryHandler.count=3 -Dmaven.wagon.http.retryHandler.requestSentEnabled=true -Dmaven.wagon.http.serviceUnavailableRetryStrategy.class=standard -Dmaven.wagon.rto=60000' ARTIFACT_RETENTION_DAYS=3 JDK_DISTRIBUTION=corretto JOB_NAME='CI - Integration - Messaging' PULSAR_TEST_IMAGE_NAME=apachepulsar/java-test-image:latest DEVELOCITY_ACCESS_KEY= CI_JDK_MAJOR_VERSION= NETTY_LEAK_DETECTION= NETTY_LEAK_DUMP_DIR=${GITHUB_WORKSPACE}/target/netty-leak-dumps "${CURRENT_ENV[@]}" \
echo "$(/home/github/68311819544/helpers/eval_expression p:'(' f:success p:'(' p:')' p:')' o:'&&' s:'')")
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=8 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=lhotari GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/pulsar GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=08d89a2ea1a2a566197f5db004881c4e222bb3ac GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Pulsar CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 MAVEN_OPTS='-Xss1500k -Xmx2048m -XX:+UnlockDiagnosticVMOptions -XX:+IgnoreUnrecognizedVMOptions -XX:GCLockerRetryAllocationCount=100 -Daether.connector.http.reuseConnections=false -Daether.connector.requestTimeout=60000 -Dhttp.keepAlive=false -Dmaven.wagon.http.pool=false -Dmaven.wagon.http.retryHandler.class=standard -Dmaven.wagon.http.retryHandler.count=3 -Dmaven.wagon.http.retryHandler.requestSentEnabled=true -Dmaven.wagon.http.serviceUnavailableRetryStrategy.class=standard -Dmaven.wagon.rto=60000' ARTIFACT_RETENTION_DAYS=3 JDK_DISTRIBUTION=corretto JOB_NAME='CI - Integration - Messaging' PULSAR_TEST_IMAGE_NAME=apachepulsar/java-test-image:latest DEVELOCITY_ACCESS_KEY= CI_JDK_MAJOR_VERSION= NETTY_LEAK_DETECTION= NETTY_LEAK_DUMP_DIR=${GITHUB_WORKSPACE}/target/netty-leak-dumps "${CURRENT_ENV[@]}" \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run 
echo "##[endgroup]"
echo '
' > /home/github/68311819544/steps/bugswarm_8.sh
chmod u+x /home/github/68311819544/steps/bugswarm_8.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=8 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=lhotari GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/pulsar GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=08d89a2ea1a2a566197f5db004881c4e222bb3ac GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Pulsar CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 MAVEN_OPTS='-Xss1500k -Xmx2048m -XX:+UnlockDiagnosticVMOptions -XX:+IgnoreUnrecognizedVMOptions -XX:GCLockerRetryAllocationCount=100 -Daether.connector.http.reuseConnections=false -Daether.connector.requestTimeout=60000 -Dhttp.keepAlive=false -Dmaven.wagon.http.pool=false -Dmaven.wagon.http.retryHandler.class=standard -Dmaven.wagon.http.retryHandler.count=3 -Dmaven.wagon.http.retryHandler.requestSentEnabled=true -Dmaven.wagon.http.serviceUnavailableRetryStrategy.class=standard -Dmaven.wagon.rto=60000' ARTIFACT_RETENTION_DAYS=3 JDK_DISTRIBUTION=corretto JOB_NAME='CI - Integration - Messaging' PULSAR_TEST_IMAGE_NAME=apachepulsar/java-test-image:latest DEVELOCITY_ACCESS_KEY= CI_JDK_MAJOR_VERSION= NETTY_LEAK_DETECTION= NETTY_LEAK_DUMP_DIR=${GITHUB_WORKSPACE}/target/netty-leak-dumps "${CURRENT_ENV[@]}" \
bash -e /home/github/68311819544/steps/bugswarm_8.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=8 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=lhotari GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/pulsar GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=08d89a2ea1a2a566197f5db004881c4e222bb3ac GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Pulsar CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 MAVEN_OPTS='-Xss1500k -Xmx2048m -XX:+UnlockDiagnosticVMOptions -XX:+IgnoreUnrecognizedVMOptions -XX:GCLockerRetryAllocationCount=100 -Daether.connector.http.reuseConnections=false -Daether.connector.requestTimeout=60000 -Dhttp.keepAlive=false -Dmaven.wagon.http.pool=false -Dmaven.wagon.http.retryHandler.class=standard -Dmaven.wagon.http.retryHandler.count=3 -Dmaven.wagon.http.retryHandler.requestSentEnabled=true -Dmaven.wagon.http.serviceUnavailableRetryStrategy.class=standard -Dmaven.wagon.rto=60000' ARTIFACT_RETENTION_DAYS=3 JDK_DISTRIBUTION=corretto JOB_NAME='CI - Integration - Messaging' PULSAR_TEST_IMAGE_NAME=apachepulsar/java-test-image:latest DEVELOCITY_ACCESS_KEY= CI_JDK_MAJOR_VERSION= NETTY_LEAK_DETECTION= NETTY_LEAK_DUMP_DIR=${GITHUB_WORKSPACE}/target/netty-leak-dumps "${CURRENT_ENV[@]}" \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=8 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=lhotari GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/pulsar GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=08d89a2ea1a2a566197f5db004881c4e222bb3ac GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Pulsar CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 MAVEN_OPTS='-Xss1500k -Xmx2048m -XX:+UnlockDiagnosticVMOptions -XX:+IgnoreUnrecognizedVMOptions -XX:GCLockerRetryAllocationCount=100 -Daether.connector.http.reuseConnections=false -Daether.connector.requestTimeout=60000 -Dhttp.keepAlive=false -Dmaven.wagon.http.pool=false -Dmaven.wagon.http.retryHandler.class=standard -Dmaven.wagon.http.retryHandler.count=3 -Dmaven.wagon.http.retryHandler.requestSentEnabled=true -Dmaven.wagon.http.serviceUnavailableRetryStrategy.class=standard -Dmaven.wagon.rto=60000' ARTIFACT_RETENTION_DAYS=3 JDK_DISTRIBUTION=corretto JOB_NAME='CI - Integration - Messaging' PULSAR_TEST_IMAGE_NAME=apachepulsar/java-test-image:latest DEVELOCITY_ACCESS_KEY= CI_JDK_MAJOR_VERSION= NETTY_LEAK_DETECTION= NETTY_LEAK_DUMP_DIR=${GITHUB_WORKSPACE}/target/netty-leak-dumps "${CURRENT_ENV[@]}" \
bash -e $ACTIONS_RUNNER_HOOK_STEP_COMPLETED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

fi

update_current_env "$LAST_JOB_NAME"
LAST_JOB_NAME="UNKNOWN"
if [ -f /home/github/workflow/paths.txt ]; then
   while read NEW_PATH 
   do
      PATH="$(eval echo "$NEW_PATH"):$PATH"
   done <<< "$(cat /home/github/workflow/paths.txt)"
else
  echo -n "" > /home/github/workflow/paths.txt
fi

if [ ! -f /home/github/workflow/event.json ]; then
  echo -n "{}" > /home/github/workflow/event.json
fi

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=9 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=actions/setup-java GITHUB_ACTIONS=true GITHUB_ACTOR=lhotari GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/pulsar GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=08d89a2ea1a2a566197f5db004881c4e222bb3ac GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Pulsar CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 MAVEN_OPTS='-Xss1500k -Xmx2048m -XX:+UnlockDiagnosticVMOptions -XX:+IgnoreUnrecognizedVMOptions -XX:GCLockerRetryAllocationCount=100 -Daether.connector.http.reuseConnections=false -Daether.connector.requestTimeout=60000 -Dhttp.keepAlive=false -Dmaven.wagon.http.pool=false -Dmaven.wagon.http.retryHandler.class=standard -Dmaven.wagon.http.retryHandler.count=3 -Dmaven.wagon.http.retryHandler.requestSentEnabled=true -Dmaven.wagon.http.serviceUnavailableRetryStrategy.class=standard -Dmaven.wagon.rto=60000' ARTIFACT_RETENTION_DAYS=3 JDK_DISTRIBUTION=corretto GITHUB_ACTION_PATH=/home/github/68311819544/actions/actions-setup-java@v4 JOB_NAME='CI - Integration - Messaging' PULSAR_TEST_IMAGE_NAME=apachepulsar/java-test-image:latest DEVELOCITY_ACCESS_KEY= CI_JDK_MAJOR_VERSION= NETTY_LEAK_DETECTION= NETTY_LEAK_DUMP_DIR=${GITHUB_WORKSPACE}/target/netty-leak-dumps "${CURRENT_ENV[@]}" INPUT_DISTRIBUTION="$(test -v "CURRENT_ENV_MAP[JDK_DISTRIBUTION]" && echo "${CURRENT_ENV_MAP[JDK_DISTRIBUTION]}" || echo corretto)" INPUT_JAVA-VERSION= INPUT_OVERWRITE-SETTINGS=False INPUT_TOKEN= INPUT_JAVA-PACKAGE=jdk INPUT_CHECK-LATEST=false INPUT_SERVER-ID=github INPUT_SERVER-USERNAME=GITHUB_ACTOR INPUT_SERVER-PASSWORD=GITHUB_TOKEN INPUT_JOB-STATUS="${_GITHUB_JOB_STATUS}" \
echo "$(/home/github/68311819544/helpers/eval_expression p:'(' f:success p:'(' p:')' p:')' o:'&&' s:'')")
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=9 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=actions/setup-java GITHUB_ACTIONS=true GITHUB_ACTOR=lhotari GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/pulsar GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=08d89a2ea1a2a566197f5db004881c4e222bb3ac GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Pulsar CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 MAVEN_OPTS='-Xss1500k -Xmx2048m -XX:+UnlockDiagnosticVMOptions -XX:+IgnoreUnrecognizedVMOptions -XX:GCLockerRetryAllocationCount=100 -Daether.connector.http.reuseConnections=false -Daether.connector.requestTimeout=60000 -Dhttp.keepAlive=false -Dmaven.wagon.http.pool=false -Dmaven.wagon.http.retryHandler.class=standard -Dmaven.wagon.http.retryHandler.count=3 -Dmaven.wagon.http.retryHandler.requestSentEnabled=true -Dmaven.wagon.http.serviceUnavailableRetryStrategy.class=standard -Dmaven.wagon.rto=60000' ARTIFACT_RETENTION_DAYS=3 JDK_DISTRIBUTION=corretto GITHUB_ACTION_PATH=/home/github/68311819544/actions/actions-setup-java@v4 JOB_NAME='CI - Integration - Messaging' PULSAR_TEST_IMAGE_NAME=apachepulsar/java-test-image:latest DEVELOCITY_ACCESS_KEY= CI_JDK_MAJOR_VERSION= NETTY_LEAK_DETECTION= NETTY_LEAK_DUMP_DIR=${GITHUB_WORKSPACE}/target/netty-leak-dumps "${CURRENT_ENV[@]}" INPUT_DISTRIBUTION="$(test -v "CURRENT_ENV_MAP[JDK_DISTRIBUTION]" && echo "${CURRENT_ENV_MAP[JDK_DISTRIBUTION]}" || echo corretto)" INPUT_JAVA-VERSION= INPUT_OVERWRITE-SETTINGS=False INPUT_TOKEN= INPUT_JAVA-PACKAGE=jdk INPUT_CHECK-LATEST=false INPUT_SERVER-ID=github INPUT_SERVER-USERNAME=GITHUB_ACTOR INPUT_SERVER-PASSWORD=GITHUB_TOKEN INPUT_JOB-STATUS="${_GITHUB_JOB_STATUS}" \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run actions/setup-java@v4
echo "##[endgroup]"
echo node /home/github/68311819544/actions/actions-setup-java@v4/dist/setup/index.js > /home/github/68311819544/steps/bugswarm_cmd.sh
chmod u+x /home/github/68311819544/steps/bugswarm_cmd.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=9 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=actions/setup-java GITHUB_ACTIONS=true GITHUB_ACTOR=lhotari GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/pulsar GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=08d89a2ea1a2a566197f5db004881c4e222bb3ac GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Pulsar CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 MAVEN_OPTS='-Xss1500k -Xmx2048m -XX:+UnlockDiagnosticVMOptions -XX:+IgnoreUnrecognizedVMOptions -XX:GCLockerRetryAllocationCount=100 -Daether.connector.http.reuseConnections=false -Daether.connector.requestTimeout=60000 -Dhttp.keepAlive=false -Dmaven.wagon.http.pool=false -Dmaven.wagon.http.retryHandler.class=standard -Dmaven.wagon.http.retryHandler.count=3 -Dmaven.wagon.http.retryHandler.requestSentEnabled=true -Dmaven.wagon.http.serviceUnavailableRetryStrategy.class=standard -Dmaven.wagon.rto=60000' ARTIFACT_RETENTION_DAYS=3 JDK_DISTRIBUTION=corretto GITHUB_ACTION_PATH=/home/github/68311819544/actions/actions-setup-java@v4 JOB_NAME='CI - Integration - Messaging' PULSAR_TEST_IMAGE_NAME=apachepulsar/java-test-image:latest DEVELOCITY_ACCESS_KEY= CI_JDK_MAJOR_VERSION= NETTY_LEAK_DETECTION= NETTY_LEAK_DUMP_DIR=${GITHUB_WORKSPACE}/target/netty-leak-dumps "${CURRENT_ENV[@]}" INPUT_DISTRIBUTION="$(test -v "CURRENT_ENV_MAP[JDK_DISTRIBUTION]" && echo "${CURRENT_ENV_MAP[JDK_DISTRIBUTION]}" || echo corretto)" INPUT_JAVA-VERSION= INPUT_OVERWRITE-SETTINGS=False INPUT_TOKEN= INPUT_JAVA-PACKAGE=jdk INPUT_CHECK-LATEST=false INPUT_SERVER-ID=github INPUT_SERVER-USERNAME=GITHUB_ACTOR INPUT_SERVER-PASSWORD=GITHUB_TOKEN INPUT_JOB-STATUS="${_GITHUB_JOB_STATUS}" \
bash -e /home/github/68311819544/steps/bugswarm_cmd.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=9 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=actions/setup-java GITHUB_ACTIONS=true GITHUB_ACTOR=lhotari GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/pulsar GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=08d89a2ea1a2a566197f5db004881c4e222bb3ac GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Pulsar CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 MAVEN_OPTS='-Xss1500k -Xmx2048m -XX:+UnlockDiagnosticVMOptions -XX:+IgnoreUnrecognizedVMOptions -XX:GCLockerRetryAllocationCount=100 -Daether.connector.http.reuseConnections=false -Daether.connector.requestTimeout=60000 -Dhttp.keepAlive=false -Dmaven.wagon.http.pool=false -Dmaven.wagon.http.retryHandler.class=standard -Dmaven.wagon.http.retryHandler.count=3 -Dmaven.wagon.http.retryHandler.requestSentEnabled=true -Dmaven.wagon.http.serviceUnavailableRetryStrategy.class=standard -Dmaven.wagon.rto=60000' ARTIFACT_RETENTION_DAYS=3 JDK_DISTRIBUTION=corretto GITHUB_ACTION_PATH=/home/github/68311819544/actions/actions-setup-java@v4 JOB_NAME='CI - Integration - Messaging' PULSAR_TEST_IMAGE_NAME=apachepulsar/java-test-image:latest DEVELOCITY_ACCESS_KEY= CI_JDK_MAJOR_VERSION= NETTY_LEAK_DETECTION= NETTY_LEAK_DUMP_DIR=${GITHUB_WORKSPACE}/target/netty-leak-dumps "${CURRENT_ENV[@]}" INPUT_DISTRIBUTION="$(test -v "CURRENT_ENV_MAP[JDK_DISTRIBUTION]" && echo "${CURRENT_ENV_MAP[JDK_DISTRIBUTION]}" || echo corretto)" INPUT_JAVA-VERSION= INPUT_OVERWRITE-SETTINGS=False INPUT_TOKEN= INPUT_JAVA-PACKAGE=jdk INPUT_CHECK-LATEST=false INPUT_SERVER-ID=github INPUT_SERVER-USERNAME=GITHUB_ACTOR INPUT_SERVER-PASSWORD=GITHUB_TOKEN INPUT_JOB-STATUS="${_GITHUB_JOB_STATUS}" \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=9 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=actions/setup-java GITHUB_ACTIONS=true GITHUB_ACTOR=lhotari GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/pulsar GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=08d89a2ea1a2a566197f5db004881c4e222bb3ac GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Pulsar CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 MAVEN_OPTS='-Xss1500k -Xmx2048m -XX:+UnlockDiagnosticVMOptions -XX:+IgnoreUnrecognizedVMOptions -XX:GCLockerRetryAllocationCount=100 -Daether.connector.http.reuseConnections=false -Daether.connector.requestTimeout=60000 -Dhttp.keepAlive=false -Dmaven.wagon.http.pool=false -Dmaven.wagon.http.retryHandler.class=standard -Dmaven.wagon.http.retryHandler.count=3 -Dmaven.wagon.http.retryHandler.requestSentEnabled=true -Dmaven.wagon.http.serviceUnavailableRetryStrategy.class=standard -Dmaven.wagon.rto=60000' ARTIFACT_RETENTION_DAYS=3 JDK_DISTRIBUTION=corretto GITHUB_ACTION_PATH=/home/github/68311819544/actions/actions-setup-java@v4 JOB_NAME='CI - Integration - Messaging' PULSAR_TEST_IMAGE_NAME=apachepulsar/java-test-image:latest DEVELOCITY_ACCESS_KEY= CI_JDK_MAJOR_VERSION= NETTY_LEAK_DETECTION= NETTY_LEAK_DUMP_DIR=${GITHUB_WORKSPACE}/target/netty-leak-dumps "${CURRENT_ENV[@]}" INPUT_DISTRIBUTION="$(test -v "CURRENT_ENV_MAP[JDK_DISTRIBUTION]" && echo "${CURRENT_ENV_MAP[JDK_DISTRIBUTION]}" || echo corretto)" INPUT_JAVA-VERSION= INPUT_OVERWRITE-SETTINGS=False INPUT_TOKEN= INPUT_JAVA-PACKAGE=jdk INPUT_CHECK-LATEST=false INPUT_SERVER-ID=github INPUT_SERVER-USERNAME=GITHUB_ACTOR INPUT_SERVER-PASSWORD=GITHUB_TOKEN INPUT_JOB-STATUS="${_GITHUB_JOB_STATUS}" \
bash -e $ACTIONS_RUNNER_HOOK_STEP_COMPLETED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

fi

update_current_env "$LAST_JOB_NAME"
LAST_JOB_NAME="UNKNOWN"
if [ -f /home/github/workflow/paths.txt ]; then
   while read NEW_PATH 
   do
      PATH="$(eval echo "$NEW_PATH"):$PATH"
   done <<< "$(cat /home/github/workflow/paths.txt)"
else
  echo -n "" > /home/github/workflow/paths.txt
fi

if [ ! -f /home/github/workflow/event.json ]; then
  echo -n "{}" > /home/github/workflow/event.json
fi

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=10 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=lhotari GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/pulsar GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=08d89a2ea1a2a566197f5db004881c4e222bb3ac GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Pulsar CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 MAVEN_OPTS='-Xss1500k -Xmx2048m -XX:+UnlockDiagnosticVMOptions -XX:+IgnoreUnrecognizedVMOptions -XX:GCLockerRetryAllocationCount=100 -Daether.connector.http.reuseConnections=false -Daether.connector.requestTimeout=60000 -Dhttp.keepAlive=false -Dmaven.wagon.http.pool=false -Dmaven.wagon.http.retryHandler.class=standard -Dmaven.wagon.http.retryHandler.count=3 -Dmaven.wagon.http.retryHandler.requestSentEnabled=true -Dmaven.wagon.http.serviceUnavailableRetryStrategy.class=standard -Dmaven.wagon.rto=60000' ARTIFACT_RETENTION_DAYS=3 JDK_DISTRIBUTION=corretto JOB_NAME='CI - Integration - Messaging' PULSAR_TEST_IMAGE_NAME=apachepulsar/java-test-image:latest DEVELOCITY_ACCESS_KEY= CI_JDK_MAJOR_VERSION= NETTY_LEAK_DETECTION= NETTY_LEAK_DUMP_DIR=${GITHUB_WORKSPACE}/target/netty-leak-dumps "${CURRENT_ENV[@]}" \
echo $(test "$_GITHUB_JOB_STATUS" = "success" && echo true || echo false))
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=10 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=lhotari GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/pulsar GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=08d89a2ea1a2a566197f5db004881c4e222bb3ac GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Pulsar CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 MAVEN_OPTS='-Xss1500k -Xmx2048m -XX:+UnlockDiagnosticVMOptions -XX:+IgnoreUnrecognizedVMOptions -XX:GCLockerRetryAllocationCount=100 -Daether.connector.http.reuseConnections=false -Daether.connector.requestTimeout=60000 -Dhttp.keepAlive=false -Dmaven.wagon.http.pool=false -Dmaven.wagon.http.retryHandler.class=standard -Dmaven.wagon.http.retryHandler.count=3 -Dmaven.wagon.http.retryHandler.requestSentEnabled=true -Dmaven.wagon.http.serviceUnavailableRetryStrategy.class=standard -Dmaven.wagon.rto=60000' ARTIFACT_RETENTION_DAYS=3 JDK_DISTRIBUTION=corretto JOB_NAME='CI - Integration - Messaging' PULSAR_TEST_IMAGE_NAME=apachepulsar/java-test-image:latest DEVELOCITY_ACCESS_KEY= CI_JDK_MAJOR_VERSION= NETTY_LEAK_DETECTION= NETTY_LEAK_DUMP_DIR=${GITHUB_WORKSPACE}/target/netty-leak-dumps "${CURRENT_ENV[@]}" \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run 'if [[ "" != "true" && "" == "true" ]]; then'
echo "##[endgroup]"
echo 'if [[ "" != "true" && "" == "true" ]]; then
  coverage_args="--coverage"
fi
./build/run_integration_group.sh MESSAGING $coverage_args
' > /home/github/68311819544/steps/bugswarm_10.sh
chmod u+x /home/github/68311819544/steps/bugswarm_10.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=10 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=lhotari GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/pulsar GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=08d89a2ea1a2a566197f5db004881c4e222bb3ac GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Pulsar CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 MAVEN_OPTS='-Xss1500k -Xmx2048m -XX:+UnlockDiagnosticVMOptions -XX:+IgnoreUnrecognizedVMOptions -XX:GCLockerRetryAllocationCount=100 -Daether.connector.http.reuseConnections=false -Daether.connector.requestTimeout=60000 -Dhttp.keepAlive=false -Dmaven.wagon.http.pool=false -Dmaven.wagon.http.retryHandler.class=standard -Dmaven.wagon.http.retryHandler.count=3 -Dmaven.wagon.http.retryHandler.requestSentEnabled=true -Dmaven.wagon.http.serviceUnavailableRetryStrategy.class=standard -Dmaven.wagon.rto=60000' ARTIFACT_RETENTION_DAYS=3 JDK_DISTRIBUTION=corretto JOB_NAME='CI - Integration - Messaging' PULSAR_TEST_IMAGE_NAME=apachepulsar/java-test-image:latest DEVELOCITY_ACCESS_KEY= CI_JDK_MAJOR_VERSION= NETTY_LEAK_DETECTION= NETTY_LEAK_DUMP_DIR=${GITHUB_WORKSPACE}/target/netty-leak-dumps "${CURRENT_ENV[@]}" \
bash -e /home/github/68311819544/steps/bugswarm_10.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=10 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=lhotari GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/pulsar GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=08d89a2ea1a2a566197f5db004881c4e222bb3ac GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Pulsar CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 MAVEN_OPTS='-Xss1500k -Xmx2048m -XX:+UnlockDiagnosticVMOptions -XX:+IgnoreUnrecognizedVMOptions -XX:GCLockerRetryAllocationCount=100 -Daether.connector.http.reuseConnections=false -Daether.connector.requestTimeout=60000 -Dhttp.keepAlive=false -Dmaven.wagon.http.pool=false -Dmaven.wagon.http.retryHandler.class=standard -Dmaven.wagon.http.retryHandler.count=3 -Dmaven.wagon.http.retryHandler.requestSentEnabled=true -Dmaven.wagon.http.serviceUnavailableRetryStrategy.class=standard -Dmaven.wagon.rto=60000' ARTIFACT_RETENTION_DAYS=3 JDK_DISTRIBUTION=corretto JOB_NAME='CI - Integration - Messaging' PULSAR_TEST_IMAGE_NAME=apachepulsar/java-test-image:latest DEVELOCITY_ACCESS_KEY= CI_JDK_MAJOR_VERSION= NETTY_LEAK_DETECTION= NETTY_LEAK_DUMP_DIR=${GITHUB_WORKSPACE}/target/netty-leak-dumps "${CURRENT_ENV[@]}" \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=10 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=lhotari GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/pulsar GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=08d89a2ea1a2a566197f5db004881c4e222bb3ac GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Pulsar CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 MAVEN_OPTS='-Xss1500k -Xmx2048m -XX:+UnlockDiagnosticVMOptions -XX:+IgnoreUnrecognizedVMOptions -XX:GCLockerRetryAllocationCount=100 -Daether.connector.http.reuseConnections=false -Daether.connector.requestTimeout=60000 -Dhttp.keepAlive=false -Dmaven.wagon.http.pool=false -Dmaven.wagon.http.retryHandler.class=standard -Dmaven.wagon.http.retryHandler.count=3 -Dmaven.wagon.http.retryHandler.requestSentEnabled=true -Dmaven.wagon.http.serviceUnavailableRetryStrategy.class=standard -Dmaven.wagon.rto=60000' ARTIFACT_RETENTION_DAYS=3 JDK_DISTRIBUTION=corretto JOB_NAME='CI - Integration - Messaging' PULSAR_TEST_IMAGE_NAME=apachepulsar/java-test-image:latest DEVELOCITY_ACCESS_KEY= CI_JDK_MAJOR_VERSION= NETTY_LEAK_DETECTION= NETTY_LEAK_DUMP_DIR=${GITHUB_WORKSPACE}/target/netty-leak-dumps "${CURRENT_ENV[@]}" \
bash -e $ACTIONS_RUNNER_HOOK_STEP_COMPLETED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

fi

update_current_env "$LAST_JOB_NAME"
LAST_JOB_NAME="UNKNOWN"
if [ -f /home/github/workflow/paths.txt ]; then
   while read NEW_PATH 
   do
      PATH="$(eval echo "$NEW_PATH"):$PATH"
   done <<< "$(cat /home/github/workflow/paths.txt)"
else
  echo -n "" > /home/github/workflow/paths.txt
fi

if [ ! -f /home/github/workflow/event.json ]; then
  echo -n "{}" > /home/github/workflow/event.json
fi

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=11 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=lhotari GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/pulsar GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=08d89a2ea1a2a566197f5db004881c4e222bb3ac GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Pulsar CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 MAVEN_OPTS='-Xss1500k -Xmx2048m -XX:+UnlockDiagnosticVMOptions -XX:+IgnoreUnrecognizedVMOptions -XX:GCLockerRetryAllocationCount=100 -Daether.connector.http.reuseConnections=false -Daether.connector.requestTimeout=60000 -Dhttp.keepAlive=false -Dmaven.wagon.http.pool=false -Dmaven.wagon.http.retryHandler.class=standard -Dmaven.wagon.http.retryHandler.count=3 -Dmaven.wagon.http.retryHandler.requestSentEnabled=true -Dmaven.wagon.http.serviceUnavailableRetryStrategy.class=standard -Dmaven.wagon.rto=60000' ARTIFACT_RETENTION_DAYS=3 JDK_DISTRIBUTION=corretto JOB_NAME='CI - Integration - Messaging' PULSAR_TEST_IMAGE_NAME=apachepulsar/java-test-image:latest DEVELOCITY_ACCESS_KEY= CI_JDK_MAJOR_VERSION= NETTY_LEAK_DETECTION= NETTY_LEAK_DUMP_DIR=${GITHUB_WORKSPACE}/target/netty-leak-dumps "${CURRENT_ENV[@]}" \
echo "$(/home/github/68311819544/helpers/eval_expression p:'(' f:success p:'(' p:')' p:')' o:'&&' p:'(' p:'(' o:'!' s:'' p:')' o:'&&' p:'(' s:'' o:== s:true p:')' p:')')")
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=11 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=lhotari GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/pulsar GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=08d89a2ea1a2a566197f5db004881c4e222bb3ac GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Pulsar CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 MAVEN_OPTS='-Xss1500k -Xmx2048m -XX:+UnlockDiagnosticVMOptions -XX:+IgnoreUnrecognizedVMOptions -XX:GCLockerRetryAllocationCount=100 -Daether.connector.http.reuseConnections=false -Daether.connector.requestTimeout=60000 -Dhttp.keepAlive=false -Dmaven.wagon.http.pool=false -Dmaven.wagon.http.retryHandler.class=standard -Dmaven.wagon.http.retryHandler.count=3 -Dmaven.wagon.http.retryHandler.requestSentEnabled=true -Dmaven.wagon.http.serviceUnavailableRetryStrategy.class=standard -Dmaven.wagon.rto=60000' ARTIFACT_RETENTION_DAYS=3 JDK_DISTRIBUTION=corretto JOB_NAME='CI - Integration - Messaging' PULSAR_TEST_IMAGE_NAME=apachepulsar/java-test-image:latest DEVELOCITY_ACCESS_KEY= CI_JDK_MAJOR_VERSION= NETTY_LEAK_DETECTION= NETTY_LEAK_DUMP_DIR=${GITHUB_WORKSPACE}/target/netty-leak-dumps "${CURRENT_ENV[@]}" \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run '$GITHUB_WORKSPACE/build/pulsar_ci_tool.sh upload_inttest_coverage_files MESSAGING'
echo "##[endgroup]"
echo '$GITHUB_WORKSPACE/build/pulsar_ci_tool.sh upload_inttest_coverage_files MESSAGING' > /home/github/68311819544/steps/bugswarm_11.sh
chmod u+x /home/github/68311819544/steps/bugswarm_11.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=11 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=lhotari GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/pulsar GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=08d89a2ea1a2a566197f5db004881c4e222bb3ac GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Pulsar CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 MAVEN_OPTS='-Xss1500k -Xmx2048m -XX:+UnlockDiagnosticVMOptions -XX:+IgnoreUnrecognizedVMOptions -XX:GCLockerRetryAllocationCount=100 -Daether.connector.http.reuseConnections=false -Daether.connector.requestTimeout=60000 -Dhttp.keepAlive=false -Dmaven.wagon.http.pool=false -Dmaven.wagon.http.retryHandler.class=standard -Dmaven.wagon.http.retryHandler.count=3 -Dmaven.wagon.http.retryHandler.requestSentEnabled=true -Dmaven.wagon.http.serviceUnavailableRetryStrategy.class=standard -Dmaven.wagon.rto=60000' ARTIFACT_RETENTION_DAYS=3 JDK_DISTRIBUTION=corretto JOB_NAME='CI - Integration - Messaging' PULSAR_TEST_IMAGE_NAME=apachepulsar/java-test-image:latest DEVELOCITY_ACCESS_KEY= CI_JDK_MAJOR_VERSION= NETTY_LEAK_DETECTION= NETTY_LEAK_DUMP_DIR=${GITHUB_WORKSPACE}/target/netty-leak-dumps "${CURRENT_ENV[@]}" \
bash -e /home/github/68311819544/steps/bugswarm_11.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=11 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=lhotari GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/pulsar GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=08d89a2ea1a2a566197f5db004881c4e222bb3ac GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Pulsar CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 MAVEN_OPTS='-Xss1500k -Xmx2048m -XX:+UnlockDiagnosticVMOptions -XX:+IgnoreUnrecognizedVMOptions -XX:GCLockerRetryAllocationCount=100 -Daether.connector.http.reuseConnections=false -Daether.connector.requestTimeout=60000 -Dhttp.keepAlive=false -Dmaven.wagon.http.pool=false -Dmaven.wagon.http.retryHandler.class=standard -Dmaven.wagon.http.retryHandler.count=3 -Dmaven.wagon.http.retryHandler.requestSentEnabled=true -Dmaven.wagon.http.serviceUnavailableRetryStrategy.class=standard -Dmaven.wagon.rto=60000' ARTIFACT_RETENTION_DAYS=3 JDK_DISTRIBUTION=corretto JOB_NAME='CI - Integration - Messaging' PULSAR_TEST_IMAGE_NAME=apachepulsar/java-test-image:latest DEVELOCITY_ACCESS_KEY= CI_JDK_MAJOR_VERSION= NETTY_LEAK_DETECTION= NETTY_LEAK_DUMP_DIR=${GITHUB_WORKSPACE}/target/netty-leak-dumps "${CURRENT_ENV[@]}" \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=11 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=lhotari GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/pulsar GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=08d89a2ea1a2a566197f5db004881c4e222bb3ac GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Pulsar CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 MAVEN_OPTS='-Xss1500k -Xmx2048m -XX:+UnlockDiagnosticVMOptions -XX:+IgnoreUnrecognizedVMOptions -XX:GCLockerRetryAllocationCount=100 -Daether.connector.http.reuseConnections=false -Daether.connector.requestTimeout=60000 -Dhttp.keepAlive=false -Dmaven.wagon.http.pool=false -Dmaven.wagon.http.retryHandler.class=standard -Dmaven.wagon.http.retryHandler.count=3 -Dmaven.wagon.http.retryHandler.requestSentEnabled=true -Dmaven.wagon.http.serviceUnavailableRetryStrategy.class=standard -Dmaven.wagon.rto=60000' ARTIFACT_RETENTION_DAYS=3 JDK_DISTRIBUTION=corretto JOB_NAME='CI - Integration - Messaging' PULSAR_TEST_IMAGE_NAME=apachepulsar/java-test-image:latest DEVELOCITY_ACCESS_KEY= CI_JDK_MAJOR_VERSION= NETTY_LEAK_DETECTION= NETTY_LEAK_DUMP_DIR=${GITHUB_WORKSPACE}/target/netty-leak-dumps "${CURRENT_ENV[@]}" \
bash -e $ACTIONS_RUNNER_HOOK_STEP_COMPLETED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

fi

update_current_env "$LAST_JOB_NAME"
LAST_JOB_NAME="UNKNOWN"
if [ -f /home/github/workflow/paths.txt ]; then
   while read NEW_PATH 
   do
      PATH="$(eval echo "$NEW_PATH"):$PATH"
   done <<< "$(cat /home/github/workflow/paths.txt)"
else
  echo -n "" > /home/github/workflow/paths.txt
fi

if [ ! -f /home/github/workflow/event.json ]; then
  echo -n "{}" > /home/github/workflow/event.json
fi

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=12 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=lhotari GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/pulsar GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=08d89a2ea1a2a566197f5db004881c4e222bb3ac GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Pulsar CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 MAVEN_OPTS='-Xss1500k -Xmx2048m -XX:+UnlockDiagnosticVMOptions -XX:+IgnoreUnrecognizedVMOptions -XX:GCLockerRetryAllocationCount=100 -Daether.connector.http.reuseConnections=false -Daether.connector.requestTimeout=60000 -Dhttp.keepAlive=false -Dmaven.wagon.http.pool=false -Dmaven.wagon.http.retryHandler.class=standard -Dmaven.wagon.http.retryHandler.count=3 -Dmaven.wagon.http.retryHandler.requestSentEnabled=true -Dmaven.wagon.http.serviceUnavailableRetryStrategy.class=standard -Dmaven.wagon.rto=60000' ARTIFACT_RETENTION_DAYS=3 JDK_DISTRIBUTION=corretto JOB_NAME='CI - Integration - Messaging' PULSAR_TEST_IMAGE_NAME=apachepulsar/java-test-image:latest DEVELOCITY_ACCESS_KEY= CI_JDK_MAJOR_VERSION= NETTY_LEAK_DETECTION= NETTY_LEAK_DUMP_DIR=${GITHUB_WORKSPACE}/target/netty-leak-dumps "${CURRENT_ENV[@]}" \
echo "$(/home/github/68311819544/helpers/eval_expression p:'(' f:cancelled p:'(' p:')' p:')')")
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=12 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=lhotari GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/pulsar GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=08d89a2ea1a2a566197f5db004881c4e222bb3ac GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Pulsar CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 MAVEN_OPTS='-Xss1500k -Xmx2048m -XX:+UnlockDiagnosticVMOptions -XX:+IgnoreUnrecognizedVMOptions -XX:GCLockerRetryAllocationCount=100 -Daether.connector.http.reuseConnections=false -Daether.connector.requestTimeout=60000 -Dhttp.keepAlive=false -Dmaven.wagon.http.pool=false -Dmaven.wagon.http.retryHandler.class=standard -Dmaven.wagon.http.retryHandler.count=3 -Dmaven.wagon.http.retryHandler.requestSentEnabled=true -Dmaven.wagon.http.serviceUnavailableRetryStrategy.class=standard -Dmaven.wagon.rto=60000' ARTIFACT_RETENTION_DAYS=3 JDK_DISTRIBUTION=corretto JOB_NAME='CI - Integration - Messaging' PULSAR_TEST_IMAGE_NAME=apachepulsar/java-test-image:latest DEVELOCITY_ACCESS_KEY= CI_JDK_MAJOR_VERSION= NETTY_LEAK_DETECTION= NETTY_LEAK_DUMP_DIR=${GITHUB_WORKSPACE}/target/netty-leak-dumps "${CURRENT_ENV[@]}" \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run '$GITHUB_WORKSPACE/build/pulsar_ci_tool.sh print_thread_dumps'
echo "##[endgroup]"
echo '$GITHUB_WORKSPACE/build/pulsar_ci_tool.sh print_thread_dumps' > /home/github/68311819544/steps/bugswarm_12.sh
chmod u+x /home/github/68311819544/steps/bugswarm_12.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=12 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=lhotari GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/pulsar GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=08d89a2ea1a2a566197f5db004881c4e222bb3ac GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Pulsar CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 MAVEN_OPTS='-Xss1500k -Xmx2048m -XX:+UnlockDiagnosticVMOptions -XX:+IgnoreUnrecognizedVMOptions -XX:GCLockerRetryAllocationCount=100 -Daether.connector.http.reuseConnections=false -Daether.connector.requestTimeout=60000 -Dhttp.keepAlive=false -Dmaven.wagon.http.pool=false -Dmaven.wagon.http.retryHandler.class=standard -Dmaven.wagon.http.retryHandler.count=3 -Dmaven.wagon.http.retryHandler.requestSentEnabled=true -Dmaven.wagon.http.serviceUnavailableRetryStrategy.class=standard -Dmaven.wagon.rto=60000' ARTIFACT_RETENTION_DAYS=3 JDK_DISTRIBUTION=corretto JOB_NAME='CI - Integration - Messaging' PULSAR_TEST_IMAGE_NAME=apachepulsar/java-test-image:latest DEVELOCITY_ACCESS_KEY= CI_JDK_MAJOR_VERSION= NETTY_LEAK_DETECTION= NETTY_LEAK_DUMP_DIR=${GITHUB_WORKSPACE}/target/netty-leak-dumps "${CURRENT_ENV[@]}" \
bash -e /home/github/68311819544/steps/bugswarm_12.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=12 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=lhotari GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/pulsar GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=08d89a2ea1a2a566197f5db004881c4e222bb3ac GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Pulsar CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 MAVEN_OPTS='-Xss1500k -Xmx2048m -XX:+UnlockDiagnosticVMOptions -XX:+IgnoreUnrecognizedVMOptions -XX:GCLockerRetryAllocationCount=100 -Daether.connector.http.reuseConnections=false -Daether.connector.requestTimeout=60000 -Dhttp.keepAlive=false -Dmaven.wagon.http.pool=false -Dmaven.wagon.http.retryHandler.class=standard -Dmaven.wagon.http.retryHandler.count=3 -Dmaven.wagon.http.retryHandler.requestSentEnabled=true -Dmaven.wagon.http.serviceUnavailableRetryStrategy.class=standard -Dmaven.wagon.rto=60000' ARTIFACT_RETENTION_DAYS=3 JDK_DISTRIBUTION=corretto JOB_NAME='CI - Integration - Messaging' PULSAR_TEST_IMAGE_NAME=apachepulsar/java-test-image:latest DEVELOCITY_ACCESS_KEY= CI_JDK_MAJOR_VERSION= NETTY_LEAK_DETECTION= NETTY_LEAK_DUMP_DIR=${GITHUB_WORKSPACE}/target/netty-leak-dumps "${CURRENT_ENV[@]}" \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=12 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=lhotari GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/pulsar GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=08d89a2ea1a2a566197f5db004881c4e222bb3ac GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Pulsar CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 MAVEN_OPTS='-Xss1500k -Xmx2048m -XX:+UnlockDiagnosticVMOptions -XX:+IgnoreUnrecognizedVMOptions -XX:GCLockerRetryAllocationCount=100 -Daether.connector.http.reuseConnections=false -Daether.connector.requestTimeout=60000 -Dhttp.keepAlive=false -Dmaven.wagon.http.pool=false -Dmaven.wagon.http.retryHandler.class=standard -Dmaven.wagon.http.retryHandler.count=3 -Dmaven.wagon.http.retryHandler.requestSentEnabled=true -Dmaven.wagon.http.serviceUnavailableRetryStrategy.class=standard -Dmaven.wagon.rto=60000' ARTIFACT_RETENTION_DAYS=3 JDK_DISTRIBUTION=corretto JOB_NAME='CI - Integration - Messaging' PULSAR_TEST_IMAGE_NAME=apachepulsar/java-test-image:latest DEVELOCITY_ACCESS_KEY= CI_JDK_MAJOR_VERSION= NETTY_LEAK_DETECTION= NETTY_LEAK_DUMP_DIR=${GITHUB_WORKSPACE}/target/netty-leak-dumps "${CURRENT_ENV[@]}" \
bash -e $ACTIONS_RUNNER_HOOK_STEP_COMPLETED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

fi

update_current_env "$LAST_JOB_NAME"
LAST_JOB_NAME="UNKNOWN"
if [ -f /home/github/workflow/paths.txt ]; then
   while read NEW_PATH 
   do
      PATH="$(eval echo "$NEW_PATH"):$PATH"
   done <<< "$(cat /home/github/workflow/paths.txt)"
else
  echo -n "" > /home/github/workflow/paths.txt
fi

if [ ! -f /home/github/workflow/event.json ]; then
  echo -n "{}" > /home/github/workflow/event.json
fi

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=13 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=apache/pulsar GITHUB_ACTIONS=true GITHUB_ACTOR=lhotari GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/pulsar GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=08d89a2ea1a2a566197f5db004881c4e222bb3ac GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Pulsar CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 MAVEN_OPTS='-Xss1500k -Xmx2048m -XX:+UnlockDiagnosticVMOptions -XX:+IgnoreUnrecognizedVMOptions -XX:GCLockerRetryAllocationCount=100 -Daether.connector.http.reuseConnections=false -Daether.connector.requestTimeout=60000 -Dhttp.keepAlive=false -Dmaven.wagon.http.pool=false -Dmaven.wagon.http.retryHandler.class=standard -Dmaven.wagon.http.retryHandler.count=3 -Dmaven.wagon.http.retryHandler.requestSentEnabled=true -Dmaven.wagon.http.serviceUnavailableRetryStrategy.class=standard -Dmaven.wagon.rto=60000' ARTIFACT_RETENTION_DAYS=3 JDK_DISTRIBUTION=corretto GITHUB_ACTION_PATH=/home/github/68311819544/actions/apache-pulsar/./.github/actions/copy-test-reports JOB_NAME='CI - Integration - Messaging' PULSAR_TEST_IMAGE_NAME=apachepulsar/java-test-image:latest DEVELOCITY_ACCESS_KEY= CI_JDK_MAJOR_VERSION= NETTY_LEAK_DETECTION= NETTY_LEAK_DUMP_DIR=${GITHUB_WORKSPACE}/target/netty-leak-dumps "${CURRENT_ENV[@]}" \
echo "$(/home/github/68311819544/helpers/eval_expression p:'(' f:always p:'(' p:')' p:')')")
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=13 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=apache/pulsar GITHUB_ACTIONS=true GITHUB_ACTOR=lhotari GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/pulsar GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=08d89a2ea1a2a566197f5db004881c4e222bb3ac GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Pulsar CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 MAVEN_OPTS='-Xss1500k -Xmx2048m -XX:+UnlockDiagnosticVMOptions -XX:+IgnoreUnrecognizedVMOptions -XX:GCLockerRetryAllocationCount=100 -Daether.connector.http.reuseConnections=false -Daether.connector.requestTimeout=60000 -Dhttp.keepAlive=false -Dmaven.wagon.http.pool=false -Dmaven.wagon.http.retryHandler.class=standard -Dmaven.wagon.http.retryHandler.count=3 -Dmaven.wagon.http.retryHandler.requestSentEnabled=true -Dmaven.wagon.http.serviceUnavailableRetryStrategy.class=standard -Dmaven.wagon.rto=60000' ARTIFACT_RETENTION_DAYS=3 JDK_DISTRIBUTION=corretto GITHUB_ACTION_PATH=/home/github/68311819544/actions/apache-pulsar/./.github/actions/copy-test-reports JOB_NAME='CI - Integration - Messaging' PULSAR_TEST_IMAGE_NAME=apachepulsar/java-test-image:latest DEVELOCITY_ACCESS_KEY= CI_JDK_MAJOR_VERSION= NETTY_LEAK_DETECTION= NETTY_LEAK_DUMP_DIR=${GITHUB_WORKSPACE}/target/netty-leak-dumps "${CURRENT_ENV[@]}" \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run ./.github/actions/copy-test-reports
echo "##[endgroup]"
echo /home/github/68311819544/steps/bugswarm_13_composite.sh > /home/github/68311819544/steps/bugswarm_13.sh
chmod u+x /home/github/68311819544/steps/bugswarm_13.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=13 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=apache/pulsar GITHUB_ACTIONS=true GITHUB_ACTOR=lhotari GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/pulsar GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=08d89a2ea1a2a566197f5db004881c4e222bb3ac GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Pulsar CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 MAVEN_OPTS='-Xss1500k -Xmx2048m -XX:+UnlockDiagnosticVMOptions -XX:+IgnoreUnrecognizedVMOptions -XX:GCLockerRetryAllocationCount=100 -Daether.connector.http.reuseConnections=false -Daether.connector.requestTimeout=60000 -Dhttp.keepAlive=false -Dmaven.wagon.http.pool=false -Dmaven.wagon.http.retryHandler.class=standard -Dmaven.wagon.http.retryHandler.count=3 -Dmaven.wagon.http.retryHandler.requestSentEnabled=true -Dmaven.wagon.http.serviceUnavailableRetryStrategy.class=standard -Dmaven.wagon.rto=60000' ARTIFACT_RETENTION_DAYS=3 JDK_DISTRIBUTION=corretto GITHUB_ACTION_PATH=/home/github/68311819544/actions/apache-pulsar/./.github/actions/copy-test-reports JOB_NAME='CI - Integration - Messaging' PULSAR_TEST_IMAGE_NAME=apachepulsar/java-test-image:latest DEVELOCITY_ACCESS_KEY= CI_JDK_MAJOR_VERSION= NETTY_LEAK_DETECTION= NETTY_LEAK_DUMP_DIR=${GITHUB_WORKSPACE}/target/netty-leak-dumps "${CURRENT_ENV[@]}" \
bash -e /home/github/68311819544/steps/bugswarm_13.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=13 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=apache/pulsar GITHUB_ACTIONS=true GITHUB_ACTOR=lhotari GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/pulsar GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=08d89a2ea1a2a566197f5db004881c4e222bb3ac GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Pulsar CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 MAVEN_OPTS='-Xss1500k -Xmx2048m -XX:+UnlockDiagnosticVMOptions -XX:+IgnoreUnrecognizedVMOptions -XX:GCLockerRetryAllocationCount=100 -Daether.connector.http.reuseConnections=false -Daether.connector.requestTimeout=60000 -Dhttp.keepAlive=false -Dmaven.wagon.http.pool=false -Dmaven.wagon.http.retryHandler.class=standard -Dmaven.wagon.http.retryHandler.count=3 -Dmaven.wagon.http.retryHandler.requestSentEnabled=true -Dmaven.wagon.http.serviceUnavailableRetryStrategy.class=standard -Dmaven.wagon.rto=60000' ARTIFACT_RETENTION_DAYS=3 JDK_DISTRIBUTION=corretto GITHUB_ACTION_PATH=/home/github/68311819544/actions/apache-pulsar/./.github/actions/copy-test-reports JOB_NAME='CI - Integration - Messaging' PULSAR_TEST_IMAGE_NAME=apachepulsar/java-test-image:latest DEVELOCITY_ACCESS_KEY= CI_JDK_MAJOR_VERSION= NETTY_LEAK_DETECTION= NETTY_LEAK_DUMP_DIR=${GITHUB_WORKSPACE}/target/netty-leak-dumps "${CURRENT_ENV[@]}" \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=13 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=apache/pulsar GITHUB_ACTIONS=true GITHUB_ACTOR=lhotari GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/pulsar GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=08d89a2ea1a2a566197f5db004881c4e222bb3ac GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Pulsar CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 MAVEN_OPTS='-Xss1500k -Xmx2048m -XX:+UnlockDiagnosticVMOptions -XX:+IgnoreUnrecognizedVMOptions -XX:GCLockerRetryAllocationCount=100 -Daether.connector.http.reuseConnections=false -Daether.connector.requestTimeout=60000 -Dhttp.keepAlive=false -Dmaven.wagon.http.pool=false -Dmaven.wagon.http.retryHandler.class=standard -Dmaven.wagon.http.retryHandler.count=3 -Dmaven.wagon.http.retryHandler.requestSentEnabled=true -Dmaven.wagon.http.serviceUnavailableRetryStrategy.class=standard -Dmaven.wagon.rto=60000' ARTIFACT_RETENTION_DAYS=3 JDK_DISTRIBUTION=corretto GITHUB_ACTION_PATH=/home/github/68311819544/actions/apache-pulsar/./.github/actions/copy-test-reports JOB_NAME='CI - Integration - Messaging' PULSAR_TEST_IMAGE_NAME=apachepulsar/java-test-image:latest DEVELOCITY_ACCESS_KEY= CI_JDK_MAJOR_VERSION= NETTY_LEAK_DETECTION= NETTY_LEAK_DUMP_DIR=${GITHUB_WORKSPACE}/target/netty-leak-dumps "${CURRENT_ENV[@]}" \
bash -e $ACTIONS_RUNNER_HOOK_STEP_COMPLETED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

fi

update_current_env "$LAST_JOB_NAME"
LAST_JOB_NAME="UNKNOWN"
if [ -f /home/github/workflow/paths.txt ]; then
   while read NEW_PATH 
   do
      PATH="$(eval echo "$NEW_PATH"):$PATH"
   done <<< "$(cat /home/github/workflow/paths.txt)"
else
  echo -n "" > /home/github/workflow/paths.txt
fi

if [ ! -f /home/github/workflow/event.json ]; then
  echo -n "{}" > /home/github/workflow/event.json
fi

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=14 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=apache/pulsar-test-infra GITHUB_ACTIONS=true GITHUB_ACTOR=lhotari GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/pulsar GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=08d89a2ea1a2a566197f5db004881c4e222bb3ac GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Pulsar CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 MAVEN_OPTS='-Xss1500k -Xmx2048m -XX:+UnlockDiagnosticVMOptions -XX:+IgnoreUnrecognizedVMOptions -XX:GCLockerRetryAllocationCount=100 -Daether.connector.http.reuseConnections=false -Daether.connector.requestTimeout=60000 -Dhttp.keepAlive=false -Dmaven.wagon.http.pool=false -Dmaven.wagon.http.retryHandler.class=standard -Dmaven.wagon.http.retryHandler.count=3 -Dmaven.wagon.http.retryHandler.requestSentEnabled=true -Dmaven.wagon.http.serviceUnavailableRetryStrategy.class=standard -Dmaven.wagon.rto=60000' ARTIFACT_RETENTION_DAYS=3 JDK_DISTRIBUTION=corretto GITHUB_ACTION_PATH=/home/github/68311819544/actions/apache-pulsar-test-infra@master/action-junit-report JOB_NAME='CI - Integration - Messaging' PULSAR_TEST_IMAGE_NAME=apachepulsar/java-test-image:latest DEVELOCITY_ACCESS_KEY= CI_JDK_MAJOR_VERSION= NETTY_LEAK_DETECTION= NETTY_LEAK_DUMP_DIR=${GITHUB_WORKSPACE}/target/netty-leak-dumps "${CURRENT_ENV[@]}" INPUT_REPORT_PATHS='test-reports/TEST-*.xml' INPUT_ANNOTATE_ONLY=true INPUT_TOKEN=DUMMY INPUT_TEST_FILES_PREFIX= INPUT_EXCLUDE_SOURCES=/build/,/__pycache__/ INPUT_SUITE_REGEX= INPUT_UPDATE_CHECK=false INPUT_CHECK_NAME='JUnit Test Report' INPUT_FAIL_ON_FAILURE=false INPUT_REQUIRE_TESTS=false INPUT_INCLUDE_PASSED=false INPUT_SUMMARY= INPUT_CHECK_RETRIES=false INPUT_TRANSFORMERS='[]' INPUT_JOB_SUMMARY=true INPUT_DETAILED_SUMMARY=false INPUT_ANNOTATE_NOTICE=false \
echo "$(/home/github/68311819544/helpers/eval_expression p:'(' f:always p:'(' p:')' p:')')")
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=14 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=apache/pulsar-test-infra GITHUB_ACTIONS=true GITHUB_ACTOR=lhotari GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/pulsar GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=08d89a2ea1a2a566197f5db004881c4e222bb3ac GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Pulsar CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 MAVEN_OPTS='-Xss1500k -Xmx2048m -XX:+UnlockDiagnosticVMOptions -XX:+IgnoreUnrecognizedVMOptions -XX:GCLockerRetryAllocationCount=100 -Daether.connector.http.reuseConnections=false -Daether.connector.requestTimeout=60000 -Dhttp.keepAlive=false -Dmaven.wagon.http.pool=false -Dmaven.wagon.http.retryHandler.class=standard -Dmaven.wagon.http.retryHandler.count=3 -Dmaven.wagon.http.retryHandler.requestSentEnabled=true -Dmaven.wagon.http.serviceUnavailableRetryStrategy.class=standard -Dmaven.wagon.rto=60000' ARTIFACT_RETENTION_DAYS=3 JDK_DISTRIBUTION=corretto GITHUB_ACTION_PATH=/home/github/68311819544/actions/apache-pulsar-test-infra@master/action-junit-report JOB_NAME='CI - Integration - Messaging' PULSAR_TEST_IMAGE_NAME=apachepulsar/java-test-image:latest DEVELOCITY_ACCESS_KEY= CI_JDK_MAJOR_VERSION= NETTY_LEAK_DETECTION= NETTY_LEAK_DUMP_DIR=${GITHUB_WORKSPACE}/target/netty-leak-dumps "${CURRENT_ENV[@]}" INPUT_REPORT_PATHS='test-reports/TEST-*.xml' INPUT_ANNOTATE_ONLY=true INPUT_TOKEN=DUMMY INPUT_TEST_FILES_PREFIX= INPUT_EXCLUDE_SOURCES=/build/,/__pycache__/ INPUT_SUITE_REGEX= INPUT_UPDATE_CHECK=false INPUT_CHECK_NAME='JUnit Test Report' INPUT_FAIL_ON_FAILURE=false INPUT_REQUIRE_TESTS=false INPUT_INCLUDE_PASSED=false INPUT_SUMMARY= INPUT_CHECK_RETRIES=false INPUT_TRANSFORMERS='[]' INPUT_JOB_SUMMARY=true INPUT_DETAILED_SUMMARY=false INPUT_ANNOTATE_NOTICE=false \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run apache/pulsar-test-infra/action-junit-report@master
echo "##[endgroup]"
echo node /home/github/68311819544/actions/apache-pulsar-test-infra@master/action-junit-report/dist/index.js > /home/github/68311819544/steps/bugswarm_cmd.sh
chmod u+x /home/github/68311819544/steps/bugswarm_cmd.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=14 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=apache/pulsar-test-infra GITHUB_ACTIONS=true GITHUB_ACTOR=lhotari GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/pulsar GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=08d89a2ea1a2a566197f5db004881c4e222bb3ac GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Pulsar CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 MAVEN_OPTS='-Xss1500k -Xmx2048m -XX:+UnlockDiagnosticVMOptions -XX:+IgnoreUnrecognizedVMOptions -XX:GCLockerRetryAllocationCount=100 -Daether.connector.http.reuseConnections=false -Daether.connector.requestTimeout=60000 -Dhttp.keepAlive=false -Dmaven.wagon.http.pool=false -Dmaven.wagon.http.retryHandler.class=standard -Dmaven.wagon.http.retryHandler.count=3 -Dmaven.wagon.http.retryHandler.requestSentEnabled=true -Dmaven.wagon.http.serviceUnavailableRetryStrategy.class=standard -Dmaven.wagon.rto=60000' ARTIFACT_RETENTION_DAYS=3 JDK_DISTRIBUTION=corretto GITHUB_ACTION_PATH=/home/github/68311819544/actions/apache-pulsar-test-infra@master/action-junit-report JOB_NAME='CI - Integration - Messaging' PULSAR_TEST_IMAGE_NAME=apachepulsar/java-test-image:latest DEVELOCITY_ACCESS_KEY= CI_JDK_MAJOR_VERSION= NETTY_LEAK_DETECTION= NETTY_LEAK_DUMP_DIR=${GITHUB_WORKSPACE}/target/netty-leak-dumps "${CURRENT_ENV[@]}" INPUT_REPORT_PATHS='test-reports/TEST-*.xml' INPUT_ANNOTATE_ONLY=true INPUT_TOKEN=DUMMY INPUT_TEST_FILES_PREFIX= INPUT_EXCLUDE_SOURCES=/build/,/__pycache__/ INPUT_SUITE_REGEX= INPUT_UPDATE_CHECK=false INPUT_CHECK_NAME='JUnit Test Report' INPUT_FAIL_ON_FAILURE=false INPUT_REQUIRE_TESTS=false INPUT_INCLUDE_PASSED=false INPUT_SUMMARY= INPUT_CHECK_RETRIES=false INPUT_TRANSFORMERS='[]' INPUT_JOB_SUMMARY=true INPUT_DETAILED_SUMMARY=false INPUT_ANNOTATE_NOTICE=false \
bash -e /home/github/68311819544/steps/bugswarm_cmd.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=14 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=apache/pulsar-test-infra GITHUB_ACTIONS=true GITHUB_ACTOR=lhotari GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/pulsar GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=08d89a2ea1a2a566197f5db004881c4e222bb3ac GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Pulsar CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 MAVEN_OPTS='-Xss1500k -Xmx2048m -XX:+UnlockDiagnosticVMOptions -XX:+IgnoreUnrecognizedVMOptions -XX:GCLockerRetryAllocationCount=100 -Daether.connector.http.reuseConnections=false -Daether.connector.requestTimeout=60000 -Dhttp.keepAlive=false -Dmaven.wagon.http.pool=false -Dmaven.wagon.http.retryHandler.class=standard -Dmaven.wagon.http.retryHandler.count=3 -Dmaven.wagon.http.retryHandler.requestSentEnabled=true -Dmaven.wagon.http.serviceUnavailableRetryStrategy.class=standard -Dmaven.wagon.rto=60000' ARTIFACT_RETENTION_DAYS=3 JDK_DISTRIBUTION=corretto GITHUB_ACTION_PATH=/home/github/68311819544/actions/apache-pulsar-test-infra@master/action-junit-report JOB_NAME='CI - Integration - Messaging' PULSAR_TEST_IMAGE_NAME=apachepulsar/java-test-image:latest DEVELOCITY_ACCESS_KEY= CI_JDK_MAJOR_VERSION= NETTY_LEAK_DETECTION= NETTY_LEAK_DUMP_DIR=${GITHUB_WORKSPACE}/target/netty-leak-dumps "${CURRENT_ENV[@]}" INPUT_REPORT_PATHS='test-reports/TEST-*.xml' INPUT_ANNOTATE_ONLY=true INPUT_TOKEN=DUMMY INPUT_TEST_FILES_PREFIX= INPUT_EXCLUDE_SOURCES=/build/,/__pycache__/ INPUT_SUITE_REGEX= INPUT_UPDATE_CHECK=false INPUT_CHECK_NAME='JUnit Test Report' INPUT_FAIL_ON_FAILURE=false INPUT_REQUIRE_TESTS=false INPUT_INCLUDE_PASSED=false INPUT_SUMMARY= INPUT_CHECK_RETRIES=false INPUT_TRANSFORMERS='[]' INPUT_JOB_SUMMARY=true INPUT_DETAILED_SUMMARY=false INPUT_ANNOTATE_NOTICE=false \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=14 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=apache/pulsar-test-infra GITHUB_ACTIONS=true GITHUB_ACTOR=lhotari GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/pulsar GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=08d89a2ea1a2a566197f5db004881c4e222bb3ac GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Pulsar CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 MAVEN_OPTS='-Xss1500k -Xmx2048m -XX:+UnlockDiagnosticVMOptions -XX:+IgnoreUnrecognizedVMOptions -XX:GCLockerRetryAllocationCount=100 -Daether.connector.http.reuseConnections=false -Daether.connector.requestTimeout=60000 -Dhttp.keepAlive=false -Dmaven.wagon.http.pool=false -Dmaven.wagon.http.retryHandler.class=standard -Dmaven.wagon.http.retryHandler.count=3 -Dmaven.wagon.http.retryHandler.requestSentEnabled=true -Dmaven.wagon.http.serviceUnavailableRetryStrategy.class=standard -Dmaven.wagon.rto=60000' ARTIFACT_RETENTION_DAYS=3 JDK_DISTRIBUTION=corretto GITHUB_ACTION_PATH=/home/github/68311819544/actions/apache-pulsar-test-infra@master/action-junit-report JOB_NAME='CI - Integration - Messaging' PULSAR_TEST_IMAGE_NAME=apachepulsar/java-test-image:latest DEVELOCITY_ACCESS_KEY= CI_JDK_MAJOR_VERSION= NETTY_LEAK_DETECTION= NETTY_LEAK_DUMP_DIR=${GITHUB_WORKSPACE}/target/netty-leak-dumps "${CURRENT_ENV[@]}" INPUT_REPORT_PATHS='test-reports/TEST-*.xml' INPUT_ANNOTATE_ONLY=true INPUT_TOKEN=DUMMY INPUT_TEST_FILES_PREFIX= INPUT_EXCLUDE_SOURCES=/build/,/__pycache__/ INPUT_SUITE_REGEX= INPUT_UPDATE_CHECK=false INPUT_CHECK_NAME='JUnit Test Report' INPUT_FAIL_ON_FAILURE=false INPUT_REQUIRE_TESTS=false INPUT_INCLUDE_PASSED=false INPUT_SUMMARY= INPUT_CHECK_RETRIES=false INPUT_TRANSFORMERS='[]' INPUT_JOB_SUMMARY=true INPUT_DETAILED_SUMMARY=false INPUT_ANNOTATE_NOTICE=false \
bash -e $ACTIONS_RUNNER_HOOK_STEP_COMPLETED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

fi

update_current_env "$LAST_JOB_NAME"
LAST_JOB_NAME="UNKNOWN"
if [ -f /home/github/workflow/paths.txt ]; then
   while read NEW_PATH 
   do
      PATH="$(eval echo "$NEW_PATH"):$PATH"
   done <<< "$(cat /home/github/workflow/paths.txt)"
else
  echo -n "" > /home/github/workflow/paths.txt
fi

if [ ! -f /home/github/workflow/event.json ]; then
  echo -n "{}" > /home/github/workflow/event.json
fi

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=15 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=lhotari GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/pulsar GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=08d89a2ea1a2a566197f5db004881c4e222bb3ac GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Pulsar CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 MAVEN_OPTS='-Xss1500k -Xmx2048m -XX:+UnlockDiagnosticVMOptions -XX:+IgnoreUnrecognizedVMOptions -XX:GCLockerRetryAllocationCount=100 -Daether.connector.http.reuseConnections=false -Daether.connector.requestTimeout=60000 -Dhttp.keepAlive=false -Dmaven.wagon.http.pool=false -Dmaven.wagon.http.retryHandler.class=standard -Dmaven.wagon.http.retryHandler.count=3 -Dmaven.wagon.http.retryHandler.requestSentEnabled=true -Dmaven.wagon.http.serviceUnavailableRetryStrategy.class=standard -Dmaven.wagon.rto=60000' ARTIFACT_RETENTION_DAYS=3 JDK_DISTRIBUTION=corretto JOB_NAME='CI - Integration - Messaging' PULSAR_TEST_IMAGE_NAME=apachepulsar/java-test-image:latest DEVELOCITY_ACCESS_KEY= CI_JDK_MAJOR_VERSION= NETTY_LEAK_DETECTION= NETTY_LEAK_DUMP_DIR=${GITHUB_WORKSPACE}/target/netty-leak-dumps "${CURRENT_ENV[@]}" \
echo "$(/home/github/68311819544/helpers/eval_expression p:'(' f:always p:'(' p:')' p:')' o:'&&' p:'(' s:"$(test -v "CURRENT_ENV_MAP[NETTY_LEAK_DETECTION]" && echo "${CURRENT_ENV_MAP[NETTY_LEAK_DETECTION]}" || echo )" o:'!=' s:off p:')')")
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=15 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=lhotari GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/pulsar GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=08d89a2ea1a2a566197f5db004881c4e222bb3ac GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Pulsar CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 MAVEN_OPTS='-Xss1500k -Xmx2048m -XX:+UnlockDiagnosticVMOptions -XX:+IgnoreUnrecognizedVMOptions -XX:GCLockerRetryAllocationCount=100 -Daether.connector.http.reuseConnections=false -Daether.connector.requestTimeout=60000 -Dhttp.keepAlive=false -Dmaven.wagon.http.pool=false -Dmaven.wagon.http.retryHandler.class=standard -Dmaven.wagon.http.retryHandler.count=3 -Dmaven.wagon.http.retryHandler.requestSentEnabled=true -Dmaven.wagon.http.serviceUnavailableRetryStrategy.class=standard -Dmaven.wagon.rto=60000' ARTIFACT_RETENTION_DAYS=3 JDK_DISTRIBUTION=corretto JOB_NAME='CI - Integration - Messaging' PULSAR_TEST_IMAGE_NAME=apachepulsar/java-test-image:latest DEVELOCITY_ACCESS_KEY= CI_JDK_MAJOR_VERSION= NETTY_LEAK_DETECTION= NETTY_LEAK_DUMP_DIR=${GITHUB_WORKSPACE}/target/netty-leak-dumps "${CURRENT_ENV[@]}" \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run '$GITHUB_WORKSPACE/build/pulsar_ci_tool.sh report_netty_leaks'
echo "##[endgroup]"
echo '$GITHUB_WORKSPACE/build/pulsar_ci_tool.sh report_netty_leaks' > /home/github/68311819544/steps/bugswarm_15.sh
chmod u+x /home/github/68311819544/steps/bugswarm_15.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=15 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=lhotari GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/pulsar GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=08d89a2ea1a2a566197f5db004881c4e222bb3ac GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Pulsar CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 MAVEN_OPTS='-Xss1500k -Xmx2048m -XX:+UnlockDiagnosticVMOptions -XX:+IgnoreUnrecognizedVMOptions -XX:GCLockerRetryAllocationCount=100 -Daether.connector.http.reuseConnections=false -Daether.connector.requestTimeout=60000 -Dhttp.keepAlive=false -Dmaven.wagon.http.pool=false -Dmaven.wagon.http.retryHandler.class=standard -Dmaven.wagon.http.retryHandler.count=3 -Dmaven.wagon.http.retryHandler.requestSentEnabled=true -Dmaven.wagon.http.serviceUnavailableRetryStrategy.class=standard -Dmaven.wagon.rto=60000' ARTIFACT_RETENTION_DAYS=3 JDK_DISTRIBUTION=corretto JOB_NAME='CI - Integration - Messaging' PULSAR_TEST_IMAGE_NAME=apachepulsar/java-test-image:latest DEVELOCITY_ACCESS_KEY= CI_JDK_MAJOR_VERSION= NETTY_LEAK_DETECTION= NETTY_LEAK_DUMP_DIR=${GITHUB_WORKSPACE}/target/netty-leak-dumps "${CURRENT_ENV[@]}" \
bash -e /home/github/68311819544/steps/bugswarm_15.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=15 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=lhotari GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/pulsar GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=08d89a2ea1a2a566197f5db004881c4e222bb3ac GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Pulsar CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 MAVEN_OPTS='-Xss1500k -Xmx2048m -XX:+UnlockDiagnosticVMOptions -XX:+IgnoreUnrecognizedVMOptions -XX:GCLockerRetryAllocationCount=100 -Daether.connector.http.reuseConnections=false -Daether.connector.requestTimeout=60000 -Dhttp.keepAlive=false -Dmaven.wagon.http.pool=false -Dmaven.wagon.http.retryHandler.class=standard -Dmaven.wagon.http.retryHandler.count=3 -Dmaven.wagon.http.retryHandler.requestSentEnabled=true -Dmaven.wagon.http.serviceUnavailableRetryStrategy.class=standard -Dmaven.wagon.rto=60000' ARTIFACT_RETENTION_DAYS=3 JDK_DISTRIBUTION=corretto JOB_NAME='CI - Integration - Messaging' PULSAR_TEST_IMAGE_NAME=apachepulsar/java-test-image:latest DEVELOCITY_ACCESS_KEY= CI_JDK_MAJOR_VERSION= NETTY_LEAK_DETECTION= NETTY_LEAK_DUMP_DIR=${GITHUB_WORKSPACE}/target/netty-leak-dumps "${CURRENT_ENV[@]}" \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=15 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=lhotari GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/pulsar GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=08d89a2ea1a2a566197f5db004881c4e222bb3ac GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Pulsar CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 MAVEN_OPTS='-Xss1500k -Xmx2048m -XX:+UnlockDiagnosticVMOptions -XX:+IgnoreUnrecognizedVMOptions -XX:GCLockerRetryAllocationCount=100 -Daether.connector.http.reuseConnections=false -Daether.connector.requestTimeout=60000 -Dhttp.keepAlive=false -Dmaven.wagon.http.pool=false -Dmaven.wagon.http.retryHandler.class=standard -Dmaven.wagon.http.retryHandler.count=3 -Dmaven.wagon.http.retryHandler.requestSentEnabled=true -Dmaven.wagon.http.serviceUnavailableRetryStrategy.class=standard -Dmaven.wagon.rto=60000' ARTIFACT_RETENTION_DAYS=3 JDK_DISTRIBUTION=corretto JOB_NAME='CI - Integration - Messaging' PULSAR_TEST_IMAGE_NAME=apachepulsar/java-test-image:latest DEVELOCITY_ACCESS_KEY= CI_JDK_MAJOR_VERSION= NETTY_LEAK_DETECTION= NETTY_LEAK_DUMP_DIR=${GITHUB_WORKSPACE}/target/netty-leak-dumps "${CURRENT_ENV[@]}" \
bash -e $ACTIONS_RUNNER_HOOK_STEP_COMPLETED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

fi

update_current_env "$LAST_JOB_NAME"
LAST_JOB_NAME="UNKNOWN"
if [ -f /home/github/workflow/paths.txt ]; then
   while read NEW_PATH 
   do
      PATH="$(eval echo "$NEW_PATH"):$PATH"
   done <<< "$(cat /home/github/workflow/paths.txt)"
else
  echo -n "" > /home/github/workflow/paths.txt
fi

if [ ! -f /home/github/workflow/event.json ]; then
  echo -n "{}" > /home/github/workflow/event.json
fi

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=19 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=apache/pulsar GITHUB_ACTIONS=true GITHUB_ACTOR=lhotari GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/pulsar GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=08d89a2ea1a2a566197f5db004881c4e222bb3ac GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Pulsar CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 MAVEN_OPTS='-Xss1500k -Xmx2048m -XX:+UnlockDiagnosticVMOptions -XX:+IgnoreUnrecognizedVMOptions -XX:GCLockerRetryAllocationCount=100 -Daether.connector.http.reuseConnections=false -Daether.connector.requestTimeout=60000 -Dhttp.keepAlive=false -Dmaven.wagon.http.pool=false -Dmaven.wagon.http.retryHandler.class=standard -Dmaven.wagon.http.retryHandler.count=3 -Dmaven.wagon.http.retryHandler.requestSentEnabled=true -Dmaven.wagon.http.serviceUnavailableRetryStrategy.class=standard -Dmaven.wagon.rto=60000' ARTIFACT_RETENTION_DAYS=3 JDK_DISTRIBUTION=corretto GITHUB_ACTION_PATH=/home/github/68311819544/actions/apache-pulsar/./.github/actions/ssh-access JOB_NAME='CI - Integration - Messaging' PULSAR_TEST_IMAGE_NAME=apachepulsar/java-test-image:latest DEVELOCITY_ACCESS_KEY= CI_JDK_MAJOR_VERSION= NETTY_LEAK_DETECTION= NETTY_LEAK_DUMP_DIR=${GITHUB_WORKSPACE}/target/netty-leak-dumps "${CURRENT_ENV[@]}" INPUT_ACTION=wait INPUT_LIMIT-ACCESS-TO-ACTOR=false INPUT_LIMIT-ACCESS-TO-USERS= INPUT_SECURE-ACCESS=true INPUT_TIMEOUT=300 \
echo "$(/home/github/68311819544/helpers/eval_expression p:'(' f:failure p:'(' p:')' p:')' o:'&&' p:'(' s:apache/pulsar o:'!=' s:apache/pulsar p:')' o:'&&' p:'(' s:push o:== s:pull_request p:')')")
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=19 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=apache/pulsar GITHUB_ACTIONS=true GITHUB_ACTOR=lhotari GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/pulsar GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=08d89a2ea1a2a566197f5db004881c4e222bb3ac GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Pulsar CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 MAVEN_OPTS='-Xss1500k -Xmx2048m -XX:+UnlockDiagnosticVMOptions -XX:+IgnoreUnrecognizedVMOptions -XX:GCLockerRetryAllocationCount=100 -Daether.connector.http.reuseConnections=false -Daether.connector.requestTimeout=60000 -Dhttp.keepAlive=false -Dmaven.wagon.http.pool=false -Dmaven.wagon.http.retryHandler.class=standard -Dmaven.wagon.http.retryHandler.count=3 -Dmaven.wagon.http.retryHandler.requestSentEnabled=true -Dmaven.wagon.http.serviceUnavailableRetryStrategy.class=standard -Dmaven.wagon.rto=60000' ARTIFACT_RETENTION_DAYS=3 JDK_DISTRIBUTION=corretto GITHUB_ACTION_PATH=/home/github/68311819544/actions/apache-pulsar/./.github/actions/ssh-access JOB_NAME='CI - Integration - Messaging' PULSAR_TEST_IMAGE_NAME=apachepulsar/java-test-image:latest DEVELOCITY_ACCESS_KEY= CI_JDK_MAJOR_VERSION= NETTY_LEAK_DETECTION= NETTY_LEAK_DUMP_DIR=${GITHUB_WORKSPACE}/target/netty-leak-dumps "${CURRENT_ENV[@]}" INPUT_ACTION=wait INPUT_LIMIT-ACCESS-TO-ACTOR=false INPUT_LIMIT-ACCESS-TO-USERS= INPUT_SECURE-ACCESS=true INPUT_TIMEOUT=300 \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run ./.github/actions/ssh-access
echo "##[endgroup]"
echo /home/github/68311819544/steps/bugswarm_19_composite.sh > /home/github/68311819544/steps/bugswarm_19.sh
chmod u+x /home/github/68311819544/steps/bugswarm_19.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=19 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=apache/pulsar GITHUB_ACTIONS=true GITHUB_ACTOR=lhotari GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/pulsar GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=08d89a2ea1a2a566197f5db004881c4e222bb3ac GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Pulsar CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 MAVEN_OPTS='-Xss1500k -Xmx2048m -XX:+UnlockDiagnosticVMOptions -XX:+IgnoreUnrecognizedVMOptions -XX:GCLockerRetryAllocationCount=100 -Daether.connector.http.reuseConnections=false -Daether.connector.requestTimeout=60000 -Dhttp.keepAlive=false -Dmaven.wagon.http.pool=false -Dmaven.wagon.http.retryHandler.class=standard -Dmaven.wagon.http.retryHandler.count=3 -Dmaven.wagon.http.retryHandler.requestSentEnabled=true -Dmaven.wagon.http.serviceUnavailableRetryStrategy.class=standard -Dmaven.wagon.rto=60000' ARTIFACT_RETENTION_DAYS=3 JDK_DISTRIBUTION=corretto GITHUB_ACTION_PATH=/home/github/68311819544/actions/apache-pulsar/./.github/actions/ssh-access JOB_NAME='CI - Integration - Messaging' PULSAR_TEST_IMAGE_NAME=apachepulsar/java-test-image:latest DEVELOCITY_ACCESS_KEY= CI_JDK_MAJOR_VERSION= NETTY_LEAK_DETECTION= NETTY_LEAK_DUMP_DIR=${GITHUB_WORKSPACE}/target/netty-leak-dumps "${CURRENT_ENV[@]}" INPUT_ACTION=wait INPUT_LIMIT-ACCESS-TO-ACTOR=false INPUT_LIMIT-ACCESS-TO-USERS= INPUT_SECURE-ACCESS=true INPUT_TIMEOUT=300 \
bash -e /home/github/68311819544/steps/bugswarm_19.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=19 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=apache/pulsar GITHUB_ACTIONS=true GITHUB_ACTOR=lhotari GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/pulsar GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=08d89a2ea1a2a566197f5db004881c4e222bb3ac GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Pulsar CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 MAVEN_OPTS='-Xss1500k -Xmx2048m -XX:+UnlockDiagnosticVMOptions -XX:+IgnoreUnrecognizedVMOptions -XX:GCLockerRetryAllocationCount=100 -Daether.connector.http.reuseConnections=false -Daether.connector.requestTimeout=60000 -Dhttp.keepAlive=false -Dmaven.wagon.http.pool=false -Dmaven.wagon.http.retryHandler.class=standard -Dmaven.wagon.http.retryHandler.count=3 -Dmaven.wagon.http.retryHandler.requestSentEnabled=true -Dmaven.wagon.http.serviceUnavailableRetryStrategy.class=standard -Dmaven.wagon.rto=60000' ARTIFACT_RETENTION_DAYS=3 JDK_DISTRIBUTION=corretto GITHUB_ACTION_PATH=/home/github/68311819544/actions/apache-pulsar/./.github/actions/ssh-access JOB_NAME='CI - Integration - Messaging' PULSAR_TEST_IMAGE_NAME=apachepulsar/java-test-image:latest DEVELOCITY_ACCESS_KEY= CI_JDK_MAJOR_VERSION= NETTY_LEAK_DETECTION= NETTY_LEAK_DUMP_DIR=${GITHUB_WORKSPACE}/target/netty-leak-dumps "${CURRENT_ENV[@]}" INPUT_ACTION=wait INPUT_LIMIT-ACCESS-TO-ACTOR=false INPUT_LIMIT-ACCESS-TO-USERS= INPUT_SECURE-ACCESS=true INPUT_TIMEOUT=300 \
echo true)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=19 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=apache/pulsar GITHUB_ACTIONS=true GITHUB_ACTOR=lhotari GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/pulsar GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=08d89a2ea1a2a566197f5db004881c4e222bb3ac GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Pulsar CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 MAVEN_OPTS='-Xss1500k -Xmx2048m -XX:+UnlockDiagnosticVMOptions -XX:+IgnoreUnrecognizedVMOptions -XX:GCLockerRetryAllocationCount=100 -Daether.connector.http.reuseConnections=false -Daether.connector.requestTimeout=60000 -Dhttp.keepAlive=false -Dmaven.wagon.http.pool=false -Dmaven.wagon.http.retryHandler.class=standard -Dmaven.wagon.http.retryHandler.count=3 -Dmaven.wagon.http.retryHandler.requestSentEnabled=true -Dmaven.wagon.http.serviceUnavailableRetryStrategy.class=standard -Dmaven.wagon.rto=60000' ARTIFACT_RETENTION_DAYS=3 JDK_DISTRIBUTION=corretto GITHUB_ACTION_PATH=/home/github/68311819544/actions/apache-pulsar/./.github/actions/ssh-access JOB_NAME='CI - Integration - Messaging' PULSAR_TEST_IMAGE_NAME=apachepulsar/java-test-image:latest DEVELOCITY_ACCESS_KEY= CI_JDK_MAJOR_VERSION= NETTY_LEAK_DETECTION= NETTY_LEAK_DUMP_DIR=${GITHUB_WORKSPACE}/target/netty-leak-dumps "${CURRENT_ENV[@]}" INPUT_ACTION=wait INPUT_LIMIT-ACCESS-TO-ACTOR=false INPUT_LIMIT-ACCESS-TO-USERS= INPUT_SECURE-ACCESS=true INPUT_TIMEOUT=300 \
bash -e $ACTIONS_RUNNER_HOOK_STEP_COMPLETED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_JOB_COMPLETED" ]]; then
   echo "A job completed hook has been configured by the self-hosted runner administrator"
   echo "##[group]Run '$ACTIONS_RUNNER_HOOK_JOB_COMPLETED'"
   echo "##[endgroup]"
   bash -e $ACTIONS_RUNNER_HOOK_JOB_COMPLETED 68311819544 failed
   EXIT_CODE=$?
   if [[ $EXIT_CODE != 0 ]]; then
       echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."
       exit $EXIT_CODE
   fi
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi


if [[ $_GITHUB_JOB_STATUS != "success" ]]; then
   exit 1
fi
