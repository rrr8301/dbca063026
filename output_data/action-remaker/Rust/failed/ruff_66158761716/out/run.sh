#!/usr/bin/env bash
export GITHUB_WORKSPACE=/home/github/build/astral-sh/ruff

if [[ ! -z "$ACTIONS_RUNNER_HOOK_JOB_STARTED" ]]; then
   echo "A job started hook has been configured by the self-hosted runner administrator"
   echo "##[group]Run '$ACTIONS_RUNNER_HOOK_JOB_STARTED'"
   echo "##[endgroup]"
   bash -e $ACTIONS_RUNNER_HOOK_JOB_STARTED 66158761716 failed
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

cp /home/github/66158761716/event.json /home/github/workflow/event.json
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=1 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=Swatinem/rust-cache GITHUB_ACTIONS=true GITHUB_ACTOR=Glyphack GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=shaygan-yield-type GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/shaygan-yield-type GITHUB_REF_NAME=shaygan-yield-type GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=astral-sh/ruff GITHUB_REPOSITORY_OWNER=astral-sh GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=45f11c39b1ea3ea89e83c4db3cdb7004fb707868 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_INCREMENTAL=0 CARGO_NET_RETRY=10 CARGO_TERM_COLOR=always RUSTUP_MAX_RETRIES=10 PACKAGE_NAME=ruff PYTHON_VERSION=3.14 NEXTEST_PROFILE=ci MDTEST_EXTERNAL=1 GITHUB_ACTION_PATH=/home/github/66158761716/actions/Swatinem-rust-cache@779680da715d629ac1d338a641029a2f4372abb5 "${CURRENT_ENV[@]}" INPUT_SHARED-KEY=ruff-linux-debug INPUT_SAVE-IF="$(/home/github/66158761716/helpers/eval_expression s:refs/heads/shaygan-yield-type o:== s:refs/heads/main)" INPUT_PREFIX-KEY=v0-rust INPUT_ADD-JOB-ID-KEY=true INPUT_ADD-RUST-ENVIRONMENT-HASH-KEY=true INPUT_CACHE-TARGETS=true INPUT_CACHE-ALL-CRATES=false INPUT_CACHE-WORKSPACE-CRATES=false INPUT_CACHE-PROVIDER=github INPUT_CACHE-BIN=true INPUT_LOOKUP-ONLY=false \
echo $(test "$_GITHUB_JOB_STATUS" = "success" && echo true || echo false))
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=1 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=Swatinem/rust-cache GITHUB_ACTIONS=true GITHUB_ACTOR=Glyphack GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=shaygan-yield-type GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/shaygan-yield-type GITHUB_REF_NAME=shaygan-yield-type GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=astral-sh/ruff GITHUB_REPOSITORY_OWNER=astral-sh GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=45f11c39b1ea3ea89e83c4db3cdb7004fb707868 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_INCREMENTAL=0 CARGO_NET_RETRY=10 CARGO_TERM_COLOR=always RUSTUP_MAX_RETRIES=10 PACKAGE_NAME=ruff PYTHON_VERSION=3.14 NEXTEST_PROFILE=ci MDTEST_EXTERNAL=1 GITHUB_ACTION_PATH=/home/github/66158761716/actions/Swatinem-rust-cache@779680da715d629ac1d338a641029a2f4372abb5 "${CURRENT_ENV[@]}" INPUT_SHARED-KEY=ruff-linux-debug INPUT_SAVE-IF="$(/home/github/66158761716/helpers/eval_expression s:refs/heads/shaygan-yield-type o:== s:refs/heads/main)" INPUT_PREFIX-KEY=v0-rust INPUT_ADD-JOB-ID-KEY=true INPUT_ADD-RUST-ENVIRONMENT-HASH-KEY=true INPUT_CACHE-TARGETS=true INPUT_CACHE-ALL-CRATES=false INPUT_CACHE-WORKSPACE-CRATES=false INPUT_CACHE-PROVIDER=github INPUT_CACHE-BIN=true INPUT_LOOKUP-ONLY=false \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run Swatinem/rust-cache@779680da715d629ac1d338a641029a2f4372abb5
echo "##[endgroup]"
echo node /home/github/66158761716/actions/Swatinem-rust-cache@779680da715d629ac1d338a641029a2f4372abb5/dist/restore/index.js > /home/github/66158761716/steps/bugswarm_cmd.sh
chmod u+x /home/github/66158761716/steps/bugswarm_cmd.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=1 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=Swatinem/rust-cache GITHUB_ACTIONS=true GITHUB_ACTOR=Glyphack GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=shaygan-yield-type GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/shaygan-yield-type GITHUB_REF_NAME=shaygan-yield-type GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=astral-sh/ruff GITHUB_REPOSITORY_OWNER=astral-sh GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=45f11c39b1ea3ea89e83c4db3cdb7004fb707868 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_INCREMENTAL=0 CARGO_NET_RETRY=10 CARGO_TERM_COLOR=always RUSTUP_MAX_RETRIES=10 PACKAGE_NAME=ruff PYTHON_VERSION=3.14 NEXTEST_PROFILE=ci MDTEST_EXTERNAL=1 GITHUB_ACTION_PATH=/home/github/66158761716/actions/Swatinem-rust-cache@779680da715d629ac1d338a641029a2f4372abb5 "${CURRENT_ENV[@]}" INPUT_SHARED-KEY=ruff-linux-debug INPUT_SAVE-IF="$(/home/github/66158761716/helpers/eval_expression s:refs/heads/shaygan-yield-type o:== s:refs/heads/main)" INPUT_PREFIX-KEY=v0-rust INPUT_ADD-JOB-ID-KEY=true INPUT_ADD-RUST-ENVIRONMENT-HASH-KEY=true INPUT_CACHE-TARGETS=true INPUT_CACHE-ALL-CRATES=false INPUT_CACHE-WORKSPACE-CRATES=false INPUT_CACHE-PROVIDER=github INPUT_CACHE-BIN=true INPUT_LOOKUP-ONLY=false \
bash -e /home/github/66158761716/steps/bugswarm_cmd.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=1 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=Swatinem/rust-cache GITHUB_ACTIONS=true GITHUB_ACTOR=Glyphack GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=shaygan-yield-type GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/shaygan-yield-type GITHUB_REF_NAME=shaygan-yield-type GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=astral-sh/ruff GITHUB_REPOSITORY_OWNER=astral-sh GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=45f11c39b1ea3ea89e83c4db3cdb7004fb707868 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_INCREMENTAL=0 CARGO_NET_RETRY=10 CARGO_TERM_COLOR=always RUSTUP_MAX_RETRIES=10 PACKAGE_NAME=ruff PYTHON_VERSION=3.14 NEXTEST_PROFILE=ci MDTEST_EXTERNAL=1 GITHUB_ACTION_PATH=/home/github/66158761716/actions/Swatinem-rust-cache@779680da715d629ac1d338a641029a2f4372abb5 "${CURRENT_ENV[@]}" INPUT_SHARED-KEY=ruff-linux-debug INPUT_SAVE-IF="$(/home/github/66158761716/helpers/eval_expression s:refs/heads/shaygan-yield-type o:== s:refs/heads/main)" INPUT_PREFIX-KEY=v0-rust INPUT_ADD-JOB-ID-KEY=true INPUT_ADD-RUST-ENVIRONMENT-HASH-KEY=true INPUT_CACHE-TARGETS=true INPUT_CACHE-ALL-CRATES=false INPUT_CACHE-WORKSPACE-CRATES=false INPUT_CACHE-PROVIDER=github INPUT_CACHE-BIN=true INPUT_LOOKUP-ONLY=false \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=1 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=Swatinem/rust-cache GITHUB_ACTIONS=true GITHUB_ACTOR=Glyphack GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=shaygan-yield-type GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/shaygan-yield-type GITHUB_REF_NAME=shaygan-yield-type GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=astral-sh/ruff GITHUB_REPOSITORY_OWNER=astral-sh GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=45f11c39b1ea3ea89e83c4db3cdb7004fb707868 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_INCREMENTAL=0 CARGO_NET_RETRY=10 CARGO_TERM_COLOR=always RUSTUP_MAX_RETRIES=10 PACKAGE_NAME=ruff PYTHON_VERSION=3.14 NEXTEST_PROFILE=ci MDTEST_EXTERNAL=1 GITHUB_ACTION_PATH=/home/github/66158761716/actions/Swatinem-rust-cache@779680da715d629ac1d338a641029a2f4372abb5 "${CURRENT_ENV[@]}" INPUT_SHARED-KEY=ruff-linux-debug INPUT_SAVE-IF="$(/home/github/66158761716/helpers/eval_expression s:refs/heads/shaygan-yield-type o:== s:refs/heads/main)" INPUT_PREFIX-KEY=v0-rust INPUT_ADD-JOB-ID-KEY=true INPUT_ADD-RUST-ENVIRONMENT-HASH-KEY=true INPUT_CACHE-TARGETS=true INPUT_CACHE-ALL-CRATES=false INPUT_CACHE-WORKSPACE-CRATES=false INPUT_CACHE-PROVIDER=github INPUT_CACHE-BIN=true INPUT_LOOKUP-ONLY=false \
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=2 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=Glyphack GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=shaygan-yield-type GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/shaygan-yield-type GITHUB_REF_NAME=shaygan-yield-type GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=astral-sh/ruff GITHUB_REPOSITORY_OWNER=astral-sh GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=45f11c39b1ea3ea89e83c4db3cdb7004fb707868 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_INCREMENTAL=0 CARGO_NET_RETRY=10 CARGO_TERM_COLOR=always RUSTUP_MAX_RETRIES=10 PACKAGE_NAME=ruff PYTHON_VERSION=3.14 NEXTEST_PROFILE=ci MDTEST_EXTERNAL=1 "${CURRENT_ENV[@]}" \
echo $(test "$_GITHUB_JOB_STATUS" = "success" && echo true || echo false))
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=2 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=Glyphack GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=shaygan-yield-type GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/shaygan-yield-type GITHUB_REF_NAME=shaygan-yield-type GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=astral-sh/ruff GITHUB_REPOSITORY_OWNER=astral-sh GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=45f11c39b1ea3ea89e83c4db3cdb7004fb707868 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_INCREMENTAL=0 CARGO_NET_RETRY=10 CARGO_TERM_COLOR=always RUSTUP_MAX_RETRIES=10 PACKAGE_NAME=ruff PYTHON_VERSION=3.14 NEXTEST_PROFILE=ci MDTEST_EXTERNAL=1 "${CURRENT_ENV[@]}" \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run 'rustup show'
echo "##[endgroup]"
echo 'rustup show' > /home/github/66158761716/steps/bugswarm_2.sh
chmod u+x /home/github/66158761716/steps/bugswarm_2.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=2 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=Glyphack GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=shaygan-yield-type GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/shaygan-yield-type GITHUB_REF_NAME=shaygan-yield-type GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=astral-sh/ruff GITHUB_REPOSITORY_OWNER=astral-sh GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=45f11c39b1ea3ea89e83c4db3cdb7004fb707868 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_INCREMENTAL=0 CARGO_NET_RETRY=10 CARGO_TERM_COLOR=always RUSTUP_MAX_RETRIES=10 PACKAGE_NAME=ruff PYTHON_VERSION=3.14 NEXTEST_PROFILE=ci MDTEST_EXTERNAL=1 "${CURRENT_ENV[@]}" \
bash --noprofile --norc -eo pipefail /home/github/66158761716/steps/bugswarm_2.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=2 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=Glyphack GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=shaygan-yield-type GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/shaygan-yield-type GITHUB_REF_NAME=shaygan-yield-type GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=astral-sh/ruff GITHUB_REPOSITORY_OWNER=astral-sh GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=45f11c39b1ea3ea89e83c4db3cdb7004fb707868 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_INCREMENTAL=0 CARGO_NET_RETRY=10 CARGO_TERM_COLOR=always RUSTUP_MAX_RETRIES=10 PACKAGE_NAME=ruff PYTHON_VERSION=3.14 NEXTEST_PROFILE=ci MDTEST_EXTERNAL=1 "${CURRENT_ENV[@]}" \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=2 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=Glyphack GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=shaygan-yield-type GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/shaygan-yield-type GITHUB_REF_NAME=shaygan-yield-type GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=astral-sh/ruff GITHUB_REPOSITORY_OWNER=astral-sh GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=45f11c39b1ea3ea89e83c4db3cdb7004fb707868 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_INCREMENTAL=0 CARGO_NET_RETRY=10 CARGO_TERM_COLOR=always RUSTUP_MAX_RETRIES=10 PACKAGE_NAME=ruff PYTHON_VERSION=3.14 NEXTEST_PROFILE=ci MDTEST_EXTERNAL=1 "${CURRENT_ENV[@]}" \
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=3 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=rui314/setup-mold GITHUB_ACTIONS=true GITHUB_ACTOR=Glyphack GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=shaygan-yield-type GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/shaygan-yield-type GITHUB_REF_NAME=shaygan-yield-type GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=astral-sh/ruff GITHUB_REPOSITORY_OWNER=astral-sh GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=45f11c39b1ea3ea89e83c4db3cdb7004fb707868 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_INCREMENTAL=0 CARGO_NET_RETRY=10 CARGO_TERM_COLOR=always RUSTUP_MAX_RETRIES=10 PACKAGE_NAME=ruff PYTHON_VERSION=3.14 NEXTEST_PROFILE=ci MDTEST_EXTERNAL=1 GITHUB_ACTION_PATH=/home/github/66158761716/actions/rui314-setup-mold@725a8794d15fc7563f59595bd9556495c0564878 "${CURRENT_ENV[@]}" INPUT_MOLD-VERSION=2.40.4 INPUT_MAKE-DEFAULT=true \
echo $(test "$_GITHUB_JOB_STATUS" = "success" && echo true || echo false))
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=3 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=rui314/setup-mold GITHUB_ACTIONS=true GITHUB_ACTOR=Glyphack GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=shaygan-yield-type GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/shaygan-yield-type GITHUB_REF_NAME=shaygan-yield-type GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=astral-sh/ruff GITHUB_REPOSITORY_OWNER=astral-sh GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=45f11c39b1ea3ea89e83c4db3cdb7004fb707868 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_INCREMENTAL=0 CARGO_NET_RETRY=10 CARGO_TERM_COLOR=always RUSTUP_MAX_RETRIES=10 PACKAGE_NAME=ruff PYTHON_VERSION=3.14 NEXTEST_PROFILE=ci MDTEST_EXTERNAL=1 GITHUB_ACTION_PATH=/home/github/66158761716/actions/rui314-setup-mold@725a8794d15fc7563f59595bd9556495c0564878 "${CURRENT_ENV[@]}" INPUT_MOLD-VERSION=2.40.4 INPUT_MAKE-DEFAULT=true \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run rui314/setup-mold@725a8794d15fc7563f59595bd9556495c0564878
echo "##[endgroup]"
echo /home/github/66158761716/steps/bugswarm_3_composite.sh > /home/github/66158761716/steps/bugswarm_3.sh
chmod u+x /home/github/66158761716/steps/bugswarm_3.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=3 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=rui314/setup-mold GITHUB_ACTIONS=true GITHUB_ACTOR=Glyphack GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=shaygan-yield-type GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/shaygan-yield-type GITHUB_REF_NAME=shaygan-yield-type GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=astral-sh/ruff GITHUB_REPOSITORY_OWNER=astral-sh GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=45f11c39b1ea3ea89e83c4db3cdb7004fb707868 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_INCREMENTAL=0 CARGO_NET_RETRY=10 CARGO_TERM_COLOR=always RUSTUP_MAX_RETRIES=10 PACKAGE_NAME=ruff PYTHON_VERSION=3.14 NEXTEST_PROFILE=ci MDTEST_EXTERNAL=1 GITHUB_ACTION_PATH=/home/github/66158761716/actions/rui314-setup-mold@725a8794d15fc7563f59595bd9556495c0564878 "${CURRENT_ENV[@]}" INPUT_MOLD-VERSION=2.40.4 INPUT_MAKE-DEFAULT=true \
bash -e /home/github/66158761716/steps/bugswarm_3.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=3 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=rui314/setup-mold GITHUB_ACTIONS=true GITHUB_ACTOR=Glyphack GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=shaygan-yield-type GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/shaygan-yield-type GITHUB_REF_NAME=shaygan-yield-type GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=astral-sh/ruff GITHUB_REPOSITORY_OWNER=astral-sh GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=45f11c39b1ea3ea89e83c4db3cdb7004fb707868 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_INCREMENTAL=0 CARGO_NET_RETRY=10 CARGO_TERM_COLOR=always RUSTUP_MAX_RETRIES=10 PACKAGE_NAME=ruff PYTHON_VERSION=3.14 NEXTEST_PROFILE=ci MDTEST_EXTERNAL=1 GITHUB_ACTION_PATH=/home/github/66158761716/actions/rui314-setup-mold@725a8794d15fc7563f59595bd9556495c0564878 "${CURRENT_ENV[@]}" INPUT_MOLD-VERSION=2.40.4 INPUT_MAKE-DEFAULT=true \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=3 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=rui314/setup-mold GITHUB_ACTIONS=true GITHUB_ACTOR=Glyphack GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=shaygan-yield-type GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/shaygan-yield-type GITHUB_REF_NAME=shaygan-yield-type GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=astral-sh/ruff GITHUB_REPOSITORY_OWNER=astral-sh GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=45f11c39b1ea3ea89e83c4db3cdb7004fb707868 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_INCREMENTAL=0 CARGO_NET_RETRY=10 CARGO_TERM_COLOR=always RUSTUP_MAX_RETRIES=10 PACKAGE_NAME=ruff PYTHON_VERSION=3.14 NEXTEST_PROFILE=ci MDTEST_EXTERNAL=1 GITHUB_ACTION_PATH=/home/github/66158761716/actions/rui314-setup-mold@725a8794d15fc7563f59595bd9556495c0564878 "${CURRENT_ENV[@]}" INPUT_MOLD-VERSION=2.40.4 INPUT_MAKE-DEFAULT=true \
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=4 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=taiki-e/install-action GITHUB_ACTIONS=true GITHUB_ACTOR=Glyphack GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=shaygan-yield-type GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/shaygan-yield-type GITHUB_REF_NAME=shaygan-yield-type GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=astral-sh/ruff GITHUB_REPOSITORY_OWNER=astral-sh GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=45f11c39b1ea3ea89e83c4db3cdb7004fb707868 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_INCREMENTAL=0 CARGO_NET_RETRY=10 CARGO_TERM_COLOR=always RUSTUP_MAX_RETRIES=10 PACKAGE_NAME=ruff PYTHON_VERSION=3.14 NEXTEST_PROFILE=ci MDTEST_EXTERNAL=1 GITHUB_ACTION_PATH=/home/github/66158761716/actions/taiki-e-install-action@cfdb446e391c69574ebc316dfb7d7849ec12b940 "${CURRENT_ENV[@]}" INPUT_TOOL=cargo-nextest INPUT_CHECKSUM=true INPUT_FALLBACK=cargo-binstall \
echo $(test "$_GITHUB_JOB_STATUS" = "success" && echo true || echo false))
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=4 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=taiki-e/install-action GITHUB_ACTIONS=true GITHUB_ACTOR=Glyphack GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=shaygan-yield-type GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/shaygan-yield-type GITHUB_REF_NAME=shaygan-yield-type GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=astral-sh/ruff GITHUB_REPOSITORY_OWNER=astral-sh GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=45f11c39b1ea3ea89e83c4db3cdb7004fb707868 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_INCREMENTAL=0 CARGO_NET_RETRY=10 CARGO_TERM_COLOR=always RUSTUP_MAX_RETRIES=10 PACKAGE_NAME=ruff PYTHON_VERSION=3.14 NEXTEST_PROFILE=ci MDTEST_EXTERNAL=1 GITHUB_ACTION_PATH=/home/github/66158761716/actions/taiki-e-install-action@cfdb446e391c69574ebc316dfb7d7849ec12b940 "${CURRENT_ENV[@]}" INPUT_TOOL=cargo-nextest INPUT_CHECKSUM=true INPUT_FALLBACK=cargo-binstall \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run taiki-e/install-action@cfdb446e391c69574ebc316dfb7d7849ec12b940
echo "##[endgroup]"
echo /home/github/66158761716/steps/bugswarm_4_composite.sh > /home/github/66158761716/steps/bugswarm_4.sh
chmod u+x /home/github/66158761716/steps/bugswarm_4.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=4 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=taiki-e/install-action GITHUB_ACTIONS=true GITHUB_ACTOR=Glyphack GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=shaygan-yield-type GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/shaygan-yield-type GITHUB_REF_NAME=shaygan-yield-type GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=astral-sh/ruff GITHUB_REPOSITORY_OWNER=astral-sh GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=45f11c39b1ea3ea89e83c4db3cdb7004fb707868 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_INCREMENTAL=0 CARGO_NET_RETRY=10 CARGO_TERM_COLOR=always RUSTUP_MAX_RETRIES=10 PACKAGE_NAME=ruff PYTHON_VERSION=3.14 NEXTEST_PROFILE=ci MDTEST_EXTERNAL=1 GITHUB_ACTION_PATH=/home/github/66158761716/actions/taiki-e-install-action@cfdb446e391c69574ebc316dfb7d7849ec12b940 "${CURRENT_ENV[@]}" INPUT_TOOL=cargo-nextest INPUT_CHECKSUM=true INPUT_FALLBACK=cargo-binstall \
bash -e /home/github/66158761716/steps/bugswarm_4.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=4 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=taiki-e/install-action GITHUB_ACTIONS=true GITHUB_ACTOR=Glyphack GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=shaygan-yield-type GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/shaygan-yield-type GITHUB_REF_NAME=shaygan-yield-type GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=astral-sh/ruff GITHUB_REPOSITORY_OWNER=astral-sh GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=45f11c39b1ea3ea89e83c4db3cdb7004fb707868 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_INCREMENTAL=0 CARGO_NET_RETRY=10 CARGO_TERM_COLOR=always RUSTUP_MAX_RETRIES=10 PACKAGE_NAME=ruff PYTHON_VERSION=3.14 NEXTEST_PROFILE=ci MDTEST_EXTERNAL=1 GITHUB_ACTION_PATH=/home/github/66158761716/actions/taiki-e-install-action@cfdb446e391c69574ebc316dfb7d7849ec12b940 "${CURRENT_ENV[@]}" INPUT_TOOL=cargo-nextest INPUT_CHECKSUM=true INPUT_FALLBACK=cargo-binstall \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=4 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=taiki-e/install-action GITHUB_ACTIONS=true GITHUB_ACTOR=Glyphack GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=shaygan-yield-type GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/shaygan-yield-type GITHUB_REF_NAME=shaygan-yield-type GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=astral-sh/ruff GITHUB_REPOSITORY_OWNER=astral-sh GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=45f11c39b1ea3ea89e83c4db3cdb7004fb707868 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_INCREMENTAL=0 CARGO_NET_RETRY=10 CARGO_TERM_COLOR=always RUSTUP_MAX_RETRIES=10 PACKAGE_NAME=ruff PYTHON_VERSION=3.14 NEXTEST_PROFILE=ci MDTEST_EXTERNAL=1 GITHUB_ACTION_PATH=/home/github/66158761716/actions/taiki-e-install-action@cfdb446e391c69574ebc316dfb7d7849ec12b940 "${CURRENT_ENV[@]}" INPUT_TOOL=cargo-nextest INPUT_CHECKSUM=true INPUT_FALLBACK=cargo-binstall \
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=5 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=taiki-e/install-action GITHUB_ACTIONS=true GITHUB_ACTOR=Glyphack GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=shaygan-yield-type GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/shaygan-yield-type GITHUB_REF_NAME=shaygan-yield-type GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=astral-sh/ruff GITHUB_REPOSITORY_OWNER=astral-sh GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=45f11c39b1ea3ea89e83c4db3cdb7004fb707868 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_INCREMENTAL=0 CARGO_NET_RETRY=10 CARGO_TERM_COLOR=always RUSTUP_MAX_RETRIES=10 PACKAGE_NAME=ruff PYTHON_VERSION=3.14 NEXTEST_PROFILE=ci MDTEST_EXTERNAL=1 GITHUB_ACTION_PATH=/home/github/66158761716/actions/taiki-e-install-action@cfdb446e391c69574ebc316dfb7d7849ec12b940 "${CURRENT_ENV[@]}" INPUT_TOOL=cargo-insta INPUT_CHECKSUM=true INPUT_FALLBACK=cargo-binstall \
echo $(test "$_GITHUB_JOB_STATUS" = "success" && echo true || echo false))
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=5 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=taiki-e/install-action GITHUB_ACTIONS=true GITHUB_ACTOR=Glyphack GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=shaygan-yield-type GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/shaygan-yield-type GITHUB_REF_NAME=shaygan-yield-type GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=astral-sh/ruff GITHUB_REPOSITORY_OWNER=astral-sh GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=45f11c39b1ea3ea89e83c4db3cdb7004fb707868 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_INCREMENTAL=0 CARGO_NET_RETRY=10 CARGO_TERM_COLOR=always RUSTUP_MAX_RETRIES=10 PACKAGE_NAME=ruff PYTHON_VERSION=3.14 NEXTEST_PROFILE=ci MDTEST_EXTERNAL=1 GITHUB_ACTION_PATH=/home/github/66158761716/actions/taiki-e-install-action@cfdb446e391c69574ebc316dfb7d7849ec12b940 "${CURRENT_ENV[@]}" INPUT_TOOL=cargo-insta INPUT_CHECKSUM=true INPUT_FALLBACK=cargo-binstall \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run taiki-e/install-action@cfdb446e391c69574ebc316dfb7d7849ec12b940
echo "##[endgroup]"
echo /home/github/66158761716/steps/bugswarm_5_composite.sh > /home/github/66158761716/steps/bugswarm_5.sh
chmod u+x /home/github/66158761716/steps/bugswarm_5.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=5 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=taiki-e/install-action GITHUB_ACTIONS=true GITHUB_ACTOR=Glyphack GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=shaygan-yield-type GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/shaygan-yield-type GITHUB_REF_NAME=shaygan-yield-type GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=astral-sh/ruff GITHUB_REPOSITORY_OWNER=astral-sh GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=45f11c39b1ea3ea89e83c4db3cdb7004fb707868 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_INCREMENTAL=0 CARGO_NET_RETRY=10 CARGO_TERM_COLOR=always RUSTUP_MAX_RETRIES=10 PACKAGE_NAME=ruff PYTHON_VERSION=3.14 NEXTEST_PROFILE=ci MDTEST_EXTERNAL=1 GITHUB_ACTION_PATH=/home/github/66158761716/actions/taiki-e-install-action@cfdb446e391c69574ebc316dfb7d7849ec12b940 "${CURRENT_ENV[@]}" INPUT_TOOL=cargo-insta INPUT_CHECKSUM=true INPUT_FALLBACK=cargo-binstall \
bash -e /home/github/66158761716/steps/bugswarm_5.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=5 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=taiki-e/install-action GITHUB_ACTIONS=true GITHUB_ACTOR=Glyphack GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=shaygan-yield-type GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/shaygan-yield-type GITHUB_REF_NAME=shaygan-yield-type GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=astral-sh/ruff GITHUB_REPOSITORY_OWNER=astral-sh GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=45f11c39b1ea3ea89e83c4db3cdb7004fb707868 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_INCREMENTAL=0 CARGO_NET_RETRY=10 CARGO_TERM_COLOR=always RUSTUP_MAX_RETRIES=10 PACKAGE_NAME=ruff PYTHON_VERSION=3.14 NEXTEST_PROFILE=ci MDTEST_EXTERNAL=1 GITHUB_ACTION_PATH=/home/github/66158761716/actions/taiki-e-install-action@cfdb446e391c69574ebc316dfb7d7849ec12b940 "${CURRENT_ENV[@]}" INPUT_TOOL=cargo-insta INPUT_CHECKSUM=true INPUT_FALLBACK=cargo-binstall \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=5 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=taiki-e/install-action GITHUB_ACTIONS=true GITHUB_ACTOR=Glyphack GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=shaygan-yield-type GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/shaygan-yield-type GITHUB_REF_NAME=shaygan-yield-type GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=astral-sh/ruff GITHUB_REPOSITORY_OWNER=astral-sh GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=45f11c39b1ea3ea89e83c4db3cdb7004fb707868 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_INCREMENTAL=0 CARGO_NET_RETRY=10 CARGO_TERM_COLOR=always RUSTUP_MAX_RETRIES=10 PACKAGE_NAME=ruff PYTHON_VERSION=3.14 NEXTEST_PROFILE=ci MDTEST_EXTERNAL=1 GITHUB_ACTION_PATH=/home/github/66158761716/actions/taiki-e-install-action@cfdb446e391c69574ebc316dfb7d7849ec12b940 "${CURRENT_ENV[@]}" INPUT_TOOL=cargo-insta INPUT_CHECKSUM=true INPUT_FALLBACK=cargo-binstall \
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=6 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=astral-sh/setup-uv GITHUB_ACTIONS=true GITHUB_ACTOR=Glyphack GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=shaygan-yield-type GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/shaygan-yield-type GITHUB_REF_NAME=shaygan-yield-type GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=astral-sh/ruff GITHUB_REPOSITORY_OWNER=astral-sh GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=45f11c39b1ea3ea89e83c4db3cdb7004fb707868 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_INCREMENTAL=0 CARGO_NET_RETRY=10 CARGO_TERM_COLOR=always RUSTUP_MAX_RETRIES=10 PACKAGE_NAME=ruff PYTHON_VERSION=3.14 NEXTEST_PROFILE=ci MDTEST_EXTERNAL=1 GITHUB_ACTION_PATH=/home/github/66158761716/actions/astral-sh-setup-uv@5a095e7a2014a4212f075830d4f7277575a9d098 "${CURRENT_ENV[@]}" INPUT_VERSION=0.10.7 INPUT_ENABLE-CACHE=true INPUT_VERSION-FILE= INPUT_ACTIVATE-ENVIRONMENT=false INPUT_VENV-PATH= INPUT_WORKING-DIRECTORY=${GITHUB_WORKSPACE} INPUT_GITHUB-TOKEN=DUMMY INPUT_CACHE-DEPENDENCY-GLOB='**/*requirements*.txt
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
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=6 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=astral-sh/setup-uv GITHUB_ACTIONS=true GITHUB_ACTOR=Glyphack GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=shaygan-yield-type GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/shaygan-yield-type GITHUB_REF_NAME=shaygan-yield-type GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=astral-sh/ruff GITHUB_REPOSITORY_OWNER=astral-sh GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=45f11c39b1ea3ea89e83c4db3cdb7004fb707868 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_INCREMENTAL=0 CARGO_NET_RETRY=10 CARGO_TERM_COLOR=always RUSTUP_MAX_RETRIES=10 PACKAGE_NAME=ruff PYTHON_VERSION=3.14 NEXTEST_PROFILE=ci MDTEST_EXTERNAL=1 GITHUB_ACTION_PATH=/home/github/66158761716/actions/astral-sh-setup-uv@5a095e7a2014a4212f075830d4f7277575a9d098 "${CURRENT_ENV[@]}" INPUT_VERSION=0.10.7 INPUT_ENABLE-CACHE=true INPUT_VERSION-FILE= INPUT_ACTIVATE-ENVIRONMENT=false INPUT_VENV-PATH= INPUT_WORKING-DIRECTORY=${GITHUB_WORKSPACE} INPUT_GITHUB-TOKEN=DUMMY INPUT_CACHE-DEPENDENCY-GLOB='**/*requirements*.txt
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

