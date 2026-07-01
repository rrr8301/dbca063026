#!/usr/bin/env bash
export GITHUB_WORKSPACE=/home/github/build/python/mypy

if [[ ! -z "$ACTIONS_RUNNER_HOOK_JOB_STARTED" ]]; then
   echo "A job started hook has been configured by the self-hosted runner administrator"
   echo "##[group]Run '$ACTIONS_RUNNER_HOOK_JOB_STARTED'"
   echo "##[endgroup]"
   bash -e $ACTIONS_RUNNER_HOOK_JOB_STARTED 72684881953 passed
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

cp /home/github/72684881953/event.json /home/github/workflow/event.json
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=1 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=ilevkivskyi GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=python/mypy GITHUB_REPOSITORY_OWNER=python GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=3b2b1dda51ddc43d4f81be7877ba3b0e3908f0da GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Tests GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 TOX_SKIP_MISSING_INTERPRETERS=false VIRTUALENV_SYSTEM_SITE_PACKAGES="$(/home/github/72684881953/helpers/eval_expression p:'(' s:'' o:'&&' n:1 p:')' o:'||' n:0)" FORCE_COLOR="$(/home/github/72684881953/helpers/eval_expression p:'(' p:'(' o:'!' p:'(' p:'(' f:startsWith p:'(' s:ubuntu-24.04-arm s:windows- p:')' p:')' o:'&&' p:'(' f:startsWith p:'(' s:py s:py p:')' p:')' p:')' p:')' o:'&&' n:1 p:')' o:'||' n:0)" PY_COLORS=1 PYTHON_COLORS=0 TERM=xterm-color MYPY_FORCE_COLOR=1 MYPY_FORCE_TERMINAL_WIDTH=200 PYTEST_ADDOPTS=--color=yes "${CURRENT_ENV[@]}" \
echo "$(/home/github/72684881953/helpers/eval_expression p:'(' f:success p:'(' p:')' p:')' o:'&&' p:'(' f:endsWith p:'(' s:3.11 s:-dev p:')' p:')')")
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=1 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=ilevkivskyi GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=python/mypy GITHUB_REPOSITORY_OWNER=python GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=3b2b1dda51ddc43d4f81be7877ba3b0e3908f0da GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Tests GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 TOX_SKIP_MISSING_INTERPRETERS=false VIRTUALENV_SYSTEM_SITE_PACKAGES="$(/home/github/72684881953/helpers/eval_expression p:'(' s:'' o:'&&' n:1 p:')' o:'||' n:0)" FORCE_COLOR="$(/home/github/72684881953/helpers/eval_expression p:'(' p:'(' o:'!' p:'(' p:'(' f:startsWith p:'(' s:ubuntu-24.04-arm s:windows- p:')' p:')' o:'&&' p:'(' f:startsWith p:'(' s:py s:py p:')' p:')' p:')' p:')' o:'&&' n:1 p:')' o:'||' n:0)" PY_COLORS=1 PYTHON_COLORS=0 TERM=xterm-color MYPY_FORCE_COLOR=1 MYPY_FORCE_TERMINAL_WIDTH=200 PYTEST_ADDOPTS=--color=yes "${CURRENT_ENV[@]}" \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run 'git clone --depth 1 https://github.com/python/cpython.git /tmp/cpython --branch $( echo 3.11 | sed '"'"'s/-dev//'"'"' )'
echo "##[endgroup]"
echo 'git clone --depth 1 https://github.com/python/cpython.git /tmp/cpython --branch $( echo 3.11 | sed '"'"'s/-dev//'"'"' )
cd /tmp/cpython
echo git rev-parse HEAD; git rev-parse HEAD
git show --no-patch
sudo apt-get update -q
sudo apt-get install -q -y --no-install-recommends \
  build-essential gdb lcov libbz2-dev libffi-dev libgdbm-dev liblzma-dev libncurses5-dev \
  libreadline6-dev libsqlite3-dev libssl-dev lzma lzma-dev tk-dev uuid-dev zlib1g-dev
