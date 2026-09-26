#!/usr/bin/env bash
export GITHUB_WORKSPACE=/home/github/build/cvxpy/cvxpy

if [[ ! -z "$ACTIONS_RUNNER_HOOK_JOB_STARTED" ]]; then
   echo "A job started hook has been configured by the self-hosted runner administrator"
   echo "##[group]Run '$ACTIONS_RUNNER_HOOK_JOB_STARTED'"
   echo "##[endgroup]"
   bash -e $ACTIONS_RUNNER_HOOK_JOB_STARTED 81340711434 failed
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

cp /home/github/81340711434/event.json /home/github/workflow/event.json
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=1 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=Transurgeon GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=diffengine-backend-ignoredpp GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/diffengine-backend-ignoredpp GITHUB_REF_NAME=diffengine-backend-ignoredpp GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=cvxpy/cvxpy GITHUB_REPOSITORY_OWNER=cvxpy GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=3805df2ce012c7a6d9a8956b2e30e7197d838672 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=build GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 RUNNER_OS=ubuntu-22.04 PYTHON_VERSION=3.11 SINGLE_ACTION_CONFIG="$(/home/github/81340711434/helpers/eval_expression p:'(' s:'' o:'&&' s:True p:')' o:'||' s:False)" USE_OPENMP="$(/home/github/81340711434/helpers/eval_expression p:'(' p:'(' s:'' o:== s:True p:')' o:'&&' s:True p:')' o:'||' s:False)" MOSEK_CI_BASE64= "${CURRENT_ENV[@]}" \
echo $(test "$_GITHUB_JOB_STATUS" = "success" && echo true || echo false))
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=1 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=Transurgeon GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=diffengine-backend-ignoredpp GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/diffengine-backend-ignoredpp GITHUB_REF_NAME=diffengine-backend-ignoredpp GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=cvxpy/cvxpy GITHUB_REPOSITORY_OWNER=cvxpy GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=3805df2ce012c7a6d9a8956b2e30e7197d838672 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=build GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 RUNNER_OS=ubuntu-22.04 PYTHON_VERSION=3.11 SINGLE_ACTION_CONFIG="$(/home/github/81340711434/helpers/eval_expression p:'(' s:'' o:'&&' s:True p:')' o:'||' s:False)" USE_OPENMP="$(/home/github/81340711434/helpers/eval_expression p:'(' p:'(' s:'' o:== s:True p:')' o:'&&' s:True p:')' o:'||' s:False)" MOSEK_CI_BASE64= "${CURRENT_ENV[@]}" \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run 'echo "PYTHON_SUBVERSION=$(echo $PYTHON_VERSION | cut -c 3-)" >> $GITHUB_ENV'
echo "##[endgroup]"
echo 'echo "PYTHON_SUBVERSION=$(echo $PYTHON_VERSION | cut -c 3-)" >> $GITHUB_ENV
echo $MOSEK_CI_BASE64 | base64 -d > mosek.lic
echo "MOSEKLM_LICENSE_FILE=$( [[ $RUNNER_OS == '"'"'macOS'"'"' ]] && echo $(pwd)/mosek.lic || echo $(realpath mosek.lic) )" >> $GITHUB_ENV
' > /home/github/81340711434/steps/bugswarm_1.script
chmod u+x /home/github/81340711434/steps/bugswarm_1.script


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=1 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=Transurgeon GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=diffengine-backend-ignoredpp GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/diffengine-backend-ignoredpp GITHUB_REF_NAME=diffengine-backend-ignoredpp GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=cvxpy/cvxpy GITHUB_REPOSITORY_OWNER=cvxpy GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=3805df2ce012c7a6d9a8956b2e30e7197d838672 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=build GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 RUNNER_OS=ubuntu-22.04 PYTHON_VERSION=3.11 SINGLE_ACTION_CONFIG="$(/home/github/81340711434/helpers/eval_expression p:'(' s:'' o:'&&' s:True p:')' o:'||' s:False)" USE_OPENMP="$(/home/github/81340711434/helpers/eval_expression p:'(' p:'(' s:'' o:== s:True p:')' o:'&&' s:True p:')' o:'||' s:False)" MOSEK_CI_BASE64= "${CURRENT_ENV[@]}" \
bash -l /home/github/81340711434/steps/bugswarm_1.script
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=1 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=Transurgeon GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=diffengine-backend-ignoredpp GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/diffengine-backend-ignoredpp GITHUB_REF_NAME=diffengine-backend-ignoredpp GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=cvxpy/cvxpy GITHUB_REPOSITORY_OWNER=cvxpy GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=3805df2ce012c7a6d9a8956b2e30e7197d838672 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=build GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 RUNNER_OS=ubuntu-22.04 PYTHON_VERSION=3.11 SINGLE_ACTION_CONFIG="$(/home/github/81340711434/helpers/eval_expression p:'(' s:'' o:'&&' s:True p:')' o:'||' s:False)" USE_OPENMP="$(/home/github/81340711434/helpers/eval_expression p:'(' p:'(' s:'' o:== s:True p:')' o:'&&' s:True p:')' o:'||' s:False)" MOSEK_CI_BASE64= "${CURRENT_ENV[@]}" \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=1 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=Transurgeon GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=diffengine-backend-ignoredpp GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/diffengine-backend-ignoredpp GITHUB_REF_NAME=diffengine-backend-ignoredpp GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=cvxpy/cvxpy GITHUB_REPOSITORY_OWNER=cvxpy GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=3805df2ce012c7a6d9a8956b2e30e7197d838672 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=build GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 RUNNER_OS=ubuntu-22.04 PYTHON_VERSION=3.11 SINGLE_ACTION_CONFIG="$(/home/github/81340711434/helpers/eval_expression p:'(' s:'' o:'&&' s:True p:')' o:'||' s:False)" USE_OPENMP="$(/home/github/81340711434/helpers/eval_expression p:'(' p:'(' s:'' o:== s:True p:')' o:'&&' s:True p:')' o:'||' s:False)" MOSEK_CI_BASE64= "${CURRENT_ENV[@]}" \
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=2 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=astral-sh/setup-uv GITHUB_ACTIONS=true GITHUB_ACTOR=Transurgeon GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=diffengine-backend-ignoredpp GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/diffengine-backend-ignoredpp GITHUB_REF_NAME=diffengine-backend-ignoredpp GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=cvxpy/cvxpy GITHUB_REPOSITORY_OWNER=cvxpy GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=3805df2ce012c7a6d9a8956b2e30e7197d838672 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=build GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 GITHUB_ACTION_PATH=/home/github/81340711434/actions/astral-sh-setup-uv@v7 RUNNER_OS=ubuntu-22.04 PYTHON_VERSION=3.11 SINGLE_ACTION_CONFIG="$(/home/github/81340711434/helpers/eval_expression p:'(' s:'' o:'&&' s:True p:')' o:'||' s:False)" USE_OPENMP="$(/home/github/81340711434/helpers/eval_expression p:'(' p:'(' s:'' o:== s:True p:')' o:'&&' s:True p:')' o:'||' s:False)" MOSEK_CI_BASE64= "${CURRENT_ENV[@]}" INPUT_PYTHON-VERSION=3.11 INPUT_ENABLE-CACHE=true INPUT_VERSION= INPUT_VERSION-FILE= INPUT_ACTIVATE-ENVIRONMENT=false INPUT_VENV-PATH= INPUT_WORKING-DIRECTORY=${GITHUB_WORKSPACE} INPUT_GITHUB-TOKEN=DUMMY INPUT_CACHE-DEPENDENCY-GLOB='**/*requirements*.txt
**/*requirements*.in
**/*constraints*.txt
**/*constraints*.in
**/pyproject.toml
**/uv.lock
**/*.py.lock
' INPUT_RESTORE-CACHE=true INPUT_SAVE-CACHE=true INPUT_CACHE-LOCAL-PATH= INPUT_PRUNE-CACHE=true INPUT_CACHE-PYTHON=false INPUT_IGNORE-NOTHING-TO-CACHE=false INPUT_IGNORE-EMPTY-WORKDIR=false INPUT_ADD-PROBLEM-MATCHERS=true INPUT_RESOLUTION-STRATEGY=highest \
echo $(test "$_GITHUB_JOB_STATUS" = "success" && echo true || echo false))
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=2 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=astral-sh/setup-uv GITHUB_ACTIONS=true GITHUB_ACTOR=Transurgeon GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=diffengine-backend-ignoredpp GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/diffengine-backend-ignoredpp GITHUB_REF_NAME=diffengine-backend-ignoredpp GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=cvxpy/cvxpy GITHUB_REPOSITORY_OWNER=cvxpy GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=3805df2ce012c7a6d9a8956b2e30e7197d838672 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=build GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 GITHUB_ACTION_PATH=/home/github/81340711434/actions/astral-sh-setup-uv@v7 RUNNER_OS=ubuntu-22.04 PYTHON_VERSION=3.11 SINGLE_ACTION_CONFIG="$(/home/github/81340711434/helpers/eval_expression p:'(' s:'' o:'&&' s:True p:')' o:'||' s:False)" USE_OPENMP="$(/home/github/81340711434/helpers/eval_expression p:'(' p:'(' s:'' o:== s:True p:')' o:'&&' s:True p:')' o:'||' s:False)" MOSEK_CI_BASE64= "${CURRENT_ENV[@]}" INPUT_PYTHON-VERSION=3.11 INPUT_ENABLE-CACHE=true INPUT_VERSION= INPUT_VERSION-FILE= INPUT_ACTIVATE-ENVIRONMENT=false INPUT_VENV-PATH= INPUT_WORKING-DIRECTORY=${GITHUB_WORKSPACE} INPUT_GITHUB-TOKEN=DUMMY INPUT_CACHE-DEPENDENCY-GLOB='**/*requirements*.txt
**/*requirements*.in
**/*constraints*.txt
**/*constraints*.in
**/pyproject.toml
**/uv.lock
**/*.py.lock
' INPUT_RESTORE-CACHE=true INPUT_SAVE-CACHE=true INPUT_CACHE-LOCAL-PATH= INPUT_PRUNE-CACHE=true INPUT_CACHE-PYTHON=false INPUT_IGNORE-NOTHING-TO-CACHE=false INPUT_IGNORE-EMPTY-WORKDIR=false INPUT_ADD-PROBLEM-MATCHERS=true INPUT_RESOLUTION-STRATEGY=highest \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run astral-sh/setup-uv@v7
echo "##[endgroup]"
echo node /home/github/81340711434/actions/astral-sh-setup-uv@v7/dist/setup/index.cjs > /home/github/81340711434/steps/bugswarm_cmd.sh
chmod u+x /home/github/81340711434/steps/bugswarm_cmd.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=2 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=astral-sh/setup-uv GITHUB_ACTIONS=true GITHUB_ACTOR=Transurgeon GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=diffengine-backend-ignoredpp GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/diffengine-backend-ignoredpp GITHUB_REF_NAME=diffengine-backend-ignoredpp GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=cvxpy/cvxpy GITHUB_REPOSITORY_OWNER=cvxpy GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=3805df2ce012c7a6d9a8956b2e30e7197d838672 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=build GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 GITHUB_ACTION_PATH=/home/github/81340711434/actions/astral-sh-setup-uv@v7 RUNNER_OS=ubuntu-22.04 PYTHON_VERSION=3.11 SINGLE_ACTION_CONFIG="$(/home/github/81340711434/helpers/eval_expression p:'(' s:'' o:'&&' s:True p:')' o:'||' s:False)" USE_OPENMP="$(/home/github/81340711434/helpers/eval_expression p:'(' p:'(' s:'' o:== s:True p:')' o:'&&' s:True p:')' o:'||' s:False)" MOSEK_CI_BASE64= "${CURRENT_ENV[@]}" INPUT_PYTHON-VERSION=3.11 INPUT_ENABLE-CACHE=true INPUT_VERSION= INPUT_VERSION-FILE= INPUT_ACTIVATE-ENVIRONMENT=false INPUT_VENV-PATH= INPUT_WORKING-DIRECTORY=${GITHUB_WORKSPACE} INPUT_GITHUB-TOKEN=DUMMY INPUT_CACHE-DEPENDENCY-GLOB='**/*requirements*.txt
**/*requirements*.in
**/*constraints*.txt
**/*constraints*.in
**/pyproject.toml
**/uv.lock
**/*.py.lock
' INPUT_RESTORE-CACHE=true INPUT_SAVE-CACHE=true INPUT_CACHE-LOCAL-PATH= INPUT_PRUNE-CACHE=true INPUT_CACHE-PYTHON=false INPUT_IGNORE-NOTHING-TO-CACHE=false INPUT_IGNORE-EMPTY-WORKDIR=false INPUT_ADD-PROBLEM-MATCHERS=true INPUT_RESOLUTION-STRATEGY=highest \
bash -e /home/github/81340711434/steps/bugswarm_cmd.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=2 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=astral-sh/setup-uv GITHUB_ACTIONS=true GITHUB_ACTOR=Transurgeon GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=diffengine-backend-ignoredpp GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/diffengine-backend-ignoredpp GITHUB_REF_NAME=diffengine-backend-ignoredpp GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=cvxpy/cvxpy GITHUB_REPOSITORY_OWNER=cvxpy GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=3805df2ce012c7a6d9a8956b2e30e7197d838672 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=build GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 GITHUB_ACTION_PATH=/home/github/81340711434/actions/astral-sh-setup-uv@v7 RUNNER_OS=ubuntu-22.04 PYTHON_VERSION=3.11 SINGLE_ACTION_CONFIG="$(/home/github/81340711434/helpers/eval_expression p:'(' s:'' o:'&&' s:True p:')' o:'||' s:False)" USE_OPENMP="$(/home/github/81340711434/helpers/eval_expression p:'(' p:'(' s:'' o:== s:True p:')' o:'&&' s:True p:')' o:'||' s:False)" MOSEK_CI_BASE64= "${CURRENT_ENV[@]}" INPUT_PYTHON-VERSION=3.11 INPUT_ENABLE-CACHE=true INPUT_VERSION= INPUT_VERSION-FILE= INPUT_ACTIVATE-ENVIRONMENT=false INPUT_VENV-PATH= INPUT_WORKING-DIRECTORY=${GITHUB_WORKSPACE} INPUT_GITHUB-TOKEN=DUMMY INPUT_CACHE-DEPENDENCY-GLOB='**/*requirements*.txt
**/*requirements*.in
**/*constraints*.txt
**/*constraints*.in
**/pyproject.toml
**/uv.lock
**/*.py.lock
' INPUT_RESTORE-CACHE=true INPUT_SAVE-CACHE=true INPUT_CACHE-LOCAL-PATH= INPUT_PRUNE-CACHE=true INPUT_CACHE-PYTHON=false INPUT_IGNORE-NOTHING-TO-CACHE=false INPUT_IGNORE-EMPTY-WORKDIR=false INPUT_ADD-PROBLEM-MATCHERS=true INPUT_RESOLUTION-STRATEGY=highest \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=2 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=astral-sh/setup-uv GITHUB_ACTIONS=true GITHUB_ACTOR=Transurgeon GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=diffengine-backend-ignoredpp GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/diffengine-backend-ignoredpp GITHUB_REF_NAME=diffengine-backend-ignoredpp GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=cvxpy/cvxpy GITHUB_REPOSITORY_OWNER=cvxpy GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=3805df2ce012c7a6d9a8956b2e30e7197d838672 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=build GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 GITHUB_ACTION_PATH=/home/github/81340711434/actions/astral-sh-setup-uv@v7 RUNNER_OS=ubuntu-22.04 PYTHON_VERSION=3.11 SINGLE_ACTION_CONFIG="$(/home/github/81340711434/helpers/eval_expression p:'(' s:'' o:'&&' s:True p:')' o:'||' s:False)" USE_OPENMP="$(/home/github/81340711434/helpers/eval_expression p:'(' p:'(' s:'' o:== s:True p:')' o:'&&' s:True p:')' o:'||' s:False)" MOSEK_CI_BASE64= "${CURRENT_ENV[@]}" INPUT_PYTHON-VERSION=3.11 INPUT_ENABLE-CACHE=true INPUT_VERSION= INPUT_VERSION-FILE= INPUT_ACTIVATE-ENVIRONMENT=false INPUT_VENV-PATH= INPUT_WORKING-DIRECTORY=${GITHUB_WORKSPACE} INPUT_GITHUB-TOKEN=DUMMY INPUT_CACHE-DEPENDENCY-GLOB='**/*requirements*.txt
**/*requirements*.in
**/*constraints*.txt
**/*constraints*.in
**/pyproject.toml
**/uv.lock
**/*.py.lock
' INPUT_RESTORE-CACHE=true INPUT_SAVE-CACHE=true INPUT_CACHE-LOCAL-PATH= INPUT_PRUNE-CACHE=true INPUT_CACHE-PYTHON=false INPUT_IGNORE-NOTHING-TO-CACHE=false INPUT_IGNORE-EMPTY-WORKDIR=false INPUT_ADD-PROBLEM-MATCHERS=true INPUT_RESOLUTION-STRATEGY=highest \
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=3 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=Transurgeon GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=diffengine-backend-ignoredpp GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/diffengine-backend-ignoredpp GITHUB_REF_NAME=diffengine-backend-ignoredpp GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=cvxpy/cvxpy GITHUB_REPOSITORY_OWNER=cvxpy GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=3805df2ce012c7a6d9a8956b2e30e7197d838672 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=build GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 RUNNER_OS=ubuntu-22.04 PYTHON_VERSION=3.11 SINGLE_ACTION_CONFIG="$(/home/github/81340711434/helpers/eval_expression p:'(' s:'' o:'&&' s:True p:')' o:'||' s:False)" USE_OPENMP="$(/home/github/81340711434/helpers/eval_expression p:'(' p:'(' s:'' o:== s:True p:')' o:'&&' s:True p:')' o:'||' s:False)" MOSEK_CI_BASE64= "${CURRENT_ENV[@]}" \
echo $(test "$_GITHUB_JOB_STATUS" = "success" && echo true || echo false))
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=3 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=Transurgeon GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=diffengine-backend-ignoredpp GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/diffengine-backend-ignoredpp GITHUB_REF_NAME=diffengine-backend-ignoredpp GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=cvxpy/cvxpy GITHUB_REPOSITORY_OWNER=cvxpy GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=3805df2ce012c7a6d9a8956b2e30e7197d838672 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=build GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 RUNNER_OS=ubuntu-22.04 PYTHON_VERSION=3.11 SINGLE_ACTION_CONFIG="$(/home/github/81340711434/helpers/eval_expression p:'(' s:'' o:'&&' s:True p:')' o:'||' s:False)" USE_OPENMP="$(/home/github/81340711434/helpers/eval_expression p:'(' p:'(' s:'' o:== s:True p:')' o:'&&' s:True p:')' o:'||' s:False)" MOSEK_CI_BASE64= "${CURRENT_ENV[@]}" \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run 'source continuous_integration/install_dependencies.sh'
echo "##[endgroup]"
echo 'source continuous_integration/install_dependencies.sh
' > /home/github/81340711434/steps/bugswarm_3.script
chmod u+x /home/github/81340711434/steps/bugswarm_3.script


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=3 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=Transurgeon GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=diffengine-backend-ignoredpp GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/diffengine-backend-ignoredpp GITHUB_REF_NAME=diffengine-backend-ignoredpp GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=cvxpy/cvxpy GITHUB_REPOSITORY_OWNER=cvxpy GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=3805df2ce012c7a6d9a8956b2e30e7197d838672 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=build GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 RUNNER_OS=ubuntu-22.04 PYTHON_VERSION=3.11 SINGLE_ACTION_CONFIG="$(/home/github/81340711434/helpers/eval_expression p:'(' s:'' o:'&&' s:True p:')' o:'||' s:False)" USE_OPENMP="$(/home/github/81340711434/helpers/eval_expression p:'(' p:'(' s:'' o:== s:True p:')' o:'&&' s:True p:')' o:'||' s:False)" MOSEK_CI_BASE64= "${CURRENT_ENV[@]}" \
bash -l /home/github/81340711434/steps/bugswarm_3.script
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=3 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=Transurgeon GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=diffengine-backend-ignoredpp GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/diffengine-backend-ignoredpp GITHUB_REF_NAME=diffengine-backend-ignoredpp GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=cvxpy/cvxpy GITHUB_REPOSITORY_OWNER=cvxpy GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=3805df2ce012c7a6d9a8956b2e30e7197d838672 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=build GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 RUNNER_OS=ubuntu-22.04 PYTHON_VERSION=3.11 SINGLE_ACTION_CONFIG="$(/home/github/81340711434/helpers/eval_expression p:'(' s:'' o:'&&' s:True p:')' o:'||' s:False)" USE_OPENMP="$(/home/github/81340711434/helpers/eval_expression p:'(' p:'(' s:'' o:== s:True p:')' o:'&&' s:True p:')' o:'||' s:False)" MOSEK_CI_BASE64= "${CURRENT_ENV[@]}" \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=3 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=Transurgeon GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=diffengine-backend-ignoredpp GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/diffengine-backend-ignoredpp GITHUB_REF_NAME=diffengine-backend-ignoredpp GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=cvxpy/cvxpy GITHUB_REPOSITORY_OWNER=cvxpy GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=3805df2ce012c7a6d9a8956b2e30e7197d838672 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=build GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 RUNNER_OS=ubuntu-22.04 PYTHON_VERSION=3.11 SINGLE_ACTION_CONFIG="$(/home/github/81340711434/helpers/eval_expression p:'(' s:'' o:'&&' s:True p:')' o:'||' s:False)" USE_OPENMP="$(/home/github/81340711434/helpers/eval_expression p:'(' p:'(' s:'' o:== s:True p:')' o:'&&' s:True p:')' o:'||' s:False)" MOSEK_CI_BASE64= "${CURRENT_ENV[@]}" \
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=4 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=Transurgeon GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=diffengine-backend-ignoredpp GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/diffengine-backend-ignoredpp GITHUB_REF_NAME=diffengine-backend-ignoredpp GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=cvxpy/cvxpy GITHUB_REPOSITORY_OWNER=cvxpy GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=3805df2ce012c7a6d9a8956b2e30e7197d838672 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=build GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 RUNNER_OS=ubuntu-22.04 PYTHON_VERSION=3.11 SINGLE_ACTION_CONFIG="$(/home/github/81340711434/helpers/eval_expression p:'(' s:'' o:'&&' s:True p:')' o:'||' s:False)" USE_OPENMP="$(/home/github/81340711434/helpers/eval_expression p:'(' p:'(' s:'' o:== s:True p:')' o:'&&' s:True p:')' o:'||' s:False)" MOSEK_CI_BASE64= "${CURRENT_ENV[@]}" \
echo $(test "$_GITHUB_JOB_STATUS" = "success" && echo true || echo false))
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=4 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=Transurgeon GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=diffengine-backend-ignoredpp GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/diffengine-backend-ignoredpp GITHUB_REF_NAME=diffengine-backend-ignoredpp GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=cvxpy/cvxpy GITHUB_REPOSITORY_OWNER=cvxpy GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=3805df2ce012c7a6d9a8956b2e30e7197d838672 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=build GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 RUNNER_OS=ubuntu-22.04 PYTHON_VERSION=3.11 SINGLE_ACTION_CONFIG="$(/home/github/81340711434/helpers/eval_expression p:'(' s:'' o:'&&' s:True p:')' o:'||' s:False)" USE_OPENMP="$(/home/github/81340711434/helpers/eval_expression p:'(' p:'(' s:'' o:== s:True p:')' o:'&&' s:True p:')' o:'||' s:False)" MOSEK_CI_BASE64= "${CURRENT_ENV[@]}" \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run 'source continuous_integration/test_script.sh'
echo "##[endgroup]"
echo 'source continuous_integration/test_script.sh
' > /home/github/81340711434/steps/bugswarm_4.script
chmod u+x /home/github/81340711434/steps/bugswarm_4.script


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=4 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=Transurgeon GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=diffengine-backend-ignoredpp GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/diffengine-backend-ignoredpp GITHUB_REF_NAME=diffengine-backend-ignoredpp GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=cvxpy/cvxpy GITHUB_REPOSITORY_OWNER=cvxpy GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=3805df2ce012c7a6d9a8956b2e30e7197d838672 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=build GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 RUNNER_OS=ubuntu-22.04 PYTHON_VERSION=3.11 SINGLE_ACTION_CONFIG="$(/home/github/81340711434/helpers/eval_expression p:'(' s:'' o:'&&' s:True p:')' o:'||' s:False)" USE_OPENMP="$(/home/github/81340711434/helpers/eval_expression p:'(' p:'(' s:'' o:== s:True p:')' o:'&&' s:True p:')' o:'||' s:False)" MOSEK_CI_BASE64= "${CURRENT_ENV[@]}" \
bash -l /home/github/81340711434/steps/bugswarm_4.script
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=4 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=Transurgeon GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=diffengine-backend-ignoredpp GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/diffengine-backend-ignoredpp GITHUB_REF_NAME=diffengine-backend-ignoredpp GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=cvxpy/cvxpy GITHUB_REPOSITORY_OWNER=cvxpy GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=3805df2ce012c7a6d9a8956b2e30e7197d838672 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=build GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 RUNNER_OS=ubuntu-22.04 PYTHON_VERSION=3.11 SINGLE_ACTION_CONFIG="$(/home/github/81340711434/helpers/eval_expression p:'(' s:'' o:'&&' s:True p:')' o:'||' s:False)" USE_OPENMP="$(/home/github/81340711434/helpers/eval_expression p:'(' p:'(' s:'' o:== s:True p:')' o:'&&' s:True p:')' o:'||' s:False)" MOSEK_CI_BASE64= "${CURRENT_ENV[@]}" \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=4 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=Transurgeon GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=diffengine-backend-ignoredpp GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/diffengine-backend-ignoredpp GITHUB_REF_NAME=diffengine-backend-ignoredpp GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=cvxpy/cvxpy GITHUB_REPOSITORY_OWNER=cvxpy GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=3805df2ce012c7a6d9a8956b2e30e7197d838672 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=build GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 RUNNER_OS=ubuntu-22.04 PYTHON_VERSION=3.11 SINGLE_ACTION_CONFIG="$(/home/github/81340711434/helpers/eval_expression p:'(' s:'' o:'&&' s:True p:')' o:'||' s:False)" USE_OPENMP="$(/home/github/81340711434/helpers/eval_expression p:'(' p:'(' s:'' o:== s:True p:')' o:'&&' s:True p:')' o:'||' s:False)" MOSEK_CI_BASE64= "${CURRENT_ENV[@]}" \
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
   bash -e $ACTIONS_RUNNER_HOOK_JOB_COMPLETED 81340711434 failed
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
