#!/usr/bin/env bash
export GITHUB_WORKSPACE=/home/github/build/pocl/pocl

if [[ ! -z "$ACTIONS_RUNNER_HOOK_JOB_STARTED" ]]; then
   echo "A job started hook has been configured by the self-hosted runner administrator"
   echo "##[group]Run '$ACTIONS_RUNNER_HOOK_JOB_STARTED'"
   echo "##[endgroup]"
   bash -e $ACTIONS_RUNNER_HOOK_JOB_STARTED 65449972502 failed
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

cp /home/github/65449972502/event.json /home/github/workflow/event.json
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
LAST_JOB_NAME="LOAD_ENV"
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=1 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR='dependabot[bot]' GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=dependabot/github_actions/github/codeql-action-4.32.5 GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/dependabot/github_actions/github/codeql-action-4.32.5 GITHUB_REF_NAME=dependabot/github_actions/github/codeql-action-4.32.5 GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=pocl/pocl GITHUB_REPOSITORY_OWNER=pocl GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=f2f1912d145d88e36bca00eee0f3c8f35a209e35 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Linux / CPU x86-64 on GH tests' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CCACHE_BASEDIR=${GITHUB_WORKSPACE} CCACHE_DIR=${GITHUB_WORKSPACE}/../../../../ccache_storage EXAMPLES_DIR=${GITHUB_WORKSPACE}/../../../../examples "${CURRENT_ENV[@]}" \
echo $(test "$_GITHUB_JOB_STATUS" = "success" && echo true || echo false))
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=1 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR='dependabot[bot]' GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=dependabot/github_actions/github/codeql-action-4.32.5 GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/dependabot/github_actions/github/codeql-action-4.32.5 GITHUB_REF_NAME=dependabot/github_actions/github/codeql-action-4.32.5 GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=pocl/pocl GITHUB_REPOSITORY_OWNER=pocl GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=f2f1912d145d88e36bca00eee0f3c8f35a209e35 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Linux / CPU x86-64 on GH tests' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CCACHE_BASEDIR=${GITHUB_WORKSPACE} CCACHE_DIR=${GITHUB_WORKSPACE}/../../../../ccache_storage EXAMPLES_DIR=${GITHUB_WORKSPACE}/../../../../examples "${CURRENT_ENV[@]}" \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run 'cat '${GITHUB_WORKSPACE}'/.github/variables.txt >> $GITHUB_ENV'
echo "##[endgroup]"
echo 'cat '${GITHUB_WORKSPACE}'/.github/variables.txt >> $GITHUB_ENV
' > /home/github/65449972502/steps/bugswarm_1.sh
chmod u+x /home/github/65449972502/steps/bugswarm_1.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=1 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR='dependabot[bot]' GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=dependabot/github_actions/github/codeql-action-4.32.5 GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/dependabot/github_actions/github/codeql-action-4.32.5 GITHUB_REF_NAME=dependabot/github_actions/github/codeql-action-4.32.5 GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=pocl/pocl GITHUB_REPOSITORY_OWNER=pocl GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=f2f1912d145d88e36bca00eee0f3c8f35a209e35 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Linux / CPU x86-64 on GH tests' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CCACHE_BASEDIR=${GITHUB_WORKSPACE} CCACHE_DIR=${GITHUB_WORKSPACE}/../../../../ccache_storage EXAMPLES_DIR=${GITHUB_WORKSPACE}/../../../../examples "${CURRENT_ENV[@]}" \
bash -e /home/github/65449972502/steps/bugswarm_1.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=1 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR='dependabot[bot]' GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=dependabot/github_actions/github/codeql-action-4.32.5 GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/dependabot/github_actions/github/codeql-action-4.32.5 GITHUB_REF_NAME=dependabot/github_actions/github/codeql-action-4.32.5 GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=pocl/pocl GITHUB_REPOSITORY_OWNER=pocl GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=f2f1912d145d88e36bca00eee0f3c8f35a209e35 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Linux / CPU x86-64 on GH tests' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CCACHE_BASEDIR=${GITHUB_WORKSPACE} CCACHE_DIR=${GITHUB_WORKSPACE}/../../../../ccache_storage EXAMPLES_DIR=${GITHUB_WORKSPACE}/../../../../examples "${CURRENT_ENV[@]}" \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

  _CONTEXT_STEPS_LOAD_ENV_OUTCOME=failure
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    _CONTEXT_STEPS_LOAD_ENV_CONCLUSION=failure
  else
    _CONTEXT_STEPS_LOAD_ENV_CONCLUSION=success
  fi
else
  _CONTEXT_STEPS_LOAD_ENV_OUTCOME=success
  _CONTEXT_STEPS_LOAD_ENV_CONCLUSION=success
fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=1 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR='dependabot[bot]' GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=dependabot/github_actions/github/codeql-action-4.32.5 GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/dependabot/github_actions/github/codeql-action-4.32.5 GITHUB_REF_NAME=dependabot/github_actions/github/codeql-action-4.32.5 GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=pocl/pocl GITHUB_REPOSITORY_OWNER=pocl GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=f2f1912d145d88e36bca00eee0f3c8f35a209e35 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Linux / CPU x86-64 on GH tests' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CCACHE_BASEDIR=${GITHUB_WORKSPACE} CCACHE_DIR=${GITHUB_WORKSPACE}/../../../../ccache_storage EXAMPLES_DIR=${GITHUB_WORKSPACE}/../../../../examples "${CURRENT_ENV[@]}" \
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=2 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR='dependabot[bot]' GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=dependabot/github_actions/github/codeql-action-4.32.5 GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/dependabot/github_actions/github/codeql-action-4.32.5 GITHUB_REF_NAME=dependabot/github_actions/github/codeql-action-4.32.5 GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=pocl/pocl GITHUB_REPOSITORY_OWNER=pocl GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=f2f1912d145d88e36bca00eee0f3c8f35a209e35 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Linux / CPU x86-64 on GH tests' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CCACHE_BASEDIR=${GITHUB_WORKSPACE} CCACHE_DIR=${GITHUB_WORKSPACE}/../../../../ccache_storage EXAMPLES_DIR=${GITHUB_WORKSPACE}/../../../../examples "${CURRENT_ENV[@]}" \
echo $(test "$_GITHUB_JOB_STATUS" = "success" && echo true || echo false))
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=2 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR='dependabot[bot]' GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=dependabot/github_actions/github/codeql-action-4.32.5 GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/dependabot/github_actions/github/codeql-action-4.32.5 GITHUB_REF_NAME=dependabot/github_actions/github/codeql-action-4.32.5 GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=pocl/pocl GITHUB_REPOSITORY_OWNER=pocl GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=f2f1912d145d88e36bca00eee0f3c8f35a209e35 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Linux / CPU x86-64 on GH tests' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CCACHE_BASEDIR=${GITHUB_WORKSPACE} CCACHE_DIR=${GITHUB_WORKSPACE}/../../../../ccache_storage EXAMPLES_DIR=${GITHUB_WORKSPACE}/../../../../examples "${CURRENT_ENV[@]}" \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run 'sudo apt update -y && sudo apt install -y wget gpg python3-dev libpython3-dev build-essential ocl-icd-libopencl1 cmake make git pkg-config ocl-icd-libopencl1 ocl-icd-dev ocl-icd-opencl-dev libhwloc-dev zlib1g-dev libtbb-dev'
echo "##[endgroup]"
echo 'sudo apt update -y && sudo apt install -y wget gpg python3-dev libpython3-dev build-essential ocl-icd-libopencl1 cmake make git pkg-config ocl-icd-libopencl1 ocl-icd-dev ocl-icd-opencl-dev libhwloc-dev zlib1g-dev libtbb-dev
' > /home/github/65449972502/steps/bugswarm_2.sh
chmod u+x /home/github/65449972502/steps/bugswarm_2.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=2 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR='dependabot[bot]' GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=dependabot/github_actions/github/codeql-action-4.32.5 GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/dependabot/github_actions/github/codeql-action-4.32.5 GITHUB_REF_NAME=dependabot/github_actions/github/codeql-action-4.32.5 GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=pocl/pocl GITHUB_REPOSITORY_OWNER=pocl GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=f2f1912d145d88e36bca00eee0f3c8f35a209e35 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Linux / CPU x86-64 on GH tests' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CCACHE_BASEDIR=${GITHUB_WORKSPACE} CCACHE_DIR=${GITHUB_WORKSPACE}/../../../../ccache_storage EXAMPLES_DIR=${GITHUB_WORKSPACE}/../../../../examples "${CURRENT_ENV[@]}" \
bash -e /home/github/65449972502/steps/bugswarm_2.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=2 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR='dependabot[bot]' GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=dependabot/github_actions/github/codeql-action-4.32.5 GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/dependabot/github_actions/github/codeql-action-4.32.5 GITHUB_REF_NAME=dependabot/github_actions/github/codeql-action-4.32.5 GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=pocl/pocl GITHUB_REPOSITORY_OWNER=pocl GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=f2f1912d145d88e36bca00eee0f3c8f35a209e35 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Linux / CPU x86-64 on GH tests' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CCACHE_BASEDIR=${GITHUB_WORKSPACE} CCACHE_DIR=${GITHUB_WORKSPACE}/../../../../ccache_storage EXAMPLES_DIR=${GITHUB_WORKSPACE}/../../../../examples "${CURRENT_ENV[@]}" \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=2 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR='dependabot[bot]' GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=dependabot/github_actions/github/codeql-action-4.32.5 GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/dependabot/github_actions/github/codeql-action-4.32.5 GITHUB_REF_NAME=dependabot/github_actions/github/codeql-action-4.32.5 GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=pocl/pocl GITHUB_REPOSITORY_OWNER=pocl GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=f2f1912d145d88e36bca00eee0f3c8f35a209e35 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Linux / CPU x86-64 on GH tests' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CCACHE_BASEDIR=${GITHUB_WORKSPACE} CCACHE_DIR=${GITHUB_WORKSPACE}/../../../../ccache_storage EXAMPLES_DIR=${GITHUB_WORKSPACE}/../../../../examples "${CURRENT_ENV[@]}" \
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=3 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR='dependabot[bot]' GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=dependabot/github_actions/github/codeql-action-4.32.5 GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/dependabot/github_actions/github/codeql-action-4.32.5 GITHUB_REF_NAME=dependabot/github_actions/github/codeql-action-4.32.5 GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=pocl/pocl GITHUB_REPOSITORY_OWNER=pocl GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=f2f1912d145d88e36bca00eee0f3c8f35a209e35 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Linux / CPU x86-64 on GH tests' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CCACHE_BASEDIR=${GITHUB_WORKSPACE} CCACHE_DIR=${GITHUB_WORKSPACE}/../../../../ccache_storage EXAMPLES_DIR=${GITHUB_WORKSPACE}/../../../../examples "${CURRENT_ENV[@]}" \
echo "$(/home/github/65449972502/helpers/eval_expression p:'(' f:success p:'(' p:')' p:')' o:'&&' p:'(' l:21 o:== n:18 p:')')")
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=3 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR='dependabot[bot]' GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=dependabot/github_actions/github/codeql-action-4.32.5 GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/dependabot/github_actions/github/codeql-action-4.32.5 GITHUB_REF_NAME=dependabot/github_actions/github/codeql-action-4.32.5 GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=pocl/pocl GITHUB_REPOSITORY_OWNER=pocl GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=f2f1912d145d88e36bca00eee0f3c8f35a209e35 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Linux / CPU x86-64 on GH tests' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CCACHE_BASEDIR=${GITHUB_WORKSPACE} CCACHE_DIR=${GITHUB_WORKSPACE}/../../../../ccache_storage EXAMPLES_DIR=${GITHUB_WORKSPACE}/../../../../examples "${CURRENT_ENV[@]}" \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run 'export LLVM_VERSION=21 && sudo apt install -y libclang-cpp${LLVM_VERSION}-dev llvm-${LLVM_VERSION}-dev libclang-${LLVM_VERSION}-dev clang-${LLVM_VERSION} llvm-${LLVM_VERSION} llvm-spirv-${LLVM_VERSION} libpolly-${LLVM_VERSION}-dev spirv-tools'
echo "##[endgroup]"
echo 'export LLVM_VERSION=21 && sudo apt install -y libclang-cpp${LLVM_VERSION}-dev llvm-${LLVM_VERSION}-dev libclang-${LLVM_VERSION}-dev clang-${LLVM_VERSION} llvm-${LLVM_VERSION} llvm-spirv-${LLVM_VERSION} libpolly-${LLVM_VERSION}-dev spirv-tools
' > /home/github/65449972502/steps/bugswarm_3.sh
chmod u+x /home/github/65449972502/steps/bugswarm_3.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=3 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR='dependabot[bot]' GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=dependabot/github_actions/github/codeql-action-4.32.5 GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/dependabot/github_actions/github/codeql-action-4.32.5 GITHUB_REF_NAME=dependabot/github_actions/github/codeql-action-4.32.5 GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=pocl/pocl GITHUB_REPOSITORY_OWNER=pocl GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=f2f1912d145d88e36bca00eee0f3c8f35a209e35 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Linux / CPU x86-64 on GH tests' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CCACHE_BASEDIR=${GITHUB_WORKSPACE} CCACHE_DIR=${GITHUB_WORKSPACE}/../../../../ccache_storage EXAMPLES_DIR=${GITHUB_WORKSPACE}/../../../../examples "${CURRENT_ENV[@]}" \
bash -e /home/github/65449972502/steps/bugswarm_3.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=3 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR='dependabot[bot]' GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=dependabot/github_actions/github/codeql-action-4.32.5 GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/dependabot/github_actions/github/codeql-action-4.32.5 GITHUB_REF_NAME=dependabot/github_actions/github/codeql-action-4.32.5 GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=pocl/pocl GITHUB_REPOSITORY_OWNER=pocl GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=f2f1912d145d88e36bca00eee0f3c8f35a209e35 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Linux / CPU x86-64 on GH tests' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CCACHE_BASEDIR=${GITHUB_WORKSPACE} CCACHE_DIR=${GITHUB_WORKSPACE}/../../../../ccache_storage EXAMPLES_DIR=${GITHUB_WORKSPACE}/../../../../examples "${CURRENT_ENV[@]}" \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=3 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR='dependabot[bot]' GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=dependabot/github_actions/github/codeql-action-4.32.5 GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/dependabot/github_actions/github/codeql-action-4.32.5 GITHUB_REF_NAME=dependabot/github_actions/github/codeql-action-4.32.5 GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=pocl/pocl GITHUB_REPOSITORY_OWNER=pocl GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=f2f1912d145d88e36bca00eee0f3c8f35a209e35 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Linux / CPU x86-64 on GH tests' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CCACHE_BASEDIR=${GITHUB_WORKSPACE} CCACHE_DIR=${GITHUB_WORKSPACE}/../../../../ccache_storage EXAMPLES_DIR=${GITHUB_WORKSPACE}/../../../../examples "${CURRENT_ENV[@]}" \
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=4 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR='dependabot[bot]' GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=dependabot/github_actions/github/codeql-action-4.32.5 GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/dependabot/github_actions/github/codeql-action-4.32.5 GITHUB_REF_NAME=dependabot/github_actions/github/codeql-action-4.32.5 GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=pocl/pocl GITHUB_REPOSITORY_OWNER=pocl GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=f2f1912d145d88e36bca00eee0f3c8f35a209e35 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Linux / CPU x86-64 on GH tests' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CCACHE_BASEDIR=${GITHUB_WORKSPACE} CCACHE_DIR=${GITHUB_WORKSPACE}/../../../../ccache_storage EXAMPLES_DIR=${GITHUB_WORKSPACE}/../../../../examples "${CURRENT_ENV[@]}" \
echo "$(/home/github/65449972502/helpers/eval_expression p:'(' f:success p:'(' p:')' p:')' o:'&&' p:'(' l:21 o:== n:19 p:')')")
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=4 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR='dependabot[bot]' GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=dependabot/github_actions/github/codeql-action-4.32.5 GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/dependabot/github_actions/github/codeql-action-4.32.5 GITHUB_REF_NAME=dependabot/github_actions/github/codeql-action-4.32.5 GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=pocl/pocl GITHUB_REPOSITORY_OWNER=pocl GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=f2f1912d145d88e36bca00eee0f3c8f35a209e35 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Linux / CPU x86-64 on GH tests' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CCACHE_BASEDIR=${GITHUB_WORKSPACE} CCACHE_DIR=${GITHUB_WORKSPACE}/../../../../ccache_storage EXAMPLES_DIR=${GITHUB_WORKSPACE}/../../../../examples "${CURRENT_ENV[@]}" \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run 'export LLVM_VERSION=21 && sudo apt install -y libclang-cpp${LLVM_VERSION}-dev llvm-${LLVM_VERSION}-dev libclang-${LLVM_VERSION}-dev clang-${LLVM_VERSION} llvm-${LLVM_VERSION} libllvmspirvlib-${LLVM_VERSION}-dev llvm-spirv-${LLVM_VERSION} libpolly-${LLVM_VERSION}-dev spirv-tools'
echo "##[endgroup]"
echo 'export LLVM_VERSION=21 && sudo apt install -y libclang-cpp${LLVM_VERSION}-dev llvm-${LLVM_VERSION}-dev libclang-${LLVM_VERSION}-dev clang-${LLVM_VERSION} llvm-${LLVM_VERSION} libllvmspirvlib-${LLVM_VERSION}-dev llvm-spirv-${LLVM_VERSION} libpolly-${LLVM_VERSION}-dev spirv-tools
' > /home/github/65449972502/steps/bugswarm_4.sh
chmod u+x /home/github/65449972502/steps/bugswarm_4.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=4 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR='dependabot[bot]' GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=dependabot/github_actions/github/codeql-action-4.32.5 GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/dependabot/github_actions/github/codeql-action-4.32.5 GITHUB_REF_NAME=dependabot/github_actions/github/codeql-action-4.32.5 GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=pocl/pocl GITHUB_REPOSITORY_OWNER=pocl GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=f2f1912d145d88e36bca00eee0f3c8f35a209e35 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Linux / CPU x86-64 on GH tests' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CCACHE_BASEDIR=${GITHUB_WORKSPACE} CCACHE_DIR=${GITHUB_WORKSPACE}/../../../../ccache_storage EXAMPLES_DIR=${GITHUB_WORKSPACE}/../../../../examples "${CURRENT_ENV[@]}" \
bash -e /home/github/65449972502/steps/bugswarm_4.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=4 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR='dependabot[bot]' GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=dependabot/github_actions/github/codeql-action-4.32.5 GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/dependabot/github_actions/github/codeql-action-4.32.5 GITHUB_REF_NAME=dependabot/github_actions/github/codeql-action-4.32.5 GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=pocl/pocl GITHUB_REPOSITORY_OWNER=pocl GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=f2f1912d145d88e36bca00eee0f3c8f35a209e35 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Linux / CPU x86-64 on GH tests' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CCACHE_BASEDIR=${GITHUB_WORKSPACE} CCACHE_DIR=${GITHUB_WORKSPACE}/../../../../ccache_storage EXAMPLES_DIR=${GITHUB_WORKSPACE}/../../../../examples "${CURRENT_ENV[@]}" \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=4 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR='dependabot[bot]' GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=dependabot/github_actions/github/codeql-action-4.32.5 GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/dependabot/github_actions/github/codeql-action-4.32.5 GITHUB_REF_NAME=dependabot/github_actions/github/codeql-action-4.32.5 GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=pocl/pocl GITHUB_REPOSITORY_OWNER=pocl GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=f2f1912d145d88e36bca00eee0f3c8f35a209e35 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Linux / CPU x86-64 on GH tests' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CCACHE_BASEDIR=${GITHUB_WORKSPACE} CCACHE_DIR=${GITHUB_WORKSPACE}/../../../../ccache_storage EXAMPLES_DIR=${GITHUB_WORKSPACE}/../../../../examples "${CURRENT_ENV[@]}" \
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=5 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR='dependabot[bot]' GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=dependabot/github_actions/github/codeql-action-4.32.5 GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/dependabot/github_actions/github/codeql-action-4.32.5 GITHUB_REF_NAME=dependabot/github_actions/github/codeql-action-4.32.5 GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=pocl/pocl GITHUB_REPOSITORY_OWNER=pocl GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=f2f1912d145d88e36bca00eee0f3c8f35a209e35 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Linux / CPU x86-64 on GH tests' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CCACHE_BASEDIR=${GITHUB_WORKSPACE} CCACHE_DIR=${GITHUB_WORKSPACE}/../../../../ccache_storage EXAMPLES_DIR=${GITHUB_WORKSPACE}/../../../../examples "${CURRENT_ENV[@]}" \
echo "$(/home/github/65449972502/helpers/eval_expression p:'(' f:success p:'(' p:')' p:')' o:'&&' p:'(' l:21 o:== n:20 p:')')")
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=5 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR='dependabot[bot]' GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=dependabot/github_actions/github/codeql-action-4.32.5 GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/dependabot/github_actions/github/codeql-action-4.32.5 GITHUB_REF_NAME=dependabot/github_actions/github/codeql-action-4.32.5 GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=pocl/pocl GITHUB_REPOSITORY_OWNER=pocl GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=f2f1912d145d88e36bca00eee0f3c8f35a209e35 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Linux / CPU x86-64 on GH tests' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CCACHE_BASEDIR=${GITHUB_WORKSPACE} CCACHE_DIR=${GITHUB_WORKSPACE}/../../../../ccache_storage EXAMPLES_DIR=${GITHUB_WORKSPACE}/../../../../examples "${CURRENT_ENV[@]}" \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run 'export LLVM_VERSION=21 && sudo apt install -y libclang-cpp${LLVM_VERSION}-dev llvm-${LLVM_VERSION}-dev libclang-${LLVM_VERSION}-dev clang-${LLVM_VERSION} llvm-${LLVM_VERSION} libllvmspirvlib-${LLVM_VERSION}-dev libpolly-${LLVM_VERSION}-dev spirv-tools'
echo "##[endgroup]"
echo 'export LLVM_VERSION=21 && sudo apt install -y libclang-cpp${LLVM_VERSION}-dev llvm-${LLVM_VERSION}-dev libclang-${LLVM_VERSION}-dev clang-${LLVM_VERSION} llvm-${LLVM_VERSION} libllvmspirvlib-${LLVM_VERSION}-dev libpolly-${LLVM_VERSION}-dev spirv-tools
' > /home/github/65449972502/steps/bugswarm_5.sh
chmod u+x /home/github/65449972502/steps/bugswarm_5.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=5 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR='dependabot[bot]' GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=dependabot/github_actions/github/codeql-action-4.32.5 GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/dependabot/github_actions/github/codeql-action-4.32.5 GITHUB_REF_NAME=dependabot/github_actions/github/codeql-action-4.32.5 GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=pocl/pocl GITHUB_REPOSITORY_OWNER=pocl GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=f2f1912d145d88e36bca00eee0f3c8f35a209e35 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Linux / CPU x86-64 on GH tests' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CCACHE_BASEDIR=${GITHUB_WORKSPACE} CCACHE_DIR=${GITHUB_WORKSPACE}/../../../../ccache_storage EXAMPLES_DIR=${GITHUB_WORKSPACE}/../../../../examples "${CURRENT_ENV[@]}" \
bash -e /home/github/65449972502/steps/bugswarm_5.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=5 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR='dependabot[bot]' GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=dependabot/github_actions/github/codeql-action-4.32.5 GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/dependabot/github_actions/github/codeql-action-4.32.5 GITHUB_REF_NAME=dependabot/github_actions/github/codeql-action-4.32.5 GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=pocl/pocl GITHUB_REPOSITORY_OWNER=pocl GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=f2f1912d145d88e36bca00eee0f3c8f35a209e35 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Linux / CPU x86-64 on GH tests' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CCACHE_BASEDIR=${GITHUB_WORKSPACE} CCACHE_DIR=${GITHUB_WORKSPACE}/../../../../ccache_storage EXAMPLES_DIR=${GITHUB_WORKSPACE}/../../../../examples "${CURRENT_ENV[@]}" \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=5 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR='dependabot[bot]' GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=dependabot/github_actions/github/codeql-action-4.32.5 GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/dependabot/github_actions/github/codeql-action-4.32.5 GITHUB_REF_NAME=dependabot/github_actions/github/codeql-action-4.32.5 GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=pocl/pocl GITHUB_REPOSITORY_OWNER=pocl GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=f2f1912d145d88e36bca00eee0f3c8f35a209e35 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Linux / CPU x86-64 on GH tests' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CCACHE_BASEDIR=${GITHUB_WORKSPACE} CCACHE_DIR=${GITHUB_WORKSPACE}/../../../../ccache_storage EXAMPLES_DIR=${GITHUB_WORKSPACE}/../../../../examples "${CURRENT_ENV[@]}" \
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=6 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR='dependabot[bot]' GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=dependabot/github_actions/github/codeql-action-4.32.5 GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/dependabot/github_actions/github/codeql-action-4.32.5 GITHUB_REF_NAME=dependabot/github_actions/github/codeql-action-4.32.5 GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=pocl/pocl GITHUB_REPOSITORY_OWNER=pocl GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=f2f1912d145d88e36bca00eee0f3c8f35a209e35 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Linux / CPU x86-64 on GH tests' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CCACHE_BASEDIR=${GITHUB_WORKSPACE} CCACHE_DIR=${GITHUB_WORKSPACE}/../../../../ccache_storage EXAMPLES_DIR=${GITHUB_WORKSPACE}/../../../../examples "${CURRENT_ENV[@]}" \
echo "$(/home/github/65449972502/helpers/eval_expression p:'(' f:success p:'(' p:')' p:')' o:'&&' p:'(' l:21 o:'>=' n:21 p:')')")
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=6 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR='dependabot[bot]' GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=dependabot/github_actions/github/codeql-action-4.32.5 GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/dependabot/github_actions/github/codeql-action-4.32.5 GITHUB_REF_NAME=dependabot/github_actions/github/codeql-action-4.32.5 GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=pocl/pocl GITHUB_REPOSITORY_OWNER=pocl GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=f2f1912d145d88e36bca00eee0f3c8f35a209e35 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Linux / CPU x86-64 on GH tests' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CCACHE_BASEDIR=${GITHUB_WORKSPACE} CCACHE_DIR=${GITHUB_WORKSPACE}/../../../../ccache_storage EXAMPLES_DIR=${GITHUB_WORKSPACE}/../../../../examples "${CURRENT_ENV[@]}" \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run 'export LLVM_VERSION=21 && wget -qO- https://apt.llvm.org/llvm-snapshot.gpg.key | sudo gpg --dearmor -o /usr/share/keyrings/llvm-snapshot.gpg && echo "deb [signed-by=/usr/share/keyrings/llvm-snapshot.gpg] http://apt.llvm.org/noble/ llvm-toolchain-noble-${LLVM_VERSION} main" >/tmp/llvm.list && sudo mv /tmp/llvm.list /etc/apt/sources.list.d/ && sudo apt update -y && sudo apt install -y libclang-cpp${LLVM_VERSION}-dev llvm-${LLVM_VERSION}-dev libclang-${LLVM_VERSION}-dev clang-${LLVM_VERSION} llvm-${LLVM_VERSION} mlir-${LLVM_VERSION}-tools libllvmlibc-${LLVM_VERSION}-dev libpolly-${LLVM_VERSION}-dev spirv-tools'
echo "##[endgroup]"
echo 'export LLVM_VERSION=21 && wget -qO- https://apt.llvm.org/llvm-snapshot.gpg.key | sudo gpg --dearmor -o /usr/share/keyrings/llvm-snapshot.gpg && echo "deb [signed-by=/usr/share/keyrings/llvm-snapshot.gpg] http://apt.llvm.org/noble/ llvm-toolchain-noble-${LLVM_VERSION} main" >/tmp/llvm.list && sudo mv /tmp/llvm.list /etc/apt/sources.list.d/ && sudo apt update -y && sudo apt install -y libclang-cpp${LLVM_VERSION}-dev llvm-${LLVM_VERSION}-dev libclang-${LLVM_VERSION}-dev clang-${LLVM_VERSION} llvm-${LLVM_VERSION} mlir-${LLVM_VERSION}-tools libllvmlibc-${LLVM_VERSION}-dev libpolly-${LLVM_VERSION}-dev spirv-tools
' > /home/github/65449972502/steps/bugswarm_6.sh
chmod u+x /home/github/65449972502/steps/bugswarm_6.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=6 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR='dependabot[bot]' GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=dependabot/github_actions/github/codeql-action-4.32.5 GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/dependabot/github_actions/github/codeql-action-4.32.5 GITHUB_REF_NAME=dependabot/github_actions/github/codeql-action-4.32.5 GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=pocl/pocl GITHUB_REPOSITORY_OWNER=pocl GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=f2f1912d145d88e36bca00eee0f3c8f35a209e35 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Linux / CPU x86-64 on GH tests' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CCACHE_BASEDIR=${GITHUB_WORKSPACE} CCACHE_DIR=${GITHUB_WORKSPACE}/../../../../ccache_storage EXAMPLES_DIR=${GITHUB_WORKSPACE}/../../../../examples "${CURRENT_ENV[@]}" \
bash -e /home/github/65449972502/steps/bugswarm_6.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=6 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR='dependabot[bot]' GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=dependabot/github_actions/github/codeql-action-4.32.5 GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/dependabot/github_actions/github/codeql-action-4.32.5 GITHUB_REF_NAME=dependabot/github_actions/github/codeql-action-4.32.5 GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=pocl/pocl GITHUB_REPOSITORY_OWNER=pocl GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=f2f1912d145d88e36bca00eee0f3c8f35a209e35 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Linux / CPU x86-64 on GH tests' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CCACHE_BASEDIR=${GITHUB_WORKSPACE} CCACHE_DIR=${GITHUB_WORKSPACE}/../../../../ccache_storage EXAMPLES_DIR=${GITHUB_WORKSPACE}/../../../../examples "${CURRENT_ENV[@]}" \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=6 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR='dependabot[bot]' GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=dependabot/github_actions/github/codeql-action-4.32.5 GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/dependabot/github_actions/github/codeql-action-4.32.5 GITHUB_REF_NAME=dependabot/github_actions/github/codeql-action-4.32.5 GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=pocl/pocl GITHUB_REPOSITORY_OWNER=pocl GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=f2f1912d145d88e36bca00eee0f3c8f35a209e35 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Linux / CPU x86-64 on GH tests' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CCACHE_BASEDIR=${GITHUB_WORKSPACE} CCACHE_DIR=${GITHUB_WORKSPACE}/../../../../ccache_storage EXAMPLES_DIR=${GITHUB_WORKSPACE}/../../../../examples "${CURRENT_ENV[@]}" \
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=7 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR='dependabot[bot]' GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=dependabot/github_actions/github/codeql-action-4.32.5 GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/dependabot/github_actions/github/codeql-action-4.32.5 GITHUB_REF_NAME=dependabot/github_actions/github/codeql-action-4.32.5 GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=pocl/pocl GITHUB_REPOSITORY_OWNER=pocl GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=f2f1912d145d88e36bca00eee0f3c8f35a209e35 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Linux / CPU x86-64 on GH tests' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CCACHE_BASEDIR=${GITHUB_WORKSPACE} CCACHE_DIR=${GITHUB_WORKSPACE}/../../../../ccache_storage EXAMPLES_DIR=${GITHUB_WORKSPACE}/../../../../examples "${CURRENT_ENV[@]}" \
echo "$(/home/github/65449972502/helpers/eval_expression p:'(' f:success p:'(' p:')' p:')' o:'&&' p:'(' s:DBKs o:== s:DBKs p:')')")
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=7 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR='dependabot[bot]' GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=dependabot/github_actions/github/codeql-action-4.32.5 GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/dependabot/github_actions/github/codeql-action-4.32.5 GITHUB_REF_NAME=dependabot/github_actions/github/codeql-action-4.32.5 GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=pocl/pocl GITHUB_REPOSITORY_OWNER=pocl GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=f2f1912d145d88e36bca00eee0f3c8f35a209e35 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Linux / CPU x86-64 on GH tests' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CCACHE_BASEDIR=${GITHUB_WORKSPACE} CCACHE_DIR=${GITHUB_WORKSPACE}/../../../../ccache_storage EXAMPLES_DIR=${GITHUB_WORKSPACE}/../../../../examples "${CURRENT_ENV[@]}" \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run 'sudo apt install -y libopenblas-dev && sudo wget -q -O libjpeg-turbo.deb https://github.com/libjpeg-turbo/libjpeg-turbo/releases/download/3.0.4/libjpeg-turbo-official_3.0.4_amd64.deb && sudo dpkg -i libjpeg-turbo.deb && sudo wget -q -O /tmp/onnx-runtime.tgz https://github.com/microsoft/onnxruntime/releases/download/v1.19.2/onnxruntime-linux-x64-1.19.2.tgz && sudo mkdir /opt/onnx && sudo tar -xf /tmp/onnx-runtime.tgz -C /opt/onnx --strip-components=1 && sudo ln -s /opt/libjpeg-turbo/lib64 /opt/libjpeg-turbo/lib && sudo ln -s /opt/onnx/lib /opt/onnx/lib64 && sudo mv /opt/onnx/include /opt/onnxruntime && sudo mkdir /opt/onnx/include && sudo mv /opt/onnxruntime /opt/onnx/include/ && sudo bash -c '"'"'mkdir /opt/source && cd /opt/source && git clone https://github.com/libxsmm/libxsmm.git && cd libxsmm && git checkout 50c67024876111d81e685e94939ccbf04ab464b9 && echo "unstable-1.17.1" > version.txt && make -j3 STATIC=0 FORTRAN=0 AVX=2 install DESTDIR=/opt/xsmm'"'"''
echo "##[endgroup]"
echo 'sudo apt install -y libopenblas-dev && sudo wget -q -O libjpeg-turbo.deb https://github.com/libjpeg-turbo/libjpeg-turbo/releases/download/3.0.4/libjpeg-turbo-official_3.0.4_amd64.deb && sudo dpkg -i libjpeg-turbo.deb && sudo wget -q -O /tmp/onnx-runtime.tgz https://github.com/microsoft/onnxruntime/releases/download/v1.19.2/onnxruntime-linux-x64-1.19.2.tgz && sudo mkdir /opt/onnx && sudo tar -xf /tmp/onnx-runtime.tgz -C /opt/onnx --strip-components=1 && sudo ln -s /opt/libjpeg-turbo/lib64 /opt/libjpeg-turbo/lib && sudo ln -s /opt/onnx/lib /opt/onnx/lib64 && sudo mv /opt/onnx/include /opt/onnxruntime && sudo mkdir /opt/onnx/include && sudo mv /opt/onnxruntime /opt/onnx/include/ && sudo bash -c '"'"'mkdir /opt/source && cd /opt/source && git clone https://github.com/libxsmm/libxsmm.git && cd libxsmm && git checkout 50c67024876111d81e685e94939ccbf04ab464b9 && echo "unstable-1.17.1" > version.txt && make -j3 STATIC=0 FORTRAN=0 AVX=2 install DESTDIR=/opt/xsmm'"'"'
' > /home/github/65449972502/steps/bugswarm_7.sh
chmod u+x /home/github/65449972502/steps/bugswarm_7.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=7 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR='dependabot[bot]' GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=dependabot/github_actions/github/codeql-action-4.32.5 GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/dependabot/github_actions/github/codeql-action-4.32.5 GITHUB_REF_NAME=dependabot/github_actions/github/codeql-action-4.32.5 GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=pocl/pocl GITHUB_REPOSITORY_OWNER=pocl GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=f2f1912d145d88e36bca00eee0f3c8f35a209e35 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Linux / CPU x86-64 on GH tests' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CCACHE_BASEDIR=${GITHUB_WORKSPACE} CCACHE_DIR=${GITHUB_WORKSPACE}/../../../../ccache_storage EXAMPLES_DIR=${GITHUB_WORKSPACE}/../../../../examples "${CURRENT_ENV[@]}" \
bash -e /home/github/65449972502/steps/bugswarm_7.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=7 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR='dependabot[bot]' GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=dependabot/github_actions/github/codeql-action-4.32.5 GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/dependabot/github_actions/github/codeql-action-4.32.5 GITHUB_REF_NAME=dependabot/github_actions/github/codeql-action-4.32.5 GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=pocl/pocl GITHUB_REPOSITORY_OWNER=pocl GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=f2f1912d145d88e36bca00eee0f3c8f35a209e35 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Linux / CPU x86-64 on GH tests' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CCACHE_BASEDIR=${GITHUB_WORKSPACE} CCACHE_DIR=${GITHUB_WORKSPACE}/../../../../ccache_storage EXAMPLES_DIR=${GITHUB_WORKSPACE}/../../../../examples "${CURRENT_ENV[@]}" \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=7 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR='dependabot[bot]' GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=dependabot/github_actions/github/codeql-action-4.32.5 GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/dependabot/github_actions/github/codeql-action-4.32.5 GITHUB_REF_NAME=dependabot/github_actions/github/codeql-action-4.32.5 GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=pocl/pocl GITHUB_REPOSITORY_OWNER=pocl GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=f2f1912d145d88e36bca00eee0f3c8f35a209e35 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Linux / CPU x86-64 on GH tests' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CCACHE_BASEDIR=${GITHUB_WORKSPACE} CCACHE_DIR=${GITHUB_WORKSPACE}/../../../../ccache_storage EXAMPLES_DIR=${GITHUB_WORKSPACE}/../../../../examples "${CURRENT_ENV[@]}" \
bash -e $ACTIONS_RUNNER_HOOK_STEP_COMPLETED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

