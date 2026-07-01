#!/usr/bin/env bash
export GITHUB_WORKSPACE=/home/github/build/mxsm/rocketmq-rust

if [[ ! -z "$ACTIONS_RUNNER_HOOK_JOB_STARTED" ]]; then
   echo "A job started hook has been configured by the self-hosted runner administrator"
   echo "##[group]Run '$ACTIONS_RUNNER_HOOK_JOB_STARTED'"
   echo "##[endgroup]"
   bash -e $ACTIONS_RUNNER_HOOK_JOB_STARTED 70073145678 passed
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

cp /home/github/70073145678/event.json /home/github/workflow/event.json
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=1 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=rocketmq-rust-bot GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/main GITHUB_REF_NAME=main GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=mxsm/rocketmq-rust GITHUB_REPOSITORY_OWNER=mxsm GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=bcdcb93be3d13fb8b8a989b6407050d674ac1a30 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='RocketMQ Rust CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_TERM_COLOR=always RUST_BACKTRACE=full CI=true CARGO_PROFILE_DEV_DEBUG=false CARGO_PROFILE_TEST_DEBUG=false CARGO_PROFILE_DEV_OPT_LEVEL=1 CARGO_PROFILE_DEV_OVERFLOW_CHECKS=false CARGO_TARGET_DIR=target ROCKSDB_DISABLE_JEMALLOC=1 "${CURRENT_ENV[@]}" \
echo "$(/home/github/70073145678/helpers/eval_expression p:'(' f:success p:'(' p:')' p:')' o:'&&' p:'(' s:ubuntu-latest o:== s:ubuntu-latest p:')')")
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=1 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=rocketmq-rust-bot GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/main GITHUB_REF_NAME=main GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=mxsm/rocketmq-rust GITHUB_REPOSITORY_OWNER=mxsm GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=bcdcb93be3d13fb8b8a989b6407050d674ac1a30 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='RocketMQ Rust CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_TERM_COLOR=always RUST_BACKTRACE=full CI=true CARGO_PROFILE_DEV_DEBUG=false CARGO_PROFILE_TEST_DEBUG=false CARGO_PROFILE_DEV_OPT_LEVEL=1 CARGO_PROFILE_DEV_OVERFLOW_CHECKS=false CARGO_TARGET_DIR=target ROCKSDB_DISABLE_JEMALLOC=1 "${CURRENT_ENV[@]}" \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run 'sudo apt-get update'
echo "##[endgroup]"
echo 'sudo apt-get update
sudo apt-get install -y \
  clang llvm libclang-dev \
  cmake make ninja-build pkg-config \
  protobuf-compiler \
  libsnappy-dev liblz4-dev libzstd-dev zlib1g-dev \
  libxcb1-dev libxkbcommon-dev libxkbcommon-x11-dev

