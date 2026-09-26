#!/usr/bin/env bash
export GITHUB_WORKSPACE=/home/github/build/pyinstaller/pyinstaller

if [[ ! -z "$ACTIONS_RUNNER_HOOK_JOB_STARTED" ]]; then
   echo "A job started hook has been configured by the self-hosted runner administrator"
   echo "##[group]Run '$ACTIONS_RUNNER_HOOK_JOB_STARTED'"
   echo "##[endgroup]"
   bash -e $ACTIONS_RUNNER_HOOK_JOB_STARTED 70929241273 passed
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

cp /home/github/70929241273/event.json /home/github/workflow/event.json
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=1 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=actions/setup-python GITHUB_ACTIONS=true GITHUB_ACTOR=rokm GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=termux-test GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/termux-test GITHUB_REF_NAME=termux-test GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=pyinstaller/pyinstaller GITHUB_REPOSITORY_OWNER=pyinstaller GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=208c3caedf9c6614493e0db75d64767af408f521 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 FORCE_COLOR=1 PYINSTALLER_STRICT_UNPACK_MODE=1 PYINSTALLER_STRICT_COLLECT_MODE=1 PYINSTALLER_STRICT_BUNDLE_CODESIGN_ERROR=1 PYINSTALLER_VERIFY_BUNDLE_SIGNATURE=1 PYTHONWARNDEFAULTENCODING=true GITHUB_ACTION_PATH=/home/github/70929241273/actions/actions-setup-python@v6 "${CURRENT_ENV[@]}" INPUT_PYTHON-VERSION=3.11 INPUT_CHECK-LATEST=true INPUT_TOKEN= INPUT_UPDATE-ENVIRONMENT=true INPUT_ALLOW-PRERELEASES=false INPUT_FREETHREADED=false \
echo $(test "$_GITHUB_JOB_STATUS" = "success" && echo true || echo false))
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=1 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=actions/setup-python GITHUB_ACTIONS=true GITHUB_ACTOR=rokm GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=termux-test GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/termux-test GITHUB_REF_NAME=termux-test GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=pyinstaller/pyinstaller GITHUB_REPOSITORY_OWNER=pyinstaller GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=208c3caedf9c6614493e0db75d64767af408f521 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 FORCE_COLOR=1 PYINSTALLER_STRICT_UNPACK_MODE=1 PYINSTALLER_STRICT_COLLECT_MODE=1 PYINSTALLER_STRICT_BUNDLE_CODESIGN_ERROR=1 PYINSTALLER_VERIFY_BUNDLE_SIGNATURE=1 PYTHONWARNDEFAULTENCODING=true GITHUB_ACTION_PATH=/home/github/70929241273/actions/actions-setup-python@v6 "${CURRENT_ENV[@]}" INPUT_PYTHON-VERSION=3.11 INPUT_CHECK-LATEST=true INPUT_TOKEN= INPUT_UPDATE-ENVIRONMENT=true INPUT_ALLOW-PRERELEASES=false INPUT_FREETHREADED=false \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run actions/setup-python@v6
echo "##[endgroup]"
echo node /home/github/70929241273/actions/actions-setup-python@v6/dist/setup/index.js > /home/github/70929241273/steps/bugswarm_cmd.sh
chmod u+x /home/github/70929241273/steps/bugswarm_cmd.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=1 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=actions/setup-python GITHUB_ACTIONS=true GITHUB_ACTOR=rokm GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=termux-test GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/termux-test GITHUB_REF_NAME=termux-test GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=pyinstaller/pyinstaller GITHUB_REPOSITORY_OWNER=pyinstaller GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=208c3caedf9c6614493e0db75d64767af408f521 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 FORCE_COLOR=1 PYINSTALLER_STRICT_UNPACK_MODE=1 PYINSTALLER_STRICT_COLLECT_MODE=1 PYINSTALLER_STRICT_BUNDLE_CODESIGN_ERROR=1 PYINSTALLER_VERIFY_BUNDLE_SIGNATURE=1 PYTHONWARNDEFAULTENCODING=true GITHUB_ACTION_PATH=/home/github/70929241273/actions/actions-setup-python@v6 "${CURRENT_ENV[@]}" INPUT_PYTHON-VERSION=3.11 INPUT_CHECK-LATEST=true INPUT_TOKEN= INPUT_UPDATE-ENVIRONMENT=true INPUT_ALLOW-PRERELEASES=false INPUT_FREETHREADED=false \
bash -e /home/github/70929241273/steps/bugswarm_cmd.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=1 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=actions/setup-python GITHUB_ACTIONS=true GITHUB_ACTOR=rokm GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=termux-test GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/termux-test GITHUB_REF_NAME=termux-test GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=pyinstaller/pyinstaller GITHUB_REPOSITORY_OWNER=pyinstaller GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=208c3caedf9c6614493e0db75d64767af408f521 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 FORCE_COLOR=1 PYINSTALLER_STRICT_UNPACK_MODE=1 PYINSTALLER_STRICT_COLLECT_MODE=1 PYINSTALLER_STRICT_BUNDLE_CODESIGN_ERROR=1 PYINSTALLER_VERIFY_BUNDLE_SIGNATURE=1 PYTHONWARNDEFAULTENCODING=true GITHUB_ACTION_PATH=/home/github/70929241273/actions/actions-setup-python@v6 "${CURRENT_ENV[@]}" INPUT_PYTHON-VERSION=3.11 INPUT_CHECK-LATEST=true INPUT_TOKEN= INPUT_UPDATE-ENVIRONMENT=true INPUT_ALLOW-PRERELEASES=false INPUT_FREETHREADED=false \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=1 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=actions/setup-python GITHUB_ACTIONS=true GITHUB_ACTOR=rokm GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=termux-test GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/termux-test GITHUB_REF_NAME=termux-test GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=pyinstaller/pyinstaller GITHUB_REPOSITORY_OWNER=pyinstaller GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=208c3caedf9c6614493e0db75d64767af408f521 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 FORCE_COLOR=1 PYINSTALLER_STRICT_UNPACK_MODE=1 PYINSTALLER_STRICT_COLLECT_MODE=1 PYINSTALLER_STRICT_BUNDLE_CODESIGN_ERROR=1 PYINSTALLER_VERIFY_BUNDLE_SIGNATURE=1 PYTHONWARNDEFAULTENCODING=true GITHUB_ACTION_PATH=/home/github/70929241273/actions/actions-setup-python@v6 "${CURRENT_ENV[@]}" INPUT_PYTHON-VERSION=3.11 INPUT_CHECK-LATEST=true INPUT_TOKEN= INPUT_UPDATE-ENVIRONMENT=true INPUT_ALLOW-PRERELEASES=false INPUT_FREETHREADED=false \
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=2 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=rokm GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=termux-test GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/termux-test GITHUB_REF_NAME=termux-test GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=pyinstaller/pyinstaller GITHUB_REPOSITORY_OWNER=pyinstaller GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=208c3caedf9c6614493e0db75d64767af408f521 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 FORCE_COLOR=1 PYINSTALLER_STRICT_UNPACK_MODE=1 PYINSTALLER_STRICT_COLLECT_MODE=1 PYINSTALLER_STRICT_BUNDLE_CODESIGN_ERROR=1 PYINSTALLER_VERIFY_BUNDLE_SIGNATURE=1 PYTHONWARNDEFAULTENCODING=true "${CURRENT_ENV[@]}" \
echo "$(/home/github/70929241273/helpers/eval_expression p:'(' f:success p:'(' p:')' p:')' o:'&&' p:'(' f:startsWith p:'(' s:macos-14 s:ubuntu p:')' p:')')")
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=2 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=rokm GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=termux-test GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/termux-test GITHUB_REF_NAME=termux-test GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=pyinstaller/pyinstaller GITHUB_REPOSITORY_OWNER=pyinstaller GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=208c3caedf9c6614493e0db75d64767af408f521 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 FORCE_COLOR=1 PYINSTALLER_STRICT_UNPACK_MODE=1 PYINSTALLER_STRICT_COLLECT_MODE=1 PYINSTALLER_STRICT_BUNDLE_CODESIGN_ERROR=1 PYINSTALLER_VERIFY_BUNDLE_SIGNATURE=1 PYTHONWARNDEFAULTENCODING=true "${CURRENT_ENV[@]}" \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run 'sudo apt-get update -qq'
echo "##[endgroup]"
echo 'sudo apt-get update -qq
sudo apt-get upgrade -qq
sudo apt-get install -qq --no-install-recommends \
  libcmocka-dev \
  libxml2-dev libxslt1-dev gfortran libatlas-base-dev \
  libespeak1 libxcb-image0 libxcb-keysyms1 libxcb-render-util0 \
  libxkbcommon-x11-0 libxcb-icccm4 libxcb1 openssl \
  libxcb-randr0-dev libxcb-xtest0-dev libxcb-xinerama0-dev \
  libxcb-shape0-dev libxcb-xkb-dev libxcb-cursor0 xvfb \
  libopengl0 libegl1 \
  libpulse0 libpulse-mainloop-glib0 \
  gstreamer1.0-plugins-base libgstreamer-gl1.0-0 \
  libgirepository1.0-dev libgirepository-2.0-dev libcairo2-dev \
  gir1.2-girepository-2.0 gir1.2-girepository-3.0 gir1.2-gtk-3.0 \
  libfuse2
' > /home/github/70929241273/steps/bugswarm_2.sh
chmod u+x /home/github/70929241273/steps/bugswarm_2.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=2 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=rokm GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=termux-test GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/termux-test GITHUB_REF_NAME=termux-test GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=pyinstaller/pyinstaller GITHUB_REPOSITORY_OWNER=pyinstaller GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=208c3caedf9c6614493e0db75d64767af408f521 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 FORCE_COLOR=1 PYINSTALLER_STRICT_UNPACK_MODE=1 PYINSTALLER_STRICT_COLLECT_MODE=1 PYINSTALLER_STRICT_BUNDLE_CODESIGN_ERROR=1 PYINSTALLER_VERIFY_BUNDLE_SIGNATURE=1 PYTHONWARNDEFAULTENCODING=true "${CURRENT_ENV[@]}" \
bash -e /home/github/70929241273/steps/bugswarm_2.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=2 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=rokm GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=termux-test GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/termux-test GITHUB_REF_NAME=termux-test GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=pyinstaller/pyinstaller GITHUB_REPOSITORY_OWNER=pyinstaller GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=208c3caedf9c6614493e0db75d64767af408f521 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 FORCE_COLOR=1 PYINSTALLER_STRICT_UNPACK_MODE=1 PYINSTALLER_STRICT_COLLECT_MODE=1 PYINSTALLER_STRICT_BUNDLE_CODESIGN_ERROR=1 PYINSTALLER_VERIFY_BUNDLE_SIGNATURE=1 PYTHONWARNDEFAULTENCODING=true "${CURRENT_ENV[@]}" \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=2 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=rokm GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=termux-test GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/termux-test GITHUB_REF_NAME=termux-test GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=pyinstaller/pyinstaller GITHUB_REPOSITORY_OWNER=pyinstaller GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=208c3caedf9c6614493e0db75d64767af408f521 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 FORCE_COLOR=1 PYINSTALLER_STRICT_UNPACK_MODE=1 PYINSTALLER_STRICT_COLLECT_MODE=1 PYINSTALLER_STRICT_BUNDLE_CODESIGN_ERROR=1 PYINSTALLER_VERIFY_BUNDLE_SIGNATURE=1 PYTHONWARNDEFAULTENCODING=true "${CURRENT_ENV[@]}" \
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=3 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=rokm GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=termux-test GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/termux-test GITHUB_REF_NAME=termux-test GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=pyinstaller/pyinstaller GITHUB_REPOSITORY_OWNER=pyinstaller GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=208c3caedf9c6614493e0db75d64767af408f521 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 FORCE_COLOR=1 PYINSTALLER_STRICT_UNPACK_MODE=1 PYINSTALLER_STRICT_COLLECT_MODE=1 PYINSTALLER_STRICT_BUNDLE_CODESIGN_ERROR=1 PYINSTALLER_VERIFY_BUNDLE_SIGNATURE=1 PYTHONWARNDEFAULTENCODING=true "${CURRENT_ENV[@]}" \
echo "$(/home/github/70929241273/helpers/eval_expression p:'(' f:success p:'(' p:')' p:')' o:'&&' p:'(' f:startsWith p:'(' s:macos-14 s:ubuntu p:')' p:')')")
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=3 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=rokm GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=termux-test GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/termux-test GITHUB_REF_NAME=termux-test GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=pyinstaller/pyinstaller GITHUB_REPOSITORY_OWNER=pyinstaller GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=208c3caedf9c6614493e0db75d64767af408f521 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 FORCE_COLOR=1 PYINSTALLER_STRICT_UNPACK_MODE=1 PYINSTALLER_STRICT_COLLECT_MODE=1 PYINSTALLER_STRICT_BUNDLE_CODESIGN_ERROR=1 PYINSTALLER_VERIFY_BUNDLE_SIGNATURE=1 PYTHONWARNDEFAULTENCODING=true "${CURRENT_ENV[@]}" \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run 'sudo apt-get update -qq'
echo "##[endgroup]"
echo 'sudo apt-get update -qq
sudo apt-get install -qq --no-install-recommends locales
sudo locale-gen \
  en_US.UTF-8 \
  en_US \
  sl_SI.UTF-8 \
  sl_SI \
  cs_CZ.UTF-8