fi

update_current_env "$LAST_JOB_NAME"
LAST_JOB_NAME="CMAKE"
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=8 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR='dependabot[bot]' GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=dependabot/github_actions/github/codeql-action-4.32.5 GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/dependabot/github_actions/github/codeql-action-4.32.5 GITHUB_REF_NAME=dependabot/github_actions/github/codeql-action-4.32.5 GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=pocl/pocl GITHUB_REPOSITORY_OWNER=pocl GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=f2f1912d145d88e36bca00eee0f3c8f35a209e35 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Linux / CPU x86-64 on GH tests' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CCACHE_BASEDIR=${GITHUB_WORKSPACE} CCACHE_DIR=${GITHUB_WORKSPACE}/../../../../ccache_storage EXAMPLES_DIR=${GITHUB_WORKSPACE}/../../../../examples "${CURRENT_ENV[@]}" \
echo $(test "$_GITHUB_JOB_STATUS" = "success" && echo true || echo false))
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=8 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR='dependabot[bot]' GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=dependabot/github_actions/github/codeql-action-4.32.5 GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/dependabot/github_actions/github/codeql-action-4.32.5 GITHUB_REF_NAME=dependabot/github_actions/github/codeql-action-4.32.5 GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=pocl/pocl GITHUB_REPOSITORY_OWNER=pocl GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=f2f1912d145d88e36bca00eee0f3c8f35a209e35 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Linux / CPU x86-64 on GH tests' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CCACHE_BASEDIR=${GITHUB_WORKSPACE} CCACHE_DIR=${GITHUB_WORKSPACE}/../../../../ccache_storage EXAMPLES_DIR=${GITHUB_WORKSPACE}/../../../../examples "${CURRENT_ENV[@]}" \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run 'if [ "DBKs" == "DBKs" ]; then'
echo "##[endgroup]"
echo 'if [ "DBKs" == "DBKs" ]; then
  export "CMAKE_PREFIX_PATH=/opt/libjpeg-turbo/lib/cmake:/opt/onnx/lib/cmake"
  export "PKG_CONFIG_PATH=/opt/xsmm/lib"
