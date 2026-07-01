#!/usr/bin/env bash
export GITHUB_WORKSPACE=/home/github/build/gohugoio/hugo

if [[ ! -z "$ACTIONS_RUNNER_HOOK_JOB_STARTED" ]]; then
   echo "A job started hook has been configured by the self-hosted runner administrator"
   echo "##[group]Run '$ACTIONS_RUNNER_HOOK_JOB_STARTED'"
   echo "##[endgroup]"
   bash -e $ACTIONS_RUNNER_HOOK_JOB_STARTED 70412793599 passed
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

cp /home/github/70412793599/event.json /home/github/workflow/event.json
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=0 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=jlumbroso/free-disk-space GITHUB_ACTIONS=true GITHUB_ACTOR=bep GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=gohugoio/hugo GITHUB_REPOSITORY_OWNER=gohugoio GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=c48551677c2504e3f2d7fa53ee42766e0333b957 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Test GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 GOPROXY=https://proxy.golang.org GO111MODULE=true SASS_VERSION=1.80.3 DART_SASS_SHA_LINUX=7c933edbad0a7d389192c5b79393485c088bd2c4398e32f5754c32af006a9ffd DART_SASS_SHA_MACOS=79e060b0e131c3bb3c16926bafc371dc33feab122bfa8c01aa337a072097967b DART_SASS_SHA_WINDOWS=0bc4708b37cd1bac4740e83ac5e3176e66b774f77fd5dd364da5b5cfc9bfb469 GITHUB_ACTION_PATH=/home/github/70412793599/actions/jlumbroso-free-disk-space@54081f138730dfa15788a46383842cd2f914a1be "${CURRENT_ENV[@]}" INPUT_TOOL-CACHE=true INPUT_ANDROID=true INPUT_DOTNET=true INPUT_HASKELL=true INPUT_LARGE-PACKAGES=true INPUT_DOCKER-IMAGES=true INPUT_SWAP-STORAGE=true \
echo "$(/home/github/70412793599/helpers/eval_expression p:'(' f:success p:'(' p:')' p:')' o:'&&' p:'(' s:windows-latest o:== s:ubuntu-latest p:')')")
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=0 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=jlumbroso/free-disk-space GITHUB_ACTIONS=true GITHUB_ACTOR=bep GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=gohugoio/hugo GITHUB_REPOSITORY_OWNER=gohugoio GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=c48551677c2504e3f2d7fa53ee42766e0333b957 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Test GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 GOPROXY=https://proxy.golang.org GO111MODULE=true SASS_VERSION=1.80.3 DART_SASS_SHA_LINUX=7c933edbad0a7d389192c5b79393485c088bd2c4398e32f5754c32af006a9ffd DART_SASS_SHA_MACOS=79e060b0e131c3bb3c16926bafc371dc33feab122bfa8c01aa337a072097967b DART_SASS_SHA_WINDOWS=0bc4708b37cd1bac4740e83ac5e3176e66b774f77fd5dd364da5b5cfc9bfb469 GITHUB_ACTION_PATH=/home/github/70412793599/actions/jlumbroso-free-disk-space@54081f138730dfa15788a46383842cd2f914a1be "${CURRENT_ENV[@]}" INPUT_TOOL-CACHE=true INPUT_ANDROID=true INPUT_DOTNET=true INPUT_HASKELL=true INPUT_LARGE-PACKAGES=true INPUT_DOCKER-IMAGES=true INPUT_SWAP-STORAGE=true \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run jlumbroso/free-disk-space@54081f138730dfa15788a46383842cd2f914a1be
echo "##[endgroup]"
echo /home/github/70412793599/steps/bugswarm_0_composite.sh > /home/github/70412793599/steps/bugswarm_0.sh
chmod u+x /home/github/70412793599/steps/bugswarm_0.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=0 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=jlumbroso/free-disk-space GITHUB_ACTIONS=true GITHUB_ACTOR=bep GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=gohugoio/hugo GITHUB_REPOSITORY_OWNER=gohugoio GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=c48551677c2504e3f2d7fa53ee42766e0333b957 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Test GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 GOPROXY=https://proxy.golang.org GO111MODULE=true SASS_VERSION=1.80.3 DART_SASS_SHA_LINUX=7c933edbad0a7d389192c5b79393485c088bd2c4398e32f5754c32af006a9ffd DART_SASS_SHA_MACOS=79e060b0e131c3bb3c16926bafc371dc33feab122bfa8c01aa337a072097967b DART_SASS_SHA_WINDOWS=0bc4708b37cd1bac4740e83ac5e3176e66b774f77fd5dd364da5b5cfc9bfb469 GITHUB_ACTION_PATH=/home/github/70412793599/actions/jlumbroso-free-disk-space@54081f138730dfa15788a46383842cd2f914a1be "${CURRENT_ENV[@]}" INPUT_TOOL-CACHE=true INPUT_ANDROID=true INPUT_DOTNET=true INPUT_HASKELL=true INPUT_LARGE-PACKAGES=true INPUT_DOCKER-IMAGES=true INPUT_SWAP-STORAGE=true \
bash -e /home/github/70412793599/steps/bugswarm_0.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=0 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=jlumbroso/free-disk-space GITHUB_ACTIONS=true GITHUB_ACTOR=bep GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=gohugoio/hugo GITHUB_REPOSITORY_OWNER=gohugoio GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=c48551677c2504e3f2d7fa53ee42766e0333b957 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Test GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 GOPROXY=https://proxy.golang.org GO111MODULE=true SASS_VERSION=1.80.3 DART_SASS_SHA_LINUX=7c933edbad0a7d389192c5b79393485c088bd2c4398e32f5754c32af006a9ffd DART_SASS_SHA_MACOS=79e060b0e131c3bb3c16926bafc371dc33feab122bfa8c01aa337a072097967b DART_SASS_SHA_WINDOWS=0bc4708b37cd1bac4740e83ac5e3176e66b774f77fd5dd364da5b5cfc9bfb469 GITHUB_ACTION_PATH=/home/github/70412793599/actions/jlumbroso-free-disk-space@54081f138730dfa15788a46383842cd2f914a1be "${CURRENT_ENV[@]}" INPUT_TOOL-CACHE=true INPUT_ANDROID=true INPUT_DOTNET=true INPUT_HASKELL=true INPUT_LARGE-PACKAGES=true INPUT_DOCKER-IMAGES=true INPUT_SWAP-STORAGE=true \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=0 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=jlumbroso/free-disk-space GITHUB_ACTIONS=true GITHUB_ACTOR=bep GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=gohugoio/hugo GITHUB_REPOSITORY_OWNER=gohugoio GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=c48551677c2504e3f2d7fa53ee42766e0333b957 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Test GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 GOPROXY=https://proxy.golang.org GO111MODULE=true SASS_VERSION=1.80.3 DART_SASS_SHA_LINUX=7c933edbad0a7d389192c5b79393485c088bd2c4398e32f5754c32af006a9ffd DART_SASS_SHA_MACOS=79e060b0e131c3bb3c16926bafc371dc33feab122bfa8c01aa337a072097967b DART_SASS_SHA_WINDOWS=0bc4708b37cd1bac4740e83ac5e3176e66b774f77fd5dd364da5b5cfc9bfb469 GITHUB_ACTION_PATH=/home/github/70412793599/actions/jlumbroso-free-disk-space@54081f138730dfa15788a46383842cd2f914a1be "${CURRENT_ENV[@]}" INPUT_TOOL-CACHE=true INPUT_ANDROID=true INPUT_DOTNET=true INPUT_HASKELL=true INPUT_LARGE-PACKAGES=true INPUT_DOCKER-IMAGES=true INPUT_SWAP-STORAGE=true \
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=2 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=actions/setup-go GITHUB_ACTIONS=true GITHUB_ACTOR=bep GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=gohugoio/hugo GITHUB_REPOSITORY_OWNER=gohugoio GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=c48551677c2504e3f2d7fa53ee42766e0333b957 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Test GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 GOPROXY=https://proxy.golang.org GO111MODULE=true SASS_VERSION=1.80.3 DART_SASS_SHA_LINUX=7c933edbad0a7d389192c5b79393485c088bd2c4398e32f5754c32af006a9ffd DART_SASS_SHA_MACOS=79e060b0e131c3bb3c16926bafc371dc33feab122bfa8c01aa337a072097967b DART_SASS_SHA_WINDOWS=0bc4708b37cd1bac4740e83ac5e3176e66b774f77fd5dd364da5b5cfc9bfb469 GITHUB_ACTION_PATH=/home/github/70412793599/actions/actions-setup-go@44694675825211faa026b3c33043df3e48a5fa00 "${CURRENT_ENV[@]}" INPUT_GO-VERSION=1.25.x INPUT_CHECK-LATEST=true INPUT_CACHE-DEPENDENCY-PATH='**/go.sum
**/go.mod
' INPUT_TOKEN= INPUT_CACHE=true \
echo $(test "$_GITHUB_JOB_STATUS" = "success" && echo true || echo false))
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=2 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=actions/setup-go GITHUB_ACTIONS=true GITHUB_ACTOR=bep GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=gohugoio/hugo GITHUB_REPOSITORY_OWNER=gohugoio GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=c48551677c2504e3f2d7fa53ee42766e0333b957 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Test GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 GOPROXY=https://proxy.golang.org GO111MODULE=true SASS_VERSION=1.80.3 DART_SASS_SHA_LINUX=7c933edbad0a7d389192c5b79393485c088bd2c4398e32f5754c32af006a9ffd DART_SASS_SHA_MACOS=79e060b0e131c3bb3c16926bafc371dc33feab122bfa8c01aa337a072097967b DART_SASS_SHA_WINDOWS=0bc4708b37cd1bac4740e83ac5e3176e66b774f77fd5dd364da5b5cfc9bfb469 GITHUB_ACTION_PATH=/home/github/70412793599/actions/actions-setup-go@44694675825211faa026b3c33043df3e48a5fa00 "${CURRENT_ENV[@]}" INPUT_GO-VERSION=1.25.x INPUT_CHECK-LATEST=true INPUT_CACHE-DEPENDENCY-PATH='**/go.sum
**/go.mod
' INPUT_TOKEN= INPUT_CACHE=true \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run actions/setup-go@44694675825211faa026b3c33043df3e48a5fa00
echo "##[endgroup]"
echo node /home/github/70412793599/actions/actions-setup-go@44694675825211faa026b3c33043df3e48a5fa00/dist/setup/index.js > /home/github/70412793599/steps/bugswarm_cmd.sh
chmod u+x /home/github/70412793599/steps/bugswarm_cmd.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=2 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=actions/setup-go GITHUB_ACTIONS=true GITHUB_ACTOR=bep GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=gohugoio/hugo GITHUB_REPOSITORY_OWNER=gohugoio GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=c48551677c2504e3f2d7fa53ee42766e0333b957 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Test GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 GOPROXY=https://proxy.golang.org GO111MODULE=true SASS_VERSION=1.80.3 DART_SASS_SHA_LINUX=7c933edbad0a7d389192c5b79393485c088bd2c4398e32f5754c32af006a9ffd DART_SASS_SHA_MACOS=79e060b0e131c3bb3c16926bafc371dc33feab122bfa8c01aa337a072097967b DART_SASS_SHA_WINDOWS=0bc4708b37cd1bac4740e83ac5e3176e66b774f77fd5dd364da5b5cfc9bfb469 GITHUB_ACTION_PATH=/home/github/70412793599/actions/actions-setup-go@44694675825211faa026b3c33043df3e48a5fa00 "${CURRENT_ENV[@]}" INPUT_GO-VERSION=1.25.x INPUT_CHECK-LATEST=true INPUT_CACHE-DEPENDENCY-PATH='**/go.sum
**/go.mod
' INPUT_TOKEN= INPUT_CACHE=true \
bash -e /home/github/70412793599/steps/bugswarm_cmd.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=2 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=actions/setup-go GITHUB_ACTIONS=true GITHUB_ACTOR=bep GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=gohugoio/hugo GITHUB_REPOSITORY_OWNER=gohugoio GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=c48551677c2504e3f2d7fa53ee42766e0333b957 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Test GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 GOPROXY=https://proxy.golang.org GO111MODULE=true SASS_VERSION=1.80.3 DART_SASS_SHA_LINUX=7c933edbad0a7d389192c5b79393485c088bd2c4398e32f5754c32af006a9ffd DART_SASS_SHA_MACOS=79e060b0e131c3bb3c16926bafc371dc33feab122bfa8c01aa337a072097967b DART_SASS_SHA_WINDOWS=0bc4708b37cd1bac4740e83ac5e3176e66b774f77fd5dd364da5b5cfc9bfb469 GITHUB_ACTION_PATH=/home/github/70412793599/actions/actions-setup-go@44694675825211faa026b3c33043df3e48a5fa00 "${CURRENT_ENV[@]}" INPUT_GO-VERSION=1.25.x INPUT_CHECK-LATEST=true INPUT_CACHE-DEPENDENCY-PATH='**/go.sum
**/go.mod
' INPUT_TOKEN= INPUT_CACHE=true \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=2 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=actions/setup-go GITHUB_ACTIONS=true GITHUB_ACTOR=bep GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=gohugoio/hugo GITHUB_REPOSITORY_OWNER=gohugoio GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=c48551677c2504e3f2d7fa53ee42766e0333b957 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Test GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 GOPROXY=https://proxy.golang.org GO111MODULE=true SASS_VERSION=1.80.3 DART_SASS_SHA_LINUX=7c933edbad0a7d389192c5b79393485c088bd2c4398e32f5754c32af006a9ffd DART_SASS_SHA_MACOS=79e060b0e131c3bb3c16926bafc371dc33feab122bfa8c01aa337a072097967b DART_SASS_SHA_WINDOWS=0bc4708b37cd1bac4740e83ac5e3176e66b774f77fd5dd364da5b5cfc9bfb469 GITHUB_ACTION_PATH=/home/github/70412793599/actions/actions-setup-go@44694675825211faa026b3c33043df3e48a5fa00 "${CURRENT_ENV[@]}" INPUT_GO-VERSION=1.25.x INPUT_CHECK-LATEST=true INPUT_CACHE-DEPENDENCY-PATH='**/go.sum
**/go.mod
' INPUT_TOKEN= INPUT_CACHE=true \
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=3 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=ruby/setup-ruby GITHUB_ACTIONS=true GITHUB_ACTOR=bep GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=gohugoio/hugo GITHUB_REPOSITORY_OWNER=gohugoio GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=c48551677c2504e3f2d7fa53ee42766e0333b957 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Test GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 GOPROXY=https://proxy.golang.org GO111MODULE=true SASS_VERSION=1.80.3 DART_SASS_SHA_LINUX=7c933edbad0a7d389192c5b79393485c088bd2c4398e32f5754c32af006a9ffd DART_SASS_SHA_MACOS=79e060b0e131c3bb3c16926bafc371dc33feab122bfa8c01aa337a072097967b DART_SASS_SHA_WINDOWS=0bc4708b37cd1bac4740e83ac5e3176e66b774f77fd5dd364da5b5cfc9bfb469 GITHUB_ACTION_PATH=/home/github/70412793599/actions/ruby-setup-ruby@8aeb6ff8030dd539317f8e1769a044873b56ea71 "${CURRENT_ENV[@]}" INPUT_RUBY-VERSION=3.4.5 INPUT_BUNDLER-CACHE=false \
echo $(test "$_GITHUB_JOB_STATUS" = "success" && echo true || echo false))
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=3 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=ruby/setup-ruby GITHUB_ACTIONS=true GITHUB_ACTOR=bep GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=gohugoio/hugo GITHUB_REPOSITORY_OWNER=gohugoio GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=c48551677c2504e3f2d7fa53ee42766e0333b957 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Test GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 GOPROXY=https://proxy.golang.org GO111MODULE=true SASS_VERSION=1.80.3 DART_SASS_SHA_LINUX=7c933edbad0a7d389192c5b79393485c088bd2c4398e32f5754c32af006a9ffd DART_SASS_SHA_MACOS=79e060b0e131c3bb3c16926bafc371dc33feab122bfa8c01aa337a072097967b DART_SASS_SHA_WINDOWS=0bc4708b37cd1bac4740e83ac5e3176e66b774f77fd5dd364da5b5cfc9bfb469 GITHUB_ACTION_PATH=/home/github/70412793599/actions/ruby-setup-ruby@8aeb6ff8030dd539317f8e1769a044873b56ea71 "${CURRENT_ENV[@]}" INPUT_RUBY-VERSION=3.4.5 INPUT_BUNDLER-CACHE=false \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run ruby/setup-ruby@8aeb6ff8030dd539317f8e1769a044873b56ea71
echo "##[endgroup]"
echo node /home/github/70412793599/actions/ruby-setup-ruby@8aeb6ff8030dd539317f8e1769a044873b56ea71/dist/index.js > /home/github/70412793599/steps/bugswarm_cmd.sh
chmod u+x /home/github/70412793599/steps/bugswarm_cmd.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=3 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=ruby/setup-ruby GITHUB_ACTIONS=true GITHUB_ACTOR=bep GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=gohugoio/hugo GITHUB_REPOSITORY_OWNER=gohugoio GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=c48551677c2504e3f2d7fa53ee42766e0333b957 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Test GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 GOPROXY=https://proxy.golang.org GO111MODULE=true SASS_VERSION=1.80.3 DART_SASS_SHA_LINUX=7c933edbad0a7d389192c5b79393485c088bd2c4398e32f5754c32af006a9ffd DART_SASS_SHA_MACOS=79e060b0e131c3bb3c16926bafc371dc33feab122bfa8c01aa337a072097967b DART_SASS_SHA_WINDOWS=0bc4708b37cd1bac4740e83ac5e3176e66b774f77fd5dd364da5b5cfc9bfb469 GITHUB_ACTION_PATH=/home/github/70412793599/actions/ruby-setup-ruby@8aeb6ff8030dd539317f8e1769a044873b56ea71 "${CURRENT_ENV[@]}" INPUT_RUBY-VERSION=3.4.5 INPUT_BUNDLER-CACHE=false \
bash -e /home/github/70412793599/steps/bugswarm_cmd.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=3 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=ruby/setup-ruby GITHUB_ACTIONS=true GITHUB_ACTOR=bep GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=gohugoio/hugo GITHUB_REPOSITORY_OWNER=gohugoio GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=c48551677c2504e3f2d7fa53ee42766e0333b957 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Test GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 GOPROXY=https://proxy.golang.org GO111MODULE=true SASS_VERSION=1.80.3 DART_SASS_SHA_LINUX=7c933edbad0a7d389192c5b79393485c088bd2c4398e32f5754c32af006a9ffd DART_SASS_SHA_MACOS=79e060b0e131c3bb3c16926bafc371dc33feab122bfa8c01aa337a072097967b DART_SASS_SHA_WINDOWS=0bc4708b37cd1bac4740e83ac5e3176e66b774f77fd5dd364da5b5cfc9bfb469 GITHUB_ACTION_PATH=/home/github/70412793599/actions/ruby-setup-ruby@8aeb6ff8030dd539317f8e1769a044873b56ea71 "${CURRENT_ENV[@]}" INPUT_RUBY-VERSION=3.4.5 INPUT_BUNDLER-CACHE=false \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=3 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=ruby/setup-ruby GITHUB_ACTIONS=true GITHUB_ACTOR=bep GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=gohugoio/hugo GITHUB_REPOSITORY_OWNER=gohugoio GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=c48551677c2504e3f2d7fa53ee42766e0333b957 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Test GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 GOPROXY=https://proxy.golang.org GO111MODULE=true SASS_VERSION=1.80.3 DART_SASS_SHA_LINUX=7c933edbad0a7d389192c5b79393485c088bd2c4398e32f5754c32af006a9ffd DART_SASS_SHA_MACOS=79e060b0e131c3bb3c16926bafc371dc33feab122bfa8c01aa337a072097967b DART_SASS_SHA_WINDOWS=0bc4708b37cd1bac4740e83ac5e3176e66b774f77fd5dd364da5b5cfc9bfb469 GITHUB_ACTION_PATH=/home/github/70412793599/actions/ruby-setup-ruby@8aeb6ff8030dd539317f8e1769a044873b56ea71 "${CURRENT_ENV[@]}" INPUT_RUBY-VERSION=3.4.5 INPUT_BUNDLER-CACHE=false \
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=4 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=bep GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=gohugoio/hugo GITHUB_REPOSITORY_OWNER=gohugoio GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=c48551677c2504e3f2d7fa53ee42766e0333b957 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Test GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 GOPROXY=https://proxy.golang.org GO111MODULE=true SASS_VERSION=1.80.3 DART_SASS_SHA_LINUX=7c933edbad0a7d389192c5b79393485c088bd2c4398e32f5754c32af006a9ffd DART_SASS_SHA_MACOS=79e060b0e131c3bb3c16926bafc371dc33feab122bfa8c01aa337a072097967b DART_SASS_SHA_WINDOWS=0bc4708b37cd1bac4740e83ac5e3176e66b774f77fd5dd364da5b5cfc9bfb469 "${CURRENT_ENV[@]}" \
echo $(test "$_GITHUB_JOB_STATUS" = "success" && echo true || echo false))
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=4 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=bep GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=gohugoio/hugo GITHUB_REPOSITORY_OWNER=gohugoio GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=c48551677c2504e3f2d7fa53ee42766e0333b957 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Test GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 GOPROXY=https://proxy.golang.org GO111MODULE=true SASS_VERSION=1.80.3 DART_SASS_SHA_LINUX=7c933edbad0a7d389192c5b79393485c088bd2c4398e32f5754c32af006a9ffd DART_SASS_SHA_MACOS=79e060b0e131c3bb3c16926bafc371dc33feab122bfa8c01aa337a072097967b DART_SASS_SHA_WINDOWS=0bc4708b37cd1bac4740e83ac5e3176e66b774f77fd5dd364da5b5cfc9bfb469 "${CURRENT_ENV[@]}" \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run 'gem install asciidoctor -v "2.0.26"'
echo "##[endgroup]"
echo 'gem install asciidoctor -v "2.0.26"
gem install asciidoctor-diagram -v "3.1.0"
' > /home/github/70412793599/steps/bugswarm_4.sh
chmod u+x /home/github/70412793599/steps/bugswarm_4.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=4 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=bep GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=gohugoio/hugo GITHUB_REPOSITORY_OWNER=gohugoio GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=c48551677c2504e3f2d7fa53ee42766e0333b957 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Test GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 GOPROXY=https://proxy.golang.org GO111MODULE=true SASS_VERSION=1.80.3 DART_SASS_SHA_LINUX=7c933edbad0a7d389192c5b79393485c088bd2c4398e32f5754c32af006a9ffd DART_SASS_SHA_MACOS=79e060b0e131c3bb3c16926bafc371dc33feab122bfa8c01aa337a072097967b DART_SASS_SHA_WINDOWS=0bc4708b37cd1bac4740e83ac5e3176e66b774f77fd5dd364da5b5cfc9bfb469 "${CURRENT_ENV[@]}" \
bash -e /home/github/70412793599/steps/bugswarm_4.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=4 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=bep GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=gohugoio/hugo GITHUB_REPOSITORY_OWNER=gohugoio GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=c48551677c2504e3f2d7fa53ee42766e0333b957 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Test GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 GOPROXY=https://proxy.golang.org GO111MODULE=true SASS_VERSION=1.80.3 DART_SASS_SHA_LINUX=7c933edbad0a7d389192c5b79393485c088bd2c4398e32f5754c32af006a9ffd DART_SASS_SHA_MACOS=79e060b0e131c3bb3c16926bafc371dc33feab122bfa8c01aa337a072097967b DART_SASS_SHA_WINDOWS=0bc4708b37cd1bac4740e83ac5e3176e66b774f77fd5dd364da5b5cfc9bfb469 "${CURRENT_ENV[@]}" \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=4 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=bep GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=gohugoio/hugo GITHUB_REPOSITORY_OWNER=gohugoio GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=c48551677c2504e3f2d7fa53ee42766e0333b957 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Test GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 GOPROXY=https://proxy.golang.org GO111MODULE=true SASS_VERSION=1.80.3 DART_SASS_SHA_LINUX=7c933edbad0a7d389192c5b79393485c088bd2c4398e32f5754c32af006a9ffd DART_SASS_SHA_MACOS=79e060b0e131c3bb3c16926bafc371dc33feab122bfa8c01aa337a072097967b DART_SASS_SHA_WINDOWS=0bc4708b37cd1bac4740e83ac5e3176e66b774f77fd5dd364da5b5cfc9bfb469 "${CURRENT_ENV[@]}" \
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=5 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=bep GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=gohugoio/hugo GITHUB_REPOSITORY_OWNER=gohugoio GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=c48551677c2504e3f2d7fa53ee42766e0333b957 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Test GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 GOPROXY=https://proxy.golang.org GO111MODULE=true SASS_VERSION=1.80.3 DART_SASS_SHA_LINUX=7c933edbad0a7d389192c5b79393485c088bd2c4398e32f5754c32af006a9ffd DART_SASS_SHA_MACOS=79e060b0e131c3bb3c16926bafc371dc33feab122bfa8c01aa337a072097967b DART_SASS_SHA_WINDOWS=0bc4708b37cd1bac4740e83ac5e3176e66b774f77fd5dd364da5b5cfc9bfb469 "${CURRENT_ENV[@]}" \
echo $(test "$_GITHUB_JOB_STATUS" = "success" && echo true || echo false))
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=5 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=bep GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=gohugoio/hugo GITHUB_REPOSITORY_OWNER=gohugoio GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=c48551677c2504e3f2d7fa53ee42766e0333b957 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Test GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 GOPROXY=https://proxy.golang.org GO111MODULE=true SASS_VERSION=1.80.3 DART_SASS_SHA_LINUX=7c933edbad0a7d389192c5b79393485c088bd2c4398e32f5754c32af006a9ffd DART_SASS_SHA_MACOS=79e060b0e131c3bb3c16926bafc371dc33feab122bfa8c01aa337a072097967b DART_SASS_SHA_WINDOWS=0bc4708b37cd1bac4740e83ac5e3176e66b774f77fd5dd364da5b5cfc9bfb469 "${CURRENT_ENV[@]}" \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run 'go install github.com/blampe/goat/cmd/goat@177de93b192b8ffae608e5d9ec421cc99bf68402'
echo "##[endgroup]"
echo 'go install github.com/blampe/goat/cmd/goat@177de93b192b8ffae608e5d9ec421cc99bf68402' > /home/github/70412793599/steps/bugswarm_5.sh
chmod u+x /home/github/70412793599/steps/bugswarm_5.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=5 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=bep GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=gohugoio/hugo GITHUB_REPOSITORY_OWNER=gohugoio GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=c48551677c2504e3f2d7fa53ee42766e0333b957 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Test GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 GOPROXY=https://proxy.golang.org GO111MODULE=true SASS_VERSION=1.80.3 DART_SASS_SHA_LINUX=7c933edbad0a7d389192c5b79393485c088bd2c4398e32f5754c32af006a9ffd DART_SASS_SHA_MACOS=79e060b0e131c3bb3c16926bafc371dc33feab122bfa8c01aa337a072097967b DART_SASS_SHA_WINDOWS=0bc4708b37cd1bac4740e83ac5e3176e66b774f77fd5dd364da5b5cfc9bfb469 "${CURRENT_ENV[@]}" \
bash -e /home/github/70412793599/steps/bugswarm_5.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=5 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=bep GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=gohugoio/hugo GITHUB_REPOSITORY_OWNER=gohugoio GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=c48551677c2504e3f2d7fa53ee42766e0333b957 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Test GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 GOPROXY=https://proxy.golang.org GO111MODULE=true SASS_VERSION=1.80.3 DART_SASS_SHA_LINUX=7c933edbad0a7d389192c5b79393485c088bd2c4398e32f5754c32af006a9ffd DART_SASS_SHA_MACOS=79e060b0e131c3bb3c16926bafc371dc33feab122bfa8c01aa337a072097967b DART_SASS_SHA_WINDOWS=0bc4708b37cd1bac4740e83ac5e3176e66b774f77fd5dd364da5b5cfc9bfb469 "${CURRENT_ENV[@]}" \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=5 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=bep GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=gohugoio/hugo GITHUB_REPOSITORY_OWNER=gohugoio GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=c48551677c2504e3f2d7fa53ee42766e0333b957 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Test GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 GOPROXY=https://proxy.golang.org GO111MODULE=true SASS_VERSION=1.80.3 DART_SASS_SHA_LINUX=7c933edbad0a7d389192c5b79393485c088bd2c4398e32f5754c32af006a9ffd DART_SASS_SHA_MACOS=79e060b0e131c3bb3c16926bafc371dc33feab122bfa8c01aa337a072097967b DART_SASS_SHA_WINDOWS=0bc4708b37cd1bac4740e83ac5e3176e66b774f77fd5dd364da5b5cfc9bfb469 "${CURRENT_ENV[@]}" \
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=6 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=actions/setup-python GITHUB_ACTIONS=true GITHUB_ACTOR=bep GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=gohugoio/hugo GITHUB_REPOSITORY_OWNER=gohugoio GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=c48551677c2504e3f2d7fa53ee42766e0333b957 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Test GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 GOPROXY=https://proxy.golang.org GO111MODULE=true SASS_VERSION=1.80.3 DART_SASS_SHA_LINUX=7c933edbad0a7d389192c5b79393485c088bd2c4398e32f5754c32af006a9ffd DART_SASS_SHA_MACOS=79e060b0e131c3bb3c16926bafc371dc33feab122bfa8c01aa337a072097967b DART_SASS_SHA_WINDOWS=0bc4708b37cd1bac4740e83ac5e3176e66b774f77fd5dd364da5b5cfc9bfb469 GITHUB_ACTION_PATH=/home/github/70412793599/actions/actions-setup-python@e797f83bcb11b83ae66e0230d6156d7c80228e7c "${CURRENT_ENV[@]}" INPUT_PYTHON-VERSION=3.x INPUT_TOKEN= INPUT_CHECK-LATEST=false INPUT_UPDATE-ENVIRONMENT=true INPUT_ALLOW-PRERELEASES=false INPUT_FREETHREADED=false \
echo $(test "$_GITHUB_JOB_STATUS" = "success" && echo true || echo false))
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=6 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=actions/setup-python GITHUB_ACTIONS=true GITHUB_ACTOR=bep GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=gohugoio/hugo GITHUB_REPOSITORY_OWNER=gohugoio GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=c48551677c2504e3f2d7fa53ee42766e0333b957 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Test GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 GOPROXY=https://proxy.golang.org GO111MODULE=true SASS_VERSION=1.80.3 DART_SASS_SHA_LINUX=7c933edbad0a7d389192c5b79393485c088bd2c4398e32f5754c32af006a9ffd DART_SASS_SHA_MACOS=79e060b0e131c3bb3c16926bafc371dc33feab122bfa8c01aa337a072097967b DART_SASS_SHA_WINDOWS=0bc4708b37cd1bac4740e83ac5e3176e66b774f77fd5dd364da5b5cfc9bfb469 GITHUB_ACTION_PATH=/home/github/70412793599/actions/actions-setup-python@e797f83bcb11b83ae66e0230d6156d7c80228e7c "${CURRENT_ENV[@]}" INPUT_PYTHON-VERSION=3.x INPUT_TOKEN= INPUT_CHECK-LATEST=false INPUT_UPDATE-ENVIRONMENT=true INPUT_ALLOW-PRERELEASES=false INPUT_FREETHREADED=false \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run actions/setup-python@e797f83bcb11b83ae66e0230d6156d7c80228e7c
echo "##[endgroup]"
echo node /home/github/70412793599/actions/actions-setup-python@e797f83bcb11b83ae66e0230d6156d7c80228e7c/dist/setup/index.js > /home/github/70412793599/steps/bugswarm_cmd.sh
chmod u+x /home/github/70412793599/steps/bugswarm_cmd.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=6 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=actions/setup-python GITHUB_ACTIONS=true GITHUB_ACTOR=bep GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=gohugoio/hugo GITHUB_REPOSITORY_OWNER=gohugoio GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=c48551677c2504e3f2d7fa53ee42766e0333b957 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Test GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 GOPROXY=https://proxy.golang.org GO111MODULE=true SASS_VERSION=1.80.3 DART_SASS_SHA_LINUX=7c933edbad0a7d389192c5b79393485c088bd2c4398e32f5754c32af006a9ffd DART_SASS_SHA_MACOS=79e060b0e131c3bb3c16926bafc371dc33feab122bfa8c01aa337a072097967b DART_SASS_SHA_WINDOWS=0bc4708b37cd1bac4740e83ac5e3176e66b774f77fd5dd364da5b5cfc9bfb469 GITHUB_ACTION_PATH=/home/github/70412793599/actions/actions-setup-python@e797f83bcb11b83ae66e0230d6156d7c80228e7c "${CURRENT_ENV[@]}" INPUT_PYTHON-VERSION=3.x INPUT_TOKEN= INPUT_CHECK-LATEST=false INPUT_UPDATE-ENVIRONMENT=true INPUT_ALLOW-PRERELEASES=false INPUT_FREETHREADED=false \
bash -e /home/github/70412793599/steps/bugswarm_cmd.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=6 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=actions/setup-python GITHUB_ACTIONS=true GITHUB_ACTOR=bep GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=gohugoio/hugo GITHUB_REPOSITORY_OWNER=gohugoio GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=c48551677c2504e3f2d7fa53ee42766e0333b957 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Test GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 GOPROXY=https://proxy.golang.org GO111MODULE=true SASS_VERSION=1.80.3 DART_SASS_SHA_LINUX=7c933edbad0a7d389192c5b79393485c088bd2c4398e32f5754c32af006a9ffd DART_SASS_SHA_MACOS=79e060b0e131c3bb3c16926bafc371dc33feab122bfa8c01aa337a072097967b DART_SASS_SHA_WINDOWS=0bc4708b37cd1bac4740e83ac5e3176e66b774f77fd5dd364da5b5cfc9bfb469 GITHUB_ACTION_PATH=/home/github/70412793599/actions/actions-setup-python@e797f83bcb11b83ae66e0230d6156d7c80228e7c "${CURRENT_ENV[@]}" INPUT_PYTHON-VERSION=3.x INPUT_TOKEN= INPUT_CHECK-LATEST=false INPUT_UPDATE-ENVIRONMENT=true INPUT_ALLOW-PRERELEASES=false INPUT_FREETHREADED=false \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=6 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=actions/setup-python GITHUB_ACTIONS=true GITHUB_ACTOR=bep GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=gohugoio/hugo GITHUB_REPOSITORY_OWNER=gohugoio GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=c48551677c2504e3f2d7fa53ee42766e0333b957 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Test GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 GOPROXY=https://proxy.golang.org GO111MODULE=true SASS_VERSION=1.80.3 DART_SASS_SHA_LINUX=7c933edbad0a7d389192c5b79393485c088bd2c4398e32f5754c32af006a9ffd DART_SASS_SHA_MACOS=79e060b0e131c3bb3c16926bafc371dc33feab122bfa8c01aa337a072097967b DART_SASS_SHA_WINDOWS=0bc4708b37cd1bac4740e83ac5e3176e66b774f77fd5dd364da5b5cfc9bfb469 GITHUB_ACTION_PATH=/home/github/70412793599/actions/actions-setup-python@e797f83bcb11b83ae66e0230d6156d7c80228e7c "${CURRENT_ENV[@]}" INPUT_PYTHON-VERSION=3.x INPUT_TOKEN= INPUT_CHECK-LATEST=false INPUT_UPDATE-ENVIRONMENT=true INPUT_ALLOW-PRERELEASES=false INPUT_FREETHREADED=false \
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=7 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=bep GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=gohugoio/hugo GITHUB_REPOSITORY_OWNER=gohugoio GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=c48551677c2504e3f2d7fa53ee42766e0333b957 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Test GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 GOPROXY=https://proxy.golang.org GO111MODULE=true SASS_VERSION=1.80.3 DART_SASS_SHA_LINUX=7c933edbad0a7d389192c5b79393485c088bd2c4398e32f5754c32af006a9ffd DART_SASS_SHA_MACOS=79e060b0e131c3bb3c16926bafc371dc33feab122bfa8c01aa337a072097967b DART_SASS_SHA_WINDOWS=0bc4708b37cd1bac4740e83ac5e3176e66b774f77fd5dd364da5b5cfc9bfb469 "${CURRENT_ENV[@]}" \
echo $(test "$_GITHUB_JOB_STATUS" = "success" && echo true || echo false))
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=7 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=bep GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=gohugoio/hugo GITHUB_REPOSITORY_OWNER=gohugoio GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=c48551677c2504e3f2d7fa53ee42766e0333b957 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Test GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 GOPROXY=https://proxy.golang.org GO111MODULE=true SASS_VERSION=1.80.3 DART_SASS_SHA_LINUX=7c933edbad0a7d389192c5b79393485c088bd2c4398e32f5754c32af006a9ffd DART_SASS_SHA_MACOS=79e060b0e131c3bb3c16926bafc371dc33feab122bfa8c01aa337a072097967b DART_SASS_SHA_WINDOWS=0bc4708b37cd1bac4740e83ac5e3176e66b774f77fd5dd364da5b5cfc9bfb469 "${CURRENT_ENV[@]}" \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run 'go install github.com/magefile/mage@v1.15.0'
echo "##[endgroup]"
echo 'go install github.com/magefile/mage@v1.15.0' > /home/github/70412793599/steps/bugswarm_7.sh
chmod u+x /home/github/70412793599/steps/bugswarm_7.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=7 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=bep GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=gohugoio/hugo GITHUB_REPOSITORY_OWNER=gohugoio GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=c48551677c2504e3f2d7fa53ee42766e0333b957 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Test GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 GOPROXY=https://proxy.golang.org GO111MODULE=true SASS_VERSION=1.80.3 DART_SASS_SHA_LINUX=7c933edbad0a7d389192c5b79393485c088bd2c4398e32f5754c32af006a9ffd DART_SASS_SHA_MACOS=79e060b0e131c3bb3c16926bafc371dc33feab122bfa8c01aa337a072097967b DART_SASS_SHA_WINDOWS=0bc4708b37cd1bac4740e83ac5e3176e66b774f77fd5dd364da5b5cfc9bfb469 "${CURRENT_ENV[@]}" \
bash -e /home/github/70412793599/steps/bugswarm_7.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=7 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=bep GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=gohugoio/hugo GITHUB_REPOSITORY_OWNER=gohugoio GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=c48551677c2504e3f2d7fa53ee42766e0333b957 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Test GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 GOPROXY=https://proxy.golang.org GO111MODULE=true SASS_VERSION=1.80.3 DART_SASS_SHA_LINUX=7c933edbad0a7d389192c5b79393485c088bd2c4398e32f5754c32af006a9ffd DART_SASS_SHA_MACOS=79e060b0e131c3bb3c16926bafc371dc33feab122bfa8c01aa337a072097967b DART_SASS_SHA_WINDOWS=0bc4708b37cd1bac4740e83ac5e3176e66b774f77fd5dd364da5b5cfc9bfb469 "${CURRENT_ENV[@]}" \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=7 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=bep GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=gohugoio/hugo GITHUB_REPOSITORY_OWNER=gohugoio GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=c48551677c2504e3f2d7fa53ee42766e0333b957 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Test GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 GOPROXY=https://proxy.golang.org GO111MODULE=true SASS_VERSION=1.80.3 DART_SASS_SHA_LINUX=7c933edbad0a7d389192c5b79393485c088bd2c4398e32f5754c32af006a9ffd DART_SASS_SHA_MACOS=79e060b0e131c3bb3c16926bafc371dc33feab122bfa8c01aa337a072097967b DART_SASS_SHA_WINDOWS=0bc4708b37cd1bac4740e83ac5e3176e66b774f77fd5dd364da5b5cfc9bfb469 "${CURRENT_ENV[@]}" \
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=8 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=bep GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=gohugoio/hugo GITHUB_REPOSITORY_OWNER=gohugoio GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=c48551677c2504e3f2d7fa53ee42766e0333b957 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Test GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 GOPROXY=https://proxy.golang.org GO111MODULE=true SASS_VERSION=1.80.3 DART_SASS_SHA_LINUX=7c933edbad0a7d389192c5b79393485c088bd2c4398e32f5754c32af006a9ffd DART_SASS_SHA_MACOS=79e060b0e131c3bb3c16926bafc371dc33feab122bfa8c01aa337a072097967b DART_SASS_SHA_WINDOWS=0bc4708b37cd1bac4740e83ac5e3176e66b774f77fd5dd364da5b5cfc9bfb469 "${CURRENT_ENV[@]}" \
echo $(test "$_GITHUB_JOB_STATUS" = "success" && echo true || echo false))
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=8 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=bep GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=gohugoio/hugo GITHUB_REPOSITORY_OWNER=gohugoio GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=c48551677c2504e3f2d7fa53ee42766e0333b957 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Test GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 GOPROXY=https://proxy.golang.org GO111MODULE=true SASS_VERSION=1.80.3 DART_SASS_SHA_LINUX=7c933edbad0a7d389192c5b79393485c088bd2c4398e32f5754c32af006a9ffd DART_SASS_SHA_MACOS=79e060b0e131c3bb3c16926bafc371dc33feab122bfa8c01aa337a072097967b DART_SASS_SHA_WINDOWS=0bc4708b37cd1bac4740e83ac5e3176e66b774f77fd5dd364da5b5cfc9bfb469 "${CURRENT_ENV[@]}" \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run 'pip install docutils'
echo "##[endgroup]"
echo 'pip install docutils
rst2html --version
' > /home/github/70412793599/steps/bugswarm_8.sh
chmod u+x /home/github/70412793599/steps/bugswarm_8.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=8 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=bep GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=gohugoio/hugo GITHUB_REPOSITORY_OWNER=gohugoio GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=c48551677c2504e3f2d7fa53ee42766e0333b957 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Test GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 GOPROXY=https://proxy.golang.org GO111MODULE=true SASS_VERSION=1.80.3 DART_SASS_SHA_LINUX=7c933edbad0a7d389192c5b79393485c088bd2c4398e32f5754c32af006a9ffd DART_SASS_SHA_MACOS=79e060b0e131c3bb3c16926bafc371dc33feab122bfa8c01aa337a072097967b DART_SASS_SHA_WINDOWS=0bc4708b37cd1bac4740e83ac5e3176e66b774f77fd5dd364da5b5cfc9bfb469 "${CURRENT_ENV[@]}" \
bash -e /home/github/70412793599/steps/bugswarm_8.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=8 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=bep GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=gohugoio/hugo GITHUB_REPOSITORY_OWNER=gohugoio GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=c48551677c2504e3f2d7fa53ee42766e0333b957 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Test GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 GOPROXY=https://proxy.golang.org GO111MODULE=true SASS_VERSION=1.80.3 DART_SASS_SHA_LINUX=7c933edbad0a7d389192c5b79393485c088bd2c4398e32f5754c32af006a9ffd DART_SASS_SHA_MACOS=79e060b0e131c3bb3c16926bafc371dc33feab122bfa8c01aa337a072097967b DART_SASS_SHA_WINDOWS=0bc4708b37cd1bac4740e83ac5e3176e66b774f77fd5dd364da5b5cfc9bfb469 "${CURRENT_ENV[@]}" \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=8 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=bep GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=gohugoio/hugo GITHUB_REPOSITORY_OWNER=gohugoio GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=c48551677c2504e3f2d7fa53ee42766e0333b957 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Test GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 GOPROXY=https://proxy.golang.org GO111MODULE=true SASS_VERSION=1.80.3 DART_SASS_SHA_LINUX=7c933edbad0a7d389192c5b79393485c088bd2c4398e32f5754c32af006a9ffd DART_SASS_SHA_MACOS=79e060b0e131c3bb3c16926bafc371dc33feab122bfa8c01aa337a072097967b DART_SASS_SHA_WINDOWS=0bc4708b37cd1bac4740e83ac5e3176e66b774f77fd5dd364da5b5cfc9bfb469 "${CURRENT_ENV[@]}" \
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=9 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=bep GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=gohugoio/hugo GITHUB_REPOSITORY_OWNER=gohugoio GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=c48551677c2504e3f2d7fa53ee42766e0333b957 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Test GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 GOPROXY=https://proxy.golang.org GO111MODULE=true SASS_VERSION=1.80.3 DART_SASS_SHA_LINUX=7c933edbad0a7d389192c5b79393485c088bd2c4398e32f5754c32af006a9ffd DART_SASS_SHA_MACOS=79e060b0e131c3bb3c16926bafc371dc33feab122bfa8c01aa337a072097967b DART_SASS_SHA_WINDOWS=0bc4708b37cd1bac4740e83ac5e3176e66b774f77fd5dd364da5b5cfc9bfb469 "${CURRENT_ENV[@]}" \
echo "$(/home/github/70412793599/helpers/eval_expression p:'(' f:success p:'(' p:')' p:')' o:'&&' p:'(' s:windows-latest o:== s:ubuntu-latest p:')')")
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=9 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=bep GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=gohugoio/hugo GITHUB_REPOSITORY_OWNER=gohugoio GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=c48551677c2504e3f2d7fa53ee42766e0333b957 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Test GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 GOPROXY=https://proxy.golang.org GO111MODULE=true SASS_VERSION=1.80.3 DART_SASS_SHA_LINUX=7c933edbad0a7d389192c5b79393485c088bd2c4398e32f5754c32af006a9ffd DART_SASS_SHA_MACOS=79e060b0e131c3bb3c16926bafc371dc33feab122bfa8c01aa337a072097967b DART_SASS_SHA_WINDOWS=0bc4708b37cd1bac4740e83ac5e3176e66b774f77fd5dd364da5b5cfc9bfb469 "${CURRENT_ENV[@]}" \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run 'sudo apt-get update -y'
echo "##[endgroup]"
echo 'sudo apt-get update -y
sudo apt-get install -y pandoc
' > /home/github/70412793599/steps/bugswarm_9.sh
chmod u+x /home/github/70412793599/steps/bugswarm_9.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=9 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=bep GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=gohugoio/hugo GITHUB_REPOSITORY_OWNER=gohugoio GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=c48551677c2504e3f2d7fa53ee42766e0333b957 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Test GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 GOPROXY=https://proxy.golang.org GO111MODULE=true SASS_VERSION=1.80.3 DART_SASS_SHA_LINUX=7c933edbad0a7d389192c5b79393485c088bd2c4398e32f5754c32af006a9ffd DART_SASS_SHA_MACOS=79e060b0e131c3bb3c16926bafc371dc33feab122bfa8c01aa337a072097967b DART_SASS_SHA_WINDOWS=0bc4708b37cd1bac4740e83ac5e3176e66b774f77fd5dd364da5b5cfc9bfb469 "${CURRENT_ENV[@]}" \
bash -e /home/github/70412793599/steps/bugswarm_9.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=9 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=bep GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=gohugoio/hugo GITHUB_REPOSITORY_OWNER=gohugoio GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=c48551677c2504e3f2d7fa53ee42766e0333b957 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Test GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 GOPROXY=https://proxy.golang.org GO111MODULE=true SASS_VERSION=1.80.3 DART_SASS_SHA_LINUX=7c933edbad0a7d389192c5b79393485c088bd2c4398e32f5754c32af006a9ffd DART_SASS_SHA_MACOS=79e060b0e131c3bb3c16926bafc371dc33feab122bfa8c01aa337a072097967b DART_SASS_SHA_WINDOWS=0bc4708b37cd1bac4740e83ac5e3176e66b774f77fd5dd364da5b5cfc9bfb469 "${CURRENT_ENV[@]}" \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=9 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=bep GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=gohugoio/hugo GITHUB_REPOSITORY_OWNER=gohugoio GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=c48551677c2504e3f2d7fa53ee42766e0333b957 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Test GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 GOPROXY=https://proxy.golang.org GO111MODULE=true SASS_VERSION=1.80.3 DART_SASS_SHA_LINUX=7c933edbad0a7d389192c5b79393485c088bd2c4398e32f5754c32af006a9ffd DART_SASS_SHA_MACOS=79e060b0e131c3bb3c16926bafc371dc33feab122bfa8c01aa337a072097967b DART_SASS_SHA_WINDOWS=0bc4708b37cd1bac4740e83ac5e3176e66b774f77fd5dd364da5b5cfc9bfb469 "${CURRENT_ENV[@]}" \
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=10 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=bep GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=gohugoio/hugo GITHUB_REPOSITORY_OWNER=gohugoio GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=c48551677c2504e3f2d7fa53ee42766e0333b957 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Test GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 GOPROXY=https://proxy.golang.org GO111MODULE=true SASS_VERSION=1.80.3 DART_SASS_SHA_LINUX=7c933edbad0a7d389192c5b79393485c088bd2c4398e32f5754c32af006a9ffd DART_SASS_SHA_MACOS=79e060b0e131c3bb3c16926bafc371dc33feab122bfa8c01aa337a072097967b DART_SASS_SHA_WINDOWS=0bc4708b37cd1bac4740e83ac5e3176e66b774f77fd5dd364da5b5cfc9bfb469 "${CURRENT_ENV[@]}" \
echo "$(/home/github/70412793599/helpers/eval_expression p:'(' f:success p:'(' p:')' p:')' o:'&&' p:'(' s:windows-latest o:== s:macos-latest p:')')")
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=10 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=bep GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=gohugoio/hugo GITHUB_REPOSITORY_OWNER=gohugoio GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=c48551677c2504e3f2d7fa53ee42766e0333b957 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Test GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 GOPROXY=https://proxy.golang.org GO111MODULE=true SASS_VERSION=1.80.3 DART_SASS_SHA_LINUX=7c933edbad0a7d389192c5b79393485c088bd2c4398e32f5754c32af006a9ffd DART_SASS_SHA_MACOS=79e060b0e131c3bb3c16926bafc371dc33feab122bfa8c01aa337a072097967b DART_SASS_SHA_WINDOWS=0bc4708b37cd1bac4740e83ac5e3176e66b774f77fd5dd364da5b5cfc9bfb469 "${CURRENT_ENV[@]}" \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run 'brew install pandoc'
echo "##[endgroup]"
echo 'brew install pandoc
' > /home/github/70412793599/steps/bugswarm_10.sh
chmod u+x /home/github/70412793599/steps/bugswarm_10.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=10 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=bep GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=gohugoio/hugo GITHUB_REPOSITORY_OWNER=gohugoio GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=c48551677c2504e3f2d7fa53ee42766e0333b957 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Test GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 GOPROXY=https://proxy.golang.org GO111MODULE=true SASS_VERSION=1.80.3 DART_SASS_SHA_LINUX=7c933edbad0a7d389192c5b79393485c088bd2c4398e32f5754c32af006a9ffd DART_SASS_SHA_MACOS=79e060b0e131c3bb3c16926bafc371dc33feab122bfa8c01aa337a072097967b DART_SASS_SHA_WINDOWS=0bc4708b37cd1bac4740e83ac5e3176e66b774f77fd5dd364da5b5cfc9bfb469 "${CURRENT_ENV[@]}" \
bash -e /home/github/70412793599/steps/bugswarm_10.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=10 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=bep GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=gohugoio/hugo GITHUB_REPOSITORY_OWNER=gohugoio GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=c48551677c2504e3f2d7fa53ee42766e0333b957 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Test GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 GOPROXY=https://proxy.golang.org GO111MODULE=true SASS_VERSION=1.80.3 DART_SASS_SHA_LINUX=7c933edbad0a7d389192c5b79393485c088bd2c4398e32f5754c32af006a9ffd DART_SASS_SHA_MACOS=79e060b0e131c3bb3c16926bafc371dc33feab122bfa8c01aa337a072097967b DART_SASS_SHA_WINDOWS=0bc4708b37cd1bac4740e83ac5e3176e66b774f77fd5dd364da5b5cfc9bfb469 "${CURRENT_ENV[@]}" \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=10 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=bep GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=gohugoio/hugo GITHUB_REPOSITORY_OWNER=gohugoio GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=c48551677c2504e3f2d7fa53ee42766e0333b957 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Test GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 GOPROXY=https://proxy.golang.org GO111MODULE=true SASS_VERSION=1.80.3 DART_SASS_SHA_LINUX=7c933edbad0a7d389192c5b79393485c088bd2c4398e32f5754c32af006a9ffd DART_SASS_SHA_MACOS=79e060b0e131c3bb3c16926bafc371dc33feab122bfa8c01aa337a072097967b DART_SASS_SHA_WINDOWS=0bc4708b37cd1bac4740e83ac5e3176e66b774f77fd5dd364da5b5cfc9bfb469 "${CURRENT_ENV[@]}" \
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=11 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=bep GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=gohugoio/hugo GITHUB_REPOSITORY_OWNER=gohugoio GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=c48551677c2504e3f2d7fa53ee42766e0333b957 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Test GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 GOPROXY=https://proxy.golang.org GO111MODULE=true SASS_VERSION=1.80.3 DART_SASS_SHA_LINUX=7c933edbad0a7d389192c5b79393485c088bd2c4398e32f5754c32af006a9ffd DART_SASS_SHA_MACOS=79e060b0e131c3bb3c16926bafc371dc33feab122bfa8c01aa337a072097967b DART_SASS_SHA_WINDOWS=0bc4708b37cd1bac4740e83ac5e3176e66b774f77fd5dd364da5b5cfc9bfb469 "${CURRENT_ENV[@]}" \
echo "$(/home/github/70412793599/helpers/eval_expression p:'(' f:success p:'(' p:')' p:')' o:'&&' p:'(' s:windows-latest o:== s:windows-latest p:')')")
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=11 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=bep GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=gohugoio/hugo GITHUB_REPOSITORY_OWNER=gohugoio GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=c48551677c2504e3f2d7fa53ee42766e0333b957 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Test GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 GOPROXY=https://proxy.golang.org GO111MODULE=true SASS_VERSION=1.80.3 DART_SASS_SHA_LINUX=7c933edbad0a7d389192c5b79393485c088bd2c4398e32f5754c32af006a9ffd DART_SASS_SHA_MACOS=79e060b0e131c3bb3c16926bafc371dc33feab122bfa8c01aa337a072097967b DART_SASS_SHA_WINDOWS=0bc4708b37cd1bac4740e83ac5e3176e66b774f77fd5dd364da5b5cfc9bfb469 "${CURRENT_ENV[@]}" \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run 'choco install pandoc'
echo "##[endgroup]"
echo 'choco install pandoc
' > /home/github/70412793599/steps/bugswarm_11.sh
chmod u+x /home/github/70412793599/steps/bugswarm_11.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=11 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=bep GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=gohugoio/hugo GITHUB_REPOSITORY_OWNER=gohugoio GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=c48551677c2504e3f2d7fa53ee42766e0333b957 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Test GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 GOPROXY=https://proxy.golang.org GO111MODULE=true SASS_VERSION=1.80.3 DART_SASS_SHA_LINUX=7c933edbad0a7d389192c5b79393485c088bd2c4398e32f5754c32af006a9ffd DART_SASS_SHA_MACOS=79e060b0e131c3bb3c16926bafc371dc33feab122bfa8c01aa337a072097967b DART_SASS_SHA_WINDOWS=0bc4708b37cd1bac4740e83ac5e3176e66b774f77fd5dd364da5b5cfc9bfb469 "${CURRENT_ENV[@]}" \
bash -e /home/github/70412793599/steps/bugswarm_11.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=11 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=bep GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=gohugoio/hugo GITHUB_REPOSITORY_OWNER=gohugoio GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=c48551677c2504e3f2d7fa53ee42766e0333b957 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Test GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 GOPROXY=https://proxy.golang.org GO111MODULE=true SASS_VERSION=1.80.3 DART_SASS_SHA_LINUX=7c933edbad0a7d389192c5b79393485c088bd2c4398e32f5754c32af006a9ffd DART_SASS_SHA_MACOS=79e060b0e131c3bb3c16926bafc371dc33feab122bfa8c01aa337a072097967b DART_SASS_SHA_WINDOWS=0bc4708b37cd1bac4740e83ac5e3176e66b774f77fd5dd364da5b5cfc9bfb469 "${CURRENT_ENV[@]}" \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=11 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=bep GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=gohugoio/hugo GITHUB_REPOSITORY_OWNER=gohugoio GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=c48551677c2504e3f2d7fa53ee42766e0333b957 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Test GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 GOPROXY=https://proxy.golang.org GO111MODULE=true SASS_VERSION=1.80.3 DART_SASS_SHA_LINUX=7c933edbad0a7d389192c5b79393485c088bd2c4398e32f5754c32af006a9ffd DART_SASS_SHA_MACOS=79e060b0e131c3bb3c16926bafc371dc33feab122bfa8c01aa337a072097967b DART_SASS_SHA_WINDOWS=0bc4708b37cd1bac4740e83ac5e3176e66b774f77fd5dd364da5b5cfc9bfb469 "${CURRENT_ENV[@]}" \
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=12 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=bep GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=gohugoio/hugo GITHUB_REPOSITORY_OWNER=gohugoio GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=c48551677c2504e3f2d7fa53ee42766e0333b957 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Test GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 GOPROXY=https://proxy.golang.org GO111MODULE=true SASS_VERSION=1.80.3 DART_SASS_SHA_LINUX=7c933edbad0a7d389192c5b79393485c088bd2c4398e32f5754c32af006a9ffd DART_SASS_SHA_MACOS=79e060b0e131c3bb3c16926bafc371dc33feab122bfa8c01aa337a072097967b DART_SASS_SHA_WINDOWS=0bc4708b37cd1bac4740e83ac5e3176e66b774f77fd5dd364da5b5cfc9bfb469 "${CURRENT_ENV[@]}" \
echo $(test "$_GITHUB_JOB_STATUS" = "success" && echo true || echo false))
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=12 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=bep GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=gohugoio/hugo GITHUB_REPOSITORY_OWNER=gohugoio GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=c48551677c2504e3f2d7fa53ee42766e0333b957 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Test GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 GOPROXY=https://proxy.golang.org GO111MODULE=true SASS_VERSION=1.80.3 DART_SASS_SHA_LINUX=7c933edbad0a7d389192c5b79393485c088bd2c4398e32f5754c32af006a9ffd DART_SASS_SHA_MACOS=79e060b0e131c3bb3c16926bafc371dc33feab122bfa8c01aa337a072097967b DART_SASS_SHA_WINDOWS=0bc4708b37cd1bac4740e83ac5e3176e66b774f77fd5dd364da5b5cfc9bfb469 "${CURRENT_ENV[@]}" \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run 'pandoc -v'
echo "##[endgroup]"
echo 'pandoc -v' > /home/github/70412793599/steps/bugswarm_12.sh
chmod u+x /home/github/70412793599/steps/bugswarm_12.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=12 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=bep GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=gohugoio/hugo GITHUB_REPOSITORY_OWNER=gohugoio GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=c48551677c2504e3f2d7fa53ee42766e0333b957 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Test GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 GOPROXY=https://proxy.golang.org GO111MODULE=true SASS_VERSION=1.80.3 DART_SASS_SHA_LINUX=7c933edbad0a7d389192c5b79393485c088bd2c4398e32f5754c32af006a9ffd DART_SASS_SHA_MACOS=79e060b0e131c3bb3c16926bafc371dc33feab122bfa8c01aa337a072097967b DART_SASS_SHA_WINDOWS=0bc4708b37cd1bac4740e83ac5e3176e66b774f77fd5dd364da5b5cfc9bfb469 "${CURRENT_ENV[@]}" \
bash -e /home/github/70412793599/steps/bugswarm_12.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=12 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=bep GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=gohugoio/hugo GITHUB_REPOSITORY_OWNER=gohugoio GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=c48551677c2504e3f2d7fa53ee42766e0333b957 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Test GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 GOPROXY=https://proxy.golang.org GO111MODULE=true SASS_VERSION=1.80.3 DART_SASS_SHA_LINUX=7c933edbad0a7d389192c5b79393485c088bd2c4398e32f5754c32af006a9ffd DART_SASS_SHA_MACOS=79e060b0e131c3bb3c16926bafc371dc33feab122bfa8c01aa337a072097967b DART_SASS_SHA_WINDOWS=0bc4708b37cd1bac4740e83ac5e3176e66b774f77fd5dd364da5b5cfc9bfb469 "${CURRENT_ENV[@]}" \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=12 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=bep GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=gohugoio/hugo GITHUB_REPOSITORY_OWNER=gohugoio GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=c48551677c2504e3f2d7fa53ee42766e0333b957 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Test GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 GOPROXY=https://proxy.golang.org GO111MODULE=true SASS_VERSION=1.80.3 DART_SASS_SHA_LINUX=7c933edbad0a7d389192c5b79393485c088bd2c4398e32f5754c32af006a9ffd DART_SASS_SHA_MACOS=79e060b0e131c3bb3c16926bafc371dc33feab122bfa8c01aa337a072097967b DART_SASS_SHA_WINDOWS=0bc4708b37cd1bac4740e83ac5e3176e66b774f77fd5dd364da5b5cfc9bfb469 "${CURRENT_ENV[@]}" \
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=13 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=bep GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=gohugoio/hugo GITHUB_REPOSITORY_OWNER=gohugoio GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=c48551677c2504e3f2d7fa53ee42766e0333b957 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Test GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 GOPROXY=https://proxy.golang.org GO111MODULE=true SASS_VERSION=1.80.3 DART_SASS_SHA_LINUX=7c933edbad0a7d389192c5b79393485c088bd2c4398e32f5754c32af006a9ffd DART_SASS_SHA_MACOS=79e060b0e131c3bb3c16926bafc371dc33feab122bfa8c01aa337a072097967b DART_SASS_SHA_WINDOWS=0bc4708b37cd1bac4740e83ac5e3176e66b774f77fd5dd364da5b5cfc9bfb469 "${CURRENT_ENV[@]}" \
echo "$(/home/github/70412793599/helpers/eval_expression p:'(' f:success p:'(' p:')' p:')' o:'&&' p:'(' s:windows-latest o:== s:windows-latest p:')')")
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=13 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=bep GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=gohugoio/hugo GITHUB_REPOSITORY_OWNER=gohugoio GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=c48551677c2504e3f2d7fa53ee42766e0333b957 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Test GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 GOPROXY=https://proxy.golang.org GO111MODULE=true SASS_VERSION=1.80.3 DART_SASS_SHA_LINUX=7c933edbad0a7d389192c5b79393485c088bd2c4398e32f5754c32af006a9ffd DART_SASS_SHA_MACOS=79e060b0e131c3bb3c16926bafc371dc33feab122bfa8c01aa337a072097967b DART_SASS_SHA_WINDOWS=0bc4708b37cd1bac4740e83ac5e3176e66b774f77fd5dd364da5b5cfc9bfb469 "${CURRENT_ENV[@]}" \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run 'choco install mingw'
echo "##[endgroup]"
echo 'choco install mingw
' > /home/github/70412793599/steps/bugswarm_13.sh
chmod u+x /home/github/70412793599/steps/bugswarm_13.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=13 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=bep GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=gohugoio/hugo GITHUB_REPOSITORY_OWNER=gohugoio GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=c48551677c2504e3f2d7fa53ee42766e0333b957 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Test GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 GOPROXY=https://proxy.golang.org GO111MODULE=true SASS_VERSION=1.80.3 DART_SASS_SHA_LINUX=7c933edbad0a7d389192c5b79393485c088bd2c4398e32f5754c32af006a9ffd DART_SASS_SHA_MACOS=79e060b0e131c3bb3c16926bafc371dc33feab122bfa8c01aa337a072097967b DART_SASS_SHA_WINDOWS=0bc4708b37cd1bac4740e83ac5e3176e66b774f77fd5dd364da5b5cfc9bfb469 "${CURRENT_ENV[@]}" \
bash -e /home/github/70412793599/steps/bugswarm_13.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=13 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=bep GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=gohugoio/hugo GITHUB_REPOSITORY_OWNER=gohugoio GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=c48551677c2504e3f2d7fa53ee42766e0333b957 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Test GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 GOPROXY=https://proxy.golang.org GO111MODULE=true SASS_VERSION=1.80.3 DART_SASS_SHA_LINUX=7c933edbad0a7d389192c5b79393485c088bd2c4398e32f5754c32af006a9ffd DART_SASS_SHA_MACOS=79e060b0e131c3bb3c16926bafc371dc33feab122bfa8c01aa337a072097967b DART_SASS_SHA_WINDOWS=0bc4708b37cd1bac4740e83ac5e3176e66b774f77fd5dd364da5b5cfc9bfb469 "${CURRENT_ENV[@]}" \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=13 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=bep GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=gohugoio/hugo GITHUB_REPOSITORY_OWNER=gohugoio GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=c48551677c2504e3f2d7fa53ee42766e0333b957 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Test GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 GOPROXY=https://proxy.golang.org GO111MODULE=true SASS_VERSION=1.80.3 DART_SASS_SHA_LINUX=7c933edbad0a7d389192c5b79393485c088bd2c4398e32f5754c32af006a9ffd DART_SASS_SHA_MACOS=79e060b0e131c3bb3c16926bafc371dc33feab122bfa8c01aa337a072097967b DART_SASS_SHA_WINDOWS=0bc4708b37cd1bac4740e83ac5e3176e66b774f77fd5dd364da5b5cfc9bfb469 "${CURRENT_ENV[@]}" \
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=14 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=bep GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=gohugoio/hugo GITHUB_REPOSITORY_OWNER=gohugoio GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=c48551677c2504e3f2d7fa53ee42766e0333b957 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Test GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 GOPROXY=https://proxy.golang.org GO111MODULE=true SASS_VERSION=1.80.3 DART_SASS_SHA_LINUX=7c933edbad0a7d389192c5b79393485c088bd2c4398e32f5754c32af006a9ffd DART_SASS_SHA_MACOS=79e060b0e131c3bb3c16926bafc371dc33feab122bfa8c01aa337a072097967b DART_SASS_SHA_WINDOWS=0bc4708b37cd1bac4740e83ac5e3176e66b774f77fd5dd364da5b5cfc9bfb469 "${CURRENT_ENV[@]}" \
echo "$(/home/github/70412793599/helpers/eval_expression p:'(' f:success p:'(' p:')' p:')' o:'&&' p:'(' s:windows-latest o:== s:ubuntu-latest p:')')")
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=14 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=bep GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=gohugoio/hugo GITHUB_REPOSITORY_OWNER=gohugoio GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=c48551677c2504e3f2d7fa53ee42766e0333b957 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Test GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 GOPROXY=https://proxy.golang.org GO111MODULE=true SASS_VERSION=1.80.3 DART_SASS_SHA_LINUX=7c933edbad0a7d389192c5b79393485c088bd2c4398e32f5754c32af006a9ffd DART_SASS_SHA_MACOS=79e060b0e131c3bb3c16926bafc371dc33feab122bfa8c01aa337a072097967b DART_SASS_SHA_WINDOWS=0bc4708b37cd1bac4740e83ac5e3176e66b774f77fd5dd364da5b5cfc9bfb469 "${CURRENT_ENV[@]}" \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run 'echo "Install Dart Sass version ${SASS_VERSION} ..."'
echo "##[endgroup]"
echo 'echo "Install Dart Sass version ${SASS_VERSION} ..."
curl -LJO "https://github.com/sass/dart-sass/releases/download/${SASS_VERSION}/dart-sass-${SASS_VERSION}-linux-x64.tar.gz";
echo "${DART_SASS_SHA_LINUX}  dart-sass-${SASS_VERSION}-linux-x64.tar.gz" | sha256sum -c;
tar -xvf "dart-sass-${SASS_VERSION}-linux-x64.tar.gz";
echo "$GOBIN"
echo "$GITHUB_WORKSPACE/dart-sass/" >> $GITHUB_PATH
' > /home/github/70412793599/steps/bugswarm_14.sh
chmod u+x /home/github/70412793599/steps/bugswarm_14.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=14 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=bep GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=gohugoio/hugo GITHUB_REPOSITORY_OWNER=gohugoio GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=c48551677c2504e3f2d7fa53ee42766e0333b957 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Test GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 GOPROXY=https://proxy.golang.org GO111MODULE=true SASS_VERSION=1.80.3 DART_SASS_SHA_LINUX=7c933edbad0a7d389192c5b79393485c088bd2c4398e32f5754c32af006a9ffd DART_SASS_SHA_MACOS=79e060b0e131c3bb3c16926bafc371dc33feab122bfa8c01aa337a072097967b DART_SASS_SHA_WINDOWS=0bc4708b37cd1bac4740e83ac5e3176e66b774f77fd5dd364da5b5cfc9bfb469 "${CURRENT_ENV[@]}" \
bash -e /home/github/70412793599/steps/bugswarm_14.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=14 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=bep GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=gohugoio/hugo GITHUB_REPOSITORY_OWNER=gohugoio GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=c48551677c2504e3f2d7fa53ee42766e0333b957 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Test GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 GOPROXY=https://proxy.golang.org GO111MODULE=true SASS_VERSION=1.80.3 DART_SASS_SHA_LINUX=7c933edbad0a7d389192c5b79393485c088bd2c4398e32f5754c32af006a9ffd DART_SASS_SHA_MACOS=79e060b0e131c3bb3c16926bafc371dc33feab122bfa8c01aa337a072097967b DART_SASS_SHA_WINDOWS=0bc4708b37cd1bac4740e83ac5e3176e66b774f77fd5dd364da5b5cfc9bfb469 "${CURRENT_ENV[@]}" \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=14 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=bep GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=gohugoio/hugo GITHUB_REPOSITORY_OWNER=gohugoio GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=c48551677c2504e3f2d7fa53ee42766e0333b957 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Test GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 GOPROXY=https://proxy.golang.org GO111MODULE=true SASS_VERSION=1.80.3 DART_SASS_SHA_LINUX=7c933edbad0a7d389192c5b79393485c088bd2c4398e32f5754c32af006a9ffd DART_SASS_SHA_MACOS=79e060b0e131c3bb3c16926bafc371dc33feab122bfa8c01aa337a072097967b DART_SASS_SHA_WINDOWS=0bc4708b37cd1bac4740e83ac5e3176e66b774f77fd5dd364da5b5cfc9bfb469 "${CURRENT_ENV[@]}" \
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=15 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=bep GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=gohugoio/hugo GITHUB_REPOSITORY_OWNER=gohugoio GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=c48551677c2504e3f2d7fa53ee42766e0333b957 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Test GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 GOPROXY=https://proxy.golang.org GO111MODULE=true SASS_VERSION=1.80.3 DART_SASS_SHA_LINUX=7c933edbad0a7d389192c5b79393485c088bd2c4398e32f5754c32af006a9ffd DART_SASS_SHA_MACOS=79e060b0e131c3bb3c16926bafc371dc33feab122bfa8c01aa337a072097967b DART_SASS_SHA_WINDOWS=0bc4708b37cd1bac4740e83ac5e3176e66b774f77fd5dd364da5b5cfc9bfb469 "${CURRENT_ENV[@]}" \
echo "$(/home/github/70412793599/helpers/eval_expression p:'(' f:success p:'(' p:')' p:')' o:'&&' p:'(' s:windows-latest o:== s:macos-latest p:')')")
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=15 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=bep GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=gohugoio/hugo GITHUB_REPOSITORY_OWNER=gohugoio GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=c48551677c2504e3f2d7fa53ee42766e0333b957 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Test GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 GOPROXY=https://proxy.golang.org GO111MODULE=true SASS_VERSION=1.80.3 DART_SASS_SHA_LINUX=7c933edbad0a7d389192c5b79393485c088bd2c4398e32f5754c32af006a9ffd DART_SASS_SHA_MACOS=79e060b0e131c3bb3c16926bafc371dc33feab122bfa8c01aa337a072097967b DART_SASS_SHA_WINDOWS=0bc4708b37cd1bac4740e83ac5e3176e66b774f77fd5dd364da5b5cfc9bfb469 "${CURRENT_ENV[@]}" \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run 'echo "Install Dart Sass version ${SASS_VERSION} ..."'
echo "##[endgroup]"
echo 'echo "Install Dart Sass version ${SASS_VERSION} ..."
curl -LJO "https://github.com/sass/dart-sass/releases/download/${SASS_VERSION}/dart-sass-${SASS_VERSION}-macos-x64.tar.gz";
echo "${DART_SASS_SHA_MACOS}  dart-sass-${SASS_VERSION}-macos-x64.tar.gz" | shasum -a 256 -c;
tar -xvf "dart-sass-${SASS_VERSION}-macos-x64.tar.gz";
echo "$GITHUB_WORKSPACE/dart-sass/" >> $GITHUB_PATH
' > /home/github/70412793599/steps/bugswarm_15.sh
chmod u+x /home/github/70412793599/steps/bugswarm_15.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=15 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=bep GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=gohugoio/hugo GITHUB_REPOSITORY_OWNER=gohugoio GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=c48551677c2504e3f2d7fa53ee42766e0333b957 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Test GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 GOPROXY=https://proxy.golang.org GO111MODULE=true SASS_VERSION=1.80.3 DART_SASS_SHA_LINUX=7c933edbad0a7d389192c5b79393485c088bd2c4398e32f5754c32af006a9ffd DART_SASS_SHA_MACOS=79e060b0e131c3bb3c16926bafc371dc33feab122bfa8c01aa337a072097967b DART_SASS_SHA_WINDOWS=0bc4708b37cd1bac4740e83ac5e3176e66b774f77fd5dd364da5b5cfc9bfb469 "${CURRENT_ENV[@]}" \
bash -e /home/github/70412793599/steps/bugswarm_15.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=15 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=bep GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=gohugoio/hugo GITHUB_REPOSITORY_OWNER=gohugoio GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=c48551677c2504e3f2d7fa53ee42766e0333b957 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Test GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 GOPROXY=https://proxy.golang.org GO111MODULE=true SASS_VERSION=1.80.3 DART_SASS_SHA_LINUX=7c933edbad0a7d389192c5b79393485c088bd2c4398e32f5754c32af006a9ffd DART_SASS_SHA_MACOS=79e060b0e131c3bb3c16926bafc371dc33feab122bfa8c01aa337a072097967b DART_SASS_SHA_WINDOWS=0bc4708b37cd1bac4740e83ac5e3176e66b774f77fd5dd364da5b5cfc9bfb469 "${CURRENT_ENV[@]}" \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=15 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=bep GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=gohugoio/hugo GITHUB_REPOSITORY_OWNER=gohugoio GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=c48551677c2504e3f2d7fa53ee42766e0333b957 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Test GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 GOPROXY=https://proxy.golang.org GO111MODULE=true SASS_VERSION=1.80.3 DART_SASS_SHA_LINUX=7c933edbad0a7d389192c5b79393485c088bd2c4398e32f5754c32af006a9ffd DART_SASS_SHA_MACOS=79e060b0e131c3bb3c16926bafc371dc33feab122bfa8c01aa337a072097967b DART_SASS_SHA_WINDOWS=0bc4708b37cd1bac4740e83ac5e3176e66b774f77fd5dd364da5b5cfc9bfb469 "${CURRENT_ENV[@]}" \
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=16 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=bep GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=gohugoio/hugo GITHUB_REPOSITORY_OWNER=gohugoio GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=c48551677c2504e3f2d7fa53ee42766e0333b957 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Test GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 GOPROXY=https://proxy.golang.org GO111MODULE=true SASS_VERSION=1.80.3 DART_SASS_SHA_LINUX=7c933edbad0a7d389192c5b79393485c088bd2c4398e32f5754c32af006a9ffd DART_SASS_SHA_MACOS=79e060b0e131c3bb3c16926bafc371dc33feab122bfa8c01aa337a072097967b DART_SASS_SHA_WINDOWS=0bc4708b37cd1bac4740e83ac5e3176e66b774f77fd5dd364da5b5cfc9bfb469 "${CURRENT_ENV[@]}" \
echo "$(/home/github/70412793599/helpers/eval_expression p:'(' f:success p:'(' p:')' p:')' o:'&&' p:'(' s:windows-latest o:== s:windows-latest p:')')")
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=16 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=bep GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=gohugoio/hugo GITHUB_REPOSITORY_OWNER=gohugoio GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=c48551677c2504e3f2d7fa53ee42766e0333b957 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Test GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 GOPROXY=https://proxy.golang.org GO111MODULE=true SASS_VERSION=1.80.3 DART_SASS_SHA_LINUX=7c933edbad0a7d389192c5b79393485c088bd2c4398e32f5754c32af006a9ffd DART_SASS_SHA_MACOS=79e060b0e131c3bb3c16926bafc371dc33feab122bfa8c01aa337a072097967b DART_SASS_SHA_WINDOWS=0bc4708b37cd1bac4740e83ac5e3176e66b774f77fd5dd364da5b5cfc9bfb469 "${CURRENT_ENV[@]}" \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run 'echo "Install Dart Sass version ${env:SASS_VERSION} ..."'
echo "##[endgroup]"
echo 'echo "Install Dart Sass version ${env:SASS_VERSION} ..."
curl -LJO "https://github.com/sass/dart-sass/releases/download/${env:SASS_VERSION}/dart-sass-${env:SASS_VERSION}-windows-x64.zip";
Expand-Archive -Path "dart-sass-${env:SASS_VERSION}-windows-x64.zip" -DestinationPath .;
echo  "$env:GITHUB_WORKSPACE/dart-sass/" | Out-File -FilePath $Env:GITHUB_PATH -Encoding utf-8 -Append
' > /home/github/70412793599/steps/bugswarm_16.sh
chmod u+x /home/github/70412793599/steps/bugswarm_16.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=16 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=bep GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=gohugoio/hugo GITHUB_REPOSITORY_OWNER=gohugoio GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=c48551677c2504e3f2d7fa53ee42766e0333b957 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Test GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 GOPROXY=https://proxy.golang.org GO111MODULE=true SASS_VERSION=1.80.3 DART_SASS_SHA_LINUX=7c933edbad0a7d389192c5b79393485c088bd2c4398e32f5754c32af006a9ffd DART_SASS_SHA_MACOS=79e060b0e131c3bb3c16926bafc371dc33feab122bfa8c01aa337a072097967b DART_SASS_SHA_WINDOWS=0bc4708b37cd1bac4740e83ac5e3176e66b774f77fd5dd364da5b5cfc9bfb469 "${CURRENT_ENV[@]}" \
bash -e /home/github/70412793599/steps/bugswarm_16.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=16 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=bep GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=gohugoio/hugo GITHUB_REPOSITORY_OWNER=gohugoio GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=c48551677c2504e3f2d7fa53ee42766e0333b957 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Test GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 GOPROXY=https://proxy.golang.org GO111MODULE=true SASS_VERSION=1.80.3 DART_SASS_SHA_LINUX=7c933edbad0a7d389192c5b79393485c088bd2c4398e32f5754c32af006a9ffd DART_SASS_SHA_MACOS=79e060b0e131c3bb3c16926bafc371dc33feab122bfa8c01aa337a072097967b DART_SASS_SHA_WINDOWS=0bc4708b37cd1bac4740e83ac5e3176e66b774f77fd5dd364da5b5cfc9bfb469 "${CURRENT_ENV[@]}" \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=16 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=bep GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=gohugoio/hugo GITHUB_REPOSITORY_OWNER=gohugoio GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=c48551677c2504e3f2d7fa53ee42766e0333b957 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Test GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 GOPROXY=https://proxy.golang.org GO111MODULE=true SASS_VERSION=1.80.3 DART_SASS_SHA_LINUX=7c933edbad0a7d389192c5b79393485c088bd2c4398e32f5754c32af006a9ffd DART_SASS_SHA_MACOS=79e060b0e131c3bb3c16926bafc371dc33feab122bfa8c01aa337a072097967b DART_SASS_SHA_WINDOWS=0bc4708b37cd1bac4740e83ac5e3176e66b774f77fd5dd364da5b5cfc9bfb469 "${CURRENT_ENV[@]}" \
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=17 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=bep GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=gohugoio/hugo GITHUB_REPOSITORY_OWNER=gohugoio GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=c48551677c2504e3f2d7fa53ee42766e0333b957 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Test GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 GOPROXY=https://proxy.golang.org GO111MODULE=true SASS_VERSION=1.80.3 DART_SASS_SHA_LINUX=7c933edbad0a7d389192c5b79393485c088bd2c4398e32f5754c32af006a9ffd DART_SASS_SHA_MACOS=79e060b0e131c3bb3c16926bafc371dc33feab122bfa8c01aa337a072097967b DART_SASS_SHA_WINDOWS=0bc4708b37cd1bac4740e83ac5e3176e66b774f77fd5dd364da5b5cfc9bfb469 "${CURRENT_ENV[@]}" \
echo "$(/home/github/70412793599/helpers/eval_expression p:'(' f:success p:'(' p:')' p:')' o:'&&' p:'(' s:windows-latest o:== s:ubuntu-latest p:')')")
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=17 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=bep GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=gohugoio/hugo GITHUB_REPOSITORY_OWNER=gohugoio GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=c48551677c2504e3f2d7fa53ee42766e0333b957 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Test GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 GOPROXY=https://proxy.golang.org GO111MODULE=true SASS_VERSION=1.80.3 DART_SASS_SHA_LINUX=7c933edbad0a7d389192c5b79393485c088bd2c4398e32f5754c32af006a9ffd DART_SASS_SHA_MACOS=79e060b0e131c3bb3c16926bafc371dc33feab122bfa8c01aa337a072097967b DART_SASS_SHA_WINDOWS=0bc4708b37cd1bac4740e83ac5e3176e66b774f77fd5dd364da5b5cfc9bfb469 "${CURRENT_ENV[@]}" \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run 'go install honnef.co/go/tools/cmd/staticcheck@latest'
echo "##[endgroup]"
echo 'go install honnef.co/go/tools/cmd/staticcheck@latest' > /home/github/70412793599/steps/bugswarm_17.sh
chmod u+x /home/github/70412793599/steps/bugswarm_17.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=17 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=bep GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=gohugoio/hugo GITHUB_REPOSITORY_OWNER=gohugoio GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=c48551677c2504e3f2d7fa53ee42766e0333b957 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Test GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 GOPROXY=https://proxy.golang.org GO111MODULE=true SASS_VERSION=1.80.3 DART_SASS_SHA_LINUX=7c933edbad0a7d389192c5b79393485c088bd2c4398e32f5754c32af006a9ffd DART_SASS_SHA_MACOS=79e060b0e131c3bb3c16926bafc371dc33feab122bfa8c01aa337a072097967b DART_SASS_SHA_WINDOWS=0bc4708b37cd1bac4740e83ac5e3176e66b774f77fd5dd364da5b5cfc9bfb469 "${CURRENT_ENV[@]}" \
bash -e /home/github/70412793599/steps/bugswarm_17.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=17 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=bep GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=gohugoio/hugo GITHUB_REPOSITORY_OWNER=gohugoio GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=c48551677c2504e3f2d7fa53ee42766e0333b957 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Test GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 GOPROXY=https://proxy.golang.org GO111MODULE=true SASS_VERSION=1.80.3 DART_SASS_SHA_LINUX=7c933edbad0a7d389192c5b79393485c088bd2c4398e32f5754c32af006a9ffd DART_SASS_SHA_MACOS=79e060b0e131c3bb3c16926bafc371dc33feab122bfa8c01aa337a072097967b DART_SASS_SHA_WINDOWS=0bc4708b37cd1bac4740e83ac5e3176e66b774f77fd5dd364da5b5cfc9bfb469 "${CURRENT_ENV[@]}" \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=17 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=bep GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=gohugoio/hugo GITHUB_REPOSITORY_OWNER=gohugoio GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=c48551677c2504e3f2d7fa53ee42766e0333b957 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Test GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 GOPROXY=https://proxy.golang.org GO111MODULE=true SASS_VERSION=1.80.3 DART_SASS_SHA_LINUX=7c933edbad0a7d389192c5b79393485c088bd2c4398e32f5754c32af006a9ffd DART_SASS_SHA_MACOS=79e060b0e131c3bb3c16926bafc371dc33feab122bfa8c01aa337a072097967b DART_SASS_SHA_WINDOWS=0bc4708b37cd1bac4740e83ac5e3176e66b774f77fd5dd364da5b5cfc9bfb469 "${CURRENT_ENV[@]}" \
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=18 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=bep GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=gohugoio/hugo GITHUB_REPOSITORY_OWNER=gohugoio GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=c48551677c2504e3f2d7fa53ee42766e0333b957 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Test GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 GOPROXY=https://proxy.golang.org GO111MODULE=true SASS_VERSION=1.80.3 DART_SASS_SHA_LINUX=7c933edbad0a7d389192c5b79393485c088bd2c4398e32f5754c32af006a9ffd DART_SASS_SHA_MACOS=79e060b0e131c3bb3c16926bafc371dc33feab122bfa8c01aa337a072097967b DART_SASS_SHA_WINDOWS=0bc4708b37cd1bac4740e83ac5e3176e66b774f77fd5dd364da5b5cfc9bfb469 "${CURRENT_ENV[@]}" \
echo "$(/home/github/70412793599/helpers/eval_expression p:'(' f:success p:'(' p:')' p:')' o:'&&' p:'(' s:windows-latest o:== s:ubuntu-latest p:')')")
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=18 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=bep GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=gohugoio/hugo GITHUB_REPOSITORY_OWNER=gohugoio GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=c48551677c2504e3f2d7fa53ee42766e0333b957 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Test GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 GOPROXY=https://proxy.golang.org GO111MODULE=true SASS_VERSION=1.80.3 DART_SASS_SHA_LINUX=7c933edbad0a7d389192c5b79393485c088bd2c4398e32f5754c32af006a9ffd DART_SASS_SHA_MACOS=79e060b0e131c3bb3c16926bafc371dc33feab122bfa8c01aa337a072097967b DART_SASS_SHA_WINDOWS=0bc4708b37cd1bac4740e83ac5e3176e66b774f77fd5dd364da5b5cfc9bfb469 "${CURRENT_ENV[@]}" \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run 'export STATICCHECK_CACHE="/tmp/staticcheck"'
echo "##[endgroup]"
echo 'export STATICCHECK_CACHE="/tmp/staticcheck"
staticcheck ./...
rm -rf /tmp/staticcheck
' > /home/github/70412793599/steps/bugswarm_18.sh
chmod u+x /home/github/70412793599/steps/bugswarm_18.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=18 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=bep GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=gohugoio/hugo GITHUB_REPOSITORY_OWNER=gohugoio GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=c48551677c2504e3f2d7fa53ee42766e0333b957 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Test GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 GOPROXY=https://proxy.golang.org GO111MODULE=true SASS_VERSION=1.80.3 DART_SASS_SHA_LINUX=7c933edbad0a7d389192c5b79393485c088bd2c4398e32f5754c32af006a9ffd DART_SASS_SHA_MACOS=79e060b0e131c3bb3c16926bafc371dc33feab122bfa8c01aa337a072097967b DART_SASS_SHA_WINDOWS=0bc4708b37cd1bac4740e83ac5e3176e66b774f77fd5dd364da5b5cfc9bfb469 "${CURRENT_ENV[@]}" \
bash -e /home/github/70412793599/steps/bugswarm_18.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=18 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=bep GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=gohugoio/hugo GITHUB_REPOSITORY_OWNER=gohugoio GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=c48551677c2504e3f2d7fa53ee42766e0333b957 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Test GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 GOPROXY=https://proxy.golang.org GO111MODULE=true SASS_VERSION=1.80.3 DART_SASS_SHA_LINUX=7c933edbad0a7d389192c5b79393485c088bd2c4398e32f5754c32af006a9ffd DART_SASS_SHA_MACOS=79e060b0e131c3bb3c16926bafc371dc33feab122bfa8c01aa337a072097967b DART_SASS_SHA_WINDOWS=0bc4708b37cd1bac4740e83ac5e3176e66b774f77fd5dd364da5b5cfc9bfb469 "${CURRENT_ENV[@]}" \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=18 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=bep GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=gohugoio/hugo GITHUB_REPOSITORY_OWNER=gohugoio GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=c48551677c2504e3f2d7fa53ee42766e0333b957 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Test GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 GOPROXY=https://proxy.golang.org GO111MODULE=true SASS_VERSION=1.80.3 DART_SASS_SHA_LINUX=7c933edbad0a7d389192c5b79393485c088bd2c4398e32f5754c32af006a9ffd DART_SASS_SHA_MACOS=79e060b0e131c3bb3c16926bafc371dc33feab122bfa8c01aa337a072097967b DART_SASS_SHA_WINDOWS=0bc4708b37cd1bac4740e83ac5e3176e66b774f77fd5dd364da5b5cfc9bfb469 "${CURRENT_ENV[@]}" \
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=19 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=bep GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=gohugoio/hugo GITHUB_REPOSITORY_OWNER=gohugoio GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=c48551677c2504e3f2d7fa53ee42766e0333b957 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Test GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 GOPROXY=https://proxy.golang.org GO111MODULE=true SASS_VERSION=1.80.3 DART_SASS_SHA_LINUX=7c933edbad0a7d389192c5b79393485c088bd2c4398e32f5754c32af006a9ffd DART_SASS_SHA_MACOS=79e060b0e131c3bb3c16926bafc371dc33feab122bfa8c01aa337a072097967b DART_SASS_SHA_WINDOWS=0bc4708b37cd1bac4740e83ac5e3176e66b774f77fd5dd364da5b5cfc9bfb469 "${CURRENT_ENV[@]}" HUGO_BUILD_TAGS=extended,withdeploy \
echo "$(/home/github/70412793599/helpers/eval_expression p:'(' f:success p:'(' p:')' p:')' o:'&&' p:'(' s:windows-latest o:'!=' s:windows-latest p:')')")
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=19 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=bep GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=gohugoio/hugo GITHUB_REPOSITORY_OWNER=gohugoio GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=c48551677c2504e3f2d7fa53ee42766e0333b957 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Test GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 GOPROXY=https://proxy.golang.org GO111MODULE=true SASS_VERSION=1.80.3 DART_SASS_SHA_LINUX=7c933edbad0a7d389192c5b79393485c088bd2c4398e32f5754c32af006a9ffd DART_SASS_SHA_MACOS=79e060b0e131c3bb3c16926bafc371dc33feab122bfa8c01aa337a072097967b DART_SASS_SHA_WINDOWS=0bc4708b37cd1bac4740e83ac5e3176e66b774f77fd5dd364da5b5cfc9bfb469 "${CURRENT_ENV[@]}" HUGO_BUILD_TAGS=extended,withdeploy \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run 'sass --version;'
echo "##[endgroup]"
echo 'sass --version;
mage -v check;
' > /home/github/70412793599/steps/bugswarm_19.sh
chmod u+x /home/github/70412793599/steps/bugswarm_19.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=19 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=bep GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=gohugoio/hugo GITHUB_REPOSITORY_OWNER=gohugoio GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=c48551677c2504e3f2d7fa53ee42766e0333b957 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Test GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 GOPROXY=https://proxy.golang.org GO111MODULE=true SASS_VERSION=1.80.3 DART_SASS_SHA_LINUX=7c933edbad0a7d389192c5b79393485c088bd2c4398e32f5754c32af006a9ffd DART_SASS_SHA_MACOS=79e060b0e131c3bb3c16926bafc371dc33feab122bfa8c01aa337a072097967b DART_SASS_SHA_WINDOWS=0bc4708b37cd1bac4740e83ac5e3176e66b774f77fd5dd364da5b5cfc9bfb469 "${CURRENT_ENV[@]}" HUGO_BUILD_TAGS=extended,withdeploy \
bash -e /home/github/70412793599/steps/bugswarm_19.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=19 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=bep GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=gohugoio/hugo GITHUB_REPOSITORY_OWNER=gohugoio GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=c48551677c2504e3f2d7fa53ee42766e0333b957 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Test GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 GOPROXY=https://proxy.golang.org GO111MODULE=true SASS_VERSION=1.80.3 DART_SASS_SHA_LINUX=7c933edbad0a7d389192c5b79393485c088bd2c4398e32f5754c32af006a9ffd DART_SASS_SHA_MACOS=79e060b0e131c3bb3c16926bafc371dc33feab122bfa8c01aa337a072097967b DART_SASS_SHA_WINDOWS=0bc4708b37cd1bac4740e83ac5e3176e66b774f77fd5dd364da5b5cfc9bfb469 "${CURRENT_ENV[@]}" HUGO_BUILD_TAGS=extended,withdeploy \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=19 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=bep GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=gohugoio/hugo GITHUB_REPOSITORY_OWNER=gohugoio GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=c48551677c2504e3f2d7fa53ee42766e0333b957 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Test GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 GOPROXY=https://proxy.golang.org GO111MODULE=true SASS_VERSION=1.80.3 DART_SASS_SHA_LINUX=7c933edbad0a7d389192c5b79393485c088bd2c4398e32f5754c32af006a9ffd DART_SASS_SHA_MACOS=79e060b0e131c3bb3c16926bafc371dc33feab122bfa8c01aa337a072097967b DART_SASS_SHA_WINDOWS=0bc4708b37cd1bac4740e83ac5e3176e66b774f77fd5dd364da5b5cfc9bfb469 "${CURRENT_ENV[@]}" HUGO_BUILD_TAGS=extended,withdeploy \
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=20 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=bep GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=gohugoio/hugo GITHUB_REPOSITORY_OWNER=gohugoio GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=c48551677c2504e3f2d7fa53ee42766e0333b957 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Test GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 GOPROXY=https://proxy.golang.org GO111MODULE=true SASS_VERSION=1.80.3 DART_SASS_SHA_LINUX=7c933edbad0a7d389192c5b79393485c088bd2c4398e32f5754c32af006a9ffd DART_SASS_SHA_MACOS=79e060b0e131c3bb3c16926bafc371dc33feab122bfa8c01aa337a072097967b DART_SASS_SHA_WINDOWS=0bc4708b37cd1bac4740e83ac5e3176e66b774f77fd5dd364da5b5cfc9bfb469 "${CURRENT_ENV[@]}" HUGO_BUILD_TAGS=extended,withdeploy \
echo "$(/home/github/70412793599/helpers/eval_expression p:'(' f:success p:'(' p:')' p:')' o:'&&' p:'(' s:windows-latest o:== s:windows-latest p:')')")
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=20 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=bep GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=gohugoio/hugo GITHUB_REPOSITORY_OWNER=gohugoio GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=c48551677c2504e3f2d7fa53ee42766e0333b957 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Test GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 GOPROXY=https://proxy.golang.org GO111MODULE=true SASS_VERSION=1.80.3 DART_SASS_SHA_LINUX=7c933edbad0a7d389192c5b79393485c088bd2c4398e32f5754c32af006a9ffd DART_SASS_SHA_MACOS=79e060b0e131c3bb3c16926bafc371dc33feab122bfa8c01aa337a072097967b DART_SASS_SHA_WINDOWS=0bc4708b37cd1bac4740e83ac5e3176e66b774f77fd5dd364da5b5cfc9bfb469 "${CURRENT_ENV[@]}" HUGO_BUILD_TAGS=extended,withdeploy \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run 'mage -v test'
echo "##[endgroup]"
echo 'mage -v test
' > /home/github/70412793599/steps/bugswarm_20.sh
chmod u+x /home/github/70412793599/steps/bugswarm_20.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=20 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=bep GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=gohugoio/hugo GITHUB_REPOSITORY_OWNER=gohugoio GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=c48551677c2504e3f2d7fa53ee42766e0333b957 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Test GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 GOPROXY=https://proxy.golang.org GO111MODULE=true SASS_VERSION=1.80.3 DART_SASS_SHA_LINUX=7c933edbad0a7d389192c5b79393485c088bd2c4398e32f5754c32af006a9ffd DART_SASS_SHA_MACOS=79e060b0e131c3bb3c16926bafc371dc33feab122bfa8c01aa337a072097967b DART_SASS_SHA_WINDOWS=0bc4708b37cd1bac4740e83ac5e3176e66b774f77fd5dd364da5b5cfc9bfb469 "${CURRENT_ENV[@]}" HUGO_BUILD_TAGS=extended,withdeploy \
bash -e /home/github/70412793599/steps/bugswarm_20.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=20 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=bep GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=gohugoio/hugo GITHUB_REPOSITORY_OWNER=gohugoio GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=c48551677c2504e3f2d7fa53ee42766e0333b957 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Test GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 GOPROXY=https://proxy.golang.org GO111MODULE=true SASS_VERSION=1.80.3 DART_SASS_SHA_LINUX=7c933edbad0a7d389192c5b79393485c088bd2c4398e32f5754c32af006a9ffd DART_SASS_SHA_MACOS=79e060b0e131c3bb3c16926bafc371dc33feab122bfa8c01aa337a072097967b DART_SASS_SHA_WINDOWS=0bc4708b37cd1bac4740e83ac5e3176e66b774f77fd5dd364da5b5cfc9bfb469 "${CURRENT_ENV[@]}" HUGO_BUILD_TAGS=extended,withdeploy \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=20 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=bep GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=gohugoio/hugo GITHUB_REPOSITORY_OWNER=gohugoio GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=c48551677c2504e3f2d7fa53ee42766e0333b957 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Test GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 GOPROXY=https://proxy.golang.org GO111MODULE=true SASS_VERSION=1.80.3 DART_SASS_SHA_LINUX=7c933edbad0a7d389192c5b79393485c088bd2c4398e32f5754c32af006a9ffd DART_SASS_SHA_MACOS=79e060b0e131c3bb3c16926bafc371dc33feab122bfa8c01aa337a072097967b DART_SASS_SHA_WINDOWS=0bc4708b37cd1bac4740e83ac5e3176e66b774f77fd5dd364da5b5cfc9bfb469 "${CURRENT_ENV[@]}" HUGO_BUILD_TAGS=extended,withdeploy \
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=21 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=bep GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=gohugoio/hugo GITHUB_REPOSITORY_OWNER=gohugoio GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=c48551677c2504e3f2d7fa53ee42766e0333b957 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Test GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 GOPROXY=https://proxy.golang.org GO111MODULE=true SASS_VERSION=1.80.3 DART_SASS_SHA_LINUX=7c933edbad0a7d389192c5b79393485c088bd2c4398e32f5754c32af006a9ffd DART_SASS_SHA_MACOS=79e060b0e131c3bb3c16926bafc371dc33feab122bfa8c01aa337a072097967b DART_SASS_SHA_WINDOWS=0bc4708b37cd1bac4740e83ac5e3176e66b774f77fd5dd364da5b5cfc9bfb469 "${CURRENT_ENV[@]}" GOARCH=amd64 GOOS=dragonfly \
echo "$(/home/github/70412793599/helpers/eval_expression p:'(' f:success p:'(' p:')' p:')' o:'&&' p:'(' s:windows-latest o:== s:ubuntu-latest p:')')")
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=21 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=bep GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=gohugoio/hugo GITHUB_REPOSITORY_OWNER=gohugoio GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=c48551677c2504e3f2d7fa53ee42766e0333b957 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Test GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 GOPROXY=https://proxy.golang.org GO111MODULE=true SASS_VERSION=1.80.3 DART_SASS_SHA_LINUX=7c933edbad0a7d389192c5b79393485c088bd2c4398e32f5754c32af006a9ffd DART_SASS_SHA_MACOS=79e060b0e131c3bb3c16926bafc371dc33feab122bfa8c01aa337a072097967b DART_SASS_SHA_WINDOWS=0bc4708b37cd1bac4740e83ac5e3176e66b774f77fd5dd364da5b5cfc9bfb469 "${CURRENT_ENV[@]}" GOARCH=amd64 GOOS=dragonfly \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run 'go install'
echo "##[endgroup]"
echo 'go install
go clean -i -cache
' > /home/github/70412793599/steps/bugswarm_21.sh
chmod u+x /home/github/70412793599/steps/bugswarm_21.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=21 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=bep GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=gohugoio/hugo GITHUB_REPOSITORY_OWNER=gohugoio GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=c48551677c2504e3f2d7fa53ee42766e0333b957 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Test GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 GOPROXY=https://proxy.golang.org GO111MODULE=true SASS_VERSION=1.80.3 DART_SASS_SHA_LINUX=7c933edbad0a7d389192c5b79393485c088bd2c4398e32f5754c32af006a9ffd DART_SASS_SHA_MACOS=79e060b0e131c3bb3c16926bafc371dc33feab122bfa8c01aa337a072097967b DART_SASS_SHA_WINDOWS=0bc4708b37cd1bac4740e83ac5e3176e66b774f77fd5dd364da5b5cfc9bfb469 "${CURRENT_ENV[@]}" GOARCH=amd64 GOOS=dragonfly \
bash -e /home/github/70412793599/steps/bugswarm_21.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=21 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=bep GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=gohugoio/hugo GITHUB_REPOSITORY_OWNER=gohugoio GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=c48551677c2504e3f2d7fa53ee42766e0333b957 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Test GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 GOPROXY=https://proxy.golang.org GO111MODULE=true SASS_VERSION=1.80.3 DART_SASS_SHA_LINUX=7c933edbad0a7d389192c5b79393485c088bd2c4398e32f5754c32af006a9ffd DART_SASS_SHA_MACOS=79e060b0e131c3bb3c16926bafc371dc33feab122bfa8c01aa337a072097967b DART_SASS_SHA_WINDOWS=0bc4708b37cd1bac4740e83ac5e3176e66b774f77fd5dd364da5b5cfc9bfb469 "${CURRENT_ENV[@]}" GOARCH=amd64 GOOS=dragonfly \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=21 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=bep GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=gohugoio/hugo GITHUB_REPOSITORY_OWNER=gohugoio GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=c48551677c2504e3f2d7fa53ee42766e0333b957 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Test GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 GOPROXY=https://proxy.golang.org GO111MODULE=true SASS_VERSION=1.80.3 DART_SASS_SHA_LINUX=7c933edbad0a7d389192c5b79393485c088bd2c4398e32f5754c32af006a9ffd DART_SASS_SHA_MACOS=79e060b0e131c3bb3c16926bafc371dc33feab122bfa8c01aa337a072097967b DART_SASS_SHA_WINDOWS=0bc4708b37cd1bac4740e83ac5e3176e66b774f77fd5dd364da5b5cfc9bfb469 "${CURRENT_ENV[@]}" GOARCH=amd64 GOOS=dragonfly \
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
   bash -e $ACTIONS_RUNNER_HOOK_JOB_COMPLETED 70412793599 passed
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