locale -a
' > /home/github/70929241273/steps/bugswarm_3.sh
chmod u+x /home/github/70929241273/steps/bugswarm_3.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=3 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=rokm GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=termux-test GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/termux-test GITHUB_REF_NAME=termux-test GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=pyinstaller/pyinstaller GITHUB_REPOSITORY_OWNER=pyinstaller GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=208c3caedf9c6614493e0db75d64767af408f521 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 FORCE_COLOR=1 PYINSTALLER_STRICT_UNPACK_MODE=1 PYINSTALLER_STRICT_COLLECT_MODE=1 PYINSTALLER_STRICT_BUNDLE_CODESIGN_ERROR=1 PYINSTALLER_VERIFY_BUNDLE_SIGNATURE=1 PYTHONWARNDEFAULTENCODING=true "${CURRENT_ENV[@]}" \
bash -e /home/github/70929241273/steps/bugswarm_3.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=3 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=rokm GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=termux-test GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/termux-test GITHUB_REF_NAME=termux-test GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=pyinstaller/pyinstaller GITHUB_REPOSITORY_OWNER=pyinstaller GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=208c3caedf9c6614493e0db75d64767af408f521 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 FORCE_COLOR=1 PYINSTALLER_STRICT_UNPACK_MODE=1 PYINSTALLER_STRICT_COLLECT_MODE=1 PYINSTALLER_STRICT_BUNDLE_CODESIGN_ERROR=1 PYINSTALLER_VERIFY_BUNDLE_SIGNATURE=1 PYTHONWARNDEFAULTENCODING=true "${CURRENT_ENV[@]}" \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=3 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=rokm GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=termux-test GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/termux-test GITHUB_REF_NAME=termux-test GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=pyinstaller/pyinstaller GITHUB_REPOSITORY_OWNER=pyinstaller GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=208c3caedf9c6614493e0db75d64767af408f521 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 FORCE_COLOR=1 PYINSTALLER_STRICT_UNPACK_MODE=1 PYINSTALLER_STRICT_COLLECT_MODE=1 PYINSTALLER_STRICT_BUNDLE_CODESIGN_ERROR=1 PYINSTALLER_VERIFY_BUNDLE_SIGNATURE=1 PYTHONWARNDEFAULTENCODING=true "${CURRENT_ENV[@]}" \
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=4 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=rokm GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=termux-test GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/termux-test GITHUB_REF_NAME=termux-test GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=pyinstaller/pyinstaller GITHUB_REPOSITORY_OWNER=pyinstaller GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=208c3caedf9c6614493e0db75d64767af408f521 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 FORCE_COLOR=1 PYINSTALLER_STRICT_UNPACK_MODE=1 PYINSTALLER_STRICT_COLLECT_MODE=1 PYINSTALLER_STRICT_BUNDLE_CODESIGN_ERROR=1 PYINSTALLER_VERIFY_BUNDLE_SIGNATURE=1 PYTHONWARNDEFAULTENCODING=true "${CURRENT_ENV[@]}" \
echo "$(/home/github/70929241273/helpers/eval_expression p:'(' f:success p:'(' p:')' p:')' o:'&&' p:'(' f:startsWith p:'(' s:macos-14 s:ubuntu p:')' p:')')")
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=4 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=rokm GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=termux-test GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/termux-test GITHUB_REF_NAME=termux-test GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=pyinstaller/pyinstaller GITHUB_REPOSITORY_OWNER=pyinstaller GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=208c3caedf9c6614493e0db75d64767af408f521 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 FORCE_COLOR=1 PYINSTALLER_STRICT_UNPACK_MODE=1 PYINSTALLER_STRICT_COLLECT_MODE=1 PYINSTALLER_STRICT_BUNDLE_CODESIGN_ERROR=1 PYINSTALLER_VERIFY_BUNDLE_SIGNATURE=1 PYTHONWARNDEFAULTENCODING=true "${CURRENT_ENV[@]}" \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run 'wget \'
echo "##[endgroup]"
echo 'wget \
  https://github.com/AppImage/AppImageKit/releases/download/12/appimagetool-x86_64.AppImage \
  -O $HOME/appimagetool-x86_64.AppImage