fi
runCMake() {
  BUILD_FLAGS="-O1 -march=native -Wall -Wextra -Wno-unused-parameter -Wno-unused-variable"
  cmake -DCMAKE_BUILD_TYPE=RelWithDebInfo \
  "-DCMAKE_C_FLAGS_RELWITHDEBINFO=$BUILD_FLAGS" \
  "-DCMAKE_CXX_FLAGS_RELWITHDEBINFO=$BUILD_FLAGS" \
  -DWITH_LLVM_CONFIG=/usr/bin/llvm-config-21 \
  "$@" -B '${GITHUB_WORKSPACE}'/build '${GITHUB_WORKSPACE}'
}

rm -rf '${GITHUB_WORKSPACE}'/build
mkdir '${GITHUB_WORKSPACE}'/build
if [ "DBKs" == "install" ]; then
  runCMake -DCMAKE_INSTALL_PREFIX=/usr -DENABLE_ICD=1 -DKERNELLIB_HOST_CPU_VARIANTS=distro -DPOCL_ICD_ABSOLUTE_PATH=OFF -DENABLE_POCL_BUILDING=OFF
elif [ "DBKs" == "DBKs" ]; then
  runCMake -DENABLE_ICD=1 -DENABLE_HOST_CPU_DEVICES=1
