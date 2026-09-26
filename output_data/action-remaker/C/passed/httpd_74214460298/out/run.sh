#!/usr/bin/env bash
export GITHUB_WORKSPACE=/home/github/build/apache/httpd

if [[ ! -z "$ACTIONS_RUNNER_HOOK_JOB_STARTED" ]]; then
   echo "A job started hook has been configured by the self-hosted runner administrator"
   echo "##[group]Run '$ACTIONS_RUNNER_HOOK_JOB_STARTED'"
   echo "##[endgroup]"
   bash -e $ACTIONS_RUNNER_HOOK_JOB_STARTED 74214460298 passed
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

cp /home/github/74214460298/event.json /home/github/workflow/event.json
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=0 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=asf-gitbox-commits GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/2.4.67 GITHUB_REF_NAME=2.4.67 GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/httpd GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=1284d059e417308158be7594be7b14d321a2ac61 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Linux GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 MARGS=-j2 CFLAGS=-g PHP_FPM=/usr/sbin/php-fpm8.1 NOTEST_CFLAGS= CONFIG='--enable-mods-shared=reallyall --with-mpm=event --enable-mpms-shared=all' "${CURRENT_ENV[@]}" \
echo $(test "$_GITHUB_JOB_STATUS" = "success" && echo true || echo false))
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=0 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=asf-gitbox-commits GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/2.4.67 GITHUB_REF_NAME=2.4.67 GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/httpd GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=1284d059e417308158be7594be7b14d321a2ac61 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Linux GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 MARGS=-j2 CFLAGS=-g PHP_FPM=/usr/sbin/php-fpm8.1 NOTEST_CFLAGS= CONFIG='--enable-mods-shared=reallyall --with-mpm=event --enable-mpms-shared=all' "${CURRENT_ENV[@]}" \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run 'echo "APR_VERSION=1.7.4
APU_VERSION=1.6.3
APU_CONFIG="--with-crypto"
NO_TEST_FRAMEWORK=1
TEST_INSTALL=1
TEST_H2=1
TEST_CORE=1
TEST_PROXY=1
" >> $GITHUB_ENV'
echo "##[endgroup]"
echo 'echo "APR_VERSION=1.7.4
APU_VERSION=1.6.3
APU_CONFIG="--with-crypto"
NO_TEST_FRAMEWORK=1
TEST_INSTALL=1
TEST_H2=1
TEST_CORE=1
TEST_PROXY=1
" >> $GITHUB_ENV
echo JOBID=`echo "OS=$ImageOS  APR_VERSION=1.7.4
APU_VERSION=1.6.3
APU_CONFIG="--with-crypto"
NO_TEST_FRAMEWORK=1
TEST_INSTALL=1
TEST_H2=1
TEST_CORE=1
TEST_PROXY=1
 --enable-mods-shared=reallyall --with-mpm=event --enable-mpms-shared=all" \
   | md5sum - | sed '"'"'s/ .*//'"'"'` >> $GITHUB_ENV