chmod a+x $HOME/appimagetool-x86_64.AppImage
' > /home/github/70929241273/steps/bugswarm_4.sh
chmod u+x /home/github/70929241273/steps/bugswarm_4.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=4 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=rokm GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=termux-test GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/termux-test GITHUB_REF_NAME=termux-test GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=pyinstaller/pyinstaller GITHUB_REPOSITORY_OWNER=pyinstaller GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=208c3caedf9c6614493e0db75d64767af408f521 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 FORCE_COLOR=1 PYINSTALLER_STRICT_UNPACK_MODE=1 PYINSTALLER_STRICT_COLLECT_MODE=1 PYINSTALLER_STRICT_BUNDLE_CODESIGN_ERROR=1 PYINSTALLER_VERIFY_BUNDLE_SIGNATURE=1 PYTHONWARNDEFAULTENCODING=true "${CURRENT_ENV[@]}" \
bash -e /home/github/70929241273/steps/bugswarm_4.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=4 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=rokm GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=termux-test GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/termux-test GITHUB_REF_NAME=termux-test GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=pyinstaller/pyinstaller GITHUB_REPOSITORY_OWNER=pyinstaller GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=208c3caedf9c6614493e0db75d64767af408f521 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 FORCE_COLOR=1 PYINSTALLER_STRICT_UNPACK_MODE=1 PYINSTALLER_STRICT_COLLECT_MODE=1 PYINSTALLER_STRICT_BUNDLE_CODESIGN_ERROR=1 PYINSTALLER_VERIFY_BUNDLE_SIGNATURE=1 PYTHONWARNDEFAULTENCODING=true "${CURRENT_ENV[@]}" \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=4 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=rokm GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=termux-test GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/termux-test GITHUB_REF_NAME=termux-test GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=pyinstaller/pyinstaller GITHUB_REPOSITORY_OWNER=pyinstaller GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=208c3caedf9c6614493e0db75d64767af408f521 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 FORCE_COLOR=1 PYINSTALLER_STRICT_UNPACK_MODE=1 PYINSTALLER_STRICT_COLLECT_MODE=1 PYINSTALLER_STRICT_BUNDLE_CODESIGN_ERROR=1 PYINSTALLER_VERIFY_BUNDLE_SIGNATURE=1 PYTHONWARNDEFAULTENCODING=true "${CURRENT_ENV[@]}" \
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=5 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=rokm GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=termux-test GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/termux-test GITHUB_REF_NAME=termux-test GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=pyinstaller/pyinstaller GITHUB_REPOSITORY_OWNER=pyinstaller GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=208c3caedf9c6614493e0db75d64767af408f521 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 FORCE_COLOR=1 PYINSTALLER_STRICT_UNPACK_MODE=1 PYINSTALLER_STRICT_COLLECT_MODE=1 PYINSTALLER_STRICT_BUNDLE_CODESIGN_ERROR=1 PYINSTALLER_VERIFY_BUNDLE_SIGNATURE=1 PYTHONWARNDEFAULTENCODING=true "${CURRENT_ENV[@]}" \
echo $(test "$_GITHUB_JOB_STATUS" = "success" && echo true || echo false))
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=5 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=rokm GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=termux-test GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/termux-test GITHUB_REF_NAME=termux-test GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=pyinstaller/pyinstaller GITHUB_REPOSITORY_OWNER=pyinstaller GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=208c3caedf9c6614493e0db75d64767af408f521 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 FORCE_COLOR=1 PYINSTALLER_STRICT_UNPACK_MODE=1 PYINSTALLER_STRICT_COLLECT_MODE=1 PYINSTALLER_STRICT_BUNDLE_CODESIGN_ERROR=1 PYINSTALLER_VERIFY_BUNDLE_SIGNATURE=1 PYTHONWARNDEFAULTENCODING=true "${CURRENT_ENV[@]}" \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run 'echo "pip_cache_dir=$(pip cache dir)" >> $GITHUB_ENV'
echo "##[endgroup]"
echo 'echo "pip_cache_dir=$(pip cache dir)" >> $GITHUB_ENV' > /home/github/70929241273/steps/bugswarm_5.sh
chmod u+x /home/github/70929241273/steps/bugswarm_5.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=5 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=rokm GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=termux-test GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/termux-test GITHUB_REF_NAME=termux-test GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=pyinstaller/pyinstaller GITHUB_REPOSITORY_OWNER=pyinstaller GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=208c3caedf9c6614493e0db75d64767af408f521 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 FORCE_COLOR=1 PYINSTALLER_STRICT_UNPACK_MODE=1 PYINSTALLER_STRICT_COLLECT_MODE=1 PYINSTALLER_STRICT_BUNDLE_CODESIGN_ERROR=1 PYINSTALLER_VERIFY_BUNDLE_SIGNATURE=1 PYTHONWARNDEFAULTENCODING=true "${CURRENT_ENV[@]}" \
bash --noprofile --norc -eo pipefail /home/github/70929241273/steps/bugswarm_5.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=5 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=rokm GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=termux-test GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/termux-test GITHUB_REF_NAME=termux-test GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=pyinstaller/pyinstaller GITHUB_REPOSITORY_OWNER=pyinstaller GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=208c3caedf9c6614493e0db75d64767af408f521 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 FORCE_COLOR=1 PYINSTALLER_STRICT_UNPACK_MODE=1 PYINSTALLER_STRICT_COLLECT_MODE=1 PYINSTALLER_STRICT_BUNDLE_CODESIGN_ERROR=1 PYINSTALLER_VERIFY_BUNDLE_SIGNATURE=1 PYTHONWARNDEFAULTENCODING=true "${CURRENT_ENV[@]}" \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=5 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=rokm GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=termux-test GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/termux-test GITHUB_REF_NAME=termux-test GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=pyinstaller/pyinstaller GITHUB_REPOSITORY_OWNER=pyinstaller GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=208c3caedf9c6614493e0db75d64767af408f521 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 FORCE_COLOR=1 PYINSTALLER_STRICT_UNPACK_MODE=1 PYINSTALLER_STRICT_COLLECT_MODE=1 PYINSTALLER_STRICT_BUNDLE_CODESIGN_ERROR=1 PYINSTALLER_VERIFY_BUNDLE_SIGNATURE=1 PYTHONWARNDEFAULTENCODING=true "${CURRENT_ENV[@]}" \
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=7 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=rokm GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=termux-test GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/termux-test GITHUB_REF_NAME=termux-test GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=pyinstaller/pyinstaller GITHUB_REPOSITORY_OWNER=pyinstaller GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=208c3caedf9c6614493e0db75d64767af408f521 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 FORCE_COLOR=1 PYINSTALLER_STRICT_UNPACK_MODE=1 PYINSTALLER_STRICT_COLLECT_MODE=1 PYINSTALLER_STRICT_BUNDLE_CODESIGN_ERROR=1 PYINSTALLER_VERIFY_BUNDLE_SIGNATURE=1 PYTHONWARNDEFAULTENCODING=true "${CURRENT_ENV[@]}" \
echo "$(/home/github/70929241273/helpers/eval_expression p:'(' f:success p:'(' p:')' p:')' o:'&&' p:'(' f:startsWith p:'(' s:macos-14 s:ubuntu p:')' p:')')")
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=7 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=rokm GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=termux-test GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/termux-test GITHUB_REF_NAME=termux-test GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=pyinstaller/pyinstaller GITHUB_REPOSITORY_OWNER=pyinstaller GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=208c3caedf9c6614493e0db75d64767af408f521 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 FORCE_COLOR=1 PYINSTALLER_STRICT_UNPACK_MODE=1 PYINSTALLER_STRICT_COLLECT_MODE=1 PYINSTALLER_STRICT_BUNDLE_CODESIGN_ERROR=1 PYINSTALLER_VERIFY_BUNDLE_SIGNATURE=1 PYTHONWARNDEFAULTENCODING=true "${CURRENT_ENV[@]}" \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run '# Compile bootloader'
echo "##[endgroup]"
echo '# Compile bootloader
cd bootloader
CC="gcc -std=gnu90" python waf --tests all
' > /home/github/70929241273/steps/bugswarm_7.sh
chmod u+x /home/github/70929241273/steps/bugswarm_7.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=7 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=rokm GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=termux-test GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/termux-test GITHUB_REF_NAME=termux-test GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=pyinstaller/pyinstaller GITHUB_REPOSITORY_OWNER=pyinstaller GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=208c3caedf9c6614493e0db75d64767af408f521 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 FORCE_COLOR=1 PYINSTALLER_STRICT_UNPACK_MODE=1 PYINSTALLER_STRICT_COLLECT_MODE=1 PYINSTALLER_STRICT_BUNDLE_CODESIGN_ERROR=1 PYINSTALLER_VERIFY_BUNDLE_SIGNATURE=1 PYTHONWARNDEFAULTENCODING=true "${CURRENT_ENV[@]}" \
bash -e /home/github/70929241273/steps/bugswarm_7.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=7 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=rokm GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=termux-test GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/termux-test GITHUB_REF_NAME=termux-test GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=pyinstaller/pyinstaller GITHUB_REPOSITORY_OWNER=pyinstaller GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=208c3caedf9c6614493e0db75d64767af408f521 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 FORCE_COLOR=1 PYINSTALLER_STRICT_UNPACK_MODE=1 PYINSTALLER_STRICT_COLLECT_MODE=1 PYINSTALLER_STRICT_BUNDLE_CODESIGN_ERROR=1 PYINSTALLER_VERIFY_BUNDLE_SIGNATURE=1 PYTHONWARNDEFAULTENCODING=true "${CURRENT_ENV[@]}" \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=7 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=rokm GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=termux-test GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/termux-test GITHUB_REF_NAME=termux-test GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=pyinstaller/pyinstaller GITHUB_REPOSITORY_OWNER=pyinstaller GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=208c3caedf9c6614493e0db75d64767af408f521 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 FORCE_COLOR=1 PYINSTALLER_STRICT_UNPACK_MODE=1 PYINSTALLER_STRICT_COLLECT_MODE=1 PYINSTALLER_STRICT_BUNDLE_CODESIGN_ERROR=1 PYINSTALLER_VERIFY_BUNDLE_SIGNATURE=1 PYTHONWARNDEFAULTENCODING=true "${CURRENT_ENV[@]}" \
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=8 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=rokm GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=termux-test GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/termux-test GITHUB_REF_NAME=termux-test GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=pyinstaller/pyinstaller GITHUB_REPOSITORY_OWNER=pyinstaller GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=208c3caedf9c6614493e0db75d64767af408f521 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 FORCE_COLOR=1 PYINSTALLER_STRICT_UNPACK_MODE=1 PYINSTALLER_STRICT_COLLECT_MODE=1 PYINSTALLER_STRICT_BUNDLE_CODESIGN_ERROR=1 PYINSTALLER_VERIFY_BUNDLE_SIGNATURE=1 PYTHONWARNDEFAULTENCODING=true "${CURRENT_ENV[@]}" \
echo "$(/home/github/70929241273/helpers/eval_expression p:'(' f:success p:'(' p:')' p:')' o:'&&' p:'(' f:startsWith p:'(' s:macos-14 s:ubuntu p:')' p:')')")
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=8 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=rokm GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=termux-test GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/termux-test GITHUB_REF_NAME=termux-test GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=pyinstaller/pyinstaller GITHUB_REPOSITORY_OWNER=pyinstaller GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=208c3caedf9c6614493e0db75d64767af408f521 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 FORCE_COLOR=1 PYINSTALLER_STRICT_UNPACK_MODE=1 PYINSTALLER_STRICT_COLLECT_MODE=1 PYINSTALLER_STRICT_BUNDLE_CODESIGN_ERROR=1 PYINSTALLER_VERIFY_BUNDLE_SIGNATURE=1 PYTHONWARNDEFAULTENCODING=true "${CURRENT_ENV[@]}" \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run '# Compile bootloader'
echo "##[endgroup]"
echo '# Compile bootloader
cd bootloader
CC="gcc -std=c99 -pedantic" python waf --tests all
' > /home/github/70929241273/steps/bugswarm_8.sh
chmod u+x /home/github/70929241273/steps/bugswarm_8.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=8 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=rokm GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=termux-test GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/termux-test GITHUB_REF_NAME=termux-test GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=pyinstaller/pyinstaller GITHUB_REPOSITORY_OWNER=pyinstaller GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=208c3caedf9c6614493e0db75d64767af408f521 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 FORCE_COLOR=1 PYINSTALLER_STRICT_UNPACK_MODE=1 PYINSTALLER_STRICT_COLLECT_MODE=1 PYINSTALLER_STRICT_BUNDLE_CODESIGN_ERROR=1 PYINSTALLER_VERIFY_BUNDLE_SIGNATURE=1 PYTHONWARNDEFAULTENCODING=true "${CURRENT_ENV[@]}" \
bash -e /home/github/70929241273/steps/bugswarm_8.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=8 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=rokm GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=termux-test GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/termux-test GITHUB_REF_NAME=termux-test GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=pyinstaller/pyinstaller GITHUB_REPOSITORY_OWNER=pyinstaller GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=208c3caedf9c6614493e0db75d64767af408f521 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 FORCE_COLOR=1 PYINSTALLER_STRICT_UNPACK_MODE=1 PYINSTALLER_STRICT_COLLECT_MODE=1 PYINSTALLER_STRICT_BUNDLE_CODESIGN_ERROR=1 PYINSTALLER_VERIFY_BUNDLE_SIGNATURE=1 PYTHONWARNDEFAULTENCODING=true "${CURRENT_ENV[@]}" \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=8 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=rokm GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=termux-test GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/termux-test GITHUB_REF_NAME=termux-test GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=pyinstaller/pyinstaller GITHUB_REPOSITORY_OWNER=pyinstaller GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=208c3caedf9c6614493e0db75d64767af408f521 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 FORCE_COLOR=1 PYINSTALLER_STRICT_UNPACK_MODE=1 PYINSTALLER_STRICT_COLLECT_MODE=1 PYINSTALLER_STRICT_BUNDLE_CODESIGN_ERROR=1 PYINSTALLER_VERIFY_BUNDLE_SIGNATURE=1 PYTHONWARNDEFAULTENCODING=true "${CURRENT_ENV[@]}" \
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=9 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=rokm GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=termux-test GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/termux-test GITHUB_REF_NAME=termux-test GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=pyinstaller/pyinstaller GITHUB_REPOSITORY_OWNER=pyinstaller GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=208c3caedf9c6614493e0db75d64767af408f521 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 FORCE_COLOR=1 PYINSTALLER_STRICT_UNPACK_MODE=1 PYINSTALLER_STRICT_COLLECT_MODE=1 PYINSTALLER_STRICT_BUNDLE_CODESIGN_ERROR=1 PYINSTALLER_VERIFY_BUNDLE_SIGNATURE=1 PYTHONWARNDEFAULTENCODING=true "${CURRENT_ENV[@]}" \
echo "$(/home/github/70929241273/helpers/eval_expression p:'(' f:success p:'(' p:')' p:')' o:'&&' p:'(' f:startsWith p:'(' s:macos-14 s:ubuntu p:')' p:')')")
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=9 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=rokm GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=termux-test GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/termux-test GITHUB_REF_NAME=termux-test GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=pyinstaller/pyinstaller GITHUB_REPOSITORY_OWNER=pyinstaller GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=208c3caedf9c6614493e0db75d64767af408f521 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 FORCE_COLOR=1 PYINSTALLER_STRICT_UNPACK_MODE=1 PYINSTALLER_STRICT_COLLECT_MODE=1 PYINSTALLER_STRICT_BUNDLE_CODESIGN_ERROR=1 PYINSTALLER_VERIFY_BUNDLE_SIGNATURE=1 PYTHONWARNDEFAULTENCODING=true "${CURRENT_ENV[@]}" \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run 'cd bootloader && python waf --static-zlib --tests all'
echo "##[endgroup]"
echo 'cd bootloader && python waf --static-zlib --tests all' > /home/github/70929241273/steps/bugswarm_9.sh
chmod u+x /home/github/70929241273/steps/bugswarm_9.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=9 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=rokm GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=termux-test GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/termux-test GITHUB_REF_NAME=termux-test GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=pyinstaller/pyinstaller GITHUB_REPOSITORY_OWNER=pyinstaller GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=208c3caedf9c6614493e0db75d64767af408f521 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 FORCE_COLOR=1 PYINSTALLER_STRICT_UNPACK_MODE=1 PYINSTALLER_STRICT_COLLECT_MODE=1 PYINSTALLER_STRICT_BUNDLE_CODESIGN_ERROR=1 PYINSTALLER_VERIFY_BUNDLE_SIGNATURE=1 PYTHONWARNDEFAULTENCODING=true "${CURRENT_ENV[@]}" \
bash -e /home/github/70929241273/steps/bugswarm_9.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=9 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=rokm GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=termux-test GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/termux-test GITHUB_REF_NAME=termux-test GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=pyinstaller/pyinstaller GITHUB_REPOSITORY_OWNER=pyinstaller GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=208c3caedf9c6614493e0db75d64767af408f521 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 FORCE_COLOR=1 PYINSTALLER_STRICT_UNPACK_MODE=1 PYINSTALLER_STRICT_COLLECT_MODE=1 PYINSTALLER_STRICT_BUNDLE_CODESIGN_ERROR=1 PYINSTALLER_VERIFY_BUNDLE_SIGNATURE=1 PYTHONWARNDEFAULTENCODING=true "${CURRENT_ENV[@]}" \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=9 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=rokm GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=termux-test GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/termux-test GITHUB_REF_NAME=termux-test GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=pyinstaller/pyinstaller GITHUB_REPOSITORY_OWNER=pyinstaller GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=208c3caedf9c6614493e0db75d64767af408f521 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 FORCE_COLOR=1 PYINSTALLER_STRICT_UNPACK_MODE=1 PYINSTALLER_STRICT_COLLECT_MODE=1 PYINSTALLER_STRICT_BUNDLE_CODESIGN_ERROR=1 PYINSTALLER_VERIFY_BUNDLE_SIGNATURE=1 PYTHONWARNDEFAULTENCODING=true "${CURRENT_ENV[@]}" \
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=10 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=rokm GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=termux-test GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/termux-test GITHUB_REF_NAME=termux-test GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=pyinstaller/pyinstaller GITHUB_REPOSITORY_OWNER=pyinstaller GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=208c3caedf9c6614493e0db75d64767af408f521 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 FORCE_COLOR=1 PYINSTALLER_STRICT_UNPACK_MODE=1 PYINSTALLER_STRICT_COLLECT_MODE=1 PYINSTALLER_STRICT_BUNDLE_CODESIGN_ERROR=1 PYINSTALLER_VERIFY_BUNDLE_SIGNATURE=1 PYTHONWARNDEFAULTENCODING=true "${CURRENT_ENV[@]}" \
echo "$(/home/github/70929241273/helpers/eval_expression p:'(' f:success p:'(' p:')' p:')' o:'&&' p:'(' f:startsWith p:'(' s:macos-14 s:windows p:')' p:')')")
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=10 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=rokm GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=termux-test GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/termux-test GITHUB_REF_NAME=termux-test GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=pyinstaller/pyinstaller GITHUB_REPOSITORY_OWNER=pyinstaller GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=208c3caedf9c6614493e0db75d64767af408f521 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 FORCE_COLOR=1 PYINSTALLER_STRICT_UNPACK_MODE=1 PYINSTALLER_STRICT_COLLECT_MODE=1 PYINSTALLER_STRICT_BUNDLE_CODESIGN_ERROR=1 PYINSTALLER_VERIFY_BUNDLE_SIGNATURE=1 PYTHONWARNDEFAULTENCODING=true "${CURRENT_ENV[@]}" \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run 'cd bootloader'
echo "##[endgroup]"
echo 'cd bootloader
python waf --tests --target-arch=64bit-arm all
ls ../PyInstaller/bootloader/Windows-64bit-arm
' > /home/github/70929241273/steps/bugswarm_10.sh
chmod u+x /home/github/70929241273/steps/bugswarm_10.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=10 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=rokm GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=termux-test GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/termux-test GITHUB_REF_NAME=termux-test GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=pyinstaller/pyinstaller GITHUB_REPOSITORY_OWNER=pyinstaller GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=208c3caedf9c6614493e0db75d64767af408f521 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 FORCE_COLOR=1 PYINSTALLER_STRICT_UNPACK_MODE=1 PYINSTALLER_STRICT_COLLECT_MODE=1 PYINSTALLER_STRICT_BUNDLE_CODESIGN_ERROR=1 PYINSTALLER_VERIFY_BUNDLE_SIGNATURE=1 PYTHONWARNDEFAULTENCODING=true "${CURRENT_ENV[@]}" \
bash -e /home/github/70929241273/steps/bugswarm_10.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=10 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=rokm GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=termux-test GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/termux-test GITHUB_REF_NAME=termux-test GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=pyinstaller/pyinstaller GITHUB_REPOSITORY_OWNER=pyinstaller GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=208c3caedf9c6614493e0db75d64767af408f521 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 FORCE_COLOR=1 PYINSTALLER_STRICT_UNPACK_MODE=1 PYINSTALLER_STRICT_COLLECT_MODE=1 PYINSTALLER_STRICT_BUNDLE_CODESIGN_ERROR=1 PYINSTALLER_VERIFY_BUNDLE_SIGNATURE=1 PYTHONWARNDEFAULTENCODING=true "${CURRENT_ENV[@]}" \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=10 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=rokm GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=termux-test GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/termux-test GITHUB_REF_NAME=termux-test GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=pyinstaller/pyinstaller GITHUB_REPOSITORY_OWNER=pyinstaller GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=208c3caedf9c6614493e0db75d64767af408f521 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 FORCE_COLOR=1 PYINSTALLER_STRICT_UNPACK_MODE=1 PYINSTALLER_STRICT_COLLECT_MODE=1 PYINSTALLER_STRICT_BUNDLE_CODESIGN_ERROR=1 PYINSTALLER_VERIFY_BUNDLE_SIGNATURE=1 PYTHONWARNDEFAULTENCODING=true "${CURRENT_ENV[@]}" \
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=11 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=rokm GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=termux-test GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/termux-test GITHUB_REF_NAME=termux-test GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=pyinstaller/pyinstaller GITHUB_REPOSITORY_OWNER=pyinstaller GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=208c3caedf9c6614493e0db75d64767af408f521 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 FORCE_COLOR=1 PYINSTALLER_STRICT_UNPACK_MODE=1 PYINSTALLER_STRICT_COLLECT_MODE=1 PYINSTALLER_STRICT_BUNDLE_CODESIGN_ERROR=1 PYINSTALLER_VERIFY_BUNDLE_SIGNATURE=1 PYTHONWARNDEFAULTENCODING=true "${CURRENT_ENV[@]}" \
echo $(test "$_GITHUB_JOB_STATUS" = "success" && echo true || echo false))
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=11 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=rokm GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=termux-test GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/termux-test GITHUB_REF_NAME=termux-test GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=pyinstaller/pyinstaller GITHUB_REPOSITORY_OWNER=pyinstaller GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=208c3caedf9c6614493e0db75d64767af408f521 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 FORCE_COLOR=1 PYINSTALLER_STRICT_UNPACK_MODE=1 PYINSTALLER_STRICT_COLLECT_MODE=1 PYINSTALLER_STRICT_BUNDLE_CODESIGN_ERROR=1 PYINSTALLER_VERIFY_BUNDLE_SIGNATURE=1 PYTHONWARNDEFAULTENCODING=true "${CURRENT_ENV[@]}" \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run 'python -m pip install --upgrade pip hatchling'
echo "##[endgroup]"
echo 'python -m pip install --upgrade pip hatchling' > /home/github/70929241273/steps/bugswarm_11.sh
chmod u+x /home/github/70929241273/steps/bugswarm_11.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=11 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=rokm GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=termux-test GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/termux-test GITHUB_REF_NAME=termux-test GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=pyinstaller/pyinstaller GITHUB_REPOSITORY_OWNER=pyinstaller GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=208c3caedf9c6614493e0db75d64767af408f521 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 FORCE_COLOR=1 PYINSTALLER_STRICT_UNPACK_MODE=1 PYINSTALLER_STRICT_COLLECT_MODE=1 PYINSTALLER_STRICT_BUNDLE_CODESIGN_ERROR=1 PYINSTALLER_VERIFY_BUNDLE_SIGNATURE=1 PYTHONWARNDEFAULTENCODING=true "${CURRENT_ENV[@]}" \
bash -e /home/github/70929241273/steps/bugswarm_11.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=11 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=rokm GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=termux-test GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/termux-test GITHUB_REF_NAME=termux-test GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=pyinstaller/pyinstaller GITHUB_REPOSITORY_OWNER=pyinstaller GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=208c3caedf9c6614493e0db75d64767af408f521 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 FORCE_COLOR=1 PYINSTALLER_STRICT_UNPACK_MODE=1 PYINSTALLER_STRICT_COLLECT_MODE=1 PYINSTALLER_STRICT_BUNDLE_CODESIGN_ERROR=1 PYINSTALLER_VERIFY_BUNDLE_SIGNATURE=1 PYTHONWARNDEFAULTENCODING=true "${CURRENT_ENV[@]}" \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=11 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=rokm GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=termux-test GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/termux-test GITHUB_REF_NAME=termux-test GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=pyinstaller/pyinstaller GITHUB_REPOSITORY_OWNER=pyinstaller GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=208c3caedf9c6614493e0db75d64767af408f521 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 FORCE_COLOR=1 PYINSTALLER_STRICT_UNPACK_MODE=1 PYINSTALLER_STRICT_COLLECT_MODE=1 PYINSTALLER_STRICT_BUNDLE_CODESIGN_ERROR=1 PYINSTALLER_VERIFY_BUNDLE_SIGNATURE=1 PYTHONWARNDEFAULTENCODING=true "${CURRENT_ENV[@]}" \
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=12 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=rokm GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=termux-test GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/termux-test GITHUB_REF_NAME=termux-test GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=pyinstaller/pyinstaller GITHUB_REPOSITORY_OWNER=pyinstaller GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=208c3caedf9c6614493e0db75d64767af408f521 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 FORCE_COLOR=1 PYINSTALLER_STRICT_UNPACK_MODE=1 PYINSTALLER_STRICT_COLLECT_MODE=1 PYINSTALLER_STRICT_BUNDLE_CODESIGN_ERROR=1 PYINSTALLER_VERIFY_BUNDLE_SIGNATURE=1 PYTHONWARNDEFAULTENCODING=true "${CURRENT_ENV[@]}" \
echo $(test "$_GITHUB_JOB_STATUS" = "success" && echo true || echo false))
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=12 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=rokm GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=termux-test GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/termux-test GITHUB_REF_NAME=termux-test GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=pyinstaller/pyinstaller GITHUB_REPOSITORY_OWNER=pyinstaller GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=208c3caedf9c6614493e0db75d64767af408f521 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 FORCE_COLOR=1 PYINSTALLER_STRICT_UNPACK_MODE=1 PYINSTALLER_STRICT_COLLECT_MODE=1 PYINSTALLER_STRICT_BUNDLE_CODESIGN_ERROR=1 PYINSTALLER_VERIFY_BUNDLE_SIGNATURE=1 PYTHONWARNDEFAULTENCODING=true "${CURRENT_ENV[@]}" \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run 'cd bootloader && python waf --tests all'
echo "##[endgroup]"
echo 'cd bootloader && python waf --tests all' > /home/github/70929241273/steps/bugswarm_12.sh
chmod u+x /home/github/70929241273/steps/bugswarm_12.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=12 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=rokm GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=termux-test GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/termux-test GITHUB_REF_NAME=termux-test GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=pyinstaller/pyinstaller GITHUB_REPOSITORY_OWNER=pyinstaller GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=208c3caedf9c6614493e0db75d64767af408f521 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 FORCE_COLOR=1 PYINSTALLER_STRICT_UNPACK_MODE=1 PYINSTALLER_STRICT_COLLECT_MODE=1 PYINSTALLER_STRICT_BUNDLE_CODESIGN_ERROR=1 PYINSTALLER_VERIFY_BUNDLE_SIGNATURE=1 PYTHONWARNDEFAULTENCODING=true "${CURRENT_ENV[@]}" \
bash -e /home/github/70929241273/steps/bugswarm_12.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=12 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=rokm GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=termux-test GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/termux-test GITHUB_REF_NAME=termux-test GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=pyinstaller/pyinstaller GITHUB_REPOSITORY_OWNER=pyinstaller GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=208c3caedf9c6614493e0db75d64767af408f521 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 FORCE_COLOR=1 PYINSTALLER_STRICT_UNPACK_MODE=1 PYINSTALLER_STRICT_COLLECT_MODE=1 PYINSTALLER_STRICT_BUNDLE_CODESIGN_ERROR=1 PYINSTALLER_VERIFY_BUNDLE_SIGNATURE=1 PYTHONWARNDEFAULTENCODING=true "${CURRENT_ENV[@]}" \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=12 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=rokm GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=termux-test GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/termux-test GITHUB_REF_NAME=termux-test GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=pyinstaller/pyinstaller GITHUB_REPOSITORY_OWNER=pyinstaller GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=208c3caedf9c6614493e0db75d64767af408f521 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 FORCE_COLOR=1 PYINSTALLER_STRICT_UNPACK_MODE=1 PYINSTALLER_STRICT_COLLECT_MODE=1 PYINSTALLER_STRICT_BUNDLE_CODESIGN_ERROR=1 PYINSTALLER_VERIFY_BUNDLE_SIGNATURE=1 PYTHONWARNDEFAULTENCODING=true "${CURRENT_ENV[@]}" \
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=13 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=rokm GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=termux-test GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/termux-test GITHUB_REF_NAME=termux-test GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=pyinstaller/pyinstaller GITHUB_REPOSITORY_OWNER=pyinstaller GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=208c3caedf9c6614493e0db75d64767af408f521 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 FORCE_COLOR=1 PYINSTALLER_STRICT_UNPACK_MODE=1 PYINSTALLER_STRICT_COLLECT_MODE=1 PYINSTALLER_STRICT_BUNDLE_CODESIGN_ERROR=1 PYINSTALLER_VERIFY_BUNDLE_SIGNATURE=1 PYTHONWARNDEFAULTENCODING=true "${CURRENT_ENV[@]}" \
echo $(test "$_GITHUB_JOB_STATUS" = "success" && echo true || echo false))
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=13 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=rokm GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=termux-test GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/termux-test GITHUB_REF_NAME=termux-test GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=pyinstaller/pyinstaller GITHUB_REPOSITORY_OWNER=pyinstaller GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=208c3caedf9c6614493e0db75d64767af408f521 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 FORCE_COLOR=1 PYINSTALLER_STRICT_UNPACK_MODE=1 PYINSTALLER_STRICT_COLLECT_MODE=1 PYINSTALLER_STRICT_BUNDLE_CODESIGN_ERROR=1 PYINSTALLER_VERIFY_BUNDLE_SIGNATURE=1 PYTHONWARNDEFAULTENCODING=true "${CURRENT_ENV[@]}" \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run 'python -m pip download --dest=dist .[completion] && rm -f dist/pyinstaller-*.whl'
echo "##[endgroup]"
echo 'python -m pip download --dest=dist .[completion] && rm -f dist/pyinstaller-*.whl' > /home/github/70929241273/steps/bugswarm_13.sh
chmod u+x /home/github/70929241273/steps/bugswarm_13.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=13 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=rokm GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=termux-test GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/termux-test GITHUB_REF_NAME=termux-test GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=pyinstaller/pyinstaller GITHUB_REPOSITORY_OWNER=pyinstaller GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=208c3caedf9c6614493e0db75d64767af408f521 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 FORCE_COLOR=1 PYINSTALLER_STRICT_UNPACK_MODE=1 PYINSTALLER_STRICT_COLLECT_MODE=1 PYINSTALLER_STRICT_BUNDLE_CODESIGN_ERROR=1 PYINSTALLER_VERIFY_BUNDLE_SIGNATURE=1 PYTHONWARNDEFAULTENCODING=true "${CURRENT_ENV[@]}" \
bash --noprofile --norc -eo pipefail /home/github/70929241273/steps/bugswarm_13.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=13 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=rokm GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=termux-test GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/termux-test GITHUB_REF_NAME=termux-test GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=pyinstaller/pyinstaller GITHUB_REPOSITORY_OWNER=pyinstaller GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=208c3caedf9c6614493e0db75d64767af408f521 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 FORCE_COLOR=1 PYINSTALLER_STRICT_UNPACK_MODE=1 PYINSTALLER_STRICT_COLLECT_MODE=1 PYINSTALLER_STRICT_BUNDLE_CODESIGN_ERROR=1 PYINSTALLER_VERIFY_BUNDLE_SIGNATURE=1 PYTHONWARNDEFAULTENCODING=true "${CURRENT_ENV[@]}" \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=13 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=rokm GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=termux-test GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/termux-test GITHUB_REF_NAME=termux-test GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=pyinstaller/pyinstaller GITHUB_REPOSITORY_OWNER=pyinstaller GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=208c3caedf9c6614493e0db75d64767af408f521 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 FORCE_COLOR=1 PYINSTALLER_STRICT_UNPACK_MODE=1 PYINSTALLER_STRICT_COLLECT_MODE=1 PYINSTALLER_STRICT_BUNDLE_CODESIGN_ERROR=1 PYINSTALLER_VERIFY_BUNDLE_SIGNATURE=1 PYTHONWARNDEFAULTENCODING=true "${CURRENT_ENV[@]}" \
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=14 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=rokm GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=termux-test GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/termux-test GITHUB_REF_NAME=termux-test GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=pyinstaller/pyinstaller GITHUB_REPOSITORY_OWNER=pyinstaller GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=208c3caedf9c6614493e0db75d64767af408f521 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 FORCE_COLOR=1 PYINSTALLER_STRICT_UNPACK_MODE=1 PYINSTALLER_STRICT_COLLECT_MODE=1 PYINSTALLER_STRICT_BUNDLE_CODESIGN_ERROR=1 PYINSTALLER_VERIFY_BUNDLE_SIGNATURE=1 PYTHONWARNDEFAULTENCODING=true "${CURRENT_ENV[@]}" \
echo $(test "$_GITHUB_JOB_STATUS" = "success" && echo true || echo false))
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=14 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=rokm GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=termux-test GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/termux-test GITHUB_REF_NAME=termux-test GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=pyinstaller/pyinstaller GITHUB_REPOSITORY_OWNER=pyinstaller GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=208c3caedf9c6614493e0db75d64767af408f521 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 FORCE_COLOR=1 PYINSTALLER_STRICT_UNPACK_MODE=1 PYINSTALLER_STRICT_COLLECT_MODE=1 PYINSTALLER_STRICT_BUNDLE_CODESIGN_ERROR=1 PYINSTALLER_VERIFY_BUNDLE_SIGNATURE=1 PYTHONWARNDEFAULTENCODING=true "${CURRENT_ENV[@]}" \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run 'sh release/build-wheels'
echo "##[endgroup]"
echo 'sh release/build-wheels' > /home/github/70929241273/steps/bugswarm_14.sh
chmod u+x /home/github/70929241273/steps/bugswarm_14.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=14 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=rokm GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=termux-test GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/termux-test GITHUB_REF_NAME=termux-test GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=pyinstaller/pyinstaller GITHUB_REPOSITORY_OWNER=pyinstaller GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=208c3caedf9c6614493e0db75d64767af408f521 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 FORCE_COLOR=1 PYINSTALLER_STRICT_UNPACK_MODE=1 PYINSTALLER_STRICT_COLLECT_MODE=1 PYINSTALLER_STRICT_BUNDLE_CODESIGN_ERROR=1 PYINSTALLER_VERIFY_BUNDLE_SIGNATURE=1 PYTHONWARNDEFAULTENCODING=true "${CURRENT_ENV[@]}" \
bash -e /home/github/70929241273/steps/bugswarm_14.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=14 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=rokm GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=termux-test GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/termux-test GITHUB_REF_NAME=termux-test GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=pyinstaller/pyinstaller GITHUB_REPOSITORY_OWNER=pyinstaller GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=208c3caedf9c6614493e0db75d64767af408f521 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 FORCE_COLOR=1 PYINSTALLER_STRICT_UNPACK_MODE=1 PYINSTALLER_STRICT_COLLECT_MODE=1 PYINSTALLER_STRICT_BUNDLE_CODESIGN_ERROR=1 PYINSTALLER_VERIFY_BUNDLE_SIGNATURE=1 PYTHONWARNDEFAULTENCODING=true "${CURRENT_ENV[@]}" \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=14 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=rokm GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=termux-test GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/termux-test GITHUB_REF_NAME=termux-test GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=pyinstaller/pyinstaller GITHUB_REPOSITORY_OWNER=pyinstaller GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=208c3caedf9c6614493e0db75d64767af408f521 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 FORCE_COLOR=1 PYINSTALLER_STRICT_UNPACK_MODE=1 PYINSTALLER_STRICT_COLLECT_MODE=1 PYINSTALLER_STRICT_BUNDLE_CODESIGN_ERROR=1 PYINSTALLER_VERIFY_BUNDLE_SIGNATURE=1 PYTHONWARNDEFAULTENCODING=true "${CURRENT_ENV[@]}" \
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=15 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=rokm GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=termux-test GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/termux-test GITHUB_REF_NAME=termux-test GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=pyinstaller/pyinstaller GITHUB_REPOSITORY_OWNER=pyinstaller GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=208c3caedf9c6614493e0db75d64767af408f521 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 FORCE_COLOR=1 PYINSTALLER_STRICT_UNPACK_MODE=1 PYINSTALLER_STRICT_COLLECT_MODE=1 PYINSTALLER_STRICT_BUNDLE_CODESIGN_ERROR=1 PYINSTALLER_VERIFY_BUNDLE_SIGNATURE=1 PYTHONWARNDEFAULTENCODING=true "${CURRENT_ENV[@]}" \
echo $(test "$_GITHUB_JOB_STATUS" = "success" && echo true || echo false))
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=15 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=rokm GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=termux-test GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/termux-test GITHUB_REF_NAME=termux-test GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=pyinstaller/pyinstaller GITHUB_REPOSITORY_OWNER=pyinstaller GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=208c3caedf9c6614493e0db75d64767af408f521 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 FORCE_COLOR=1 PYINSTALLER_STRICT_UNPACK_MODE=1 PYINSTALLER_STRICT_COLLECT_MODE=1 PYINSTALLER_STRICT_BUNDLE_CODESIGN_ERROR=1 PYINSTALLER_VERIFY_BUNDLE_SIGNATURE=1 PYTHONWARNDEFAULTENCODING=true "${CURRENT_ENV[@]}" \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run 'python -m pip install --no-index --find-links=dist pyinstaller[completion]'
echo "##[endgroup]"
echo 'python -m pip install --no-index --find-links=dist pyinstaller[completion]' > /home/github/70929241273/steps/bugswarm_15.sh
chmod u+x /home/github/70929241273/steps/bugswarm_15.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=15 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=rokm GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=termux-test GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/termux-test GITHUB_REF_NAME=termux-test GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=pyinstaller/pyinstaller GITHUB_REPOSITORY_OWNER=pyinstaller GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=208c3caedf9c6614493e0db75d64767af408f521 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 FORCE_COLOR=1 PYINSTALLER_STRICT_UNPACK_MODE=1 PYINSTALLER_STRICT_COLLECT_MODE=1 PYINSTALLER_STRICT_BUNDLE_CODESIGN_ERROR=1 PYINSTALLER_VERIFY_BUNDLE_SIGNATURE=1 PYTHONWARNDEFAULTENCODING=true "${CURRENT_ENV[@]}" \
bash -e /home/github/70929241273/steps/bugswarm_15.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=15 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=rokm GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=termux-test GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/termux-test GITHUB_REF_NAME=termux-test GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=pyinstaller/pyinstaller GITHUB_REPOSITORY_OWNER=pyinstaller GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=208c3caedf9c6614493e0db75d64767af408f521 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 FORCE_COLOR=1 PYINSTALLER_STRICT_UNPACK_MODE=1 PYINSTALLER_STRICT_COLLECT_MODE=1 PYINSTALLER_STRICT_BUNDLE_CODESIGN_ERROR=1 PYINSTALLER_VERIFY_BUNDLE_SIGNATURE=1 PYTHONWARNDEFAULTENCODING=true "${CURRENT_ENV[@]}" \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=15 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=rokm GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=termux-test GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/termux-test GITHUB_REF_NAME=termux-test GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=pyinstaller/pyinstaller GITHUB_REPOSITORY_OWNER=pyinstaller GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=208c3caedf9c6614493e0db75d64767af408f521 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 FORCE_COLOR=1 PYINSTALLER_STRICT_UNPACK_MODE=1 PYINSTALLER_STRICT_COLLECT_MODE=1 PYINSTALLER_STRICT_BUNDLE_CODESIGN_ERROR=1 PYINSTALLER_VERIFY_BUNDLE_SIGNATURE=1 PYTHONWARNDEFAULTENCODING=true "${CURRENT_ENV[@]}" \
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=16 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=rokm GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=termux-test GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/termux-test GITHUB_REF_NAME=termux-test GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=pyinstaller/pyinstaller GITHUB_REPOSITORY_OWNER=pyinstaller GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=208c3caedf9c6614493e0db75d64767af408f521 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 FORCE_COLOR=1 PYINSTALLER_STRICT_UNPACK_MODE=1 PYINSTALLER_STRICT_COLLECT_MODE=1 PYINSTALLER_STRICT_BUNDLE_CODESIGN_ERROR=1 PYINSTALLER_VERIFY_BUNDLE_SIGNATURE=1 PYTHONWARNDEFAULTENCODING=true "${CURRENT_ENV[@]}" \
echo $(test "$_GITHUB_JOB_STATUS" = "success" && echo true || echo false))
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=16 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=rokm GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=termux-test GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/termux-test GITHUB_REF_NAME=termux-test GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=pyinstaller/pyinstaller GITHUB_REPOSITORY_OWNER=pyinstaller GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=208c3caedf9c6614493e0db75d64767af408f521 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 FORCE_COLOR=1 PYINSTALLER_STRICT_UNPACK_MODE=1 PYINSTALLER_STRICT_COLLECT_MODE=1 PYINSTALLER_STRICT_BUNDLE_CODESIGN_ERROR=1 PYINSTALLER_VERIFY_BUNDLE_SIGNATURE=1 PYTHONWARNDEFAULTENCODING=true "${CURRENT_ENV[@]}" \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run 'python -m PyInstaller -h'
echo "##[endgroup]"
echo 'python -m PyInstaller -h' > /home/github/70929241273/steps/bugswarm_16.sh
chmod u+x /home/github/70929241273/steps/bugswarm_16.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=16 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=rokm GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=termux-test GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/termux-test GITHUB_REF_NAME=termux-test GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=pyinstaller/pyinstaller GITHUB_REPOSITORY_OWNER=pyinstaller GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=208c3caedf9c6614493e0db75d64767af408f521 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 FORCE_COLOR=1 PYINSTALLER_STRICT_UNPACK_MODE=1 PYINSTALLER_STRICT_COLLECT_MODE=1 PYINSTALLER_STRICT_BUNDLE_CODESIGN_ERROR=1 PYINSTALLER_VERIFY_BUNDLE_SIGNATURE=1 PYTHONWARNDEFAULTENCODING=true "${CURRENT_ENV[@]}" \
bash -e /home/github/70929241273/steps/bugswarm_16.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=16 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=rokm GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=termux-test GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/termux-test GITHUB_REF_NAME=termux-test GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=pyinstaller/pyinstaller GITHUB_REPOSITORY_OWNER=pyinstaller GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=208c3caedf9c6614493e0db75d64767af408f521 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 FORCE_COLOR=1 PYINSTALLER_STRICT_UNPACK_MODE=1 PYINSTALLER_STRICT_COLLECT_MODE=1 PYINSTALLER_STRICT_BUNDLE_CODESIGN_ERROR=1 PYINSTALLER_VERIFY_BUNDLE_SIGNATURE=1 PYTHONWARNDEFAULTENCODING=true "${CURRENT_ENV[@]}" \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=16 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=rokm GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=termux-test GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/termux-test GITHUB_REF_NAME=termux-test GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=pyinstaller/pyinstaller GITHUB_REPOSITORY_OWNER=pyinstaller GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=208c3caedf9c6614493e0db75d64767af408f521 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 FORCE_COLOR=1 PYINSTALLER_STRICT_UNPACK_MODE=1 PYINSTALLER_STRICT_COLLECT_MODE=1 PYINSTALLER_STRICT_BUNDLE_CODESIGN_ERROR=1 PYINSTALLER_VERIFY_BUNDLE_SIGNATURE=1 PYTHONWARNDEFAULTENCODING=true "${CURRENT_ENV[@]}" \
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=17 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=rokm GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=termux-test GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/termux-test GITHUB_REF_NAME=termux-test GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=pyinstaller/pyinstaller GITHUB_REPOSITORY_OWNER=pyinstaller GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=208c3caedf9c6614493e0db75d64767af408f521 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 FORCE_COLOR=1 PYINSTALLER_STRICT_UNPACK_MODE=1 PYINSTALLER_STRICT_COLLECT_MODE=1 PYINSTALLER_STRICT_BUNDLE_CODESIGN_ERROR=1 PYINSTALLER_VERIFY_BUNDLE_SIGNATURE=1 PYTHONWARNDEFAULTENCODING=true "${CURRENT_ENV[@]}" \
echo $(test "$_GITHUB_JOB_STATUS" = "success" && echo true || echo false))
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=17 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=rokm GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=termux-test GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/termux-test GITHUB_REF_NAME=termux-test GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=pyinstaller/pyinstaller GITHUB_REPOSITORY_OWNER=pyinstaller GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=208c3caedf9c6614493e0db75d64767af408f521 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 FORCE_COLOR=1 PYINSTALLER_STRICT_UNPACK_MODE=1 PYINSTALLER_STRICT_COLLECT_MODE=1 PYINSTALLER_STRICT_BUNDLE_CODESIGN_ERROR=1 PYINSTALLER_VERIFY_BUNDLE_SIGNATURE=1 PYTHONWARNDEFAULTENCODING=true "${CURRENT_ENV[@]}" \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run 'python -m pip install --progress-bar=off --upgrade --requirement tests/requirements-base.txt'
echo "##[endgroup]"
echo 'python -m pip install --progress-bar=off --upgrade --requirement tests/requirements-base.txt
' > /home/github/70929241273/steps/bugswarm_17.sh
chmod u+x /home/github/70929241273/steps/bugswarm_17.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=17 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=rokm GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=termux-test GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/termux-test GITHUB_REF_NAME=termux-test GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=pyinstaller/pyinstaller GITHUB_REPOSITORY_OWNER=pyinstaller GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=208c3caedf9c6614493e0db75d64767af408f521 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 FORCE_COLOR=1 PYINSTALLER_STRICT_UNPACK_MODE=1 PYINSTALLER_STRICT_COLLECT_MODE=1 PYINSTALLER_STRICT_BUNDLE_CODESIGN_ERROR=1 PYINSTALLER_VERIFY_BUNDLE_SIGNATURE=1 PYTHONWARNDEFAULTENCODING=true "${CURRENT_ENV[@]}" \
bash -e /home/github/70929241273/steps/bugswarm_17.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=17 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=rokm GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=termux-test GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/termux-test GITHUB_REF_NAME=termux-test GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=pyinstaller/pyinstaller GITHUB_REPOSITORY_OWNER=pyinstaller GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=208c3caedf9c6614493e0db75d64767af408f521 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 FORCE_COLOR=1 PYINSTALLER_STRICT_UNPACK_MODE=1 PYINSTALLER_STRICT_COLLECT_MODE=1 PYINSTALLER_STRICT_BUNDLE_CODESIGN_ERROR=1 PYINSTALLER_VERIFY_BUNDLE_SIGNATURE=1 PYTHONWARNDEFAULTENCODING=true "${CURRENT_ENV[@]}" \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=17 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=rokm GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=termux-test GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/termux-test GITHUB_REF_NAME=termux-test GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=pyinstaller/pyinstaller GITHUB_REPOSITORY_OWNER=pyinstaller GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=208c3caedf9c6614493e0db75d64767af408f521 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 FORCE_COLOR=1 PYINSTALLER_STRICT_UNPACK_MODE=1 PYINSTALLER_STRICT_COLLECT_MODE=1 PYINSTALLER_STRICT_BUNDLE_CODESIGN_ERROR=1 PYINSTALLER_VERIFY_BUNDLE_SIGNATURE=1 PYTHONWARNDEFAULTENCODING=true "${CURRENT_ENV[@]}" \
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=18 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=rokm GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=termux-test GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/termux-test GITHUB_REF_NAME=termux-test GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=pyinstaller/pyinstaller GITHUB_REPOSITORY_OWNER=pyinstaller GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=208c3caedf9c6614493e0db75d64767af408f521 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 FORCE_COLOR=1 PYINSTALLER_STRICT_UNPACK_MODE=1 PYINSTALLER_STRICT_COLLECT_MODE=1 PYINSTALLER_STRICT_BUNDLE_CODESIGN_ERROR=1 PYINSTALLER_VERIFY_BUNDLE_SIGNATURE=1 PYTHONWARNDEFAULTENCODING=true "${CURRENT_ENV[@]}" \
echo "$(/home/github/70929241273/helpers/eval_expression p:'(' f:success p:'(' p:')' p:')' o:'&&' p:'(' p:'(' o:'!' p:'(' f:endsWith p:'(' s:3.11 s:-dev p:')' p:')' p:')' o:'&&' p:'(' s:3.11 o:'!=' s:3.13t p:')' p:')')")
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=18 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=rokm GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=termux-test GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/termux-test GITHUB_REF_NAME=termux-test GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=pyinstaller/pyinstaller GITHUB_REPOSITORY_OWNER=pyinstaller GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=208c3caedf9c6614493e0db75d64767af408f521 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 FORCE_COLOR=1 PYINSTALLER_STRICT_UNPACK_MODE=1 PYINSTALLER_STRICT_COLLECT_MODE=1 PYINSTALLER_STRICT_BUNDLE_CODESIGN_ERROR=1 PYINSTALLER_VERIFY_BUNDLE_SIGNATURE=1 PYTHONWARNDEFAULTENCODING=true "${CURRENT_ENV[@]}" \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run 'python -m pip install --progress-bar=off --upgrade --requirement tests/requirements-libraries.txt'
echo "##[endgroup]"
echo 'python -m pip install --progress-bar=off --upgrade --requirement tests/requirements-libraries.txt
' > /home/github/70929241273/steps/bugswarm_18.sh
chmod u+x /home/github/70929241273/steps/bugswarm_18.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=18 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=rokm GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=termux-test GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/termux-test GITHUB_REF_NAME=termux-test GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=pyinstaller/pyinstaller GITHUB_REPOSITORY_OWNER=pyinstaller GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=208c3caedf9c6614493e0db75d64767af408f521 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 FORCE_COLOR=1 PYINSTALLER_STRICT_UNPACK_MODE=1 PYINSTALLER_STRICT_COLLECT_MODE=1 PYINSTALLER_STRICT_BUNDLE_CODESIGN_ERROR=1 PYINSTALLER_VERIFY_BUNDLE_SIGNATURE=1 PYTHONWARNDEFAULTENCODING=true "${CURRENT_ENV[@]}" \
bash -e /home/github/70929241273/steps/bugswarm_18.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=18 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=rokm GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=termux-test GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/termux-test GITHUB_REF_NAME=termux-test GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=pyinstaller/pyinstaller GITHUB_REPOSITORY_OWNER=pyinstaller GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=208c3caedf9c6614493e0db75d64767af408f521 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 FORCE_COLOR=1 PYINSTALLER_STRICT_UNPACK_MODE=1 PYINSTALLER_STRICT_COLLECT_MODE=1 PYINSTALLER_STRICT_BUNDLE_CODESIGN_ERROR=1 PYINSTALLER_VERIFY_BUNDLE_SIGNATURE=1 PYTHONWARNDEFAULTENCODING=true "${CURRENT_ENV[@]}" \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=18 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=rokm GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=termux-test GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/termux-test GITHUB_REF_NAME=termux-test GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=pyinstaller/pyinstaller GITHUB_REPOSITORY_OWNER=pyinstaller GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=208c3caedf9c6614493e0db75d64767af408f521 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 FORCE_COLOR=1 PYINSTALLER_STRICT_UNPACK_MODE=1 PYINSTALLER_STRICT_COLLECT_MODE=1 PYINSTALLER_STRICT_BUNDLE_CODESIGN_ERROR=1 PYINSTALLER_VERIFY_BUNDLE_SIGNATURE=1 PYTHONWARNDEFAULTENCODING=true "${CURRENT_ENV[@]}" \
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=19 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=rokm GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=termux-test GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/termux-test GITHUB_REF_NAME=termux-test GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=pyinstaller/pyinstaller GITHUB_REPOSITORY_OWNER=pyinstaller GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=208c3caedf9c6614493e0db75d64767af408f521 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 FORCE_COLOR=1 PYINSTALLER_STRICT_UNPACK_MODE=1 PYINSTALLER_STRICT_COLLECT_MODE=1 PYINSTALLER_STRICT_BUNDLE_CODESIGN_ERROR=1 PYINSTALLER_VERIFY_BUNDLE_SIGNATURE=1 PYTHONWARNDEFAULTENCODING=true "${CURRENT_ENV[@]}" \
echo $(test "$_GITHUB_JOB_STATUS" = "success" && echo true || echo false))
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=19 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=rokm GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=termux-test GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/termux-test GITHUB_REF_NAME=termux-test GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=pyinstaller/pyinstaller GITHUB_REPOSITORY_OWNER=pyinstaller GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=208c3caedf9c6614493e0db75d64767af408f521 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 FORCE_COLOR=1 PYINSTALLER_STRICT_UNPACK_MODE=1 PYINSTALLER_STRICT_COLLECT_MODE=1 PYINSTALLER_STRICT_BUNDLE_CODESIGN_ERROR=1 PYINSTALLER_VERIFY_BUNDLE_SIGNATURE=1 PYTHONWARNDEFAULTENCODING=true "${CURRENT_ENV[@]}" \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run 'import sys'
echo "##[endgroup]"
echo 'import sys
import pathlib
import shutil
import importlib.util