else
  echo "Unknown configuration" && exit 1
fi
' > /home/github/65449972502/steps/bugswarm_8.sh
chmod u+x /home/github/65449972502/steps/bugswarm_8.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=8 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR='dependabot[bot]' GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=dependabot/github_actions/github/codeql-action-4.32.5 GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/dependabot/github_actions/github/codeql-action-4.32.5 GITHUB_REF_NAME=dependabot/github_actions/github/codeql-action-4.32.5 GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=pocl/pocl GITHUB_REPOSITORY_OWNER=pocl GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=f2f1912d145d88e36bca00eee0f3c8f35a209e35 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Linux / CPU x86-64 on GH tests' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CCACHE_BASEDIR=${GITHUB_WORKSPACE} CCACHE_DIR=${GITHUB_WORKSPACE}/../../../../ccache_storage EXAMPLES_DIR=${GITHUB_WORKSPACE}/../../../../examples "${CURRENT_ENV[@]}" \
bash -e /home/github/65449972502/steps/bugswarm_8.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=8 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR='dependabot[bot]' GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=dependabot/github_actions/github/codeql-action-4.32.5 GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/dependabot/github_actions/github/codeql-action-4.32.5 GITHUB_REF_NAME=dependabot/github_actions/github/codeql-action-4.32.5 GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=pocl/pocl GITHUB_REPOSITORY_OWNER=pocl GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=f2f1912d145d88e36bca00eee0f3c8f35a209e35 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Linux / CPU x86-64 on GH tests' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CCACHE_BASEDIR=${GITHUB_WORKSPACE} CCACHE_DIR=${GITHUB_WORKSPACE}/../../../../ccache_storage EXAMPLES_DIR=${GITHUB_WORKSPACE}/../../../../examples "${CURRENT_ENV[@]}" \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

  _CONTEXT_STEPS_CMAKE_OUTCOME=failure
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    _CONTEXT_STEPS_CMAKE_CONCLUSION=failure
  else
    _CONTEXT_STEPS_CMAKE_CONCLUSION=success
  fi
