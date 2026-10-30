#!/usr/bin/env bash
export GITHUB_WORKSPACE=/home/github/build/google/guava

if [[ ! -z "$ACTIONS_RUNNER_HOOK_JOB_STARTED" ]]; then
   echo "A job started hook has been configured by the self-hosted runner administrator"
   echo "##[group]Run '$ACTIONS_RUNNER_HOOK_JOB_STARTED'"
   echo "##[endgroup]"
   bash -e $ACTIONS_RUNNER_HOOK_JOB_STARTED 67317731564 passed
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

cp /home/github/67317731564/event.json /home/github/workflow/event.json
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=2 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=actions/setup-java GITHUB_ACTIONS=true GITHUB_ACTOR='copybara-service[bot]' GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=google/guava GITHUB_REPOSITORY_OWNER=google GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=e35bf7d85ad58bb1fbcdb6c6869e7cb532b99dae GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 GITHUB_ACTION_PATH=/home/github/67317731564/actions/actions-setup-java@be666c2fcd27ec809703dec50e508c2fdc7f6654 ROOT_POM=pom.xml "${CURRENT_ENV[@]}" INPUT_JAVA-VERSION='11
25
' INPUT_DISTRIBUTION=temurin INPUT_OVERWRITE-SETTINGS=False INPUT_TOKEN= INPUT_JAVA-PACKAGE=jdk INPUT_CHECK-LATEST=false INPUT_SERVER-ID=github INPUT_SERVER-USERNAME=GITHUB_ACTOR INPUT_SERVER-PASSWORD=GITHUB_TOKEN INPUT_JOB-STATUS="${_GITHUB_JOB_STATUS}" \
echo $(test "$_GITHUB_JOB_STATUS" = "success" && echo true || echo false))
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=2 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=actions/setup-java GITHUB_ACTIONS=true GITHUB_ACTOR='copybara-service[bot]' GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=google/guava GITHUB_REPOSITORY_OWNER=google GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=e35bf7d85ad58bb1fbcdb6c6869e7cb532b99dae GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 GITHUB_ACTION_PATH=/home/github/67317731564/actions/actions-setup-java@be666c2fcd27ec809703dec50e508c2fdc7f6654 ROOT_POM=pom.xml "${CURRENT_ENV[@]}" INPUT_JAVA-VERSION='11
25
' INPUT_DISTRIBUTION=temurin INPUT_OVERWRITE-SETTINGS=False INPUT_TOKEN= INPUT_JAVA-PACKAGE=jdk INPUT_CHECK-LATEST=false INPUT_SERVER-ID=github INPUT_SERVER-USERNAME=GITHUB_ACTOR INPUT_SERVER-PASSWORD=GITHUB_TOKEN INPUT_JOB-STATUS="${_GITHUB_JOB_STATUS}" \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run actions/setup-java@be666c2fcd27ec809703dec50e508c2fdc7f6654
echo "##[endgroup]"
echo node /home/github/67317731564/actions/actions-setup-java@be666c2fcd27ec809703dec50e508c2fdc7f6654/dist/setup/index.js > /home/github/67317731564/steps/bugswarm_cmd.sh
chmod u+x /home/github/67317731564/steps/bugswarm_cmd.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=2 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=actions/setup-java GITHUB_ACTIONS=true GITHUB_ACTOR='copybara-service[bot]' GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=google/guava GITHUB_REPOSITORY_OWNER=google GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=e35bf7d85ad58bb1fbcdb6c6869e7cb532b99dae GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 GITHUB_ACTION_PATH=/home/github/67317731564/actions/actions-setup-java@be666c2fcd27ec809703dec50e508c2fdc7f6654 ROOT_POM=pom.xml "${CURRENT_ENV[@]}" INPUT_JAVA-VERSION='11
25
' INPUT_DISTRIBUTION=temurin INPUT_OVERWRITE-SETTINGS=False INPUT_TOKEN= INPUT_JAVA-PACKAGE=jdk INPUT_CHECK-LATEST=false INPUT_SERVER-ID=github INPUT_SERVER-USERNAME=GITHUB_ACTOR INPUT_SERVER-PASSWORD=GITHUB_TOKEN INPUT_JOB-STATUS="${_GITHUB_JOB_STATUS}" \
bash -e /home/github/67317731564/steps/bugswarm_cmd.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=2 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=actions/setup-java GITHUB_ACTIONS=true GITHUB_ACTOR='copybara-service[bot]' GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=google/guava GITHUB_REPOSITORY_OWNER=google GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=e35bf7d85ad58bb1fbcdb6c6869e7cb532b99dae GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 GITHUB_ACTION_PATH=/home/github/67317731564/actions/actions-setup-java@be666c2fcd27ec809703dec50e508c2fdc7f6654 ROOT_POM=pom.xml "${CURRENT_ENV[@]}" INPUT_JAVA-VERSION='11
25
' INPUT_DISTRIBUTION=temurin INPUT_OVERWRITE-SETTINGS=False INPUT_TOKEN= INPUT_JAVA-PACKAGE=jdk INPUT_CHECK-LATEST=false INPUT_SERVER-ID=github INPUT_SERVER-USERNAME=GITHUB_ACTOR INPUT_SERVER-PASSWORD=GITHUB_TOKEN INPUT_JOB-STATUS="${_GITHUB_JOB_STATUS}" \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=2 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=actions/setup-java GITHUB_ACTIONS=true GITHUB_ACTOR='copybara-service[bot]' GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=google/guava GITHUB_REPOSITORY_OWNER=google GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=e35bf7d85ad58bb1fbcdb6c6869e7cb532b99dae GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 GITHUB_ACTION_PATH=/home/github/67317731564/actions/actions-setup-java@be666c2fcd27ec809703dec50e508c2fdc7f6654 ROOT_POM=pom.xml "${CURRENT_ENV[@]}" INPUT_JAVA-VERSION='11
25
' INPUT_DISTRIBUTION=temurin INPUT_OVERWRITE-SETTINGS=False INPUT_TOKEN= INPUT_JAVA-PACKAGE=jdk INPUT_CHECK-LATEST=false INPUT_SERVER-ID=github INPUT_SERVER-USERNAME=GITHUB_ACTOR INPUT_SERVER-PASSWORD=GITHUB_TOKEN INPUT_JOB-STATUS="${_GITHUB_JOB_STATUS}" \
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=3 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR='copybara-service[bot]' GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=google/guava GITHUB_REPOSITORY_OWNER=google GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=e35bf7d85ad58bb1fbcdb6c6869e7cb532b99dae GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 ROOT_POM=pom.xml "${CURRENT_ENV[@]}" \
echo $(test "$_GITHUB_JOB_STATUS" = "success" && echo true || echo false))
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=3 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR='copybara-service[bot]' GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=google/guava GITHUB_REPOSITORY_OWNER=google GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=e35bf7d85ad58bb1fbcdb6c6869e7cb532b99dae GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 ROOT_POM=pom.xml "${CURRENT_ENV[@]}" \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run './mvnw -B -ntp -Dtoolchain.skip install -U -DskipTests=true -f $ROOT_POM'
echo "##[endgroup]"
echo './mvnw -B -ntp -Dtoolchain.skip install -U -DskipTests=true -f $ROOT_POM' > /home/github/67317731564/steps/bugswarm_3.sh
chmod u+x /home/github/67317731564/steps/bugswarm_3.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=3 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR='copybara-service[bot]' GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=google/guava GITHUB_REPOSITORY_OWNER=google GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=e35bf7d85ad58bb1fbcdb6c6869e7cb532b99dae GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 ROOT_POM=pom.xml "${CURRENT_ENV[@]}" \
bash --noprofile --norc -eo pipefail /home/github/67317731564/steps/bugswarm_3.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=3 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR='copybara-service[bot]' GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=google/guava GITHUB_REPOSITORY_OWNER=google GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=e35bf7d85ad58bb1fbcdb6c6869e7cb532b99dae GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 ROOT_POM=pom.xml "${CURRENT_ENV[@]}" \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=3 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR='copybara-service[bot]' GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=google/guava GITHUB_REPOSITORY_OWNER=google GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=e35bf7d85ad58bb1fbcdb6c6869e7cb532b99dae GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 ROOT_POM=pom.xml "${CURRENT_ENV[@]}" \
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=4 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR='copybara-service[bot]' GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=google/guava GITHUB_REPOSITORY_OWNER=google GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=e35bf7d85ad58bb1fbcdb6c6869e7cb532b99dae GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 ROOT_POM=pom.xml "${CURRENT_ENV[@]}" \
echo $(test "$_GITHUB_JOB_STATUS" = "success" && echo true || echo false))
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=4 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR='copybara-service[bot]' GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=google/guava GITHUB_REPOSITORY_OWNER=google GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=e35bf7d85ad58bb1fbcdb6c6869e7cb532b99dae GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 ROOT_POM=pom.xml "${CURRENT_ENV[@]}" \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run './mvnw -B -ntp -P!standard-with-extra-repos -Dtoolchain.skip verify -U -Dmaven.javadoc.skip=true -Dsurefire.toolchain.version=11 -f $ROOT_POM'
echo "##[endgroup]"
echo './mvnw -B -ntp -P!standard-with-extra-repos -Dtoolchain.skip verify -U -Dmaven.javadoc.skip=true -Dsurefire.toolchain.version=11 -f $ROOT_POM' > /home/github/67317731564/steps/bugswarm_4.sh
chmod u+x /home/github/67317731564/steps/bugswarm_4.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=4 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR='copybara-service[bot]' GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=google/guava GITHUB_REPOSITORY_OWNER=google GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=e35bf7d85ad58bb1fbcdb6c6869e7cb532b99dae GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 ROOT_POM=pom.xml "${CURRENT_ENV[@]}" \
bash --noprofile --norc -eo pipefail /home/github/67317731564/steps/bugswarm_4.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=4 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR='copybara-service[bot]' GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=google/guava GITHUB_REPOSITORY_OWNER=google GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=e35bf7d85ad58bb1fbcdb6c6869e7cb532b99dae GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 ROOT_POM=pom.xml "${CURRENT_ENV[@]}" \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=4 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR='copybara-service[bot]' GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=google/guava GITHUB_REPOSITORY_OWNER=google GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=e35bf7d85ad58bb1fbcdb6c6869e7cb532b99dae GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 ROOT_POM=pom.xml "${CURRENT_ENV[@]}" \
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=5 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR='copybara-service[bot]' GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=google/guava GITHUB_REPOSITORY_OWNER=google GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=e35bf7d85ad58bb1fbcdb6c6869e7cb532b99dae GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 ROOT_POM=pom.xml "${CURRENT_ENV[@]}" \
echo "$(/home/github/67317731564/helpers/eval_expression p:'(' f:failure p:'(' p:')' p:')')")
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=5 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR='copybara-service[bot]' GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=google/guava GITHUB_REPOSITORY_OWNER=google GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=e35bf7d85ad58bb1fbcdb6c6869e7cb532b99dae GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 ROOT_POM=pom.xml "${CURRENT_ENV[@]}" \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run ./util/print_surefire_reports.sh
echo "##[endgroup]"
echo ./util/print_surefire_reports.sh > /home/github/67317731564/steps/bugswarm_5.sh
chmod u+x /home/github/67317731564/steps/bugswarm_5.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=5 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR='copybara-service[bot]' GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=google/guava GITHUB_REPOSITORY_OWNER=google GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=e35bf7d85ad58bb1fbcdb6c6869e7cb532b99dae GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 ROOT_POM=pom.xml "${CURRENT_ENV[@]}" \
bash --noprofile --norc -eo pipefail /home/github/67317731564/steps/bugswarm_5.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=5 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR='copybara-service[bot]' GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=google/guava GITHUB_REPOSITORY_OWNER=google GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=e35bf7d85ad58bb1fbcdb6c6869e7cb532b99dae GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 ROOT_POM=pom.xml "${CURRENT_ENV[@]}" \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=5 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR='copybara-service[bot]' GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=google/guava GITHUB_REPOSITORY_OWNER=google GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=e35bf7d85ad58bb1fbcdb6c6869e7cb532b99dae GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 ROOT_POM=pom.xml "${CURRENT_ENV[@]}" \
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=6 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=gradle/actions GITHUB_ACTIONS=true GITHUB_ACTOR='copybara-service[bot]' GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=google/guava GITHUB_REPOSITORY_OWNER=google GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=e35bf7d85ad58bb1fbcdb6c6869e7cb532b99dae GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 GITHUB_ACTION_PATH=/home/github/67317731564/actions/gradle-actions@0723195856401067f7a2779048b490ace7a47d7c/setup-gradle ROOT_POM=pom.xml "${CURRENT_ENV[@]}" INPUT_CACHE-DISABLED=false INPUT_CACHE-READ-ONLY="$(/home/github/67317731564/helpers/eval_expression p:'(' l:'{"allow_forking": true, "archive_url": "https://api.github.com/repos/google/guava/{archive_format}{/ref}", "archived": false, "assignees_url": "https://api.github.com/repos/google/guava/assignees{/user}", "blobs_url": "https://api.github.com/repos/google/guava/git/blobs{/sha}", "branches_url": "https://api.github.com/repos/google/guava/branches{/branch}", "clone_url": "https://github.com/google/guava.git", "collaborators_url": "https://api.github.com/repos/google/guava/collaborators{/collaborator}", "comments_url": "https://api.github.com/repos/google/guava/comments{/number}", "commits_url": "https://api.github.com/repos/google/guava/commits{/sha}", "compare_url": "https://api.github.com/repos/google/guava/compare/{base}...{head}", "contents_url": "https://api.github.com/repos/google/guava/contents/{+path}", "contributors_url": "https://api.github.com/repos/google/guava/contributors", "created_at": 0, "default_branch": "master", "deployments_url": "https://api.github.com/repos/google/guava/deployments", "description": "Google core libraries for Java", "disabled": false, "downloads_url": "https://api.github.com/repos/google/guava/downloads", "events_url": "https://api.github.com/repos/google/guava/events", "fork": false, "forks": 0, "forks_count": 0, "forks_url": "https://api.github.com/repos/google/guava/forks", "full_name": "google/guava", "git_commits_url": "https://api.github.com/repos/google/guava/git/commits{/sha}", "git_refs_url": "https://api.github.com/repos/google/guava/git/refs{/sha}", "git_tags_url": "https://api.github.com/repos/google/guava/git/tags{/sha}", "git_url": "git://github.com/google/guava.git", "has_downloads": true, "has_issues": true, "has_pages": true, "has_projects": true, "has_wiki": true, "homepage": null, "hooks_url": "https://api.github.com/repos/google/guava/hooks", "html_url": "https://github.com/google/guava", "id": 20300177, "is_template": false, "issue_comment_url": "https://api.github.com/repos/google/guava/issues/comments{/number}", "issue_events_url": "https://api.github.com/repos/google/guava/issues/events{/number}", "issues_url": "https://api.github.com/repos/google/guava/issues{/number}", "keys_url": "https://api.github.com/repos/google/guava/keys{/key_id}", "labels_url": "https://api.github.com/repos/google/guava/labels{/name}", "language": "", "languages_url": "https://api.github.com/repos/google/guava/languages", "license": null, "master_branch": "master", "merges_url": "https://api.github.com/repos/google/guava/merges", "milestones_url": "https://api.github.com/repos/google/guava/milestones{/number}", "mirror_url": null, "name": "guava", "node_id": "MDEwOlJlcG9zaXRvcnkyMDMwMDE3Nw==", "notifications_url": "https://api.github.com/repos/google/guava/notifications{?since,all,participating}", "open_issues": 0, "open_issues_count": 0, "owner": {"avatar_url": "https://avatars.githubusercontent.com/u/1342004?v=4", "email": "", "events_url": "https://api.github.com/users/google/events{/privacy}", "followers_url": "https://api.github.com/users/google/followers", "following_url": "https://api.github.com/users/google/following{/other_user}", "gists_url": "https://api.github.com/users/google/gists{/gist_id}", "gravatar_id": "", "html_url": "https://github.com/google", "id": 1342004, "login": "google", "name": "google", "node_id": "MDEyOk9yZ2FuaXphdGlvbjEzNDIwMDQ=", "organizations_url": "https://api.github.com/users/google/orgs", "received_events_url": "https://api.github.com/users/google/received_events", "repos_url": "https://api.github.com/users/google/repos", "site_admin": false, "starred_url": "https://api.github.com/users/google/starred{/owner}{/repo}", "subscriptions_url": "https://api.github.com/users/google/subscriptions", "type": "Organization", "url": "https://api.github.com/users/google"}, "private": false, "pulls_url": "https://api.github.com/repos/google/guava/pulls{/number}", "pushed_at": 0, "releases_url": "https://api.github.com/repos/google/guava/releases{/id}", "size": 0, "ssh_url": "git@github.com:google/guava.git", "stargazers": 0, "stargazers_count": 0, "stargazers_url": "https://api.github.com/repos/google/guava/stargazers", "statuses_url": "https://api.github.com/repos/google/guava/statuses/{sha}", "subscribers_url": "https://api.github.com/repos/google/guava/subscribers", "subscription_url": "https://api.github.com/repos/google/guava/subscription", "svn_url": "https://github.com/google/guava", "tags_url": "https://api.github.com/repos/google/guava/tags", "teams_url": "https://api.github.com/repos/google/guava/teams", "topics": [], "trees_url": "https://api.github.com/repos/google/guava/git/trees{/sha}", "updated_at": "2026-03-16T22:45:21Z", "url": "https://api.github.com/repos/google/guava", "visibility": "public", "watchers": 0, "watchers_count": 0, "web_commit_signoff_required": false}' o:'!=' l:'' p:')' o:'&&' p:'(' s:master o:'!=' s:master p:')')" INPUT_CACHE-WRITE-ONLY=false INPUT_CACHE-OVERWRITE-EXISTING=false INPUT_CACHE-CLEANUP=on-success INPUT_GRADLE-HOME-CACHE-INCLUDES='caches
notifications
' INPUT_ADD-JOB-SUMMARY=always INPUT_ADD-JOB-SUMMARY-AS-PR-COMMENT=never INPUT_DEPENDENCY-GRAPH=disabled INPUT_DEPENDENCY-GRAPH-REPORT-DIR=dependency-graph-reports INPUT_DEPENDENCY-GRAPH-CONTINUE-ON-FAILURE=true INPUT_BUILD-SCAN-PUBLISH=false INPUT_VALIDATE-WRAPPERS=true INPUT_ALLOW-SNAPSHOT-WRAPPERS=false INPUT_GRADLE-HOME-CACHE-STRICT-MATCH=false INPUT_WORKFLOW-JOB-CONTEXT="$(/home/github/67317731564/helpers/eval_expression p:'(' f:toJSON p:'(' l:'{"os": "ubuntu-latest", "java": 11, "root-pom": "pom.xml"}' p:')' p:')')" INPUT_GITHUB-TOKEN=DUMMY \
echo "$(/home/github/67317731564/helpers/eval_expression p:'(' f:success p:'(' p:')' p:')' o:'&&' p:'(' l:11 o:== n:11 p:')')")
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=6 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=gradle/actions GITHUB_ACTIONS=true GITHUB_ACTOR='copybara-service[bot]' GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=google/guava GITHUB_REPOSITORY_OWNER=google GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=e35bf7d85ad58bb1fbcdb6c6869e7cb532b99dae GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 GITHUB_ACTION_PATH=/home/github/67317731564/actions/gradle-actions@0723195856401067f7a2779048b490ace7a47d7c/setup-gradle ROOT_POM=pom.xml "${CURRENT_ENV[@]}" INPUT_CACHE-DISABLED=false INPUT_CACHE-READ-ONLY="$(/home/github/67317731564/helpers/eval_expression p:'(' l:'{"allow_forking": true, "archive_url": "https://api.github.com/repos/google/guava/{archive_format}{/ref}", "archived": false, "assignees_url": "https://api.github.com/repos/google/guava/assignees{/user}", "blobs_url": "https://api.github.com/repos/google/guava/git/blobs{/sha}", "branches_url": "https://api.github.com/repos/google/guava/branches{/branch}", "clone_url": "https://github.com/google/guava.git", "collaborators_url": "https://api.github.com/repos/google/guava/collaborators{/collaborator}", "comments_url": "https://api.github.com/repos/google/guava/comments{/number}", "commits_url": "https://api.github.com/repos/google/guava/commits{/sha}", "compare_url": "https://api.github.com/repos/google/guava/compare/{base}...{head}", "contents_url": "https://api.github.com/repos/google/guava/contents/{+path}", "contributors_url": "https://api.github.com/repos/google/guava/contributors", "created_at": 0, "default_branch": "master", "deployments_url": "https://api.github.com/repos/google/guava/deployments", "description": "Google core libraries for Java", "disabled": false, "downloads_url": "https://api.github.com/repos/google/guava/downloads", "events_url": "https://api.github.com/repos/google/guava/events", "fork": false, "forks": 0, "forks_count": 0, "forks_url": "https://api.github.com/repos/google/guava/forks", "full_name": "google/guava", "git_commits_url": "https://api.github.com/repos/google/guava/git/commits{/sha}", "git_refs_url": "https://api.github.com/repos/google/guava/git/refs{/sha}", "git_tags_url": "https://api.github.com/repos/google/guava/git/tags{/sha}", "git_url": "git://github.com/google/guava.git", "has_downloads": true, "has_issues": true, "has_pages": true, "has_projects": true, "has_wiki": true, "homepage": null, "hooks_url": "https://api.github.com/repos/google/guava/hooks", "html_url": "https://github.com/google/guava", "id": 20300177, "is_template": false, "issue_comment_url": "https://api.github.com/repos/google/guava/issues/comments{/number}", "issue_events_url": "https://api.github.com/repos/google/guava/issues/events{/number}", "issues_url": "https://api.github.com/repos/google/guava/issues{/number}", "keys_url": "https://api.github.com/repos/google/guava/keys{/key_id}", "labels_url": "https://api.github.com/repos/google/guava/labels{/name}", "language": "", "languages_url": "https://api.github.com/repos/google/guava/languages", "license": null, "master_branch": "master", "merges_url": "https://api.github.com/repos/google/guava/merges", "milestones_url": "https://api.github.com/repos/google/guava/milestones{/number}", "mirror_url": null, "name": "guava", "node_id": "MDEwOlJlcG9zaXRvcnkyMDMwMDE3Nw==", "notifications_url": "https://api.github.com/repos/google/guava/notifications{?since,all,participating}", "open_issues": 0, "open_issues_count": 0, "owner": {"avatar_url": "https://avatars.githubusercontent.com/u/1342004?v=4", "email": "", "events_url": "https://api.github.com/users/google/events{/privacy}", "followers_url": "https://api.github.com/users/google/followers", "following_url": "https://api.github.com/users/google/following{/other_user}", "gists_url": "https://api.github.com/users/google/gists{/gist_id}", "gravatar_id": "", "html_url": "https://github.com/google", "id": 1342004, "login": "google", "name": "google", "node_id": "MDEyOk9yZ2FuaXphdGlvbjEzNDIwMDQ=", "organizations_url": "https://api.github.com/users/google/orgs", "received_events_url": "https://api.github.com/users/google/received_events", "repos_url": "https://api.github.com/users/google/repos", "site_admin": false, "starred_url": "https://api.github.com/users/google/starred{/owner}{/repo}", "subscriptions_url": "https://api.github.com/users/google/subscriptions", "type": "Organization", "url": "https://api.github.com/users/google"}, "private": false, "pulls_url": "https://api.github.com/repos/google/guava/pulls{/number}", "pushed_at": 0, "releases_url": "https://api.github.com/repos/google/guava/releases{/id}", "size": 0, "ssh_url": "git@github.com:google/guava.git", "stargazers": 0, "stargazers_count": 0, "stargazers_url": "https://api.github.com/repos/google/guava/stargazers", "statuses_url": "https://api.github.com/repos/google/guava/statuses/{sha}", "subscribers_url": "https://api.github.com/repos/google/guava/subscribers", "subscription_url": "https://api.github.com/repos/google/guava/subscription", "svn_url": "https://github.com/google/guava", "tags_url": "https://api.github.com/repos/google/guava/tags", "teams_url": "https://api.github.com/repos/google/guava/teams", "topics": [], "trees_url": "https://api.github.com/repos/google/guava/git/trees{/sha}", "updated_at": "2026-03-16T22:45:21Z", "url": "https://api.github.com/repos/google/guava", "visibility": "public", "watchers": 0, "watchers_count": 0, "web_commit_signoff_required": false}' o:'!=' l:'' p:')' o:'&&' p:'(' s:master o:'!=' s:master p:')')" INPUT_CACHE-WRITE-ONLY=false INPUT_CACHE-OVERWRITE-EXISTING=false INPUT_CACHE-CLEANUP=on-success INPUT_GRADLE-HOME-CACHE-INCLUDES='caches
notifications
' INPUT_ADD-JOB-SUMMARY=always INPUT_ADD-JOB-SUMMARY-AS-PR-COMMENT=never INPUT_DEPENDENCY-GRAPH=disabled INPUT_DEPENDENCY-GRAPH-REPORT-DIR=dependency-graph-reports INPUT_DEPENDENCY-GRAPH-CONTINUE-ON-FAILURE=true INPUT_BUILD-SCAN-PUBLISH=false INPUT_VALIDATE-WRAPPERS=true INPUT_ALLOW-SNAPSHOT-WRAPPERS=false INPUT_GRADLE-HOME-CACHE-STRICT-MATCH=false INPUT_WORKFLOW-JOB-CONTEXT="$(/home/github/67317731564/helpers/eval_expression p:'(' f:toJSON p:'(' l:'{"os": "ubuntu-latest", "java": 11, "root-pom": "pom.xml"}' p:')' p:')')" INPUT_GITHUB-TOKEN=DUMMY \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run gradle/actions/setup-gradle@0723195856401067f7a2779048b490ace7a47d7c
echo "##[endgroup]"
echo node /home/github/67317731564/actions/gradle-actions@0723195856401067f7a2779048b490ace7a47d7c/setup-gradle/../dist/setup-gradle/main/index.js > /home/github/67317731564/steps/bugswarm_cmd.sh
chmod u+x /home/github/67317731564/steps/bugswarm_cmd.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=6 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=gradle/actions GITHUB_ACTIONS=true GITHUB_ACTOR='copybara-service[bot]' GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=google/guava GITHUB_REPOSITORY_OWNER=google GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=e35bf7d85ad58bb1fbcdb6c6869e7cb532b99dae GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 GITHUB_ACTION_PATH=/home/github/67317731564/actions/gradle-actions@0723195856401067f7a2779048b490ace7a47d7c/setup-gradle ROOT_POM=pom.xml "${CURRENT_ENV[@]}" INPUT_CACHE-DISABLED=false INPUT_CACHE-READ-ONLY="$(/home/github/67317731564/helpers/eval_expression p:'(' l:'{"allow_forking": true, "archive_url": "https://api.github.com/repos/google/guava/{archive_format}{/ref}", "archived": false, "assignees_url": "https://api.github.com/repos/google/guava/assignees{/user}", "blobs_url": "https://api.github.com/repos/google/guava/git/blobs{/sha}", "branches_url": "https://api.github.com/repos/google/guava/branches{/branch}", "clone_url": "https://github.com/google/guava.git", "collaborators_url": "https://api.github.com/repos/google/guava/collaborators{/collaborator}", "comments_url": "https://api.github.com/repos/google/guava/comments{/number}", "commits_url": "https://api.github.com/repos/google/guava/commits{/sha}", "compare_url": "https://api.github.com/repos/google/guava/compare/{base}...{head}", "contents_url": "https://api.github.com/repos/google/guava/contents/{+path}", "contributors_url": "https://api.github.com/repos/google/guava/contributors", "created_at": 0, "default_branch": "master", "deployments_url": "https://api.github.com/repos/google/guava/deployments", "description": "Google core libraries for Java", "disabled": false, "downloads_url": "https://api.github.com/repos/google/guava/downloads", "events_url": "https://api.github.com/repos/google/guava/events", "fork": false, "forks": 0, "forks_count": 0, "forks_url": "https://api.github.com/repos/google/guava/forks", "full_name": "google/guava", "git_commits_url": "https://api.github.com/repos/google/guava/git/commits{/sha}", "git_refs_url": "https://api.github.com/repos/google/guava/git/refs{/sha}", "git_tags_url": "https://api.github.com/repos/google/guava/git/tags{/sha}", "git_url": "git://github.com/google/guava.git", "has_downloads": true, "has_issues": true, "has_pages": true, "has_projects": true, "has_wiki": true, "homepage": null, "hooks_url": "https://api.github.com/repos/google/guava/hooks", "html_url": "https://github.com/google/guava", "id": 20300177, "is_template": false, "issue_comment_url": "https://api.github.com/repos/google/guava/issues/comments{/number}", "issue_events_url": "https://api.github.com/repos/google/guava/issues/events{/number}", "issues_url": "https://api.github.com/repos/google/guava/issues{/number}", "keys_url": "https://api.github.com/repos/google/guava/keys{/key_id}", "labels_url": "https://api.github.com/repos/google/guava/labels{/name}", "language": "", "languages_url": "https://api.github.com/repos/google/guava/languages", "license": null, "master_branch": "master", "merges_url": "https://api.github.com/repos/google/guava/merges", "milestones_url": "https://api.github.com/repos/google/guava/milestones{/number}", "mirror_url": null, "name": "guava", "node_id": "MDEwOlJlcG9zaXRvcnkyMDMwMDE3Nw==", "notifications_url": "https://api.github.com/repos/google/guava/notifications{?since,all,participating}", "open_issues": 0, "open_issues_count": 0, "owner": {"avatar_url": "https://avatars.githubusercontent.com/u/1342004?v=4", "email": "", "events_url": "https://api.github.com/users/google/events{/privacy}", "followers_url": "https://api.github.com/users/google/followers", "following_url": "https://api.github.com/users/google/following{/other_user}", "gists_url": "https://api.github.com/users/google/gists{/gist_id}", "gravatar_id": "", "html_url": "https://github.com/google", "id": 1342004, "login": "google", "name": "google", "node_id": "MDEyOk9yZ2FuaXphdGlvbjEzNDIwMDQ=", "organizations_url": "https://api.github.com/users/google/orgs", "received_events_url": "https://api.github.com/users/google/received_events", "repos_url": "https://api.github.com/users/google/repos", "site_admin": false, "starred_url": "https://api.github.com/users/google/starred{/owner}{/repo}", "subscriptions_url": "https://api.github.com/users/google/subscriptions", "type": "Organization", "url": "https://api.github.com/users/google"}, "private": false, "pulls_url": "https://api.github.com/repos/google/guava/pulls{/number}", "pushed_at": 0, "releases_url": "https://api.github.com/repos/google/guava/releases{/id}", "size": 0, "ssh_url": "git@github.com:google/guava.git", "stargazers": 0, "stargazers_count": 0, "stargazers_url": "https://api.github.com/repos/google/guava/stargazers", "statuses_url": "https://api.github.com/repos/google/guava/statuses/{sha}", "subscribers_url": "https://api.github.com/repos/google/guava/subscribers", "subscription_url": "https://api.github.com/repos/google/guava/subscription", "svn_url": "https://github.com/google/guava", "tags_url": "https://api.github.com/repos/google/guava/tags", "teams_url": "https://api.github.com/repos/google/guava/teams", "topics": [], "trees_url": "https://api.github.com/repos/google/guava/git/trees{/sha}", "updated_at": "2026-03-16T22:45:21Z", "url": "https://api.github.com/repos/google/guava", "visibility": "public", "watchers": 0, "watchers_count": 0, "web_commit_signoff_required": false}' o:'!=' l:'' p:')' o:'&&' p:'(' s:master o:'!=' s:master p:')')" INPUT_CACHE-WRITE-ONLY=false INPUT_CACHE-OVERWRITE-EXISTING=false INPUT_CACHE-CLEANUP=on-success INPUT_GRADLE-HOME-CACHE-INCLUDES='caches
notifications
' INPUT_ADD-JOB-SUMMARY=always INPUT_ADD-JOB-SUMMARY-AS-PR-COMMENT=never INPUT_DEPENDENCY-GRAPH=disabled INPUT_DEPENDENCY-GRAPH-REPORT-DIR=dependency-graph-reports INPUT_DEPENDENCY-GRAPH-CONTINUE-ON-FAILURE=true INPUT_BUILD-SCAN-PUBLISH=false INPUT_VALIDATE-WRAPPERS=true INPUT_ALLOW-SNAPSHOT-WRAPPERS=false INPUT_GRADLE-HOME-CACHE-STRICT-MATCH=false INPUT_WORKFLOW-JOB-CONTEXT="$(/home/github/67317731564/helpers/eval_expression p:'(' f:toJSON p:'(' l:'{"os": "ubuntu-latest", "java": 11, "root-pom": "pom.xml"}' p:')' p:')')" INPUT_GITHUB-TOKEN=DUMMY \
bash -e /home/github/67317731564/steps/bugswarm_cmd.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=6 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=gradle/actions GITHUB_ACTIONS=true GITHUB_ACTOR='copybara-service[bot]' GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=google/guava GITHUB_REPOSITORY_OWNER=google GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=e35bf7d85ad58bb1fbcdb6c6869e7cb532b99dae GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 GITHUB_ACTION_PATH=/home/github/67317731564/actions/gradle-actions@0723195856401067f7a2779048b490ace7a47d7c/setup-gradle ROOT_POM=pom.xml "${CURRENT_ENV[@]}" INPUT_CACHE-DISABLED=false INPUT_CACHE-READ-ONLY="$(/home/github/67317731564/helpers/eval_expression p:'(' l:'{"allow_forking": true, "archive_url": "https://api.github.com/repos/google/guava/{archive_format}{/ref}", "archived": false, "assignees_url": "https://api.github.com/repos/google/guava/assignees{/user}", "blobs_url": "https://api.github.com/repos/google/guava/git/blobs{/sha}", "branches_url": "https://api.github.com/repos/google/guava/branches{/branch}", "clone_url": "https://github.com/google/guava.git", "collaborators_url": "https://api.github.com/repos/google/guava/collaborators{/collaborator}", "comments_url": "https://api.github.com/repos/google/guava/comments{/number}", "commits_url": "https://api.github.com/repos/google/guava/commits{/sha}", "compare_url": "https://api.github.com/repos/google/guava/compare/{base}...{head}", "contents_url": "https://api.github.com/repos/google/guava/contents/{+path}", "contributors_url": "https://api.github.com/repos/google/guava/contributors", "created_at": 0, "default_branch": "master", "deployments_url": "https://api.github.com/repos/google/guava/deployments", "description": "Google core libraries for Java", "disabled": false, "downloads_url": "https://api.github.com/repos/google/guava/downloads", "events_url": "https://api.github.com/repos/google/guava/events", "fork": false, "forks": 0, "forks_count": 0, "forks_url": "https://api.github.com/repos/google/guava/forks", "full_name": "google/guava", "git_commits_url": "https://api.github.com/repos/google/guava/git/commits{/sha}", "git_refs_url": "https://api.github.com/repos/google/guava/git/refs{/sha}", "git_tags_url": "https://api.github.com/repos/google/guava/git/tags{/sha}", "git_url": "git://github.com/google/guava.git", "has_downloads": true, "has_issues": true, "has_pages": true, "has_projects": true, "has_wiki": true, "homepage": null, "hooks_url": "https://api.github.com/repos/google/guava/hooks", "html_url": "https://github.com/google/guava", "id": 20300177, "is_template": false, "issue_comment_url": "https://api.github.com/repos/google/guava/issues/comments{/number}", "issue_events_url": "https://api.github.com/repos/google/guava/issues/events{/number}", "issues_url": "https://api.github.com/repos/google/guava/issues{/number}", "keys_url": "https://api.github.com/repos/google/guava/keys{/key_id}", "labels_url": "https://api.github.com/repos/google/guava/labels{/name}", "language": "", "languages_url": "https://api.github.com/repos/google/guava/languages", "license": null, "master_branch": "master", "merges_url": "https://api.github.com/repos/google/guava/merges", "milestones_url": "https://api.github.com/repos/google/guava/milestones{/number}", "mirror_url": null, "name": "guava", "node_id": "MDEwOlJlcG9zaXRvcnkyMDMwMDE3Nw==", "notifications_url": "https://api.github.com/repos/google/guava/notifications{?since,all,participating}", "open_issues": 0, "open_issues_count": 0, "owner": {"avatar_url": "https://avatars.githubusercontent.com/u/1342004?v=4", "email": "", "events_url": "https://api.github.com/users/google/events{/privacy}", "followers_url": "https://api.github.com/users/google/followers", "following_url": "https://api.github.com/users/google/following{/other_user}", "gists_url": "https://api.github.com/users/google/gists{/gist_id}", "gravatar_id": "", "html_url": "https://github.com/google", "id": 1342004, "login": "google", "name": "google", "node_id": "MDEyOk9yZ2FuaXphdGlvbjEzNDIwMDQ=", "organizations_url": "https://api.github.com/users/google/orgs", "received_events_url": "https://api.github.com/users/google/received_events", "repos_url": "https://api.github.com/users/google/repos", "site_admin": false, "starred_url": "https://api.github.com/users/google/starred{/owner}{/repo}", "subscriptions_url": "https://api.github.com/users/google/subscriptions", "type": "Organization", "url": "https://api.github.com/users/google"}, "private": false, "pulls_url": "https://api.github.com/repos/google/guava/pulls{/number}", "pushed_at": 0, "releases_url": "https://api.github.com/repos/google/guava/releases{/id}", "size": 0, "ssh_url": "git@github.com:google/guava.git", "stargazers": 0, "stargazers_count": 0, "stargazers_url": "https://api.github.com/repos/google/guava/stargazers", "statuses_url": "https://api.github.com/repos/google/guava/statuses/{sha}", "subscribers_url": "https://api.github.com/repos/google/guava/subscribers", "subscription_url": "https://api.github.com/repos/google/guava/subscription", "svn_url": "https://github.com/google/guava", "tags_url": "https://api.github.com/repos/google/guava/tags", "teams_url": "https://api.github.com/repos/google/guava/teams", "topics": [], "trees_url": "https://api.github.com/repos/google/guava/git/trees{/sha}", "updated_at": "2026-03-16T22:45:21Z", "url": "https://api.github.com/repos/google/guava", "visibility": "public", "watchers": 0, "watchers_count": 0, "web_commit_signoff_required": false}' o:'!=' l:'' p:')' o:'&&' p:'(' s:master o:'!=' s:master p:')')" INPUT_CACHE-WRITE-ONLY=false INPUT_CACHE-OVERWRITE-EXISTING=false INPUT_CACHE-CLEANUP=on-success INPUT_GRADLE-HOME-CACHE-INCLUDES='caches
notifications
' INPUT_ADD-JOB-SUMMARY=always INPUT_ADD-JOB-SUMMARY-AS-PR-COMMENT=never INPUT_DEPENDENCY-GRAPH=disabled INPUT_DEPENDENCY-GRAPH-REPORT-DIR=dependency-graph-reports INPUT_DEPENDENCY-GRAPH-CONTINUE-ON-FAILURE=true INPUT_BUILD-SCAN-PUBLISH=false INPUT_VALIDATE-WRAPPERS=true INPUT_ALLOW-SNAPSHOT-WRAPPERS=false INPUT_GRADLE-HOME-CACHE-STRICT-MATCH=false INPUT_WORKFLOW-JOB-CONTEXT="$(/home/github/67317731564/helpers/eval_expression p:'(' f:toJSON p:'(' l:'{"os": "ubuntu-latest", "java": 11, "root-pom": "pom.xml"}' p:')' p:')')" INPUT_GITHUB-TOKEN=DUMMY \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=6 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=gradle/actions GITHUB_ACTIONS=true GITHUB_ACTOR='copybara-service[bot]' GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=google/guava GITHUB_REPOSITORY_OWNER=google GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=e35bf7d85ad58bb1fbcdb6c6869e7cb532b99dae GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 GITHUB_ACTION_PATH=/home/github/67317731564/actions/gradle-actions@0723195856401067f7a2779048b490ace7a47d7c/setup-gradle ROOT_POM=pom.xml "${CURRENT_ENV[@]}" INPUT_CACHE-DISABLED=false INPUT_CACHE-READ-ONLY="$(/home/github/67317731564/helpers/eval_expression p:'(' l:'{"allow_forking": true, "archive_url": "https://api.github.com/repos/google/guava/{archive_format}{/ref}", "archived": false, "assignees_url": "https://api.github.com/repos/google/guava/assignees{/user}", "blobs_url": "https://api.github.com/repos/google/guava/git/blobs{/sha}", "branches_url": "https://api.github.com/repos/google/guava/branches{/branch}", "clone_url": "https://github.com/google/guava.git", "collaborators_url": "https://api.github.com/repos/google/guava/collaborators{/collaborator}", "comments_url": "https://api.github.com/repos/google/guava/comments{/number}", "commits_url": "https://api.github.com/repos/google/guava/commits{/sha}", "compare_url": "https://api.github.com/repos/google/guava/compare/{base}...{head}", "contents_url": "https://api.github.com/repos/google/guava/contents/{+path}", "contributors_url": "https://api.github.com/repos/google/guava/contributors", "created_at": 0, "default_branch": "master", "deployments_url": "https://api.github.com/repos/google/guava/deployments", "description": "Google core libraries for Java", "disabled": false, "downloads_url": "https://api.github.com/repos/google/guava/downloads", "events_url": "https://api.github.com/repos/google/guava/events", "fork": false, "forks": 0, "forks_count": 0, "forks_url": "https://api.github.com/repos/google/guava/forks", "full_name": "google/guava", "git_commits_url": "https://api.github.com/repos/google/guava/git/commits{/sha}", "git_refs_url": "https://api.github.com/repos/google/guava/git/refs{/sha}", "git_tags_url": "https://api.github.com/repos/google/guava/git/tags{/sha}", "git_url": "git://github.com/google/guava.git", "has_downloads": true, "has_issues": true, "has_pages": true, "has_projects": true, "has_wiki": true, "homepage": null, "hooks_url": "https://api.github.com/repos/google/guava/hooks", "html_url": "https://github.com/google/guava", "id": 20300177, "is_template": false, "issue_comment_url": "https://api.github.com/repos/google/guava/issues/comments{/number}", "issue_events_url": "https://api.github.com/repos/google/guava/issues/events{/number}", "issues_url": "https://api.github.com/repos/google/guava/issues{/number}", "keys_url": "https://api.github.com/repos/google/guava/keys{/key_id}", "labels_url": "https://api.github.com/repos/google/guava/labels{/name}", "language": "", "languages_url": "https://api.github.com/repos/google/guava/languages", "license": null, "master_branch": "master", "merges_url": "https://api.github.com/repos/google/guava/merges", "milestones_url": "https://api.github.com/repos/google/guava/milestones{/number}", "mirror_url": null, "name": "guava", "node_id": "MDEwOlJlcG9zaXRvcnkyMDMwMDE3Nw==", "notifications_url": "https://api.github.com/repos/google/guava/notifications{?since,all,participating}", "open_issues": 0, "open_issues_count": 0, "owner": {"avatar_url": "https://avatars.githubusercontent.com/u/1342004?v=4", "email": "", "events_url": "https://api.github.com/users/google/events{/privacy}", "followers_url": "https://api.github.com/users/google/followers", "following_url": "https://api.github.com/users/google/following{/other_user}", "gists_url": "https://api.github.com/users/google/gists{/gist_id}", "gravatar_id": "", "html_url": "https://github.com/google", "id": 1342004, "login": "google", "name": "google", "node_id": "MDEyOk9yZ2FuaXphdGlvbjEzNDIwMDQ=", "organizations_url": "https://api.github.com/users/google/orgs", "received_events_url": "https://api.github.com/users/google/received_events", "repos_url": "https://api.github.com/users/google/repos", "site_admin": false, "starred_url": "https://api.github.com/users/google/starred{/owner}{/repo}", "subscriptions_url": "https://api.github.com/users/google/subscriptions", "type": "Organization", "url": "https://api.github.com/users/google"}, "private": false, "pulls_url": "https://api.github.com/repos/google/guava/pulls{/number}", "pushed_at": 0, "releases_url": "https://api.github.com/repos/google/guava/releases{/id}", "size": 0, "ssh_url": "git@github.com:google/guava.git", "stargazers": 0, "stargazers_count": 0, "stargazers_url": "https://api.github.com/repos/google/guava/stargazers", "statuses_url": "https://api.github.com/repos/google/guava/statuses/{sha}", "subscribers_url": "https://api.github.com/repos/google/guava/subscribers", "subscription_url": "https://api.github.com/repos/google/guava/subscription", "svn_url": "https://github.com/google/guava", "tags_url": "https://api.github.com/repos/google/guava/tags", "teams_url": "https://api.github.com/repos/google/guava/teams", "topics": [], "trees_url": "https://api.github.com/repos/google/guava/git/trees{/sha}", "updated_at": "2026-03-16T22:45:21Z", "url": "https://api.github.com/repos/google/guava", "visibility": "public", "watchers": 0, "watchers_count": 0, "web_commit_signoff_required": false}' o:'!=' l:'' p:')' o:'&&' p:'(' s:master o:'!=' s:master p:')')" INPUT_CACHE-WRITE-ONLY=false INPUT_CACHE-OVERWRITE-EXISTING=false INPUT_CACHE-CLEANUP=on-success INPUT_GRADLE-HOME-CACHE-INCLUDES='caches
notifications
' INPUT_ADD-JOB-SUMMARY=always INPUT_ADD-JOB-SUMMARY-AS-PR-COMMENT=never INPUT_DEPENDENCY-GRAPH=disabled INPUT_DEPENDENCY-GRAPH-REPORT-DIR=dependency-graph-reports INPUT_DEPENDENCY-GRAPH-CONTINUE-ON-FAILURE=true INPUT_BUILD-SCAN-PUBLISH=false INPUT_VALIDATE-WRAPPERS=true INPUT_ALLOW-SNAPSHOT-WRAPPERS=false INPUT_GRADLE-HOME-CACHE-STRICT-MATCH=false INPUT_WORKFLOW-JOB-CONTEXT="$(/home/github/67317731564/helpers/eval_expression p:'(' f:toJSON p:'(' l:'{"os": "ubuntu-latest", "java": 11, "root-pom": "pom.xml"}' p:')' p:')')" INPUT_GITHUB-TOKEN=DUMMY \
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=7 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR='copybara-service[bot]' GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=google/guava GITHUB_REPOSITORY_OWNER=google GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=e35bf7d85ad58bb1fbcdb6c6869e7cb532b99dae GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 ROOT_POM=pom.xml "${CURRENT_ENV[@]}" \
echo "$(/home/github/67317731564/helpers/eval_expression p:'(' f:success p:'(' p:')' p:')' o:'&&' p:'(' l:11 o:== n:11 p:')')")
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=7 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR='copybara-service[bot]' GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=google/guava GITHUB_REPOSITORY_OWNER=google GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=e35bf7d85ad58bb1fbcdb6c6869e7cb532b99dae GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 ROOT_POM=pom.xml "${CURRENT_ENV[@]}" \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run util/gradle_integration_tests.sh
echo "##[endgroup]"
echo util/gradle_integration_tests.sh > /home/github/67317731564/steps/bugswarm_7.sh
chmod u+x /home/github/67317731564/steps/bugswarm_7.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=7 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR='copybara-service[bot]' GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=google/guava GITHUB_REPOSITORY_OWNER=google GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=e35bf7d85ad58bb1fbcdb6c6869e7cb532b99dae GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 ROOT_POM=pom.xml "${CURRENT_ENV[@]}" \
bash --noprofile --norc -eo pipefail /home/github/67317731564/steps/bugswarm_7.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=7 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR='copybara-service[bot]' GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=google/guava GITHUB_REPOSITORY_OWNER=google GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=e35bf7d85ad58bb1fbcdb6c6869e7cb532b99dae GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 ROOT_POM=pom.xml "${CURRENT_ENV[@]}" \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=7 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR='copybara-service[bot]' GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=google/guava GITHUB_REPOSITORY_OWNER=google GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=e35bf7d85ad58bb1fbcdb6c6869e7cb532b99dae GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 ROOT_POM=pom.xml "${CURRENT_ENV[@]}" \
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
   bash -e $ACTIONS_RUNNER_HOOK_JOB_COMPLETED 67317731564 passed
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