./configure --prefix=/opt/pythondev
make -j$(nproc)
sudo make install
sudo ln -s /opt/pythondev/bin/python3 /opt/pythondev/bin/python
sudo ln -s /opt/pythondev/bin/pip3 /opt/pythondev/bin/pip
echo "/opt/pythondev/bin" >> $GITHUB_PATH
' > /home/github/72684881953/steps/bugswarm_1.sh
chmod u+x /home/github/72684881953/steps/bugswarm_1.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=1 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=ilevkivskyi GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=python/mypy GITHUB_REPOSITORY_OWNER=python GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=3b2b1dda51ddc43d4f81be7877ba3b0e3908f0da GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Tests GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 TOX_SKIP_MISSING_INTERPRETERS=false VIRTUALENV_SYSTEM_SITE_PACKAGES="$(/home/github/72684881953/helpers/eval_expression p:'(' s:'' o:'&&' n:1 p:')' o:'||' n:0)" FORCE_COLOR="$(/home/github/72684881953/helpers/eval_expression p:'(' p:'(' o:'!' p:'(' p:'(' f:startsWith p:'(' s:ubuntu-24.04-arm s:windows- p:')' p:')' o:'&&' p:'(' f:startsWith p:'(' s:py s:py p:')' p:')' p:')' p:')' o:'&&' n:1 p:')' o:'||' n:0)" PY_COLORS=1 PYTHON_COLORS=0 TERM=xterm-color MYPY_FORCE_COLOR=1 MYPY_FORCE_TERMINAL_WIDTH=200 PYTEST_ADDOPTS=--color=yes "${CURRENT_ENV[@]}" \
bash -e /home/github/72684881953/steps/bugswarm_1.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=1 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=ilevkivskyi GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=python/mypy GITHUB_REPOSITORY_OWNER=python GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=3b2b1dda51ddc43d4f81be7877ba3b0e3908f0da GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Tests GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 TOX_SKIP_MISSING_INTERPRETERS=false VIRTUALENV_SYSTEM_SITE_PACKAGES="$(/home/github/72684881953/helpers/eval_expression p:'(' s:'' o:'&&' n:1 p:')' o:'||' n:0)" FORCE_COLOR="$(/home/github/72684881953/helpers/eval_expression p:'(' p:'(' o:'!' p:'(' p:'(' f:startsWith p:'(' s:ubuntu-24.04-arm s:windows- p:')' p:')' o:'&&' p:'(' f:startsWith p:'(' s:py s:py p:')' p:')' p:')' p:')' o:'&&' n:1 p:')' o:'||' n:0)" PY_COLORS=1 PYTHON_COLORS=0 TERM=xterm-color MYPY_FORCE_COLOR=1 MYPY_FORCE_TERMINAL_WIDTH=200 PYTEST_ADDOPTS=--color=yes "${CURRENT_ENV[@]}" \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=1 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=ilevkivskyi GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=python/mypy GITHUB_REPOSITORY_OWNER=python GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=3b2b1dda51ddc43d4f81be7877ba3b0e3908f0da GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Tests GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 TOX_SKIP_MISSING_INTERPRETERS=false VIRTUALENV_SYSTEM_SITE_PACKAGES="$(/home/github/72684881953/helpers/eval_expression p:'(' s:'' o:'&&' n:1 p:')' o:'||' n:0)" FORCE_COLOR="$(/home/github/72684881953/helpers/eval_expression p:'(' p:'(' o:'!' p:'(' p:'(' f:startsWith p:'(' s:ubuntu-24.04-arm s:windows- p:')' p:')' o:'&&' p:'(' f:startsWith p:'(' s:py s:py p:')' p:')' p:')' p:')' o:'&&' n:1 p:')' o:'||' n:0)" PY_COLORS=1 PYTHON_COLORS=0 TERM=xterm-color MYPY_FORCE_COLOR=1 MYPY_FORCE_TERMINAL_WIDTH=200 PYTEST_ADDOPTS=--color=yes "${CURRENT_ENV[@]}" \
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=2 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=ilevkivskyi GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=python/mypy GITHUB_REPOSITORY_OWNER=python GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=3b2b1dda51ddc43d4f81be7877ba3b0e3908f0da GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Tests GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 TOX_SKIP_MISSING_INTERPRETERS=false VIRTUALENV_SYSTEM_SITE_PACKAGES="$(/home/github/72684881953/helpers/eval_expression p:'(' s:'' o:'&&' n:1 p:')' o:'||' n:0)" FORCE_COLOR="$(/home/github/72684881953/helpers/eval_expression p:'(' p:'(' o:'!' p:'(' p:'(' f:startsWith p:'(' s:ubuntu-24.04-arm s:windows- p:')' p:')' o:'&&' p:'(' f:startsWith p:'(' s:py s:py p:')' p:')' p:')' p:')' o:'&&' n:1 p:')' o:'||' n:0)" PY_COLORS=1 PYTHON_COLORS=0 TERM=xterm-color MYPY_FORCE_COLOR=1 MYPY_FORCE_TERMINAL_WIDTH=200 PYTEST_ADDOPTS=--color=yes "${CURRENT_ENV[@]}" \
echo "$(/home/github/72684881953/helpers/eval_expression p:'(' f:success p:'(' p:')' p:')' o:'&&' s:'')")
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=2 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=ilevkivskyi GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=python/mypy GITHUB_REPOSITORY_OWNER=python GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=3b2b1dda51ddc43d4f81be7877ba3b0e3908f0da GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Tests GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 TOX_SKIP_MISSING_INTERPRETERS=false VIRTUALENV_SYSTEM_SITE_PACKAGES="$(/home/github/72684881953/helpers/eval_expression p:'(' s:'' o:'&&' n:1 p:')' o:'||' n:0)" FORCE_COLOR="$(/home/github/72684881953/helpers/eval_expression p:'(' p:'(' o:'!' p:'(' p:'(' f:startsWith p:'(' s:ubuntu-24.04-arm s:windows- p:')' p:')' o:'&&' p:'(' f:startsWith p:'(' s:py s:py p:')' p:')' p:')' p:')' o:'&&' n:1 p:')' o:'||' n:0)" PY_COLORS=1 PYTHON_COLORS=0 TERM=xterm-color MYPY_FORCE_COLOR=1 MYPY_FORCE_TERMINAL_WIDTH=200 PYTEST_ADDOPTS=--color=yes "${CURRENT_ENV[@]}" \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run 'git clone --depth 1 https://github.com/python/cpython.git /tmp/cpython --branch 3.11'
echo "##[endgroup]"
echo 'git clone --depth 1 https://github.com/python/cpython.git /tmp/cpython --branch 3.11
cd /tmp/cpython
echo git rev-parse HEAD; git rev-parse HEAD
git show --no-patch
sudo apt-get update -q
sudo apt-get install -q -y --no-install-recommends \
  build-essential gdb lcov libbz2-dev libffi-dev libgdbm-dev liblzma-dev libncurses5-dev \
  libreadline6-dev libsqlite3-dev libssl-dev lzma lzma-dev tk-dev uuid-dev zlib1g-dev