else
  _CONTEXT_STEPS_CMAKE_OUTCOME=success
  _CONTEXT_STEPS_CMAKE_CONCLUSION=success
fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=8 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR='dependabot[bot]' GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=dependabot/github_actions/github/codeql-action-4.32.5 GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/dependabot/github_actions/github/codeql-action-4.32.5 GITHUB_REF_NAME=dependabot/github_actions/github/codeql-action-4.32.5 GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=pocl/pocl GITHUB_REPOSITORY_OWNER=pocl GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=f2f1912d145d88e36bca00eee0f3c8f35a209e35 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Linux / CPU x86-64 on GH tests' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CCACHE_BASEDIR=${GITHUB_WORKSPACE} CCACHE_DIR=${GITHUB_WORKSPACE}/../../../../ccache_storage EXAMPLES_DIR=${GITHUB_WORKSPACE}/../../../../examples "${CURRENT_ENV[@]}" \
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=9 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR='dependabot[bot]' GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=dependabot/github_actions/github/codeql-action-4.32.5 GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/dependabot/github_actions/github/codeql-action-4.32.5 GITHUB_REF_NAME=dependabot/github_actions/github/codeql-action-4.32.5 GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=pocl/pocl GITHUB_REPOSITORY_OWNER=pocl GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=f2f1912d145d88e36bca00eee0f3c8f35a209e35 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Linux / CPU x86-64 on GH tests' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CCACHE_BASEDIR=${GITHUB_WORKSPACE} CCACHE_DIR=${GITHUB_WORKSPACE}/../../../../ccache_storage EXAMPLES_DIR=${GITHUB_WORKSPACE}/../../../../examples "${CURRENT_ENV[@]}" \
echo "$(/home/github/65449972502/helpers/eval_expression p:'(' f:success p:'(' p:')' p:')' o:'&&' p:'(' s:DBKs o:== s:DBKs p:')')")
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=9 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR='dependabot[bot]' GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=dependabot/github_actions/github/codeql-action-4.32.5 GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/dependabot/github_actions/github/codeql-action-4.32.5 GITHUB_REF_NAME=dependabot/github_actions/github/codeql-action-4.32.5 GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=pocl/pocl GITHUB_REPOSITORY_OWNER=pocl GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=f2f1912d145d88e36bca00eee0f3c8f35a209e35 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Linux / CPU x86-64 on GH tests' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CCACHE_BASEDIR=${GITHUB_WORKSPACE} CCACHE_DIR=${GITHUB_WORKSPACE}/../../../../ccache_storage EXAMPLES_DIR=${GITHUB_WORKSPACE}/../../../../examples "${CURRENT_ENV[@]}" \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run 'cd '${GITHUB_WORKSPACE}'/build && grep '"'"'define HAVE_ONNXRT'"'"' config.h && grep '"'"'define HAVE_LIBJPEG_TURBO'"'"' config.h && grep '"'"'define HAVE_LIBXSMM'"'"' config.h'
echo "##[endgroup]"
echo 'cd '${GITHUB_WORKSPACE}'/build && grep '"'"'define HAVE_ONNXRT'"'"' config.h && grep '"'"'define HAVE_LIBJPEG_TURBO'"'"' config.h && grep '"'"'define HAVE_LIBXSMM'"'"' config.h
' > /home/github/65449972502/steps/bugswarm_9.sh
chmod u+x /home/github/65449972502/steps/bugswarm_9.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=9 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR='dependabot[bot]' GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=dependabot/github_actions/github/codeql-action-4.32.5 GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/dependabot/github_actions/github/codeql-action-4.32.5 GITHUB_REF_NAME=dependabot/github_actions/github/codeql-action-4.32.5 GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=pocl/pocl GITHUB_REPOSITORY_OWNER=pocl GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=f2f1912d145d88e36bca00eee0f3c8f35a209e35 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Linux / CPU x86-64 on GH tests' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CCACHE_BASEDIR=${GITHUB_WORKSPACE} CCACHE_DIR=${GITHUB_WORKSPACE}/../../../../ccache_storage EXAMPLES_DIR=${GITHUB_WORKSPACE}/../../../../examples "${CURRENT_ENV[@]}" \
bash -e /home/github/65449972502/steps/bugswarm_9.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=9 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR='dependabot[bot]' GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=dependabot/github_actions/github/codeql-action-4.32.5 GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/dependabot/github_actions/github/codeql-action-4.32.5 GITHUB_REF_NAME=dependabot/github_actions/github/codeql-action-4.32.5 GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=pocl/pocl GITHUB_REPOSITORY_OWNER=pocl GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=f2f1912d145d88e36bca00eee0f3c8f35a209e35 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Linux / CPU x86-64 on GH tests' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CCACHE_BASEDIR=${GITHUB_WORKSPACE} CCACHE_DIR=${GITHUB_WORKSPACE}/../../../../ccache_storage EXAMPLES_DIR=${GITHUB_WORKSPACE}/../../../../examples "${CURRENT_ENV[@]}" \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=9 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR='dependabot[bot]' GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=dependabot/github_actions/github/codeql-action-4.32.5 GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/dependabot/github_actions/github/codeql-action-4.32.5 GITHUB_REF_NAME=dependabot/github_actions/github/codeql-action-4.32.5 GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=pocl/pocl GITHUB_REPOSITORY_OWNER=pocl GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=f2f1912d145d88e36bca00eee0f3c8f35a209e35 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Linux / CPU x86-64 on GH tests' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CCACHE_BASEDIR=${GITHUB_WORKSPACE} CCACHE_DIR=${GITHUB_WORKSPACE}/../../../../ccache_storage EXAMPLES_DIR=${GITHUB_WORKSPACE}/../../../../examples "${CURRENT_ENV[@]}" \
bash -e $ACTIONS_RUNNER_HOOK_STEP_COMPLETED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

fi