' > /home/github/74214460298/steps/bugswarm_0.sh
chmod u+x /home/github/74214460298/steps/bugswarm_0.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=0 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=asf-gitbox-commits GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/2.4.67 GITHUB_REF_NAME=2.4.67 GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/httpd GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=1284d059e417308158be7594be7b14d321a2ac61 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Linux GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 MARGS=-j2 CFLAGS=-g PHP_FPM=/usr/sbin/php-fpm8.1 NOTEST_CFLAGS= CONFIG='--enable-mods-shared=reallyall --with-mpm=event --enable-mpms-shared=all' "${CURRENT_ENV[@]}" \
bash -e /home/github/74214460298/steps/bugswarm_0.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=0 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=asf-gitbox-commits GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/2.4.67 GITHUB_REF_NAME=2.4.67 GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/httpd GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=1284d059e417308158be7594be7b14d321a2ac61 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Linux GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 MARGS=-j2 CFLAGS=-g PHP_FPM=/usr/sbin/php-fpm8.1 NOTEST_CFLAGS= CONFIG='--enable-mods-shared=reallyall --with-mpm=event --enable-mpms-shared=all' "${CURRENT_ENV[@]}" \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=0 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=asf-gitbox-commits GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/2.4.67 GITHUB_REF_NAME=2.4.67 GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/httpd GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=1284d059e417308158be7594be7b14d321a2ac61 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Linux GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 MARGS=-j2 CFLAGS=-g PHP_FPM=/usr/sbin/php-fpm8.1 NOTEST_CFLAGS= CONFIG='--enable-mods-shared=reallyall --with-mpm=event --enable-mpms-shared=all' "${CURRENT_ENV[@]}" \
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=1 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=asf-gitbox-commits GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/2.4.67 GITHUB_REF_NAME=2.4.67 GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/httpd GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=1284d059e417308158be7594be7b14d321a2ac61 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Linux GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 MARGS=-j2 CFLAGS=-g PHP_FPM=/usr/sbin/php-fpm8.1 NOTEST_CFLAGS= CONFIG='--enable-mods-shared=reallyall --with-mpm=event --enable-mpms-shared=all' "${CURRENT_ENV[@]}" \
echo $(test "$_GITHUB_JOB_STATUS" = "success" && echo true || echo false))
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=1 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=asf-gitbox-commits GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/2.4.67 GITHUB_REF_NAME=2.4.67 GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/httpd GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=1284d059e417308158be7594be7b14d321a2ac61 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Linux GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 MARGS=-j2 CFLAGS=-g PHP_FPM=/usr/sbin/php-fpm8.1 NOTEST_CFLAGS= CONFIG='--enable-mods-shared=reallyall --with-mpm=event --enable-mpms-shared=all' "${CURRENT_ENV[@]}" \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run 'sudo sysctl vm.mmap_rnd_bits=28'
echo "##[endgroup]"
echo 'sudo sysctl vm.mmap_rnd_bits=28' > /home/github/74214460298/steps/bugswarm_1.sh
chmod u+x /home/github/74214460298/steps/bugswarm_1.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=1 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=asf-gitbox-commits GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/2.4.67 GITHUB_REF_NAME=2.4.67 GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/httpd GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=1284d059e417308158be7594be7b14d321a2ac61 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Linux GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 MARGS=-j2 CFLAGS=-g PHP_FPM=/usr/sbin/php-fpm8.1 NOTEST_CFLAGS= CONFIG='--enable-mods-shared=reallyall --with-mpm=event --enable-mpms-shared=all' "${CURRENT_ENV[@]}" \
bash -e /home/github/74214460298/steps/bugswarm_1.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=1 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=asf-gitbox-commits GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/2.4.67 GITHUB_REF_NAME=2.4.67 GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/httpd GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=1284d059e417308158be7594be7b14d321a2ac61 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Linux GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 MARGS=-j2 CFLAGS=-g PHP_FPM=/usr/sbin/php-fpm8.1 NOTEST_CFLAGS= CONFIG='--enable-mods-shared=reallyall --with-mpm=event --enable-mpms-shared=all' "${CURRENT_ENV[@]}" \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=1 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=asf-gitbox-commits GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/2.4.67 GITHUB_REF_NAME=2.4.67 GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/httpd GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=1284d059e417308158be7594be7b14d321a2ac61 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Linux GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 MARGS=-j2 CFLAGS=-g PHP_FPM=/usr/sbin/php-fpm8.1 NOTEST_CFLAGS= CONFIG='--enable-mods-shared=reallyall --with-mpm=event --enable-mpms-shared=all' "${CURRENT_ENV[@]}" \
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=2 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=asf-gitbox-commits GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/2.4.67 GITHUB_REF_NAME=2.4.67 GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/httpd GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=1284d059e417308158be7594be7b14d321a2ac61 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Linux GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 MARGS=-j2 CFLAGS=-g PHP_FPM=/usr/sbin/php-fpm8.1 NOTEST_CFLAGS= CONFIG='--enable-mods-shared=reallyall --with-mpm=event --enable-mpms-shared=all' "${CURRENT_ENV[@]}" \
echo $(test "$_GITHUB_JOB_STATUS" = "success" && echo true || echo false))
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=2 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=asf-gitbox-commits GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/2.4.67 GITHUB_REF_NAME=2.4.67 GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/httpd GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=1284d059e417308158be7594be7b14d321a2ac61 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Linux GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 MARGS=-j2 CFLAGS=-g PHP_FPM=/usr/sbin/php-fpm8.1 NOTEST_CFLAGS= CONFIG='--enable-mods-shared=reallyall --with-mpm=event --enable-mpms-shared=all' "${CURRENT_ENV[@]}" \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run 'sudo apt-get -o Acquire::Retries=5 update'
echo "##[endgroup]"
echo 'sudo apt-get -o Acquire::Retries=5 update' > /home/github/74214460298/steps/bugswarm_2.sh
chmod u+x /home/github/74214460298/steps/bugswarm_2.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=2 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=asf-gitbox-commits GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/2.4.67 GITHUB_REF_NAME=2.4.67 GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/httpd GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=1284d059e417308158be7594be7b14d321a2ac61 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Linux GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 MARGS=-j2 CFLAGS=-g PHP_FPM=/usr/sbin/php-fpm8.1 NOTEST_CFLAGS= CONFIG='--enable-mods-shared=reallyall --with-mpm=event --enable-mpms-shared=all' "${CURRENT_ENV[@]}" \
bash -e /home/github/74214460298/steps/bugswarm_2.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=2 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=asf-gitbox-commits GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/2.4.67 GITHUB_REF_NAME=2.4.67 GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/httpd GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=1284d059e417308158be7594be7b14d321a2ac61 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Linux GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 MARGS=-j2 CFLAGS=-g PHP_FPM=/usr/sbin/php-fpm8.1 NOTEST_CFLAGS= CONFIG='--enable-mods-shared=reallyall --with-mpm=event --enable-mpms-shared=all' "${CURRENT_ENV[@]}" \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=2 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=asf-gitbox-commits GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/2.4.67 GITHUB_REF_NAME=2.4.67 GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/httpd GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=1284d059e417308158be7594be7b14d321a2ac61 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Linux GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 MARGS=-j2 CFLAGS=-g PHP_FPM=/usr/sbin/php-fpm8.1 NOTEST_CFLAGS= CONFIG='--enable-mods-shared=reallyall --with-mpm=event --enable-mpms-shared=all' "${CURRENT_ENV[@]}" \
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=3 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=asf-gitbox-commits GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/2.4.67 GITHUB_REF_NAME=2.4.67 GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/httpd GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=1284d059e417308158be7594be7b14d321a2ac61 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Linux GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 MARGS=-j2 CFLAGS=-g PHP_FPM=/usr/sbin/php-fpm8.1 NOTEST_CFLAGS= CONFIG='--enable-mods-shared=reallyall --with-mpm=event --enable-mpms-shared=all' "${CURRENT_ENV[@]}" \
echo $(test "$_GITHUB_JOB_STATUS" = "success" && echo true || echo false))
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=3 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=asf-gitbox-commits GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/2.4.67 GITHUB_REF_NAME=2.4.67 GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/httpd GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=1284d059e417308158be7594be7b14d321a2ac61 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Linux GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 MARGS=-j2 CFLAGS=-g PHP_FPM=/usr/sbin/php-fpm8.1 NOTEST_CFLAGS= CONFIG='--enable-mods-shared=reallyall --with-mpm=event --enable-mpms-shared=all' "${CURRENT_ENV[@]}" \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run 'sudo apt-get install -o Acquire::Retries=5 cpanminus libtool-bin libapr1-dev libaprutil1-dev liblua5.3-dev libbrotli-dev libcurl4-openssl-dev libnghttp2-dev libjansson-dev libpcre2-dev gdb perl-doc libsasl2-dev curl python3-pytest nghttp2-client python3-cryptography python3-requests python3-multipart python3-filelock python3-websockets'
echo "##[endgroup]"
echo 'sudo apt-get install -o Acquire::Retries=5 cpanminus libtool-bin libapr1-dev libaprutil1-dev liblua5.3-dev libbrotli-dev libcurl4-openssl-dev libnghttp2-dev libjansson-dev libpcre2-dev gdb perl-doc libsasl2-dev curl python3-pytest nghttp2-client python3-cryptography python3-requests python3-multipart python3-filelock python3-websockets' > /home/github/74214460298/steps/bugswarm_3.sh
chmod u+x /home/github/74214460298/steps/bugswarm_3.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=3 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=asf-gitbox-commits GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/2.4.67 GITHUB_REF_NAME=2.4.67 GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/httpd GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=1284d059e417308158be7594be7b14d321a2ac61 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Linux GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 MARGS=-j2 CFLAGS=-g PHP_FPM=/usr/sbin/php-fpm8.1 NOTEST_CFLAGS= CONFIG='--enable-mods-shared=reallyall --with-mpm=event --enable-mpms-shared=all' "${CURRENT_ENV[@]}" \
bash -e /home/github/74214460298/steps/bugswarm_3.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=3 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=asf-gitbox-commits GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/2.4.67 GITHUB_REF_NAME=2.4.67 GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/httpd GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=1284d059e417308158be7594be7b14d321a2ac61 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Linux GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 MARGS=-j2 CFLAGS=-g PHP_FPM=/usr/sbin/php-fpm8.1 NOTEST_CFLAGS= CONFIG='--enable-mods-shared=reallyall --with-mpm=event --enable-mpms-shared=all' "${CURRENT_ENV[@]}" \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=3 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=asf-gitbox-commits GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/2.4.67 GITHUB_REF_NAME=2.4.67 GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/httpd GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=1284d059e417308158be7594be7b14d321a2ac61 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Linux GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 MARGS=-j2 CFLAGS=-g PHP_FPM=/usr/sbin/php-fpm8.1 NOTEST_CFLAGS= CONFIG='--enable-mods-shared=reallyall --with-mpm=event --enable-mpms-shared=all' "${CURRENT_ENV[@]}" \
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=7 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=asf-gitbox-commits GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/2.4.67 GITHUB_REF_NAME=2.4.67 GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/httpd GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=1284d059e417308158be7594be7b14d321a2ac61 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Linux GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 MARGS=-j2 CFLAGS=-g PHP_FPM=/usr/sbin/php-fpm8.1 NOTEST_CFLAGS= CONFIG='--enable-mods-shared=reallyall --with-mpm=event --enable-mpms-shared=all' "${CURRENT_ENV[@]}" \
echo $(test "$_GITHUB_JOB_STATUS" = "success" && echo true || echo false))
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=7 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=asf-gitbox-commits GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/2.4.67 GITHUB_REF_NAME=2.4.67 GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/httpd GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=1284d059e417308158be7594be7b14d321a2ac61 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Linux GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 MARGS=-j2 CFLAGS=-g PHP_FPM=/usr/sbin/php-fpm8.1 NOTEST_CFLAGS= CONFIG='--enable-mods-shared=reallyall --with-mpm=event --enable-mpms-shared=all' "${CURRENT_ENV[@]}" \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run ./test/travis_before_linux.sh
echo "##[endgroup]"
echo ./test/travis_before_linux.sh > /home/github/74214460298/steps/bugswarm_7.sh
chmod u+x /home/github/74214460298/steps/bugswarm_7.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=7 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=asf-gitbox-commits GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/2.4.67 GITHUB_REF_NAME=2.4.67 GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/httpd GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=1284d059e417308158be7594be7b14d321a2ac61 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Linux GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 MARGS=-j2 CFLAGS=-g PHP_FPM=/usr/sbin/php-fpm8.1 NOTEST_CFLAGS= CONFIG='--enable-mods-shared=reallyall --with-mpm=event --enable-mpms-shared=all' "${CURRENT_ENV[@]}" \
bash -e /home/github/74214460298/steps/bugswarm_7.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=7 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=asf-gitbox-commits GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/2.4.67 GITHUB_REF_NAME=2.4.67 GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/httpd GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=1284d059e417308158be7594be7b14d321a2ac61 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Linux GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 MARGS=-j2 CFLAGS=-g PHP_FPM=/usr/sbin/php-fpm8.1 NOTEST_CFLAGS= CONFIG='--enable-mods-shared=reallyall --with-mpm=event --enable-mpms-shared=all' "${CURRENT_ENV[@]}" \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=7 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=asf-gitbox-commits GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/2.4.67 GITHUB_REF_NAME=2.4.67 GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/httpd GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=1284d059e417308158be7594be7b14d321a2ac61 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Linux GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 MARGS=-j2 CFLAGS=-g PHP_FPM=/usr/sbin/php-fpm8.1 NOTEST_CFLAGS= CONFIG='--enable-mods-shared=reallyall --with-mpm=event --enable-mpms-shared=all' "${CURRENT_ENV[@]}" \
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=9 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=asf-gitbox-commits GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/2.4.67 GITHUB_REF_NAME=2.4.67 GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/httpd GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=1284d059e417308158be7594be7b14d321a2ac61 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Linux GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 MARGS=-j2 CFLAGS=-g PHP_FPM=/usr/sbin/php-fpm8.1 NOTEST_CFLAGS= CONFIG='--enable-mods-shared=reallyall --with-mpm=event --enable-mpms-shared=all' "${CURRENT_ENV[@]}" \
echo $(test "$_GITHUB_JOB_STATUS" = "success" && echo true || echo false))
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=9 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=asf-gitbox-commits GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/2.4.67 GITHUB_REF_NAME=2.4.67 GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/httpd GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=1284d059e417308158be7594be7b14d321a2ac61 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Linux GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 MARGS=-j2 CFLAGS=-g PHP_FPM=/usr/sbin/php-fpm8.1 NOTEST_CFLAGS= CONFIG='--enable-mods-shared=reallyall --with-mpm=event --enable-mpms-shared=all' "${CURRENT_ENV[@]}" \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run ./test/travis_run_linux.sh
echo "##[endgroup]"
echo ./test/travis_run_linux.sh > /home/github/74214460298/steps/bugswarm_9.sh
chmod u+x /home/github/74214460298/steps/bugswarm_9.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=9 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=asf-gitbox-commits GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/2.4.67 GITHUB_REF_NAME=2.4.67 GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/httpd GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=1284d059e417308158be7594be7b14d321a2ac61 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Linux GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 MARGS=-j2 CFLAGS=-g PHP_FPM=/usr/sbin/php-fpm8.1 NOTEST_CFLAGS= CONFIG='--enable-mods-shared=reallyall --with-mpm=event --enable-mpms-shared=all' "${CURRENT_ENV[@]}" \
bash -e /home/github/74214460298/steps/bugswarm_9.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=9 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=asf-gitbox-commits GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/2.4.67 GITHUB_REF_NAME=2.4.67 GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/httpd GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=1284d059e417308158be7594be7b14d321a2ac61 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Linux GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 MARGS=-j2 CFLAGS=-g PHP_FPM=/usr/sbin/php-fpm8.1 NOTEST_CFLAGS= CONFIG='--enable-mods-shared=reallyall --with-mpm=event --enable-mpms-shared=all' "${CURRENT_ENV[@]}" \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=9 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=asf-gitbox-commits GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/2.4.67 GITHUB_REF_NAME=2.4.67 GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/httpd GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=1284d059e417308158be7594be7b14d321a2ac61 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Linux GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 MARGS=-j2 CFLAGS=-g PHP_FPM=/usr/sbin/php-fpm8.1 NOTEST_CFLAGS= CONFIG='--enable-mods-shared=reallyall --with-mpm=event --enable-mpms-shared=all' "${CURRENT_ENV[@]}" \
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
   bash -e $ACTIONS_RUNNER_HOOK_JOB_COMPLETED 74214460298 passed
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
