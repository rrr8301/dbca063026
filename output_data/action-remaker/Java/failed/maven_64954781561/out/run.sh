#!/usr/bin/env bash
export GITHUB_WORKSPACE=/home/github/build/apache/maven

if [[ ! -z "$ACTIONS_RUNNER_HOOK_JOB_STARTED" ]]; then
   echo "A job started hook has been configured by the self-hosted runner administrator"
   echo "##[group]Run '$ACTIONS_RUNNER_HOOK_JOB_STARTED'"
   echo "##[endgroup]"
   bash -e $ACTIONS_RUNNER_HOOK_JOB_STARTED 64954781561 failed
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

cp /home/github/64954781561/event.json /home/github/workflow/event.json
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=0 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=actions/setup-java GITHUB_ACTIONS=true GITHUB_ACTOR=arturobernalg GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=11715 GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/11715 GITHUB_REF_NAME=11715 GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/maven GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=af2dea7e5dadb3ed02031162e88a28a6e3d7dbb8 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Java CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 MIMIR_VERSION=0.11.2 MIMIR_BASEDIR='~/.mimir' MIMIR_LOCAL='~/.mimir/local' MAVEN_OPTS='-XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=./target/java_heapdump.hprof' MVNW_REPOURL=https://maven-central.storage-download.googleapis.com/maven2 GITHUB_ACTION_PATH=/home/github/64954781561/actions/actions-setup-java@be666c2fcd27ec809703dec50e508c2fdc7f6654 "${CURRENT_ENV[@]}" INPUT_JAVA-VERSION=21 INPUT_DISTRIBUTION=temurin INPUT_OVERWRITE-SETTINGS=False INPUT_TOKEN= INPUT_JAVA-PACKAGE=jdk INPUT_CHECK-LATEST=false INPUT_SERVER-ID=github INPUT_SERVER-USERNAME=GITHUB_ACTOR INPUT_SERVER-PASSWORD=GITHUB_TOKEN INPUT_JOB-STATUS="${_GITHUB_JOB_STATUS}" \
echo $(test "$_GITHUB_JOB_STATUS" = "success" && echo true || echo false))
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=0 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=actions/setup-java GITHUB_ACTIONS=true GITHUB_ACTOR=arturobernalg GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=11715 GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/11715 GITHUB_REF_NAME=11715 GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/maven GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=af2dea7e5dadb3ed02031162e88a28a6e3d7dbb8 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Java CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 MIMIR_VERSION=0.11.2 MIMIR_BASEDIR='~/.mimir' MIMIR_LOCAL='~/.mimir/local' MAVEN_OPTS='-XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=./target/java_heapdump.hprof' MVNW_REPOURL=https://maven-central.storage-download.googleapis.com/maven2 GITHUB_ACTION_PATH=/home/github/64954781561/actions/actions-setup-java@be666c2fcd27ec809703dec50e508c2fdc7f6654 "${CURRENT_ENV[@]}" INPUT_JAVA-VERSION=21 INPUT_DISTRIBUTION=temurin INPUT_OVERWRITE-SETTINGS=False INPUT_TOKEN= INPUT_JAVA-PACKAGE=jdk INPUT_CHECK-LATEST=false INPUT_SERVER-ID=github INPUT_SERVER-USERNAME=GITHUB_ACTOR INPUT_SERVER-PASSWORD=GITHUB_TOKEN INPUT_JOB-STATUS="${_GITHUB_JOB_STATUS}" \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run actions/setup-java@be666c2fcd27ec809703dec50e508c2fdc7f6654
echo "##[endgroup]"
echo node /home/github/64954781561/actions/actions-setup-java@be666c2fcd27ec809703dec50e508c2fdc7f6654/dist/setup/index.js > /home/github/64954781561/steps/bugswarm_cmd.sh
chmod u+x /home/github/64954781561/steps/bugswarm_cmd.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=0 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=actions/setup-java GITHUB_ACTIONS=true GITHUB_ACTOR=arturobernalg GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=11715 GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/11715 GITHUB_REF_NAME=11715 GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/maven GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=af2dea7e5dadb3ed02031162e88a28a6e3d7dbb8 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Java CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 MIMIR_VERSION=0.11.2 MIMIR_BASEDIR='~/.mimir' MIMIR_LOCAL='~/.mimir/local' MAVEN_OPTS='-XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=./target/java_heapdump.hprof' MVNW_REPOURL=https://maven-central.storage-download.googleapis.com/maven2 GITHUB_ACTION_PATH=/home/github/64954781561/actions/actions-setup-java@be666c2fcd27ec809703dec50e508c2fdc7f6654 "${CURRENT_ENV[@]}" INPUT_JAVA-VERSION=21 INPUT_DISTRIBUTION=temurin INPUT_OVERWRITE-SETTINGS=False INPUT_TOKEN= INPUT_JAVA-PACKAGE=jdk INPUT_CHECK-LATEST=false INPUT_SERVER-ID=github INPUT_SERVER-USERNAME=GITHUB_ACTOR INPUT_SERVER-PASSWORD=GITHUB_TOKEN INPUT_JOB-STATUS="${_GITHUB_JOB_STATUS}" \
bash -e /home/github/64954781561/steps/bugswarm_cmd.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=0 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=actions/setup-java GITHUB_ACTIONS=true GITHUB_ACTOR=arturobernalg GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=11715 GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/11715 GITHUB_REF_NAME=11715 GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/maven GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=af2dea7e5dadb3ed02031162e88a28a6e3d7dbb8 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Java CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 MIMIR_VERSION=0.11.2 MIMIR_BASEDIR='~/.mimir' MIMIR_LOCAL='~/.mimir/local' MAVEN_OPTS='-XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=./target/java_heapdump.hprof' MVNW_REPOURL=https://maven-central.storage-download.googleapis.com/maven2 GITHUB_ACTION_PATH=/home/github/64954781561/actions/actions-setup-java@be666c2fcd27ec809703dec50e508c2fdc7f6654 "${CURRENT_ENV[@]}" INPUT_JAVA-VERSION=21 INPUT_DISTRIBUTION=temurin INPUT_OVERWRITE-SETTINGS=False INPUT_TOKEN= INPUT_JAVA-PACKAGE=jdk INPUT_CHECK-LATEST=false INPUT_SERVER-ID=github INPUT_SERVER-USERNAME=GITHUB_ACTOR INPUT_SERVER-PASSWORD=GITHUB_TOKEN INPUT_JOB-STATUS="${_GITHUB_JOB_STATUS}" \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=0 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=actions/setup-java GITHUB_ACTIONS=true GITHUB_ACTOR=arturobernalg GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=11715 GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/11715 GITHUB_REF_NAME=11715 GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/maven GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=af2dea7e5dadb3ed02031162e88a28a6e3d7dbb8 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Java CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 MIMIR_VERSION=0.11.2 MIMIR_BASEDIR='~/.mimir' MIMIR_LOCAL='~/.mimir/local' MAVEN_OPTS='-XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=./target/java_heapdump.hprof' MVNW_REPOURL=https://maven-central.storage-download.googleapis.com/maven2 GITHUB_ACTION_PATH=/home/github/64954781561/actions/actions-setup-java@be666c2fcd27ec809703dec50e508c2fdc7f6654 "${CURRENT_ENV[@]}" INPUT_JAVA-VERSION=21 INPUT_DISTRIBUTION=temurin INPUT_OVERWRITE-SETTINGS=False INPUT_TOKEN= INPUT_JAVA-PACKAGE=jdk INPUT_CHECK-LATEST=false INPUT_SERVER-ID=github INPUT_SERVER-USERNAME=GITHUB_ACTOR INPUT_SERVER-PASSWORD=GITHUB_TOKEN INPUT_JOB-STATUS="${_GITHUB_JOB_STATUS}" \
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=2 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=arturobernalg GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=11715 GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/11715 GITHUB_REF_NAME=11715 GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/maven GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=af2dea7e5dadb3ed02031162e88a28a6e3d7dbb8 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Java CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 MIMIR_VERSION=0.11.2 MIMIR_BASEDIR='~/.mimir' MIMIR_LOCAL='~/.mimir/local' MAVEN_OPTS='-XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=./target/java_heapdump.hprof' MVNW_REPOURL=https://maven-central.storage-download.googleapis.com/maven2 "${CURRENT_ENV[@]}" \
echo $(test "$_GITHUB_JOB_STATUS" = "success" && echo true || echo false))
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=2 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=arturobernalg GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=11715 GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/11715 GITHUB_REF_NAME=11715 GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/maven GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=af2dea7e5dadb3ed02031162e88a28a6e3d7dbb8 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Java CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 MIMIR_VERSION=0.11.2 MIMIR_BASEDIR='~/.mimir' MIMIR_LOCAL='~/.mimir/local' MAVEN_OPTS='-XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=./target/java_heapdump.hprof' MVNW_REPOURL=https://maven-central.storage-download.googleapis.com/maven2 "${CURRENT_ENV[@]}" \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run 'mkdir -p '"$(test -v "CURRENT_ENV_MAP[MIMIR_BASEDIR]" && echo "${CURRENT_ENV_MAP[MIMIR_BASEDIR]}" || echo '~/.mimir')"
echo "##[endgroup]"
echo 'mkdir -p '"$(test -v "CURRENT_ENV_MAP[MIMIR_BASEDIR]" && echo "${CURRENT_ENV_MAP[MIMIR_BASEDIR]}" || echo '~/.mimir')"'
cp .github/ci-mimir-session.properties '"$(test -v "CURRENT_ENV_MAP[MIMIR_BASEDIR]" && echo "${CURRENT_ENV_MAP[MIMIR_BASEDIR]}" || echo '~/.mimir')"'/session.properties
cp .github/ci-mimir-daemon.properties '"$(test -v "CURRENT_ENV_MAP[MIMIR_BASEDIR]" && echo "${CURRENT_ENV_MAP[MIMIR_BASEDIR]}" || echo '~/.mimir')"'/daemon.properties
mkdir -p ~/.m2
cp .github/ci-extensions.xml ~/.m2/extensions.xml
' > /home/github/64954781561/steps/bugswarm_2.sh
chmod u+x /home/github/64954781561/steps/bugswarm_2.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=2 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=arturobernalg GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=11715 GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/11715 GITHUB_REF_NAME=11715 GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/maven GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=af2dea7e5dadb3ed02031162e88a28a6e3d7dbb8 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Java CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 MIMIR_VERSION=0.11.2 MIMIR_BASEDIR='~/.mimir' MIMIR_LOCAL='~/.mimir/local' MAVEN_OPTS='-XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=./target/java_heapdump.hprof' MVNW_REPOURL=https://maven-central.storage-download.googleapis.com/maven2 "${CURRENT_ENV[@]}" \
bash --noprofile --norc -eo pipefail /home/github/64954781561/steps/bugswarm_2.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=2 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=arturobernalg GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=11715 GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/11715 GITHUB_REF_NAME=11715 GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/maven GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=af2dea7e5dadb3ed02031162e88a28a6e3d7dbb8 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Java CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 MIMIR_VERSION=0.11.2 MIMIR_BASEDIR='~/.mimir' MIMIR_LOCAL='~/.mimir/local' MAVEN_OPTS='-XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=./target/java_heapdump.hprof' MVNW_REPOURL=https://maven-central.storage-download.googleapis.com/maven2 "${CURRENT_ENV[@]}" \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=2 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=arturobernalg GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=11715 GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/11715 GITHUB_REF_NAME=11715 GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/maven GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=af2dea7e5dadb3ed02031162e88a28a6e3d7dbb8 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Java CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 MIMIR_VERSION=0.11.2 MIMIR_BASEDIR='~/.mimir' MIMIR_LOCAL='~/.mimir/local' MAVEN_OPTS='-XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=./target/java_heapdump.hprof' MVNW_REPOURL=https://maven-central.storage-download.googleapis.com/maven2 "${CURRENT_ENV[@]}" \
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=5 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=arturobernalg GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=11715 GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/11715 GITHUB_REF_NAME=11715 GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/maven GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=af2dea7e5dadb3ed02031162e88a28a6e3d7dbb8 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Java CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 MIMIR_VERSION=0.11.2 MIMIR_BASEDIR='~/.mimir' MIMIR_LOCAL='~/.mimir/local' MAVEN_OPTS='-XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=./target/java_heapdump.hprof' MVNW_REPOURL=https://maven-central.storage-download.googleapis.com/maven2 "${CURRENT_ENV[@]}" \
echo $(test "$_GITHUB_JOB_STATUS" = "success" && echo true || echo false))
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=5 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=arturobernalg GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=11715 GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/11715 GITHUB_REF_NAME=11715 GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/maven GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=af2dea7e5dadb3ed02031162e88a28a6e3d7dbb8 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Java CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 MIMIR_VERSION=0.11.2 MIMIR_BASEDIR='~/.mimir' MIMIR_LOCAL='~/.mimir/local' MAVEN_OPTS='-XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=./target/java_heapdump.hprof' MVNW_REPOURL=https://maven-central.storage-download.googleapis.com/maven2 "${CURRENT_ENV[@]}" \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run 'ls -la maven-dist'
echo "##[endgroup]"
echo 'ls -la maven-dist' > /home/github/64954781561/steps/bugswarm_5.sh
chmod u+x /home/github/64954781561/steps/bugswarm_5.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=5 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=arturobernalg GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=11715 GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/11715 GITHUB_REF_NAME=11715 GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/maven GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=af2dea7e5dadb3ed02031162e88a28a6e3d7dbb8 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Java CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 MIMIR_VERSION=0.11.2 MIMIR_BASEDIR='~/.mimir' MIMIR_LOCAL='~/.mimir/local' MAVEN_OPTS='-XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=./target/java_heapdump.hprof' MVNW_REPOURL=https://maven-central.storage-download.googleapis.com/maven2 "${CURRENT_ENV[@]}" \
bash --noprofile --norc -eo pipefail /home/github/64954781561/steps/bugswarm_5.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=5 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=arturobernalg GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=11715 GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/11715 GITHUB_REF_NAME=11715 GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/maven GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=af2dea7e5dadb3ed02031162e88a28a6e3d7dbb8 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Java CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 MIMIR_VERSION=0.11.2 MIMIR_BASEDIR='~/.mimir' MIMIR_LOCAL='~/.mimir/local' MAVEN_OPTS='-XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=./target/java_heapdump.hprof' MVNW_REPOURL=https://maven-central.storage-download.googleapis.com/maven2 "${CURRENT_ENV[@]}" \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=5 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=arturobernalg GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=11715 GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/11715 GITHUB_REF_NAME=11715 GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/maven GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=af2dea7e5dadb3ed02031162e88a28a6e3d7dbb8 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Java CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 MIMIR_VERSION=0.11.2 MIMIR_BASEDIR='~/.mimir' MIMIR_LOCAL='~/.mimir/local' MAVEN_OPTS='-XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=./target/java_heapdump.hprof' MVNW_REPOURL=https://maven-central.storage-download.googleapis.com/maven2 "${CURRENT_ENV[@]}" \
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=6 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=arturobernalg GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=11715 GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/11715 GITHUB_REF_NAME=11715 GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/maven GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=af2dea7e5dadb3ed02031162e88a28a6e3d7dbb8 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Java CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 MIMIR_VERSION=0.11.2 MIMIR_BASEDIR='~/.mimir' MIMIR_LOCAL='~/.mimir/local' MAVEN_OPTS='-XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=./target/java_heapdump.hprof' MVNW_REPOURL=https://maven-central.storage-download.googleapis.com/maven2 "${CURRENT_ENV[@]}" \
echo $(test "$_GITHUB_JOB_STATUS" = "success" && echo true || echo false))
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=6 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=arturobernalg GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=11715 GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/11715 GITHUB_REF_NAME=11715 GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/maven GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=af2dea7e5dadb3ed02031162e88a28a6e3d7dbb8 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Java CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 MIMIR_VERSION=0.11.2 MIMIR_BASEDIR='~/.mimir' MIMIR_LOCAL='~/.mimir/local' MAVEN_OPTS='-XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=./target/java_heapdump.hprof' MVNW_REPOURL=https://maven-central.storage-download.googleapis.com/maven2 "${CURRENT_ENV[@]}" \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run 'mkdir -p maven-local'
echo "##[endgroup]"
echo 'mkdir -p maven-local
if [ "Linux" = "Windows" ]; then
  unzip maven-dist/apache-maven-*-bin.zip -d maven-local
  # Get the name of the extracted directory
  MAVEN_DIR=$(ls maven-local)
  # Move contents up one level
  mv "maven-local/$MAVEN_DIR"/* maven-local/
  rm -r "maven-local/$MAVEN_DIR"
else
  tar xzf maven-dist/apache-maven-*-bin.tar.gz -C maven-local --strip-components 1
fi
echo "MAVEN_HOME=$PWD/maven-local" >> $GITHUB_ENV
echo "$PWD/maven-local/bin" >> $GITHUB_PATH
' > /home/github/64954781561/steps/bugswarm_6.sh
chmod u+x /home/github/64954781561/steps/bugswarm_6.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=6 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=arturobernalg GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=11715 GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/11715 GITHUB_REF_NAME=11715 GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/maven GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=af2dea7e5dadb3ed02031162e88a28a6e3d7dbb8 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Java CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 MIMIR_VERSION=0.11.2 MIMIR_BASEDIR='~/.mimir' MIMIR_LOCAL='~/.mimir/local' MAVEN_OPTS='-XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=./target/java_heapdump.hprof' MVNW_REPOURL=https://maven-central.storage-download.googleapis.com/maven2 "${CURRENT_ENV[@]}" \
bash --noprofile --norc -eo pipefail /home/github/64954781561/steps/bugswarm_6.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=6 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=arturobernalg GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=11715 GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/11715 GITHUB_REF_NAME=11715 GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/maven GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=af2dea7e5dadb3ed02031162e88a28a6e3d7dbb8 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Java CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 MIMIR_VERSION=0.11.2 MIMIR_BASEDIR='~/.mimir' MIMIR_LOCAL='~/.mimir/local' MAVEN_OPTS='-XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=./target/java_heapdump.hprof' MVNW_REPOURL=https://maven-central.storage-download.googleapis.com/maven2 "${CURRENT_ENV[@]}" \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=6 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=arturobernalg GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=11715 GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/11715 GITHUB_REF_NAME=11715 GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/maven GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=af2dea7e5dadb3ed02031162e88a28a6e3d7dbb8 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Java CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 MIMIR_VERSION=0.11.2 MIMIR_BASEDIR='~/.mimir' MIMIR_LOCAL='~/.mimir/local' MAVEN_OPTS='-XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=./target/java_heapdump.hprof' MVNW_REPOURL=https://maven-central.storage-download.googleapis.com/maven2 "${CURRENT_ENV[@]}" \
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=7 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=arturobernalg GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=11715 GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/11715 GITHUB_REF_NAME=11715 GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/maven GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=af2dea7e5dadb3ed02031162e88a28a6e3d7dbb8 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Java CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 MIMIR_VERSION=0.11.2 MIMIR_BASEDIR='~/.mimir' MIMIR_LOCAL='~/.mimir/local' MAVEN_OPTS='-XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=./target/java_heapdump.hprof' MVNW_REPOURL=https://maven-central.storage-download.googleapis.com/maven2 "${CURRENT_ENV[@]}" \
echo $(test "$_GITHUB_JOB_STATUS" = "success" && echo true || echo false))
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=7 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=arturobernalg GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=11715 GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/11715 GITHUB_REF_NAME=11715 GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/maven GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=af2dea7e5dadb3ed02031162e88a28a6e3d7dbb8 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Java CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 MIMIR_VERSION=0.11.2 MIMIR_BASEDIR='~/.mimir' MIMIR_LOCAL='~/.mimir/local' MAVEN_OPTS='-XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=./target/java_heapdump.hprof' MVNW_REPOURL=https://maven-central.storage-download.googleapis.com/maven2 "${CURRENT_ENV[@]}" \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run 'mvn install -e -B -V -Prun-its,mimir'
echo "##[endgroup]"
echo 'mvn install -e -B -V -Prun-its,mimir' > /home/github/64954781561/steps/bugswarm_7.sh
chmod u+x /home/github/64954781561/steps/bugswarm_7.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=7 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=arturobernalg GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=11715 GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/11715 GITHUB_REF_NAME=11715 GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/maven GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=af2dea7e5dadb3ed02031162e88a28a6e3d7dbb8 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Java CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 MIMIR_VERSION=0.11.2 MIMIR_BASEDIR='~/.mimir' MIMIR_LOCAL='~/.mimir/local' MAVEN_OPTS='-XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=./target/java_heapdump.hprof' MVNW_REPOURL=https://maven-central.storage-download.googleapis.com/maven2 "${CURRENT_ENV[@]}" \
bash --noprofile --norc -eo pipefail /home/github/64954781561/steps/bugswarm_7.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=7 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=arturobernalg GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=11715 GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/11715 GITHUB_REF_NAME=11715 GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/maven GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=af2dea7e5dadb3ed02031162e88a28a6e3d7dbb8 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Java CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 MIMIR_VERSION=0.11.2 MIMIR_BASEDIR='~/.mimir' MIMIR_LOCAL='~/.mimir/local' MAVEN_OPTS='-XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=./target/java_heapdump.hprof' MVNW_REPOURL=https://maven-central.storage-download.googleapis.com/maven2 "${CURRENT_ENV[@]}" \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=7 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=arturobernalg GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=11715 GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/11715 GITHUB_REF_NAME=11715 GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/maven GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=af2dea7e5dadb3ed02031162e88a28a6e3d7dbb8 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Java CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 MIMIR_VERSION=0.11.2 MIMIR_BASEDIR='~/.mimir' MIMIR_LOCAL='~/.mimir/local' MAVEN_OPTS='-XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=./target/java_heapdump.hprof' MVNW_REPOURL=https://maven-central.storage-download.googleapis.com/maven2 "${CURRENT_ENV[@]}" \
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
   bash -e $ACTIONS_RUNNER_HOOK_JOB_COMPLETED 64954781561 failed
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