PACKAGES = [
  '"'"'setuptools._vendor.importlib_resources'"'"',
  '"'"'pkg_resources'"'"',
]

def fix_package(package_name):
  try:
    spec = importlib.util.find_spec(package_name)
  except ImportError:
    spec = None  # parent package (e.g., setuptools or setuptools._vendor) does not exist
  if spec is None:
    print(f"Did not find {package_name}.")
    return
  elif spec.loader is not None:
    # Not a namespace package (i.e., directory with just __pycache__ sub-directory)
    print(f"Found a valid copy of {package_name}.")
    return

  print(f"Found a defunct copy of {package_name}!")

  # List the contents of package directory for debug purposes
  def list_directory(path, pad=""):
    for child in path.iterdir():
      if child.is_dir():
        print(f"{pad} + {child.name}")
        list_directory(child, pad + " ")
      else:
        print(f"{pad} - {child.name} ({child.stat().st_size} bytes)")

  for path in spec.submodule_search_locations:
    print(f"Listing contents of {path}")
    list_directory(pathlib.Path(path))

  # Remove
  for path in spec.submodule_search_locations:
    print(f"Removing {path}...")
    shutil.rmtree(path)

for package in PACKAGES:
  fix_package(package)
' > /home/github/70929241273/steps/bugswarm_19.py
chmod u+x /home/github/70929241273/steps/bugswarm_19.py


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=19 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=rokm GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=termux-test GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/termux-test GITHUB_REF_NAME=termux-test GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=pyinstaller/pyinstaller GITHUB_REPOSITORY_OWNER=pyinstaller GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=208c3caedf9c6614493e0db75d64767af408f521 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 FORCE_COLOR=1 PYINSTALLER_STRICT_UNPACK_MODE=1 PYINSTALLER_STRICT_COLLECT_MODE=1 PYINSTALLER_STRICT_BUNDLE_CODESIGN_ERROR=1 PYINSTALLER_VERIFY_BUNDLE_SIGNATURE=1 PYTHONWARNDEFAULTENCODING=true "${CURRENT_ENV[@]}" \
python /home/github/70929241273/steps/bugswarm_19.py
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=19 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=rokm GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=termux-test GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/termux-test GITHUB_REF_NAME=termux-test GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=pyinstaller/pyinstaller GITHUB_REPOSITORY_OWNER=pyinstaller GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=208c3caedf9c6614493e0db75d64767af408f521 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 FORCE_COLOR=1 PYINSTALLER_STRICT_UNPACK_MODE=1 PYINSTALLER_STRICT_COLLECT_MODE=1 PYINSTALLER_STRICT_BUNDLE_CODESIGN_ERROR=1 PYINSTALLER_VERIFY_BUNDLE_SIGNATURE=1 PYTHONWARNDEFAULTENCODING=true "${CURRENT_ENV[@]}" \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=19 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=rokm GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=termux-test GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/termux-test GITHUB_REF_NAME=termux-test GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=pyinstaller/pyinstaller GITHUB_REPOSITORY_OWNER=pyinstaller GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=208c3caedf9c6614493e0db75d64767af408f521 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 FORCE_COLOR=1 PYINSTALLER_STRICT_UNPACK_MODE=1 PYINSTALLER_STRICT_COLLECT_MODE=1 PYINSTALLER_STRICT_BUNDLE_CODESIGN_ERROR=1 PYINSTALLER_VERIFY_BUNDLE_SIGNATURE=1 PYTHONWARNDEFAULTENCODING=true "${CURRENT_ENV[@]}" \
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=20 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=rokm GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=termux-test GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/termux-test GITHUB_REF_NAME=termux-test GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=pyinstaller/pyinstaller GITHUB_REPOSITORY_OWNER=pyinstaller GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=208c3caedf9c6614493e0db75d64767af408f521 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 FORCE_COLOR=1 PYINSTALLER_STRICT_UNPACK_MODE=1 PYINSTALLER_STRICT_COLLECT_MODE=1 PYINSTALLER_STRICT_BUNDLE_CODESIGN_ERROR=1 PYINSTALLER_VERIFY_BUNDLE_SIGNATURE=1 PYTHONWARNDEFAULTENCODING=true "${CURRENT_ENV[@]}" \
echo "$(/home/github/70929241273/helpers/eval_expression p:'(' f:success p:'(' p:')' p:')' o:'&&' p:'(' f:startsWith p:'(' s:macos-14 s:ubuntu p:')' p:')')")
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=20 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=rokm GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=termux-test GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/termux-test GITHUB_REF_NAME=termux-test GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=pyinstaller/pyinstaller GITHUB_REPOSITORY_OWNER=pyinstaller GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=208c3caedf9c6614493e0db75d64767af408f521 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 FORCE_COLOR=1 PYINSTALLER_STRICT_UNPACK_MODE=1 PYINSTALLER_STRICT_COLLECT_MODE=1 PYINSTALLER_STRICT_BUNDLE_CODESIGN_ERROR=1 PYINSTALLER_VERIFY_BUNDLE_SIGNATURE=1 PYTHONWARNDEFAULTENCODING=true "${CURRENT_ENV[@]}" \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run 'Xvfb :99 &'
echo "##[endgroup]"
echo 'Xvfb :99 &
echo "DISPLAY=:99" >> $GITHUB_ENV
' > /home/github/70929241273/steps/bugswarm_20.sh
chmod u+x /home/github/70929241273/steps/bugswarm_20.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=20 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=rokm GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=termux-test GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/termux-test GITHUB_REF_NAME=termux-test GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=pyinstaller/pyinstaller GITHUB_REPOSITORY_OWNER=pyinstaller GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=208c3caedf9c6614493e0db75d64767af408f521 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 FORCE_COLOR=1 PYINSTALLER_STRICT_UNPACK_MODE=1 PYINSTALLER_STRICT_COLLECT_MODE=1 PYINSTALLER_STRICT_BUNDLE_CODESIGN_ERROR=1 PYINSTALLER_VERIFY_BUNDLE_SIGNATURE=1 PYTHONWARNDEFAULTENCODING=true "${CURRENT_ENV[@]}" \
bash -e /home/github/70929241273/steps/bugswarm_20.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=20 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=rokm GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=termux-test GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/termux-test GITHUB_REF_NAME=termux-test GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=pyinstaller/pyinstaller GITHUB_REPOSITORY_OWNER=pyinstaller GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=208c3caedf9c6614493e0db75d64767af408f521 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 FORCE_COLOR=1 PYINSTALLER_STRICT_UNPACK_MODE=1 PYINSTALLER_STRICT_COLLECT_MODE=1 PYINSTALLER_STRICT_BUNDLE_CODESIGN_ERROR=1 PYINSTALLER_VERIFY_BUNDLE_SIGNATURE=1 PYTHONWARNDEFAULTENCODING=true "${CURRENT_ENV[@]}" \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=20 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=rokm GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=termux-test GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/termux-test GITHUB_REF_NAME=termux-test GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=pyinstaller/pyinstaller GITHUB_REPOSITORY_OWNER=pyinstaller GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=208c3caedf9c6614493e0db75d64767af408f521 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 FORCE_COLOR=1 PYINSTALLER_STRICT_UNPACK_MODE=1 PYINSTALLER_STRICT_COLLECT_MODE=1 PYINSTALLER_STRICT_BUNDLE_CODESIGN_ERROR=1 PYINSTALLER_VERIFY_BUNDLE_SIGNATURE=1 PYTHONWARNDEFAULTENCODING=true "${CURRENT_ENV[@]}" \
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=21 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=rokm GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=termux-test GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/termux-test GITHUB_REF_NAME=termux-test GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=pyinstaller/pyinstaller GITHUB_REPOSITORY_OWNER=pyinstaller GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=208c3caedf9c6614493e0db75d64767af408f521 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 FORCE_COLOR=1 PYINSTALLER_STRICT_UNPACK_MODE=1 PYINSTALLER_STRICT_COLLECT_MODE=1 PYINSTALLER_STRICT_BUNDLE_CODESIGN_ERROR=1 PYINSTALLER_VERIFY_BUNDLE_SIGNATURE=1 PYTHONWARNDEFAULTENCODING=true "${CURRENT_ENV[@]}" \
echo $(test "$_GITHUB_JOB_STATUS" = "success" && echo true || echo false))
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=21 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=rokm GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=termux-test GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/termux-test GITHUB_REF_NAME=termux-test GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=pyinstaller/pyinstaller GITHUB_REPOSITORY_OWNER=pyinstaller GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=208c3caedf9c6614493e0db75d64767af408f521 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 FORCE_COLOR=1 PYINSTALLER_STRICT_UNPACK_MODE=1 PYINSTALLER_STRICT_COLLECT_MODE=1 PYINSTALLER_STRICT_BUNDLE_CODESIGN_ERROR=1 PYINSTALLER_VERIFY_BUNDLE_SIGNATURE=1 PYTHONWARNDEFAULTENCODING=true "${CURRENT_ENV[@]}" \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run 'echo "PYTEST_DEBUG_TEMPROOT=$RUNNER_TEMP" >> $GITHUB_ENV'
echo "##[endgroup]"
echo 'echo "PYTEST_DEBUG_TEMPROOT=$RUNNER_TEMP" >> $GITHUB_ENV
' > /home/github/70929241273/steps/bugswarm_21.sh
chmod u+x /home/github/70929241273/steps/bugswarm_21.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=21 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=rokm GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=termux-test GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/termux-test GITHUB_REF_NAME=termux-test GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=pyinstaller/pyinstaller GITHUB_REPOSITORY_OWNER=pyinstaller GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=208c3caedf9c6614493e0db75d64767af408f521 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 FORCE_COLOR=1 PYINSTALLER_STRICT_UNPACK_MODE=1 PYINSTALLER_STRICT_COLLECT_MODE=1 PYINSTALLER_STRICT_BUNDLE_CODESIGN_ERROR=1 PYINSTALLER_VERIFY_BUNDLE_SIGNATURE=1 PYTHONWARNDEFAULTENCODING=true "${CURRENT_ENV[@]}" \
bash --noprofile --norc -eo pipefail /home/github/70929241273/steps/bugswarm_21.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=21 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=rokm GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=termux-test GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/termux-test GITHUB_REF_NAME=termux-test GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=pyinstaller/pyinstaller GITHUB_REPOSITORY_OWNER=pyinstaller GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=208c3caedf9c6614493e0db75d64767af408f521 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 FORCE_COLOR=1 PYINSTALLER_STRICT_UNPACK_MODE=1 PYINSTALLER_STRICT_COLLECT_MODE=1 PYINSTALLER_STRICT_BUNDLE_CODESIGN_ERROR=1 PYINSTALLER_VERIFY_BUNDLE_SIGNATURE=1 PYTHONWARNDEFAULTENCODING=true "${CURRENT_ENV[@]}" \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=21 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=rokm GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=termux-test GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/termux-test GITHUB_REF_NAME=termux-test GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=pyinstaller/pyinstaller GITHUB_REPOSITORY_OWNER=pyinstaller GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=208c3caedf9c6614493e0db75d64767af408f521 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 FORCE_COLOR=1 PYINSTALLER_STRICT_UNPACK_MODE=1 PYINSTALLER_STRICT_COLLECT_MODE=1 PYINSTALLER_STRICT_BUNDLE_CODESIGN_ERROR=1 PYINSTALLER_VERIFY_BUNDLE_SIGNATURE=1 PYTHONWARNDEFAULTENCODING=true "${CURRENT_ENV[@]}" \
bash -e $ACTIONS_RUNNER_HOOK_STEP_COMPLETED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