update_current_env "$LAST_JOB_NAME"
LAST_JOB_NAME="BUILD_POCL"
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=10 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR='dependabot[bot]' GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=dependabot/github_actions/github/codeql-action-4.32.5 GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/dependabot/github_actions/github/codeql-action-4.32.5 GITHUB_REF_NAME=dependabot/github_actions/github/codeql-action-4.32.5 GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=pocl/pocl GITHUB_REPOSITORY_OWNER=pocl GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=f2f1912d145d88e36bca00eee0f3c8f35a209e35 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Linux / CPU x86-64 on GH tests' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CCACHE_BASEDIR=${GITHUB_WORKSPACE} CCACHE_DIR=${GITHUB_WORKSPACE}/../../../../ccache_storage EXAMPLES_DIR=${GITHUB_WORKSPACE}/../../../../examples "${CURRENT_ENV[@]}" \
echo $(test "$_GITHUB_JOB_STATUS" = "success" && echo true || echo false))
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=10 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR='dependabot[bot]' GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=dependabot/github_actions/github/codeql-action-4.32.5 GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/dependabot/github_actions/github/codeql-action-4.32.5 GITHUB_REF_NAME=dependabot/github_actions/github/codeql-action-4.32.5 GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=pocl/pocl GITHUB_REPOSITORY_OWNER=pocl GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=f2f1912d145d88e36bca00eee0f3c8f35a209e35 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Linux / CPU x86-64 on GH tests' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CCACHE_BASEDIR=${GITHUB_WORKSPACE} CCACHE_DIR=${GITHUB_WORKSPACE}/../../../../ccache_storage EXAMPLES_DIR=${GITHUB_WORKSPACE}/../../../../examples "${CURRENT_ENV[@]}" \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run 'cd '${GITHUB_WORKSPACE}'/build && make -j$(nproc)'
echo "##[endgroup]"
echo 'cd '${GITHUB_WORKSPACE}'/build && make -j$(nproc)
' > /home/github/65449972502/steps/bugswarm_10.sh
chmod u+x /home/github/65449972502/steps/bugswarm_10.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=10 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR='dependabot[bot]' GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=dependabot/github_actions/github/codeql-action-4.32.5 GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/dependabot/github_actions/github/codeql-action-4.32.5 GITHUB_REF_NAME=dependabot/github_actions/github/codeql-action-4.32.5 GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=pocl/pocl GITHUB_REPOSITORY_OWNER=pocl GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=f2f1912d145d88e36bca00eee0f3c8f35a209e35 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Linux / CPU x86-64 on GH tests' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CCACHE_BASEDIR=${GITHUB_WORKSPACE} CCACHE_DIR=${GITHUB_WORKSPACE}/../../../../ccache_storage EXAMPLES_DIR=${GITHUB_WORKSPACE}/../../../../examples "${CURRENT_ENV[@]}" \
bash -e /home/github/65449972502/steps/bugswarm_10.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=10 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR='dependabot[bot]' GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=dependabot/github_actions/github/codeql-action-4.32.5 GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/dependabot/github_actions/github/codeql-action-4.32.5 GITHUB_REF_NAME=dependabot/github_actions/github/codeql-action-4.32.5 GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=pocl/pocl GITHUB_REPOSITORY_OWNER=pocl GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=f2f1912d145d88e36bca00eee0f3c8f35a209e35 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Linux / CPU x86-64 on GH tests' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CCACHE_BASEDIR=${GITHUB_WORKSPACE} CCACHE_DIR=${GITHUB_WORKSPACE}/../../../../ccache_storage EXAMPLES_DIR=${GITHUB_WORKSPACE}/../../../../examples "${CURRENT_ENV[@]}" \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

  _CONTEXT_STEPS_BUILD_POCL_OUTCOME=failure
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    _CONTEXT_STEPS_BUILD_POCL_CONCLUSION=failure
  else
    _CONTEXT_STEPS_BUILD_POCL_CONCLUSION=success
  fi
else
  _CONTEXT_STEPS_BUILD_POCL_OUTCOME=success
  _CONTEXT_STEPS_BUILD_POCL_CONCLUSION=success
fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=10 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR='dependabot[bot]' GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=dependabot/github_actions/github/codeql-action-4.32.5 GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/dependabot/github_actions/github/codeql-action-4.32.5 GITHUB_REF_NAME=dependabot/github_actions/github/codeql-action-4.32.5 GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=pocl/pocl GITHUB_REPOSITORY_OWNER=pocl GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=f2f1912d145d88e36bca00eee0f3c8f35a209e35 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Linux / CPU x86-64 on GH tests' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CCACHE_BASEDIR=${GITHUB_WORKSPACE} CCACHE_DIR=${GITHUB_WORKSPACE}/../../../../ccache_storage EXAMPLES_DIR=${GITHUB_WORKSPACE}/../../../../examples "${CURRENT_ENV[@]}" \
bash -e $ACTIONS_RUNNER_HOOK_STEP_COMPLETED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

fi

update_current_env "$LAST_JOB_NAME"
LAST_JOB_NAME="INSTALL_POCL"
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=11 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR='dependabot[bot]' GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=dependabot/github_actions/github/codeql-action-4.32.5 GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/dependabot/github_actions/github/codeql-action-4.32.5 GITHUB_REF_NAME=dependabot/github_actions/github/codeql-action-4.32.5 GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=pocl/pocl GITHUB_REPOSITORY_OWNER=pocl GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=f2f1912d145d88e36bca00eee0f3c8f35a209e35 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Linux / CPU x86-64 on GH tests' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CCACHE_BASEDIR=${GITHUB_WORKSPACE} CCACHE_DIR=${GITHUB_WORKSPACE}/../../../../ccache_storage EXAMPLES_DIR=${GITHUB_WORKSPACE}/../../../../examples "${CURRENT_ENV[@]}" \
echo "$(/home/github/65449972502/helpers/eval_expression p:'(' f:success p:'(' p:')' p:')' o:'&&' p:'(' s:DBKs o:== s:install p:')')")
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=11 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR='dependabot[bot]' GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=dependabot/github_actions/github/codeql-action-4.32.5 GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/dependabot/github_actions/github/codeql-action-4.32.5 GITHUB_REF_NAME=dependabot/github_actions/github/codeql-action-4.32.5 GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=pocl/pocl GITHUB_REPOSITORY_OWNER=pocl GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=f2f1912d145d88e36bca00eee0f3c8f35a209e35 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Linux / CPU x86-64 on GH tests' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CCACHE_BASEDIR=${GITHUB_WORKSPACE} CCACHE_DIR=${GITHUB_WORKSPACE}/../../../../ccache_storage EXAMPLES_DIR=${GITHUB_WORKSPACE}/../../../../examples "${CURRENT_ENV[@]}" \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run '# remove CTestCustom.cmake - it contains POCL_BUILDING and OCL_ICD_VENDORS incompatible with install config'
echo "##[endgroup]"
echo '# remove CTestCustom.cmake - it contains POCL_BUILDING and OCL_ICD_VENDORS incompatible with install config
cd '${GITHUB_WORKSPACE}'/build && sudo make install && rm CTestCustom.cmake
# remove the built libpocl.so library
cd '${GITHUB_WORKSPACE}'/build/lib/CL && make clean
' > /home/github/65449972502/steps/bugswarm_11.sh
chmod u+x /home/github/65449972502/steps/bugswarm_11.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=11 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR='dependabot[bot]' GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=dependabot/github_actions/github/codeql-action-4.32.5 GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/dependabot/github_actions/github/codeql-action-4.32.5 GITHUB_REF_NAME=dependabot/github_actions/github/codeql-action-4.32.5 GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=pocl/pocl GITHUB_REPOSITORY_OWNER=pocl GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=f2f1912d145d88e36bca00eee0f3c8f35a209e35 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Linux / CPU x86-64 on GH tests' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CCACHE_BASEDIR=${GITHUB_WORKSPACE} CCACHE_DIR=${GITHUB_WORKSPACE}/../../../../ccache_storage EXAMPLES_DIR=${GITHUB_WORKSPACE}/../../../../examples "${CURRENT_ENV[@]}" \
bash -e /home/github/65449972502/steps/bugswarm_11.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=11 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR='dependabot[bot]' GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=dependabot/github_actions/github/codeql-action-4.32.5 GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/dependabot/github_actions/github/codeql-action-4.32.5 GITHUB_REF_NAME=dependabot/github_actions/github/codeql-action-4.32.5 GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=pocl/pocl GITHUB_REPOSITORY_OWNER=pocl GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=f2f1912d145d88e36bca00eee0f3c8f35a209e35 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Linux / CPU x86-64 on GH tests' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CCACHE_BASEDIR=${GITHUB_WORKSPACE} CCACHE_DIR=${GITHUB_WORKSPACE}/../../../../ccache_storage EXAMPLES_DIR=${GITHUB_WORKSPACE}/../../../../examples "${CURRENT_ENV[@]}" \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

  _CONTEXT_STEPS_INSTALL_POCL_OUTCOME=failure
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    _CONTEXT_STEPS_INSTALL_POCL_CONCLUSION=failure
  else
    _CONTEXT_STEPS_INSTALL_POCL_CONCLUSION=success
  fi
