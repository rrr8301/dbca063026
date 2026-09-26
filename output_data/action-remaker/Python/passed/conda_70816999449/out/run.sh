#!/usr/bin/env bash
export GITHUB_WORKSPACE=/home/github/build/conda/conda

if [[ ! -z "$ACTIONS_RUNNER_HOOK_JOB_STARTED" ]]; then
   echo "A job started hook has been configured by the self-hosted runner administrator"
   echo "##[group]Run '$ACTIONS_RUNNER_HOOK_JOB_STARTED'"
   echo "##[endgroup]"
   bash -e $ACTIONS_RUNNER_HOOK_JOB_STARTED 70816999449 passed
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

cp /home/github/70816999449/event.json /home/github/workflow/event.json
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=1 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=kenodegard GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/26.3.x GITHUB_REF_NAME=26.3.x GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=conda/conda GITHUB_REPOSITORY_OWNER=conda GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=ef0833c6af84c17d6e6962284863521ba02b11de GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Tests GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CONDA_LIBMAMBA_SOLVER_NO_CHANNELS_FROM_INSTALLED=true PYTEST_MARKER="$(/home/github/70816999449/helpers/eval_expression p:'(' p:'(' s:integration o:== s:unit p:')' o:'&&' s:'not integration' p:')' o:'||' s:integration)" PYTEST_SPLITS="$(/home/github/70816999449/helpers/eval_expression p:'(' p:'(' s:integration o:== s:unit p:')' o:'&&' s:2 p:')' o:'||' s:3)" CONDA_TEST_SOLVERS="$(/home/github/70816999449/helpers/eval_expression p:'(' p:'(' s:push o:== s:pull_request p:')' o:'&&' p:'(' p:'(' s:3.12 o:'!=' s:3.14 p:')' o:'||' p:'(' s:defaults o:== s:conda-forge p:')' p:')' o:'&&' s:libmamba p:')' o:'||' s:libmamba,classic)" "${CURRENT_ENV[@]}" \
echo $(test "$_GITHUB_JOB_STATUS" = "success" && echo true || echo false))
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=1 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=kenodegard GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/26.3.x GITHUB_REF_NAME=26.3.x GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=conda/conda GITHUB_REPOSITORY_OWNER=conda GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=ef0833c6af84c17d6e6962284863521ba02b11de GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Tests GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CONDA_LIBMAMBA_SOLVER_NO_CHANNELS_FROM_INSTALLED=true PYTEST_MARKER="$(/home/github/70816999449/helpers/eval_expression p:'(' p:'(' s:integration o:== s:unit p:')' o:'&&' s:'not integration' p:')' o:'||' s:integration)" PYTEST_SPLITS="$(/home/github/70816999449/helpers/eval_expression p:'(' p:'(' s:integration o:== s:unit p:')' o:'&&' s:2 p:')' o:'||' s:3)" CONDA_TEST_SOLVERS="$(/home/github/70816999449/helpers/eval_expression p:'(' p:'(' s:push o:== s:pull_request p:')' o:'&&' p:'(' p:'(' s:3.12 o:'!=' s:3.14 p:')' o:'||' p:'(' s:defaults o:== s:conda-forge p:')' p:')' o:'&&' s:libmamba p:')' o:'||' s:libmamba,classic)" "${CURRENT_ENV[@]}" \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run 'STEM="Linux-X64-Py3.12-defaults-$(date -u "+%Y%m")"'
echo "##[endgroup]"
echo 'STEM="Linux-X64-Py3.12-defaults-$(date -u "+%Y%m")"
echo "CACHE_KEY=${STEM}" >> $GITHUB_ENV
echo "HASH=${STEM}-integration-3" >> $GITHUB_ENV
' > /home/github/70816999449/steps/bugswarm_1.script
chmod u+x /home/github/70816999449/steps/bugswarm_1.script


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=1 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=kenodegard GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/26.3.x GITHUB_REF_NAME=26.3.x GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=conda/conda GITHUB_REPOSITORY_OWNER=conda GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=ef0833c6af84c17d6e6962284863521ba02b11de GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Tests GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CONDA_LIBMAMBA_SOLVER_NO_CHANNELS_FROM_INSTALLED=true PYTEST_MARKER="$(/home/github/70816999449/helpers/eval_expression p:'(' p:'(' s:integration o:== s:unit p:')' o:'&&' s:'not integration' p:')' o:'||' s:integration)" PYTEST_SPLITS="$(/home/github/70816999449/helpers/eval_expression p:'(' p:'(' s:integration o:== s:unit p:')' o:'&&' s:2 p:')' o:'||' s:3)" CONDA_TEST_SOLVERS="$(/home/github/70816999449/helpers/eval_expression p:'(' p:'(' s:push o:== s:pull_request p:')' o:'&&' p:'(' p:'(' s:3.12 o:'!=' s:3.14 p:')' o:'||' p:'(' s:defaults o:== s:conda-forge p:')' p:')' o:'&&' s:libmamba p:')' o:'||' s:libmamba,classic)" "${CURRENT_ENV[@]}" \
bash -el /home/github/70816999449/steps/bugswarm_1.script
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=1 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=kenodegard GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/26.3.x GITHUB_REF_NAME=26.3.x GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=conda/conda GITHUB_REPOSITORY_OWNER=conda GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=ef0833c6af84c17d6e6962284863521ba02b11de GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Tests GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CONDA_LIBMAMBA_SOLVER_NO_CHANNELS_FROM_INSTALLED=true PYTEST_MARKER="$(/home/github/70816999449/helpers/eval_expression p:'(' p:'(' s:integration o:== s:unit p:')' o:'&&' s:'not integration' p:')' o:'||' s:integration)" PYTEST_SPLITS="$(/home/github/70816999449/helpers/eval_expression p:'(' p:'(' s:integration o:== s:unit p:')' o:'&&' s:2 p:')' o:'||' s:3)" CONDA_TEST_SOLVERS="$(/home/github/70816999449/helpers/eval_expression p:'(' p:'(' s:push o:== s:pull_request p:')' o:'&&' p:'(' p:'(' s:3.12 o:'!=' s:3.14 p:')' o:'||' p:'(' s:defaults o:== s:conda-forge p:')' p:')' o:'&&' s:libmamba p:')' o:'||' s:libmamba,classic)" "${CURRENT_ENV[@]}" \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=1 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=kenodegard GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/26.3.x GITHUB_REF_NAME=26.3.x GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=conda/conda GITHUB_REPOSITORY_OWNER=conda GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=ef0833c6af84c17d6e6962284863521ba02b11de GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Tests GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CONDA_LIBMAMBA_SOLVER_NO_CHANNELS_FROM_INSTALLED=true PYTEST_MARKER="$(/home/github/70816999449/helpers/eval_expression p:'(' p:'(' s:integration o:== s:unit p:')' o:'&&' s:'not integration' p:')' o:'||' s:integration)" PYTEST_SPLITS="$(/home/github/70816999449/helpers/eval_expression p:'(' p:'(' s:integration o:== s:unit p:')' o:'&&' s:2 p:')' o:'||' s:3)" CONDA_TEST_SOLVERS="$(/home/github/70816999449/helpers/eval_expression p:'(' p:'(' s:push o:== s:pull_request p:')' o:'&&' p:'(' p:'(' s:3.12 o:'!=' s:3.14 p:')' o:'||' p:'(' s:defaults o:== s:conda-forge p:')' p:')' o:'&&' s:libmamba p:')' o:'||' s:libmamba,classic)" "${CURRENT_ENV[@]}" \
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=3 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=conda-incubator/setup-miniconda GITHUB_ACTIONS=true GITHUB_ACTOR=kenodegard GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/26.3.x GITHUB_REF_NAME=26.3.x GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=conda/conda GITHUB_REPOSITORY_OWNER=conda GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=ef0833c6af84c17d6e6962284863521ba02b11de GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Tests GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CONDA_LIBMAMBA_SOLVER_NO_CHANNELS_FROM_INSTALLED=true GITHUB_ACTION_PATH=/home/github/70816999449/actions/conda-incubator-setup-miniconda@fc2d68f6413eb2d87b895e92f8584b5b94a10167 PYTEST_MARKER="$(/home/github/70816999449/helpers/eval_expression p:'(' p:'(' s:integration o:== s:unit p:')' o:'&&' s:'not integration' p:')' o:'||' s:integration)" PYTEST_SPLITS="$(/home/github/70816999449/helpers/eval_expression p:'(' p:'(' s:integration o:== s:unit p:')' o:'&&' s:2 p:')' o:'||' s:3)" CONDA_TEST_SOLVERS="$(/home/github/70816999449/helpers/eval_expression p:'(' p:'(' s:push o:== s:pull_request p:')' o:'&&' p:'(' p:'(' s:3.12 o:'!=' s:3.14 p:')' o:'||' p:'(' s:defaults o:== s:conda-forge p:')' p:')' o:'&&' s:libmamba p:')' o:'||' s:libmamba,classic)" "${CURRENT_ENV[@]}" INPUT_CONDARC-FILE=.github/condarc-defaults INPUT_RUN-POST=false INPUT_MINICONDA-VERSION="$(/home/github/70816999449/helpers/eval_expression p:'(' p:'(' s:defaults o:== s:defaults p:')' o:'&&' s:latest p:')' o:'||' l:'')" INPUT_MINIFORGE-VERSION="$(/home/github/70816999449/helpers/eval_expression p:'(' p:'(' s:defaults o:== s:conda-forge p:')' o:'&&' s:latest p:')' o:'||' l:'')" INPUT_INSTALLER-URL= INPUT_INSTALLATION-DIR= INPUT_MINIFORGE-VARIANT= INPUT_CONDA-VERSION= INPUT_CONDA-BUILD-VERSION= INPUT_ENVIRONMENT-FILE= INPUT_ACTIVATE-ENVIRONMENT=test INPUT_PYTHON-VERSION= INPUT_ADD-ANACONDA-TOKEN= INPUT_ADD-PIP-AS-PYTHON-DEPENDENCY= INPUT_ALLOW-SOFTLINKS= INPUT_AUTO-ACTIVATE=true INPUT_AUTO-ACTIVATE-BASE=legacy-placeholder INPUT_AUTO-UPDATE-CONDA=false INPUT_CHANNEL-ALIAS= INPUT_CHANNEL-PRIORITY= INPUT_CHANNELS= INPUT_CONDA-REMOVE-DEFAULTS= INPUT_SHOW-CHANNEL-URLS= INPUT_PKGS-DIRS= INPUT_USE-ONLY-TAR-BZ2= INPUT_REMOVE-PROFILES=true INPUT_MAMBA-VERSION= INPUT_USE-MAMBA= INPUT_CONDA-SOLVER=libmamba INPUT_ARCHITECTURE= INPUT_CLEAN-PATCHED-ENVIRONMENT-FILE=true \
echo $(test "$_GITHUB_JOB_STATUS" = "success" && echo true || echo false))
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=3 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=conda-incubator/setup-miniconda GITHUB_ACTIONS=true GITHUB_ACTOR=kenodegard GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/26.3.x GITHUB_REF_NAME=26.3.x GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=conda/conda GITHUB_REPOSITORY_OWNER=conda GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=ef0833c6af84c17d6e6962284863521ba02b11de GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Tests GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CONDA_LIBMAMBA_SOLVER_NO_CHANNELS_FROM_INSTALLED=true GITHUB_ACTION_PATH=/home/github/70816999449/actions/conda-incubator-setup-miniconda@fc2d68f6413eb2d87b895e92f8584b5b94a10167 PYTEST_MARKER="$(/home/github/70816999449/helpers/eval_expression p:'(' p:'(' s:integration o:== s:unit p:')' o:'&&' s:'not integration' p:')' o:'||' s:integration)" PYTEST_SPLITS="$(/home/github/70816999449/helpers/eval_expression p:'(' p:'(' s:integration o:== s:unit p:')' o:'&&' s:2 p:')' o:'||' s:3)" CONDA_TEST_SOLVERS="$(/home/github/70816999449/helpers/eval_expression p:'(' p:'(' s:push o:== s:pull_request p:')' o:'&&' p:'(' p:'(' s:3.12 o:'!=' s:3.14 p:')' o:'||' p:'(' s:defaults o:== s:conda-forge p:')' p:')' o:'&&' s:libmamba p:')' o:'||' s:libmamba,classic)" "${CURRENT_ENV[@]}" INPUT_CONDARC-FILE=.github/condarc-defaults INPUT_RUN-POST=false INPUT_MINICONDA-VERSION="$(/home/github/70816999449/helpers/eval_expression p:'(' p:'(' s:defaults o:== s:defaults p:')' o:'&&' s:latest p:')' o:'||' l:'')" INPUT_MINIFORGE-VERSION="$(/home/github/70816999449/helpers/eval_expression p:'(' p:'(' s:defaults o:== s:conda-forge p:')' o:'&&' s:latest p:')' o:'||' l:'')" INPUT_INSTALLER-URL= INPUT_INSTALLATION-DIR= INPUT_MINIFORGE-VARIANT= INPUT_CONDA-VERSION= INPUT_CONDA-BUILD-VERSION= INPUT_ENVIRONMENT-FILE= INPUT_ACTIVATE-ENVIRONMENT=test INPUT_PYTHON-VERSION= INPUT_ADD-ANACONDA-TOKEN= INPUT_ADD-PIP-AS-PYTHON-DEPENDENCY= INPUT_ALLOW-SOFTLINKS= INPUT_AUTO-ACTIVATE=true INPUT_AUTO-ACTIVATE-BASE=legacy-placeholder INPUT_AUTO-UPDATE-CONDA=false INPUT_CHANNEL-ALIAS= INPUT_CHANNEL-PRIORITY= INPUT_CHANNELS= INPUT_CONDA-REMOVE-DEFAULTS= INPUT_SHOW-CHANNEL-URLS= INPUT_PKGS-DIRS= INPUT_USE-ONLY-TAR-BZ2= INPUT_REMOVE-PROFILES=true INPUT_MAMBA-VERSION= INPUT_USE-MAMBA= INPUT_CONDA-SOLVER=libmamba INPUT_ARCHITECTURE= INPUT_CLEAN-PATCHED-ENVIRONMENT-FILE=true \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run conda-incubator/setup-miniconda@fc2d68f6413eb2d87b895e92f8584b5b94a10167
echo "##[endgroup]"
echo node /home/github/70816999449/actions/conda-incubator-setup-miniconda@fc2d68f6413eb2d87b895e92f8584b5b94a10167/dist/setup/index.js > /home/github/70816999449/steps/bugswarm_cmd.sh
chmod u+x /home/github/70816999449/steps/bugswarm_cmd.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=3 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=conda-incubator/setup-miniconda GITHUB_ACTIONS=true GITHUB_ACTOR=kenodegard GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/26.3.x GITHUB_REF_NAME=26.3.x GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=conda/conda GITHUB_REPOSITORY_OWNER=conda GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=ef0833c6af84c17d6e6962284863521ba02b11de GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Tests GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CONDA_LIBMAMBA_SOLVER_NO_CHANNELS_FROM_INSTALLED=true GITHUB_ACTION_PATH=/home/github/70816999449/actions/conda-incubator-setup-miniconda@fc2d68f6413eb2d87b895e92f8584b5b94a10167 PYTEST_MARKER="$(/home/github/70816999449/helpers/eval_expression p:'(' p:'(' s:integration o:== s:unit p:')' o:'&&' s:'not integration' p:')' o:'||' s:integration)" PYTEST_SPLITS="$(/home/github/70816999449/helpers/eval_expression p:'(' p:'(' s:integration o:== s:unit p:')' o:'&&' s:2 p:')' o:'||' s:3)" CONDA_TEST_SOLVERS="$(/home/github/70816999449/helpers/eval_expression p:'(' p:'(' s:push o:== s:pull_request p:')' o:'&&' p:'(' p:'(' s:3.12 o:'!=' s:3.14 p:')' o:'||' p:'(' s:defaults o:== s:conda-forge p:')' p:')' o:'&&' s:libmamba p:')' o:'||' s:libmamba,classic)" "${CURRENT_ENV[@]}" INPUT_CONDARC-FILE=.github/condarc-defaults INPUT_RUN-POST=false INPUT_MINICONDA-VERSION="$(/home/github/70816999449/helpers/eval_expression p:'(' p:'(' s:defaults o:== s:defaults p:')' o:'&&' s:latest p:')' o:'||' l:'')" INPUT_MINIFORGE-VERSION="$(/home/github/70816999449/helpers/eval_expression p:'(' p:'(' s:defaults o:== s:conda-forge p:')' o:'&&' s:latest p:')' o:'||' l:'')" INPUT_INSTALLER-URL= INPUT_INSTALLATION-DIR= INPUT_MINIFORGE-VARIANT= INPUT_CONDA-VERSION= INPUT_CONDA-BUILD-VERSION= INPUT_ENVIRONMENT-FILE= INPUT_ACTIVATE-ENVIRONMENT=test INPUT_PYTHON-VERSION= INPUT_ADD-ANACONDA-TOKEN= INPUT_ADD-PIP-AS-PYTHON-DEPENDENCY= INPUT_ALLOW-SOFTLINKS= INPUT_AUTO-ACTIVATE=true INPUT_AUTO-ACTIVATE-BASE=legacy-placeholder INPUT_AUTO-UPDATE-CONDA=false INPUT_CHANNEL-ALIAS= INPUT_CHANNEL-PRIORITY= INPUT_CHANNELS= INPUT_CONDA-REMOVE-DEFAULTS= INPUT_SHOW-CHANNEL-URLS= INPUT_PKGS-DIRS= INPUT_USE-ONLY-TAR-BZ2= INPUT_REMOVE-PROFILES=true INPUT_MAMBA-VERSION= INPUT_USE-MAMBA= INPUT_CONDA-SOLVER=libmamba INPUT_ARCHITECTURE= INPUT_CLEAN-PATCHED-ENVIRONMENT-FILE=true \
bash -e /home/github/70816999449/steps/bugswarm_cmd.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=3 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=conda-incubator/setup-miniconda GITHUB_ACTIONS=true GITHUB_ACTOR=kenodegard GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/26.3.x GITHUB_REF_NAME=26.3.x GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=conda/conda GITHUB_REPOSITORY_OWNER=conda GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=ef0833c6af84c17d6e6962284863521ba02b11de GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Tests GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CONDA_LIBMAMBA_SOLVER_NO_CHANNELS_FROM_INSTALLED=true GITHUB_ACTION_PATH=/home/github/70816999449/actions/conda-incubator-setup-miniconda@fc2d68f6413eb2d87b895e92f8584b5b94a10167 PYTEST_MARKER="$(/home/github/70816999449/helpers/eval_expression p:'(' p:'(' s:integration o:== s:unit p:')' o:'&&' s:'not integration' p:')' o:'||' s:integration)" PYTEST_SPLITS="$(/home/github/70816999449/helpers/eval_expression p:'(' p:'(' s:integration o:== s:unit p:')' o:'&&' s:2 p:')' o:'||' s:3)" CONDA_TEST_SOLVERS="$(/home/github/70816999449/helpers/eval_expression p:'(' p:'(' s:push o:== s:pull_request p:')' o:'&&' p:'(' p:'(' s:3.12 o:'!=' s:3.14 p:')' o:'||' p:'(' s:defaults o:== s:conda-forge p:')' p:')' o:'&&' s:libmamba p:')' o:'||' s:libmamba,classic)" "${CURRENT_ENV[@]}" INPUT_CONDARC-FILE=.github/condarc-defaults INPUT_RUN-POST=false INPUT_MINICONDA-VERSION="$(/home/github/70816999449/helpers/eval_expression p:'(' p:'(' s:defaults o:== s:defaults p:')' o:'&&' s:latest p:')' o:'||' l:'')" INPUT_MINIFORGE-VERSION="$(/home/github/70816999449/helpers/eval_expression p:'(' p:'(' s:defaults o:== s:conda-forge p:')' o:'&&' s:latest p:')' o:'||' l:'')" INPUT_INSTALLER-URL= INPUT_INSTALLATION-DIR= INPUT_MINIFORGE-VARIANT= INPUT_CONDA-VERSION= INPUT_CONDA-BUILD-VERSION= INPUT_ENVIRONMENT-FILE= INPUT_ACTIVATE-ENVIRONMENT=test INPUT_PYTHON-VERSION= INPUT_ADD-ANACONDA-TOKEN= INPUT_ADD-PIP-AS-PYTHON-DEPENDENCY= INPUT_ALLOW-SOFTLINKS= INPUT_AUTO-ACTIVATE=true INPUT_AUTO-ACTIVATE-BASE=legacy-placeholder INPUT_AUTO-UPDATE-CONDA=false INPUT_CHANNEL-ALIAS= INPUT_CHANNEL-PRIORITY= INPUT_CHANNELS= INPUT_CONDA-REMOVE-DEFAULTS= INPUT_SHOW-CHANNEL-URLS= INPUT_PKGS-DIRS= INPUT_USE-ONLY-TAR-BZ2= INPUT_REMOVE-PROFILES=true INPUT_MAMBA-VERSION= INPUT_USE-MAMBA= INPUT_CONDA-SOLVER=libmamba INPUT_ARCHITECTURE= INPUT_CLEAN-PATCHED-ENVIRONMENT-FILE=true \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=3 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=conda-incubator/setup-miniconda GITHUB_ACTIONS=true GITHUB_ACTOR=kenodegard GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/26.3.x GITHUB_REF_NAME=26.3.x GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=conda/conda GITHUB_REPOSITORY_OWNER=conda GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=ef0833c6af84c17d6e6962284863521ba02b11de GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Tests GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CONDA_LIBMAMBA_SOLVER_NO_CHANNELS_FROM_INSTALLED=true GITHUB_ACTION_PATH=/home/github/70816999449/actions/conda-incubator-setup-miniconda@fc2d68f6413eb2d87b895e92f8584b5b94a10167 PYTEST_MARKER="$(/home/github/70816999449/helpers/eval_expression p:'(' p:'(' s:integration o:== s:unit p:')' o:'&&' s:'not integration' p:')' o:'||' s:integration)" PYTEST_SPLITS="$(/home/github/70816999449/helpers/eval_expression p:'(' p:'(' s:integration o:== s:unit p:')' o:'&&' s:2 p:')' o:'||' s:3)" CONDA_TEST_SOLVERS="$(/home/github/70816999449/helpers/eval_expression p:'(' p:'(' s:push o:== s:pull_request p:')' o:'&&' p:'(' p:'(' s:3.12 o:'!=' s:3.14 p:')' o:'||' p:'(' s:defaults o:== s:conda-forge p:')' p:')' o:'&&' s:libmamba p:')' o:'||' s:libmamba,classic)" "${CURRENT_ENV[@]}" INPUT_CONDARC-FILE=.github/condarc-defaults INPUT_RUN-POST=false INPUT_MINICONDA-VERSION="$(/home/github/70816999449/helpers/eval_expression p:'(' p:'(' s:defaults o:== s:defaults p:')' o:'&&' s:latest p:')' o:'||' l:'')" INPUT_MINIFORGE-VERSION="$(/home/github/70816999449/helpers/eval_expression p:'(' p:'(' s:defaults o:== s:conda-forge p:')' o:'&&' s:latest p:')' o:'||' l:'')" INPUT_INSTALLER-URL= INPUT_INSTALLATION-DIR= INPUT_MINIFORGE-VARIANT= INPUT_CONDA-VERSION= INPUT_CONDA-BUILD-VERSION= INPUT_ENVIRONMENT-FILE= INPUT_ACTIVATE-ENVIRONMENT=test INPUT_PYTHON-VERSION= INPUT_ADD-ANACONDA-TOKEN= INPUT_ADD-PIP-AS-PYTHON-DEPENDENCY= INPUT_ALLOW-SOFTLINKS= INPUT_AUTO-ACTIVATE=true INPUT_AUTO-ACTIVATE-BASE=legacy-placeholder INPUT_AUTO-UPDATE-CONDA=false INPUT_CHANNEL-ALIAS= INPUT_CHANNEL-PRIORITY= INPUT_CHANNELS= INPUT_CONDA-REMOVE-DEFAULTS= INPUT_SHOW-CHANNEL-URLS= INPUT_PKGS-DIRS= INPUT_USE-ONLY-TAR-BZ2= INPUT_REMOVE-PROFILES=true INPUT_MAMBA-VERSION= INPUT_USE-MAMBA= INPUT_CONDA-SOLVER=libmamba INPUT_ARCHITECTURE= INPUT_CLEAN-PATCHED-ENVIRONMENT-FILE=true \
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=4 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=kenodegard GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/26.3.x GITHUB_REF_NAME=26.3.x GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=conda/conda GITHUB_REPOSITORY_OWNER=conda GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=ef0833c6af84c17d6e6962284863521ba02b11de GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Tests GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CONDA_LIBMAMBA_SOLVER_NO_CHANNELS_FROM_INSTALLED=true PYTEST_MARKER="$(/home/github/70816999449/helpers/eval_expression p:'(' p:'(' s:integration o:== s:unit p:')' o:'&&' s:'not integration' p:')' o:'||' s:integration)" PYTEST_SPLITS="$(/home/github/70816999449/helpers/eval_expression p:'(' p:'(' s:integration o:== s:unit p:')' o:'&&' s:2 p:')' o:'||' s:3)" CONDA_TEST_SOLVERS="$(/home/github/70816999449/helpers/eval_expression p:'(' p:'(' s:push o:== s:pull_request p:')' o:'&&' p:'(' p:'(' s:3.12 o:'!=' s:3.14 p:')' o:'||' p:'(' s:defaults o:== s:conda-forge p:')' p:')' o:'&&' s:libmamba p:')' o:'||' s:libmamba,classic)" "${CURRENT_ENV[@]}" \
echo $(test "$_GITHUB_JOB_STATUS" = "success" && echo true || echo false))
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=4 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=kenodegard GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/26.3.x GITHUB_REF_NAME=26.3.x GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=conda/conda GITHUB_REPOSITORY_OWNER=conda GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=ef0833c6af84c17d6e6962284863521ba02b11de GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Tests GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CONDA_LIBMAMBA_SOLVER_NO_CHANNELS_FROM_INSTALLED=true PYTEST_MARKER="$(/home/github/70816999449/helpers/eval_expression p:'(' p:'(' s:integration o:== s:unit p:')' o:'&&' s:'not integration' p:')' o:'||' s:integration)" PYTEST_SPLITS="$(/home/github/70816999449/helpers/eval_expression p:'(' p:'(' s:integration o:== s:unit p:')' o:'&&' s:2 p:')' o:'||' s:3)" CONDA_TEST_SOLVERS="$(/home/github/70816999449/helpers/eval_expression p:'(' p:'(' s:push o:== s:pull_request p:')' o:'&&' p:'(' p:'(' s:3.12 o:'!=' s:3.14 p:')' o:'||' p:'(' s:defaults o:== s:conda-forge p:')' p:')' o:'&&' s:libmamba p:')' o:'||' s:libmamba,classic)" "${CURRENT_ENV[@]}" \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run 'conda install --yes --file tests/requirements.txt --file tests/requirements-Linux.txt --file tests/requirements-ci.txt --file tests/requirements-s3.txt python=3.12'
echo "##[endgroup]"
echo 'conda install --yes --file tests/requirements.txt --file tests/requirements-Linux.txt --file tests/requirements-ci.txt --file tests/requirements-s3.txt python=3.12
' > /home/github/70816999449/steps/bugswarm_4.script
chmod u+x /home/github/70816999449/steps/bugswarm_4.script


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=4 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=kenodegard GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/26.3.x GITHUB_REF_NAME=26.3.x GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=conda/conda GITHUB_REPOSITORY_OWNER=conda GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=ef0833c6af84c17d6e6962284863521ba02b11de GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Tests GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CONDA_LIBMAMBA_SOLVER_NO_CHANNELS_FROM_INSTALLED=true PYTEST_MARKER="$(/home/github/70816999449/helpers/eval_expression p:'(' p:'(' s:integration o:== s:unit p:')' o:'&&' s:'not integration' p:')' o:'||' s:integration)" PYTEST_SPLITS="$(/home/github/70816999449/helpers/eval_expression p:'(' p:'(' s:integration o:== s:unit p:')' o:'&&' s:2 p:')' o:'||' s:3)" CONDA_TEST_SOLVERS="$(/home/github/70816999449/helpers/eval_expression p:'(' p:'(' s:push o:== s:pull_request p:')' o:'&&' p:'(' p:'(' s:3.12 o:'!=' s:3.14 p:')' o:'||' p:'(' s:defaults o:== s:conda-forge p:')' p:')' o:'&&' s:libmamba p:')' o:'||' s:libmamba,classic)" "${CURRENT_ENV[@]}" \
bash -el /home/github/70816999449/steps/bugswarm_4.script
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=4 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=kenodegard GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/26.3.x GITHUB_REF_NAME=26.3.x GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=conda/conda GITHUB_REPOSITORY_OWNER=conda GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=ef0833c6af84c17d6e6962284863521ba02b11de GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Tests GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CONDA_LIBMAMBA_SOLVER_NO_CHANNELS_FROM_INSTALLED=true PYTEST_MARKER="$(/home/github/70816999449/helpers/eval_expression p:'(' p:'(' s:integration o:== s:unit p:')' o:'&&' s:'not integration' p:')' o:'||' s:integration)" PYTEST_SPLITS="$(/home/github/70816999449/helpers/eval_expression p:'(' p:'(' s:integration o:== s:unit p:')' o:'&&' s:2 p:')' o:'||' s:3)" CONDA_TEST_SOLVERS="$(/home/github/70816999449/helpers/eval_expression p:'(' p:'(' s:push o:== s:pull_request p:')' o:'&&' p:'(' p:'(' s:3.12 o:'!=' s:3.14 p:')' o:'||' p:'(' s:defaults o:== s:conda-forge p:')' p:')' o:'&&' s:libmamba p:')' o:'||' s:libmamba,classic)" "${CURRENT_ENV[@]}" \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=4 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=kenodegard GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/26.3.x GITHUB_REF_NAME=26.3.x GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=conda/conda GITHUB_REPOSITORY_OWNER=conda GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=ef0833c6af84c17d6e6962284863521ba02b11de GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Tests GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CONDA_LIBMAMBA_SOLVER_NO_CHANNELS_FROM_INSTALLED=true PYTEST_MARKER="$(/home/github/70816999449/helpers/eval_expression p:'(' p:'(' s:integration o:== s:unit p:')' o:'&&' s:'not integration' p:')' o:'||' s:integration)" PYTEST_SPLITS="$(/home/github/70816999449/helpers/eval_expression p:'(' p:'(' s:integration o:== s:unit p:')' o:'&&' s:2 p:')' o:'||' s:3)" CONDA_TEST_SOLVERS="$(/home/github/70816999449/helpers/eval_expression p:'(' p:'(' s:push o:== s:pull_request p:')' o:'&&' p:'(' p:'(' s:3.12 o:'!=' s:3.14 p:')' o:'||' p:'(' s:defaults o:== s:conda-forge p:')' p:')' o:'&&' s:libmamba p:')' o:'||' s:libmamba,classic)" "${CURRENT_ENV[@]}" \
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=5 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=kenodegard GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/26.3.x GITHUB_REF_NAME=26.3.x GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=conda/conda GITHUB_REPOSITORY_OWNER=conda GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=ef0833c6af84c17d6e6962284863521ba02b11de GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Tests GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CONDA_LIBMAMBA_SOLVER_NO_CHANNELS_FROM_INSTALLED=true PYTEST_MARKER="$(/home/github/70816999449/helpers/eval_expression p:'(' p:'(' s:integration o:== s:unit p:')' o:'&&' s:'not integration' p:')' o:'||' s:integration)" PYTEST_SPLITS="$(/home/github/70816999449/helpers/eval_expression p:'(' p:'(' s:integration o:== s:unit p:')' o:'&&' s:2 p:')' o:'||' s:3)" CONDA_TEST_SOLVERS="$(/home/github/70816999449/helpers/eval_expression p:'(' p:'(' s:push o:== s:pull_request p:')' o:'&&' p:'(' p:'(' s:3.12 o:'!=' s:3.14 p:')' o:'||' p:'(' s:defaults o:== s:conda-forge p:')' p:')' o:'&&' s:libmamba p:')' o:'||' s:libmamba,classic)" "${CURRENT_ENV[@]}" \
echo $(test "$_GITHUB_JOB_STATUS" = "success" && echo true || echo false))
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=5 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=kenodegard GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/26.3.x GITHUB_REF_NAME=26.3.x GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=conda/conda GITHUB_REPOSITORY_OWNER=conda GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=ef0833c6af84c17d6e6962284863521ba02b11de GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Tests GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CONDA_LIBMAMBA_SOLVER_NO_CHANNELS_FROM_INSTALLED=true PYTEST_MARKER="$(/home/github/70816999449/helpers/eval_expression p:'(' p:'(' s:integration o:== s:unit p:')' o:'&&' s:'not integration' p:')' o:'||' s:integration)" PYTEST_SPLITS="$(/home/github/70816999449/helpers/eval_expression p:'(' p:'(' s:integration o:== s:unit p:')' o:'&&' s:2 p:')' o:'||' s:3)" CONDA_TEST_SOLVERS="$(/home/github/70816999449/helpers/eval_expression p:'(' p:'(' s:push o:== s:pull_request p:')' o:'&&' p:'(' p:'(' s:3.12 o:'!=' s:3.14 p:')' o:'||' p:'(' s:defaults o:== s:conda-forge p:')' p:')' o:'&&' s:libmamba p:')' o:'||' s:libmamba,classic)" "${CURRENT_ENV[@]}" \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run 'python -m conda info --verbose'
echo "##[endgroup]"
echo 'python -m conda info --verbose' > /home/github/70816999449/steps/bugswarm_5.script
chmod u+x /home/github/70816999449/steps/bugswarm_5.script


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=5 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=kenodegard GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/26.3.x GITHUB_REF_NAME=26.3.x GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=conda/conda GITHUB_REPOSITORY_OWNER=conda GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=ef0833c6af84c17d6e6962284863521ba02b11de GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Tests GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CONDA_LIBMAMBA_SOLVER_NO_CHANNELS_FROM_INSTALLED=true PYTEST_MARKER="$(/home/github/70816999449/helpers/eval_expression p:'(' p:'(' s:integration o:== s:unit p:')' o:'&&' s:'not integration' p:')' o:'||' s:integration)" PYTEST_SPLITS="$(/home/github/70816999449/helpers/eval_expression p:'(' p:'(' s:integration o:== s:unit p:')' o:'&&' s:2 p:')' o:'||' s:3)" CONDA_TEST_SOLVERS="$(/home/github/70816999449/helpers/eval_expression p:'(' p:'(' s:push o:== s:pull_request p:')' o:'&&' p:'(' p:'(' s:3.12 o:'!=' s:3.14 p:')' o:'||' p:'(' s:defaults o:== s:conda-forge p:')' p:')' o:'&&' s:libmamba p:')' o:'||' s:libmamba,classic)" "${CURRENT_ENV[@]}" \
bash -el /home/github/70816999449/steps/bugswarm_5.script
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=5 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=kenodegard GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/26.3.x GITHUB_REF_NAME=26.3.x GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=conda/conda GITHUB_REPOSITORY_OWNER=conda GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=ef0833c6af84c17d6e6962284863521ba02b11de GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Tests GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CONDA_LIBMAMBA_SOLVER_NO_CHANNELS_FROM_INSTALLED=true PYTEST_MARKER="$(/home/github/70816999449/helpers/eval_expression p:'(' p:'(' s:integration o:== s:unit p:')' o:'&&' s:'not integration' p:')' o:'||' s:integration)" PYTEST_SPLITS="$(/home/github/70816999449/helpers/eval_expression p:'(' p:'(' s:integration o:== s:unit p:')' o:'&&' s:2 p:')' o:'||' s:3)" CONDA_TEST_SOLVERS="$(/home/github/70816999449/helpers/eval_expression p:'(' p:'(' s:push o:== s:pull_request p:')' o:'&&' p:'(' p:'(' s:3.12 o:'!=' s:3.14 p:')' o:'||' p:'(' s:defaults o:== s:conda-forge p:')' p:')' o:'&&' s:libmamba p:')' o:'||' s:libmamba,classic)" "${CURRENT_ENV[@]}" \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=5 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=kenodegard GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/26.3.x GITHUB_REF_NAME=26.3.x GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=conda/conda GITHUB_REPOSITORY_OWNER=conda GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=ef0833c6af84c17d6e6962284863521ba02b11de GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Tests GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CONDA_LIBMAMBA_SOLVER_NO_CHANNELS_FROM_INSTALLED=true PYTEST_MARKER="$(/home/github/70816999449/helpers/eval_expression p:'(' p:'(' s:integration o:== s:unit p:')' o:'&&' s:'not integration' p:')' o:'||' s:integration)" PYTEST_SPLITS="$(/home/github/70816999449/helpers/eval_expression p:'(' p:'(' s:integration o:== s:unit p:')' o:'&&' s:2 p:')' o:'||' s:3)" CONDA_TEST_SOLVERS="$(/home/github/70816999449/helpers/eval_expression p:'(' p:'(' s:push o:== s:pull_request p:')' o:'&&' p:'(' p:'(' s:3.12 o:'!=' s:3.14 p:')' o:'||' p:'(' s:defaults o:== s:conda-forge p:')' p:')' o:'&&' s:libmamba p:')' o:'||' s:libmamba,classic)" "${CURRENT_ENV[@]}" \
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=6 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=kenodegard GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/26.3.x GITHUB_REF_NAME=26.3.x GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=conda/conda GITHUB_REPOSITORY_OWNER=conda GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=ef0833c6af84c17d6e6962284863521ba02b11de GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Tests GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CONDA_LIBMAMBA_SOLVER_NO_CHANNELS_FROM_INSTALLED=true PYTEST_MARKER="$(/home/github/70816999449/helpers/eval_expression p:'(' p:'(' s:integration o:== s:unit p:')' o:'&&' s:'not integration' p:')' o:'||' s:integration)" PYTEST_SPLITS="$(/home/github/70816999449/helpers/eval_expression p:'(' p:'(' s:integration o:== s:unit p:')' o:'&&' s:2 p:')' o:'||' s:3)" CONDA_TEST_SOLVERS="$(/home/github/70816999449/helpers/eval_expression p:'(' p:'(' s:push o:== s:pull_request p:')' o:'&&' p:'(' p:'(' s:3.12 o:'!=' s:3.14 p:')' o:'||' p:'(' s:defaults o:== s:conda-forge p:')' p:')' o:'&&' s:libmamba p:')' o:'||' s:libmamba,classic)" "${CURRENT_ENV[@]}" \
echo $(test "$_GITHUB_JOB_STATUS" = "success" && echo true || echo false))
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=6 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=kenodegard GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/26.3.x GITHUB_REF_NAME=26.3.x GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=conda/conda GITHUB_REPOSITORY_OWNER=conda GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=ef0833c6af84c17d6e6962284863521ba02b11de GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Tests GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CONDA_LIBMAMBA_SOLVER_NO_CHANNELS_FROM_INSTALLED=true PYTEST_MARKER="$(/home/github/70816999449/helpers/eval_expression p:'(' p:'(' s:integration o:== s:unit p:')' o:'&&' s:'not integration' p:')' o:'||' s:integration)" PYTEST_SPLITS="$(/home/github/70816999449/helpers/eval_expression p:'(' p:'(' s:integration o:== s:unit p:')' o:'&&' s:2 p:')' o:'||' s:3)" CONDA_TEST_SOLVERS="$(/home/github/70816999449/helpers/eval_expression p:'(' p:'(' s:push o:== s:pull_request p:')' o:'&&' p:'(' p:'(' s:3.12 o:'!=' s:3.14 p:')' o:'||' p:'(' s:defaults o:== s:conda-forge p:')' p:')' o:'&&' s:libmamba p:')' o:'||' s:libmamba,classic)" "${CURRENT_ENV[@]}" \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run 'conda config --show-sources'
echo "##[endgroup]"
echo 'conda config --show-sources' > /home/github/70816999449/steps/bugswarm_6.script
chmod u+x /home/github/70816999449/steps/bugswarm_6.script


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=6 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=kenodegard GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/26.3.x GITHUB_REF_NAME=26.3.x GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=conda/conda GITHUB_REPOSITORY_OWNER=conda GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=ef0833c6af84c17d6e6962284863521ba02b11de GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Tests GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CONDA_LIBMAMBA_SOLVER_NO_CHANNELS_FROM_INSTALLED=true PYTEST_MARKER="$(/home/github/70816999449/helpers/eval_expression p:'(' p:'(' s:integration o:== s:unit p:')' o:'&&' s:'not integration' p:')' o:'||' s:integration)" PYTEST_SPLITS="$(/home/github/70816999449/helpers/eval_expression p:'(' p:'(' s:integration o:== s:unit p:')' o:'&&' s:2 p:')' o:'||' s:3)" CONDA_TEST_SOLVERS="$(/home/github/70816999449/helpers/eval_expression p:'(' p:'(' s:push o:== s:pull_request p:')' o:'&&' p:'(' p:'(' s:3.12 o:'!=' s:3.14 p:')' o:'||' p:'(' s:defaults o:== s:conda-forge p:')' p:')' o:'&&' s:libmamba p:')' o:'||' s:libmamba,classic)" "${CURRENT_ENV[@]}" \
bash -el /home/github/70816999449/steps/bugswarm_6.script
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=6 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=kenodegard GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/26.3.x GITHUB_REF_NAME=26.3.x GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=conda/conda GITHUB_REPOSITORY_OWNER=conda GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=ef0833c6af84c17d6e6962284863521ba02b11de GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Tests GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CONDA_LIBMAMBA_SOLVER_NO_CHANNELS_FROM_INSTALLED=true PYTEST_MARKER="$(/home/github/70816999449/helpers/eval_expression p:'(' p:'(' s:integration o:== s:unit p:')' o:'&&' s:'not integration' p:')' o:'||' s:integration)" PYTEST_SPLITS="$(/home/github/70816999449/helpers/eval_expression p:'(' p:'(' s:integration o:== s:unit p:')' o:'&&' s:2 p:')' o:'||' s:3)" CONDA_TEST_SOLVERS="$(/home/github/70816999449/helpers/eval_expression p:'(' p:'(' s:push o:== s:pull_request p:')' o:'&&' p:'(' p:'(' s:3.12 o:'!=' s:3.14 p:')' o:'||' p:'(' s:defaults o:== s:conda-forge p:')' p:')' o:'&&' s:libmamba p:')' o:'||' s:libmamba,classic)" "${CURRENT_ENV[@]}" \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=6 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=kenodegard GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/26.3.x GITHUB_REF_NAME=26.3.x GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=conda/conda GITHUB_REPOSITORY_OWNER=conda GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=ef0833c6af84c17d6e6962284863521ba02b11de GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Tests GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CONDA_LIBMAMBA_SOLVER_NO_CHANNELS_FROM_INSTALLED=true PYTEST_MARKER="$(/home/github/70816999449/helpers/eval_expression p:'(' p:'(' s:integration o:== s:unit p:')' o:'&&' s:'not integration' p:')' o:'||' s:integration)" PYTEST_SPLITS="$(/home/github/70816999449/helpers/eval_expression p:'(' p:'(' s:integration o:== s:unit p:')' o:'&&' s:2 p:')' o:'||' s:3)" CONDA_TEST_SOLVERS="$(/home/github/70816999449/helpers/eval_expression p:'(' p:'(' s:push o:== s:pull_request p:')' o:'&&' p:'(' p:'(' s:3.12 o:'!=' s:3.14 p:')' o:'||' p:'(' s:defaults o:== s:conda-forge p:')' p:')' o:'&&' s:libmamba p:')' o:'||' s:libmamba,classic)" "${CURRENT_ENV[@]}" \
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=7 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=kenodegard GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/26.3.x GITHUB_REF_NAME=26.3.x GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=conda/conda GITHUB_REPOSITORY_OWNER=conda GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=ef0833c6af84c17d6e6962284863521ba02b11de GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Tests GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CONDA_LIBMAMBA_SOLVER_NO_CHANNELS_FROM_INSTALLED=true PYTEST_MARKER="$(/home/github/70816999449/helpers/eval_expression p:'(' p:'(' s:integration o:== s:unit p:')' o:'&&' s:'not integration' p:')' o:'||' s:integration)" PYTEST_SPLITS="$(/home/github/70816999449/helpers/eval_expression p:'(' p:'(' s:integration o:== s:unit p:')' o:'&&' s:2 p:')' o:'||' s:3)" CONDA_TEST_SOLVERS="$(/home/github/70816999449/helpers/eval_expression p:'(' p:'(' s:push o:== s:pull_request p:')' o:'&&' p:'(' p:'(' s:3.12 o:'!=' s:3.14 p:')' o:'||' p:'(' s:defaults o:== s:conda-forge p:')' p:')' o:'&&' s:libmamba p:')' o:'||' s:libmamba,classic)" "${CURRENT_ENV[@]}" \
echo $(test "$_GITHUB_JOB_STATUS" = "success" && echo true || echo false))
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=7 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=kenodegard GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/26.3.x GITHUB_REF_NAME=26.3.x GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=conda/conda GITHUB_REPOSITORY_OWNER=conda GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=ef0833c6af84c17d6e6962284863521ba02b11de GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Tests GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CONDA_LIBMAMBA_SOLVER_NO_CHANNELS_FROM_INSTALLED=true PYTEST_MARKER="$(/home/github/70816999449/helpers/eval_expression p:'(' p:'(' s:integration o:== s:unit p:')' o:'&&' s:'not integration' p:')' o:'||' s:integration)" PYTEST_SPLITS="$(/home/github/70816999449/helpers/eval_expression p:'(' p:'(' s:integration o:== s:unit p:')' o:'&&' s:2 p:')' o:'||' s:3)" CONDA_TEST_SOLVERS="$(/home/github/70816999449/helpers/eval_expression p:'(' p:'(' s:push o:== s:pull_request p:')' o:'&&' p:'(' p:'(' s:3.12 o:'!=' s:3.14 p:')' o:'||' p:'(' s:defaults o:== s:conda-forge p:')' p:')' o:'&&' s:libmamba p:')' o:'||' s:libmamba,classic)" "${CURRENT_ENV[@]}" \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run 'conda list --show-channel-urls'
echo "##[endgroup]"
echo 'conda list --show-channel-urls' > /home/github/70816999449/steps/bugswarm_7.script
chmod u+x /home/github/70816999449/steps/bugswarm_7.script


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=7 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=kenodegard GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/26.3.x GITHUB_REF_NAME=26.3.x GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=conda/conda GITHUB_REPOSITORY_OWNER=conda GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=ef0833c6af84c17d6e6962284863521ba02b11de GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Tests GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CONDA_LIBMAMBA_SOLVER_NO_CHANNELS_FROM_INSTALLED=true PYTEST_MARKER="$(/home/github/70816999449/helpers/eval_expression p:'(' p:'(' s:integration o:== s:unit p:')' o:'&&' s:'not integration' p:')' o:'||' s:integration)" PYTEST_SPLITS="$(/home/github/70816999449/helpers/eval_expression p:'(' p:'(' s:integration o:== s:unit p:')' o:'&&' s:2 p:')' o:'||' s:3)" CONDA_TEST_SOLVERS="$(/home/github/70816999449/helpers/eval_expression p:'(' p:'(' s:push o:== s:pull_request p:')' o:'&&' p:'(' p:'(' s:3.12 o:'!=' s:3.14 p:')' o:'||' p:'(' s:defaults o:== s:conda-forge p:')' p:')' o:'&&' s:libmamba p:')' o:'||' s:libmamba,classic)" "${CURRENT_ENV[@]}" \
bash -el /home/github/70816999449/steps/bugswarm_7.script
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=7 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=kenodegard GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/26.3.x GITHUB_REF_NAME=26.3.x GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=conda/conda GITHUB_REPOSITORY_OWNER=conda GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=ef0833c6af84c17d6e6962284863521ba02b11de GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Tests GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CONDA_LIBMAMBA_SOLVER_NO_CHANNELS_FROM_INSTALLED=true PYTEST_MARKER="$(/home/github/70816999449/helpers/eval_expression p:'(' p:'(' s:integration o:== s:unit p:')' o:'&&' s:'not integration' p:')' o:'||' s:integration)" PYTEST_SPLITS="$(/home/github/70816999449/helpers/eval_expression p:'(' p:'(' s:integration o:== s:unit p:')' o:'&&' s:2 p:')' o:'||' s:3)" CONDA_TEST_SOLVERS="$(/home/github/70816999449/helpers/eval_expression p:'(' p:'(' s:push o:== s:pull_request p:')' o:'&&' p:'(' p:'(' s:3.12 o:'!=' s:3.14 p:')' o:'||' p:'(' s:defaults o:== s:conda-forge p:')' p:')' o:'&&' s:libmamba p:')' o:'||' s:libmamba,classic)" "${CURRENT_ENV[@]}" \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=7 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=kenodegard GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/26.3.x GITHUB_REF_NAME=26.3.x GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=conda/conda GITHUB_REPOSITORY_OWNER=conda GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=ef0833c6af84c17d6e6962284863521ba02b11de GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Tests GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CONDA_LIBMAMBA_SOLVER_NO_CHANNELS_FROM_INSTALLED=true PYTEST_MARKER="$(/home/github/70816999449/helpers/eval_expression p:'(' p:'(' s:integration o:== s:unit p:')' o:'&&' s:'not integration' p:')' o:'||' s:integration)" PYTEST_SPLITS="$(/home/github/70816999449/helpers/eval_expression p:'(' p:'(' s:integration o:== s:unit p:')' o:'&&' s:2 p:')' o:'||' s:3)" CONDA_TEST_SOLVERS="$(/home/github/70816999449/helpers/eval_expression p:'(' p:'(' s:push o:== s:pull_request p:')' o:'&&' p:'(' p:'(' s:3.12 o:'!=' s:3.14 p:')' o:'||' p:'(' s:defaults o:== s:conda-forge p:')' p:')' o:'&&' s:libmamba p:')' o:'||' s:libmamba,classic)" "${CURRENT_ENV[@]}" \
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=8 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=kenodegard GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/26.3.x GITHUB_REF_NAME=26.3.x GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=conda/conda GITHUB_REPOSITORY_OWNER=conda GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=ef0833c6af84c17d6e6962284863521ba02b11de GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Tests GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CONDA_LIBMAMBA_SOLVER_NO_CHANNELS_FROM_INSTALLED=true PYTEST_MARKER="$(/home/github/70816999449/helpers/eval_expression p:'(' p:'(' s:integration o:== s:unit p:')' o:'&&' s:'not integration' p:')' o:'||' s:integration)" PYTEST_SPLITS="$(/home/github/70816999449/helpers/eval_expression p:'(' p:'(' s:integration o:== s:unit p:')' o:'&&' s:2 p:')' o:'||' s:3)" CONDA_TEST_SOLVERS="$(/home/github/70816999449/helpers/eval_expression p:'(' p:'(' s:push o:== s:pull_request p:')' o:'&&' p:'(' p:'(' s:3.12 o:'!=' s:3.14 p:')' o:'||' p:'(' s:defaults o:== s:conda-forge p:')' p:')' o:'&&' s:libmamba p:')' o:'||' s:libmamba,classic)" "${CURRENT_ENV[@]}" \
echo "$(/home/github/70816999449/helpers/eval_expression p:'(' f:success p:'(' p:')' p:')' o:'&&' p:'(' s:integration o:== s:integration p:')')")
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=8 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=kenodegard GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/26.3.x GITHUB_REF_NAME=26.3.x GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=conda/conda GITHUB_REPOSITORY_OWNER=conda GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=ef0833c6af84c17d6e6962284863521ba02b11de GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Tests GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CONDA_LIBMAMBA_SOLVER_NO_CHANNELS_FROM_INSTALLED=true PYTEST_MARKER="$(/home/github/70816999449/helpers/eval_expression p:'(' p:'(' s:integration o:== s:unit p:')' o:'&&' s:'not integration' p:')' o:'||' s:integration)" PYTEST_SPLITS="$(/home/github/70816999449/helpers/eval_expression p:'(' p:'(' s:integration o:== s:unit p:')' o:'&&' s:2 p:')' o:'||' s:3)" CONDA_TEST_SOLVERS="$(/home/github/70816999449/helpers/eval_expression p:'(' p:'(' s:push o:== s:pull_request p:')' o:'&&' p:'(' p:'(' s:3.12 o:'!=' s:3.14 p:')' o:'||' p:'(' s:defaults o:== s:conda-forge p:')' p:')' o:'&&' s:libmamba p:')' o:'||' s:libmamba,classic)" "${CURRENT_ENV[@]}" \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run 'sudo apt update && sudo apt install ash csh fish tcsh zsh'
echo "##[endgroup]"
echo 'sudo apt update && sudo apt install ash csh fish tcsh zsh
# xonsh is installed with conda in step above
# Initialize all shells
python -m conda init --all
' > /home/github/70816999449/steps/bugswarm_8.script
chmod u+x /home/github/70816999449/steps/bugswarm_8.script


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=8 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=kenodegard GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/26.3.x GITHUB_REF_NAME=26.3.x GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=conda/conda GITHUB_REPOSITORY_OWNER=conda GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=ef0833c6af84c17d6e6962284863521ba02b11de GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Tests GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CONDA_LIBMAMBA_SOLVER_NO_CHANNELS_FROM_INSTALLED=true PYTEST_MARKER="$(/home/github/70816999449/helpers/eval_expression p:'(' p:'(' s:integration o:== s:unit p:')' o:'&&' s:'not integration' p:')' o:'||' s:integration)" PYTEST_SPLITS="$(/home/github/70816999449/helpers/eval_expression p:'(' p:'(' s:integration o:== s:unit p:')' o:'&&' s:2 p:')' o:'||' s:3)" CONDA_TEST_SOLVERS="$(/home/github/70816999449/helpers/eval_expression p:'(' p:'(' s:push o:== s:pull_request p:')' o:'&&' p:'(' p:'(' s:3.12 o:'!=' s:3.14 p:')' o:'||' p:'(' s:defaults o:== s:conda-forge p:')' p:')' o:'&&' s:libmamba p:')' o:'||' s:libmamba,classic)" "${CURRENT_ENV[@]}" \
bash -el /home/github/70816999449/steps/bugswarm_8.script
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=8 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=kenodegard GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/26.3.x GITHUB_REF_NAME=26.3.x GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=conda/conda GITHUB_REPOSITORY_OWNER=conda GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=ef0833c6af84c17d6e6962284863521ba02b11de GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Tests GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CONDA_LIBMAMBA_SOLVER_NO_CHANNELS_FROM_INSTALLED=true PYTEST_MARKER="$(/home/github/70816999449/helpers/eval_expression p:'(' p:'(' s:integration o:== s:unit p:')' o:'&&' s:'not integration' p:')' o:'||' s:integration)" PYTEST_SPLITS="$(/home/github/70816999449/helpers/eval_expression p:'(' p:'(' s:integration o:== s:unit p:')' o:'&&' s:2 p:')' o:'||' s:3)" CONDA_TEST_SOLVERS="$(/home/github/70816999449/helpers/eval_expression p:'(' p:'(' s:push o:== s:pull_request p:')' o:'&&' p:'(' p:'(' s:3.12 o:'!=' s:3.14 p:')' o:'||' p:'(' s:defaults o:== s:conda-forge p:')' p:')' o:'&&' s:libmamba p:')' o:'||' s:libmamba,classic)" "${CURRENT_ENV[@]}" \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=8 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=kenodegard GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/26.3.x GITHUB_REF_NAME=26.3.x GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=conda/conda GITHUB_REPOSITORY_OWNER=conda GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=ef0833c6af84c17d6e6962284863521ba02b11de GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Tests GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CONDA_LIBMAMBA_SOLVER_NO_CHANNELS_FROM_INSTALLED=true PYTEST_MARKER="$(/home/github/70816999449/helpers/eval_expression p:'(' p:'(' s:integration o:== s:unit p:')' o:'&&' s:'not integration' p:')' o:'||' s:integration)" PYTEST_SPLITS="$(/home/github/70816999449/helpers/eval_expression p:'(' p:'(' s:integration o:== s:unit p:')' o:'&&' s:2 p:')' o:'||' s:3)" CONDA_TEST_SOLVERS="$(/home/github/70816999449/helpers/eval_expression p:'(' p:'(' s:push o:== s:pull_request p:')' o:'&&' p:'(' p:'(' s:3.12 o:'!=' s:3.14 p:')' o:'||' p:'(' s:defaults o:== s:conda-forge p:')' p:')' o:'&&' s:libmamba p:')' o:'||' s:libmamba,classic)" "${CURRENT_ENV[@]}" \
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=9 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=kenodegard GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/26.3.x GITHUB_REF_NAME=26.3.x GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=conda/conda GITHUB_REPOSITORY_OWNER=conda GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=ef0833c6af84c17d6e6962284863521ba02b11de GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Tests GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CONDA_LIBMAMBA_SOLVER_NO_CHANNELS_FROM_INSTALLED=true PYTEST_MARKER="$(/home/github/70816999449/helpers/eval_expression p:'(' p:'(' s:integration o:== s:unit p:')' o:'&&' s:'not integration' p:')' o:'||' s:integration)" PYTEST_SPLITS="$(/home/github/70816999449/helpers/eval_expression p:'(' p:'(' s:integration o:== s:unit p:')' o:'&&' s:2 p:')' o:'||' s:3)" CONDA_TEST_SOLVERS="$(/home/github/70816999449/helpers/eval_expression p:'(' p:'(' s:push o:== s:pull_request p:')' o:'&&' p:'(' p:'(' s:3.12 o:'!=' s:3.14 p:')' o:'||' p:'(' s:defaults o:== s:conda-forge p:')' p:')' o:'&&' s:libmamba p:')' o:'||' s:libmamba,classic)" "${CURRENT_ENV[@]}" \
echo $(test "$_GITHUB_JOB_STATUS" = "success" && echo true || echo false))
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=9 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=kenodegard GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/26.3.x GITHUB_REF_NAME=26.3.x GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=conda/conda GITHUB_REPOSITORY_OWNER=conda GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=ef0833c6af84c17d6e6962284863521ba02b11de GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Tests GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CONDA_LIBMAMBA_SOLVER_NO_CHANNELS_FROM_INSTALLED=true PYTEST_MARKER="$(/home/github/70816999449/helpers/eval_expression p:'(' p:'(' s:integration o:== s:unit p:')' o:'&&' s:'not integration' p:')' o:'||' s:integration)" PYTEST_SPLITS="$(/home/github/70816999449/helpers/eval_expression p:'(' p:'(' s:integration o:== s:unit p:')' o:'&&' s:2 p:')' o:'||' s:3)" CONDA_TEST_SOLVERS="$(/home/github/70816999449/helpers/eval_expression p:'(' p:'(' s:push o:== s:pull_request p:')' o:'&&' p:'(' p:'(' s:3.12 o:'!=' s:3.14 p:')' o:'||' p:'(' s:defaults o:== s:conda-forge p:')' p:')' o:'&&' s:libmamba p:')' o:'||' s:libmamba,classic)" "${CURRENT_ENV[@]}" \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run 'python -m pytest --cov=conda --durations-path=durations/Linux.json --group=3 --splits='"$(test -v "CURRENT_ENV_MAP[PYTEST_SPLITS]" && echo "${CURRENT_ENV_MAP[PYTEST_SPLITS]}" || echo "$(/home/github/70816999449/helpers/eval_expression p:'(' p:'(' s:integration o:== s:unit p:')' o:'&&' s:2 p:')' o:'||' s:3)")"' -m "'"$(test -v "CURRENT_ENV_MAP[PYTEST_MARKER]" && echo "${CURRENT_ENV_MAP[PYTEST_MARKER]}" || echo "$(/home/github/70816999449/helpers/eval_expression p:'(' p:'(' s:integration o:== s:unit p:')' o:'&&' s:'not integration' p:')' o:'||' s:integration)")"'"'
echo "##[endgroup]"
echo 'python -m pytest --cov=conda --durations-path=durations/Linux.json --group=3 --splits='"$(test -v "CURRENT_ENV_MAP[PYTEST_SPLITS]" && echo "${CURRENT_ENV_MAP[PYTEST_SPLITS]}" || echo "$(/home/github/70816999449/helpers/eval_expression p:'(' p:'(' s:integration o:== s:unit p:')' o:'&&' s:2 p:')' o:'||' s:3)")"' -m "'"$(test -v "CURRENT_ENV_MAP[PYTEST_MARKER]" && echo "${CURRENT_ENV_MAP[PYTEST_MARKER]}" || echo "$(/home/github/70816999449/helpers/eval_expression p:'(' p:'(' s:integration o:== s:unit p:')' o:'&&' s:'not integration' p:')' o:'||' s:integration)")"'"
' > /home/github/70816999449/steps/bugswarm_9.script
chmod u+x /home/github/70816999449/steps/bugswarm_9.script


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=9 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=kenodegard GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/26.3.x GITHUB_REF_NAME=26.3.x GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=conda/conda GITHUB_REPOSITORY_OWNER=conda GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=ef0833c6af84c17d6e6962284863521ba02b11de GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Tests GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CONDA_LIBMAMBA_SOLVER_NO_CHANNELS_FROM_INSTALLED=true PYTEST_MARKER="$(/home/github/70816999449/helpers/eval_expression p:'(' p:'(' s:integration o:== s:unit p:')' o:'&&' s:'not integration' p:')' o:'||' s:integration)" PYTEST_SPLITS="$(/home/github/70816999449/helpers/eval_expression p:'(' p:'(' s:integration o:== s:unit p:')' o:'&&' s:2 p:')' o:'||' s:3)" CONDA_TEST_SOLVERS="$(/home/github/70816999449/helpers/eval_expression p:'(' p:'(' s:push o:== s:pull_request p:')' o:'&&' p:'(' p:'(' s:3.12 o:'!=' s:3.14 p:')' o:'||' p:'(' s:defaults o:== s:conda-forge p:')' p:')' o:'&&' s:libmamba p:')' o:'||' s:libmamba,classic)" "${CURRENT_ENV[@]}" \
bash -el /home/github/70816999449/steps/bugswarm_9.script
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=9 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=kenodegard GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/26.3.x GITHUB_REF_NAME=26.3.x GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=conda/conda GITHUB_REPOSITORY_OWNER=conda GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=ef0833c6af84c17d6e6962284863521ba02b11de GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Tests GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CONDA_LIBMAMBA_SOLVER_NO_CHANNELS_FROM_INSTALLED=true PYTEST_MARKER="$(/home/github/70816999449/helpers/eval_expression p:'(' p:'(' s:integration o:== s:unit p:')' o:'&&' s:'not integration' p:')' o:'||' s:integration)" PYTEST_SPLITS="$(/home/github/70816999449/helpers/eval_expression p:'(' p:'(' s:integration o:== s:unit p:')' o:'&&' s:2 p:')' o:'||' s:3)" CONDA_TEST_SOLVERS="$(/home/github/70816999449/helpers/eval_expression p:'(' p:'(' s:push o:== s:pull_request p:')' o:'&&' p:'(' p:'(' s:3.12 o:'!=' s:3.14 p:')' o:'||' p:'(' s:defaults o:== s:conda-forge p:')' p:')' o:'&&' s:libmamba p:')' o:'||' s:libmamba,classic)" "${CURRENT_ENV[@]}" \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=9 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=kenodegard GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/26.3.x GITHUB_REF_NAME=26.3.x GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=conda/conda GITHUB_REPOSITORY_OWNER=conda GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=ef0833c6af84c17d6e6962284863521ba02b11de GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Tests GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CONDA_LIBMAMBA_SOLVER_NO_CHANNELS_FROM_INSTALLED=true PYTEST_MARKER="$(/home/github/70816999449/helpers/eval_expression p:'(' p:'(' s:integration o:== s:unit p:')' o:'&&' s:'not integration' p:')' o:'||' s:integration)" PYTEST_SPLITS="$(/home/github/70816999449/helpers/eval_expression p:'(' p:'(' s:integration o:== s:unit p:')' o:'&&' s:2 p:')' o:'||' s:3)" CONDA_TEST_SOLVERS="$(/home/github/70816999449/helpers/eval_expression p:'(' p:'(' s:push o:== s:pull_request p:')' o:'&&' p:'(' p:'(' s:3.12 o:'!=' s:3.14 p:')' o:'||' p:'(' s:defaults o:== s:conda-forge p:')' p:')' o:'&&' s:libmamba p:')' o:'||' s:libmamba,classic)" "${CURRENT_ENV[@]}" \
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
   bash -e $ACTIONS_RUNNER_HOOK_JOB_COMPLETED 70816999449 passed
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