fi

update_current_env "$LAST_JOB_NAME"
LAST_JOB_NAME="RUN_TESTS"
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=22 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=rokm GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=termux-test GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/termux-test GITHUB_REF_NAME=termux-test GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=pyinstaller/pyinstaller GITHUB_REPOSITORY_OWNER=pyinstaller GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=208c3caedf9c6614493e0db75d64767af408f521 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 FORCE_COLOR=1 PYINSTALLER_STRICT_UNPACK_MODE=1 PYINSTALLER_STRICT_COLLECT_MODE=1 PYINSTALLER_STRICT_BUNDLE_CODESIGN_ERROR=1 PYINSTALLER_VERIFY_BUNDLE_SIGNATURE=1 PYTHONWARNDEFAULTENCODING=true "${CURRENT_ENV[@]}" \
echo $(test "$_GITHUB_JOB_STATUS" = "success" && echo true || echo false))
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=22 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=rokm GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=termux-test GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/termux-test GITHUB_REF_NAME=termux-test GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=pyinstaller/pyinstaller GITHUB_REPOSITORY_OWNER=pyinstaller GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=208c3caedf9c6614493e0db75d64767af408f521 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 FORCE_COLOR=1 PYINSTALLER_STRICT_UNPACK_MODE=1 PYINSTALLER_STRICT_COLLECT_MODE=1 PYINSTALLER_STRICT_BUNDLE_CODESIGN_ERROR=1 PYINSTALLER_VERIFY_BUNDLE_SIGNATURE=1 PYTHONWARNDEFAULTENCODING=true "${CURRENT_ENV[@]}" \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run 'pytest -n 5 --maxfail 3 --durations 10 tests/unit tests/functional'
echo "##[endgroup]"
echo 'pytest -n 5 --maxfail 3 --durations 10 tests/unit tests/functional
' > /home/github/70929241273/steps/bugswarm_22.sh
chmod u+x /home/github/70929241273/steps/bugswarm_22.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=22 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=rokm GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=termux-test GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/termux-test GITHUB_REF_NAME=termux-test GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=pyinstaller/pyinstaller GITHUB_REPOSITORY_OWNER=pyinstaller GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=208c3caedf9c6614493e0db75d64767af408f521 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 FORCE_COLOR=1 PYINSTALLER_STRICT_UNPACK_MODE=1 PYINSTALLER_STRICT_COLLECT_MODE=1 PYINSTALLER_STRICT_BUNDLE_CODESIGN_ERROR=1 PYINSTALLER_VERIFY_BUNDLE_SIGNATURE=1 PYTHONWARNDEFAULTENCODING=true "${CURRENT_ENV[@]}" \
bash -e /home/github/70929241273/steps/bugswarm_22.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=22 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=rokm GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=termux-test GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/termux-test GITHUB_REF_NAME=termux-test GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=pyinstaller/pyinstaller GITHUB_REPOSITORY_OWNER=pyinstaller GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=208c3caedf9c6614493e0db75d64767af408f521 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 FORCE_COLOR=1 PYINSTALLER_STRICT_UNPACK_MODE=1 PYINSTALLER_STRICT_COLLECT_MODE=1 PYINSTALLER_STRICT_BUNDLE_CODESIGN_ERROR=1 PYINSTALLER_VERIFY_BUNDLE_SIGNATURE=1 PYTHONWARNDEFAULTENCODING=true "${CURRENT_ENV[@]}" \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

  _CONTEXT_STEPS_RUN_TESTS_OUTCOME=failure
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    _CONTEXT_STEPS_RUN_TESTS_CONCLUSION=failure
  else
    _CONTEXT_STEPS_RUN_TESTS_CONCLUSION=success
  fi