else
  _CONTEXT_STEPS_INSTALL_POCL_OUTCOME=success
  _CONTEXT_STEPS_INSTALL_POCL_CONCLUSION=success
fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=11 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR='dependabot[bot]' GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=dependabot/github_actions/github/codeql-action-4.32.5 GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/dependabot/github_actions/github/codeql-action-4.32.5 GITHUB_REF_NAME=dependabot/github_actions/github/codeql-action-4.32.5 GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=pocl/pocl GITHUB_REPOSITORY_OWNER=pocl GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=f2f1912d145d88e36bca00eee0f3c8f35a209e35 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Linux / CPU x86-64 on GH tests' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CCACHE_BASEDIR=${GITHUB_WORKSPACE} CCACHE_DIR=${GITHUB_WORKSPACE}/../../../../ccache_storage EXAMPLES_DIR=${GITHUB_WORKSPACE}/../../../../examples "${CURRENT_ENV[@]}" \
bash -e $ACTIONS_RUNNER_HOOK_STEP_COMPLETED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

fi

update_current_env "$LAST_JOB_NAME"
LAST_JOB_NAME="CTEST"
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=12 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR='dependabot[bot]' GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=dependabot/github_actions/github/codeql-action-4.32.5 GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/dependabot/github_actions/github/codeql-action-4.32.5 GITHUB_REF_NAME=dependabot/github_actions/github/codeql-action-4.32.5 GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=pocl/pocl GITHUB_REPOSITORY_OWNER=pocl GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=f2f1912d145d88e36bca00eee0f3c8f35a209e35 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Linux / CPU x86-64 on GH tests' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CCACHE_BASEDIR=${GITHUB_WORKSPACE} CCACHE_DIR=${GITHUB_WORKSPACE}/../../../../ccache_storage EXAMPLES_DIR=${GITHUB_WORKSPACE}/../../../../examples "${CURRENT_ENV[@]}" POCL_CACHE_DIR=/tmp/GH_POCL_CACHE CL_PLATFORM_NAME=Portable CL_DEVICE_TYPE=cpu \
echo $(test "$_GITHUB_JOB_STATUS" = "success" && echo true || echo false))
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=12 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR='dependabot[bot]' GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=dependabot/github_actions/github/codeql-action-4.32.5 GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/dependabot/github_actions/github/codeql-action-4.32.5 GITHUB_REF_NAME=dependabot/github_actions/github/codeql-action-4.32.5 GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=pocl/pocl GITHUB_REPOSITORY_OWNER=pocl GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=f2f1912d145d88e36bca00eee0f3c8f35a209e35 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Linux / CPU x86-64 on GH tests' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CCACHE_BASEDIR=${GITHUB_WORKSPACE} CCACHE_DIR=${GITHUB_WORKSPACE}/../../../../ccache_storage EXAMPLES_DIR=${GITHUB_WORKSPACE}/../../../../examples "${CURRENT_ENV[@]}" POCL_CACHE_DIR=/tmp/GH_POCL_CACHE CL_PLATFORM_NAME=Portable CL_DEVICE_TYPE=cpu \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run 'rm -rf '/tmp/GH_POCL_CACHE
echo "##[endgroup]"
echo 'rm -rf '/tmp/GH_POCL_CACHE'
mkdir '/tmp/GH_POCL_CACHE'
if [ "DBKs" == "install" ]; then
  # Do not use the run_cpu_tests script as we want to test the installation, not
  # the build dir.
  # the pocl_test_dlopen tests try to dlopen libraries from the build dir; however,
  # we removed that libpocl.so at the install step to ensure we test the installed libpocl
  cd '${GITHUB_WORKSPACE}'/build && ctest -j$(nproc) -E pocl_test_dlopen_ -LE cpu_fail $CTEST_FLAGS "$@"
else
  cd '${GITHUB_WORKSPACE}'/build && '${GITHUB_WORKSPACE}'/tools/scripts/run_cpu_tests -j$(nproc) $CTEST_FLAGS "$@"
fi
' > /home/github/65449972502/steps/bugswarm_12.sh
chmod u+x /home/github/65449972502/steps/bugswarm_12.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=12 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR='dependabot[bot]' GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=dependabot/github_actions/github/codeql-action-4.32.5 GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/dependabot/github_actions/github/codeql-action-4.32.5 GITHUB_REF_NAME=dependabot/github_actions/github/codeql-action-4.32.5 GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=pocl/pocl GITHUB_REPOSITORY_OWNER=pocl GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=f2f1912d145d88e36bca00eee0f3c8f35a209e35 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Linux / CPU x86-64 on GH tests' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CCACHE_BASEDIR=${GITHUB_WORKSPACE} CCACHE_DIR=${GITHUB_WORKSPACE}/../../../../ccache_storage EXAMPLES_DIR=${GITHUB_WORKSPACE}/../../../../examples "${CURRENT_ENV[@]}" POCL_CACHE_DIR=/tmp/GH_POCL_CACHE CL_PLATFORM_NAME=Portable CL_DEVICE_TYPE=cpu \
bash -e /home/github/65449972502/steps/bugswarm_12.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=12 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR='dependabot[bot]' GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=dependabot/github_actions/github/codeql-action-4.32.5 GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/dependabot/github_actions/github/codeql-action-4.32.5 GITHUB_REF_NAME=dependabot/github_actions/github/codeql-action-4.32.5 GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=pocl/pocl GITHUB_REPOSITORY_OWNER=pocl GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=f2f1912d145d88e36bca00eee0f3c8f35a209e35 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Linux / CPU x86-64 on GH tests' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CCACHE_BASEDIR=${GITHUB_WORKSPACE} CCACHE_DIR=${GITHUB_WORKSPACE}/../../../../ccache_storage EXAMPLES_DIR=${GITHUB_WORKSPACE}/../../../../examples "${CURRENT_ENV[@]}" POCL_CACHE_DIR=/tmp/GH_POCL_CACHE CL_PLATFORM_NAME=Portable CL_DEVICE_TYPE=cpu \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

  _CONTEXT_STEPS_CTEST_OUTCOME=failure
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    _CONTEXT_STEPS_CTEST_CONCLUSION=failure
  else
    _CONTEXT_STEPS_CTEST_CONCLUSION=success
  fi
else
  _CONTEXT_STEPS_CTEST_OUTCOME=success
  _CONTEXT_STEPS_CTEST_CONCLUSION=success
fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=12 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR='dependabot[bot]' GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=dependabot/github_actions/github/codeql-action-4.32.5 GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/dependabot/github_actions/github/codeql-action-4.32.5 GITHUB_REF_NAME=dependabot/github_actions/github/codeql-action-4.32.5 GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=pocl/pocl GITHUB_REPOSITORY_OWNER=pocl GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=f2f1912d145d88e36bca00eee0f3c8f35a209e35 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Linux / CPU x86-64 on GH tests' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CCACHE_BASEDIR=${GITHUB_WORKSPACE} CCACHE_DIR=${GITHUB_WORKSPACE}/../../../../ccache_storage EXAMPLES_DIR=${GITHUB_WORKSPACE}/../../../../examples "${CURRENT_ENV[@]}" POCL_CACHE_DIR=/tmp/GH_POCL_CACHE CL_PLATFORM_NAME=Portable CL_DEVICE_TYPE=cpu \
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
   bash -e $ACTIONS_RUNNER_HOOK_JOB_COMPLETED 65449972502 failed
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