./configure CFLAGS="-DPy_DEBUG -DPy_TRACE_REFS -DPYMALLOC_DEBUG" --with-pydebug -with-trace-refs --prefix=/opt/pythondev
make -j$(nproc)
sudo make install
sudo ln -s /opt/pythondev/bin/python3 /opt/pythondev/bin/python
sudo ln -s /opt/pythondev/bin/pip3 /opt/pythondev/bin/pip
echo "/opt/pythondev/bin" >> $GITHUB_PATH
' > /home/github/72684881953/steps/bugswarm_2.sh
chmod u+x /home/github/72684881953/steps/bugswarm_2.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=2 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=ilevkivskyi GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=python/mypy GITHUB_REPOSITORY_OWNER=python GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=3b2b1dda51ddc43d4f81be7877ba3b0e3908f0da GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Tests GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 TOX_SKIP_MISSING_INTERPRETERS=false VIRTUALENV_SYSTEM_SITE_PACKAGES="$(/home/github/72684881953/helpers/eval_expression p:'(' s:'' o:'&&' n:1 p:')' o:'||' n:0)" FORCE_COLOR="$(/home/github/72684881953/helpers/eval_expression p:'(' p:'(' o:'!' p:'(' p:'(' f:startsWith p:'(' s:ubuntu-24.04-arm s:windows- p:')' p:')' o:'&&' p:'(' f:startsWith p:'(' s:py s:py p:')' p:')' p:')' p:')' o:'&&' n:1 p:')' o:'||' n:0)" PY_COLORS=1 PYTHON_COLORS=0 TERM=xterm-color MYPY_FORCE_COLOR=1 MYPY_FORCE_TERMINAL_WIDTH=200 PYTEST_ADDOPTS=--color=yes "${CURRENT_ENV[@]}" \
bash -e /home/github/72684881953/steps/bugswarm_2.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=2 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=ilevkivskyi GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=python/mypy GITHUB_REPOSITORY_OWNER=python GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=3b2b1dda51ddc43d4f81be7877ba3b0e3908f0da GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Tests GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 TOX_SKIP_MISSING_INTERPRETERS=false VIRTUALENV_SYSTEM_SITE_PACKAGES="$(/home/github/72684881953/helpers/eval_expression p:'(' s:'' o:'&&' n:1 p:')' o:'||' n:0)" FORCE_COLOR="$(/home/github/72684881953/helpers/eval_expression p:'(' p:'(' o:'!' p:'(' p:'(' f:startsWith p:'(' s:ubuntu-24.04-arm s:windows- p:')' p:')' o:'&&' p:'(' f:startsWith p:'(' s:py s:py p:')' p:')' p:')' p:')' o:'&&' n:1 p:')' o:'||' n:0)" PY_COLORS=1 PYTHON_COLORS=0 TERM=xterm-color MYPY_FORCE_COLOR=1 MYPY_FORCE_TERMINAL_WIDTH=200 PYTEST_ADDOPTS=--color=yes "${CURRENT_ENV[@]}" \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=2 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=ilevkivskyi GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=python/mypy GITHUB_REPOSITORY_OWNER=python GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=3b2b1dda51ddc43d4f81be7877ba3b0e3908f0da GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Tests GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 TOX_SKIP_MISSING_INTERPRETERS=false VIRTUALENV_SYSTEM_SITE_PACKAGES="$(/home/github/72684881953/helpers/eval_expression p:'(' s:'' o:'&&' n:1 p:')' o:'||' n:0)" FORCE_COLOR="$(/home/github/72684881953/helpers/eval_expression p:'(' p:'(' o:'!' p:'(' p:'(' f:startsWith p:'(' s:ubuntu-24.04-arm s:windows- p:')' p:')' o:'&&' p:'(' f:startsWith p:'(' s:py s:py p:')' p:')' p:')' p:')' o:'&&' n:1 p:')' o:'||' n:0)" PY_COLORS=1 PYTHON_COLORS=0 TERM=xterm-color MYPY_FORCE_COLOR=1 MYPY_FORCE_TERMINAL_WIDTH=200 PYTEST_ADDOPTS=--color=yes "${CURRENT_ENV[@]}" \
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=3 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=actions/setup-python GITHUB_ACTIONS=true GITHUB_ACTOR=ilevkivskyi GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=python/mypy GITHUB_REPOSITORY_OWNER=python GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=3b2b1dda51ddc43d4f81be7877ba3b0e3908f0da GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Tests GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 GITHUB_ACTION_PATH=/home/github/72684881953/actions/actions-setup-python@v5 TOX_SKIP_MISSING_INTERPRETERS=false VIRTUALENV_SYSTEM_SITE_PACKAGES="$(/home/github/72684881953/helpers/eval_expression p:'(' s:'' o:'&&' n:1 p:')' o:'||' n:0)" FORCE_COLOR="$(/home/github/72684881953/helpers/eval_expression p:'(' p:'(' o:'!' p:'(' p:'(' f:startsWith p:'(' s:ubuntu-24.04-arm s:windows- p:')' p:')' o:'&&' p:'(' f:startsWith p:'(' s:py s:py p:')' p:')' p:')' p:')' o:'&&' n:1 p:')' o:'||' n:0)" PY_COLORS=1 PYTHON_COLORS=0 TERM=xterm-color MYPY_FORCE_COLOR=1 MYPY_FORCE_TERMINAL_WIDTH=200 PYTEST_ADDOPTS=--color=yes "${CURRENT_ENV[@]}" INPUT_PYTHON-VERSION=3.11 INPUT_TOKEN= INPUT_CHECK-LATEST=false INPUT_UPDATE-ENVIRONMENT=true INPUT_ALLOW-PRERELEASES=false INPUT_FREETHREADED=false \
echo "$(/home/github/72684881953/helpers/eval_expression p:'(' f:success p:'(' p:')' p:')' o:'&&' p:'(' o:'!' p:'(' s:'' o:'||' p:'(' f:endsWith p:'(' s:3.11 s:-dev p:')' p:')' p:')' p:')')")
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=3 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=actions/setup-python GITHUB_ACTIONS=true GITHUB_ACTOR=ilevkivskyi GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=python/mypy GITHUB_REPOSITORY_OWNER=python GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=3b2b1dda51ddc43d4f81be7877ba3b0e3908f0da GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Tests GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 GITHUB_ACTION_PATH=/home/github/72684881953/actions/actions-setup-python@v5 TOX_SKIP_MISSING_INTERPRETERS=false VIRTUALENV_SYSTEM_SITE_PACKAGES="$(/home/github/72684881953/helpers/eval_expression p:'(' s:'' o:'&&' n:1 p:')' o:'||' n:0)" FORCE_COLOR="$(/home/github/72684881953/helpers/eval_expression p:'(' p:'(' o:'!' p:'(' p:'(' f:startsWith p:'(' s:ubuntu-24.04-arm s:windows- p:')' p:')' o:'&&' p:'(' f:startsWith p:'(' s:py s:py p:')' p:')' p:')' p:')' o:'&&' n:1 p:')' o:'||' n:0)" PY_COLORS=1 PYTHON_COLORS=0 TERM=xterm-color MYPY_FORCE_COLOR=1 MYPY_FORCE_TERMINAL_WIDTH=200 PYTEST_ADDOPTS=--color=yes "${CURRENT_ENV[@]}" INPUT_PYTHON-VERSION=3.11 INPUT_TOKEN= INPUT_CHECK-LATEST=false INPUT_UPDATE-ENVIRONMENT=true INPUT_ALLOW-PRERELEASES=false INPUT_FREETHREADED=false \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run actions/setup-python@v5
echo "##[endgroup]"
echo node /home/github/72684881953/actions/actions-setup-python@v5/dist/setup/index.js > /home/github/72684881953/steps/bugswarm_cmd.sh
chmod u+x /home/github/72684881953/steps/bugswarm_cmd.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=3 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=actions/setup-python GITHUB_ACTIONS=true GITHUB_ACTOR=ilevkivskyi GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=python/mypy GITHUB_REPOSITORY_OWNER=python GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=3b2b1dda51ddc43d4f81be7877ba3b0e3908f0da GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Tests GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 GITHUB_ACTION_PATH=/home/github/72684881953/actions/actions-setup-python@v5 TOX_SKIP_MISSING_INTERPRETERS=false VIRTUALENV_SYSTEM_SITE_PACKAGES="$(/home/github/72684881953/helpers/eval_expression p:'(' s:'' o:'&&' n:1 p:')' o:'||' n:0)" FORCE_COLOR="$(/home/github/72684881953/helpers/eval_expression p:'(' p:'(' o:'!' p:'(' p:'(' f:startsWith p:'(' s:ubuntu-24.04-arm s:windows- p:')' p:')' o:'&&' p:'(' f:startsWith p:'(' s:py s:py p:')' p:')' p:')' p:')' o:'&&' n:1 p:')' o:'||' n:0)" PY_COLORS=1 PYTHON_COLORS=0 TERM=xterm-color MYPY_FORCE_COLOR=1 MYPY_FORCE_TERMINAL_WIDTH=200 PYTEST_ADDOPTS=--color=yes "${CURRENT_ENV[@]}" INPUT_PYTHON-VERSION=3.11 INPUT_TOKEN= INPUT_CHECK-LATEST=false INPUT_UPDATE-ENVIRONMENT=true INPUT_ALLOW-PRERELEASES=false INPUT_FREETHREADED=false \
bash -e /home/github/72684881953/steps/bugswarm_cmd.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=3 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=actions/setup-python GITHUB_ACTIONS=true GITHUB_ACTOR=ilevkivskyi GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=python/mypy GITHUB_REPOSITORY_OWNER=python GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=3b2b1dda51ddc43d4f81be7877ba3b0e3908f0da GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Tests GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 GITHUB_ACTION_PATH=/home/github/72684881953/actions/actions-setup-python@v5 TOX_SKIP_MISSING_INTERPRETERS=false VIRTUALENV_SYSTEM_SITE_PACKAGES="$(/home/github/72684881953/helpers/eval_expression p:'(' s:'' o:'&&' n:1 p:')' o:'||' n:0)" FORCE_COLOR="$(/home/github/72684881953/helpers/eval_expression p:'(' p:'(' o:'!' p:'(' p:'(' f:startsWith p:'(' s:ubuntu-24.04-arm s:windows- p:')' p:')' o:'&&' p:'(' f:startsWith p:'(' s:py s:py p:')' p:')' p:')' p:')' o:'&&' n:1 p:')' o:'||' n:0)" PY_COLORS=1 PYTHON_COLORS=0 TERM=xterm-color MYPY_FORCE_COLOR=1 MYPY_FORCE_TERMINAL_WIDTH=200 PYTEST_ADDOPTS=--color=yes "${CURRENT_ENV[@]}" INPUT_PYTHON-VERSION=3.11 INPUT_TOKEN= INPUT_CHECK-LATEST=false INPUT_UPDATE-ENVIRONMENT=true INPUT_ALLOW-PRERELEASES=false INPUT_FREETHREADED=false \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=3 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=actions/setup-python GITHUB_ACTIONS=true GITHUB_ACTOR=ilevkivskyi GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=python/mypy GITHUB_REPOSITORY_OWNER=python GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=3b2b1dda51ddc43d4f81be7877ba3b0e3908f0da GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Tests GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 GITHUB_ACTION_PATH=/home/github/72684881953/actions/actions-setup-python@v5 TOX_SKIP_MISSING_INTERPRETERS=false VIRTUALENV_SYSTEM_SITE_PACKAGES="$(/home/github/72684881953/helpers/eval_expression p:'(' s:'' o:'&&' n:1 p:')' o:'||' n:0)" FORCE_COLOR="$(/home/github/72684881953/helpers/eval_expression p:'(' p:'(' o:'!' p:'(' p:'(' f:startsWith p:'(' s:ubuntu-24.04-arm s:windows- p:')' p:')' o:'&&' p:'(' f:startsWith p:'(' s:py s:py p:')' p:')' p:')' p:')' o:'&&' n:1 p:')' o:'||' n:0)" PY_COLORS=1 PYTHON_COLORS=0 TERM=xterm-color MYPY_FORCE_COLOR=1 MYPY_FORCE_TERMINAL_WIDTH=200 PYTEST_ADDOPTS=--color=yes "${CURRENT_ENV[@]}" INPUT_PYTHON-VERSION=3.11 INPUT_TOKEN= INPUT_CHECK-LATEST=false INPUT_UPDATE-ENVIRONMENT=true INPUT_ALLOW-PRERELEASES=false INPUT_FREETHREADED=false \
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=4 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=ilevkivskyi GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=python/mypy GITHUB_REPOSITORY_OWNER=python GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=3b2b1dda51ddc43d4f81be7877ba3b0e3908f0da GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Tests GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 TOX_SKIP_MISSING_INTERPRETERS=false VIRTUALENV_SYSTEM_SITE_PACKAGES="$(/home/github/72684881953/helpers/eval_expression p:'(' s:'' o:'&&' n:1 p:')' o:'||' n:0)" FORCE_COLOR="$(/home/github/72684881953/helpers/eval_expression p:'(' p:'(' o:'!' p:'(' p:'(' f:startsWith p:'(' s:ubuntu-24.04-arm s:windows- p:')' p:')' o:'&&' p:'(' f:startsWith p:'(' s:py s:py p:')' p:')' p:')' p:')' o:'&&' n:1 p:')' o:'||' n:0)" PY_COLORS=1 PYTHON_COLORS=0 TERM=xterm-color MYPY_FORCE_COLOR=1 MYPY_FORCE_TERMINAL_WIDTH=200 PYTEST_ADDOPTS=--color=yes "${CURRENT_ENV[@]}" \
echo $(test "$_GITHUB_JOB_STATUS" = "success" && echo true || echo false))
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=4 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=ilevkivskyi GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=python/mypy GITHUB_REPOSITORY_OWNER=python GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=3b2b1dda51ddc43d4f81be7877ba3b0e3908f0da GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Tests GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 TOX_SKIP_MISSING_INTERPRETERS=false VIRTUALENV_SYSTEM_SITE_PACKAGES="$(/home/github/72684881953/helpers/eval_expression p:'(' s:'' o:'&&' n:1 p:')' o:'||' n:0)" FORCE_COLOR="$(/home/github/72684881953/helpers/eval_expression p:'(' p:'(' o:'!' p:'(' p:'(' f:startsWith p:'(' s:ubuntu-24.04-arm s:windows- p:')' p:')' o:'&&' p:'(' f:startsWith p:'(' s:py s:py p:')' p:')' p:')' p:')' o:'&&' n:1 p:')' o:'||' n:0)" PY_COLORS=1 PYTHON_COLORS=0 TERM=xterm-color MYPY_FORCE_COLOR=1 MYPY_FORCE_TERMINAL_WIDTH=200 PYTEST_ADDOPTS=--color=yes "${CURRENT_ENV[@]}" \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run 'echo PATH; echo $PATH'
echo "##[endgroup]"
echo 'echo PATH; echo $PATH
echo which python; which python
echo which pip; which pip
echo python version; python -c '"'"'import sys; print(sys.version)'"'"'
echo debug build; python -c '"'"'import sysconfig; print(bool(sysconfig.get_config_var("Py_DEBUG")))'"'"'
echo os.cpu_count; python -c '"'"'import os; print(os.cpu_count())'"'"'
echo os.sched_getaffinity; python -c '"'"'import os; print(len(getattr(os, "sched_getaffinity", lambda *args: [])(0)))'"'"'
pip install tox==4.26.0
' > /home/github/72684881953/steps/bugswarm_4.sh
chmod u+x /home/github/72684881953/steps/bugswarm_4.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=4 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=ilevkivskyi GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=python/mypy GITHUB_REPOSITORY_OWNER=python GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=3b2b1dda51ddc43d4f81be7877ba3b0e3908f0da GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Tests GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 TOX_SKIP_MISSING_INTERPRETERS=false VIRTUALENV_SYSTEM_SITE_PACKAGES="$(/home/github/72684881953/helpers/eval_expression p:'(' s:'' o:'&&' n:1 p:')' o:'||' n:0)" FORCE_COLOR="$(/home/github/72684881953/helpers/eval_expression p:'(' p:'(' o:'!' p:'(' p:'(' f:startsWith p:'(' s:ubuntu-24.04-arm s:windows- p:')' p:')' o:'&&' p:'(' f:startsWith p:'(' s:py s:py p:')' p:')' p:')' p:')' o:'&&' n:1 p:')' o:'||' n:0)" PY_COLORS=1 PYTHON_COLORS=0 TERM=xterm-color MYPY_FORCE_COLOR=1 MYPY_FORCE_TERMINAL_WIDTH=200 PYTEST_ADDOPTS=--color=yes "${CURRENT_ENV[@]}" \
bash -e /home/github/72684881953/steps/bugswarm_4.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=4 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=ilevkivskyi GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=python/mypy GITHUB_REPOSITORY_OWNER=python GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=3b2b1dda51ddc43d4f81be7877ba3b0e3908f0da GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Tests GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 TOX_SKIP_MISSING_INTERPRETERS=false VIRTUALENV_SYSTEM_SITE_PACKAGES="$(/home/github/72684881953/helpers/eval_expression p:'(' s:'' o:'&&' n:1 p:')' o:'||' n:0)" FORCE_COLOR="$(/home/github/72684881953/helpers/eval_expression p:'(' p:'(' o:'!' p:'(' p:'(' f:startsWith p:'(' s:ubuntu-24.04-arm s:windows- p:')' p:')' o:'&&' p:'(' f:startsWith p:'(' s:py s:py p:')' p:')' p:')' p:')' o:'&&' n:1 p:')' o:'||' n:0)" PY_COLORS=1 PYTHON_COLORS=0 TERM=xterm-color MYPY_FORCE_COLOR=1 MYPY_FORCE_TERMINAL_WIDTH=200 PYTEST_ADDOPTS=--color=yes "${CURRENT_ENV[@]}" \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=4 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=ilevkivskyi GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=python/mypy GITHUB_REPOSITORY_OWNER=python GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=3b2b1dda51ddc43d4f81be7877ba3b0e3908f0da GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Tests GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 TOX_SKIP_MISSING_INTERPRETERS=false VIRTUALENV_SYSTEM_SITE_PACKAGES="$(/home/github/72684881953/helpers/eval_expression p:'(' s:'' o:'&&' n:1 p:')' o:'||' n:0)" FORCE_COLOR="$(/home/github/72684881953/helpers/eval_expression p:'(' p:'(' o:'!' p:'(' p:'(' f:startsWith p:'(' s:ubuntu-24.04-arm s:windows- p:')' p:')' o:'&&' p:'(' f:startsWith p:'(' s:py s:py p:')' p:')' p:')' p:')' o:'&&' n:1 p:')' o:'||' n:0)" PY_COLORS=1 PYTHON_COLORS=0 TERM=xterm-color MYPY_FORCE_COLOR=1 MYPY_FORCE_TERMINAL_WIDTH=200 PYTEST_ADDOPTS=--color=yes "${CURRENT_ENV[@]}" \
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=5 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=ilevkivskyi GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=python/mypy GITHUB_REPOSITORY_OWNER=python GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=3b2b1dda51ddc43d4f81be7877ba3b0e3908f0da GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Tests GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 TOX_SKIP_MISSING_INTERPRETERS=false VIRTUALENV_SYSTEM_SITE_PACKAGES="$(/home/github/72684881953/helpers/eval_expression p:'(' s:'' o:'&&' n:1 p:')' o:'||' n:0)" FORCE_COLOR="$(/home/github/72684881953/helpers/eval_expression p:'(' p:'(' o:'!' p:'(' p:'(' f:startsWith p:'(' s:ubuntu-24.04-arm s:windows- p:')' p:')' o:'&&' p:'(' f:startsWith p:'(' s:py s:py p:')' p:')' p:')' p:')' o:'&&' n:1 p:')' o:'||' n:0)" PY_COLORS=1 PYTHON_COLORS=0 TERM=xterm-color MYPY_FORCE_COLOR=1 MYPY_FORCE_TERMINAL_WIDTH=200 PYTEST_ADDOPTS=--color=yes "${CURRENT_ENV[@]}" \
echo "$(/home/github/72684881953/helpers/eval_expression p:'(' f:success p:'(' p:')' p:')' o:'&&' s:'')")
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=5 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=ilevkivskyi GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=python/mypy GITHUB_REPOSITORY_OWNER=python GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=3b2b1dda51ddc43d4f81be7877ba3b0e3908f0da GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Tests GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 TOX_SKIP_MISSING_INTERPRETERS=false VIRTUALENV_SYSTEM_SITE_PACKAGES="$(/home/github/72684881953/helpers/eval_expression p:'(' s:'' o:'&&' n:1 p:')' o:'||' n:0)" FORCE_COLOR="$(/home/github/72684881953/helpers/eval_expression p:'(' p:'(' o:'!' p:'(' p:'(' f:startsWith p:'(' s:ubuntu-24.04-arm s:windows- p:')' p:')' o:'&&' p:'(' f:startsWith p:'(' s:py s:py p:')' p:')' p:')' p:')' o:'&&' n:1 p:')' o:'||' n:0)" PY_COLORS=1 PYTHON_COLORS=0 TERM=xterm-color MYPY_FORCE_COLOR=1 MYPY_FORCE_TERMINAL_WIDTH=200 PYTEST_ADDOPTS=--color=yes "${CURRENT_ENV[@]}" \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run 'pip install -r test-requirements.txt'
echo "##[endgroup]"
echo 'pip install -r test-requirements.txt
pip install -U mypyc/lib-rt
CC=clang MYPYC_OPT_LEVEL=0 MYPY_USE_MYPYC=1 pip install -e .
' > /home/github/72684881953/steps/bugswarm_5.sh
chmod u+x /home/github/72684881953/steps/bugswarm_5.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=5 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=ilevkivskyi GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=python/mypy GITHUB_REPOSITORY_OWNER=python GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=3b2b1dda51ddc43d4f81be7877ba3b0e3908f0da GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Tests GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 TOX_SKIP_MISSING_INTERPRETERS=false VIRTUALENV_SYSTEM_SITE_PACKAGES="$(/home/github/72684881953/helpers/eval_expression p:'(' s:'' o:'&&' n:1 p:')' o:'||' n:0)" FORCE_COLOR="$(/home/github/72684881953/helpers/eval_expression p:'(' p:'(' o:'!' p:'(' p:'(' f:startsWith p:'(' s:ubuntu-24.04-arm s:windows- p:')' p:')' o:'&&' p:'(' f:startsWith p:'(' s:py s:py p:')' p:')' p:')' p:')' o:'&&' n:1 p:')' o:'||' n:0)" PY_COLORS=1 PYTHON_COLORS=0 TERM=xterm-color MYPY_FORCE_COLOR=1 MYPY_FORCE_TERMINAL_WIDTH=200 PYTEST_ADDOPTS=--color=yes "${CURRENT_ENV[@]}" \
bash -e /home/github/72684881953/steps/bugswarm_5.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=5 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=ilevkivskyi GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=python/mypy GITHUB_REPOSITORY_OWNER=python GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=3b2b1dda51ddc43d4f81be7877ba3b0e3908f0da GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Tests GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 TOX_SKIP_MISSING_INTERPRETERS=false VIRTUALENV_SYSTEM_SITE_PACKAGES="$(/home/github/72684881953/helpers/eval_expression p:'(' s:'' o:'&&' n:1 p:')' o:'||' n:0)" FORCE_COLOR="$(/home/github/72684881953/helpers/eval_expression p:'(' p:'(' o:'!' p:'(' p:'(' f:startsWith p:'(' s:ubuntu-24.04-arm s:windows- p:')' p:')' o:'&&' p:'(' f:startsWith p:'(' s:py s:py p:')' p:')' p:')' p:')' o:'&&' n:1 p:')' o:'||' n:0)" PY_COLORS=1 PYTHON_COLORS=0 TERM=xterm-color MYPY_FORCE_COLOR=1 MYPY_FORCE_TERMINAL_WIDTH=200 PYTEST_ADDOPTS=--color=yes "${CURRENT_ENV[@]}" \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=5 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=ilevkivskyi GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=python/mypy GITHUB_REPOSITORY_OWNER=python GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=3b2b1dda51ddc43d4f81be7877ba3b0e3908f0da GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Tests GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 TOX_SKIP_MISSING_INTERPRETERS=false VIRTUALENV_SYSTEM_SITE_PACKAGES="$(/home/github/72684881953/helpers/eval_expression p:'(' s:'' o:'&&' n:1 p:')' o:'||' n:0)" FORCE_COLOR="$(/home/github/72684881953/helpers/eval_expression p:'(' p:'(' o:'!' p:'(' p:'(' f:startsWith p:'(' s:ubuntu-24.04-arm s:windows- p:')' p:')' o:'&&' p:'(' f:startsWith p:'(' s:py s:py p:')' p:')' p:')' p:')' o:'&&' n:1 p:')' o:'||' n:0)" PY_COLORS=1 PYTHON_COLORS=0 TERM=xterm-color MYPY_FORCE_COLOR=1 MYPY_FORCE_TERMINAL_WIDTH=200 PYTEST_ADDOPTS=--color=yes "${CURRENT_ENV[@]}" \
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=6 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=ilevkivskyi GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=python/mypy GITHUB_REPOSITORY_OWNER=python GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=3b2b1dda51ddc43d4f81be7877ba3b0e3908f0da GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Tests GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 TOX_SKIP_MISSING_INTERPRETERS=false VIRTUALENV_SYSTEM_SITE_PACKAGES="$(/home/github/72684881953/helpers/eval_expression p:'(' s:'' o:'&&' n:1 p:')' o:'||' n:0)" FORCE_COLOR="$(/home/github/72684881953/helpers/eval_expression p:'(' p:'(' o:'!' p:'(' p:'(' f:startsWith p:'(' s:ubuntu-24.04-arm s:windows- p:')' p:')' o:'&&' p:'(' f:startsWith p:'(' s:py s:py p:')' p:')' p:')' p:')' o:'&&' n:1 p:')' o:'||' n:0)" PY_COLORS=1 PYTHON_COLORS=0 TERM=xterm-color MYPY_FORCE_COLOR=1 MYPY_FORCE_TERMINAL_WIDTH=200 PYTEST_ADDOPTS=--color=yes "${CURRENT_ENV[@]}" \
echo $(test "$_GITHUB_JOB_STATUS" = "success" && echo true || echo false))
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=6 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=ilevkivskyi GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=python/mypy GITHUB_REPOSITORY_OWNER=python GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=3b2b1dda51ddc43d4f81be7877ba3b0e3908f0da GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Tests GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 TOX_SKIP_MISSING_INTERPRETERS=false VIRTUALENV_SYSTEM_SITE_PACKAGES="$(/home/github/72684881953/helpers/eval_expression p:'(' s:'' o:'&&' n:1 p:')' o:'||' n:0)" FORCE_COLOR="$(/home/github/72684881953/helpers/eval_expression p:'(' p:'(' o:'!' p:'(' p:'(' f:startsWith p:'(' s:ubuntu-24.04-arm s:windows- p:')' p:')' o:'&&' p:'(' f:startsWith p:'(' s:py s:py p:')' p:')' p:')' p:')' o:'&&' n:1 p:')' o:'||' n:0)" PY_COLORS=1 PYTHON_COLORS=0 TERM=xterm-color MYPY_FORCE_COLOR=1 MYPY_FORCE_TERMINAL_WIDTH=200 PYTEST_ADDOPTS=--color=yes "${CURRENT_ENV[@]}" \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run 'tox run -e py --notest'
echo "##[endgroup]"
echo 'tox run -e py --notest
' > /home/github/72684881953/steps/bugswarm_6.sh
chmod u+x /home/github/72684881953/steps/bugswarm_6.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=6 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=ilevkivskyi GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=python/mypy GITHUB_REPOSITORY_OWNER=python GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=3b2b1dda51ddc43d4f81be7877ba3b0e3908f0da GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Tests GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 TOX_SKIP_MISSING_INTERPRETERS=false VIRTUALENV_SYSTEM_SITE_PACKAGES="$(/home/github/72684881953/helpers/eval_expression p:'(' s:'' o:'&&' n:1 p:')' o:'||' n:0)" FORCE_COLOR="$(/home/github/72684881953/helpers/eval_expression p:'(' p:'(' o:'!' p:'(' p:'(' f:startsWith p:'(' s:ubuntu-24.04-arm s:windows- p:')' p:')' o:'&&' p:'(' f:startsWith p:'(' s:py s:py p:')' p:')' p:')' p:')' o:'&&' n:1 p:')' o:'||' n:0)" PY_COLORS=1 PYTHON_COLORS=0 TERM=xterm-color MYPY_FORCE_COLOR=1 MYPY_FORCE_TERMINAL_WIDTH=200 PYTEST_ADDOPTS=--color=yes "${CURRENT_ENV[@]}" \
bash -e /home/github/72684881953/steps/bugswarm_6.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=6 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=ilevkivskyi GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=python/mypy GITHUB_REPOSITORY_OWNER=python GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=3b2b1dda51ddc43d4f81be7877ba3b0e3908f0da GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Tests GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 TOX_SKIP_MISSING_INTERPRETERS=false VIRTUALENV_SYSTEM_SITE_PACKAGES="$(/home/github/72684881953/helpers/eval_expression p:'(' s:'' o:'&&' n:1 p:')' o:'||' n:0)" FORCE_COLOR="$(/home/github/72684881953/helpers/eval_expression p:'(' p:'(' o:'!' p:'(' p:'(' f:startsWith p:'(' s:ubuntu-24.04-arm s:windows- p:')' p:')' o:'&&' p:'(' f:startsWith p:'(' s:py s:py p:')' p:')' p:')' p:')' o:'&&' n:1 p:')' o:'||' n:0)" PY_COLORS=1 PYTHON_COLORS=0 TERM=xterm-color MYPY_FORCE_COLOR=1 MYPY_FORCE_TERMINAL_WIDTH=200 PYTEST_ADDOPTS=--color=yes "${CURRENT_ENV[@]}" \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=6 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=ilevkivskyi GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=python/mypy GITHUB_REPOSITORY_OWNER=python GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=3b2b1dda51ddc43d4f81be7877ba3b0e3908f0da GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Tests GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 TOX_SKIP_MISSING_INTERPRETERS=false VIRTUALENV_SYSTEM_SITE_PACKAGES="$(/home/github/72684881953/helpers/eval_expression p:'(' s:'' o:'&&' n:1 p:')' o:'||' n:0)" FORCE_COLOR="$(/home/github/72684881953/helpers/eval_expression p:'(' p:'(' o:'!' p:'(' p:'(' f:startsWith p:'(' s:ubuntu-24.04-arm s:windows- p:')' p:')' o:'&&' p:'(' f:startsWith p:'(' s:py s:py p:')' p:')' p:')' p:')' o:'&&' n:1 p:')' o:'||' n:0)" PY_COLORS=1 PYTHON_COLORS=0 TERM=xterm-color MYPY_FORCE_COLOR=1 MYPY_FORCE_TERMINAL_WIDTH=200 PYTEST_ADDOPTS=--color=yes "${CURRENT_ENV[@]}" \
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=7 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=ilevkivskyi GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=python/mypy GITHUB_REPOSITORY_OWNER=python GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=3b2b1dda51ddc43d4f81be7877ba3b0e3908f0da GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Tests GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 TOX_SKIP_MISSING_INTERPRETERS=false VIRTUALENV_SYSTEM_SITE_PACKAGES="$(/home/github/72684881953/helpers/eval_expression p:'(' s:'' o:'&&' n:1 p:')' o:'||' n:0)" FORCE_COLOR="$(/home/github/72684881953/helpers/eval_expression p:'(' p:'(' o:'!' p:'(' p:'(' f:startsWith p:'(' s:ubuntu-24.04-arm s:windows- p:')' p:')' o:'&&' p:'(' f:startsWith p:'(' s:py s:py p:')' p:')' p:')' p:')' o:'&&' n:1 p:')' o:'||' n:0)" PY_COLORS=1 PYTHON_COLORS=0 TERM=xterm-color MYPY_FORCE_COLOR=1 MYPY_FORCE_TERMINAL_WIDTH=200 PYTEST_ADDOPTS=--color=yes "${CURRENT_ENV[@]}" \
echo $(test "$_GITHUB_JOB_STATUS" = "success" && echo true || echo false))
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=7 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=ilevkivskyi GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=python/mypy GITHUB_REPOSITORY_OWNER=python GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=3b2b1dda51ddc43d4f81be7877ba3b0e3908f0da GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Tests GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 TOX_SKIP_MISSING_INTERPRETERS=false VIRTUALENV_SYSTEM_SITE_PACKAGES="$(/home/github/72684881953/helpers/eval_expression p:'(' s:'' o:'&&' n:1 p:')' o:'||' n:0)" FORCE_COLOR="$(/home/github/72684881953/helpers/eval_expression p:'(' p:'(' o:'!' p:'(' p:'(' f:startsWith p:'(' s:ubuntu-24.04-arm s:windows- p:')' p:')' o:'&&' p:'(' f:startsWith p:'(' s:py s:py p:')' p:')' p:')' p:')' o:'&&' n:1 p:')' o:'||' n:0)" PY_COLORS=1 PYTHON_COLORS=0 TERM=xterm-color MYPY_FORCE_COLOR=1 MYPY_FORCE_TERMINAL_WIDTH=200 PYTEST_ADDOPTS=--color=yes "${CURRENT_ENV[@]}" \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run 'tox run -e py --skip-pkg-install -- -n 4'
echo "##[endgroup]"
echo 'tox run -e py --skip-pkg-install -- -n 4' > /home/github/72684881953/steps/bugswarm_7.sh
chmod u+x /home/github/72684881953/steps/bugswarm_7.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=7 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=ilevkivskyi GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=python/mypy GITHUB_REPOSITORY_OWNER=python GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=3b2b1dda51ddc43d4f81be7877ba3b0e3908f0da GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Tests GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 TOX_SKIP_MISSING_INTERPRETERS=false VIRTUALENV_SYSTEM_SITE_PACKAGES="$(/home/github/72684881953/helpers/eval_expression p:'(' s:'' o:'&&' n:1 p:')' o:'||' n:0)" FORCE_COLOR="$(/home/github/72684881953/helpers/eval_expression p:'(' p:'(' o:'!' p:'(' p:'(' f:startsWith p:'(' s:ubuntu-24.04-arm s:windows- p:')' p:')' o:'&&' p:'(' f:startsWith p:'(' s:py s:py p:')' p:')' p:')' p:')' o:'&&' n:1 p:')' o:'||' n:0)" PY_COLORS=1 PYTHON_COLORS=0 TERM=xterm-color MYPY_FORCE_COLOR=1 MYPY_FORCE_TERMINAL_WIDTH=200 PYTEST_ADDOPTS=--color=yes "${CURRENT_ENV[@]}" \
bash -e /home/github/72684881953/steps/bugswarm_7.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=7 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=ilevkivskyi GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=python/mypy GITHUB_REPOSITORY_OWNER=python GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=3b2b1dda51ddc43d4f81be7877ba3b0e3908f0da GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Tests GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 TOX_SKIP_MISSING_INTERPRETERS=false VIRTUALENV_SYSTEM_SITE_PACKAGES="$(/home/github/72684881953/helpers/eval_expression p:'(' s:'' o:'&&' n:1 p:')' o:'||' n:0)" FORCE_COLOR="$(/home/github/72684881953/helpers/eval_expression p:'(' p:'(' o:'!' p:'(' p:'(' f:startsWith p:'(' s:ubuntu-24.04-arm s:windows- p:')' p:')' o:'&&' p:'(' f:startsWith p:'(' s:py s:py p:')' p:')' p:')' p:')' o:'&&' n:1 p:')' o:'||' n:0)" PY_COLORS=1 PYTHON_COLORS=0 TERM=xterm-color MYPY_FORCE_COLOR=1 MYPY_FORCE_TERMINAL_WIDTH=200 PYTEST_ADDOPTS=--color=yes "${CURRENT_ENV[@]}" \
echo "$(/home/github/72684881953/helpers/eval_expression s:'' o:== s:true)")
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=7 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=ilevkivskyi GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=python/mypy GITHUB_REPOSITORY_OWNER=python GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=3b2b1dda51ddc43d4f81be7877ba3b0e3908f0da GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Tests GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 TOX_SKIP_MISSING_INTERPRETERS=false VIRTUALENV_SYSTEM_SITE_PACKAGES="$(/home/github/72684881953/helpers/eval_expression p:'(' s:'' o:'&&' n:1 p:')' o:'||' n:0)" FORCE_COLOR="$(/home/github/72684881953/helpers/eval_expression p:'(' p:'(' o:'!' p:'(' p:'(' f:startsWith p:'(' s:ubuntu-24.04-arm s:windows- p:')' p:')' o:'&&' p:'(' f:startsWith p:'(' s:py s:py p:')' p:')' p:')' p:')' o:'&&' n:1 p:')' o:'||' n:0)" PY_COLORS=1 PYTHON_COLORS=0 TERM=xterm-color MYPY_FORCE_COLOR=1 MYPY_FORCE_TERMINAL_WIDTH=200 PYTEST_ADDOPTS=--color=yes "${CURRENT_ENV[@]}" \
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=8 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=ilevkivskyi GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=python/mypy GITHUB_REPOSITORY_OWNER=python GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=3b2b1dda51ddc43d4f81be7877ba3b0e3908f0da GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Tests GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 TOX_SKIP_MISSING_INTERPRETERS=false VIRTUALENV_SYSTEM_SITE_PACKAGES="$(/home/github/72684881953/helpers/eval_expression p:'(' s:'' o:'&&' n:1 p:')' o:'||' n:0)" FORCE_COLOR="$(/home/github/72684881953/helpers/eval_expression p:'(' p:'(' o:'!' p:'(' p:'(' f:startsWith p:'(' s:ubuntu-24.04-arm s:windows- p:')' p:')' o:'&&' p:'(' f:startsWith p:'(' s:py s:py p:')' p:')' p:')' p:')' o:'&&' n:1 p:')' o:'||' n:0)" PY_COLORS=1 PYTHON_COLORS=0 TERM=xterm-color MYPY_FORCE_COLOR=1 MYPY_FORCE_TERMINAL_WIDTH=200 PYTEST_ADDOPTS=--color=yes "${CURRENT_ENV[@]}" \
echo "$(/home/github/72684881953/helpers/eval_expression p:'(' f:success p:'(' p:')' p:')' o:'&&' p:'(' s:'' o:== s:true p:')')")
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=8 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=ilevkivskyi GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=python/mypy GITHUB_REPOSITORY_OWNER=python GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=3b2b1dda51ddc43d4f81be7877ba3b0e3908f0da GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Tests GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 TOX_SKIP_MISSING_INTERPRETERS=false VIRTUALENV_SYSTEM_SITE_PACKAGES="$(/home/github/72684881953/helpers/eval_expression p:'(' s:'' o:'&&' n:1 p:')' o:'||' n:0)" FORCE_COLOR="$(/home/github/72684881953/helpers/eval_expression p:'(' p:'(' o:'!' p:'(' p:'(' f:startsWith p:'(' s:ubuntu-24.04-arm s:windows- p:')' p:')' o:'&&' p:'(' f:startsWith p:'(' s:py s:py p:')' p:')' p:')' p:')' o:'&&' n:1 p:')' o:'||' n:0)" PY_COLORS=1 PYTHON_COLORS=0 TERM=xterm-color MYPY_FORCE_COLOR=1 MYPY_FORCE_TERMINAL_WIDTH=200 PYTEST_ADDOPTS=--color=yes "${CURRENT_ENV[@]}" \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run 'exit 0'
echo "##[endgroup]"
echo 'exit 0' > /home/github/72684881953/steps/bugswarm_8.sh
chmod u+x /home/github/72684881953/steps/bugswarm_8.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=8 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=ilevkivskyi GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=python/mypy GITHUB_REPOSITORY_OWNER=python GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=3b2b1dda51ddc43d4f81be7877ba3b0e3908f0da GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Tests GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 TOX_SKIP_MISSING_INTERPRETERS=false VIRTUALENV_SYSTEM_SITE_PACKAGES="$(/home/github/72684881953/helpers/eval_expression p:'(' s:'' o:'&&' n:1 p:')' o:'||' n:0)" FORCE_COLOR="$(/home/github/72684881953/helpers/eval_expression p:'(' p:'(' o:'!' p:'(' p:'(' f:startsWith p:'(' s:ubuntu-24.04-arm s:windows- p:')' p:')' o:'&&' p:'(' f:startsWith p:'(' s:py s:py p:')' p:')' p:')' p:')' o:'&&' n:1 p:')' o:'||' n:0)" PY_COLORS=1 PYTHON_COLORS=0 TERM=xterm-color MYPY_FORCE_COLOR=1 MYPY_FORCE_TERMINAL_WIDTH=200 PYTEST_ADDOPTS=--color=yes "${CURRENT_ENV[@]}" \
bash -e /home/github/72684881953/steps/bugswarm_8.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=8 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=ilevkivskyi GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=python/mypy GITHUB_REPOSITORY_OWNER=python GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=3b2b1dda51ddc43d4f81be7877ba3b0e3908f0da GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Tests GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 TOX_SKIP_MISSING_INTERPRETERS=false VIRTUALENV_SYSTEM_SITE_PACKAGES="$(/home/github/72684881953/helpers/eval_expression p:'(' s:'' o:'&&' n:1 p:')' o:'||' n:0)" FORCE_COLOR="$(/home/github/72684881953/helpers/eval_expression p:'(' p:'(' o:'!' p:'(' p:'(' f:startsWith p:'(' s:ubuntu-24.04-arm s:windows- p:')' p:')' o:'&&' p:'(' f:startsWith p:'(' s:py s:py p:')' p:')' p:')' p:')' o:'&&' n:1 p:')' o:'||' n:0)" PY_COLORS=1 PYTHON_COLORS=0 TERM=xterm-color MYPY_FORCE_COLOR=1 MYPY_FORCE_TERMINAL_WIDTH=200 PYTEST_ADDOPTS=--color=yes "${CURRENT_ENV[@]}" \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=8 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=ilevkivskyi GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=python/mypy GITHUB_REPOSITORY_OWNER=python GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=3b2b1dda51ddc43d4f81be7877ba3b0e3908f0da GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Tests GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 TOX_SKIP_MISSING_INTERPRETERS=false VIRTUALENV_SYSTEM_SITE_PACKAGES="$(/home/github/72684881953/helpers/eval_expression p:'(' s:'' o:'&&' n:1 p:')' o:'||' n:0)" FORCE_COLOR="$(/home/github/72684881953/helpers/eval_expression p:'(' p:'(' o:'!' p:'(' p:'(' f:startsWith p:'(' s:ubuntu-24.04-arm s:windows- p:')' p:')' o:'&&' p:'(' f:startsWith p:'(' s:py s:py p:')' p:')' p:')' p:')' o:'&&' n:1 p:')' o:'||' n:0)" PY_COLORS=1 PYTHON_COLORS=0 TERM=xterm-color MYPY_FORCE_COLOR=1 MYPY_FORCE_TERMINAL_WIDTH=200 PYTEST_ADDOPTS=--color=yes "${CURRENT_ENV[@]}" \
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
   bash -e $ACTIONS_RUNNER_HOOK_JOB_COMPLETED 72684881953 passed
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