else
  _CONTEXT_STEPS_RUN_TESTS_OUTCOME=success
  _CONTEXT_STEPS_RUN_TESTS_CONCLUSION=success
fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=22 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=rokm GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=termux-test GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/termux-test GITHUB_REF_NAME=termux-test GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=pyinstaller/pyinstaller GITHUB_REPOSITORY_OWNER=pyinstaller GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=208c3caedf9c6614493e0db75d64767af408f521 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 FORCE_COLOR=1 PYINSTALLER_STRICT_UNPACK_MODE=1 PYINSTALLER_STRICT_COLLECT_MODE=1 PYINSTALLER_STRICT_BUNDLE_CODESIGN_ERROR=1 PYINSTALLER_VERIFY_BUNDLE_SIGNATURE=1 PYTHONWARNDEFAULTENCODING=true "${CURRENT_ENV[@]}" \
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=23 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=rokm GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=termux-test GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/termux-test GITHUB_REF_NAME=termux-test GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=pyinstaller/pyinstaller GITHUB_REPOSITORY_OWNER=pyinstaller GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=208c3caedf9c6614493e0db75d64767af408f521 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 FORCE_COLOR=1 PYINSTALLER_STRICT_UNPACK_MODE=1 PYINSTALLER_STRICT_COLLECT_MODE=1 PYINSTALLER_STRICT_BUNDLE_CODESIGN_ERROR=1 PYINSTALLER_VERIFY_BUNDLE_SIGNATURE=1 PYTHONWARNDEFAULTENCODING=true "${CURRENT_ENV[@]}" \
echo "$(/home/github/70929241273/helpers/eval_expression p:'(' f:failure p:'(' p:')' p:')' o:'&&' p:'(' s:${_CONTEXT_STEPS_RUN_TESTS_OUTCOME} o:== s:failure p:')')")
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=23 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=rokm GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=termux-test GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/termux-test GITHUB_REF_NAME=termux-test GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=pyinstaller/pyinstaller GITHUB_REPOSITORY_OWNER=pyinstaller GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=208c3caedf9c6614493e0db75d64767af408f521 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 FORCE_COLOR=1 PYINSTALLER_STRICT_UNPACK_MODE=1 PYINSTALLER_STRICT_COLLECT_MODE=1 PYINSTALLER_STRICT_BUNDLE_CODESIGN_ERROR=1 PYINSTALLER_VERIFY_BUNDLE_SIGNATURE=1 PYTHONWARNDEFAULTENCODING=true "${CURRENT_ENV[@]}" \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run 'import os'
echo "##[endgroup]"
echo 'import os
import sys
import tarfile