echo "##[group]"Run astral-sh/setup-uv@5a095e7a2014a4212f075830d4f7277575a9d098
echo "##[endgroup]"
echo node /home/github/66158761716/actions/astral-sh-setup-uv@5a095e7a2014a4212f075830d4f7277575a9d098/dist/setup/index.js > /home/github/66158761716/steps/bugswarm_cmd.sh
chmod u+x /home/github/66158761716/steps/bugswarm_cmd.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=6 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=astral-sh/setup-uv GITHUB_ACTIONS=true GITHUB_ACTOR=Glyphack GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=shaygan-yield-type GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/shaygan-yield-type GITHUB_REF_NAME=shaygan-yield-type GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=astral-sh/ruff GITHUB_REPOSITORY_OWNER=astral-sh GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=45f11c39b1ea3ea89e83c4db3cdb7004fb707868 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_INCREMENTAL=0 CARGO_NET_RETRY=10 CARGO_TERM_COLOR=always RUSTUP_MAX_RETRIES=10 PACKAGE_NAME=ruff PYTHON_VERSION=3.14 NEXTEST_PROFILE=ci MDTEST_EXTERNAL=1 GITHUB_ACTION_PATH=/home/github/66158761716/actions/astral-sh-setup-uv@5a095e7a2014a4212f075830d4f7277575a9d098 "${CURRENT_ENV[@]}" INPUT_VERSION=0.10.7 INPUT_ENABLE-CACHE=true INPUT_VERSION-FILE= INPUT_ACTIVATE-ENVIRONMENT=false INPUT_VENV-PATH= INPUT_WORKING-DIRECTORY=${GITHUB_WORKSPACE} INPUT_GITHUB-TOKEN=DUMMY INPUT_CACHE-DEPENDENCY-GLOB='**/*requirements*.txt
**/*requirements*.in
**/*constraints*.txt
**/*constraints*.in
**/pyproject.toml
**/uv.lock
**/*.py.lock
' INPUT_RESTORE-CACHE=true INPUT_SAVE-CACHE=true INPUT_CACHE-LOCAL-PATH= INPUT_PRUNE-CACHE=true INPUT_CACHE-PYTHON=false INPUT_IGNORE-NOTHING-TO-CACHE=false INPUT_IGNORE-EMPTY-WORKDIR=false INPUT_ADD-PROBLEM-MATCHERS=true INPUT_RESOLUTION-STRATEGY=highest \
bash -e /home/github/66158761716/steps/bugswarm_cmd.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=6 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=astral-sh/setup-uv GITHUB_ACTIONS=true GITHUB_ACTOR=Glyphack GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=shaygan-yield-type GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/shaygan-yield-type GITHUB_REF_NAME=shaygan-yield-type GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=astral-sh/ruff GITHUB_REPOSITORY_OWNER=astral-sh GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=45f11c39b1ea3ea89e83c4db3cdb7004fb707868 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_INCREMENTAL=0 CARGO_NET_RETRY=10 CARGO_TERM_COLOR=always RUSTUP_MAX_RETRIES=10 PACKAGE_NAME=ruff PYTHON_VERSION=3.14 NEXTEST_PROFILE=ci MDTEST_EXTERNAL=1 GITHUB_ACTION_PATH=/home/github/66158761716/actions/astral-sh-setup-uv@5a095e7a2014a4212f075830d4f7277575a9d098 "${CURRENT_ENV[@]}" INPUT_VERSION=0.10.7 INPUT_ENABLE-CACHE=true INPUT_VERSION-FILE= INPUT_ACTIVATE-ENVIRONMENT=false INPUT_VENV-PATH= INPUT_WORKING-DIRECTORY=${GITHUB_WORKSPACE} INPUT_GITHUB-TOKEN=DUMMY INPUT_CACHE-DEPENDENCY-GLOB='**/*requirements*.txt
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
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=6 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=astral-sh/setup-uv GITHUB_ACTIONS=true GITHUB_ACTOR=Glyphack GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=shaygan-yield-type GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/shaygan-yield-type GITHUB_REF_NAME=shaygan-yield-type GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=astral-sh/ruff GITHUB_REPOSITORY_OWNER=astral-sh GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=45f11c39b1ea3ea89e83c4db3cdb7004fb707868 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_INCREMENTAL=0 CARGO_NET_RETRY=10 CARGO_TERM_COLOR=always RUSTUP_MAX_RETRIES=10 PACKAGE_NAME=ruff PYTHON_VERSION=3.14 NEXTEST_PROFILE=ci MDTEST_EXTERNAL=1 GITHUB_ACTION_PATH=/home/github/66158761716/actions/astral-sh-setup-uv@5a095e7a2014a4212f075830d4f7277575a9d098 "${CURRENT_ENV[@]}" INPUT_VERSION=0.10.7 INPUT_ENABLE-CACHE=true INPUT_VERSION-FILE= INPUT_ACTIVATE-ENVIRONMENT=false INPUT_VENV-PATH= INPUT_WORKING-DIRECTORY=${GITHUB_WORKSPACE} INPUT_GITHUB-TOKEN=DUMMY INPUT_CACHE-DEPENDENCY-GLOB='**/*requirements*.txt
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=7 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=Glyphack GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=shaygan-yield-type GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/shaygan-yield-type GITHUB_REF_NAME=shaygan-yield-type GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=astral-sh/ruff GITHUB_REPOSITORY_OWNER=astral-sh GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=45f11c39b1ea3ea89e83c4db3cdb7004fb707868 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_INCREMENTAL=0 CARGO_NET_RETRY=10 CARGO_TERM_COLOR=always RUSTUP_MAX_RETRIES=10 PACKAGE_NAME=ruff PYTHON_VERSION=3.14 NEXTEST_PROFILE=ci MDTEST_EXTERNAL=1 "${CURRENT_ENV[@]}" NO_COLOR=1 MDTEST_GITHUB_ANNOTATIONS_FORMAT=1 \
echo "$(/home/github/66158761716/helpers/eval_expression p:'(' f:success p:'(' p:')' p:')' o:'&&' p:'(' s:'' o:== s:true p:')')")
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=7 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=Glyphack GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=shaygan-yield-type GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/shaygan-yield-type GITHUB_REF_NAME=shaygan-yield-type GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=astral-sh/ruff GITHUB_REPOSITORY_OWNER=astral-sh GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=45f11c39b1ea3ea89e83c4db3cdb7004fb707868 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_INCREMENTAL=0 CARGO_NET_RETRY=10 CARGO_TERM_COLOR=always RUSTUP_MAX_RETRIES=10 PACKAGE_NAME=ruff PYTHON_VERSION=3.14 NEXTEST_PROFILE=ci MDTEST_EXTERNAL=1 "${CURRENT_ENV[@]}" NO_COLOR=1 MDTEST_GITHUB_ANNOTATIONS_FORMAT=1 \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run 'cargo test -p ty_python_semantic --test mdtest || true'
echo "##[endgroup]"
echo 'cargo test -p ty_python_semantic --test mdtest || true' > /home/github/66158761716/steps/bugswarm_7.sh
chmod u+x /home/github/66158761716/steps/bugswarm_7.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=7 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=Glyphack GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=shaygan-yield-type GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/shaygan-yield-type GITHUB_REF_NAME=shaygan-yield-type GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=astral-sh/ruff GITHUB_REPOSITORY_OWNER=astral-sh GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=45f11c39b1ea3ea89e83c4db3cdb7004fb707868 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_INCREMENTAL=0 CARGO_NET_RETRY=10 CARGO_TERM_COLOR=always RUSTUP_MAX_RETRIES=10 PACKAGE_NAME=ruff PYTHON_VERSION=3.14 NEXTEST_PROFILE=ci MDTEST_EXTERNAL=1 "${CURRENT_ENV[@]}" NO_COLOR=1 MDTEST_GITHUB_ANNOTATIONS_FORMAT=1 \
bash --noprofile --norc -eo pipefail /home/github/66158761716/steps/bugswarm_7.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=7 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=Glyphack GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=shaygan-yield-type GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/shaygan-yield-type GITHUB_REF_NAME=shaygan-yield-type GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=astral-sh/ruff GITHUB_REPOSITORY_OWNER=astral-sh GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=45f11c39b1ea3ea89e83c4db3cdb7004fb707868 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_INCREMENTAL=0 CARGO_NET_RETRY=10 CARGO_TERM_COLOR=always RUSTUP_MAX_RETRIES=10 PACKAGE_NAME=ruff PYTHON_VERSION=3.14 NEXTEST_PROFILE=ci MDTEST_EXTERNAL=1 "${CURRENT_ENV[@]}" NO_COLOR=1 MDTEST_GITHUB_ANNOTATIONS_FORMAT=1 \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=7 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=Glyphack GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=shaygan-yield-type GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/shaygan-yield-type GITHUB_REF_NAME=shaygan-yield-type GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=astral-sh/ruff GITHUB_REPOSITORY_OWNER=astral-sh GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=45f11c39b1ea3ea89e83c4db3cdb7004fb707868 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_INCREMENTAL=0 CARGO_NET_RETRY=10 CARGO_TERM_COLOR=always RUSTUP_MAX_RETRIES=10 PACKAGE_NAME=ruff PYTHON_VERSION=3.14 NEXTEST_PROFILE=ci MDTEST_EXTERNAL=1 "${CURRENT_ENV[@]}" NO_COLOR=1 MDTEST_GITHUB_ANNOTATIONS_FORMAT=1 \
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=8 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=Glyphack GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=shaygan-yield-type GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/shaygan-yield-type GITHUB_REF_NAME=shaygan-yield-type GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=astral-sh/ruff GITHUB_REPOSITORY_OWNER=astral-sh GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=45f11c39b1ea3ea89e83c4db3cdb7004fb707868 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_INCREMENTAL=0 CARGO_NET_RETRY=10 CARGO_TERM_COLOR=always RUSTUP_MAX_RETRIES=10 PACKAGE_NAME=ruff PYTHON_VERSION=3.14 NEXTEST_PROFILE=ci MDTEST_EXTERNAL=1 "${CURRENT_ENV[@]}" \
echo $(test "$_GITHUB_JOB_STATUS" = "success" && echo true || echo false))
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=8 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=Glyphack GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=shaygan-yield-type GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/shaygan-yield-type GITHUB_REF_NAME=shaygan-yield-type GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=astral-sh/ruff GITHUB_REPOSITORY_OWNER=astral-sh GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=45f11c39b1ea3ea89e83c4db3cdb7004fb707868 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_INCREMENTAL=0 CARGO_NET_RETRY=10 CARGO_TERM_COLOR=always RUSTUP_MAX_RETRIES=10 PACKAGE_NAME=ruff PYTHON_VERSION=3.14 NEXTEST_PROFILE=ci MDTEST_EXTERNAL=1 "${CURRENT_ENV[@]}" \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run 'cargo insta test --all-features --unreferenced reject --test-runner nextest'
echo "##[endgroup]"
echo 'cargo insta test --all-features --unreferenced reject --test-runner nextest' > /home/github/66158761716/steps/bugswarm_8.sh
chmod u+x /home/github/66158761716/steps/bugswarm_8.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=8 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=Glyphack GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=shaygan-yield-type GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/shaygan-yield-type GITHUB_REF_NAME=shaygan-yield-type GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=astral-sh/ruff GITHUB_REPOSITORY_OWNER=astral-sh GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=45f11c39b1ea3ea89e83c4db3cdb7004fb707868 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_INCREMENTAL=0 CARGO_NET_RETRY=10 CARGO_TERM_COLOR=always RUSTUP_MAX_RETRIES=10 PACKAGE_NAME=ruff PYTHON_VERSION=3.14 NEXTEST_PROFILE=ci MDTEST_EXTERNAL=1 "${CURRENT_ENV[@]}" \
bash --noprofile --norc -eo pipefail /home/github/66158761716/steps/bugswarm_8.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=8 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=Glyphack GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=shaygan-yield-type GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/shaygan-yield-type GITHUB_REF_NAME=shaygan-yield-type GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=astral-sh/ruff GITHUB_REPOSITORY_OWNER=astral-sh GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=45f11c39b1ea3ea89e83c4db3cdb7004fb707868 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_INCREMENTAL=0 CARGO_NET_RETRY=10 CARGO_TERM_COLOR=always RUSTUP_MAX_RETRIES=10 PACKAGE_NAME=ruff PYTHON_VERSION=3.14 NEXTEST_PROFILE=ci MDTEST_EXTERNAL=1 "${CURRENT_ENV[@]}" \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=8 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=Glyphack GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=shaygan-yield-type GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/shaygan-yield-type GITHUB_REF_NAME=shaygan-yield-type GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=astral-sh/ruff GITHUB_REPOSITORY_OWNER=astral-sh GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=45f11c39b1ea3ea89e83c4db3cdb7004fb707868 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_INCREMENTAL=0 CARGO_NET_RETRY=10 CARGO_TERM_COLOR=always RUSTUP_MAX_RETRIES=10 PACKAGE_NAME=ruff PYTHON_VERSION=3.14 NEXTEST_PROFILE=ci MDTEST_EXTERNAL=1 "${CURRENT_ENV[@]}" \
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=9 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=Glyphack GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=shaygan-yield-type GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/shaygan-yield-type GITHUB_REF_NAME=shaygan-yield-type GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=astral-sh/ruff GITHUB_REPOSITORY_OWNER=astral-sh GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=45f11c39b1ea3ea89e83c4db3cdb7004fb707868 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_INCREMENTAL=0 CARGO_NET_RETRY=10 CARGO_TERM_COLOR=always RUSTUP_MAX_RETRIES=10 PACKAGE_NAME=ruff PYTHON_VERSION=3.14 NEXTEST_PROFILE=ci MDTEST_EXTERNAL=1 "${CURRENT_ENV[@]}" \
echo $(test "$_GITHUB_JOB_STATUS" = "success" && echo true || echo false))
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=9 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=Glyphack GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=shaygan-yield-type GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/shaygan-yield-type GITHUB_REF_NAME=shaygan-yield-type GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=astral-sh/ruff GITHUB_REPOSITORY_OWNER=astral-sh GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=45f11c39b1ea3ea89e83c4db3cdb7004fb707868 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_INCREMENTAL=0 CARGO_NET_RETRY=10 CARGO_TERM_COLOR=always RUSTUP_MAX_RETRIES=10 PACKAGE_NAME=ruff PYTHON_VERSION=3.14 NEXTEST_PROFILE=ci MDTEST_EXTERNAL=1 "${CURRENT_ENV[@]}" \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run 'uv run --project=./python/py-fuzzer cargo run -p ty check --project=./python/py-fuzzer'
echo "##[endgroup]"
echo 'uv run --project=./python/py-fuzzer cargo run -p ty check --project=./python/py-fuzzer' > /home/github/66158761716/steps/bugswarm_9.sh
chmod u+x /home/github/66158761716/steps/bugswarm_9.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=9 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=Glyphack GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=shaygan-yield-type GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/shaygan-yield-type GITHUB_REF_NAME=shaygan-yield-type GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=astral-sh/ruff GITHUB_REPOSITORY_OWNER=astral-sh GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=45f11c39b1ea3ea89e83c4db3cdb7004fb707868 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_INCREMENTAL=0 CARGO_NET_RETRY=10 CARGO_TERM_COLOR=always RUSTUP_MAX_RETRIES=10 PACKAGE_NAME=ruff PYTHON_VERSION=3.14 NEXTEST_PROFILE=ci MDTEST_EXTERNAL=1 "${CURRENT_ENV[@]}" \
bash --noprofile --norc -eo pipefail /home/github/66158761716/steps/bugswarm_9.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=9 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=Glyphack GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=shaygan-yield-type GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/shaygan-yield-type GITHUB_REF_NAME=shaygan-yield-type GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=astral-sh/ruff GITHUB_REPOSITORY_OWNER=astral-sh GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=45f11c39b1ea3ea89e83c4db3cdb7004fb707868 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_INCREMENTAL=0 CARGO_NET_RETRY=10 CARGO_TERM_COLOR=always RUSTUP_MAX_RETRIES=10 PACKAGE_NAME=ruff PYTHON_VERSION=3.14 NEXTEST_PROFILE=ci MDTEST_EXTERNAL=1 "${CURRENT_ENV[@]}" \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=9 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=Glyphack GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=shaygan-yield-type GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/shaygan-yield-type GITHUB_REF_NAME=shaygan-yield-type GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=astral-sh/ruff GITHUB_REPOSITORY_OWNER=astral-sh GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=45f11c39b1ea3ea89e83c4db3cdb7004fb707868 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_INCREMENTAL=0 CARGO_NET_RETRY=10 CARGO_TERM_COLOR=always RUSTUP_MAX_RETRIES=10 PACKAGE_NAME=ruff PYTHON_VERSION=3.14 NEXTEST_PROFILE=ci MDTEST_EXTERNAL=1 "${CURRENT_ENV[@]}" \
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=10 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=Glyphack GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=shaygan-yield-type GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/shaygan-yield-type GITHUB_REF_NAME=shaygan-yield-type GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=astral-sh/ruff GITHUB_REPOSITORY_OWNER=astral-sh GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=45f11c39b1ea3ea89e83c4db3cdb7004fb707868 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_INCREMENTAL=0 CARGO_NET_RETRY=10 CARGO_TERM_COLOR=always RUSTUP_MAX_RETRIES=10 PACKAGE_NAME=ruff PYTHON_VERSION=3.14 NEXTEST_PROFILE=ci MDTEST_EXTERNAL=1 "${CURRENT_ENV[@]}" \
echo $(test "$_GITHUB_JOB_STATUS" = "success" && echo true || echo false))
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=10 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=Glyphack GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=shaygan-yield-type GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/shaygan-yield-type GITHUB_REF_NAME=shaygan-yield-type GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=astral-sh/ruff GITHUB_REPOSITORY_OWNER=astral-sh GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=45f11c39b1ea3ea89e83c4db3cdb7004fb707868 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_INCREMENTAL=0 CARGO_NET_RETRY=10 CARGO_TERM_COLOR=always RUSTUP_MAX_RETRIES=10 PACKAGE_NAME=ruff PYTHON_VERSION=3.14 NEXTEST_PROFILE=ci MDTEST_EXTERNAL=1 "${CURRENT_ENV[@]}" \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run 'uv run --project=./scripts cargo run -p ty check --project=./scripts'
echo "##[endgroup]"
echo 'uv run --project=./scripts cargo run -p ty check --project=./scripts' > /home/github/66158761716/steps/bugswarm_10.sh
chmod u+x /home/github/66158761716/steps/bugswarm_10.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=10 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=Glyphack GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=shaygan-yield-type GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/shaygan-yield-type GITHUB_REF_NAME=shaygan-yield-type GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=astral-sh/ruff GITHUB_REPOSITORY_OWNER=astral-sh GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=45f11c39b1ea3ea89e83c4db3cdb7004fb707868 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_INCREMENTAL=0 CARGO_NET_RETRY=10 CARGO_TERM_COLOR=always RUSTUP_MAX_RETRIES=10 PACKAGE_NAME=ruff PYTHON_VERSION=3.14 NEXTEST_PROFILE=ci MDTEST_EXTERNAL=1 "${CURRENT_ENV[@]}" \
bash --noprofile --norc -eo pipefail /home/github/66158761716/steps/bugswarm_10.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=10 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=Glyphack GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=shaygan-yield-type GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/shaygan-yield-type GITHUB_REF_NAME=shaygan-yield-type GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=astral-sh/ruff GITHUB_REPOSITORY_OWNER=astral-sh GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=45f11c39b1ea3ea89e83c4db3cdb7004fb707868 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_INCREMENTAL=0 CARGO_NET_RETRY=10 CARGO_TERM_COLOR=always RUSTUP_MAX_RETRIES=10 PACKAGE_NAME=ruff PYTHON_VERSION=3.14 NEXTEST_PROFILE=ci MDTEST_EXTERNAL=1 "${CURRENT_ENV[@]}" \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=10 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=Glyphack GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=shaygan-yield-type GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/shaygan-yield-type GITHUB_REF_NAME=shaygan-yield-type GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=astral-sh/ruff GITHUB_REPOSITORY_OWNER=astral-sh GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=45f11c39b1ea3ea89e83c4db3cdb7004fb707868 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_INCREMENTAL=0 CARGO_NET_RETRY=10 CARGO_TERM_COLOR=always RUSTUP_MAX_RETRIES=10 PACKAGE_NAME=ruff PYTHON_VERSION=3.14 NEXTEST_PROFILE=ci MDTEST_EXTERNAL=1 "${CURRENT_ENV[@]}" \
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=11 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=Glyphack GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=shaygan-yield-type GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/shaygan-yield-type GITHUB_REF_NAME=shaygan-yield-type GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=astral-sh/ruff GITHUB_REPOSITORY_OWNER=astral-sh GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=45f11c39b1ea3ea89e83c4db3cdb7004fb707868 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_INCREMENTAL=0 CARGO_NET_RETRY=10 CARGO_TERM_COLOR=always RUSTUP_MAX_RETRIES=10 PACKAGE_NAME=ruff PYTHON_VERSION=3.14 NEXTEST_PROFILE=ci MDTEST_EXTERNAL=1 "${CURRENT_ENV[@]}" \
echo $(test "$_GITHUB_JOB_STATUS" = "success" && echo true || echo false))
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=11 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=Glyphack GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=shaygan-yield-type GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/shaygan-yield-type GITHUB_REF_NAME=shaygan-yield-type GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=astral-sh/ruff GITHUB_REPOSITORY_OWNER=astral-sh GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=45f11c39b1ea3ea89e83c4db3cdb7004fb707868 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_INCREMENTAL=0 CARGO_NET_RETRY=10 CARGO_TERM_COLOR=always RUSTUP_MAX_RETRIES=10 PACKAGE_NAME=ruff PYTHON_VERSION=3.14 NEXTEST_PROFILE=ci MDTEST_EXTERNAL=1 "${CURRENT_ENV[@]}" \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run 'uv run --project=./scripts/ty_benchmark cargo run -p ty check --project=./scripts/ty_benchmark'
echo "##[endgroup]"
echo 'uv run --project=./scripts/ty_benchmark cargo run -p ty check --project=./scripts/ty_benchmark' > /home/github/66158761716/steps/bugswarm_11.sh
chmod u+x /home/github/66158761716/steps/bugswarm_11.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=11 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=Glyphack GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=shaygan-yield-type GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/shaygan-yield-type GITHUB_REF_NAME=shaygan-yield-type GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=astral-sh/ruff GITHUB_REPOSITORY_OWNER=astral-sh GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=45f11c39b1ea3ea89e83c4db3cdb7004fb707868 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_INCREMENTAL=0 CARGO_NET_RETRY=10 CARGO_TERM_COLOR=always RUSTUP_MAX_RETRIES=10 PACKAGE_NAME=ruff PYTHON_VERSION=3.14 NEXTEST_PROFILE=ci MDTEST_EXTERNAL=1 "${CURRENT_ENV[@]}" \
bash --noprofile --norc -eo pipefail /home/github/66158761716/steps/bugswarm_11.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=11 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=Glyphack GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=shaygan-yield-type GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/shaygan-yield-type GITHUB_REF_NAME=shaygan-yield-type GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=astral-sh/ruff GITHUB_REPOSITORY_OWNER=astral-sh GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=45f11c39b1ea3ea89e83c4db3cdb7004fb707868 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_INCREMENTAL=0 CARGO_NET_RETRY=10 CARGO_TERM_COLOR=always RUSTUP_MAX_RETRIES=10 PACKAGE_NAME=ruff PYTHON_VERSION=3.14 NEXTEST_PROFILE=ci MDTEST_EXTERNAL=1 "${CURRENT_ENV[@]}" \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=11 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=Glyphack GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=shaygan-yield-type GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/shaygan-yield-type GITHUB_REF_NAME=shaygan-yield-type GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=astral-sh/ruff GITHUB_REPOSITORY_OWNER=astral-sh GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=45f11c39b1ea3ea89e83c4db3cdb7004fb707868 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_INCREMENTAL=0 CARGO_NET_RETRY=10 CARGO_TERM_COLOR=always RUSTUP_MAX_RETRIES=10 PACKAGE_NAME=ruff PYTHON_VERSION=3.14 NEXTEST_PROFILE=ci MDTEST_EXTERNAL=1 "${CURRENT_ENV[@]}" \
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=12 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=Glyphack GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=shaygan-yield-type GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/shaygan-yield-type GITHUB_REF_NAME=shaygan-yield-type GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=astral-sh/ruff GITHUB_REPOSITORY_OWNER=astral-sh GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=45f11c39b1ea3ea89e83c4db3cdb7004fb707868 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_INCREMENTAL=0 CARGO_NET_RETRY=10 CARGO_TERM_COLOR=always RUSTUP_MAX_RETRIES=10 PACKAGE_NAME=ruff PYTHON_VERSION=3.14 NEXTEST_PROFILE=ci MDTEST_EXTERNAL=1 "${CURRENT_ENV[@]}" RUSTDOCFLAGS='-D warnings' \
echo $(test "$_GITHUB_JOB_STATUS" = "success" && echo true || echo false))
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=12 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=Glyphack GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=shaygan-yield-type GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/shaygan-yield-type GITHUB_REF_NAME=shaygan-yield-type GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=astral-sh/ruff GITHUB_REPOSITORY_OWNER=astral-sh GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=45f11c39b1ea3ea89e83c4db3cdb7004fb707868 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_INCREMENTAL=0 CARGO_NET_RETRY=10 CARGO_TERM_COLOR=always RUSTUP_MAX_RETRIES=10 PACKAGE_NAME=ruff PYTHON_VERSION=3.14 NEXTEST_PROFILE=ci MDTEST_EXTERNAL=1 "${CURRENT_ENV[@]}" RUSTDOCFLAGS='-D warnings' \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run 'cargo doc --all --no-deps'
echo "##[endgroup]"
echo 'cargo doc --all --no-deps' > /home/github/66158761716/steps/bugswarm_12.sh
chmod u+x /home/github/66158761716/steps/bugswarm_12.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=12 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=Glyphack GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=shaygan-yield-type GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/shaygan-yield-type GITHUB_REF_NAME=shaygan-yield-type GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=astral-sh/ruff GITHUB_REPOSITORY_OWNER=astral-sh GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=45f11c39b1ea3ea89e83c4db3cdb7004fb707868 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_INCREMENTAL=0 CARGO_NET_RETRY=10 CARGO_TERM_COLOR=always RUSTUP_MAX_RETRIES=10 PACKAGE_NAME=ruff PYTHON_VERSION=3.14 NEXTEST_PROFILE=ci MDTEST_EXTERNAL=1 "${CURRENT_ENV[@]}" RUSTDOCFLAGS='-D warnings' \
bash --noprofile --norc -eo pipefail /home/github/66158761716/steps/bugswarm_12.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=12 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=Glyphack GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=shaygan-yield-type GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/shaygan-yield-type GITHUB_REF_NAME=shaygan-yield-type GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=astral-sh/ruff GITHUB_REPOSITORY_OWNER=astral-sh GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=45f11c39b1ea3ea89e83c4db3cdb7004fb707868 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_INCREMENTAL=0 CARGO_NET_RETRY=10 CARGO_TERM_COLOR=always RUSTUP_MAX_RETRIES=10 PACKAGE_NAME=ruff PYTHON_VERSION=3.14 NEXTEST_PROFILE=ci MDTEST_EXTERNAL=1 "${CURRENT_ENV[@]}" RUSTDOCFLAGS='-D warnings' \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=12 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=Glyphack GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=shaygan-yield-type GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/shaygan-yield-type GITHUB_REF_NAME=shaygan-yield-type GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=astral-sh/ruff GITHUB_REPOSITORY_OWNER=astral-sh GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=45f11c39b1ea3ea89e83c4db3cdb7004fb707868 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_INCREMENTAL=0 CARGO_NET_RETRY=10 CARGO_TERM_COLOR=always RUSTUP_MAX_RETRIES=10 PACKAGE_NAME=ruff PYTHON_VERSION=3.14 NEXTEST_PROFILE=ci MDTEST_EXTERNAL=1 "${CURRENT_ENV[@]}" RUSTDOCFLAGS='-D warnings' \
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=13 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=Glyphack GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=shaygan-yield-type GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/shaygan-yield-type GITHUB_REF_NAME=shaygan-yield-type GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=astral-sh/ruff GITHUB_REPOSITORY_OWNER=astral-sh GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=45f11c39b1ea3ea89e83c4db3cdb7004fb707868 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_INCREMENTAL=0 CARGO_NET_RETRY=10 CARGO_TERM_COLOR=always RUSTUP_MAX_RETRIES=10 PACKAGE_NAME=ruff PYTHON_VERSION=3.14 NEXTEST_PROFILE=ci MDTEST_EXTERNAL=1 "${CURRENT_ENV[@]}" RUSTDOCFLAGS='-D warnings' \
echo $(test "$_GITHUB_JOB_STATUS" = "success" && echo true || echo false))
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=13 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=Glyphack GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=shaygan-yield-type GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/shaygan-yield-type GITHUB_REF_NAME=shaygan-yield-type GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=astral-sh/ruff GITHUB_REPOSITORY_OWNER=astral-sh GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=45f11c39b1ea3ea89e83c4db3cdb7004fb707868 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_INCREMENTAL=0 CARGO_NET_RETRY=10 CARGO_TERM_COLOR=always RUSTUP_MAX_RETRIES=10 PACKAGE_NAME=ruff PYTHON_VERSION=3.14 NEXTEST_PROFILE=ci MDTEST_EXTERNAL=1 "${CURRENT_ENV[@]}" RUSTDOCFLAGS='-D warnings' \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run 'cargo doc --no-deps -p ty_python_semantic -p ty -p ty_test -p ruff_db -p ruff_python_formatter --document-private-items'
echo "##[endgroup]"
echo 'cargo doc --no-deps -p ty_python_semantic -p ty -p ty_test -p ruff_db -p ruff_python_formatter --document-private-items' > /home/github/66158761716/steps/bugswarm_13.sh
chmod u+x /home/github/66158761716/steps/bugswarm_13.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=13 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=Glyphack GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=shaygan-yield-type GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/shaygan-yield-type GITHUB_REF_NAME=shaygan-yield-type GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=astral-sh/ruff GITHUB_REPOSITORY_OWNER=astral-sh GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=45f11c39b1ea3ea89e83c4db3cdb7004fb707868 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_INCREMENTAL=0 CARGO_NET_RETRY=10 CARGO_TERM_COLOR=always RUSTUP_MAX_RETRIES=10 PACKAGE_NAME=ruff PYTHON_VERSION=3.14 NEXTEST_PROFILE=ci MDTEST_EXTERNAL=1 "${CURRENT_ENV[@]}" RUSTDOCFLAGS='-D warnings' \
bash --noprofile --norc -eo pipefail /home/github/66158761716/steps/bugswarm_13.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=13 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=Glyphack GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=shaygan-yield-type GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/shaygan-yield-type GITHUB_REF_NAME=shaygan-yield-type GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=astral-sh/ruff GITHUB_REPOSITORY_OWNER=astral-sh GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=45f11c39b1ea3ea89e83c4db3cdb7004fb707868 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_INCREMENTAL=0 CARGO_NET_RETRY=10 CARGO_TERM_COLOR=always RUSTUP_MAX_RETRIES=10 PACKAGE_NAME=ruff PYTHON_VERSION=3.14 NEXTEST_PROFILE=ci MDTEST_EXTERNAL=1 "${CURRENT_ENV[@]}" RUSTDOCFLAGS='-D warnings' \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=13 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=Glyphack GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=shaygan-yield-type GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/shaygan-yield-type GITHUB_REF_NAME=shaygan-yield-type GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=astral-sh/ruff GITHUB_REPOSITORY_OWNER=astral-sh GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=45f11c39b1ea3ea89e83c4db3cdb7004fb707868 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_INCREMENTAL=0 CARGO_NET_RETRY=10 CARGO_TERM_COLOR=always RUSTUP_MAX_RETRIES=10 PACKAGE_NAME=ruff PYTHON_VERSION=3.14 NEXTEST_PROFILE=ci MDTEST_EXTERNAL=1 "${CURRENT_ENV[@]}" RUSTDOCFLAGS='-D warnings' \
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
   bash -e $ACTIONS_RUNNER_HOOK_JOB_COMPLETED 66158761716 failed
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
