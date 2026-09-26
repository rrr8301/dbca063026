#!/usr/bin/env bash
export GITHUB_WORKSPACE=/home/github/build/apache/dubbo

if [[ ! -z "$ACTIONS_RUNNER_HOOK_JOB_STARTED" ]]; then
   echo "A job started hook has been configured by the self-hosted runner administrator"
   echo "##[group]Run '$ACTIONS_RUNNER_HOOK_JOB_STARTED'"
   echo "##[endgroup]"
   bash -e $ACTIONS_RUNNER_HOOK_JOB_STARTED 65347060790 failed
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

cp /home/github/65347060790/event.json /home/github/workflow/event.json
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=0 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=EarthChen GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/3.3 GITHUB_REF_NAME=3.3 GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/dubbo GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=2287790902efc675391b45b9907ca761c54cf4f7 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Build and Test For PR' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 FORK_COUNT=2 FAIL_FAST=0 SHOW_ERROR_DETAIL=1 VERSIONS_LIMIT=4 JACOCO_ENABLE=true CANDIDATE_VERSIONS=' spring.version:5.3.24,6.1.5; spring-boot.version:2.7.6,3.2.3; ' MAVEN_OPTS='-XX:+UseG1GC -XX:InitiatingHeapOccupancyPercent=45 -XX:+UseStringDeduplication -XX:-TieredCompilation -XX:TieredStopAtLevel=1 -Dmaven.javadoc.skip=true -Dmaven.wagon.http.retryHandler.count=5 -Dmaven.wagon.httpconnectionManager.ttlSeconds=120' MAVEN_ARGS='-e --batch-mode --no-snapshot-updates --no-transfer-progress --fail-fast' DISABLE_FILE_SYSTEM_TEST=true CURRENT_ROLE= ZOOKEEPER_VERSION=3.7.2 "${CURRENT_ENV[@]}" \
echo "$(/home/github/65347060790/helpers/eval_expression p:'(' f:success p:'(' p:')' p:')' o:'&&' p:'(' l:25 o:'>=' n:24 p:')')")
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=0 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=EarthChen GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/3.3 GITHUB_REF_NAME=3.3 GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/dubbo GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=2287790902efc675391b45b9907ca761c54cf4f7 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Build and Test For PR' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 FORK_COUNT=2 FAIL_FAST=0 SHOW_ERROR_DETAIL=1 VERSIONS_LIMIT=4 JACOCO_ENABLE=true CANDIDATE_VERSIONS=' spring.version:5.3.24,6.1.5; spring-boot.version:2.7.6,3.2.3; ' MAVEN_OPTS='-XX:+UseG1GC -XX:InitiatingHeapOccupancyPercent=45 -XX:+UseStringDeduplication -XX:-TieredCompilation -XX:TieredStopAtLevel=1 -Dmaven.javadoc.skip=true -Dmaven.wagon.http.retryHandler.count=5 -Dmaven.wagon.httpconnectionManager.ttlSeconds=120' MAVEN_ARGS='-e --batch-mode --no-snapshot-updates --no-transfer-progress --fail-fast' DISABLE_FILE_SYSTEM_TEST=true CURRENT_ROLE= ZOOKEEPER_VERSION=3.7.2 "${CURRENT_ENV[@]}" \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run 'echo "MAVEN_OPTS=--sun-misc-unsafe-memory-access=allow" >> $GITHUB_ENV'
echo "##[endgroup]"
echo 'echo "MAVEN_OPTS=--sun-misc-unsafe-memory-access=allow" >> $GITHUB_ENV' > /home/github/65347060790/steps/bugswarm_0.sh
chmod u+x /home/github/65347060790/steps/bugswarm_0.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=0 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=EarthChen GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/3.3 GITHUB_REF_NAME=3.3 GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/dubbo GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=2287790902efc675391b45b9907ca761c54cf4f7 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Build and Test For PR' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 FORK_COUNT=2 FAIL_FAST=0 SHOW_ERROR_DETAIL=1 VERSIONS_LIMIT=4 JACOCO_ENABLE=true CANDIDATE_VERSIONS=' spring.version:5.3.24,6.1.5; spring-boot.version:2.7.6,3.2.3; ' MAVEN_OPTS='-XX:+UseG1GC -XX:InitiatingHeapOccupancyPercent=45 -XX:+UseStringDeduplication -XX:-TieredCompilation -XX:TieredStopAtLevel=1 -Dmaven.javadoc.skip=true -Dmaven.wagon.http.retryHandler.count=5 -Dmaven.wagon.httpconnectionManager.ttlSeconds=120' MAVEN_ARGS='-e --batch-mode --no-snapshot-updates --no-transfer-progress --fail-fast' DISABLE_FILE_SYSTEM_TEST=true CURRENT_ROLE= ZOOKEEPER_VERSION=3.7.2 "${CURRENT_ENV[@]}" \
bash -e /home/github/65347060790/steps/bugswarm_0.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=0 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=EarthChen GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/3.3 GITHUB_REF_NAME=3.3 GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/dubbo GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=2287790902efc675391b45b9907ca761c54cf4f7 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Build and Test For PR' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 FORK_COUNT=2 FAIL_FAST=0 SHOW_ERROR_DETAIL=1 VERSIONS_LIMIT=4 JACOCO_ENABLE=true CANDIDATE_VERSIONS=' spring.version:5.3.24,6.1.5; spring-boot.version:2.7.6,3.2.3; ' MAVEN_OPTS='-XX:+UseG1GC -XX:InitiatingHeapOccupancyPercent=45 -XX:+UseStringDeduplication -XX:-TieredCompilation -XX:TieredStopAtLevel=1 -Dmaven.javadoc.skip=true -Dmaven.wagon.http.retryHandler.count=5 -Dmaven.wagon.httpconnectionManager.ttlSeconds=120' MAVEN_ARGS='-e --batch-mode --no-snapshot-updates --no-transfer-progress --fail-fast' DISABLE_FILE_SYSTEM_TEST=true CURRENT_ROLE= ZOOKEEPER_VERSION=3.7.2 "${CURRENT_ENV[@]}" \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=0 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=EarthChen GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/3.3 GITHUB_REF_NAME=3.3 GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/dubbo GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=2287790902efc675391b45b9907ca761c54cf4f7 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Build and Test For PR' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 FORK_COUNT=2 FAIL_FAST=0 SHOW_ERROR_DETAIL=1 VERSIONS_LIMIT=4 JACOCO_ENABLE=true CANDIDATE_VERSIONS=' spring.version:5.3.24,6.1.5; spring-boot.version:2.7.6,3.2.3; ' MAVEN_OPTS='-XX:+UseG1GC -XX:InitiatingHeapOccupancyPercent=45 -XX:+UseStringDeduplication -XX:-TieredCompilation -XX:TieredStopAtLevel=1 -Dmaven.javadoc.skip=true -Dmaven.wagon.http.retryHandler.count=5 -Dmaven.wagon.httpconnectionManager.ttlSeconds=120' MAVEN_ARGS='-e --batch-mode --no-snapshot-updates --no-transfer-progress --fail-fast' DISABLE_FILE_SYSTEM_TEST=true CURRENT_ROLE= ZOOKEEPER_VERSION=3.7.2 "${CURRENT_ENV[@]}" \
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=2 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=actions/setup-java GITHUB_ACTIONS=true GITHUB_ACTOR=EarthChen GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/3.3 GITHUB_REF_NAME=3.3 GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/dubbo GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=2287790902efc675391b45b9907ca761c54cf4f7 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Build and Test For PR' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 FORK_COUNT=2 FAIL_FAST=0 SHOW_ERROR_DETAIL=1 VERSIONS_LIMIT=4 JACOCO_ENABLE=true CANDIDATE_VERSIONS=' spring.version:5.3.24,6.1.5; spring-boot.version:2.7.6,3.2.3; ' MAVEN_OPTS='-XX:+UseG1GC -XX:InitiatingHeapOccupancyPercent=45 -XX:+UseStringDeduplication -XX:-TieredCompilation -XX:TieredStopAtLevel=1 -Dmaven.javadoc.skip=true -Dmaven.wagon.http.retryHandler.count=5 -Dmaven.wagon.httpconnectionManager.ttlSeconds=120' MAVEN_ARGS='-e --batch-mode --no-snapshot-updates --no-transfer-progress --fail-fast' GITHUB_ACTION_PATH=/home/github/65347060790/actions/actions-setup-java@v4 DISABLE_FILE_SYSTEM_TEST=true CURRENT_ROLE= ZOOKEEPER_VERSION=3.7.2 "${CURRENT_ENV[@]}" INPUT_DISTRIBUTION=zulu INPUT_JAVA-VERSION=25 INPUT_OVERWRITE-SETTINGS=False INPUT_TOKEN= INPUT_JAVA-PACKAGE=jdk INPUT_CHECK-LATEST=false INPUT_SERVER-ID=github INPUT_SERVER-USERNAME=GITHUB_ACTOR INPUT_SERVER-PASSWORD=GITHUB_TOKEN INPUT_JOB-STATUS="${_GITHUB_JOB_STATUS}" \
echo $(test "$_GITHUB_JOB_STATUS" = "success" && echo true || echo false))
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=2 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=actions/setup-java GITHUB_ACTIONS=true GITHUB_ACTOR=EarthChen GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/3.3 GITHUB_REF_NAME=3.3 GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/dubbo GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=2287790902efc675391b45b9907ca761c54cf4f7 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Build and Test For PR' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 FORK_COUNT=2 FAIL_FAST=0 SHOW_ERROR_DETAIL=1 VERSIONS_LIMIT=4 JACOCO_ENABLE=true CANDIDATE_VERSIONS=' spring.version:5.3.24,6.1.5; spring-boot.version:2.7.6,3.2.3; ' MAVEN_OPTS='-XX:+UseG1GC -XX:InitiatingHeapOccupancyPercent=45 -XX:+UseStringDeduplication -XX:-TieredCompilation -XX:TieredStopAtLevel=1 -Dmaven.javadoc.skip=true -Dmaven.wagon.http.retryHandler.count=5 -Dmaven.wagon.httpconnectionManager.ttlSeconds=120' MAVEN_ARGS='-e --batch-mode --no-snapshot-updates --no-transfer-progress --fail-fast' GITHUB_ACTION_PATH=/home/github/65347060790/actions/actions-setup-java@v4 DISABLE_FILE_SYSTEM_TEST=true CURRENT_ROLE= ZOOKEEPER_VERSION=3.7.2 "${CURRENT_ENV[@]}" INPUT_DISTRIBUTION=zulu INPUT_JAVA-VERSION=25 INPUT_OVERWRITE-SETTINGS=False INPUT_TOKEN= INPUT_JAVA-PACKAGE=jdk INPUT_CHECK-LATEST=false INPUT_SERVER-ID=github INPUT_SERVER-USERNAME=GITHUB_ACTOR INPUT_SERVER-PASSWORD=GITHUB_TOKEN INPUT_JOB-STATUS="${_GITHUB_JOB_STATUS}" \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run actions/setup-java@v4
echo "##[endgroup]"
echo node /home/github/65347060790/actions/actions-setup-java@v4/dist/setup/index.js > /home/github/65347060790/steps/bugswarm_cmd.sh
chmod u+x /home/github/65347060790/steps/bugswarm_cmd.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=2 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=actions/setup-java GITHUB_ACTIONS=true GITHUB_ACTOR=EarthChen GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/3.3 GITHUB_REF_NAME=3.3 GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/dubbo GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=2287790902efc675391b45b9907ca761c54cf4f7 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Build and Test For PR' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 FORK_COUNT=2 FAIL_FAST=0 SHOW_ERROR_DETAIL=1 VERSIONS_LIMIT=4 JACOCO_ENABLE=true CANDIDATE_VERSIONS=' spring.version:5.3.24,6.1.5; spring-boot.version:2.7.6,3.2.3; ' MAVEN_OPTS='-XX:+UseG1GC -XX:InitiatingHeapOccupancyPercent=45 -XX:+UseStringDeduplication -XX:-TieredCompilation -XX:TieredStopAtLevel=1 -Dmaven.javadoc.skip=true -Dmaven.wagon.http.retryHandler.count=5 -Dmaven.wagon.httpconnectionManager.ttlSeconds=120' MAVEN_ARGS='-e --batch-mode --no-snapshot-updates --no-transfer-progress --fail-fast' GITHUB_ACTION_PATH=/home/github/65347060790/actions/actions-setup-java@v4 DISABLE_FILE_SYSTEM_TEST=true CURRENT_ROLE= ZOOKEEPER_VERSION=3.7.2 "${CURRENT_ENV[@]}" INPUT_DISTRIBUTION=zulu INPUT_JAVA-VERSION=25 INPUT_OVERWRITE-SETTINGS=False INPUT_TOKEN= INPUT_JAVA-PACKAGE=jdk INPUT_CHECK-LATEST=false INPUT_SERVER-ID=github INPUT_SERVER-USERNAME=GITHUB_ACTOR INPUT_SERVER-PASSWORD=GITHUB_TOKEN INPUT_JOB-STATUS="${_GITHUB_JOB_STATUS}" \
bash -e /home/github/65347060790/steps/bugswarm_cmd.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=2 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=actions/setup-java GITHUB_ACTIONS=true GITHUB_ACTOR=EarthChen GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/3.3 GITHUB_REF_NAME=3.3 GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/dubbo GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=2287790902efc675391b45b9907ca761c54cf4f7 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Build and Test For PR' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 FORK_COUNT=2 FAIL_FAST=0 SHOW_ERROR_DETAIL=1 VERSIONS_LIMIT=4 JACOCO_ENABLE=true CANDIDATE_VERSIONS=' spring.version:5.3.24,6.1.5; spring-boot.version:2.7.6,3.2.3; ' MAVEN_OPTS='-XX:+UseG1GC -XX:InitiatingHeapOccupancyPercent=45 -XX:+UseStringDeduplication -XX:-TieredCompilation -XX:TieredStopAtLevel=1 -Dmaven.javadoc.skip=true -Dmaven.wagon.http.retryHandler.count=5 -Dmaven.wagon.httpconnectionManager.ttlSeconds=120' MAVEN_ARGS='-e --batch-mode --no-snapshot-updates --no-transfer-progress --fail-fast' GITHUB_ACTION_PATH=/home/github/65347060790/actions/actions-setup-java@v4 DISABLE_FILE_SYSTEM_TEST=true CURRENT_ROLE= ZOOKEEPER_VERSION=3.7.2 "${CURRENT_ENV[@]}" INPUT_DISTRIBUTION=zulu INPUT_JAVA-VERSION=25 INPUT_OVERWRITE-SETTINGS=False INPUT_TOKEN= INPUT_JAVA-PACKAGE=jdk INPUT_CHECK-LATEST=false INPUT_SERVER-ID=github INPUT_SERVER-USERNAME=GITHUB_ACTOR INPUT_SERVER-PASSWORD=GITHUB_TOKEN INPUT_JOB-STATUS="${_GITHUB_JOB_STATUS}" \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=2 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=actions/setup-java GITHUB_ACTIONS=true GITHUB_ACTOR=EarthChen GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/3.3 GITHUB_REF_NAME=3.3 GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/dubbo GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=2287790902efc675391b45b9907ca761c54cf4f7 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Build and Test For PR' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 FORK_COUNT=2 FAIL_FAST=0 SHOW_ERROR_DETAIL=1 VERSIONS_LIMIT=4 JACOCO_ENABLE=true CANDIDATE_VERSIONS=' spring.version:5.3.24,6.1.5; spring-boot.version:2.7.6,3.2.3; ' MAVEN_OPTS='-XX:+UseG1GC -XX:InitiatingHeapOccupancyPercent=45 -XX:+UseStringDeduplication -XX:-TieredCompilation -XX:TieredStopAtLevel=1 -Dmaven.javadoc.skip=true -Dmaven.wagon.http.retryHandler.count=5 -Dmaven.wagon.httpconnectionManager.ttlSeconds=120' MAVEN_ARGS='-e --batch-mode --no-snapshot-updates --no-transfer-progress --fail-fast' GITHUB_ACTION_PATH=/home/github/65347060790/actions/actions-setup-java@v4 DISABLE_FILE_SYSTEM_TEST=true CURRENT_ROLE= ZOOKEEPER_VERSION=3.7.2 "${CURRENT_ENV[@]}" INPUT_DISTRIBUTION=zulu INPUT_JAVA-VERSION=25 INPUT_OVERWRITE-SETTINGS=False INPUT_TOKEN= INPUT_JAVA-PACKAGE=jdk INPUT_CHECK-LATEST=false INPUT_SERVER-ID=github INPUT_SERVER-USERNAME=GITHUB_ACTOR INPUT_SERVER-PASSWORD=GITHUB_TOKEN INPUT_JOB-STATUS="${_GITHUB_JOB_STATUS}" \
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=3 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=EarthChen GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/3.3 GITHUB_REF_NAME=3.3 GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/dubbo GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=2287790902efc675391b45b9907ca761c54cf4f7 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Build and Test For PR' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 FORK_COUNT=2 FAIL_FAST=0 SHOW_ERROR_DETAIL=1 VERSIONS_LIMIT=4 JACOCO_ENABLE=true CANDIDATE_VERSIONS=' spring.version:5.3.24,6.1.5; spring-boot.version:2.7.6,3.2.3; ' MAVEN_OPTS='-XX:+UseG1GC -XX:InitiatingHeapOccupancyPercent=45 -XX:+UseStringDeduplication -XX:-TieredCompilation -XX:TieredStopAtLevel=1 -Dmaven.javadoc.skip=true -Dmaven.wagon.http.retryHandler.count=5 -Dmaven.wagon.httpconnectionManager.ttlSeconds=120' MAVEN_ARGS='-e --batch-mode --no-snapshot-updates --no-transfer-progress --fail-fast' DISABLE_FILE_SYSTEM_TEST=true CURRENT_ROLE= ZOOKEEPER_VERSION=3.7.2 "${CURRENT_ENV[@]}" \
echo $(test "$_GITHUB_JOB_STATUS" = "success" && echo true || echo false))
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=3 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=EarthChen GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/3.3 GITHUB_REF_NAME=3.3 GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/dubbo GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=2287790902efc675391b45b9907ca761c54cf4f7 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Build and Test For PR' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 FORK_COUNT=2 FAIL_FAST=0 SHOW_ERROR_DETAIL=1 VERSIONS_LIMIT=4 JACOCO_ENABLE=true CANDIDATE_VERSIONS=' spring.version:5.3.24,6.1.5; spring-boot.version:2.7.6,3.2.3; ' MAVEN_OPTS='-XX:+UseG1GC -XX:InitiatingHeapOccupancyPercent=45 -XX:+UseStringDeduplication -XX:-TieredCompilation -XX:TieredStopAtLevel=1 -Dmaven.javadoc.skip=true -Dmaven.wagon.http.retryHandler.count=5 -Dmaven.wagon.httpconnectionManager.ttlSeconds=120' MAVEN_ARGS='-e --batch-mode --no-snapshot-updates --no-transfer-progress --fail-fast' DISABLE_FILE_SYSTEM_TEST=true CURRENT_ROLE= ZOOKEEPER_VERSION=3.7.2 "${CURRENT_ENV[@]}" \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run 'echo "TODAY=$(date +'"'"'%Y%m%d'"'"')" >> $GITHUB_ENV'
echo "##[endgroup]"
echo 'echo "TODAY=$(date +'"'"'%Y%m%d'"'"')" >> $GITHUB_ENV' > /home/github/65347060790/steps/bugswarm_3.sh
chmod u+x /home/github/65347060790/steps/bugswarm_3.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=3 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=EarthChen GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/3.3 GITHUB_REF_NAME=3.3 GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/dubbo GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=2287790902efc675391b45b9907ca761c54cf4f7 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Build and Test For PR' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 FORK_COUNT=2 FAIL_FAST=0 SHOW_ERROR_DETAIL=1 VERSIONS_LIMIT=4 JACOCO_ENABLE=true CANDIDATE_VERSIONS=' spring.version:5.3.24,6.1.5; spring-boot.version:2.7.6,3.2.3; ' MAVEN_OPTS='-XX:+UseG1GC -XX:InitiatingHeapOccupancyPercent=45 -XX:+UseStringDeduplication -XX:-TieredCompilation -XX:TieredStopAtLevel=1 -Dmaven.javadoc.skip=true -Dmaven.wagon.http.retryHandler.count=5 -Dmaven.wagon.httpconnectionManager.ttlSeconds=120' MAVEN_ARGS='-e --batch-mode --no-snapshot-updates --no-transfer-progress --fail-fast' DISABLE_FILE_SYSTEM_TEST=true CURRENT_ROLE= ZOOKEEPER_VERSION=3.7.2 "${CURRENT_ENV[@]}" \
bash -e /home/github/65347060790/steps/bugswarm_3.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=3 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=EarthChen GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/3.3 GITHUB_REF_NAME=3.3 GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/dubbo GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=2287790902efc675391b45b9907ca761c54cf4f7 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Build and Test For PR' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 FORK_COUNT=2 FAIL_FAST=0 SHOW_ERROR_DETAIL=1 VERSIONS_LIMIT=4 JACOCO_ENABLE=true CANDIDATE_VERSIONS=' spring.version:5.3.24,6.1.5; spring-boot.version:2.7.6,3.2.3; ' MAVEN_OPTS='-XX:+UseG1GC -XX:InitiatingHeapOccupancyPercent=45 -XX:+UseStringDeduplication -XX:-TieredCompilation -XX:TieredStopAtLevel=1 -Dmaven.javadoc.skip=true -Dmaven.wagon.http.retryHandler.count=5 -Dmaven.wagon.httpconnectionManager.ttlSeconds=120' MAVEN_ARGS='-e --batch-mode --no-snapshot-updates --no-transfer-progress --fail-fast' DISABLE_FILE_SYSTEM_TEST=true CURRENT_ROLE= ZOOKEEPER_VERSION=3.7.2 "${CURRENT_ENV[@]}" \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=3 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=EarthChen GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/3.3 GITHUB_REF_NAME=3.3 GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/dubbo GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=2287790902efc675391b45b9907ca761c54cf4f7 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Build and Test For PR' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 FORK_COUNT=2 FAIL_FAST=0 SHOW_ERROR_DETAIL=1 VERSIONS_LIMIT=4 JACOCO_ENABLE=true CANDIDATE_VERSIONS=' spring.version:5.3.24,6.1.5; spring-boot.version:2.7.6,3.2.3; ' MAVEN_OPTS='-XX:+UseG1GC -XX:InitiatingHeapOccupancyPercent=45 -XX:+UseStringDeduplication -XX:-TieredCompilation -XX:TieredStopAtLevel=1 -Dmaven.javadoc.skip=true -Dmaven.wagon.http.retryHandler.count=5 -Dmaven.wagon.httpconnectionManager.ttlSeconds=120' MAVEN_ARGS='-e --batch-mode --no-snapshot-updates --no-transfer-progress --fail-fast' DISABLE_FILE_SYSTEM_TEST=true CURRENT_ROLE= ZOOKEEPER_VERSION=3.7.2 "${CURRENT_ENV[@]}" \
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=6 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=EarthChen GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/3.3 GITHUB_REF_NAME=3.3 GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/dubbo GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=2287790902efc675391b45b9907ca761c54cf4f7 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Build and Test For PR' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 FORK_COUNT=2 FAIL_FAST=0 SHOW_ERROR_DETAIL=1 VERSIONS_LIMIT=4 JACOCO_ENABLE=true CANDIDATE_VERSIONS=' spring.version:5.3.24,6.1.5; spring-boot.version:2.7.6,3.2.3; ' MAVEN_OPTS='-XX:+UseG1GC -XX:InitiatingHeapOccupancyPercent=45 -XX:+UseStringDeduplication -XX:-TieredCompilation -XX:TieredStopAtLevel=1 -Dmaven.javadoc.skip=true -Dmaven.wagon.http.retryHandler.count=5 -Dmaven.wagon.httpconnectionManager.ttlSeconds=120' MAVEN_ARGS='-e --batch-mode --no-snapshot-updates --no-transfer-progress --fail-fast' DISABLE_FILE_SYSTEM_TEST=true CURRENT_ROLE= ZOOKEEPER_VERSION=3.7.2 "${CURRENT_ENV[@]}" \
echo "$(/home/github/65347060790/helpers/eval_expression p:'(' f:success p:'(' p:')' p:')' o:'&&' p:'(' l:25 o:== s:8 p:')')")
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=6 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=EarthChen GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/3.3 GITHUB_REF_NAME=3.3 GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/dubbo GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=2287790902efc675391b45b9907ca761c54cf4f7 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Build and Test For PR' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 FORK_COUNT=2 FAIL_FAST=0 SHOW_ERROR_DETAIL=1 VERSIONS_LIMIT=4 JACOCO_ENABLE=true CANDIDATE_VERSIONS=' spring.version:5.3.24,6.1.5; spring-boot.version:2.7.6,3.2.3; ' MAVEN_OPTS='-XX:+UseG1GC -XX:InitiatingHeapOccupancyPercent=45 -XX:+UseStringDeduplication -XX:-TieredCompilation -XX:TieredStopAtLevel=1 -Dmaven.javadoc.skip=true -Dmaven.wagon.http.retryHandler.count=5 -Dmaven.wagon.httpconnectionManager.ttlSeconds=120' MAVEN_ARGS='-e --batch-mode --no-snapshot-updates --no-transfer-progress --fail-fast' DISABLE_FILE_SYSTEM_TEST=true CURRENT_ROLE= ZOOKEEPER_VERSION=3.7.2 "${CURRENT_ENV[@]}" \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run 'set -o pipefail'
echo "##[endgroup]"
echo 'set -o pipefail
./mvnw '"$(test -v "CURRENT_ENV_MAP[MAVEN_ARGS]" && echo "${CURRENT_ENV_MAP[MAVEN_ARGS]}" || echo '-e --batch-mode --no-snapshot-updates --no-transfer-progress --fail-fast')"' clean test verify -Pjacoco,'"'"'!jdk15ge-add-open'"'"',skip-spotless -DtrimStackTrace=false -Dmaven.test.skip=false -Dcheckstyle.skip=false -Dcheckstyle_unix.skip=false -Drat.skip=false -DembeddedZookeeperPath='${GITHUB_WORKSPACE}'/.tmp/zookeeper 2>&1 | tee >(grep -n -B 1 -A 200 "FAILURE! -- in" > test_errors.log)
' > /home/github/65347060790/steps/bugswarm_6.sh
chmod u+x /home/github/65347060790/steps/bugswarm_6.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=6 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=EarthChen GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/3.3 GITHUB_REF_NAME=3.3 GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/dubbo GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=2287790902efc675391b45b9907ca761c54cf4f7 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Build and Test For PR' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 FORK_COUNT=2 FAIL_FAST=0 SHOW_ERROR_DETAIL=1 VERSIONS_LIMIT=4 JACOCO_ENABLE=true CANDIDATE_VERSIONS=' spring.version:5.3.24,6.1.5; spring-boot.version:2.7.6,3.2.3; ' MAVEN_OPTS='-XX:+UseG1GC -XX:InitiatingHeapOccupancyPercent=45 -XX:+UseStringDeduplication -XX:-TieredCompilation -XX:TieredStopAtLevel=1 -Dmaven.javadoc.skip=true -Dmaven.wagon.http.retryHandler.count=5 -Dmaven.wagon.httpconnectionManager.ttlSeconds=120' MAVEN_ARGS='-e --batch-mode --no-snapshot-updates --no-transfer-progress --fail-fast' DISABLE_FILE_SYSTEM_TEST=true CURRENT_ROLE= ZOOKEEPER_VERSION=3.7.2 "${CURRENT_ENV[@]}" \
bash -e /home/github/65347060790/steps/bugswarm_6.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=6 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=EarthChen GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/3.3 GITHUB_REF_NAME=3.3 GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/dubbo GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=2287790902efc675391b45b9907ca761c54cf4f7 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Build and Test For PR' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 FORK_COUNT=2 FAIL_FAST=0 SHOW_ERROR_DETAIL=1 VERSIONS_LIMIT=4 JACOCO_ENABLE=true CANDIDATE_VERSIONS=' spring.version:5.3.24,6.1.5; spring-boot.version:2.7.6,3.2.3; ' MAVEN_OPTS='-XX:+UseG1GC -XX:InitiatingHeapOccupancyPercent=45 -XX:+UseStringDeduplication -XX:-TieredCompilation -XX:TieredStopAtLevel=1 -Dmaven.javadoc.skip=true -Dmaven.wagon.http.retryHandler.count=5 -Dmaven.wagon.httpconnectionManager.ttlSeconds=120' MAVEN_ARGS='-e --batch-mode --no-snapshot-updates --no-transfer-progress --fail-fast' DISABLE_FILE_SYSTEM_TEST=true CURRENT_ROLE= ZOOKEEPER_VERSION=3.7.2 "${CURRENT_ENV[@]}" \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=6 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=EarthChen GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/3.3 GITHUB_REF_NAME=3.3 GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/dubbo GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=2287790902efc675391b45b9907ca761c54cf4f7 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Build and Test For PR' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 FORK_COUNT=2 FAIL_FAST=0 SHOW_ERROR_DETAIL=1 VERSIONS_LIMIT=4 JACOCO_ENABLE=true CANDIDATE_VERSIONS=' spring.version:5.3.24,6.1.5; spring-boot.version:2.7.6,3.2.3; ' MAVEN_OPTS='-XX:+UseG1GC -XX:InitiatingHeapOccupancyPercent=45 -XX:+UseStringDeduplication -XX:-TieredCompilation -XX:TieredStopAtLevel=1 -Dmaven.javadoc.skip=true -Dmaven.wagon.http.retryHandler.count=5 -Dmaven.wagon.httpconnectionManager.ttlSeconds=120' MAVEN_ARGS='-e --batch-mode --no-snapshot-updates --no-transfer-progress --fail-fast' DISABLE_FILE_SYSTEM_TEST=true CURRENT_ROLE= ZOOKEEPER_VERSION=3.7.2 "${CURRENT_ENV[@]}" \
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=7 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=EarthChen GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/3.3 GITHUB_REF_NAME=3.3 GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/dubbo GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=2287790902efc675391b45b9907ca761c54cf4f7 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Build and Test For PR' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 FORK_COUNT=2 FAIL_FAST=0 SHOW_ERROR_DETAIL=1 VERSIONS_LIMIT=4 JACOCO_ENABLE=true CANDIDATE_VERSIONS=' spring.version:5.3.24,6.1.5; spring-boot.version:2.7.6,3.2.3; ' MAVEN_OPTS='-XX:+UseG1GC -XX:InitiatingHeapOccupancyPercent=45 -XX:+UseStringDeduplication -XX:-TieredCompilation -XX:TieredStopAtLevel=1 -Dmaven.javadoc.skip=true -Dmaven.wagon.http.retryHandler.count=5 -Dmaven.wagon.httpconnectionManager.ttlSeconds=120' MAVEN_ARGS='-e --batch-mode --no-snapshot-updates --no-transfer-progress --fail-fast' DISABLE_FILE_SYSTEM_TEST=true CURRENT_ROLE= ZOOKEEPER_VERSION=3.7.2 "${CURRENT_ENV[@]}" \
echo "$(/home/github/65347060790/helpers/eval_expression p:'(' f:success p:'(' p:')' p:')' o:'&&' p:'(' l:25 o:'!=' s:8 p:')')")
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=7 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=EarthChen GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/3.3 GITHUB_REF_NAME=3.3 GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/dubbo GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=2287790902efc675391b45b9907ca761c54cf4f7 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Build and Test For PR' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 FORK_COUNT=2 FAIL_FAST=0 SHOW_ERROR_DETAIL=1 VERSIONS_LIMIT=4 JACOCO_ENABLE=true CANDIDATE_VERSIONS=' spring.version:5.3.24,6.1.5; spring-boot.version:2.7.6,3.2.3; ' MAVEN_OPTS='-XX:+UseG1GC -XX:InitiatingHeapOccupancyPercent=45 -XX:+UseStringDeduplication -XX:-TieredCompilation -XX:TieredStopAtLevel=1 -Dmaven.javadoc.skip=true -Dmaven.wagon.http.retryHandler.count=5 -Dmaven.wagon.httpconnectionManager.ttlSeconds=120' MAVEN_ARGS='-e --batch-mode --no-snapshot-updates --no-transfer-progress --fail-fast' DISABLE_FILE_SYSTEM_TEST=true CURRENT_ROLE= ZOOKEEPER_VERSION=3.7.2 "${CURRENT_ENV[@]}" \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run 'set -o pipefail'
echo "##[endgroup]"
echo 'set -o pipefail
./mvnw '"$(test -v "CURRENT_ENV_MAP[MAVEN_ARGS]" && echo "${CURRENT_ENV_MAP[MAVEN_ARGS]}" || echo '-e --batch-mode --no-snapshot-updates --no-transfer-progress --fail-fast')"' clean test verify -Pjacoco,jdk15ge-simple,'"'"'!jdk15ge-add-open'"'"',skip-spotless -DtrimStackTrace=false -Dmaven.test.skip=false -Dcheckstyle.skip=false -Dcheckstyle_unix.skip=false -Drat.skip=false -DembeddedZookeeperPath='${GITHUB_WORKSPACE}'/.tmp/zookeeper 2>&1 | tee >(grep -n -B 1 -A 200 "FAILURE! -- in" > test_errors.log)
' > /home/github/65347060790/steps/bugswarm_7.sh
chmod u+x /home/github/65347060790/steps/bugswarm_7.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=7 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=EarthChen GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/3.3 GITHUB_REF_NAME=3.3 GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/dubbo GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=2287790902efc675391b45b9907ca761c54cf4f7 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Build and Test For PR' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 FORK_COUNT=2 FAIL_FAST=0 SHOW_ERROR_DETAIL=1 VERSIONS_LIMIT=4 JACOCO_ENABLE=true CANDIDATE_VERSIONS=' spring.version:5.3.24,6.1.5; spring-boot.version:2.7.6,3.2.3; ' MAVEN_OPTS='-XX:+UseG1GC -XX:InitiatingHeapOccupancyPercent=45 -XX:+UseStringDeduplication -XX:-TieredCompilation -XX:TieredStopAtLevel=1 -Dmaven.javadoc.skip=true -Dmaven.wagon.http.retryHandler.count=5 -Dmaven.wagon.httpconnectionManager.ttlSeconds=120' MAVEN_ARGS='-e --batch-mode --no-snapshot-updates --no-transfer-progress --fail-fast' DISABLE_FILE_SYSTEM_TEST=true CURRENT_ROLE= ZOOKEEPER_VERSION=3.7.2 "${CURRENT_ENV[@]}" \
bash -e /home/github/65347060790/steps/bugswarm_7.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=7 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=EarthChen GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/3.3 GITHUB_REF_NAME=3.3 GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/dubbo GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=2287790902efc675391b45b9907ca761c54cf4f7 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Build and Test For PR' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 FORK_COUNT=2 FAIL_FAST=0 SHOW_ERROR_DETAIL=1 VERSIONS_LIMIT=4 JACOCO_ENABLE=true CANDIDATE_VERSIONS=' spring.version:5.3.24,6.1.5; spring-boot.version:2.7.6,3.2.3; ' MAVEN_OPTS='-XX:+UseG1GC -XX:InitiatingHeapOccupancyPercent=45 -XX:+UseStringDeduplication -XX:-TieredCompilation -XX:TieredStopAtLevel=1 -Dmaven.javadoc.skip=true -Dmaven.wagon.http.retryHandler.count=5 -Dmaven.wagon.httpconnectionManager.ttlSeconds=120' MAVEN_ARGS='-e --batch-mode --no-snapshot-updates --no-transfer-progress --fail-fast' DISABLE_FILE_SYSTEM_TEST=true CURRENT_ROLE= ZOOKEEPER_VERSION=3.7.2 "${CURRENT_ENV[@]}" \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=7 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=EarthChen GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/3.3 GITHUB_REF_NAME=3.3 GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/dubbo GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=2287790902efc675391b45b9907ca761c54cf4f7 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Build and Test For PR' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 FORK_COUNT=2 FAIL_FAST=0 SHOW_ERROR_DETAIL=1 VERSIONS_LIMIT=4 JACOCO_ENABLE=true CANDIDATE_VERSIONS=' spring.version:5.3.24,6.1.5; spring-boot.version:2.7.6,3.2.3; ' MAVEN_OPTS='-XX:+UseG1GC -XX:InitiatingHeapOccupancyPercent=45 -XX:+UseStringDeduplication -XX:-TieredCompilation -XX:TieredStopAtLevel=1 -Dmaven.javadoc.skip=true -Dmaven.wagon.http.retryHandler.count=5 -Dmaven.wagon.httpconnectionManager.ttlSeconds=120' MAVEN_ARGS='-e --batch-mode --no-snapshot-updates --no-transfer-progress --fail-fast' DISABLE_FILE_SYSTEM_TEST=true CURRENT_ROLE= ZOOKEEPER_VERSION=3.7.2 "${CURRENT_ENV[@]}" \
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=8 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=EarthChen GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/3.3 GITHUB_REF_NAME=3.3 GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/dubbo GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=2287790902efc675391b45b9907ca761c54cf4f7 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Build and Test For PR' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 FORK_COUNT=2 FAIL_FAST=0 SHOW_ERROR_DETAIL=1 VERSIONS_LIMIT=4 JACOCO_ENABLE=true CANDIDATE_VERSIONS=' spring.version:5.3.24,6.1.5; spring-boot.version:2.7.6,3.2.3; ' MAVEN_OPTS='-XX:+UseG1GC -XX:InitiatingHeapOccupancyPercent=45 -XX:+UseStringDeduplication -XX:-TieredCompilation -XX:TieredStopAtLevel=1 -Dmaven.javadoc.skip=true -Dmaven.wagon.http.retryHandler.count=5 -Dmaven.wagon.httpconnectionManager.ttlSeconds=120' MAVEN_ARGS='-e --batch-mode --no-snapshot-updates --no-transfer-progress --fail-fast' DISABLE_FILE_SYSTEM_TEST=true CURRENT_ROLE= ZOOKEEPER_VERSION=3.7.2 "${CURRENT_ENV[@]}" \
echo "$(/home/github/65347060790/helpers/eval_expression p:'(' f:failure p:'(' p:')' p:')')")
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=8 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=EarthChen GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/3.3 GITHUB_REF_NAME=3.3 GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/dubbo GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=2287790902efc675391b45b9907ca761c54cf4f7 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Build and Test For PR' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 FORK_COUNT=2 FAIL_FAST=0 SHOW_ERROR_DETAIL=1 VERSIONS_LIMIT=4 JACOCO_ENABLE=true CANDIDATE_VERSIONS=' spring.version:5.3.24,6.1.5; spring-boot.version:2.7.6,3.2.3; ' MAVEN_OPTS='-XX:+UseG1GC -XX:InitiatingHeapOccupancyPercent=45 -XX:+UseStringDeduplication -XX:-TieredCompilation -XX:TieredStopAtLevel=1 -Dmaven.javadoc.skip=true -Dmaven.wagon.http.retryHandler.count=5 -Dmaven.wagon.httpconnectionManager.ttlSeconds=120' MAVEN_ARGS='-e --batch-mode --no-snapshot-updates --no-transfer-progress --fail-fast' DISABLE_FILE_SYSTEM_TEST=true CURRENT_ROLE= ZOOKEEPER_VERSION=3.7.2 "${CURRENT_ENV[@]}" \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run 'cat test_errors.log'
echo "##[endgroup]"
echo 'cat test_errors.log' > /home/github/65347060790/steps/bugswarm_8.sh
chmod u+x /home/github/65347060790/steps/bugswarm_8.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=8 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=EarthChen GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/3.3 GITHUB_REF_NAME=3.3 GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/dubbo GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=2287790902efc675391b45b9907ca761c54cf4f7 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Build and Test For PR' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 FORK_COUNT=2 FAIL_FAST=0 SHOW_ERROR_DETAIL=1 VERSIONS_LIMIT=4 JACOCO_ENABLE=true CANDIDATE_VERSIONS=' spring.version:5.3.24,6.1.5; spring-boot.version:2.7.6,3.2.3; ' MAVEN_OPTS='-XX:+UseG1GC -XX:InitiatingHeapOccupancyPercent=45 -XX:+UseStringDeduplication -XX:-TieredCompilation -XX:TieredStopAtLevel=1 -Dmaven.javadoc.skip=true -Dmaven.wagon.http.retryHandler.count=5 -Dmaven.wagon.httpconnectionManager.ttlSeconds=120' MAVEN_ARGS='-e --batch-mode --no-snapshot-updates --no-transfer-progress --fail-fast' DISABLE_FILE_SYSTEM_TEST=true CURRENT_ROLE= ZOOKEEPER_VERSION=3.7.2 "${CURRENT_ENV[@]}" \
bash -e /home/github/65347060790/steps/bugswarm_8.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=8 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=EarthChen GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/3.3 GITHUB_REF_NAME=3.3 GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/dubbo GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=2287790902efc675391b45b9907ca761c54cf4f7 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Build and Test For PR' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 FORK_COUNT=2 FAIL_FAST=0 SHOW_ERROR_DETAIL=1 VERSIONS_LIMIT=4 JACOCO_ENABLE=true CANDIDATE_VERSIONS=' spring.version:5.3.24,6.1.5; spring-boot.version:2.7.6,3.2.3; ' MAVEN_OPTS='-XX:+UseG1GC -XX:InitiatingHeapOccupancyPercent=45 -XX:+UseStringDeduplication -XX:-TieredCompilation -XX:TieredStopAtLevel=1 -Dmaven.javadoc.skip=true -Dmaven.wagon.http.retryHandler.count=5 -Dmaven.wagon.httpconnectionManager.ttlSeconds=120' MAVEN_ARGS='-e --batch-mode --no-snapshot-updates --no-transfer-progress --fail-fast' DISABLE_FILE_SYSTEM_TEST=true CURRENT_ROLE= ZOOKEEPER_VERSION=3.7.2 "${CURRENT_ENV[@]}" \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=8 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=EarthChen GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/3.3 GITHUB_REF_NAME=3.3 GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/dubbo GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=2287790902efc675391b45b9907ca761c54cf4f7 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Build and Test For PR' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 FORK_COUNT=2 FAIL_FAST=0 SHOW_ERROR_DETAIL=1 VERSIONS_LIMIT=4 JACOCO_ENABLE=true CANDIDATE_VERSIONS=' spring.version:5.3.24,6.1.5; spring-boot.version:2.7.6,3.2.3; ' MAVEN_OPTS='-XX:+UseG1GC -XX:InitiatingHeapOccupancyPercent=45 -XX:+UseStringDeduplication -XX:-TieredCompilation -XX:TieredStopAtLevel=1 -Dmaven.javadoc.skip=true -Dmaven.wagon.http.retryHandler.count=5 -Dmaven.wagon.httpconnectionManager.ttlSeconds=120' MAVEN_ARGS='-e --batch-mode --no-snapshot-updates --no-transfer-progress --fail-fast' DISABLE_FILE_SYSTEM_TEST=true CURRENT_ROLE= ZOOKEEPER_VERSION=3.7.2 "${CURRENT_ENV[@]}" \
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
   bash -e $ACTIONS_RUNNER_HOOK_JOB_COMPLETED 65347060790 failed
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