try:
  import getpass
  user = getpass.getuser() or "unknown"
except Exception:
  user = "unknown"

temproot = os.environ['"'"'PYTEST_DEBUG_TEMPROOT'"'"']

pytest_name = f'"'"'pytest-of-{user}'"'"'
pytest_fullpath = os.path.join(temproot, pytest_name)
print(f"Input directory: {pytest_fullpath}!", file=sys.stderr)

output_file = os.path.join(temproot, '"'"'archived-failed-tests.tar'"'"')
print(f"Output file: {output_file}!", file=sys.stderr)

assert os.path.isdir(pytest_fullpath)
assert not os.path.exists(output_file)

with tarfile.open(output_file, "w") as tf:
  tf.add(pytest_fullpath, arcname=pytest_name, recursive=True)

print(f"Created {output_file}!", file=sys.stderr)
' > /home/github/70929241273/steps/bugswarm_23.py
chmod u+x /home/github/70929241273/steps/bugswarm_23.py


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=23 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=rokm GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=termux-test GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/termux-test GITHUB_REF_NAME=termux-test GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=pyinstaller/pyinstaller GITHUB_REPOSITORY_OWNER=pyinstaller GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=208c3caedf9c6614493e0db75d64767af408f521 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 FORCE_COLOR=1 PYINSTALLER_STRICT_UNPACK_MODE=1 PYINSTALLER_STRICT_COLLECT_MODE=1 PYINSTALLER_STRICT_BUNDLE_CODESIGN_ERROR=1 PYINSTALLER_VERIFY_BUNDLE_SIGNATURE=1 PYTHONWARNDEFAULTENCODING=true "${CURRENT_ENV[@]}" \
python /home/github/70929241273/steps/bugswarm_23.py
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=23 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=rokm GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=termux-test GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/termux-test GITHUB_REF_NAME=termux-test GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=pyinstaller/pyinstaller GITHUB_REPOSITORY_OWNER=pyinstaller GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=208c3caedf9c6614493e0db75d64767af408f521 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 FORCE_COLOR=1 PYINSTALLER_STRICT_UNPACK_MODE=1 PYINSTALLER_STRICT_COLLECT_MODE=1 PYINSTALLER_STRICT_BUNDLE_CODESIGN_ERROR=1 PYINSTALLER_VERIFY_BUNDLE_SIGNATURE=1 PYTHONWARNDEFAULTENCODING=true "${CURRENT_ENV[@]}" \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=23 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=rokm GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=termux-test GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/termux-test GITHUB_REF_NAME=termux-test GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=pyinstaller/pyinstaller GITHUB_REPOSITORY_OWNER=pyinstaller GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=208c3caedf9c6614493e0db75d64767af408f521 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 FORCE_COLOR=1 PYINSTALLER_STRICT_UNPACK_MODE=1 PYINSTALLER_STRICT_COLLECT_MODE=1 PYINSTALLER_STRICT_BUNDLE_CODESIGN_ERROR=1 PYINSTALLER_VERIFY_BUNDLE_SIGNATURE=1 PYTHONWARNDEFAULTENCODING=true "${CURRENT_ENV[@]}" \
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=25 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=rokm GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=termux-test GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/termux-test GITHUB_REF_NAME=termux-test GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=pyinstaller/pyinstaller GITHUB_REPOSITORY_OWNER=pyinstaller GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=208c3caedf9c6614493e0db75d64767af408f521 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 FORCE_COLOR=1 PYINSTALLER_STRICT_UNPACK_MODE=1 PYINSTALLER_STRICT_COLLECT_MODE=1 PYINSTALLER_STRICT_BUNDLE_CODESIGN_ERROR=1 PYINSTALLER_VERIFY_BUNDLE_SIGNATURE=1 PYTHONWARNDEFAULTENCODING=true "${CURRENT_ENV[@]}" \
echo $(test "$_GITHUB_JOB_STATUS" = "success" && echo true || echo false))
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=25 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=rokm GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=termux-test GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/termux-test GITHUB_REF_NAME=termux-test GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=pyinstaller/pyinstaller GITHUB_REPOSITORY_OWNER=pyinstaller GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=208c3caedf9c6614493e0db75d64767af408f521 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 FORCE_COLOR=1 PYINSTALLER_STRICT_UNPACK_MODE=1 PYINSTALLER_STRICT_COLLECT_MODE=1 PYINSTALLER_STRICT_BUNDLE_CODESIGN_ERROR=1 PYINSTALLER_VERIFY_BUNDLE_SIGNATURE=1 PYTHONWARNDEFAULTENCODING=true "${CURRENT_ENV[@]}" \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run 'python -m pip install "https://github.com/pyinstaller/hooksample/archive/v4.0rc1.zip"'
echo "##[endgroup]"
echo 'python -m pip install "https://github.com/pyinstaller/hooksample/archive/v4.0rc1.zip"' > /home/github/70929241273/steps/bugswarm_25.sh
chmod u+x /home/github/70929241273/steps/bugswarm_25.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=25 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=rokm GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=termux-test GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/termux-test GITHUB_REF_NAME=termux-test GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=pyinstaller/pyinstaller GITHUB_REPOSITORY_OWNER=pyinstaller GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=208c3caedf9c6614493e0db75d64767af408f521 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 FORCE_COLOR=1 PYINSTALLER_STRICT_UNPACK_MODE=1 PYINSTALLER_STRICT_COLLECT_MODE=1 PYINSTALLER_STRICT_BUNDLE_CODESIGN_ERROR=1 PYINSTALLER_VERIFY_BUNDLE_SIGNATURE=1 PYTHONWARNDEFAULTENCODING=true "${CURRENT_ENV[@]}" \
bash -e /home/github/70929241273/steps/bugswarm_25.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=25 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=rokm GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=termux-test GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/termux-test GITHUB_REF_NAME=termux-test GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=pyinstaller/pyinstaller GITHUB_REPOSITORY_OWNER=pyinstaller GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=208c3caedf9c6614493e0db75d64767af408f521 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 FORCE_COLOR=1 PYINSTALLER_STRICT_UNPACK_MODE=1 PYINSTALLER_STRICT_COLLECT_MODE=1 PYINSTALLER_STRICT_BUNDLE_CODESIGN_ERROR=1 PYINSTALLER_VERIFY_BUNDLE_SIGNATURE=1 PYTHONWARNDEFAULTENCODING=true "${CURRENT_ENV[@]}" \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=25 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=rokm GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=termux-test GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/termux-test GITHUB_REF_NAME=termux-test GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=pyinstaller/pyinstaller GITHUB_REPOSITORY_OWNER=pyinstaller GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=208c3caedf9c6614493e0db75d64767af408f521 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 FORCE_COLOR=1 PYINSTALLER_STRICT_UNPACK_MODE=1 PYINSTALLER_STRICT_COLLECT_MODE=1 PYINSTALLER_STRICT_BUNDLE_CODESIGN_ERROR=1 PYINSTALLER_VERIFY_BUNDLE_SIGNATURE=1 PYTHONWARNDEFAULTENCODING=true "${CURRENT_ENV[@]}" \
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=26 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=rokm GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=termux-test GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/termux-test GITHUB_REF_NAME=termux-test GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=pyinstaller/pyinstaller GITHUB_REPOSITORY_OWNER=pyinstaller GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=208c3caedf9c6614493e0db75d64767af408f521 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 FORCE_COLOR=1 PYINSTALLER_STRICT_UNPACK_MODE=1 PYINSTALLER_STRICT_COLLECT_MODE=1 PYINSTALLER_STRICT_BUNDLE_CODESIGN_ERROR=1 PYINSTALLER_VERIFY_BUNDLE_SIGNATURE=1 PYTHONWARNDEFAULTENCODING=true "${CURRENT_ENV[@]}" \
echo $(test "$_GITHUB_JOB_STATUS" = "success" && echo true || echo false))
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=26 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=rokm GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=termux-test GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/termux-test GITHUB_REF_NAME=termux-test GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=pyinstaller/pyinstaller GITHUB_REPOSITORY_OWNER=pyinstaller GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=208c3caedf9c6614493e0db75d64767af408f521 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 FORCE_COLOR=1 PYINSTALLER_STRICT_UNPACK_MODE=1 PYINSTALLER_STRICT_COLLECT_MODE=1 PYINSTALLER_STRICT_BUNDLE_CODESIGN_ERROR=1 PYINSTALLER_VERIFY_BUNDLE_SIGNATURE=1 PYTHONWARNDEFAULTENCODING=true "${CURRENT_ENV[@]}" \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run 'import os'
echo "##[endgroup]"
echo 'import os
from _pyinstaller_hooks_contrib import (
    stdhooks,
    pre_safe_import_module,
    pre_find_module_path,
)
with open(os.path.join(stdhooks.__path__[0], "hook-pyi_hooksample.py"), "w", encoding="utf-8") as f:
    f.write('"'"'raise Exception("Wrong hook! Use the pyi_hooksample copy instead!")\n'"'"')
