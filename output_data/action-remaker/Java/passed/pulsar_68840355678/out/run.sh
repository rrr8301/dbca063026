#!/usr/bin/env bash
export GITHUB_WORKSPACE=/home/github/build/apache/pulsar

if [[ ! -z "$ACTIONS_RUNNER_HOOK_JOB_STARTED" ]]; then
   echo "A job started hook has been configured by the self-hosted runner administrator"
   echo "##[group]Run '$ACTIONS_RUNNER_HOOK_JOB_STARTED'"
   echo "##[endgroup]"
   bash -e $ACTIONS_RUNNER_HOOK_JOB_STARTED 68840355678 passed
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

cp /home/github/68840355678/event.json /home/github/workflow/event.json
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=1 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=apache/pulsar GITHUB_ACTIONS=true GITHUB_ACTOR=lhotari GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/pulsar GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=1a457bbbab464417d5a101ddc7d5d75f16484dd4 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Pulsar CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 ARTIFACT_RETENTION_DAYS=3 JDK_DISTRIBUTION=corretto GITHUB_ACTION_PATH=/home/github/68840355678/actions/apache-pulsar/./.github/actions/tune-runner-vm JOB_NAME='CI - Integration - Shade on Java 17' PULSAR_TEST_IMAGE_NAME=apachepulsar/java-test-image:latest DEVELOCITY_ACCESS_KEY= CI_JDK_MAJOR_VERSION= "${CURRENT_ENV[@]}" \
echo $(test "$_GITHUB_JOB_STATUS" = "success" && echo true || echo false))
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=1 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=apache/pulsar GITHUB_ACTIONS=true GITHUB_ACTOR=lhotari GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/pulsar GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=1a457bbbab464417d5a101ddc7d5d75f16484dd4 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Pulsar CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 ARTIFACT_RETENTION_DAYS=3 JDK_DISTRIBUTION=corretto GITHUB_ACTION_PATH=/home/github/68840355678/actions/apache-pulsar/./.github/actions/tune-runner-vm JOB_NAME='CI - Integration - Shade on Java 17' PULSAR_TEST_IMAGE_NAME=apachepulsar/java-test-image:latest DEVELOCITY_ACCESS_KEY= CI_JDK_MAJOR_VERSION= "${CURRENT_ENV[@]}" \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run ./.github/actions/tune-runner-vm
echo "##[endgroup]"
echo /home/github/68840355678/steps/bugswarm_1_composite.sh > /home/github/68840355678/steps/bugswarm_1.sh
chmod u+x /home/github/68840355678/steps/bugswarm_1.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=1 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=apache/pulsar GITHUB_ACTIONS=true GITHUB_ACTOR=lhotari GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/pulsar GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=1a457bbbab464417d5a101ddc7d5d75f16484dd4 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Pulsar CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 ARTIFACT_RETENTION_DAYS=3 JDK_DISTRIBUTION=corretto GITHUB_ACTION_PATH=/home/github/68840355678/actions/apache-pulsar/./.github/actions/tune-runner-vm JOB_NAME='CI - Integration - Shade on Java 17' PULSAR_TEST_IMAGE_NAME=apachepulsar/java-test-image:latest DEVELOCITY_ACCESS_KEY= CI_JDK_MAJOR_VERSION= "${CURRENT_ENV[@]}" \
bash -e /home/github/68840355678/steps/bugswarm_1.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=1 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=apache/pulsar GITHUB_ACTIONS=true GITHUB_ACTOR=lhotari GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/pulsar GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=1a457bbbab464417d5a101ddc7d5d75f16484dd4 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Pulsar CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 ARTIFACT_RETENTION_DAYS=3 JDK_DISTRIBUTION=corretto GITHUB_ACTION_PATH=/home/github/68840355678/actions/apache-pulsar/./.github/actions/tune-runner-vm JOB_NAME='CI - Integration - Shade on Java 17' PULSAR_TEST_IMAGE_NAME=apachepulsar/java-test-image:latest DEVELOCITY_ACCESS_KEY= CI_JDK_MAJOR_VERSION= "${CURRENT_ENV[@]}" \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=1 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=apache/pulsar GITHUB_ACTIONS=true GITHUB_ACTOR=lhotari GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/pulsar GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=1a457bbbab464417d5a101ddc7d5d75f16484dd4 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Pulsar CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 ARTIFACT_RETENTION_DAYS=3 JDK_DISTRIBUTION=corretto GITHUB_ACTION_PATH=/home/github/68840355678/actions/apache-pulsar/./.github/actions/tune-runner-vm JOB_NAME='CI - Integration - Shade on Java 17' PULSAR_TEST_IMAGE_NAME=apachepulsar/java-test-image:latest DEVELOCITY_ACCESS_KEY= CI_JDK_MAJOR_VERSION= "${CURRENT_ENV[@]}" \
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=2 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=apache/pulsar GITHUB_ACTIONS=true GITHUB_ACTOR=lhotari GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/pulsar GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=1a457bbbab464417d5a101ddc7d5d75f16484dd4 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Pulsar CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 ARTIFACT_RETENTION_DAYS=3 JDK_DISTRIBUTION=corretto GITHUB_ACTION_PATH=/home/github/68840355678/actions/apache-pulsar/./.github/actions/ssh-access JOB_NAME='CI - Integration - Shade on Java 17' PULSAR_TEST_IMAGE_NAME=apachepulsar/java-test-image:latest DEVELOCITY_ACCESS_KEY= CI_JDK_MAJOR_VERSION= "${CURRENT_ENV[@]}" INPUT_LIMIT-ACCESS-TO-ACTOR=true INPUT_ACTION=start INPUT_LIMIT-ACCESS-TO-USERS= INPUT_SECURE-ACCESS=true INPUT_TIMEOUT=300 \
echo "$(/home/github/68840355678/helpers/eval_expression p:'(' f:success p:'(' p:')' p:')' o:'&&' p:'(' p:'(' s:apache/pulsar o:'!=' s:apache/pulsar p:')' o:'&&' p:'(' s:push o:== s:pull_request p:')' p:')')")
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=2 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=apache/pulsar GITHUB_ACTIONS=true GITHUB_ACTOR=lhotari GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/pulsar GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=1a457bbbab464417d5a101ddc7d5d75f16484dd4 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Pulsar CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 ARTIFACT_RETENTION_DAYS=3 JDK_DISTRIBUTION=corretto GITHUB_ACTION_PATH=/home/github/68840355678/actions/apache-pulsar/./.github/actions/ssh-access JOB_NAME='CI - Integration - Shade on Java 17' PULSAR_TEST_IMAGE_NAME=apachepulsar/java-test-image:latest DEVELOCITY_ACCESS_KEY= CI_JDK_MAJOR_VERSION= "${CURRENT_ENV[@]}" INPUT_LIMIT-ACCESS-TO-ACTOR=true INPUT_ACTION=start INPUT_LIMIT-ACCESS-TO-USERS= INPUT_SECURE-ACCESS=true INPUT_TIMEOUT=300 \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run ./.github/actions/ssh-access
echo "##[endgroup]"
echo /home/github/68840355678/steps/bugswarm_2_composite.sh > /home/github/68840355678/steps/bugswarm_2.sh
chmod u+x /home/github/68840355678/steps/bugswarm_2.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=2 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=apache/pulsar GITHUB_ACTIONS=true GITHUB_ACTOR=lhotari GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/pulsar GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=1a457bbbab464417d5a101ddc7d5d75f16484dd4 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Pulsar CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 ARTIFACT_RETENTION_DAYS=3 JDK_DISTRIBUTION=corretto GITHUB_ACTION_PATH=/home/github/68840355678/actions/apache-pulsar/./.github/actions/ssh-access JOB_NAME='CI - Integration - Shade on Java 17' PULSAR_TEST_IMAGE_NAME=apachepulsar/java-test-image:latest DEVELOCITY_ACCESS_KEY= CI_JDK_MAJOR_VERSION= "${CURRENT_ENV[@]}" INPUT_LIMIT-ACCESS-TO-ACTOR=true INPUT_ACTION=start INPUT_LIMIT-ACCESS-TO-USERS= INPUT_SECURE-ACCESS=true INPUT_TIMEOUT=300 \
bash -e /home/github/68840355678/steps/bugswarm_2.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=2 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=apache/pulsar GITHUB_ACTIONS=true GITHUB_ACTOR=lhotari GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/pulsar GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=1a457bbbab464417d5a101ddc7d5d75f16484dd4 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Pulsar CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 ARTIFACT_RETENTION_DAYS=3 JDK_DISTRIBUTION=corretto GITHUB_ACTION_PATH=/home/github/68840355678/actions/apache-pulsar/./.github/actions/ssh-access JOB_NAME='CI - Integration - Shade on Java 17' PULSAR_TEST_IMAGE_NAME=apachepulsar/java-test-image:latest DEVELOCITY_ACCESS_KEY= CI_JDK_MAJOR_VERSION= "${CURRENT_ENV[@]}" INPUT_LIMIT-ACCESS-TO-ACTOR=true INPUT_ACTION=start INPUT_LIMIT-ACCESS-TO-USERS= INPUT_SECURE-ACCESS=true INPUT_TIMEOUT=300 \
echo true)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=2 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=apache/pulsar GITHUB_ACTIONS=true GITHUB_ACTOR=lhotari GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/pulsar GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=1a457bbbab464417d5a101ddc7d5d75f16484dd4 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Pulsar CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 ARTIFACT_RETENTION_DAYS=3 JDK_DISTRIBUTION=corretto GITHUB_ACTION_PATH=/home/github/68840355678/actions/apache-pulsar/./.github/actions/ssh-access JOB_NAME='CI - Integration - Shade on Java 17' PULSAR_TEST_IMAGE_NAME=apachepulsar/java-test-image:latest DEVELOCITY_ACCESS_KEY= CI_JDK_MAJOR_VERSION= "${CURRENT_ENV[@]}" INPUT_LIMIT-ACCESS-TO-ACTOR=true INPUT_ACTION=start INPUT_LIMIT-ACCESS-TO-USERS= INPUT_SECURE-ACCESS=true INPUT_TIMEOUT=300 \
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=3 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=actions/setup-java GITHUB_ACTIONS=true GITHUB_ACTOR=lhotari GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/pulsar GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=1a457bbbab464417d5a101ddc7d5d75f16484dd4 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Pulsar CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 ARTIFACT_RETENTION_DAYS=3 JDK_DISTRIBUTION=corretto GITHUB_ACTION_PATH=/home/github/68840355678/actions/actions-setup-java@v4 JOB_NAME='CI - Integration - Shade on Java 17' PULSAR_TEST_IMAGE_NAME=apachepulsar/java-test-image:latest DEVELOCITY_ACCESS_KEY= CI_JDK_MAJOR_VERSION= "${CURRENT_ENV[@]}" INPUT_DISTRIBUTION="$(test -v "CURRENT_ENV_MAP[JDK_DISTRIBUTION]" && echo "${CURRENT_ENV_MAP[JDK_DISTRIBUTION]}" || echo corretto)" INPUT_JAVA-VERSION="$(test -v "CURRENT_ENV_MAP[CI_JDK_MAJOR_VERSION]" && echo "${CURRENT_ENV_MAP[CI_JDK_MAJOR_VERSION]}" || echo )" INPUT_OVERWRITE-SETTINGS=False INPUT_TOKEN= INPUT_JAVA-PACKAGE=jdk INPUT_CHECK-LATEST=false INPUT_SERVER-ID=github INPUT_SERVER-USERNAME=GITHUB_ACTOR INPUT_SERVER-PASSWORD=GITHUB_TOKEN INPUT_JOB-STATUS="${_GITHUB_JOB_STATUS}" \
echo $(test "$_GITHUB_JOB_STATUS" = "success" && echo true || echo false))
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=3 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=actions/setup-java GITHUB_ACTIONS=true GITHUB_ACTOR=lhotari GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/pulsar GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=1a457bbbab464417d5a101ddc7d5d75f16484dd4 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Pulsar CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 ARTIFACT_RETENTION_DAYS=3 JDK_DISTRIBUTION=corretto GITHUB_ACTION_PATH=/home/github/68840355678/actions/actions-setup-java@v4 JOB_NAME='CI - Integration - Shade on Java 17' PULSAR_TEST_IMAGE_NAME=apachepulsar/java-test-image:latest DEVELOCITY_ACCESS_KEY= CI_JDK_MAJOR_VERSION= "${CURRENT_ENV[@]}" INPUT_DISTRIBUTION="$(test -v "CURRENT_ENV_MAP[JDK_DISTRIBUTION]" && echo "${CURRENT_ENV_MAP[JDK_DISTRIBUTION]}" || echo corretto)" INPUT_JAVA-VERSION="$(test -v "CURRENT_ENV_MAP[CI_JDK_MAJOR_VERSION]" && echo "${CURRENT_ENV_MAP[CI_JDK_MAJOR_VERSION]}" || echo )" INPUT_OVERWRITE-SETTINGS=False INPUT_TOKEN= INPUT_JAVA-PACKAGE=jdk INPUT_CHECK-LATEST=false INPUT_SERVER-ID=github INPUT_SERVER-USERNAME=GITHUB_ACTOR INPUT_SERVER-PASSWORD=GITHUB_TOKEN INPUT_JOB-STATUS="${_GITHUB_JOB_STATUS}" \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run actions/setup-java@v4
echo "##[endgroup]"
echo node /home/github/68840355678/actions/actions-setup-java@v4/dist/setup/index.js > /home/github/68840355678/steps/bugswarm_cmd.sh
chmod u+x /home/github/68840355678/steps/bugswarm_cmd.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=3 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=actions/setup-java GITHUB_ACTIONS=true GITHUB_ACTOR=lhotari GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/pulsar GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=1a457bbbab464417d5a101ddc7d5d75f16484dd4 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Pulsar CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 ARTIFACT_RETENTION_DAYS=3 JDK_DISTRIBUTION=corretto GITHUB_ACTION_PATH=/home/github/68840355678/actions/actions-setup-java@v4 JOB_NAME='CI - Integration - Shade on Java 17' PULSAR_TEST_IMAGE_NAME=apachepulsar/java-test-image:latest DEVELOCITY_ACCESS_KEY= CI_JDK_MAJOR_VERSION= "${CURRENT_ENV[@]}" INPUT_DISTRIBUTION="$(test -v "CURRENT_ENV_MAP[JDK_DISTRIBUTION]" && echo "${CURRENT_ENV_MAP[JDK_DISTRIBUTION]}" || echo corretto)" INPUT_JAVA-VERSION="$(test -v "CURRENT_ENV_MAP[CI_JDK_MAJOR_VERSION]" && echo "${CURRENT_ENV_MAP[CI_JDK_MAJOR_VERSION]}" || echo )" INPUT_OVERWRITE-SETTINGS=False INPUT_TOKEN= INPUT_JAVA-PACKAGE=jdk INPUT_CHECK-LATEST=false INPUT_SERVER-ID=github INPUT_SERVER-USERNAME=GITHUB_ACTOR INPUT_SERVER-PASSWORD=GITHUB_TOKEN INPUT_JOB-STATUS="${_GITHUB_JOB_STATUS}" \
bash -e /home/github/68840355678/steps/bugswarm_cmd.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=3 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=actions/setup-java GITHUB_ACTIONS=true GITHUB_ACTOR=lhotari GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/pulsar GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=1a457bbbab464417d5a101ddc7d5d75f16484dd4 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Pulsar CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 ARTIFACT_RETENTION_DAYS=3 JDK_DISTRIBUTION=corretto GITHUB_ACTION_PATH=/home/github/68840355678/actions/actions-setup-java@v4 JOB_NAME='CI - Integration - Shade on Java 17' PULSAR_TEST_IMAGE_NAME=apachepulsar/java-test-image:latest DEVELOCITY_ACCESS_KEY= CI_JDK_MAJOR_VERSION= "${CURRENT_ENV[@]}" INPUT_DISTRIBUTION="$(test -v "CURRENT_ENV_MAP[JDK_DISTRIBUTION]" && echo "${CURRENT_ENV_MAP[JDK_DISTRIBUTION]}" || echo corretto)" INPUT_JAVA-VERSION="$(test -v "CURRENT_ENV_MAP[CI_JDK_MAJOR_VERSION]" && echo "${CURRENT_ENV_MAP[CI_JDK_MAJOR_VERSION]}" || echo )" INPUT_OVERWRITE-SETTINGS=False INPUT_TOKEN= INPUT_JAVA-PACKAGE=jdk INPUT_CHECK-LATEST=false INPUT_SERVER-ID=github INPUT_SERVER-USERNAME=GITHUB_ACTOR INPUT_SERVER-PASSWORD=GITHUB_TOKEN INPUT_JOB-STATUS="${_GITHUB_JOB_STATUS}" \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=3 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=actions/setup-java GITHUB_ACTIONS=true GITHUB_ACTOR=lhotari GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/pulsar GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=1a457bbbab464417d5a101ddc7d5d75f16484dd4 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Pulsar CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 ARTIFACT_RETENTION_DAYS=3 JDK_DISTRIBUTION=corretto GITHUB_ACTION_PATH=/home/github/68840355678/actions/actions-setup-java@v4 JOB_NAME='CI - Integration - Shade on Java 17' PULSAR_TEST_IMAGE_NAME=apachepulsar/java-test-image:latest DEVELOCITY_ACCESS_KEY= CI_JDK_MAJOR_VERSION= "${CURRENT_ENV[@]}" INPUT_DISTRIBUTION="$(test -v "CURRENT_ENV_MAP[JDK_DISTRIBUTION]" && echo "${CURRENT_ENV_MAP[JDK_DISTRIBUTION]}" || echo corretto)" INPUT_JAVA-VERSION="$(test -v "CURRENT_ENV_MAP[CI_JDK_MAJOR_VERSION]" && echo "${CURRENT_ENV_MAP[CI_JDK_MAJOR_VERSION]}" || echo )" INPUT_OVERWRITE-SETTINGS=False INPUT_TOKEN= INPUT_JAVA-PACKAGE=jdk INPUT_CHECK-LATEST=false INPUT_SERVER-ID=github INPUT_SERVER-USERNAME=GITHUB_ACTOR INPUT_SERVER-PASSWORD=GITHUB_TOKEN INPUT_JOB-STATUS="${_GITHUB_JOB_STATUS}" \
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=4 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=gradle/actions GITHUB_ACTIONS=true GITHUB_ACTOR=lhotari GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/pulsar GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=1a457bbbab464417d5a101ddc7d5d75f16484dd4 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Pulsar CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 ARTIFACT_RETENTION_DAYS=3 JDK_DISTRIBUTION=corretto GITHUB_ACTION_PATH=/home/github/68840355678/actions/gradle-actions@0723195856401067f7a2779048b490ace7a47d7c/setup-gradle JOB_NAME='CI - Integration - Shade on Java 17' PULSAR_TEST_IMAGE_NAME=apachepulsar/java-test-image:latest DEVELOCITY_ACCESS_KEY= CI_JDK_MAJOR_VERSION= "${CURRENT_ENV[@]}" INPUT_DEVELOCITY-INJECTION-ENABLED=true INPUT_DEVELOCITY-URL=https://develocity.apache.org INPUT_ADD-JOB-SUMMARY=always INPUT_CACHE-DISABLED=false INPUT_CACHE-READ-ONLY="$(/home/github/68840355678/helpers/eval_expression p:'(' l:'{"allow_forking": true, "archive_url": "https://api.github.com/repos/apache/pulsar/{archive_format}{/ref}", "archived": false, "assignees_url": "https://api.github.com/repos/apache/pulsar/assignees{/user}", "blobs_url": "https://api.github.com/repos/apache/pulsar/git/blobs{/sha}", "branches_url": "https://api.github.com/repos/apache/pulsar/branches{/branch}", "clone_url": "https://github.com/apache/pulsar.git", "collaborators_url": "https://api.github.com/repos/apache/pulsar/collaborators{/collaborator}", "comments_url": "https://api.github.com/repos/apache/pulsar/comments{/number}", "commits_url": "https://api.github.com/repos/apache/pulsar/commits{/sha}", "compare_url": "https://api.github.com/repos/apache/pulsar/compare/{base}...{head}", "contents_url": "https://api.github.com/repos/apache/pulsar/contents/{+path}", "contributors_url": "https://api.github.com/repos/apache/pulsar/contributors", "created_at": 0, "default_branch": "master", "deployments_url": "https://api.github.com/repos/apache/pulsar/deployments", "description": "Apache Pulsar - distributed pub-sub messaging system", "disabled": false, "downloads_url": "https://api.github.com/repos/apache/pulsar/downloads", "events_url": "https://api.github.com/repos/apache/pulsar/events", "fork": false, "forks": 0, "forks_count": 0, "forks_url": "https://api.github.com/repos/apache/pulsar/forks", "full_name": "apache/pulsar", "git_commits_url": "https://api.github.com/repos/apache/pulsar/git/commits{/sha}", "git_refs_url": "https://api.github.com/repos/apache/pulsar/git/refs{/sha}", "git_tags_url": "https://api.github.com/repos/apache/pulsar/git/tags{/sha}", "git_url": "git://github.com/apache/pulsar.git", "has_downloads": true, "has_issues": true, "has_pages": true, "has_projects": true, "has_wiki": true, "homepage": null, "hooks_url": "https://api.github.com/repos/apache/pulsar/hooks", "html_url": "https://github.com/apache/pulsar", "id": 62117812, "is_template": false, "issue_comment_url": "https://api.github.com/repos/apache/pulsar/issues/comments{/number}", "issue_events_url": "https://api.github.com/repos/apache/pulsar/issues/events{/number}", "issues_url": "https://api.github.com/repos/apache/pulsar/issues{/number}", "keys_url": "https://api.github.com/repos/apache/pulsar/keys{/key_id}", "labels_url": "https://api.github.com/repos/apache/pulsar/labels{/name}", "language": "", "languages_url": "https://api.github.com/repos/apache/pulsar/languages", "license": null, "master_branch": "master", "merges_url": "https://api.github.com/repos/apache/pulsar/merges", "milestones_url": "https://api.github.com/repos/apache/pulsar/milestones{/number}", "mirror_url": null, "name": "pulsar", "node_id": "MDEwOlJlcG9zaXRvcnk2MjExNzgxMg==", "notifications_url": "https://api.github.com/repos/apache/pulsar/notifications{?since,all,participating}", "open_issues": 0, "open_issues_count": 0, "owner": {"avatar_url": "https://avatars.githubusercontent.com/u/47359?v=4", "email": "", "events_url": "https://api.github.com/users/apache/events{/privacy}", "followers_url": "https://api.github.com/users/apache/followers", "following_url": "https://api.github.com/users/apache/following{/other_user}", "gists_url": "https://api.github.com/users/apache/gists{/gist_id}", "gravatar_id": "", "html_url": "https://github.com/apache", "id": 47359, "login": "apache", "name": "apache", "node_id": "MDEyOk9yZ2FuaXphdGlvbjQ3MzU5", "organizations_url": "https://api.github.com/users/apache/orgs", "received_events_url": "https://api.github.com/users/apache/received_events", "repos_url": "https://api.github.com/users/apache/repos", "site_admin": false, "starred_url": "https://api.github.com/users/apache/starred{/owner}{/repo}", "subscriptions_url": "https://api.github.com/users/apache/subscriptions", "type": "Organization", "url": "https://api.github.com/users/apache"}, "private": false, "pulls_url": "https://api.github.com/repos/apache/pulsar/pulls{/number}", "pushed_at": 0, "releases_url": "https://api.github.com/repos/apache/pulsar/releases{/id}", "size": 0, "ssh_url": "git@github.com:apache/pulsar.git", "stargazers": 0, "stargazers_count": 0, "stargazers_url": "https://api.github.com/repos/apache/pulsar/stargazers", "statuses_url": "https://api.github.com/repos/apache/pulsar/statuses/{sha}", "subscribers_url": "https://api.github.com/repos/apache/pulsar/subscribers", "subscription_url": "https://api.github.com/repos/apache/pulsar/subscription", "svn_url": "https://github.com/apache/pulsar", "tags_url": "https://api.github.com/repos/apache/pulsar/tags", "teams_url": "https://api.github.com/repos/apache/pulsar/teams", "topics": [], "trees_url": "https://api.github.com/repos/apache/pulsar/git/trees{/sha}", "updated_at": "2026-03-27T06:09:08Z", "url": "https://api.github.com/repos/apache/pulsar", "visibility": "public", "watchers": 0, "watchers_count": 0, "web_commit_signoff_required": false}' o:'!=' l:'' p:')' o:'&&' p:'(' s:master o:'!=' s:master p:')')" INPUT_CACHE-WRITE-ONLY=false INPUT_CACHE-OVERWRITE-EXISTING=false INPUT_CACHE-CLEANUP=on-success INPUT_GRADLE-HOME-CACHE-INCLUDES='caches
notifications
' INPUT_ADD-JOB-SUMMARY-AS-PR-COMMENT=never INPUT_DEPENDENCY-GRAPH=disabled INPUT_DEPENDENCY-GRAPH-REPORT-DIR=dependency-graph-reports INPUT_DEPENDENCY-GRAPH-CONTINUE-ON-FAILURE=true INPUT_BUILD-SCAN-PUBLISH=false INPUT_VALIDATE-WRAPPERS=true INPUT_ALLOW-SNAPSHOT-WRAPPERS=false INPUT_GRADLE-HOME-CACHE-STRICT-MATCH=false INPUT_WORKFLOW-JOB-CONTEXT="$(/home/github/68840355678/helpers/eval_expression p:'(' f:toJSON p:'(' l:'{"name": "Shade on Java 17", "group": "SHADE_RUN", "upload_name": "SHADE_RUN_17", "runtime_jdk": 17, "setup": "./pulsar-build/run_integration_group_gradle.sh SHADE_BUILD"}' p:')' p:')')" INPUT_GITHUB-TOKEN=DUMMY \
echo $(test "$_GITHUB_JOB_STATUS" = "success" && echo true || echo false))
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=4 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=gradle/actions GITHUB_ACTIONS=true GITHUB_ACTOR=lhotari GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/pulsar GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=1a457bbbab464417d5a101ddc7d5d75f16484dd4 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Pulsar CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 ARTIFACT_RETENTION_DAYS=3 JDK_DISTRIBUTION=corretto GITHUB_ACTION_PATH=/home/github/68840355678/actions/gradle-actions@0723195856401067f7a2779048b490ace7a47d7c/setup-gradle JOB_NAME='CI - Integration - Shade on Java 17' PULSAR_TEST_IMAGE_NAME=apachepulsar/java-test-image:latest DEVELOCITY_ACCESS_KEY= CI_JDK_MAJOR_VERSION= "${CURRENT_ENV[@]}" INPUT_DEVELOCITY-INJECTION-ENABLED=true INPUT_DEVELOCITY-URL=https://develocity.apache.org INPUT_ADD-JOB-SUMMARY=always INPUT_CACHE-DISABLED=false INPUT_CACHE-READ-ONLY="$(/home/github/68840355678/helpers/eval_expression p:'(' l:'{"allow_forking": true, "archive_url": "https://api.github.com/repos/apache/pulsar/{archive_format}{/ref}", "archived": false, "assignees_url": "https://api.github.com/repos/apache/pulsar/assignees{/user}", "blobs_url": "https://api.github.com/repos/apache/pulsar/git/blobs{/sha}", "branches_url": "https://api.github.com/repos/apache/pulsar/branches{/branch}", "clone_url": "https://github.com/apache/pulsar.git", "collaborators_url": "https://api.github.com/repos/apache/pulsar/collaborators{/collaborator}", "comments_url": "https://api.github.com/repos/apache/pulsar/comments{/number}", "commits_url": "https://api.github.com/repos/apache/pulsar/commits{/sha}", "compare_url": "https://api.github.com/repos/apache/pulsar/compare/{base}...{head}", "contents_url": "https://api.github.com/repos/apache/pulsar/contents/{+path}", "contributors_url": "https://api.github.com/repos/apache/pulsar/contributors", "created_at": 0, "default_branch": "master", "deployments_url": "https://api.github.com/repos/apache/pulsar/deployments", "description": "Apache Pulsar - distributed pub-sub messaging system", "disabled": false, "downloads_url": "https://api.github.com/repos/apache/pulsar/downloads", "events_url": "https://api.github.com/repos/apache/pulsar/events", "fork": false, "forks": 0, "forks_count": 0, "forks_url": "https://api.github.com/repos/apache/pulsar/forks", "full_name": "apache/pulsar", "git_commits_url": "https://api.github.com/repos/apache/pulsar/git/commits{/sha}", "git_refs_url": "https://api.github.com/repos/apache/pulsar/git/refs{/sha}", "git_tags_url": "https://api.github.com/repos/apache/pulsar/git/tags{/sha}", "git_url": "git://github.com/apache/pulsar.git", "has_downloads": true, "has_issues": true, "has_pages": true, "has_projects": true, "has_wiki": true, "homepage": null, "hooks_url": "https://api.github.com/repos/apache/pulsar/hooks", "html_url": "https://github.com/apache/pulsar", "id": 62117812, "is_template": false, "issue_comment_url": "https://api.github.com/repos/apache/pulsar/issues/comments{/number}", "issue_events_url": "https://api.github.com/repos/apache/pulsar/issues/events{/number}", "issues_url": "https://api.github.com/repos/apache/pulsar/issues{/number}", "keys_url": "https://api.github.com/repos/apache/pulsar/keys{/key_id}", "labels_url": "https://api.github.com/repos/apache/pulsar/labels{/name}", "language": "", "languages_url": "https://api.github.com/repos/apache/pulsar/languages", "license": null, "master_branch": "master", "merges_url": "https://api.github.com/repos/apache/pulsar/merges", "milestones_url": "https://api.github.com/repos/apache/pulsar/milestones{/number}", "mirror_url": null, "name": "pulsar", "node_id": "MDEwOlJlcG9zaXRvcnk2MjExNzgxMg==", "notifications_url": "https://api.github.com/repos/apache/pulsar/notifications{?since,all,participating}", "open_issues": 0, "open_issues_count": 0, "owner": {"avatar_url": "https://avatars.githubusercontent.com/u/47359?v=4", "email": "", "events_url": "https://api.github.com/users/apache/events{/privacy}", "followers_url": "https://api.github.com/users/apache/followers", "following_url": "https://api.github.com/users/apache/following{/other_user}", "gists_url": "https://api.github.com/users/apache/gists{/gist_id}", "gravatar_id": "", "html_url": "https://github.com/apache", "id": 47359, "login": "apache", "name": "apache", "node_id": "MDEyOk9yZ2FuaXphdGlvbjQ3MzU5", "organizations_url": "https://api.github.com/users/apache/orgs", "received_events_url": "https://api.github.com/users/apache/received_events", "repos_url": "https://api.github.com/users/apache/repos", "site_admin": false, "starred_url": "https://api.github.com/users/apache/starred{/owner}{/repo}", "subscriptions_url": "https://api.github.com/users/apache/subscriptions", "type": "Organization", "url": "https://api.github.com/users/apache"}, "private": false, "pulls_url": "https://api.github.com/repos/apache/pulsar/pulls{/number}", "pushed_at": 0, "releases_url": "https://api.github.com/repos/apache/pulsar/releases{/id}", "size": 0, "ssh_url": "git@github.com:apache/pulsar.git", "stargazers": 0, "stargazers_count": 0, "stargazers_url": "https://api.github.com/repos/apache/pulsar/stargazers", "statuses_url": "https://api.github.com/repos/apache/pulsar/statuses/{sha}", "subscribers_url": "https://api.github.com/repos/apache/pulsar/subscribers", "subscription_url": "https://api.github.com/repos/apache/pulsar/subscription", "svn_url": "https://github.com/apache/pulsar", "tags_url": "https://api.github.com/repos/apache/pulsar/tags", "teams_url": "https://api.github.com/repos/apache/pulsar/teams", "topics": [], "trees_url": "https://api.github.com/repos/apache/pulsar/git/trees{/sha}", "updated_at": "2026-03-27T06:09:08Z", "url": "https://api.github.com/repos/apache/pulsar", "visibility": "public", "watchers": 0, "watchers_count": 0, "web_commit_signoff_required": false}' o:'!=' l:'' p:')' o:'&&' p:'(' s:master o:'!=' s:master p:')')" INPUT_CACHE-WRITE-ONLY=false INPUT_CACHE-OVERWRITE-EXISTING=false INPUT_CACHE-CLEANUP=on-success INPUT_GRADLE-HOME-CACHE-INCLUDES='caches
notifications
' INPUT_ADD-JOB-SUMMARY-AS-PR-COMMENT=never INPUT_DEPENDENCY-GRAPH=disabled INPUT_DEPENDENCY-GRAPH-REPORT-DIR=dependency-graph-reports INPUT_DEPENDENCY-GRAPH-CONTINUE-ON-FAILURE=true INPUT_BUILD-SCAN-PUBLISH=false INPUT_VALIDATE-WRAPPERS=true INPUT_ALLOW-SNAPSHOT-WRAPPERS=false INPUT_GRADLE-HOME-CACHE-STRICT-MATCH=false INPUT_WORKFLOW-JOB-CONTEXT="$(/home/github/68840355678/helpers/eval_expression p:'(' f:toJSON p:'(' l:'{"name": "Shade on Java 17", "group": "SHADE_RUN", "upload_name": "SHADE_RUN_17", "runtime_jdk": 17, "setup": "./pulsar-build/run_integration_group_gradle.sh SHADE_BUILD"}' p:')' p:')')" INPUT_GITHUB-TOKEN=DUMMY \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run gradle/actions/setup-gradle@0723195856401067f7a2779048b490ace7a47d7c
echo "##[endgroup]"
echo node /home/github/68840355678/actions/gradle-actions@0723195856401067f7a2779048b490ace7a47d7c/setup-gradle/../dist/setup-gradle/main/index.js > /home/github/68840355678/steps/bugswarm_cmd.sh
chmod u+x /home/github/68840355678/steps/bugswarm_cmd.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=4 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=gradle/actions GITHUB_ACTIONS=true GITHUB_ACTOR=lhotari GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/pulsar GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=1a457bbbab464417d5a101ddc7d5d75f16484dd4 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Pulsar CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 ARTIFACT_RETENTION_DAYS=3 JDK_DISTRIBUTION=corretto GITHUB_ACTION_PATH=/home/github/68840355678/actions/gradle-actions@0723195856401067f7a2779048b490ace7a47d7c/setup-gradle JOB_NAME='CI - Integration - Shade on Java 17' PULSAR_TEST_IMAGE_NAME=apachepulsar/java-test-image:latest DEVELOCITY_ACCESS_KEY= CI_JDK_MAJOR_VERSION= "${CURRENT_ENV[@]}" INPUT_DEVELOCITY-INJECTION-ENABLED=true INPUT_DEVELOCITY-URL=https://develocity.apache.org INPUT_ADD-JOB-SUMMARY=always INPUT_CACHE-DISABLED=false INPUT_CACHE-READ-ONLY="$(/home/github/68840355678/helpers/eval_expression p:'(' l:'{"allow_forking": true, "archive_url": "https://api.github.com/repos/apache/pulsar/{archive_format}{/ref}", "archived": false, "assignees_url": "https://api.github.com/repos/apache/pulsar/assignees{/user}", "blobs_url": "https://api.github.com/repos/apache/pulsar/git/blobs{/sha}", "branches_url": "https://api.github.com/repos/apache/pulsar/branches{/branch}", "clone_url": "https://github.com/apache/pulsar.git", "collaborators_url": "https://api.github.com/repos/apache/pulsar/collaborators{/collaborator}", "comments_url": "https://api.github.com/repos/apache/pulsar/comments{/number}", "commits_url": "https://api.github.com/repos/apache/pulsar/commits{/sha}", "compare_url": "https://api.github.com/repos/apache/pulsar/compare/{base}...{head}", "contents_url": "https://api.github.com/repos/apache/pulsar/contents/{+path}", "contributors_url": "https://api.github.com/repos/apache/pulsar/contributors", "created_at": 0, "default_branch": "master", "deployments_url": "https://api.github.com/repos/apache/pulsar/deployments", "description": "Apache Pulsar - distributed pub-sub messaging system", "disabled": false, "downloads_url": "https://api.github.com/repos/apache/pulsar/downloads", "events_url": "https://api.github.com/repos/apache/pulsar/events", "fork": false, "forks": 0, "forks_count": 0, "forks_url": "https://api.github.com/repos/apache/pulsar/forks", "full_name": "apache/pulsar", "git_commits_url": "https://api.github.com/repos/apache/pulsar/git/commits{/sha}", "git_refs_url": "https://api.github.com/repos/apache/pulsar/git/refs{/sha}", "git_tags_url": "https://api.github.com/repos/apache/pulsar/git/tags{/sha}", "git_url": "git://github.com/apache/pulsar.git", "has_downloads": true, "has_issues": true, "has_pages": true, "has_projects": true, "has_wiki": true, "homepage": null, "hooks_url": "https://api.github.com/repos/apache/pulsar/hooks", "html_url": "https://github.com/apache/pulsar", "id": 62117812, "is_template": false, "issue_comment_url": "https://api.github.com/repos/apache/pulsar/issues/comments{/number}", "issue_events_url": "https://api.github.com/repos/apache/pulsar/issues/events{/number}", "issues_url": "https://api.github.com/repos/apache/pulsar/issues{/number}", "keys_url": "https://api.github.com/repos/apache/pulsar/keys{/key_id}", "labels_url": "https://api.github.com/repos/apache/pulsar/labels{/name}", "language": "", "languages_url": "https://api.github.com/repos/apache/pulsar/languages", "license": null, "master_branch": "master", "merges_url": "https://api.github.com/repos/apache/pulsar/merges", "milestones_url": "https://api.github.com/repos/apache/pulsar/milestones{/number}", "mirror_url": null, "name": "pulsar", "node_id": "MDEwOlJlcG9zaXRvcnk2MjExNzgxMg==", "notifications_url": "https://api.github.com/repos/apache/pulsar/notifications{?since,all,participating}", "open_issues": 0, "open_issues_count": 0, "owner": {"avatar_url": "https://avatars.githubusercontent.com/u/47359?v=4", "email": "", "events_url": "https://api.github.com/users/apache/events{/privacy}", "followers_url": "https://api.github.com/users/apache/followers", "following_url": "https://api.github.com/users/apache/following{/other_user}", "gists_url": "https://api.github.com/users/apache/gists{/gist_id}", "gravatar_id": "", "html_url": "https://github.com/apache", "id": 47359, "login": "apache", "name": "apache", "node_id": "MDEyOk9yZ2FuaXphdGlvbjQ3MzU5", "organizations_url": "https://api.github.com/users/apache/orgs", "received_events_url": "https://api.github.com/users/apache/received_events", "repos_url": "https://api.github.com/users/apache/repos", "site_admin": false, "starred_url": "https://api.github.com/users/apache/starred{/owner}{/repo}", "subscriptions_url": "https://api.github.com/users/apache/subscriptions", "type": "Organization", "url": "https://api.github.com/users/apache"}, "private": false, "pulls_url": "https://api.github.com/repos/apache/pulsar/pulls{/number}", "pushed_at": 0, "releases_url": "https://api.github.com/repos/apache/pulsar/releases{/id}", "size": 0, "ssh_url": "git@github.com:apache/pulsar.git", "stargazers": 0, "stargazers_count": 0, "stargazers_url": "https://api.github.com/repos/apache/pulsar/stargazers", "statuses_url": "https://api.github.com/repos/apache/pulsar/statuses/{sha}", "subscribers_url": "https://api.github.com/repos/apache/pulsar/subscribers", "subscription_url": "https://api.github.com/repos/apache/pulsar/subscription", "svn_url": "https://github.com/apache/pulsar", "tags_url": "https://api.github.com/repos/apache/pulsar/tags", "teams_url": "https://api.github.com/repos/apache/pulsar/teams", "topics": [], "trees_url": "https://api.github.com/repos/apache/pulsar/git/trees{/sha}", "updated_at": "2026-03-27T06:09:08Z", "url": "https://api.github.com/repos/apache/pulsar", "visibility": "public", "watchers": 0, "watchers_count": 0, "web_commit_signoff_required": false}' o:'!=' l:'' p:')' o:'&&' p:'(' s:master o:'!=' s:master p:')')" INPUT_CACHE-WRITE-ONLY=false INPUT_CACHE-OVERWRITE-EXISTING=false INPUT_CACHE-CLEANUP=on-success INPUT_GRADLE-HOME-CACHE-INCLUDES='caches
notifications
' INPUT_ADD-JOB-SUMMARY-AS-PR-COMMENT=never INPUT_DEPENDENCY-GRAPH=disabled INPUT_DEPENDENCY-GRAPH-REPORT-DIR=dependency-graph-reports INPUT_DEPENDENCY-GRAPH-CONTINUE-ON-FAILURE=true INPUT_BUILD-SCAN-PUBLISH=false INPUT_VALIDATE-WRAPPERS=true INPUT_ALLOW-SNAPSHOT-WRAPPERS=false INPUT_GRADLE-HOME-CACHE-STRICT-MATCH=false INPUT_WORKFLOW-JOB-CONTEXT="$(/home/github/68840355678/helpers/eval_expression p:'(' f:toJSON p:'(' l:'{"name": "Shade on Java 17", "group": "SHADE_RUN", "upload_name": "SHADE_RUN_17", "runtime_jdk": 17, "setup": "./pulsar-build/run_integration_group_gradle.sh SHADE_BUILD"}' p:')' p:')')" INPUT_GITHUB-TOKEN=DUMMY \
bash -e /home/github/68840355678/steps/bugswarm_cmd.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=4 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=gradle/actions GITHUB_ACTIONS=true GITHUB_ACTOR=lhotari GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/pulsar GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=1a457bbbab464417d5a101ddc7d5d75f16484dd4 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Pulsar CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 ARTIFACT_RETENTION_DAYS=3 JDK_DISTRIBUTION=corretto GITHUB_ACTION_PATH=/home/github/68840355678/actions/gradle-actions@0723195856401067f7a2779048b490ace7a47d7c/setup-gradle JOB_NAME='CI - Integration - Shade on Java 17' PULSAR_TEST_IMAGE_NAME=apachepulsar/java-test-image:latest DEVELOCITY_ACCESS_KEY= CI_JDK_MAJOR_VERSION= "${CURRENT_ENV[@]}" INPUT_DEVELOCITY-INJECTION-ENABLED=true INPUT_DEVELOCITY-URL=https://develocity.apache.org INPUT_ADD-JOB-SUMMARY=always INPUT_CACHE-DISABLED=false INPUT_CACHE-READ-ONLY="$(/home/github/68840355678/helpers/eval_expression p:'(' l:'{"allow_forking": true, "archive_url": "https://api.github.com/repos/apache/pulsar/{archive_format}{/ref}", "archived": false, "assignees_url": "https://api.github.com/repos/apache/pulsar/assignees{/user}", "blobs_url": "https://api.github.com/repos/apache/pulsar/git/blobs{/sha}", "branches_url": "https://api.github.com/repos/apache/pulsar/branches{/branch}", "clone_url": "https://github.com/apache/pulsar.git", "collaborators_url": "https://api.github.com/repos/apache/pulsar/collaborators{/collaborator}", "comments_url": "https://api.github.com/repos/apache/pulsar/comments{/number}", "commits_url": "https://api.github.com/repos/apache/pulsar/commits{/sha}", "compare_url": "https://api.github.com/repos/apache/pulsar/compare/{base}...{head}", "contents_url": "https://api.github.com/repos/apache/pulsar/contents/{+path}", "contributors_url": "https://api.github.com/repos/apache/pulsar/contributors", "created_at": 0, "default_branch": "master", "deployments_url": "https://api.github.com/repos/apache/pulsar/deployments", "description": "Apache Pulsar - distributed pub-sub messaging system", "disabled": false, "downloads_url": "https://api.github.com/repos/apache/pulsar/downloads", "events_url": "https://api.github.com/repos/apache/pulsar/events", "fork": false, "forks": 0, "forks_count": 0, "forks_url": "https://api.github.com/repos/apache/pulsar/forks", "full_name": "apache/pulsar", "git_commits_url": "https://api.github.com/repos/apache/pulsar/git/commits{/sha}", "git_refs_url": "https://api.github.com/repos/apache/pulsar/git/refs{/sha}", "git_tags_url": "https://api.github.com/repos/apache/pulsar/git/tags{/sha}", "git_url": "git://github.com/apache/pulsar.git", "has_downloads": true, "has_issues": true, "has_pages": true, "has_projects": true, "has_wiki": true, "homepage": null, "hooks_url": "https://api.github.com/repos/apache/pulsar/hooks", "html_url": "https://github.com/apache/pulsar", "id": 62117812, "is_template": false, "issue_comment_url": "https://api.github.com/repos/apache/pulsar/issues/comments{/number}", "issue_events_url": "https://api.github.com/repos/apache/pulsar/issues/events{/number}", "issues_url": "https://api.github.com/repos/apache/pulsar/issues{/number}", "keys_url": "https://api.github.com/repos/apache/pulsar/keys{/key_id}", "labels_url": "https://api.github.com/repos/apache/pulsar/labels{/name}", "language": "", "languages_url": "https://api.github.com/repos/apache/pulsar/languages", "license": null, "master_branch": "master", "merges_url": "https://api.github.com/repos/apache/pulsar/merges", "milestones_url": "https://api.github.com/repos/apache/pulsar/milestones{/number}", "mirror_url": null, "name": "pulsar", "node_id": "MDEwOlJlcG9zaXRvcnk2MjExNzgxMg==", "notifications_url": "https://api.github.com/repos/apache/pulsar/notifications{?since,all,participating}", "open_issues": 0, "open_issues_count": 0, "owner": {"avatar_url": "https://avatars.githubusercontent.com/u/47359?v=4", "email": "", "events_url": "https://api.github.com/users/apache/events{/privacy}", "followers_url": "https://api.github.com/users/apache/followers", "following_url": "https://api.github.com/users/apache/following{/other_user}", "gists_url": "https://api.github.com/users/apache/gists{/gist_id}", "gravatar_id": "", "html_url": "https://github.com/apache", "id": 47359, "login": "apache", "name": "apache", "node_id": "MDEyOk9yZ2FuaXphdGlvbjQ3MzU5", "organizations_url": "https://api.github.com/users/apache/orgs", "received_events_url": "https://api.github.com/users/apache/received_events", "repos_url": "https://api.github.com/users/apache/repos", "site_admin": false, "starred_url": "https://api.github.com/users/apache/starred{/owner}{/repo}", "subscriptions_url": "https://api.github.com/users/apache/subscriptions", "type": "Organization", "url": "https://api.github.com/users/apache"}, "private": false, "pulls_url": "https://api.github.com/repos/apache/pulsar/pulls{/number}", "pushed_at": 0, "releases_url": "https://api.github.com/repos/apache/pulsar/releases{/id}", "size": 0, "ssh_url": "git@github.com:apache/pulsar.git", "stargazers": 0, "stargazers_count": 0, "stargazers_url": "https://api.github.com/repos/apache/pulsar/stargazers", "statuses_url": "https://api.github.com/repos/apache/pulsar/statuses/{sha}", "subscribers_url": "https://api.github.com/repos/apache/pulsar/subscribers", "subscription_url": "https://api.github.com/repos/apache/pulsar/subscription", "svn_url": "https://github.com/apache/pulsar", "tags_url": "https://api.github.com/repos/apache/pulsar/tags", "teams_url": "https://api.github.com/repos/apache/pulsar/teams", "topics": [], "trees_url": "https://api.github.com/repos/apache/pulsar/git/trees{/sha}", "updated_at": "2026-03-27T06:09:08Z", "url": "https://api.github.com/repos/apache/pulsar", "visibility": "public", "watchers": 0, "watchers_count": 0, "web_commit_signoff_required": false}' o:'!=' l:'' p:')' o:'&&' p:'(' s:master o:'!=' s:master p:')')" INPUT_CACHE-WRITE-ONLY=false INPUT_CACHE-OVERWRITE-EXISTING=false INPUT_CACHE-CLEANUP=on-success INPUT_GRADLE-HOME-CACHE-INCLUDES='caches
notifications
' INPUT_ADD-JOB-SUMMARY-AS-PR-COMMENT=never INPUT_DEPENDENCY-GRAPH=disabled INPUT_DEPENDENCY-GRAPH-REPORT-DIR=dependency-graph-reports INPUT_DEPENDENCY-GRAPH-CONTINUE-ON-FAILURE=true INPUT_BUILD-SCAN-PUBLISH=false INPUT_VALIDATE-WRAPPERS=true INPUT_ALLOW-SNAPSHOT-WRAPPERS=false INPUT_GRADLE-HOME-CACHE-STRICT-MATCH=false INPUT_WORKFLOW-JOB-CONTEXT="$(/home/github/68840355678/helpers/eval_expression p:'(' f:toJSON p:'(' l:'{"name": "Shade on Java 17", "group": "SHADE_RUN", "upload_name": "SHADE_RUN_17", "runtime_jdk": 17, "setup": "./pulsar-build/run_integration_group_gradle.sh SHADE_BUILD"}' p:')' p:')')" INPUT_GITHUB-TOKEN=DUMMY \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=4 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=gradle/actions GITHUB_ACTIONS=true GITHUB_ACTOR=lhotari GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/pulsar GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=1a457bbbab464417d5a101ddc7d5d75f16484dd4 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Pulsar CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 ARTIFACT_RETENTION_DAYS=3 JDK_DISTRIBUTION=corretto GITHUB_ACTION_PATH=/home/github/68840355678/actions/gradle-actions@0723195856401067f7a2779048b490ace7a47d7c/setup-gradle JOB_NAME='CI - Integration - Shade on Java 17' PULSAR_TEST_IMAGE_NAME=apachepulsar/java-test-image:latest DEVELOCITY_ACCESS_KEY= CI_JDK_MAJOR_VERSION= "${CURRENT_ENV[@]}" INPUT_DEVELOCITY-INJECTION-ENABLED=true INPUT_DEVELOCITY-URL=https://develocity.apache.org INPUT_ADD-JOB-SUMMARY=always INPUT_CACHE-DISABLED=false INPUT_CACHE-READ-ONLY="$(/home/github/68840355678/helpers/eval_expression p:'(' l:'{"allow_forking": true, "archive_url": "https://api.github.com/repos/apache/pulsar/{archive_format}{/ref}", "archived": false, "assignees_url": "https://api.github.com/repos/apache/pulsar/assignees{/user}", "blobs_url": "https://api.github.com/repos/apache/pulsar/git/blobs{/sha}", "branches_url": "https://api.github.com/repos/apache/pulsar/branches{/branch}", "clone_url": "https://github.com/apache/pulsar.git", "collaborators_url": "https://api.github.com/repos/apache/pulsar/collaborators{/collaborator}", "comments_url": "https://api.github.com/repos/apache/pulsar/comments{/number}", "commits_url": "https://api.github.com/repos/apache/pulsar/commits{/sha}", "compare_url": "https://api.github.com/repos/apache/pulsar/compare/{base}...{head}", "contents_url": "https://api.github.com/repos/apache/pulsar/contents/{+path}", "contributors_url": "https://api.github.com/repos/apache/pulsar/contributors", "created_at": 0, "default_branch": "master", "deployments_url": "https://api.github.com/repos/apache/pulsar/deployments", "description": "Apache Pulsar - distributed pub-sub messaging system", "disabled": false, "downloads_url": "https://api.github.com/repos/apache/pulsar/downloads", "events_url": "https://api.github.com/repos/apache/pulsar/events", "fork": false, "forks": 0, "forks_count": 0, "forks_url": "https://api.github.com/repos/apache/pulsar/forks", "full_name": "apache/pulsar", "git_commits_url": "https://api.github.com/repos/apache/pulsar/git/commits{/sha}", "git_refs_url": "https://api.github.com/repos/apache/pulsar/git/refs{/sha}", "git_tags_url": "https://api.github.com/repos/apache/pulsar/git/tags{/sha}", "git_url": "git://github.com/apache/pulsar.git", "has_downloads": true, "has_issues": true, "has_pages": true, "has_projects": true, "has_wiki": true, "homepage": null, "hooks_url": "https://api.github.com/repos/apache/pulsar/hooks", "html_url": "https://github.com/apache/pulsar", "id": 62117812, "is_template": false, "issue_comment_url": "https://api.github.com/repos/apache/pulsar/issues/comments{/number}", "issue_events_url": "https://api.github.com/repos/apache/pulsar/issues/events{/number}", "issues_url": "https://api.github.com/repos/apache/pulsar/issues{/number}", "keys_url": "https://api.github.com/repos/apache/pulsar/keys{/key_id}", "labels_url": "https://api.github.com/repos/apache/pulsar/labels{/name}", "language": "", "languages_url": "https://api.github.com/repos/apache/pulsar/languages", "license": null, "master_branch": "master", "merges_url": "https://api.github.com/repos/apache/pulsar/merges", "milestones_url": "https://api.github.com/repos/apache/pulsar/milestones{/number}", "mirror_url": null, "name": "pulsar", "node_id": "MDEwOlJlcG9zaXRvcnk2MjExNzgxMg==", "notifications_url": "https://api.github.com/repos/apache/pulsar/notifications{?since,all,participating}", "open_issues": 0, "open_issues_count": 0, "owner": {"avatar_url": "https://avatars.githubusercontent.com/u/47359?v=4", "email": "", "events_url": "https://api.github.com/users/apache/events{/privacy}", "followers_url": "https://api.github.com/users/apache/followers", "following_url": "https://api.github.com/users/apache/following{/other_user}", "gists_url": "https://api.github.com/users/apache/gists{/gist_id}", "gravatar_id": "", "html_url": "https://github.com/apache", "id": 47359, "login": "apache", "name": "apache", "node_id": "MDEyOk9yZ2FuaXphdGlvbjQ3MzU5", "organizations_url": "https://api.github.com/users/apache/orgs", "received_events_url": "https://api.github.com/users/apache/received_events", "repos_url": "https://api.github.com/users/apache/repos", "site_admin": false, "starred_url": "https://api.github.com/users/apache/starred{/owner}{/repo}", "subscriptions_url": "https://api.github.com/users/apache/subscriptions", "type": "Organization", "url": "https://api.github.com/users/apache"}, "private": false, "pulls_url": "https://api.github.com/repos/apache/pulsar/pulls{/number}", "pushed_at": 0, "releases_url": "https://api.github.com/repos/apache/pulsar/releases{/id}", "size": 0, "ssh_url": "git@github.com:apache/pulsar.git", "stargazers": 0, "stargazers_count": 0, "stargazers_url": "https://api.github.com/repos/apache/pulsar/stargazers", "statuses_url": "https://api.github.com/repos/apache/pulsar/statuses/{sha}", "subscribers_url": "https://api.github.com/repos/apache/pulsar/subscribers", "subscription_url": "https://api.github.com/repos/apache/pulsar/subscription", "svn_url": "https://github.com/apache/pulsar", "tags_url": "https://api.github.com/repos/apache/pulsar/tags", "teams_url": "https://api.github.com/repos/apache/pulsar/teams", "topics": [], "trees_url": "https://api.github.com/repos/apache/pulsar/git/trees{/sha}", "updated_at": "2026-03-27T06:09:08Z", "url": "https://api.github.com/repos/apache/pulsar", "visibility": "public", "watchers": 0, "watchers_count": 0, "web_commit_signoff_required": false}' o:'!=' l:'' p:')' o:'&&' p:'(' s:master o:'!=' s:master p:')')" INPUT_CACHE-WRITE-ONLY=false INPUT_CACHE-OVERWRITE-EXISTING=false INPUT_CACHE-CLEANUP=on-success INPUT_GRADLE-HOME-CACHE-INCLUDES='caches
notifications
' INPUT_ADD-JOB-SUMMARY-AS-PR-COMMENT=never INPUT_DEPENDENCY-GRAPH=disabled INPUT_DEPENDENCY-GRAPH-REPORT-DIR=dependency-graph-reports INPUT_DEPENDENCY-GRAPH-CONTINUE-ON-FAILURE=true INPUT_BUILD-SCAN-PUBLISH=false INPUT_VALIDATE-WRAPPERS=true INPUT_ALLOW-SNAPSHOT-WRAPPERS=false INPUT_GRADLE-HOME-CACHE-STRICT-MATCH=false INPUT_WORKFLOW-JOB-CONTEXT="$(/home/github/68840355678/helpers/eval_expression p:'(' f:toJSON p:'(' l:'{"name": "Shade on Java 17", "group": "SHADE_RUN", "upload_name": "SHADE_RUN_17", "runtime_jdk": 17, "setup": "./pulsar-build/run_integration_group_gradle.sh SHADE_BUILD"}' p:')' p:')')" INPUT_GITHUB-TOKEN=DUMMY \
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=6 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=lhotari GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/pulsar GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=1a457bbbab464417d5a101ddc7d5d75f16484dd4 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Pulsar CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 ARTIFACT_RETENTION_DAYS=3 JDK_DISTRIBUTION=corretto JOB_NAME='CI - Integration - Shade on Java 17' PULSAR_TEST_IMAGE_NAME=apachepulsar/java-test-image:latest DEVELOCITY_ACCESS_KEY= CI_JDK_MAJOR_VERSION= "${CURRENT_ENV[@]}" \
echo $(test "$_GITHUB_JOB_STATUS" = "success" && echo true || echo false))
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=6 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=lhotari GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/pulsar GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=1a457bbbab464417d5a101ddc7d5d75f16484dd4 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Pulsar CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 ARTIFACT_RETENTION_DAYS=3 JDK_DISTRIBUTION=corretto JOB_NAME='CI - Integration - Shade on Java 17' PULSAR_TEST_IMAGE_NAME=apachepulsar/java-test-image:latest DEVELOCITY_ACCESS_KEY= CI_JDK_MAJOR_VERSION= "${CURRENT_ENV[@]}" \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run 'tar xf gradle-build-outputs.tar'
echo "##[endgroup]"
echo 'tar xf gradle-build-outputs.tar' > /home/github/68840355678/steps/bugswarm_6.sh
chmod u+x /home/github/68840355678/steps/bugswarm_6.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=6 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=lhotari GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/pulsar GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=1a457bbbab464417d5a101ddc7d5d75f16484dd4 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Pulsar CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 ARTIFACT_RETENTION_DAYS=3 JDK_DISTRIBUTION=corretto JOB_NAME='CI - Integration - Shade on Java 17' PULSAR_TEST_IMAGE_NAME=apachepulsar/java-test-image:latest DEVELOCITY_ACCESS_KEY= CI_JDK_MAJOR_VERSION= "${CURRENT_ENV[@]}" \
bash -e /home/github/68840355678/steps/bugswarm_6.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=6 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=lhotari GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/pulsar GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=1a457bbbab464417d5a101ddc7d5d75f16484dd4 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Pulsar CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 ARTIFACT_RETENTION_DAYS=3 JDK_DISTRIBUTION=corretto JOB_NAME='CI - Integration - Shade on Java 17' PULSAR_TEST_IMAGE_NAME=apachepulsar/java-test-image:latest DEVELOCITY_ACCESS_KEY= CI_JDK_MAJOR_VERSION= "${CURRENT_ENV[@]}" \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=6 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=lhotari GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/pulsar GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=1a457bbbab464417d5a101ddc7d5d75f16484dd4 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Pulsar CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 ARTIFACT_RETENTION_DAYS=3 JDK_DISTRIBUTION=corretto JOB_NAME='CI - Integration - Shade on Java 17' PULSAR_TEST_IMAGE_NAME=apachepulsar/java-test-image:latest DEVELOCITY_ACCESS_KEY= CI_JDK_MAJOR_VERSION= "${CURRENT_ENV[@]}" \
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=8 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=lhotari GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/pulsar GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=1a457bbbab464417d5a101ddc7d5d75f16484dd4 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Pulsar CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 ARTIFACT_RETENTION_DAYS=3 JDK_DISTRIBUTION=corretto JOB_NAME='CI - Integration - Shade on Java 17' PULSAR_TEST_IMAGE_NAME=apachepulsar/java-test-image:latest DEVELOCITY_ACCESS_KEY= CI_JDK_MAJOR_VERSION= "${CURRENT_ENV[@]}" \
echo $(test "$_GITHUB_JOB_STATUS" = "success" && echo true || echo false))
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=8 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=lhotari GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/pulsar GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=1a457bbbab464417d5a101ddc7d5d75f16484dd4 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Pulsar CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 ARTIFACT_RETENTION_DAYS=3 JDK_DISTRIBUTION=corretto JOB_NAME='CI - Integration - Shade on Java 17' PULSAR_TEST_IMAGE_NAME=apachepulsar/java-test-image:latest DEVELOCITY_ACCESS_KEY= CI_JDK_MAJOR_VERSION= "${CURRENT_ENV[@]}" \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run 'docker load -i /tmp/java-test-image.tar.gz'
echo "##[endgroup]"
echo 'docker load -i /tmp/java-test-image.tar.gz' > /home/github/68840355678/steps/bugswarm_8.sh
chmod u+x /home/github/68840355678/steps/bugswarm_8.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=8 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=lhotari GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/pulsar GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=1a457bbbab464417d5a101ddc7d5d75f16484dd4 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Pulsar CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 ARTIFACT_RETENTION_DAYS=3 JDK_DISTRIBUTION=corretto JOB_NAME='CI - Integration - Shade on Java 17' PULSAR_TEST_IMAGE_NAME=apachepulsar/java-test-image:latest DEVELOCITY_ACCESS_KEY= CI_JDK_MAJOR_VERSION= "${CURRENT_ENV[@]}" \
bash -e /home/github/68840355678/steps/bugswarm_8.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=8 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=lhotari GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/pulsar GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=1a457bbbab464417d5a101ddc7d5d75f16484dd4 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Pulsar CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 ARTIFACT_RETENTION_DAYS=3 JDK_DISTRIBUTION=corretto JOB_NAME='CI - Integration - Shade on Java 17' PULSAR_TEST_IMAGE_NAME=apachepulsar/java-test-image:latest DEVELOCITY_ACCESS_KEY= CI_JDK_MAJOR_VERSION= "${CURRENT_ENV[@]}" \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=8 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=lhotari GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/pulsar GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=1a457bbbab464417d5a101ddc7d5d75f16484dd4 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Pulsar CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 ARTIFACT_RETENTION_DAYS=3 JDK_DISTRIBUTION=corretto JOB_NAME='CI - Integration - Shade on Java 17' PULSAR_TEST_IMAGE_NAME=apachepulsar/java-test-image:latest DEVELOCITY_ACCESS_KEY= CI_JDK_MAJOR_VERSION= "${CURRENT_ENV[@]}" \
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=9 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=lhotari GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/pulsar GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=1a457bbbab464417d5a101ddc7d5d75f16484dd4 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Pulsar CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 ARTIFACT_RETENTION_DAYS=3 JDK_DISTRIBUTION=corretto JOB_NAME='CI - Integration - Shade on Java 17' PULSAR_TEST_IMAGE_NAME=apachepulsar/java-test-image:latest DEVELOCITY_ACCESS_KEY= CI_JDK_MAJOR_VERSION= "${CURRENT_ENV[@]}" \
echo "$(/home/github/68840355678/helpers/eval_expression p:'(' f:success p:'(' p:')' p:')' o:'&&' s:'./pulsar-build/run_integration_group_gradle.sh SHADE_BUILD')")
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=9 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=lhotari GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/pulsar GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=1a457bbbab464417d5a101ddc7d5d75f16484dd4 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Pulsar CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 ARTIFACT_RETENTION_DAYS=3 JDK_DISTRIBUTION=corretto JOB_NAME='CI - Integration - Shade on Java 17' PULSAR_TEST_IMAGE_NAME=apachepulsar/java-test-image:latest DEVELOCITY_ACCESS_KEY= CI_JDK_MAJOR_VERSION= "${CURRENT_ENV[@]}" \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run './pulsar-build/run_integration_group_gradle.sh SHADE_BUILD'
echo "##[endgroup]"
echo './pulsar-build/run_integration_group_gradle.sh SHADE_BUILD
' > /home/github/68840355678/steps/bugswarm_9.sh
chmod u+x /home/github/68840355678/steps/bugswarm_9.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=9 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=lhotari GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/pulsar GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=1a457bbbab464417d5a101ddc7d5d75f16484dd4 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Pulsar CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 ARTIFACT_RETENTION_DAYS=3 JDK_DISTRIBUTION=corretto JOB_NAME='CI - Integration - Shade on Java 17' PULSAR_TEST_IMAGE_NAME=apachepulsar/java-test-image:latest DEVELOCITY_ACCESS_KEY= CI_JDK_MAJOR_VERSION= "${CURRENT_ENV[@]}" \
bash -e /home/github/68840355678/steps/bugswarm_9.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=9 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=lhotari GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/pulsar GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=1a457bbbab464417d5a101ddc7d5d75f16484dd4 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Pulsar CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 ARTIFACT_RETENTION_DAYS=3 JDK_DISTRIBUTION=corretto JOB_NAME='CI - Integration - Shade on Java 17' PULSAR_TEST_IMAGE_NAME=apachepulsar/java-test-image:latest DEVELOCITY_ACCESS_KEY= CI_JDK_MAJOR_VERSION= "${CURRENT_ENV[@]}" \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=9 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=lhotari GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/pulsar GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=1a457bbbab464417d5a101ddc7d5d75f16484dd4 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Pulsar CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 ARTIFACT_RETENTION_DAYS=3 JDK_DISTRIBUTION=corretto JOB_NAME='CI - Integration - Shade on Java 17' PULSAR_TEST_IMAGE_NAME=apachepulsar/java-test-image:latest DEVELOCITY_ACCESS_KEY= CI_JDK_MAJOR_VERSION= "${CURRENT_ENV[@]}" \
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=10 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=actions/setup-java GITHUB_ACTIONS=true GITHUB_ACTOR=lhotari GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/pulsar GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=1a457bbbab464417d5a101ddc7d5d75f16484dd4 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Pulsar CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 ARTIFACT_RETENTION_DAYS=3 JDK_DISTRIBUTION=corretto GITHUB_ACTION_PATH=/home/github/68840355678/actions/actions-setup-java@v4 JOB_NAME='CI - Integration - Shade on Java 17' PULSAR_TEST_IMAGE_NAME=apachepulsar/java-test-image:latest DEVELOCITY_ACCESS_KEY= CI_JDK_MAJOR_VERSION= "${CURRENT_ENV[@]}" INPUT_DISTRIBUTION="$(test -v "CURRENT_ENV_MAP[JDK_DISTRIBUTION]" && echo "${CURRENT_ENV_MAP[JDK_DISTRIBUTION]}" || echo corretto)" INPUT_JAVA-VERSION=17 INPUT_OVERWRITE-SETTINGS=False INPUT_TOKEN= INPUT_JAVA-PACKAGE=jdk INPUT_CHECK-LATEST=false INPUT_SERVER-ID=github INPUT_SERVER-USERNAME=GITHUB_ACTOR INPUT_SERVER-PASSWORD=GITHUB_TOKEN INPUT_JOB-STATUS="${_GITHUB_JOB_STATUS}" \
echo "$(/home/github/68840355678/helpers/eval_expression p:'(' f:success p:'(' p:')' p:')' o:'&&' l:17)")
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=10 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=actions/setup-java GITHUB_ACTIONS=true GITHUB_ACTOR=lhotari GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/pulsar GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=1a457bbbab464417d5a101ddc7d5d75f16484dd4 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Pulsar CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 ARTIFACT_RETENTION_DAYS=3 JDK_DISTRIBUTION=corretto GITHUB_ACTION_PATH=/home/github/68840355678/actions/actions-setup-java@v4 JOB_NAME='CI - Integration - Shade on Java 17' PULSAR_TEST_IMAGE_NAME=apachepulsar/java-test-image:latest DEVELOCITY_ACCESS_KEY= CI_JDK_MAJOR_VERSION= "${CURRENT_ENV[@]}" INPUT_DISTRIBUTION="$(test -v "CURRENT_ENV_MAP[JDK_DISTRIBUTION]" && echo "${CURRENT_ENV_MAP[JDK_DISTRIBUTION]}" || echo corretto)" INPUT_JAVA-VERSION=17 INPUT_OVERWRITE-SETTINGS=False INPUT_TOKEN= INPUT_JAVA-PACKAGE=jdk INPUT_CHECK-LATEST=false INPUT_SERVER-ID=github INPUT_SERVER-USERNAME=GITHUB_ACTOR INPUT_SERVER-PASSWORD=GITHUB_TOKEN INPUT_JOB-STATUS="${_GITHUB_JOB_STATUS}" \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run actions/setup-java@v4
echo "##[endgroup]"
echo node /home/github/68840355678/actions/actions-setup-java@v4/dist/setup/index.js > /home/github/68840355678/steps/bugswarm_cmd.sh
chmod u+x /home/github/68840355678/steps/bugswarm_cmd.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=10 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=actions/setup-java GITHUB_ACTIONS=true GITHUB_ACTOR=lhotari GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/pulsar GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=1a457bbbab464417d5a101ddc7d5d75f16484dd4 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Pulsar CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 ARTIFACT_RETENTION_DAYS=3 JDK_DISTRIBUTION=corretto GITHUB_ACTION_PATH=/home/github/68840355678/actions/actions-setup-java@v4 JOB_NAME='CI - Integration - Shade on Java 17' PULSAR_TEST_IMAGE_NAME=apachepulsar/java-test-image:latest DEVELOCITY_ACCESS_KEY= CI_JDK_MAJOR_VERSION= "${CURRENT_ENV[@]}" INPUT_DISTRIBUTION="$(test -v "CURRENT_ENV_MAP[JDK_DISTRIBUTION]" && echo "${CURRENT_ENV_MAP[JDK_DISTRIBUTION]}" || echo corretto)" INPUT_JAVA-VERSION=17 INPUT_OVERWRITE-SETTINGS=False INPUT_TOKEN= INPUT_JAVA-PACKAGE=jdk INPUT_CHECK-LATEST=false INPUT_SERVER-ID=github INPUT_SERVER-USERNAME=GITHUB_ACTOR INPUT_SERVER-PASSWORD=GITHUB_TOKEN INPUT_JOB-STATUS="${_GITHUB_JOB_STATUS}" \
bash -e /home/github/68840355678/steps/bugswarm_cmd.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=10 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=actions/setup-java GITHUB_ACTIONS=true GITHUB_ACTOR=lhotari GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/pulsar GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=1a457bbbab464417d5a101ddc7d5d75f16484dd4 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Pulsar CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 ARTIFACT_RETENTION_DAYS=3 JDK_DISTRIBUTION=corretto GITHUB_ACTION_PATH=/home/github/68840355678/actions/actions-setup-java@v4 JOB_NAME='CI - Integration - Shade on Java 17' PULSAR_TEST_IMAGE_NAME=apachepulsar/java-test-image:latest DEVELOCITY_ACCESS_KEY= CI_JDK_MAJOR_VERSION= "${CURRENT_ENV[@]}" INPUT_DISTRIBUTION="$(test -v "CURRENT_ENV_MAP[JDK_DISTRIBUTION]" && echo "${CURRENT_ENV_MAP[JDK_DISTRIBUTION]}" || echo corretto)" INPUT_JAVA-VERSION=17 INPUT_OVERWRITE-SETTINGS=False INPUT_TOKEN= INPUT_JAVA-PACKAGE=jdk INPUT_CHECK-LATEST=false INPUT_SERVER-ID=github INPUT_SERVER-USERNAME=GITHUB_ACTOR INPUT_SERVER-PASSWORD=GITHUB_TOKEN INPUT_JOB-STATUS="${_GITHUB_JOB_STATUS}" \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=10 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=actions/setup-java GITHUB_ACTIONS=true GITHUB_ACTOR=lhotari GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/pulsar GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=1a457bbbab464417d5a101ddc7d5d75f16484dd4 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Pulsar CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 ARTIFACT_RETENTION_DAYS=3 JDK_DISTRIBUTION=corretto GITHUB_ACTION_PATH=/home/github/68840355678/actions/actions-setup-java@v4 JOB_NAME='CI - Integration - Shade on Java 17' PULSAR_TEST_IMAGE_NAME=apachepulsar/java-test-image:latest DEVELOCITY_ACCESS_KEY= CI_JDK_MAJOR_VERSION= "${CURRENT_ENV[@]}" INPUT_DISTRIBUTION="$(test -v "CURRENT_ENV_MAP[JDK_DISTRIBUTION]" && echo "${CURRENT_ENV_MAP[JDK_DISTRIBUTION]}" || echo corretto)" INPUT_JAVA-VERSION=17 INPUT_OVERWRITE-SETTINGS=False INPUT_TOKEN= INPUT_JAVA-PACKAGE=jdk INPUT_CHECK-LATEST=false INPUT_SERVER-ID=github INPUT_SERVER-USERNAME=GITHUB_ACTOR INPUT_SERVER-PASSWORD=GITHUB_TOKEN INPUT_JOB-STATUS="${_GITHUB_JOB_STATUS}" \
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=11 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=lhotari GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/pulsar GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=1a457bbbab464417d5a101ddc7d5d75f16484dd4 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Pulsar CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 ARTIFACT_RETENTION_DAYS=3 JDK_DISTRIBUTION=corretto JOB_NAME='CI - Integration - Shade on Java 17' PULSAR_TEST_IMAGE_NAME=apachepulsar/java-test-image:latest DEVELOCITY_ACCESS_KEY= CI_JDK_MAJOR_VERSION= "${CURRENT_ENV[@]}" \
echo $(test "$_GITHUB_JOB_STATUS" = "success" && echo true || echo false))
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=11 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=lhotari GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/pulsar GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=1a457bbbab464417d5a101ddc7d5d75f16484dd4 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Pulsar CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 ARTIFACT_RETENTION_DAYS=3 JDK_DISTRIBUTION=corretto JOB_NAME='CI - Integration - Shade on Java 17' PULSAR_TEST_IMAGE_NAME=apachepulsar/java-test-image:latest DEVELOCITY_ACCESS_KEY= CI_JDK_MAJOR_VERSION= "${CURRENT_ENV[@]}" \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run './pulsar-build/run_integration_group_gradle.sh SHADE_RUN'
echo "##[endgroup]"
echo './pulsar-build/run_integration_group_gradle.sh SHADE_RUN
' > /home/github/68840355678/steps/bugswarm_11.sh
chmod u+x /home/github/68840355678/steps/bugswarm_11.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=11 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=lhotari GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/pulsar GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=1a457bbbab464417d5a101ddc7d5d75f16484dd4 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Pulsar CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 ARTIFACT_RETENTION_DAYS=3 JDK_DISTRIBUTION=corretto JOB_NAME='CI - Integration - Shade on Java 17' PULSAR_TEST_IMAGE_NAME=apachepulsar/java-test-image:latest DEVELOCITY_ACCESS_KEY= CI_JDK_MAJOR_VERSION= "${CURRENT_ENV[@]}" \
bash -e /home/github/68840355678/steps/bugswarm_11.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=11 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=lhotari GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/pulsar GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=1a457bbbab464417d5a101ddc7d5d75f16484dd4 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Pulsar CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 ARTIFACT_RETENTION_DAYS=3 JDK_DISTRIBUTION=corretto JOB_NAME='CI - Integration - Shade on Java 17' PULSAR_TEST_IMAGE_NAME=apachepulsar/java-test-image:latest DEVELOCITY_ACCESS_KEY= CI_JDK_MAJOR_VERSION= "${CURRENT_ENV[@]}" \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=11 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=lhotari GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/pulsar GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=1a457bbbab464417d5a101ddc7d5d75f16484dd4 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Pulsar CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 ARTIFACT_RETENTION_DAYS=3 JDK_DISTRIBUTION=corretto JOB_NAME='CI - Integration - Shade on Java 17' PULSAR_TEST_IMAGE_NAME=apachepulsar/java-test-image:latest DEVELOCITY_ACCESS_KEY= CI_JDK_MAJOR_VERSION= "${CURRENT_ENV[@]}" \
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=12 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=lhotari GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/pulsar GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=1a457bbbab464417d5a101ddc7d5d75f16484dd4 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Pulsar CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 ARTIFACT_RETENTION_DAYS=3 JDK_DISTRIBUTION=corretto JOB_NAME='CI - Integration - Shade on Java 17' PULSAR_TEST_IMAGE_NAME=apachepulsar/java-test-image:latest DEVELOCITY_ACCESS_KEY= CI_JDK_MAJOR_VERSION= "${CURRENT_ENV[@]}" \
echo "$(/home/github/68840355678/helpers/eval_expression p:'(' f:cancelled p:'(' p:')' p:')')")
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=12 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=lhotari GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/pulsar GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=1a457bbbab464417d5a101ddc7d5d75f16484dd4 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Pulsar CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 ARTIFACT_RETENTION_DAYS=3 JDK_DISTRIBUTION=corretto JOB_NAME='CI - Integration - Shade on Java 17' PULSAR_TEST_IMAGE_NAME=apachepulsar/java-test-image:latest DEVELOCITY_ACCESS_KEY= CI_JDK_MAJOR_VERSION= "${CURRENT_ENV[@]}" \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run '$GITHUB_WORKSPACE/pulsar-build/pulsar_ci_tool.sh print_thread_dumps'
echo "##[endgroup]"
echo '$GITHUB_WORKSPACE/pulsar-build/pulsar_ci_tool.sh print_thread_dumps' > /home/github/68840355678/steps/bugswarm_12.sh
chmod u+x /home/github/68840355678/steps/bugswarm_12.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=12 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=lhotari GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/pulsar GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=1a457bbbab464417d5a101ddc7d5d75f16484dd4 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Pulsar CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 ARTIFACT_RETENTION_DAYS=3 JDK_DISTRIBUTION=corretto JOB_NAME='CI - Integration - Shade on Java 17' PULSAR_TEST_IMAGE_NAME=apachepulsar/java-test-image:latest DEVELOCITY_ACCESS_KEY= CI_JDK_MAJOR_VERSION= "${CURRENT_ENV[@]}" \
bash -e /home/github/68840355678/steps/bugswarm_12.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=12 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=lhotari GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/pulsar GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=1a457bbbab464417d5a101ddc7d5d75f16484dd4 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Pulsar CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 ARTIFACT_RETENTION_DAYS=3 JDK_DISTRIBUTION=corretto JOB_NAME='CI - Integration - Shade on Java 17' PULSAR_TEST_IMAGE_NAME=apachepulsar/java-test-image:latest DEVELOCITY_ACCESS_KEY= CI_JDK_MAJOR_VERSION= "${CURRENT_ENV[@]}" \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=12 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=lhotari GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/pulsar GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=1a457bbbab464417d5a101ddc7d5d75f16484dd4 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Pulsar CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 ARTIFACT_RETENTION_DAYS=3 JDK_DISTRIBUTION=corretto JOB_NAME='CI - Integration - Shade on Java 17' PULSAR_TEST_IMAGE_NAME=apachepulsar/java-test-image:latest DEVELOCITY_ACCESS_KEY= CI_JDK_MAJOR_VERSION= "${CURRENT_ENV[@]}" \
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=13 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=apache/pulsar GITHUB_ACTIONS=true GITHUB_ACTOR=lhotari GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/pulsar GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=1a457bbbab464417d5a101ddc7d5d75f16484dd4 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Pulsar CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 ARTIFACT_RETENTION_DAYS=3 JDK_DISTRIBUTION=corretto GITHUB_ACTION_PATH=/home/github/68840355678/actions/apache-pulsar/./.github/actions/copy-test-reports JOB_NAME='CI - Integration - Shade on Java 17' PULSAR_TEST_IMAGE_NAME=apachepulsar/java-test-image:latest DEVELOCITY_ACCESS_KEY= CI_JDK_MAJOR_VERSION= "${CURRENT_ENV[@]}" \
echo "$(/home/github/68840355678/helpers/eval_expression p:'(' f:always p:'(' p:')' p:')')")
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=13 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=apache/pulsar GITHUB_ACTIONS=true GITHUB_ACTOR=lhotari GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/pulsar GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=1a457bbbab464417d5a101ddc7d5d75f16484dd4 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Pulsar CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 ARTIFACT_RETENTION_DAYS=3 JDK_DISTRIBUTION=corretto GITHUB_ACTION_PATH=/home/github/68840355678/actions/apache-pulsar/./.github/actions/copy-test-reports JOB_NAME='CI - Integration - Shade on Java 17' PULSAR_TEST_IMAGE_NAME=apachepulsar/java-test-image:latest DEVELOCITY_ACCESS_KEY= CI_JDK_MAJOR_VERSION= "${CURRENT_ENV[@]}" \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run ./.github/actions/copy-test-reports
echo "##[endgroup]"
echo /home/github/68840355678/steps/bugswarm_13_composite.sh > /home/github/68840355678/steps/bugswarm_13.sh
chmod u+x /home/github/68840355678/steps/bugswarm_13.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=13 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=apache/pulsar GITHUB_ACTIONS=true GITHUB_ACTOR=lhotari GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/pulsar GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=1a457bbbab464417d5a101ddc7d5d75f16484dd4 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Pulsar CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 ARTIFACT_RETENTION_DAYS=3 JDK_DISTRIBUTION=corretto GITHUB_ACTION_PATH=/home/github/68840355678/actions/apache-pulsar/./.github/actions/copy-test-reports JOB_NAME='CI - Integration - Shade on Java 17' PULSAR_TEST_IMAGE_NAME=apachepulsar/java-test-image:latest DEVELOCITY_ACCESS_KEY= CI_JDK_MAJOR_VERSION= "${CURRENT_ENV[@]}" \
bash -e /home/github/68840355678/steps/bugswarm_13.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=13 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=apache/pulsar GITHUB_ACTIONS=true GITHUB_ACTOR=lhotari GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/pulsar GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=1a457bbbab464417d5a101ddc7d5d75f16484dd4 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Pulsar CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 ARTIFACT_RETENTION_DAYS=3 JDK_DISTRIBUTION=corretto GITHUB_ACTION_PATH=/home/github/68840355678/actions/apache-pulsar/./.github/actions/copy-test-reports JOB_NAME='CI - Integration - Shade on Java 17' PULSAR_TEST_IMAGE_NAME=apachepulsar/java-test-image:latest DEVELOCITY_ACCESS_KEY= CI_JDK_MAJOR_VERSION= "${CURRENT_ENV[@]}" \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=13 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=apache/pulsar GITHUB_ACTIONS=true GITHUB_ACTOR=lhotari GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/pulsar GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=1a457bbbab464417d5a101ddc7d5d75f16484dd4 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Pulsar CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 ARTIFACT_RETENTION_DAYS=3 JDK_DISTRIBUTION=corretto GITHUB_ACTION_PATH=/home/github/68840355678/actions/apache-pulsar/./.github/actions/copy-test-reports JOB_NAME='CI - Integration - Shade on Java 17' PULSAR_TEST_IMAGE_NAME=apachepulsar/java-test-image:latest DEVELOCITY_ACCESS_KEY= CI_JDK_MAJOR_VERSION= "${CURRENT_ENV[@]}" \
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=14 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=apache/pulsar-test-infra GITHUB_ACTIONS=true GITHUB_ACTOR=lhotari GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/pulsar GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=1a457bbbab464417d5a101ddc7d5d75f16484dd4 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Pulsar CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 ARTIFACT_RETENTION_DAYS=3 JDK_DISTRIBUTION=corretto GITHUB_ACTION_PATH=/home/github/68840355678/actions/apache-pulsar-test-infra@master/action-junit-report JOB_NAME='CI - Integration - Shade on Java 17' PULSAR_TEST_IMAGE_NAME=apachepulsar/java-test-image:latest DEVELOCITY_ACCESS_KEY= CI_JDK_MAJOR_VERSION= "${CURRENT_ENV[@]}" INPUT_REPORT_PATHS='test-reports/TEST-*.xml' INPUT_ANNOTATE_ONLY=true INPUT_TOKEN=DUMMY INPUT_TEST_FILES_PREFIX= INPUT_EXCLUDE_SOURCES=/build/,/__pycache__/ INPUT_SUITE_REGEX= INPUT_UPDATE_CHECK=false INPUT_CHECK_NAME='JUnit Test Report' INPUT_FAIL_ON_FAILURE=false INPUT_REQUIRE_TESTS=false INPUT_INCLUDE_PASSED=false INPUT_SUMMARY= INPUT_CHECK_RETRIES=false INPUT_TRANSFORMERS='[]' INPUT_JOB_SUMMARY=true INPUT_DETAILED_SUMMARY=false INPUT_ANNOTATE_NOTICE=false \
echo "$(/home/github/68840355678/helpers/eval_expression p:'(' f:always p:'(' p:')' p:')')")
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=14 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=apache/pulsar-test-infra GITHUB_ACTIONS=true GITHUB_ACTOR=lhotari GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/pulsar GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=1a457bbbab464417d5a101ddc7d5d75f16484dd4 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Pulsar CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 ARTIFACT_RETENTION_DAYS=3 JDK_DISTRIBUTION=corretto GITHUB_ACTION_PATH=/home/github/68840355678/actions/apache-pulsar-test-infra@master/action-junit-report JOB_NAME='CI - Integration - Shade on Java 17' PULSAR_TEST_IMAGE_NAME=apachepulsar/java-test-image:latest DEVELOCITY_ACCESS_KEY= CI_JDK_MAJOR_VERSION= "${CURRENT_ENV[@]}" INPUT_REPORT_PATHS='test-reports/TEST-*.xml' INPUT_ANNOTATE_ONLY=true INPUT_TOKEN=DUMMY INPUT_TEST_FILES_PREFIX= INPUT_EXCLUDE_SOURCES=/build/,/__pycache__/ INPUT_SUITE_REGEX= INPUT_UPDATE_CHECK=false INPUT_CHECK_NAME='JUnit Test Report' INPUT_FAIL_ON_FAILURE=false INPUT_REQUIRE_TESTS=false INPUT_INCLUDE_PASSED=false INPUT_SUMMARY= INPUT_CHECK_RETRIES=false INPUT_TRANSFORMERS='[]' INPUT_JOB_SUMMARY=true INPUT_DETAILED_SUMMARY=false INPUT_ANNOTATE_NOTICE=false \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run apache/pulsar-test-infra/action-junit-report@master
echo "##[endgroup]"
echo node /home/github/68840355678/actions/apache-pulsar-test-infra@master/action-junit-report/dist/index.js > /home/github/68840355678/steps/bugswarm_cmd.sh
chmod u+x /home/github/68840355678/steps/bugswarm_cmd.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=14 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=apache/pulsar-test-infra GITHUB_ACTIONS=true GITHUB_ACTOR=lhotari GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/pulsar GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=1a457bbbab464417d5a101ddc7d5d75f16484dd4 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Pulsar CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 ARTIFACT_RETENTION_DAYS=3 JDK_DISTRIBUTION=corretto GITHUB_ACTION_PATH=/home/github/68840355678/actions/apache-pulsar-test-infra@master/action-junit-report JOB_NAME='CI - Integration - Shade on Java 17' PULSAR_TEST_IMAGE_NAME=apachepulsar/java-test-image:latest DEVELOCITY_ACCESS_KEY= CI_JDK_MAJOR_VERSION= "${CURRENT_ENV[@]}" INPUT_REPORT_PATHS='test-reports/TEST-*.xml' INPUT_ANNOTATE_ONLY=true INPUT_TOKEN=DUMMY INPUT_TEST_FILES_PREFIX= INPUT_EXCLUDE_SOURCES=/build/,/__pycache__/ INPUT_SUITE_REGEX= INPUT_UPDATE_CHECK=false INPUT_CHECK_NAME='JUnit Test Report' INPUT_FAIL_ON_FAILURE=false INPUT_REQUIRE_TESTS=false INPUT_INCLUDE_PASSED=false INPUT_SUMMARY= INPUT_CHECK_RETRIES=false INPUT_TRANSFORMERS='[]' INPUT_JOB_SUMMARY=true INPUT_DETAILED_SUMMARY=false INPUT_ANNOTATE_NOTICE=false \
bash -e /home/github/68840355678/steps/bugswarm_cmd.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=14 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=apache/pulsar-test-infra GITHUB_ACTIONS=true GITHUB_ACTOR=lhotari GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/pulsar GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=1a457bbbab464417d5a101ddc7d5d75f16484dd4 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Pulsar CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 ARTIFACT_RETENTION_DAYS=3 JDK_DISTRIBUTION=corretto GITHUB_ACTION_PATH=/home/github/68840355678/actions/apache-pulsar-test-infra@master/action-junit-report JOB_NAME='CI - Integration - Shade on Java 17' PULSAR_TEST_IMAGE_NAME=apachepulsar/java-test-image:latest DEVELOCITY_ACCESS_KEY= CI_JDK_MAJOR_VERSION= "${CURRENT_ENV[@]}" INPUT_REPORT_PATHS='test-reports/TEST-*.xml' INPUT_ANNOTATE_ONLY=true INPUT_TOKEN=DUMMY INPUT_TEST_FILES_PREFIX= INPUT_EXCLUDE_SOURCES=/build/,/__pycache__/ INPUT_SUITE_REGEX= INPUT_UPDATE_CHECK=false INPUT_CHECK_NAME='JUnit Test Report' INPUT_FAIL_ON_FAILURE=false INPUT_REQUIRE_TESTS=false INPUT_INCLUDE_PASSED=false INPUT_SUMMARY= INPUT_CHECK_RETRIES=false INPUT_TRANSFORMERS='[]' INPUT_JOB_SUMMARY=true INPUT_DETAILED_SUMMARY=false INPUT_ANNOTATE_NOTICE=false \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=14 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=apache/pulsar-test-infra GITHUB_ACTIONS=true GITHUB_ACTOR=lhotari GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/pulsar GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=1a457bbbab464417d5a101ddc7d5d75f16484dd4 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Pulsar CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 ARTIFACT_RETENTION_DAYS=3 JDK_DISTRIBUTION=corretto GITHUB_ACTION_PATH=/home/github/68840355678/actions/apache-pulsar-test-infra@master/action-junit-report JOB_NAME='CI - Integration - Shade on Java 17' PULSAR_TEST_IMAGE_NAME=apachepulsar/java-test-image:latest DEVELOCITY_ACCESS_KEY= CI_JDK_MAJOR_VERSION= "${CURRENT_ENV[@]}" INPUT_REPORT_PATHS='test-reports/TEST-*.xml' INPUT_ANNOTATE_ONLY=true INPUT_TOKEN=DUMMY INPUT_TEST_FILES_PREFIX= INPUT_EXCLUDE_SOURCES=/build/,/__pycache__/ INPUT_SUITE_REGEX= INPUT_UPDATE_CHECK=false INPUT_CHECK_NAME='JUnit Test Report' INPUT_FAIL_ON_FAILURE=false INPUT_REQUIRE_TESTS=false INPUT_INCLUDE_PASSED=false INPUT_SUMMARY= INPUT_CHECK_RETRIES=false INPUT_TRANSFORMERS='[]' INPUT_JOB_SUMMARY=true INPUT_DETAILED_SUMMARY=false INPUT_ANNOTATE_NOTICE=false \
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=18 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=apache/pulsar GITHUB_ACTIONS=true GITHUB_ACTOR=lhotari GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/pulsar GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=1a457bbbab464417d5a101ddc7d5d75f16484dd4 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Pulsar CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 ARTIFACT_RETENTION_DAYS=3 JDK_DISTRIBUTION=corretto GITHUB_ACTION_PATH=/home/github/68840355678/actions/apache-pulsar/./.github/actions/ssh-access JOB_NAME='CI - Integration - Shade on Java 17' PULSAR_TEST_IMAGE_NAME=apachepulsar/java-test-image:latest DEVELOCITY_ACCESS_KEY= CI_JDK_MAJOR_VERSION= "${CURRENT_ENV[@]}" INPUT_ACTION=wait INPUT_LIMIT-ACCESS-TO-ACTOR=false INPUT_LIMIT-ACCESS-TO-USERS= INPUT_SECURE-ACCESS=true INPUT_TIMEOUT=300 \
echo "$(/home/github/68840355678/helpers/eval_expression p:'(' f:failure p:'(' p:')' p:')' o:'&&' p:'(' s:apache/pulsar o:'!=' s:apache/pulsar p:')' o:'&&' p:'(' s:push o:== s:pull_request p:')')")
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=18 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=apache/pulsar GITHUB_ACTIONS=true GITHUB_ACTOR=lhotari GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/pulsar GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=1a457bbbab464417d5a101ddc7d5d75f16484dd4 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Pulsar CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 ARTIFACT_RETENTION_DAYS=3 JDK_DISTRIBUTION=corretto GITHUB_ACTION_PATH=/home/github/68840355678/actions/apache-pulsar/./.github/actions/ssh-access JOB_NAME='CI - Integration - Shade on Java 17' PULSAR_TEST_IMAGE_NAME=apachepulsar/java-test-image:latest DEVELOCITY_ACCESS_KEY= CI_JDK_MAJOR_VERSION= "${CURRENT_ENV[@]}" INPUT_ACTION=wait INPUT_LIMIT-ACCESS-TO-ACTOR=false INPUT_LIMIT-ACCESS-TO-USERS= INPUT_SECURE-ACCESS=true INPUT_TIMEOUT=300 \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run ./.github/actions/ssh-access
echo "##[endgroup]"
echo /home/github/68840355678/steps/bugswarm_18_composite.sh > /home/github/68840355678/steps/bugswarm_18.sh
chmod u+x /home/github/68840355678/steps/bugswarm_18.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=18 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=apache/pulsar GITHUB_ACTIONS=true GITHUB_ACTOR=lhotari GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/pulsar GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=1a457bbbab464417d5a101ddc7d5d75f16484dd4 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Pulsar CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 ARTIFACT_RETENTION_DAYS=3 JDK_DISTRIBUTION=corretto GITHUB_ACTION_PATH=/home/github/68840355678/actions/apache-pulsar/./.github/actions/ssh-access JOB_NAME='CI - Integration - Shade on Java 17' PULSAR_TEST_IMAGE_NAME=apachepulsar/java-test-image:latest DEVELOCITY_ACCESS_KEY= CI_JDK_MAJOR_VERSION= "${CURRENT_ENV[@]}" INPUT_ACTION=wait INPUT_LIMIT-ACCESS-TO-ACTOR=false INPUT_LIMIT-ACCESS-TO-USERS= INPUT_SECURE-ACCESS=true INPUT_TIMEOUT=300 \
bash -e /home/github/68840355678/steps/bugswarm_18.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=18 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=apache/pulsar GITHUB_ACTIONS=true GITHUB_ACTOR=lhotari GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/pulsar GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=1a457bbbab464417d5a101ddc7d5d75f16484dd4 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Pulsar CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 ARTIFACT_RETENTION_DAYS=3 JDK_DISTRIBUTION=corretto GITHUB_ACTION_PATH=/home/github/68840355678/actions/apache-pulsar/./.github/actions/ssh-access JOB_NAME='CI - Integration - Shade on Java 17' PULSAR_TEST_IMAGE_NAME=apachepulsar/java-test-image:latest DEVELOCITY_ACCESS_KEY= CI_JDK_MAJOR_VERSION= "${CURRENT_ENV[@]}" INPUT_ACTION=wait INPUT_LIMIT-ACCESS-TO-ACTOR=false INPUT_LIMIT-ACCESS-TO-USERS= INPUT_SECURE-ACCESS=true INPUT_TIMEOUT=300 \
echo true)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=18 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=apache/pulsar GITHUB_ACTIONS=true GITHUB_ACTOR=lhotari GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=apache/pulsar GITHUB_REPOSITORY_OWNER=apache GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=1a457bbbab464417d5a101ddc7d5d75f16484dd4 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Pulsar CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 ARTIFACT_RETENTION_DAYS=3 JDK_DISTRIBUTION=corretto GITHUB_ACTION_PATH=/home/github/68840355678/actions/apache-pulsar/./.github/actions/ssh-access JOB_NAME='CI - Integration - Shade on Java 17' PULSAR_TEST_IMAGE_NAME=apachepulsar/java-test-image:latest DEVELOCITY_ACCESS_KEY= CI_JDK_MAJOR_VERSION= "${CURRENT_ENV[@]}" INPUT_ACTION=wait INPUT_LIMIT-ACCESS-TO-ACTOR=false INPUT_LIMIT-ACCESS-TO-USERS= INPUT_SECURE-ACCESS=true INPUT_TIMEOUT=300 \
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
   bash -e $ACTIONS_RUNNER_HOOK_JOB_COMPLETED 68840355678 passed
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
