#!/usr/bin/env bash
export GITHUB_WORKSPACE=/home/github/build/GitoxideLabs/gitoxide

if [[ ! -z "$ACTIONS_RUNNER_HOOK_JOB_STARTED" ]]; then
   echo "A job started hook has been configured by the self-hosted runner administrator"
   echo "##[group]Run '$ACTIONS_RUNNER_HOOK_JOB_STARTED'"
   echo "##[endgroup]"
   bash -e $ACTIONS_RUNNER_HOOK_JOB_STARTED 66133989777 failed
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

cp /home/github/66133989777/event.json /home/github/workflow/event.json
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=1 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=datdenkikniet GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=mini-optimize GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/mini-optimize GITHUB_REF_NAME=mini-optimize GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=GitoxideLabs/gitoxide GITHUB_REPOSITORY_OWNER=GitoxideLabs GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=7b50a7e9235cc2b182d40895ea8272ed8998709b GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=ci GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_TERM_COLOR=always CLICOLOR=1 "${CURRENT_ENV[@]}" \
echo $(test "$_GITHUB_JOB_STATUS" = "success" && echo true || echo false))
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=1 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=datdenkikniet GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=mini-optimize GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/mini-optimize GITHUB_REF_NAME=mini-optimize GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=GitoxideLabs/gitoxide GITHUB_REPOSITORY_OWNER=GitoxideLabs GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=7b50a7e9235cc2b182d40895ea8272ed8998709b GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=ci GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_TERM_COLOR=always CLICOLOR=1 "${CURRENT_ENV[@]}" \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run 'rustup update stable'
echo "##[endgroup]"
echo 'rustup update stable
rustup default stable
' > /home/github/66133989777/steps/bugswarm_1.sh
chmod u+x /home/github/66133989777/steps/bugswarm_1.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=1 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=datdenkikniet GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=mini-optimize GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/mini-optimize GITHUB_REF_NAME=mini-optimize GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=GitoxideLabs/gitoxide GITHUB_REPOSITORY_OWNER=GitoxideLabs GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=7b50a7e9235cc2b182d40895ea8272ed8998709b GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=ci GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_TERM_COLOR=always CLICOLOR=1 "${CURRENT_ENV[@]}" \
bash --noprofile --norc -eo pipefail /home/github/66133989777/steps/bugswarm_1.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=1 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=datdenkikniet GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=mini-optimize GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/mini-optimize GITHUB_REF_NAME=mini-optimize GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=GitoxideLabs/gitoxide GITHUB_REPOSITORY_OWNER=GitoxideLabs GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=7b50a7e9235cc2b182d40895ea8272ed8998709b GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=ci GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_TERM_COLOR=always CLICOLOR=1 "${CURRENT_ENV[@]}" \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=1 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=datdenkikniet GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=mini-optimize GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/mini-optimize GITHUB_REF_NAME=mini-optimize GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=GitoxideLabs/gitoxide GITHUB_REPOSITORY_OWNER=GitoxideLabs GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=7b50a7e9235cc2b182d40895ea8272ed8998709b GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=ci GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_TERM_COLOR=always CLICOLOR=1 "${CURRENT_ENV[@]}" \
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=2 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=Swatinem/rust-cache GITHUB_ACTIONS=true GITHUB_ACTOR=datdenkikniet GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=mini-optimize GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/mini-optimize GITHUB_REF_NAME=mini-optimize GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=GitoxideLabs/gitoxide GITHUB_REPOSITORY_OWNER=GitoxideLabs GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=7b50a7e9235cc2b182d40895ea8272ed8998709b GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=ci GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_TERM_COLOR=always CLICOLOR=1 GITHUB_ACTION_PATH=/home/github/66133989777/actions/Swatinem-rust-cache@779680da715d629ac1d338a641029a2f4372abb5 "${CURRENT_ENV[@]}" INPUT_SAVE-IF="$(/home/github/66133989777/helpers/eval_expression s:refs/heads/mini-optimize o:== s:refs/heads/main)" INPUT_PREFIX-KEY=v0-rust INPUT_ADD-JOB-ID-KEY=true INPUT_ADD-RUST-ENVIRONMENT-HASH-KEY=true INPUT_CACHE-TARGETS=true INPUT_CACHE-ALL-CRATES=false INPUT_CACHE-WORKSPACE-CRATES=false INPUT_CACHE-PROVIDER=github INPUT_CACHE-BIN=true INPUT_LOOKUP-ONLY=false \
echo $(test "$_GITHUB_JOB_STATUS" = "success" && echo true || echo false))
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=2 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=Swatinem/rust-cache GITHUB_ACTIONS=true GITHUB_ACTOR=datdenkikniet GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=mini-optimize GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/mini-optimize GITHUB_REF_NAME=mini-optimize GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=GitoxideLabs/gitoxide GITHUB_REPOSITORY_OWNER=GitoxideLabs GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=7b50a7e9235cc2b182d40895ea8272ed8998709b GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=ci GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_TERM_COLOR=always CLICOLOR=1 GITHUB_ACTION_PATH=/home/github/66133989777/actions/Swatinem-rust-cache@779680da715d629ac1d338a641029a2f4372abb5 "${CURRENT_ENV[@]}" INPUT_SAVE-IF="$(/home/github/66133989777/helpers/eval_expression s:refs/heads/mini-optimize o:== s:refs/heads/main)" INPUT_PREFIX-KEY=v0-rust INPUT_ADD-JOB-ID-KEY=true INPUT_ADD-RUST-ENVIRONMENT-HASH-KEY=true INPUT_CACHE-TARGETS=true INPUT_CACHE-ALL-CRATES=false INPUT_CACHE-WORKSPACE-CRATES=false INPUT_CACHE-PROVIDER=github INPUT_CACHE-BIN=true INPUT_LOOKUP-ONLY=false \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run Swatinem/rust-cache@779680da715d629ac1d338a641029a2f4372abb5
echo "##[endgroup]"
echo node /home/github/66133989777/actions/Swatinem-rust-cache@779680da715d629ac1d338a641029a2f4372abb5/dist/restore/index.js > /home/github/66133989777/steps/bugswarm_cmd.sh
chmod u+x /home/github/66133989777/steps/bugswarm_cmd.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=2 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=Swatinem/rust-cache GITHUB_ACTIONS=true GITHUB_ACTOR=datdenkikniet GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=mini-optimize GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/mini-optimize GITHUB_REF_NAME=mini-optimize GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=GitoxideLabs/gitoxide GITHUB_REPOSITORY_OWNER=GitoxideLabs GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=7b50a7e9235cc2b182d40895ea8272ed8998709b GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=ci GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_TERM_COLOR=always CLICOLOR=1 GITHUB_ACTION_PATH=/home/github/66133989777/actions/Swatinem-rust-cache@779680da715d629ac1d338a641029a2f4372abb5 "${CURRENT_ENV[@]}" INPUT_SAVE-IF="$(/home/github/66133989777/helpers/eval_expression s:refs/heads/mini-optimize o:== s:refs/heads/main)" INPUT_PREFIX-KEY=v0-rust INPUT_ADD-JOB-ID-KEY=true INPUT_ADD-RUST-ENVIRONMENT-HASH-KEY=true INPUT_CACHE-TARGETS=true INPUT_CACHE-ALL-CRATES=false INPUT_CACHE-WORKSPACE-CRATES=false INPUT_CACHE-PROVIDER=github INPUT_CACHE-BIN=true INPUT_LOOKUP-ONLY=false \
bash -e /home/github/66133989777/steps/bugswarm_cmd.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=2 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=Swatinem/rust-cache GITHUB_ACTIONS=true GITHUB_ACTOR=datdenkikniet GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=mini-optimize GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/mini-optimize GITHUB_REF_NAME=mini-optimize GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=GitoxideLabs/gitoxide GITHUB_REPOSITORY_OWNER=GitoxideLabs GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=7b50a7e9235cc2b182d40895ea8272ed8998709b GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=ci GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_TERM_COLOR=always CLICOLOR=1 GITHUB_ACTION_PATH=/home/github/66133989777/actions/Swatinem-rust-cache@779680da715d629ac1d338a641029a2f4372abb5 "${CURRENT_ENV[@]}" INPUT_SAVE-IF="$(/home/github/66133989777/helpers/eval_expression s:refs/heads/mini-optimize o:== s:refs/heads/main)" INPUT_PREFIX-KEY=v0-rust INPUT_ADD-JOB-ID-KEY=true INPUT_ADD-RUST-ENVIRONMENT-HASH-KEY=true INPUT_CACHE-TARGETS=true INPUT_CACHE-ALL-CRATES=false INPUT_CACHE-WORKSPACE-CRATES=false INPUT_CACHE-PROVIDER=github INPUT_CACHE-BIN=true INPUT_LOOKUP-ONLY=false \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=2 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=Swatinem/rust-cache GITHUB_ACTIONS=true GITHUB_ACTOR=datdenkikniet GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=mini-optimize GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/mini-optimize GITHUB_REF_NAME=mini-optimize GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=GitoxideLabs/gitoxide GITHUB_REPOSITORY_OWNER=GitoxideLabs GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=7b50a7e9235cc2b182d40895ea8272ed8998709b GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=ci GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_TERM_COLOR=always CLICOLOR=1 GITHUB_ACTION_PATH=/home/github/66133989777/actions/Swatinem-rust-cache@779680da715d629ac1d338a641029a2f4372abb5 "${CURRENT_ENV[@]}" INPUT_SAVE-IF="$(/home/github/66133989777/helpers/eval_expression s:refs/heads/mini-optimize o:== s:refs/heads/main)" INPUT_PREFIX-KEY=v0-rust INPUT_ADD-JOB-ID-KEY=true INPUT_ADD-RUST-ENVIRONMENT-HASH-KEY=true INPUT_CACHE-TARGETS=true INPUT_CACHE-ALL-CRATES=false INPUT_CACHE-WORKSPACE-CRATES=false INPUT_CACHE-PROVIDER=github INPUT_CACHE-BIN=true INPUT_LOOKUP-ONLY=false \
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=3 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=datdenkikniet GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=mini-optimize GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/mini-optimize GITHUB_REF_NAME=mini-optimize GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=GitoxideLabs/gitoxide GITHUB_REPOSITORY_OWNER=GitoxideLabs GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=7b50a7e9235cc2b182d40895ea8272ed8998709b GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=ci GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_TERM_COLOR=always CLICOLOR=1 "${CURRENT_ENV[@]}" \
echo "$(/home/github/66133989777/helpers/eval_expression p:'(' f:success p:'(' p:')' p:')' o:'&&' p:'(' f:startsWith p:'(' s:ubuntu-24.04-arm s:windows p:')' p:')')")
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=3 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=datdenkikniet GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=mini-optimize GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/mini-optimize GITHUB_REF_NAME=mini-optimize GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=GitoxideLabs/gitoxide GITHUB_REPOSITORY_OWNER=GitoxideLabs GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=7b50a7e9235cc2b182d40895ea8272ed8998709b GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=ci GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_TERM_COLOR=always CLICOLOR=1 "${CURRENT_ENV[@]}" \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run 'cargo check --workspace --bins --examples'
echo "##[endgroup]"
echo 'cargo check --workspace --bins --examples' > /home/github/66133989777/steps/bugswarm_3.sh
chmod u+x /home/github/66133989777/steps/bugswarm_3.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=3 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=datdenkikniet GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=mini-optimize GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/mini-optimize GITHUB_REF_NAME=mini-optimize GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=GitoxideLabs/gitoxide GITHUB_REPOSITORY_OWNER=GitoxideLabs GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=7b50a7e9235cc2b182d40895ea8272ed8998709b GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=ci GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_TERM_COLOR=always CLICOLOR=1 "${CURRENT_ENV[@]}" \
bash -e /home/github/66133989777/steps/bugswarm_3.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=3 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=datdenkikniet GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=mini-optimize GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/mini-optimize GITHUB_REF_NAME=mini-optimize GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=GitoxideLabs/gitoxide GITHUB_REPOSITORY_OWNER=GitoxideLabs GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=7b50a7e9235cc2b182d40895ea8272ed8998709b GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=ci GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_TERM_COLOR=always CLICOLOR=1 "${CURRENT_ENV[@]}" \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=3 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=datdenkikniet GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=mini-optimize GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/mini-optimize GITHUB_REF_NAME=mini-optimize GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=GitoxideLabs/gitoxide GITHUB_REPOSITORY_OWNER=GitoxideLabs GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=7b50a7e9235cc2b182d40895ea8272ed8998709b GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=ci GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_TERM_COLOR=always CLICOLOR=1 "${CURRENT_ENV[@]}" \
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=4 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=taiki-e/install-action GITHUB_ACTIONS=true GITHUB_ACTOR=datdenkikniet GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=mini-optimize GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/mini-optimize GITHUB_REF_NAME=mini-optimize GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=GitoxideLabs/gitoxide GITHUB_REPOSITORY_OWNER=GitoxideLabs GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=7b50a7e9235cc2b182d40895ea8272ed8998709b GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=ci GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_TERM_COLOR=always CLICOLOR=1 GITHUB_ACTION_PATH=/home/github/66133989777/actions/taiki-e-install-action@cc33365ec7e3350bc47bf935f247582cc6f68344 "${CURRENT_ENV[@]}" INPUT_TOOL=nextest INPUT_CHECKSUM=true INPUT_FALLBACK=cargo-binstall \
echo $(test "$_GITHUB_JOB_STATUS" = "success" && echo true || echo false))
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=4 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=taiki-e/install-action GITHUB_ACTIONS=true GITHUB_ACTOR=datdenkikniet GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=mini-optimize GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/mini-optimize GITHUB_REF_NAME=mini-optimize GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=GitoxideLabs/gitoxide GITHUB_REPOSITORY_OWNER=GitoxideLabs GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=7b50a7e9235cc2b182d40895ea8272ed8998709b GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=ci GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_TERM_COLOR=always CLICOLOR=1 GITHUB_ACTION_PATH=/home/github/66133989777/actions/taiki-e-install-action@cc33365ec7e3350bc47bf935f247582cc6f68344 "${CURRENT_ENV[@]}" INPUT_TOOL=nextest INPUT_CHECKSUM=true INPUT_FALLBACK=cargo-binstall \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run taiki-e/install-action@cc33365ec7e3350bc47bf935f247582cc6f68344
echo "##[endgroup]"
echo /home/github/66133989777/steps/bugswarm_4_composite.sh > /home/github/66133989777/steps/bugswarm_4.sh
chmod u+x /home/github/66133989777/steps/bugswarm_4.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=4 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=taiki-e/install-action GITHUB_ACTIONS=true GITHUB_ACTOR=datdenkikniet GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=mini-optimize GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/mini-optimize GITHUB_REF_NAME=mini-optimize GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=GitoxideLabs/gitoxide GITHUB_REPOSITORY_OWNER=GitoxideLabs GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=7b50a7e9235cc2b182d40895ea8272ed8998709b GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=ci GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_TERM_COLOR=always CLICOLOR=1 GITHUB_ACTION_PATH=/home/github/66133989777/actions/taiki-e-install-action@cc33365ec7e3350bc47bf935f247582cc6f68344 "${CURRENT_ENV[@]}" INPUT_TOOL=nextest INPUT_CHECKSUM=true INPUT_FALLBACK=cargo-binstall \
bash -e /home/github/66133989777/steps/bugswarm_4.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=4 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=taiki-e/install-action GITHUB_ACTIONS=true GITHUB_ACTOR=datdenkikniet GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=mini-optimize GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/mini-optimize GITHUB_REF_NAME=mini-optimize GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=GitoxideLabs/gitoxide GITHUB_REPOSITORY_OWNER=GitoxideLabs GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=7b50a7e9235cc2b182d40895ea8272ed8998709b GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=ci GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_TERM_COLOR=always CLICOLOR=1 GITHUB_ACTION_PATH=/home/github/66133989777/actions/taiki-e-install-action@cc33365ec7e3350bc47bf935f247582cc6f68344 "${CURRENT_ENV[@]}" INPUT_TOOL=nextest INPUT_CHECKSUM=true INPUT_FALLBACK=cargo-binstall \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=4 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=taiki-e/install-action GITHUB_ACTIONS=true GITHUB_ACTOR=datdenkikniet GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=mini-optimize GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/mini-optimize GITHUB_REF_NAME=mini-optimize GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=GitoxideLabs/gitoxide GITHUB_REPOSITORY_OWNER=GitoxideLabs GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=7b50a7e9235cc2b182d40895ea8272ed8998709b GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=ci GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_TERM_COLOR=always CLICOLOR=1 GITHUB_ACTION_PATH=/home/github/66133989777/actions/taiki-e-install-action@cc33365ec7e3350bc47bf935f247582cc6f68344 "${CURRENT_ENV[@]}" INPUT_TOOL=nextest INPUT_CHECKSUM=true INPUT_FALLBACK=cargo-binstall \
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=5 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=datdenkikniet GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=mini-optimize GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/mini-optimize GITHUB_REF_NAME=mini-optimize GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=GitoxideLabs/gitoxide GITHUB_REPOSITORY_OWNER=GitoxideLabs GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=7b50a7e9235cc2b182d40895ea8272ed8998709b GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=ci GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_TERM_COLOR=always CLICOLOR=1 "${CURRENT_ENV[@]}" GIX_TEST_CREATE_ARCHIVES_EVEN_ON_CI=1 \
echo $(test "$_GITHUB_JOB_STATUS" = "success" && echo true || echo false))
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=5 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=datdenkikniet GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=mini-optimize GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/mini-optimize GITHUB_REF_NAME=mini-optimize GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=GitoxideLabs/gitoxide GITHUB_REPOSITORY_OWNER=GitoxideLabs GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=7b50a7e9235cc2b182d40895ea8272ed8998709b GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=ci GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_TERM_COLOR=always CLICOLOR=1 "${CURRENT_ENV[@]}" GIX_TEST_CREATE_ARCHIVES_EVEN_ON_CI=1 \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run 'cargo nextest run --workspace --no-fail-fast --exclude gix-error -- '
echo "##[endgroup]"
echo 'cargo nextest run --workspace --no-fail-fast --exclude gix-error -- 
' > /home/github/66133989777/steps/bugswarm_5.sh
chmod u+x /home/github/66133989777/steps/bugswarm_5.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=5 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=datdenkikniet GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=mini-optimize GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/mini-optimize GITHUB_REF_NAME=mini-optimize GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=GitoxideLabs/gitoxide GITHUB_REPOSITORY_OWNER=GitoxideLabs GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=7b50a7e9235cc2b182d40895ea8272ed8998709b GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=ci GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_TERM_COLOR=always CLICOLOR=1 "${CURRENT_ENV[@]}" GIX_TEST_CREATE_ARCHIVES_EVEN_ON_CI=1 \
bash -e /home/github/66133989777/steps/bugswarm_5.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=5 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=datdenkikniet GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=mini-optimize GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/mini-optimize GITHUB_REF_NAME=mini-optimize GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=GitoxideLabs/gitoxide GITHUB_REPOSITORY_OWNER=GitoxideLabs GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=7b50a7e9235cc2b182d40895ea8272ed8998709b GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=ci GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_TERM_COLOR=always CLICOLOR=1 "${CURRENT_ENV[@]}" GIX_TEST_CREATE_ARCHIVES_EVEN_ON_CI=1 \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=5 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=datdenkikniet GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=mini-optimize GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/mini-optimize GITHUB_REF_NAME=mini-optimize GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=GitoxideLabs/gitoxide GITHUB_REPOSITORY_OWNER=GitoxideLabs GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=7b50a7e9235cc2b182d40895ea8272ed8998709b GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=ci GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_TERM_COLOR=always CLICOLOR=1 "${CURRENT_ENV[@]}" GIX_TEST_CREATE_ARCHIVES_EVEN_ON_CI=1 \
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=6 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=datdenkikniet GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=mini-optimize GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/mini-optimize GITHUB_REF_NAME=mini-optimize GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=GitoxideLabs/gitoxide GITHUB_REPOSITORY_OWNER=GitoxideLabs GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=7b50a7e9235cc2b182d40895ea8272ed8998709b GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=ci GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_TERM_COLOR=always CLICOLOR=1 "${CURRENT_ENV[@]}" \
echo $(test "$_GITHUB_JOB_STATUS" = "success" && echo true || echo false))
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=6 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=datdenkikniet GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=mini-optimize GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/mini-optimize GITHUB_REF_NAME=mini-optimize GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=GitoxideLabs/gitoxide GITHUB_REPOSITORY_OWNER=GitoxideLabs GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=7b50a7e9235cc2b182d40895ea8272ed8998709b GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=ci GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_TERM_COLOR=always CLICOLOR=1 "${CURRENT_ENV[@]}" \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run '# If this fails, the fix is usually to commit a regenerated archive.'
echo "##[endgroup]"
echo '# If this fails, the fix is usually to commit a regenerated archive.
git diff --exit-code
' > /home/github/66133989777/steps/bugswarm_6.sh
chmod u+x /home/github/66133989777/steps/bugswarm_6.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=6 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=datdenkikniet GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=mini-optimize GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/mini-optimize GITHUB_REF_NAME=mini-optimize GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=GitoxideLabs/gitoxide GITHUB_REPOSITORY_OWNER=GitoxideLabs GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=7b50a7e9235cc2b182d40895ea8272ed8998709b GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=ci GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_TERM_COLOR=always CLICOLOR=1 "${CURRENT_ENV[@]}" \
bash -e /home/github/66133989777/steps/bugswarm_6.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=6 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=datdenkikniet GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=mini-optimize GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/mini-optimize GITHUB_REF_NAME=mini-optimize GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=GitoxideLabs/gitoxide GITHUB_REPOSITORY_OWNER=GitoxideLabs GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=7b50a7e9235cc2b182d40895ea8272ed8998709b GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=ci GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_TERM_COLOR=always CLICOLOR=1 "${CURRENT_ENV[@]}" \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=6 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=datdenkikniet GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=mini-optimize GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/mini-optimize GITHUB_REF_NAME=mini-optimize GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=GitoxideLabs/gitoxide GITHUB_REPOSITORY_OWNER=GitoxideLabs GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=7b50a7e9235cc2b182d40895ea8272ed8998709b GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=ci GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_TERM_COLOR=always CLICOLOR=1 "${CURRENT_ENV[@]}" \
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=7 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=datdenkikniet GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=mini-optimize GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/mini-optimize GITHUB_REF_NAME=mini-optimize GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=GitoxideLabs/gitoxide GITHUB_REPOSITORY_OWNER=GitoxideLabs GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=7b50a7e9235cc2b182d40895ea8272ed8998709b GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=ci GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_TERM_COLOR=always CLICOLOR=1 "${CURRENT_ENV[@]}" \
echo "$(/home/github/66133989777/helpers/eval_expression p:'(' f:success p:'(' p:')' p:')' o:'&&' p:'(' f:startsWith p:'(' s:ubuntu-24.04-arm s:windows p:')' p:')')")
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=7 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=datdenkikniet GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=mini-optimize GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/mini-optimize GITHUB_REF_NAME=mini-optimize GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=GitoxideLabs/gitoxide GITHUB_REPOSITORY_OWNER=GitoxideLabs GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=7b50a7e9235cc2b182d40895ea8272ed8998709b GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=ci GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_TERM_COLOR=always CLICOLOR=1 "${CURRENT_ENV[@]}" \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run '$prefix = '"'"'C:\Program Files\Git'"'"''
echo "##[endgroup]"
echo '$prefix = '"'"'C:\Program Files\Git'"'"'
$filtered = ($Env:PATH -split '"'"';'"'"' | Where-Object { $_ -notlike "$prefix\*" }) -join '"'"';'"'"'
Add-Content -Value "PATH=$filtered" -Path $Env:GITHUB_ENV
' > /home/github/66133989777/steps/bugswarm_7.sh
chmod u+x /home/github/66133989777/steps/bugswarm_7.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=7 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=datdenkikniet GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=mini-optimize GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/mini-optimize GITHUB_REF_NAME=mini-optimize GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=GitoxideLabs/gitoxide GITHUB_REPOSITORY_OWNER=GitoxideLabs GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=7b50a7e9235cc2b182d40895ea8272ed8998709b GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=ci GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_TERM_COLOR=always CLICOLOR=1 "${CURRENT_ENV[@]}" \
bash -e /home/github/66133989777/steps/bugswarm_7.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=7 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=datdenkikniet GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=mini-optimize GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/mini-optimize GITHUB_REF_NAME=mini-optimize GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=GitoxideLabs/gitoxide GITHUB_REPOSITORY_OWNER=GitoxideLabs GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=7b50a7e9235cc2b182d40895ea8272ed8998709b GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=ci GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_TERM_COLOR=always CLICOLOR=1 "${CURRENT_ENV[@]}" \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=7 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=datdenkikniet GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=mini-optimize GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/mini-optimize GITHUB_REF_NAME=mini-optimize GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=GitoxideLabs/gitoxide GITHUB_REPOSITORY_OWNER=GitoxideLabs GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=7b50a7e9235cc2b182d40895ea8272ed8998709b GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=ci GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_TERM_COLOR=always CLICOLOR=1 "${CURRENT_ENV[@]}" \
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=8 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=datdenkikniet GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=mini-optimize GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/mini-optimize GITHUB_REF_NAME=mini-optimize GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=GitoxideLabs/gitoxide GITHUB_REPOSITORY_OWNER=GitoxideLabs GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=7b50a7e9235cc2b182d40895ea8272ed8998709b GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=ci GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_TERM_COLOR=always CLICOLOR=1 "${CURRENT_ENV[@]}" \
echo "$(/home/github/66133989777/helpers/eval_expression p:'(' f:success p:'(' p:')' p:')' o:'&&' p:'(' f:startsWith p:'(' s:ubuntu-24.04-arm s:windows p:')' p:')')")
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=8 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=datdenkikniet GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=mini-optimize GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/mini-optimize GITHUB_REF_NAME=mini-optimize GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=GitoxideLabs/gitoxide GITHUB_REPOSITORY_OWNER=GitoxideLabs GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=7b50a7e9235cc2b182d40895ea8272ed8998709b GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=ci GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_TERM_COLOR=always CLICOLOR=1 "${CURRENT_ENV[@]}" \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run '$git = Get-Command git -ErrorAction SilentlyContinue'
echo "##[endgroup]"
echo '$git = Get-Command git -ErrorAction SilentlyContinue
if ($null -eq $git) { exit 0 } else { exit 1 }
' > /home/github/66133989777/steps/bugswarm_8.sh
chmod u+x /home/github/66133989777/steps/bugswarm_8.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=8 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=datdenkikniet GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=mini-optimize GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/mini-optimize GITHUB_REF_NAME=mini-optimize GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=GitoxideLabs/gitoxide GITHUB_REPOSITORY_OWNER=GitoxideLabs GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=7b50a7e9235cc2b182d40895ea8272ed8998709b GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=ci GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_TERM_COLOR=always CLICOLOR=1 "${CURRENT_ENV[@]}" \
bash -e /home/github/66133989777/steps/bugswarm_8.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=8 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=datdenkikniet GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=mini-optimize GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/mini-optimize GITHUB_REF_NAME=mini-optimize GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=GitoxideLabs/gitoxide GITHUB_REPOSITORY_OWNER=GitoxideLabs GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=7b50a7e9235cc2b182d40895ea8272ed8998709b GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=ci GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_TERM_COLOR=always CLICOLOR=1 "${CURRENT_ENV[@]}" \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=8 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=datdenkikniet GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=mini-optimize GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/mini-optimize GITHUB_REF_NAME=mini-optimize GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=GitoxideLabs/gitoxide GITHUB_REPOSITORY_OWNER=GitoxideLabs GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=7b50a7e9235cc2b182d40895ea8272ed8998709b GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=ci GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_TERM_COLOR=always CLICOLOR=1 "${CURRENT_ENV[@]}" \
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=9 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=datdenkikniet GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=mini-optimize GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/mini-optimize GITHUB_REF_NAME=mini-optimize GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=GitoxideLabs/gitoxide GITHUB_REPOSITORY_OWNER=GitoxideLabs GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=7b50a7e9235cc2b182d40895ea8272ed8998709b GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=ci GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_TERM_COLOR=always CLICOLOR=1 "${CURRENT_ENV[@]}" \
echo "$(/home/github/66133989777/helpers/eval_expression p:'(' f:success p:'(' p:')' p:')' o:'&&' p:'(' f:startsWith p:'(' s:ubuntu-24.04-arm s:windows p:')' p:')')")
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=9 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=datdenkikniet GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=mini-optimize GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/mini-optimize GITHUB_REF_NAME=mini-optimize GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=GitoxideLabs/gitoxide GITHUB_REPOSITORY_OWNER=GitoxideLabs GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=7b50a7e9235cc2b182d40895ea8272ed8998709b GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=ci GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_TERM_COLOR=always CLICOLOR=1 "${CURRENT_ENV[@]}" \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run 'if ($null -eq $Env:EXEPATH) { exit 0 } else { exit 1 }'
echo "##[endgroup]"
echo 'if ($null -eq $Env:EXEPATH) { exit 0 } else { exit 1 }' > /home/github/66133989777/steps/bugswarm_9.sh
chmod u+x /home/github/66133989777/steps/bugswarm_9.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=9 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=datdenkikniet GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=mini-optimize GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/mini-optimize GITHUB_REF_NAME=mini-optimize GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=GitoxideLabs/gitoxide GITHUB_REPOSITORY_OWNER=GitoxideLabs GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=7b50a7e9235cc2b182d40895ea8272ed8998709b GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=ci GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_TERM_COLOR=always CLICOLOR=1 "${CURRENT_ENV[@]}" \
bash -e /home/github/66133989777/steps/bugswarm_9.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=9 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=datdenkikniet GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=mini-optimize GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/mini-optimize GITHUB_REF_NAME=mini-optimize GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=GitoxideLabs/gitoxide GITHUB_REPOSITORY_OWNER=GitoxideLabs GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=7b50a7e9235cc2b182d40895ea8272ed8998709b GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=ci GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_TERM_COLOR=always CLICOLOR=1 "${CURRENT_ENV[@]}" \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=9 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=datdenkikniet GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=mini-optimize GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/mini-optimize GITHUB_REF_NAME=mini-optimize GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=GitoxideLabs/gitoxide GITHUB_REPOSITORY_OWNER=GitoxideLabs GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=7b50a7e9235cc2b182d40895ea8272ed8998709b GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=ci GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_TERM_COLOR=always CLICOLOR=1 "${CURRENT_ENV[@]}" \
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=10 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=datdenkikniet GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=mini-optimize GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/mini-optimize GITHUB_REF_NAME=mini-optimize GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=GitoxideLabs/gitoxide GITHUB_REPOSITORY_OWNER=GitoxideLabs GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=7b50a7e9235cc2b182d40895ea8272ed8998709b GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=ci GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_TERM_COLOR=always CLICOLOR=1 "${CURRENT_ENV[@]}" TEST_ARGS= \
echo "$(/home/github/66133989777/helpers/eval_expression p:'(' f:success p:'(' p:')' p:')' o:'&&' p:'(' f:startsWith p:'(' s:ubuntu-24.04-arm s:windows p:')' p:')')")
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=10 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=datdenkikniet GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=mini-optimize GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/mini-optimize GITHUB_REF_NAME=mini-optimize GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=GitoxideLabs/gitoxide GITHUB_REPOSITORY_OWNER=GitoxideLabs GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=7b50a7e9235cc2b182d40895ea8272ed8998709b GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=ci GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_TERM_COLOR=always CLICOLOR=1 "${CURRENT_ENV[@]}" TEST_ARGS= \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run 'cargo nextest run -p gix-path --no-fail-fast -- (-split $Env:TEST_ARGS)'
echo "##[endgroup]"
echo 'cargo nextest run -p gix-path --no-fail-fast -- (-split $Env:TEST_ARGS)
' > /home/github/66133989777/steps/bugswarm_10.sh
chmod u+x /home/github/66133989777/steps/bugswarm_10.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=10 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=datdenkikniet GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=mini-optimize GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/mini-optimize GITHUB_REF_NAME=mini-optimize GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=GitoxideLabs/gitoxide GITHUB_REPOSITORY_OWNER=GitoxideLabs GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=7b50a7e9235cc2b182d40895ea8272ed8998709b GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=ci GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_TERM_COLOR=always CLICOLOR=1 "${CURRENT_ENV[@]}" TEST_ARGS= \
bash -e /home/github/66133989777/steps/bugswarm_10.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=10 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=datdenkikniet GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=mini-optimize GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/mini-optimize GITHUB_REF_NAME=mini-optimize GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=GitoxideLabs/gitoxide GITHUB_REPOSITORY_OWNER=GitoxideLabs GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=7b50a7e9235cc2b182d40895ea8272ed8998709b GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=ci GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_TERM_COLOR=always CLICOLOR=1 "${CURRENT_ENV[@]}" TEST_ARGS= \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=10 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=datdenkikniet GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=mini-optimize GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/mini-optimize GITHUB_REF_NAME=mini-optimize GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=GitoxideLabs/gitoxide GITHUB_REPOSITORY_OWNER=GitoxideLabs GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=7b50a7e9235cc2b182d40895ea8272ed8998709b GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=ci GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_TERM_COLOR=always CLICOLOR=1 "${CURRENT_ENV[@]}" TEST_ARGS= \
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
   bash -e $ACTIONS_RUNNER_HOOK_JOB_COMPLETED 66133989777 failed
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