with open(os.path.join(pre_safe_import_module.__path__[0], "hook-pyi_hooksample.py"), "w", encoding="utf-8") as f:
    f.write('"'"'raise Exception("Wrong hook! Use the pyi_hooksample copy instead!")\n'"'"')
with open(os.path.join(pre_find_module_path.__path__[0], "hook-pyi_hooksample.py"), "w", encoding="utf-8") as f:
    f.write('"'"'raise Exception("Wrong hook! Use the pyi_hooksample copy instead!")\n'"'"')
' > /home/github/70929241273/steps/bugswarm_26.py
chmod u+x /home/github/70929241273/steps/bugswarm_26.py


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=26 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=rokm GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=termux-test GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/termux-test GITHUB_REF_NAME=termux-test GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=pyinstaller/pyinstaller GITHUB_REPOSITORY_OWNER=pyinstaller GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=208c3caedf9c6614493e0db75d64767af408f521 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 FORCE_COLOR=1 PYINSTALLER_STRICT_UNPACK_MODE=1 PYINSTALLER_STRICT_COLLECT_MODE=1 PYINSTALLER_STRICT_BUNDLE_CODESIGN_ERROR=1 PYINSTALLER_VERIFY_BUNDLE_SIGNATURE=1 PYTHONWARNDEFAULTENCODING=true "${CURRENT_ENV[@]}" \
python /home/github/70929241273/steps/bugswarm_26.py
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=26 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=rokm GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=termux-test GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/termux-test GITHUB_REF_NAME=termux-test GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=pyinstaller/pyinstaller GITHUB_REPOSITORY_OWNER=pyinstaller GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=208c3caedf9c6614493e0db75d64767af408f521 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 FORCE_COLOR=1 PYINSTALLER_STRICT_UNPACK_MODE=1 PYINSTALLER_STRICT_COLLECT_MODE=1 PYINSTALLER_STRICT_BUNDLE_CODESIGN_ERROR=1 PYINSTALLER_VERIFY_BUNDLE_SIGNATURE=1 PYTHONWARNDEFAULTENCODING=true "${CURRENT_ENV[@]}" \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=26 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=rokm GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=termux-test GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/termux-test GITHUB_REF_NAME=termux-test GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=pyinstaller/pyinstaller GITHUB_REPOSITORY_OWNER=pyinstaller GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=208c3caedf9c6614493e0db75d64767af408f521 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 FORCE_COLOR=1 PYINSTALLER_STRICT_UNPACK_MODE=1 PYINSTALLER_STRICT_COLLECT_MODE=1 PYINSTALLER_STRICT_BUNDLE_CODESIGN_ERROR=1 PYINSTALLER_VERIFY_BUNDLE_SIGNATURE=1 PYTHONWARNDEFAULTENCODING=true "${CURRENT_ENV[@]}" \
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=27 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=rokm GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=termux-test GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/termux-test GITHUB_REF_NAME=termux-test GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=pyinstaller/pyinstaller GITHUB_REPOSITORY_OWNER=pyinstaller GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=208c3caedf9c6614493e0db75d64767af408f521 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 FORCE_COLOR=1 PYINSTALLER_STRICT_UNPACK_MODE=1 PYINSTALLER_STRICT_COLLECT_MODE=1 PYINSTALLER_STRICT_BUNDLE_CODESIGN_ERROR=1 PYINSTALLER_VERIFY_BUNDLE_SIGNATURE=1 PYTHONWARNDEFAULTENCODING=true "${CURRENT_ENV[@]}" \
echo $(test "$_GITHUB_JOB_STATUS" = "success" && echo true || echo false))
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=27 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=rokm GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=termux-test GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/termux-test GITHUB_REF_NAME=termux-test GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=pyinstaller/pyinstaller GITHUB_REPOSITORY_OWNER=pyinstaller GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=208c3caedf9c6614493e0db75d64767af408f521 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 FORCE_COLOR=1 PYINSTALLER_STRICT_UNPACK_MODE=1 PYINSTALLER_STRICT_COLLECT_MODE=1 PYINSTALLER_STRICT_BUNDLE_CODESIGN_ERROR=1 PYINSTALLER_VERIFY_BUNDLE_SIGNATURE=1 PYTHONWARNDEFAULTENCODING=true "${CURRENT_ENV[@]}" \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run '# The ``run_tests`` script is invoked somewhere outside of the pyinstaller git clone to prevent pytest from'
echo "##[endgroup]"
echo '# The ``run_tests`` script is invoked somewhere outside of the pyinstaller git clone to prevent pytest from
# loading PyInstaller'"'"'s pytest.ini.
cd ~
python -m PyInstaller.utils.run_tests --include_only=pyi_hooksample.
' > /home/github/70929241273/steps/bugswarm_27.sh
chmod u+x /home/github/70929241273/steps/bugswarm_27.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=27 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=rokm GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=termux-test GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/termux-test GITHUB_REF_NAME=termux-test GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=pyinstaller/pyinstaller GITHUB_REPOSITORY_OWNER=pyinstaller GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=208c3caedf9c6614493e0db75d64767af408f521 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 FORCE_COLOR=1 PYINSTALLER_STRICT_UNPACK_MODE=1 PYINSTALLER_STRICT_COLLECT_MODE=1 PYINSTALLER_STRICT_BUNDLE_CODESIGN_ERROR=1 PYINSTALLER_VERIFY_BUNDLE_SIGNATURE=1 PYTHONWARNDEFAULTENCODING=true "${CURRENT_ENV[@]}" \
bash -e /home/github/70929241273/steps/bugswarm_27.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=27 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=rokm GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=termux-test GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/termux-test GITHUB_REF_NAME=termux-test GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=pyinstaller/pyinstaller GITHUB_REPOSITORY_OWNER=pyinstaller GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=208c3caedf9c6614493e0db75d64767af408f521 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 FORCE_COLOR=1 PYINSTALLER_STRICT_UNPACK_MODE=1 PYINSTALLER_STRICT_COLLECT_MODE=1 PYINSTALLER_STRICT_BUNDLE_CODESIGN_ERROR=1 PYINSTALLER_VERIFY_BUNDLE_SIGNATURE=1 PYTHONWARNDEFAULTENCODING=true "${CURRENT_ENV[@]}" \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=27 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=rokm GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=termux-test GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/termux-test GITHUB_REF_NAME=termux-test GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=pyinstaller/pyinstaller GITHUB_REPOSITORY_OWNER=pyinstaller GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=208c3caedf9c6614493e0db75d64767af408f521 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 FORCE_COLOR=1 PYINSTALLER_STRICT_UNPACK_MODE=1 PYINSTALLER_STRICT_COLLECT_MODE=1 PYINSTALLER_STRICT_BUNDLE_CODESIGN_ERROR=1 PYINSTALLER_VERIFY_BUNDLE_SIGNATURE=1 PYTHONWARNDEFAULTENCODING=true "${CURRENT_ENV[@]}" \
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
   bash -e $ACTIONS_RUNNER_HOOK_JOB_COMPLETED 70929241273 passed
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
