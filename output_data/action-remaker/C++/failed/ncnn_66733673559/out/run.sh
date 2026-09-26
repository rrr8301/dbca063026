#!/usr/bin/env bash
export GITHUB_WORKSPACE=/home/github/build/Tencent/ncnn

if [[ ! -z "$ACTIONS_RUNNER_HOOK_JOB_STARTED" ]]; then
   echo "A job started hook has been configured by the self-hosted runner administrator"
   echo "##[group]Run '$ACTIONS_RUNNER_HOOK_JOB_STARTED'"
   echo "##[endgroup]"
   bash -e $ACTIONS_RUNNER_HOOK_JOB_STARTED 66733673559 failed
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

cp /home/github/66733673559/event.json /home/github/workflow/event.json
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=1 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=nihui GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=gemm-x86-bf16s GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/gemm-x86-bf16s GITHUB_REF_NAME=gemm-x86-bf16s GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=Tencent/ncnn GITHUB_REPOSITORY_OWNER=Tencent GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=91ba57c305ba4dd2d14980e69aaece4e0ed9d381 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=linux-x64-cpu-clang GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 "${CURRENT_ENV[@]}" \
echo $(test "$_GITHUB_JOB_STATUS" = "success" && echo true || echo false))
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=1 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=nihui GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=gemm-x86-bf16s GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/gemm-x86-bf16s GITHUB_REF_NAME=gemm-x86-bf16s GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=Tencent/ncnn GITHUB_REPOSITORY_OWNER=Tencent GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=91ba57c305ba4dd2d14980e69aaece4e0ed9d381 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=linux-x64-cpu-clang GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 "${CURRENT_ENV[@]}" \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run 'sudo apt-get update'
echo "##[endgroup]"
echo 'sudo apt-get update' > /home/github/66733673559/steps/bugswarm_1.sh
chmod u+x /home/github/66733673559/steps/bugswarm_1.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=1 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=nihui GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=gemm-x86-bf16s GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/gemm-x86-bf16s GITHUB_REF_NAME=gemm-x86-bf16s GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=Tencent/ncnn GITHUB_REPOSITORY_OWNER=Tencent GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=91ba57c305ba4dd2d14980e69aaece4e0ed9d381 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=linux-x64-cpu-clang GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 "${CURRENT_ENV[@]}" \
bash -e /home/github/66733673559/steps/bugswarm_1.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=1 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=nihui GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=gemm-x86-bf16s GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/gemm-x86-bf16s GITHUB_REF_NAME=gemm-x86-bf16s GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=Tencent/ncnn GITHUB_REPOSITORY_OWNER=Tencent GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=91ba57c305ba4dd2d14980e69aaece4e0ed9d381 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=linux-x64-cpu-clang GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 "${CURRENT_ENV[@]}" \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=1 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=nihui GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=gemm-x86-bf16s GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/gemm-x86-bf16s GITHUB_REF_NAME=gemm-x86-bf16s GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=Tencent/ncnn GITHUB_REPOSITORY_OWNER=Tencent GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=91ba57c305ba4dd2d14980e69aaece4e0ed9d381 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=linux-x64-cpu-clang GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 "${CURRENT_ENV[@]}" \
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=2 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=nihui GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=gemm-x86-bf16s GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/gemm-x86-bf16s GITHUB_REF_NAME=gemm-x86-bf16s GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=Tencent/ncnn GITHUB_REPOSITORY_OWNER=Tencent GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=91ba57c305ba4dd2d14980e69aaece4e0ed9d381 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=linux-x64-cpu-clang GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 "${CURRENT_ENV[@]}" \
echo $(test "$_GITHUB_JOB_STATUS" = "success" && echo true || echo false))
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=2 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=nihui GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=gemm-x86-bf16s GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/gemm-x86-bf16s GITHUB_REF_NAME=gemm-x86-bf16s GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=Tencent/ncnn GITHUB_REPOSITORY_OWNER=Tencent GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=91ba57c305ba4dd2d14980e69aaece4e0ed9d381 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=linux-x64-cpu-clang GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 "${CURRENT_ENV[@]}" \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run 'sudo apt-get install libprotobuf-dev protobuf-compiler libopencv-dev'
echo "##[endgroup]"
echo 'sudo apt-get install libprotobuf-dev protobuf-compiler libopencv-dev' > /home/github/66733673559/steps/bugswarm_2.sh
chmod u+x /home/github/66733673559/steps/bugswarm_2.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=2 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=nihui GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=gemm-x86-bf16s GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/gemm-x86-bf16s GITHUB_REF_NAME=gemm-x86-bf16s GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=Tencent/ncnn GITHUB_REPOSITORY_OWNER=Tencent GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=91ba57c305ba4dd2d14980e69aaece4e0ed9d381 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=linux-x64-cpu-clang GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 "${CURRENT_ENV[@]}" \
bash -e /home/github/66733673559/steps/bugswarm_2.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=2 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=nihui GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=gemm-x86-bf16s GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/gemm-x86-bf16s GITHUB_REF_NAME=gemm-x86-bf16s GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=Tencent/ncnn GITHUB_REPOSITORY_OWNER=Tencent GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=91ba57c305ba4dd2d14980e69aaece4e0ed9d381 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=linux-x64-cpu-clang GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 "${CURRENT_ENV[@]}" \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=2 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=nihui GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=gemm-x86-bf16s GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/gemm-x86-bf16s GITHUB_REF_NAME=gemm-x86-bf16s GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=Tencent/ncnn GITHUB_REPOSITORY_OWNER=Tencent GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=91ba57c305ba4dd2d14980e69aaece4e0ed9d381 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=linux-x64-cpu-clang GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 "${CURRENT_ENV[@]}" \
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=3 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=nihui GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=gemm-x86-bf16s GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/gemm-x86-bf16s GITHUB_REF_NAME=gemm-x86-bf16s GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=Tencent/ncnn GITHUB_REPOSITORY_OWNER=Tencent GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=91ba57c305ba4dd2d14980e69aaece4e0ed9d381 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=linux-x64-cpu-clang GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 "${CURRENT_ENV[@]}" CC=clang CXX=clang++ \
echo $(test "$_GITHUB_JOB_STATUS" = "success" && echo true || echo false))
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=3 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=nihui GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=gemm-x86-bf16s GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/gemm-x86-bf16s GITHUB_REF_NAME=gemm-x86-bf16s GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=Tencent/ncnn GITHUB_REPOSITORY_OWNER=Tencent GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=91ba57c305ba4dd2d14980e69aaece4e0ed9d381 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=linux-x64-cpu-clang GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 "${CURRENT_ENV[@]}" CC=clang CXX=clang++ \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run 'mkdir build-sse2 && cd build-sse2'
echo "##[endgroup]"
echo 'mkdir build-sse2 && cd build-sse2
cmake -DNCNN_AVX=OFF -DNCNN_AVX2=OFF -DNCNN_BUILD_TESTS=ON ..
cmake --build . -j $(nproc)
' > /home/github/66733673559/steps/bugswarm_3.sh
chmod u+x /home/github/66733673559/steps/bugswarm_3.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=3 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=nihui GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=gemm-x86-bf16s GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/gemm-x86-bf16s GITHUB_REF_NAME=gemm-x86-bf16s GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=Tencent/ncnn GITHUB_REPOSITORY_OWNER=Tencent GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=91ba57c305ba4dd2d14980e69aaece4e0ed9d381 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=linux-x64-cpu-clang GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 "${CURRENT_ENV[@]}" CC=clang CXX=clang++ \
bash -e /home/github/66733673559/steps/bugswarm_3.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=3 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=nihui GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=gemm-x86-bf16s GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/gemm-x86-bf16s GITHUB_REF_NAME=gemm-x86-bf16s GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=Tencent/ncnn GITHUB_REPOSITORY_OWNER=Tencent GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=91ba57c305ba4dd2d14980e69aaece4e0ed9d381 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=linux-x64-cpu-clang GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 "${CURRENT_ENV[@]}" CC=clang CXX=clang++ \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=3 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=nihui GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=gemm-x86-bf16s GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/gemm-x86-bf16s GITHUB_REF_NAME=gemm-x86-bf16s GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=Tencent/ncnn GITHUB_REPOSITORY_OWNER=Tencent GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=91ba57c305ba4dd2d14980e69aaece4e0ed9d381 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=linux-x64-cpu-clang GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 "${CURRENT_ENV[@]}" CC=clang CXX=clang++ \
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=4 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=nihui GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=gemm-x86-bf16s GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/gemm-x86-bf16s GITHUB_REF_NAME=gemm-x86-bf16s GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=Tencent/ncnn GITHUB_REPOSITORY_OWNER=Tencent GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=91ba57c305ba4dd2d14980e69aaece4e0ed9d381 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=linux-x64-cpu-clang GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 "${CURRENT_ENV[@]}" \
echo $(test "$_GITHUB_JOB_STATUS" = "success" && echo true || echo false))
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=4 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=nihui GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=gemm-x86-bf16s GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/gemm-x86-bf16s GITHUB_REF_NAME=gemm-x86-bf16s GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=Tencent/ncnn GITHUB_REPOSITORY_OWNER=Tencent GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=91ba57c305ba4dd2d14980e69aaece4e0ed9d381 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=linux-x64-cpu-clang GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 "${CURRENT_ENV[@]}" \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run 'cd build-sse2 && ctest --output-on-failure -j $(nproc)'
echo "##[endgroup]"
echo 'cd build-sse2 && ctest --output-on-failure -j $(nproc)' > /home/github/66733673559/steps/bugswarm_4.sh
chmod u+x /home/github/66733673559/steps/bugswarm_4.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=4 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=nihui GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=gemm-x86-bf16s GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/gemm-x86-bf16s GITHUB_REF_NAME=gemm-x86-bf16s GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=Tencent/ncnn GITHUB_REPOSITORY_OWNER=Tencent GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=91ba57c305ba4dd2d14980e69aaece4e0ed9d381 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=linux-x64-cpu-clang GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 "${CURRENT_ENV[@]}" \
bash -e /home/github/66733673559/steps/bugswarm_4.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=4 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=nihui GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=gemm-x86-bf16s GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/gemm-x86-bf16s GITHUB_REF_NAME=gemm-x86-bf16s GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=Tencent/ncnn GITHUB_REPOSITORY_OWNER=Tencent GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=91ba57c305ba4dd2d14980e69aaece4e0ed9d381 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=linux-x64-cpu-clang GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 "${CURRENT_ENV[@]}" \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=4 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=nihui GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=gemm-x86-bf16s GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/gemm-x86-bf16s GITHUB_REF_NAME=gemm-x86-bf16s GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=Tencent/ncnn GITHUB_REPOSITORY_OWNER=Tencent GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=91ba57c305ba4dd2d14980e69aaece4e0ed9d381 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=linux-x64-cpu-clang GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 "${CURRENT_ENV[@]}" \
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=5 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=nihui GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=gemm-x86-bf16s GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/gemm-x86-bf16s GITHUB_REF_NAME=gemm-x86-bf16s GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=Tencent/ncnn GITHUB_REPOSITORY_OWNER=Tencent GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=91ba57c305ba4dd2d14980e69aaece4e0ed9d381 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=linux-x64-cpu-clang GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 "${CURRENT_ENV[@]}" CC=clang CXX=clang++ \
echo $(test "$_GITHUB_JOB_STATUS" = "success" && echo true || echo false))
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=5 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=nihui GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=gemm-x86-bf16s GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/gemm-x86-bf16s GITHUB_REF_NAME=gemm-x86-bf16s GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=Tencent/ncnn GITHUB_REPOSITORY_OWNER=Tencent GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=91ba57c305ba4dd2d14980e69aaece4e0ed9d381 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=linux-x64-cpu-clang GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 "${CURRENT_ENV[@]}" CC=clang CXX=clang++ \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run 'mkdir build-shared && cd build-shared'
echo "##[endgroup]"
echo 'mkdir build-shared && cd build-shared
cmake -DNCNN_AVX2=ON -DNCNN_SHARED_LIB=ON ..
cmake --build . -j $(nproc)
' > /home/github/66733673559/steps/bugswarm_5.sh
chmod u+x /home/github/66733673559/steps/bugswarm_5.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=5 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=nihui GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=gemm-x86-bf16s GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/gemm-x86-bf16s GITHUB_REF_NAME=gemm-x86-bf16s GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=Tencent/ncnn GITHUB_REPOSITORY_OWNER=Tencent GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=91ba57c305ba4dd2d14980e69aaece4e0ed9d381 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=linux-x64-cpu-clang GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 "${CURRENT_ENV[@]}" CC=clang CXX=clang++ \
bash -e /home/github/66733673559/steps/bugswarm_5.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=5 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=nihui GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=gemm-x86-bf16s GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/gemm-x86-bf16s GITHUB_REF_NAME=gemm-x86-bf16s GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=Tencent/ncnn GITHUB_REPOSITORY_OWNER=Tencent GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=91ba57c305ba4dd2d14980e69aaece4e0ed9d381 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=linux-x64-cpu-clang GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 "${CURRENT_ENV[@]}" CC=clang CXX=clang++ \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=5 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=nihui GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=gemm-x86-bf16s GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/gemm-x86-bf16s GITHUB_REF_NAME=gemm-x86-bf16s GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=Tencent/ncnn GITHUB_REPOSITORY_OWNER=Tencent GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=91ba57c305ba4dd2d14980e69aaece4e0ed9d381 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=linux-x64-cpu-clang GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 "${CURRENT_ENV[@]}" CC=clang CXX=clang++ \
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=6 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=nihui GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=gemm-x86-bf16s GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/gemm-x86-bf16s GITHUB_REF_NAME=gemm-x86-bf16s GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=Tencent/ncnn GITHUB_REPOSITORY_OWNER=Tencent GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=91ba57c305ba4dd2d14980e69aaece4e0ed9d381 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=linux-x64-cpu-clang GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 "${CURRENT_ENV[@]}" CC=clang CXX=clang++ \
echo $(test "$_GITHUB_JOB_STATUS" = "success" && echo true || echo false))
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=6 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=nihui GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=gemm-x86-bf16s GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/gemm-x86-bf16s GITHUB_REF_NAME=gemm-x86-bf16s GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=Tencent/ncnn GITHUB_REPOSITORY_OWNER=Tencent GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=91ba57c305ba4dd2d14980e69aaece4e0ed9d381 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=linux-x64-cpu-clang GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 "${CURRENT_ENV[@]}" CC=clang CXX=clang++ \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run 'mkdir build-avx2 && cd build-avx2'
echo "##[endgroup]"
echo 'mkdir build-avx2 && cd build-avx2
cmake -DNCNN_AVX2=ON -DNCNN_BUILD_TESTS=ON ..
cmake --build . -j $(nproc)
' > /home/github/66733673559/steps/bugswarm_6.sh
chmod u+x /home/github/66733673559/steps/bugswarm_6.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=6 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=nihui GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=gemm-x86-bf16s GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/gemm-x86-bf16s GITHUB_REF_NAME=gemm-x86-bf16s GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=Tencent/ncnn GITHUB_REPOSITORY_OWNER=Tencent GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=91ba57c305ba4dd2d14980e69aaece4e0ed9d381 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=linux-x64-cpu-clang GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 "${CURRENT_ENV[@]}" CC=clang CXX=clang++ \
bash -e /home/github/66733673559/steps/bugswarm_6.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=6 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=nihui GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=gemm-x86-bf16s GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/gemm-x86-bf16s GITHUB_REF_NAME=gemm-x86-bf16s GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=Tencent/ncnn GITHUB_REPOSITORY_OWNER=Tencent GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=91ba57c305ba4dd2d14980e69aaece4e0ed9d381 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=linux-x64-cpu-clang GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 "${CURRENT_ENV[@]}" CC=clang CXX=clang++ \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=6 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=nihui GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=gemm-x86-bf16s GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/gemm-x86-bf16s GITHUB_REF_NAME=gemm-x86-bf16s GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=Tencent/ncnn GITHUB_REPOSITORY_OWNER=Tencent GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=91ba57c305ba4dd2d14980e69aaece4e0ed9d381 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=linux-x64-cpu-clang GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 "${CURRENT_ENV[@]}" CC=clang CXX=clang++ \
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=7 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=nihui GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=gemm-x86-bf16s GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/gemm-x86-bf16s GITHUB_REF_NAME=gemm-x86-bf16s GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=Tencent/ncnn GITHUB_REPOSITORY_OWNER=Tencent GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=91ba57c305ba4dd2d14980e69aaece4e0ed9d381 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=linux-x64-cpu-clang GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 "${CURRENT_ENV[@]}" \
echo $(test "$_GITHUB_JOB_STATUS" = "success" && echo true || echo false))
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=7 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=nihui GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=gemm-x86-bf16s GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/gemm-x86-bf16s GITHUB_REF_NAME=gemm-x86-bf16s GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=Tencent/ncnn GITHUB_REPOSITORY_OWNER=Tencent GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=91ba57c305ba4dd2d14980e69aaece4e0ed9d381 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=linux-x64-cpu-clang GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 "${CURRENT_ENV[@]}" \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run 'cd build-avx2 && ctest --output-on-failure -j $(nproc)'
echo "##[endgroup]"
echo 'cd build-avx2 && ctest --output-on-failure -j $(nproc)' > /home/github/66733673559/steps/bugswarm_7.sh
chmod u+x /home/github/66733673559/steps/bugswarm_7.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=7 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=nihui GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=gemm-x86-bf16s GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/gemm-x86-bf16s GITHUB_REF_NAME=gemm-x86-bf16s GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=Tencent/ncnn GITHUB_REPOSITORY_OWNER=Tencent GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=91ba57c305ba4dd2d14980e69aaece4e0ed9d381 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=linux-x64-cpu-clang GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 "${CURRENT_ENV[@]}" \
bash -e /home/github/66733673559/steps/bugswarm_7.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=7 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=nihui GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=gemm-x86-bf16s GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/gemm-x86-bf16s GITHUB_REF_NAME=gemm-x86-bf16s GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=Tencent/ncnn GITHUB_REPOSITORY_OWNER=Tencent GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=91ba57c305ba4dd2d14980e69aaece4e0ed9d381 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=linux-x64-cpu-clang GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 "${CURRENT_ENV[@]}" \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=7 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=nihui GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=gemm-x86-bf16s GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/gemm-x86-bf16s GITHUB_REF_NAME=gemm-x86-bf16s GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=Tencent/ncnn GITHUB_REPOSITORY_OWNER=Tencent GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=91ba57c305ba4dd2d14980e69aaece4e0ed9d381 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=linux-x64-cpu-clang GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 "${CURRENT_ENV[@]}" \
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=8 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=nihui GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=gemm-x86-bf16s GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/gemm-x86-bf16s GITHUB_REF_NAME=gemm-x86-bf16s GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=Tencent/ncnn GITHUB_REPOSITORY_OWNER=Tencent GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=91ba57c305ba4dd2d14980e69aaece4e0ed9d381 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=linux-x64-cpu-clang GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 "${CURRENT_ENV[@]}" CC=clang CXX=clang++ \
echo $(test "$_GITHUB_JOB_STATUS" = "success" && echo true || echo false))
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=8 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=nihui GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=gemm-x86-bf16s GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/gemm-x86-bf16s GITHUB_REF_NAME=gemm-x86-bf16s GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=Tencent/ncnn GITHUB_REPOSITORY_OWNER=Tencent GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=91ba57c305ba4dd2d14980e69aaece4e0ed9d381 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=linux-x64-cpu-clang GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 "${CURRENT_ENV[@]}" CC=clang CXX=clang++ \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run 'mkdir build-avx && cd build-avx'
echo "##[endgroup]"
echo 'mkdir build-avx && cd build-avx
cmake -DNCNN_AVX2=OFF -DNCNN_AVX=ON -DNCNN_BUILD_TESTS=ON ..
cmake --build . -j $(nproc)
' > /home/github/66733673559/steps/bugswarm_8.sh
chmod u+x /home/github/66733673559/steps/bugswarm_8.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=8 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=nihui GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=gemm-x86-bf16s GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/gemm-x86-bf16s GITHUB_REF_NAME=gemm-x86-bf16s GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=Tencent/ncnn GITHUB_REPOSITORY_OWNER=Tencent GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=91ba57c305ba4dd2d14980e69aaece4e0ed9d381 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=linux-x64-cpu-clang GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 "${CURRENT_ENV[@]}" CC=clang CXX=clang++ \
bash -e /home/github/66733673559/steps/bugswarm_8.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=8 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=nihui GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=gemm-x86-bf16s GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/gemm-x86-bf16s GITHUB_REF_NAME=gemm-x86-bf16s GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=Tencent/ncnn GITHUB_REPOSITORY_OWNER=Tencent GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=91ba57c305ba4dd2d14980e69aaece4e0ed9d381 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=linux-x64-cpu-clang GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 "${CURRENT_ENV[@]}" CC=clang CXX=clang++ \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=8 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=nihui GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=gemm-x86-bf16s GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/gemm-x86-bf16s GITHUB_REF_NAME=gemm-x86-bf16s GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=Tencent/ncnn GITHUB_REPOSITORY_OWNER=Tencent GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=91ba57c305ba4dd2d14980e69aaece4e0ed9d381 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=linux-x64-cpu-clang GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 "${CURRENT_ENV[@]}" CC=clang CXX=clang++ \
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=9 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=nihui GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=gemm-x86-bf16s GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/gemm-x86-bf16s GITHUB_REF_NAME=gemm-x86-bf16s GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=Tencent/ncnn GITHUB_REPOSITORY_OWNER=Tencent GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=91ba57c305ba4dd2d14980e69aaece4e0ed9d381 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=linux-x64-cpu-clang GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 "${CURRENT_ENV[@]}" \
echo $(test "$_GITHUB_JOB_STATUS" = "success" && echo true || echo false))
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=9 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=nihui GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=gemm-x86-bf16s GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/gemm-x86-bf16s GITHUB_REF_NAME=gemm-x86-bf16s GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=Tencent/ncnn GITHUB_REPOSITORY_OWNER=Tencent GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=91ba57c305ba4dd2d14980e69aaece4e0ed9d381 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=linux-x64-cpu-clang GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 "${CURRENT_ENV[@]}" \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run 'cd build-avx && ctest --output-on-failure -j $(nproc)'
echo "##[endgroup]"
echo 'cd build-avx && ctest --output-on-failure -j $(nproc)' > /home/github/66733673559/steps/bugswarm_9.sh
chmod u+x /home/github/66733673559/steps/bugswarm_9.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=9 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=nihui GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=gemm-x86-bf16s GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/gemm-x86-bf16s GITHUB_REF_NAME=gemm-x86-bf16s GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=Tencent/ncnn GITHUB_REPOSITORY_OWNER=Tencent GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=91ba57c305ba4dd2d14980e69aaece4e0ed9d381 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=linux-x64-cpu-clang GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 "${CURRENT_ENV[@]}" \
bash -e /home/github/66733673559/steps/bugswarm_9.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=9 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=nihui GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=gemm-x86-bf16s GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/gemm-x86-bf16s GITHUB_REF_NAME=gemm-x86-bf16s GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=Tencent/ncnn GITHUB_REPOSITORY_OWNER=Tencent GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=91ba57c305ba4dd2d14980e69aaece4e0ed9d381 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=linux-x64-cpu-clang GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 "${CURRENT_ENV[@]}" \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=9 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=nihui GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=gemm-x86-bf16s GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/gemm-x86-bf16s GITHUB_REF_NAME=gemm-x86-bf16s GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=Tencent/ncnn GITHUB_REPOSITORY_OWNER=Tencent GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=91ba57c305ba4dd2d14980e69aaece4e0ed9d381 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=linux-x64-cpu-clang GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 "${CURRENT_ENV[@]}" \
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=10 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=nihui GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=gemm-x86-bf16s GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/gemm-x86-bf16s GITHUB_REF_NAME=gemm-x86-bf16s GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=Tencent/ncnn GITHUB_REPOSITORY_OWNER=Tencent GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=91ba57c305ba4dd2d14980e69aaece4e0ed9d381 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=linux-x64-cpu-clang GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 "${CURRENT_ENV[@]}" CC=clang CXX=clang++ \
echo $(test "$_GITHUB_JOB_STATUS" = "success" && echo true || echo false))
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=10 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=nihui GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=gemm-x86-bf16s GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/gemm-x86-bf16s GITHUB_REF_NAME=gemm-x86-bf16s GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=Tencent/ncnn GITHUB_REPOSITORY_OWNER=Tencent GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=91ba57c305ba4dd2d14980e69aaece4e0ed9d381 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=linux-x64-cpu-clang GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 "${CURRENT_ENV[@]}" CC=clang CXX=clang++ \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run 'mkdir build-avx1-2 && cd build-avx1-2'
echo "##[endgroup]"
echo 'mkdir build-avx1-2 && cd build-avx1-2
cmake -DNCNN_AVX2=ON -DNCNN_AVX=ON -DNCNN_BUILD_TESTS=ON ..
cmake --build . -j $(nproc)
' > /home/github/66733673559/steps/bugswarm_10.sh
chmod u+x /home/github/66733673559/steps/bugswarm_10.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=10 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=nihui GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=gemm-x86-bf16s GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/gemm-x86-bf16s GITHUB_REF_NAME=gemm-x86-bf16s GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=Tencent/ncnn GITHUB_REPOSITORY_OWNER=Tencent GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=91ba57c305ba4dd2d14980e69aaece4e0ed9d381 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=linux-x64-cpu-clang GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 "${CURRENT_ENV[@]}" CC=clang CXX=clang++ \
bash -e /home/github/66733673559/steps/bugswarm_10.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=10 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=nihui GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=gemm-x86-bf16s GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/gemm-x86-bf16s GITHUB_REF_NAME=gemm-x86-bf16s GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=Tencent/ncnn GITHUB_REPOSITORY_OWNER=Tencent GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=91ba57c305ba4dd2d14980e69aaece4e0ed9d381 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=linux-x64-cpu-clang GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 "${CURRENT_ENV[@]}" CC=clang CXX=clang++ \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=10 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=nihui GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=gemm-x86-bf16s GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/gemm-x86-bf16s GITHUB_REF_NAME=gemm-x86-bf16s GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=Tencent/ncnn GITHUB_REPOSITORY_OWNER=Tencent GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=91ba57c305ba4dd2d14980e69aaece4e0ed9d381 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=linux-x64-cpu-clang GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 "${CURRENT_ENV[@]}" CC=clang CXX=clang++ \
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=11 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=nihui GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=gemm-x86-bf16s GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/gemm-x86-bf16s GITHUB_REF_NAME=gemm-x86-bf16s GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=Tencent/ncnn GITHUB_REPOSITORY_OWNER=Tencent GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=91ba57c305ba4dd2d14980e69aaece4e0ed9d381 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=linux-x64-cpu-clang GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 "${CURRENT_ENV[@]}" \
echo $(test "$_GITHUB_JOB_STATUS" = "success" && echo true || echo false))
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=11 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=nihui GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=gemm-x86-bf16s GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/gemm-x86-bf16s GITHUB_REF_NAME=gemm-x86-bf16s GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=Tencent/ncnn GITHUB_REPOSITORY_OWNER=Tencent GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=91ba57c305ba4dd2d14980e69aaece4e0ed9d381 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=linux-x64-cpu-clang GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 "${CURRENT_ENV[@]}" \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run 'cd build-avx1-2 && ctest --output-on-failure -j $(nproc)'
echo "##[endgroup]"
echo 'cd build-avx1-2 && ctest --output-on-failure -j $(nproc)' > /home/github/66733673559/steps/bugswarm_11.sh
chmod u+x /home/github/66733673559/steps/bugswarm_11.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=11 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=nihui GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=gemm-x86-bf16s GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/gemm-x86-bf16s GITHUB_REF_NAME=gemm-x86-bf16s GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=Tencent/ncnn GITHUB_REPOSITORY_OWNER=Tencent GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=91ba57c305ba4dd2d14980e69aaece4e0ed9d381 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=linux-x64-cpu-clang GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 "${CURRENT_ENV[@]}" \
bash -e /home/github/66733673559/steps/bugswarm_11.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=11 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=nihui GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=gemm-x86-bf16s GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/gemm-x86-bf16s GITHUB_REF_NAME=gemm-x86-bf16s GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=Tencent/ncnn GITHUB_REPOSITORY_OWNER=Tencent GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=91ba57c305ba4dd2d14980e69aaece4e0ed9d381 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=linux-x64-cpu-clang GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 "${CURRENT_ENV[@]}" \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=11 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=nihui GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=gemm-x86-bf16s GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/gemm-x86-bf16s GITHUB_REF_NAME=gemm-x86-bf16s GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=Tencent/ncnn GITHUB_REPOSITORY_OWNER=Tencent GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=91ba57c305ba4dd2d14980e69aaece4e0ed9d381 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=linux-x64-cpu-clang GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 "${CURRENT_ENV[@]}" \
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=12 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=nihui GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=gemm-x86-bf16s GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/gemm-x86-bf16s GITHUB_REF_NAME=gemm-x86-bf16s GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=Tencent/ncnn GITHUB_REPOSITORY_OWNER=Tencent GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=91ba57c305ba4dd2d14980e69aaece4e0ed9d381 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=linux-x64-cpu-clang GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 "${CURRENT_ENV[@]}" CC=clang CXX=clang++ \
echo $(test "$_GITHUB_JOB_STATUS" = "success" && echo true || echo false))
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=12 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=nihui GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=gemm-x86-bf16s GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/gemm-x86-bf16s GITHUB_REF_NAME=gemm-x86-bf16s GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=Tencent/ncnn GITHUB_REPOSITORY_OWNER=Tencent GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=91ba57c305ba4dd2d14980e69aaece4e0ed9d381 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=linux-x64-cpu-clang GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 "${CURRENT_ENV[@]}" CC=clang CXX=clang++ \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run 'mkdir build-noint8 && cd build-noint8'
echo "##[endgroup]"
echo 'mkdir build-noint8 && cd build-noint8
cmake -DNCNN_INT8=OFF -DNCNN_BUILD_TESTS=ON ..
cmake --build . -j $(nproc)
' > /home/github/66733673559/steps/bugswarm_12.sh
chmod u+x /home/github/66733673559/steps/bugswarm_12.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=12 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=nihui GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=gemm-x86-bf16s GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/gemm-x86-bf16s GITHUB_REF_NAME=gemm-x86-bf16s GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=Tencent/ncnn GITHUB_REPOSITORY_OWNER=Tencent GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=91ba57c305ba4dd2d14980e69aaece4e0ed9d381 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=linux-x64-cpu-clang GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 "${CURRENT_ENV[@]}" CC=clang CXX=clang++ \
bash -e /home/github/66733673559/steps/bugswarm_12.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=12 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=nihui GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=gemm-x86-bf16s GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/gemm-x86-bf16s GITHUB_REF_NAME=gemm-x86-bf16s GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=Tencent/ncnn GITHUB_REPOSITORY_OWNER=Tencent GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=91ba57c305ba4dd2d14980e69aaece4e0ed9d381 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=linux-x64-cpu-clang GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 "${CURRENT_ENV[@]}" CC=clang CXX=clang++ \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=12 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=nihui GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=gemm-x86-bf16s GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/gemm-x86-bf16s GITHUB_REF_NAME=gemm-x86-bf16s GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=Tencent/ncnn GITHUB_REPOSITORY_OWNER=Tencent GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=91ba57c305ba4dd2d14980e69aaece4e0ed9d381 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=linux-x64-cpu-clang GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 "${CURRENT_ENV[@]}" CC=clang CXX=clang++ \
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=13 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=nihui GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=gemm-x86-bf16s GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/gemm-x86-bf16s GITHUB_REF_NAME=gemm-x86-bf16s GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=Tencent/ncnn GITHUB_REPOSITORY_OWNER=Tencent GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=91ba57c305ba4dd2d14980e69aaece4e0ed9d381 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=linux-x64-cpu-clang GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 "${CURRENT_ENV[@]}" \
echo $(test "$_GITHUB_JOB_STATUS" = "success" && echo true || echo false))
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=13 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=nihui GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=gemm-x86-bf16s GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/gemm-x86-bf16s GITHUB_REF_NAME=gemm-x86-bf16s GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=Tencent/ncnn GITHUB_REPOSITORY_OWNER=Tencent GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=91ba57c305ba4dd2d14980e69aaece4e0ed9d381 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=linux-x64-cpu-clang GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 "${CURRENT_ENV[@]}" \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run 'cd build-noint8 && ctest --output-on-failure -j $(nproc)'
echo "##[endgroup]"
echo 'cd build-noint8 && ctest --output-on-failure -j $(nproc)' > /home/github/66733673559/steps/bugswarm_13.sh
chmod u+x /home/github/66733673559/steps/bugswarm_13.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=13 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=nihui GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=gemm-x86-bf16s GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/gemm-x86-bf16s GITHUB_REF_NAME=gemm-x86-bf16s GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=Tencent/ncnn GITHUB_REPOSITORY_OWNER=Tencent GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=91ba57c305ba4dd2d14980e69aaece4e0ed9d381 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=linux-x64-cpu-clang GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 "${CURRENT_ENV[@]}" \
bash -e /home/github/66733673559/steps/bugswarm_13.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=13 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=nihui GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=gemm-x86-bf16s GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/gemm-x86-bf16s GITHUB_REF_NAME=gemm-x86-bf16s GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=Tencent/ncnn GITHUB_REPOSITORY_OWNER=Tencent GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=91ba57c305ba4dd2d14980e69aaece4e0ed9d381 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=linux-x64-cpu-clang GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 "${CURRENT_ENV[@]}" \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=13 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=nihui GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=gemm-x86-bf16s GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/gemm-x86-bf16s GITHUB_REF_NAME=gemm-x86-bf16s GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=Tencent/ncnn GITHUB_REPOSITORY_OWNER=Tencent GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=91ba57c305ba4dd2d14980e69aaece4e0ed9d381 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=linux-x64-cpu-clang GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 "${CURRENT_ENV[@]}" \
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
   bash -e $ACTIONS_RUNNER_HOOK_JOB_COMPLETED 66733673559 failed
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