echo "CC=clang" >> $GITHUB_ENV
echo "CXX=clang++" >> $GITHUB_ENV
LIBCLANG_DIR=$(ls -d /usr/lib/llvm-*/lib | head -n 1)
echo "LIBCLANG_PATH=$LIBCLANG_DIR" >> $GITHUB_ENV
' > /home/github/70073145678/steps/bugswarm_1.sh
chmod u+x /home/github/70073145678/steps/bugswarm_1.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=1 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=rocketmq-rust-bot GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/main GITHUB_REF_NAME=main GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=mxsm/rocketmq-rust GITHUB_REPOSITORY_OWNER=mxsm GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=bcdcb93be3d13fb8b8a989b6407050d674ac1a30 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='RocketMQ Rust CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_TERM_COLOR=always RUST_BACKTRACE=full CI=true CARGO_PROFILE_DEV_DEBUG=false CARGO_PROFILE_TEST_DEBUG=false CARGO_PROFILE_DEV_OPT_LEVEL=1 CARGO_PROFILE_DEV_OVERFLOW_CHECKS=false CARGO_TARGET_DIR=target ROCKSDB_DISABLE_JEMALLOC=1 "${CURRENT_ENV[@]}" \
bash -e /home/github/70073145678/steps/bugswarm_1.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=1 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=rocketmq-rust-bot GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/main GITHUB_REF_NAME=main GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=mxsm/rocketmq-rust GITHUB_REPOSITORY_OWNER=mxsm GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=bcdcb93be3d13fb8b8a989b6407050d674ac1a30 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='RocketMQ Rust CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_TERM_COLOR=always RUST_BACKTRACE=full CI=true CARGO_PROFILE_DEV_DEBUG=false CARGO_PROFILE_TEST_DEBUG=false CARGO_PROFILE_DEV_OPT_LEVEL=1 CARGO_PROFILE_DEV_OVERFLOW_CHECKS=false CARGO_TARGET_DIR=target ROCKSDB_DISABLE_JEMALLOC=1 "${CURRENT_ENV[@]}" \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=1 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=rocketmq-rust-bot GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/main GITHUB_REF_NAME=main GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=mxsm/rocketmq-rust GITHUB_REPOSITORY_OWNER=mxsm GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=bcdcb93be3d13fb8b8a989b6407050d674ac1a30 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='RocketMQ Rust CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_TERM_COLOR=always RUST_BACKTRACE=full CI=true CARGO_PROFILE_DEV_DEBUG=false CARGO_PROFILE_TEST_DEBUG=false CARGO_PROFILE_DEV_OPT_LEVEL=1 CARGO_PROFILE_DEV_OVERFLOW_CHECKS=false CARGO_TARGET_DIR=target ROCKSDB_DISABLE_JEMALLOC=1 "${CURRENT_ENV[@]}" \
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=2 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=rocketmq-rust-bot GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/main GITHUB_REF_NAME=main GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=mxsm/rocketmq-rust GITHUB_REPOSITORY_OWNER=mxsm GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=bcdcb93be3d13fb8b8a989b6407050d674ac1a30 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='RocketMQ Rust CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_TERM_COLOR=always RUST_BACKTRACE=full CI=true CARGO_PROFILE_DEV_DEBUG=false CARGO_PROFILE_TEST_DEBUG=false CARGO_PROFILE_DEV_OPT_LEVEL=1 CARGO_PROFILE_DEV_OVERFLOW_CHECKS=false CARGO_TARGET_DIR=target ROCKSDB_DISABLE_JEMALLOC=1 "${CURRENT_ENV[@]}" \
echo "$(/home/github/70073145678/helpers/eval_expression p:'(' f:success p:'(' p:')' p:')' o:'&&' p:'(' s:ubuntu-latest o:== s:macos-latest p:')')")
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=2 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=rocketmq-rust-bot GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/main GITHUB_REF_NAME=main GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=mxsm/rocketmq-rust GITHUB_REPOSITORY_OWNER=mxsm GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=bcdcb93be3d13fb8b8a989b6407050d674ac1a30 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='RocketMQ Rust CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_TERM_COLOR=always RUST_BACKTRACE=full CI=true CARGO_PROFILE_DEV_DEBUG=false CARGO_PROFILE_TEST_DEBUG=false CARGO_PROFILE_DEV_OPT_LEVEL=1 CARGO_PROFILE_DEV_OVERFLOW_CHECKS=false CARGO_TARGET_DIR=target ROCKSDB_DISABLE_JEMALLOC=1 "${CURRENT_ENV[@]}" \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run 'brew update'
echo "##[endgroup]"
echo 'brew update
brew install cmake protobuf snappy lz4 zstd
' > /home/github/70073145678/steps/bugswarm_2.sh
chmod u+x /home/github/70073145678/steps/bugswarm_2.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=2 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=rocketmq-rust-bot GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/main GITHUB_REF_NAME=main GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=mxsm/rocketmq-rust GITHUB_REPOSITORY_OWNER=mxsm GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=bcdcb93be3d13fb8b8a989b6407050d674ac1a30 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='RocketMQ Rust CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_TERM_COLOR=always RUST_BACKTRACE=full CI=true CARGO_PROFILE_DEV_DEBUG=false CARGO_PROFILE_TEST_DEBUG=false CARGO_PROFILE_DEV_OPT_LEVEL=1 CARGO_PROFILE_DEV_OVERFLOW_CHECKS=false CARGO_TARGET_DIR=target ROCKSDB_DISABLE_JEMALLOC=1 "${CURRENT_ENV[@]}" \
bash -e /home/github/70073145678/steps/bugswarm_2.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=2 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=rocketmq-rust-bot GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/main GITHUB_REF_NAME=main GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=mxsm/rocketmq-rust GITHUB_REPOSITORY_OWNER=mxsm GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=bcdcb93be3d13fb8b8a989b6407050d674ac1a30 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='RocketMQ Rust CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_TERM_COLOR=always RUST_BACKTRACE=full CI=true CARGO_PROFILE_DEV_DEBUG=false CARGO_PROFILE_TEST_DEBUG=false CARGO_PROFILE_DEV_OPT_LEVEL=1 CARGO_PROFILE_DEV_OVERFLOW_CHECKS=false CARGO_TARGET_DIR=target ROCKSDB_DISABLE_JEMALLOC=1 "${CURRENT_ENV[@]}" \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=2 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=rocketmq-rust-bot GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/main GITHUB_REF_NAME=main GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=mxsm/rocketmq-rust GITHUB_REPOSITORY_OWNER=mxsm GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=bcdcb93be3d13fb8b8a989b6407050d674ac1a30 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='RocketMQ Rust CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_TERM_COLOR=always RUST_BACKTRACE=full CI=true CARGO_PROFILE_DEV_DEBUG=false CARGO_PROFILE_TEST_DEBUG=false CARGO_PROFILE_DEV_OPT_LEVEL=1 CARGO_PROFILE_DEV_OVERFLOW_CHECKS=false CARGO_TARGET_DIR=target ROCKSDB_DISABLE_JEMALLOC=1 "${CURRENT_ENV[@]}" \
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=3 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=rocketmq-rust-bot GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/main GITHUB_REF_NAME=main GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=mxsm/rocketmq-rust GITHUB_REPOSITORY_OWNER=mxsm GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=bcdcb93be3d13fb8b8a989b6407050d674ac1a30 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='RocketMQ Rust CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_TERM_COLOR=always RUST_BACKTRACE=full CI=true CARGO_PROFILE_DEV_DEBUG=false CARGO_PROFILE_TEST_DEBUG=false CARGO_PROFILE_DEV_OPT_LEVEL=1 CARGO_PROFILE_DEV_OVERFLOW_CHECKS=false CARGO_TARGET_DIR=target ROCKSDB_DISABLE_JEMALLOC=1 "${CURRENT_ENV[@]}" \
echo "$(/home/github/70073145678/helpers/eval_expression p:'(' f:success p:'(' p:')' p:')' o:'&&' p:'(' s:ubuntu-latest o:== s:windows-latest p:')')")
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=3 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=rocketmq-rust-bot GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/main GITHUB_REF_NAME=main GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=mxsm/rocketmq-rust GITHUB_REPOSITORY_OWNER=mxsm GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=bcdcb93be3d13fb8b8a989b6407050d674ac1a30 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='RocketMQ Rust CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_TERM_COLOR=always RUST_BACKTRACE=full CI=true CARGO_PROFILE_DEV_DEBUG=false CARGO_PROFILE_TEST_DEBUG=false CARGO_PROFILE_DEV_OPT_LEVEL=1 CARGO_PROFILE_DEV_OVERFLOW_CHECKS=false CARGO_TARGET_DIR=target ROCKSDB_DISABLE_JEMALLOC=1 "${CURRENT_ENV[@]}" \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run 'choco install cmake ninja protoc -y'
echo "##[endgroup]"
echo 'choco install cmake ninja protoc -y
' > /home/github/70073145678/steps/bugswarm_3.sh
chmod u+x /home/github/70073145678/steps/bugswarm_3.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=3 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=rocketmq-rust-bot GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/main GITHUB_REF_NAME=main GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=mxsm/rocketmq-rust GITHUB_REPOSITORY_OWNER=mxsm GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=bcdcb93be3d13fb8b8a989b6407050d674ac1a30 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='RocketMQ Rust CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_TERM_COLOR=always RUST_BACKTRACE=full CI=true CARGO_PROFILE_DEV_DEBUG=false CARGO_PROFILE_TEST_DEBUG=false CARGO_PROFILE_DEV_OPT_LEVEL=1 CARGO_PROFILE_DEV_OVERFLOW_CHECKS=false CARGO_TARGET_DIR=target ROCKSDB_DISABLE_JEMALLOC=1 "${CURRENT_ENV[@]}" \
bash -e /home/github/70073145678/steps/bugswarm_3.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=3 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=rocketmq-rust-bot GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/main GITHUB_REF_NAME=main GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=mxsm/rocketmq-rust GITHUB_REPOSITORY_OWNER=mxsm GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=bcdcb93be3d13fb8b8a989b6407050d674ac1a30 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='RocketMQ Rust CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_TERM_COLOR=always RUST_BACKTRACE=full CI=true CARGO_PROFILE_DEV_DEBUG=false CARGO_PROFILE_TEST_DEBUG=false CARGO_PROFILE_DEV_OPT_LEVEL=1 CARGO_PROFILE_DEV_OVERFLOW_CHECKS=false CARGO_TARGET_DIR=target ROCKSDB_DISABLE_JEMALLOC=1 "${CURRENT_ENV[@]}" \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=3 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=rocketmq-rust-bot GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/main GITHUB_REF_NAME=main GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=mxsm/rocketmq-rust GITHUB_REPOSITORY_OWNER=mxsm GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=bcdcb93be3d13fb8b8a989b6407050d674ac1a30 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='RocketMQ Rust CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_TERM_COLOR=always RUST_BACKTRACE=full CI=true CARGO_PROFILE_DEV_DEBUG=false CARGO_PROFILE_TEST_DEBUG=false CARGO_PROFILE_DEV_OPT_LEVEL=1 CARGO_PROFILE_DEV_OVERFLOW_CHECKS=false CARGO_TARGET_DIR=target ROCKSDB_DISABLE_JEMALLOC=1 "${CURRENT_ENV[@]}" \
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=4 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=dtolnay/rust-toolchain GITHUB_ACTIONS=true GITHUB_ACTOR=rocketmq-rust-bot GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/main GITHUB_REF_NAME=main GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=mxsm/rocketmq-rust GITHUB_REPOSITORY_OWNER=mxsm GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=bcdcb93be3d13fb8b8a989b6407050d674ac1a30 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='RocketMQ Rust CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_TERM_COLOR=always RUST_BACKTRACE=full CI=true CARGO_PROFILE_DEV_DEBUG=false CARGO_PROFILE_TEST_DEBUG=false CARGO_PROFILE_DEV_OPT_LEVEL=1 CARGO_PROFILE_DEV_OVERFLOW_CHECKS=false CARGO_TARGET_DIR=target ROCKSDB_DISABLE_JEMALLOC=1 GITHUB_ACTION_PATH=/home/github/70073145678/actions/dtolnay-rust-toolchain@nightly "${CURRENT_ENV[@]}" INPUT_TOOLCHAIN=nightly \
echo $(test "$_GITHUB_JOB_STATUS" = "success" && echo true || echo false))
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=4 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=dtolnay/rust-toolchain GITHUB_ACTIONS=true GITHUB_ACTOR=rocketmq-rust-bot GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/main GITHUB_REF_NAME=main GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=mxsm/rocketmq-rust GITHUB_REPOSITORY_OWNER=mxsm GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=bcdcb93be3d13fb8b8a989b6407050d674ac1a30 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='RocketMQ Rust CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_TERM_COLOR=always RUST_BACKTRACE=full CI=true CARGO_PROFILE_DEV_DEBUG=false CARGO_PROFILE_TEST_DEBUG=false CARGO_PROFILE_DEV_OPT_LEVEL=1 CARGO_PROFILE_DEV_OVERFLOW_CHECKS=false CARGO_TARGET_DIR=target ROCKSDB_DISABLE_JEMALLOC=1 GITHUB_ACTION_PATH=/home/github/70073145678/actions/dtolnay-rust-toolchain@nightly "${CURRENT_ENV[@]}" INPUT_TOOLCHAIN=nightly \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run dtolnay/rust-toolchain@nightly
echo "##[endgroup]"
echo /home/github/70073145678/steps/bugswarm_4_composite.sh > /home/github/70073145678/steps/bugswarm_4.sh
chmod u+x /home/github/70073145678/steps/bugswarm_4.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=4 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=dtolnay/rust-toolchain GITHUB_ACTIONS=true GITHUB_ACTOR=rocketmq-rust-bot GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/main GITHUB_REF_NAME=main GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=mxsm/rocketmq-rust GITHUB_REPOSITORY_OWNER=mxsm GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=bcdcb93be3d13fb8b8a989b6407050d674ac1a30 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='RocketMQ Rust CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_TERM_COLOR=always RUST_BACKTRACE=full CI=true CARGO_PROFILE_DEV_DEBUG=false CARGO_PROFILE_TEST_DEBUG=false CARGO_PROFILE_DEV_OPT_LEVEL=1 CARGO_PROFILE_DEV_OVERFLOW_CHECKS=false CARGO_TARGET_DIR=target ROCKSDB_DISABLE_JEMALLOC=1 GITHUB_ACTION_PATH=/home/github/70073145678/actions/dtolnay-rust-toolchain@nightly "${CURRENT_ENV[@]}" INPUT_TOOLCHAIN=nightly \
bash -e /home/github/70073145678/steps/bugswarm_4.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=4 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=dtolnay/rust-toolchain GITHUB_ACTIONS=true GITHUB_ACTOR=rocketmq-rust-bot GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/main GITHUB_REF_NAME=main GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=mxsm/rocketmq-rust GITHUB_REPOSITORY_OWNER=mxsm GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=bcdcb93be3d13fb8b8a989b6407050d674ac1a30 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='RocketMQ Rust CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_TERM_COLOR=always RUST_BACKTRACE=full CI=true CARGO_PROFILE_DEV_DEBUG=false CARGO_PROFILE_TEST_DEBUG=false CARGO_PROFILE_DEV_OPT_LEVEL=1 CARGO_PROFILE_DEV_OVERFLOW_CHECKS=false CARGO_TARGET_DIR=target ROCKSDB_DISABLE_JEMALLOC=1 GITHUB_ACTION_PATH=/home/github/70073145678/actions/dtolnay-rust-toolchain@nightly "${CURRENT_ENV[@]}" INPUT_TOOLCHAIN=nightly \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=4 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=dtolnay/rust-toolchain GITHUB_ACTIONS=true GITHUB_ACTOR=rocketmq-rust-bot GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/main GITHUB_REF_NAME=main GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=mxsm/rocketmq-rust GITHUB_REPOSITORY_OWNER=mxsm GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=bcdcb93be3d13fb8b8a989b6407050d674ac1a30 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='RocketMQ Rust CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_TERM_COLOR=always RUST_BACKTRACE=full CI=true CARGO_PROFILE_DEV_DEBUG=false CARGO_PROFILE_TEST_DEBUG=false CARGO_PROFILE_DEV_OPT_LEVEL=1 CARGO_PROFILE_DEV_OVERFLOW_CHECKS=false CARGO_TARGET_DIR=target ROCKSDB_DISABLE_JEMALLOC=1 GITHUB_ACTION_PATH=/home/github/70073145678/actions/dtolnay-rust-toolchain@nightly "${CURRENT_ENV[@]}" INPUT_TOOLCHAIN=nightly \
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=5 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=Swatinem/rust-cache GITHUB_ACTIONS=true GITHUB_ACTOR=rocketmq-rust-bot GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/main GITHUB_REF_NAME=main GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=mxsm/rocketmq-rust GITHUB_REPOSITORY_OWNER=mxsm GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=bcdcb93be3d13fb8b8a989b6407050d674ac1a30 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='RocketMQ Rust CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_TERM_COLOR=always RUST_BACKTRACE=full CI=true CARGO_PROFILE_DEV_DEBUG=false CARGO_PROFILE_TEST_DEBUG=false CARGO_PROFILE_DEV_OPT_LEVEL=1 CARGO_PROFILE_DEV_OVERFLOW_CHECKS=false CARGO_TARGET_DIR=target ROCKSDB_DISABLE_JEMALLOC=1 GITHUB_ACTION_PATH=/home/github/70073145678/actions/Swatinem-rust-cache@v2 "${CURRENT_ENV[@]}" INPUT_SHARED-KEY=rocketmq-rust-ubuntu-latest INPUT_WORKSPACES='.
' INPUT_ENV-VARS='CC
CXX
LIBCLANG_PATH
ROCKSDB_DISABLE_JEMALLOC
' INPUT_PREFIX-KEY=v0-rust INPUT_ADD-JOB-ID-KEY=true INPUT_ADD-RUST-ENVIRONMENT-HASH-KEY=true INPUT_CACHE-TARGETS=true INPUT_CACHE-ALL-CRATES=false INPUT_CACHE-WORKSPACE-CRATES=false INPUT_SAVE-IF=true INPUT_CACHE-PROVIDER=github INPUT_CACHE-BIN=true INPUT_LOOKUP-ONLY=false INPUT_CMD-FORMAT='{0}' \
echo $(test "$_GITHUB_JOB_STATUS" = "success" && echo true || echo false))
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=5 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=Swatinem/rust-cache GITHUB_ACTIONS=true GITHUB_ACTOR=rocketmq-rust-bot GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/main GITHUB_REF_NAME=main GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=mxsm/rocketmq-rust GITHUB_REPOSITORY_OWNER=mxsm GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=bcdcb93be3d13fb8b8a989b6407050d674ac1a30 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='RocketMQ Rust CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_TERM_COLOR=always RUST_BACKTRACE=full CI=true CARGO_PROFILE_DEV_DEBUG=false CARGO_PROFILE_TEST_DEBUG=false CARGO_PROFILE_DEV_OPT_LEVEL=1 CARGO_PROFILE_DEV_OVERFLOW_CHECKS=false CARGO_TARGET_DIR=target ROCKSDB_DISABLE_JEMALLOC=1 GITHUB_ACTION_PATH=/home/github/70073145678/actions/Swatinem-rust-cache@v2 "${CURRENT_ENV[@]}" INPUT_SHARED-KEY=rocketmq-rust-ubuntu-latest INPUT_WORKSPACES='.
' INPUT_ENV-VARS='CC
CXX
LIBCLANG_PATH
ROCKSDB_DISABLE_JEMALLOC
' INPUT_PREFIX-KEY=v0-rust INPUT_ADD-JOB-ID-KEY=true INPUT_ADD-RUST-ENVIRONMENT-HASH-KEY=true INPUT_CACHE-TARGETS=true INPUT_CACHE-ALL-CRATES=false INPUT_CACHE-WORKSPACE-CRATES=false INPUT_SAVE-IF=true INPUT_CACHE-PROVIDER=github INPUT_CACHE-BIN=true INPUT_LOOKUP-ONLY=false INPUT_CMD-FORMAT='{0}' \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run Swatinem/rust-cache@v2
echo "##[endgroup]"
echo node /home/github/70073145678/actions/Swatinem-rust-cache@v2/dist/restore/index.js > /home/github/70073145678/steps/bugswarm_cmd.sh
chmod u+x /home/github/70073145678/steps/bugswarm_cmd.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=5 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=Swatinem/rust-cache GITHUB_ACTIONS=true GITHUB_ACTOR=rocketmq-rust-bot GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/main GITHUB_REF_NAME=main GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=mxsm/rocketmq-rust GITHUB_REPOSITORY_OWNER=mxsm GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=bcdcb93be3d13fb8b8a989b6407050d674ac1a30 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='RocketMQ Rust CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_TERM_COLOR=always RUST_BACKTRACE=full CI=true CARGO_PROFILE_DEV_DEBUG=false CARGO_PROFILE_TEST_DEBUG=false CARGO_PROFILE_DEV_OPT_LEVEL=1 CARGO_PROFILE_DEV_OVERFLOW_CHECKS=false CARGO_TARGET_DIR=target ROCKSDB_DISABLE_JEMALLOC=1 GITHUB_ACTION_PATH=/home/github/70073145678/actions/Swatinem-rust-cache@v2 "${CURRENT_ENV[@]}" INPUT_SHARED-KEY=rocketmq-rust-ubuntu-latest INPUT_WORKSPACES='.
' INPUT_ENV-VARS='CC
CXX
LIBCLANG_PATH
ROCKSDB_DISABLE_JEMALLOC
' INPUT_PREFIX-KEY=v0-rust INPUT_ADD-JOB-ID-KEY=true INPUT_ADD-RUST-ENVIRONMENT-HASH-KEY=true INPUT_CACHE-TARGETS=true INPUT_CACHE-ALL-CRATES=false INPUT_CACHE-WORKSPACE-CRATES=false INPUT_SAVE-IF=true INPUT_CACHE-PROVIDER=github INPUT_CACHE-BIN=true INPUT_LOOKUP-ONLY=false INPUT_CMD-FORMAT='{0}' \
bash -e /home/github/70073145678/steps/bugswarm_cmd.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=5 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=Swatinem/rust-cache GITHUB_ACTIONS=true GITHUB_ACTOR=rocketmq-rust-bot GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/main GITHUB_REF_NAME=main GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=mxsm/rocketmq-rust GITHUB_REPOSITORY_OWNER=mxsm GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=bcdcb93be3d13fb8b8a989b6407050d674ac1a30 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='RocketMQ Rust CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_TERM_COLOR=always RUST_BACKTRACE=full CI=true CARGO_PROFILE_DEV_DEBUG=false CARGO_PROFILE_TEST_DEBUG=false CARGO_PROFILE_DEV_OPT_LEVEL=1 CARGO_PROFILE_DEV_OVERFLOW_CHECKS=false CARGO_TARGET_DIR=target ROCKSDB_DISABLE_JEMALLOC=1 GITHUB_ACTION_PATH=/home/github/70073145678/actions/Swatinem-rust-cache@v2 "${CURRENT_ENV[@]}" INPUT_SHARED-KEY=rocketmq-rust-ubuntu-latest INPUT_WORKSPACES='.
' INPUT_ENV-VARS='CC
CXX
LIBCLANG_PATH
ROCKSDB_DISABLE_JEMALLOC
' INPUT_PREFIX-KEY=v0-rust INPUT_ADD-JOB-ID-KEY=true INPUT_ADD-RUST-ENVIRONMENT-HASH-KEY=true INPUT_CACHE-TARGETS=true INPUT_CACHE-ALL-CRATES=false INPUT_CACHE-WORKSPACE-CRATES=false INPUT_SAVE-IF=true INPUT_CACHE-PROVIDER=github INPUT_CACHE-BIN=true INPUT_LOOKUP-ONLY=false INPUT_CMD-FORMAT='{0}' \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=5 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=Swatinem/rust-cache GITHUB_ACTIONS=true GITHUB_ACTOR=rocketmq-rust-bot GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/main GITHUB_REF_NAME=main GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=mxsm/rocketmq-rust GITHUB_REPOSITORY_OWNER=mxsm GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=bcdcb93be3d13fb8b8a989b6407050d674ac1a30 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='RocketMQ Rust CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_TERM_COLOR=always RUST_BACKTRACE=full CI=true CARGO_PROFILE_DEV_DEBUG=false CARGO_PROFILE_TEST_DEBUG=false CARGO_PROFILE_DEV_OPT_LEVEL=1 CARGO_PROFILE_DEV_OVERFLOW_CHECKS=false CARGO_TARGET_DIR=target ROCKSDB_DISABLE_JEMALLOC=1 GITHUB_ACTION_PATH=/home/github/70073145678/actions/Swatinem-rust-cache@v2 "${CURRENT_ENV[@]}" INPUT_SHARED-KEY=rocketmq-rust-ubuntu-latest INPUT_WORKSPACES='.
' INPUT_ENV-VARS='CC
CXX
LIBCLANG_PATH
ROCKSDB_DISABLE_JEMALLOC
' INPUT_PREFIX-KEY=v0-rust INPUT_ADD-JOB-ID-KEY=true INPUT_ADD-RUST-ENVIRONMENT-HASH-KEY=true INPUT_CACHE-TARGETS=true INPUT_CACHE-ALL-CRATES=false INPUT_CACHE-WORKSPACE-CRATES=false INPUT_SAVE-IF=true INPUT_CACHE-PROVIDER=github INPUT_CACHE-BIN=true INPUT_LOOKUP-ONLY=false INPUT_CMD-FORMAT='{0}' \
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=6 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=rocketmq-rust-bot GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/main GITHUB_REF_NAME=main GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=mxsm/rocketmq-rust GITHUB_REPOSITORY_OWNER=mxsm GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=bcdcb93be3d13fb8b8a989b6407050d674ac1a30 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='RocketMQ Rust CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_TERM_COLOR=always RUST_BACKTRACE=full CI=true CARGO_PROFILE_DEV_DEBUG=false CARGO_PROFILE_TEST_DEBUG=false CARGO_PROFILE_DEV_OPT_LEVEL=1 CARGO_PROFILE_DEV_OVERFLOW_CHECKS=false CARGO_TARGET_DIR=target ROCKSDB_DISABLE_JEMALLOC=1 "${CURRENT_ENV[@]}" \
echo $(test "$_GITHUB_JOB_STATUS" = "success" && echo true || echo false))
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=6 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=rocketmq-rust-bot GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/main GITHUB_REF_NAME=main GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=mxsm/rocketmq-rust GITHUB_REPOSITORY_OWNER=mxsm GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=bcdcb93be3d13fb8b8a989b6407050d674ac1a30 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='RocketMQ Rust CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_TERM_COLOR=always RUST_BACKTRACE=full CI=true CARGO_PROFILE_DEV_DEBUG=false CARGO_PROFILE_TEST_DEBUG=false CARGO_PROFILE_DEV_OPT_LEVEL=1 CARGO_PROFILE_DEV_OVERFLOW_CHECKS=false CARGO_TARGET_DIR=target ROCKSDB_DISABLE_JEMALLOC=1 "${CURRENT_ENV[@]}" \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run 'cargo build --workspace --all-features'
echo "##[endgroup]"
echo 'cargo build --workspace --all-features' > /home/github/70073145678/steps/bugswarm_6.sh
chmod u+x /home/github/70073145678/steps/bugswarm_6.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=6 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=rocketmq-rust-bot GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/main GITHUB_REF_NAME=main GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=mxsm/rocketmq-rust GITHUB_REPOSITORY_OWNER=mxsm GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=bcdcb93be3d13fb8b8a989b6407050d674ac1a30 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='RocketMQ Rust CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_TERM_COLOR=always RUST_BACKTRACE=full CI=true CARGO_PROFILE_DEV_DEBUG=false CARGO_PROFILE_TEST_DEBUG=false CARGO_PROFILE_DEV_OPT_LEVEL=1 CARGO_PROFILE_DEV_OVERFLOW_CHECKS=false CARGO_TARGET_DIR=target ROCKSDB_DISABLE_JEMALLOC=1 "${CURRENT_ENV[@]}" \
bash -e /home/github/70073145678/steps/bugswarm_6.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=6 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=rocketmq-rust-bot GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/main GITHUB_REF_NAME=main GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=mxsm/rocketmq-rust GITHUB_REPOSITORY_OWNER=mxsm GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=bcdcb93be3d13fb8b8a989b6407050d674ac1a30 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='RocketMQ Rust CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_TERM_COLOR=always RUST_BACKTRACE=full CI=true CARGO_PROFILE_DEV_DEBUG=false CARGO_PROFILE_TEST_DEBUG=false CARGO_PROFILE_DEV_OPT_LEVEL=1 CARGO_PROFILE_DEV_OVERFLOW_CHECKS=false CARGO_TARGET_DIR=target ROCKSDB_DISABLE_JEMALLOC=1 "${CURRENT_ENV[@]}" \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=6 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=rocketmq-rust-bot GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/main GITHUB_REF_NAME=main GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=mxsm/rocketmq-rust GITHUB_REPOSITORY_OWNER=mxsm GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=bcdcb93be3d13fb8b8a989b6407050d674ac1a30 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='RocketMQ Rust CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_TERM_COLOR=always RUST_BACKTRACE=full CI=true CARGO_PROFILE_DEV_DEBUG=false CARGO_PROFILE_TEST_DEBUG=false CARGO_PROFILE_DEV_OPT_LEVEL=1 CARGO_PROFILE_DEV_OVERFLOW_CHECKS=false CARGO_TARGET_DIR=target ROCKSDB_DISABLE_JEMALLOC=1 "${CURRENT_ENV[@]}" \
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=7 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=rocketmq-rust-bot GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/main GITHUB_REF_NAME=main GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=mxsm/rocketmq-rust GITHUB_REPOSITORY_OWNER=mxsm GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=bcdcb93be3d13fb8b8a989b6407050d674ac1a30 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='RocketMQ Rust CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_TERM_COLOR=always RUST_BACKTRACE=full CI=true CARGO_PROFILE_DEV_DEBUG=false CARGO_PROFILE_TEST_DEBUG=false CARGO_PROFILE_DEV_OPT_LEVEL=1 CARGO_PROFILE_DEV_OVERFLOW_CHECKS=false CARGO_TARGET_DIR=target ROCKSDB_DISABLE_JEMALLOC=1 "${CURRENT_ENV[@]}" \
echo "$(/home/github/70073145678/helpers/eval_expression p:'(' f:success p:'(' p:')' p:')' o:'&&' p:'(' s:ubuntu-latest o:== s:ubuntu-latest p:')')")
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=7 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=rocketmq-rust-bot GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/main GITHUB_REF_NAME=main GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=mxsm/rocketmq-rust GITHUB_REPOSITORY_OWNER=mxsm GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=bcdcb93be3d13fb8b8a989b6407050d674ac1a30 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='RocketMQ Rust CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_TERM_COLOR=always RUST_BACKTRACE=full CI=true CARGO_PROFILE_DEV_DEBUG=false CARGO_PROFILE_TEST_DEBUG=false CARGO_PROFILE_DEV_OPT_LEVEL=1 CARGO_PROFILE_DEV_OVERFLOW_CHECKS=false CARGO_TARGET_DIR=target ROCKSDB_DISABLE_JEMALLOC=1 "${CURRENT_ENV[@]}" \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run 'cargo test --workspace --all-features'
echo "##[endgroup]"
echo 'cargo test --workspace --all-features' > /home/github/70073145678/steps/bugswarm_7.sh
chmod u+x /home/github/70073145678/steps/bugswarm_7.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=7 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=rocketmq-rust-bot GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/main GITHUB_REF_NAME=main GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=mxsm/rocketmq-rust GITHUB_REPOSITORY_OWNER=mxsm GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=bcdcb93be3d13fb8b8a989b6407050d674ac1a30 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='RocketMQ Rust CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_TERM_COLOR=always RUST_BACKTRACE=full CI=true CARGO_PROFILE_DEV_DEBUG=false CARGO_PROFILE_TEST_DEBUG=false CARGO_PROFILE_DEV_OPT_LEVEL=1 CARGO_PROFILE_DEV_OVERFLOW_CHECKS=false CARGO_TARGET_DIR=target ROCKSDB_DISABLE_JEMALLOC=1 "${CURRENT_ENV[@]}" \
bash -e /home/github/70073145678/steps/bugswarm_7.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=7 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=rocketmq-rust-bot GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/main GITHUB_REF_NAME=main GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=mxsm/rocketmq-rust GITHUB_REPOSITORY_OWNER=mxsm GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=bcdcb93be3d13fb8b8a989b6407050d674ac1a30 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='RocketMQ Rust CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_TERM_COLOR=always RUST_BACKTRACE=full CI=true CARGO_PROFILE_DEV_DEBUG=false CARGO_PROFILE_TEST_DEBUG=false CARGO_PROFILE_DEV_OPT_LEVEL=1 CARGO_PROFILE_DEV_OVERFLOW_CHECKS=false CARGO_TARGET_DIR=target ROCKSDB_DISABLE_JEMALLOC=1 "${CURRENT_ENV[@]}" \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=7 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=rocketmq-rust-bot GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/main GITHUB_REF_NAME=main GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=mxsm/rocketmq-rust GITHUB_REPOSITORY_OWNER=mxsm GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=bcdcb93be3d13fb8b8a989b6407050d674ac1a30 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='RocketMQ Rust CI' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_TERM_COLOR=always RUST_BACKTRACE=full CI=true CARGO_PROFILE_DEV_DEBUG=false CARGO_PROFILE_TEST_DEBUG=false CARGO_PROFILE_DEV_OPT_LEVEL=1 CARGO_PROFILE_DEV_OVERFLOW_CHECKS=false CARGO_TARGET_DIR=target ROCKSDB_DISABLE_JEMALLOC=1 "${CURRENT_ENV[@]}" \
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
   bash -e $ACTIONS_RUNNER_HOOK_JOB_COMPLETED 70073145678 passed
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
