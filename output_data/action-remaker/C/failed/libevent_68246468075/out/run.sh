#!/usr/bin/env bash
export GITHUB_WORKSPACE=/home/github/build/libevent/libevent

if [[ ! -z "$ACTIONS_RUNNER_HOOK_JOB_STARTED" ]]; then
   echo "A job started hook has been configured by the self-hosted runner administrator"
   echo "##[group]Run '$ACTIONS_RUNNER_HOOK_JOB_STARTED'"
   echo "##[endgroup]"
   bash -e $ACTIONS_RUNNER_HOOK_JOB_STARTED 68246468075 failed
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

cp /home/github/68246468075/event.json /home/github/workflow/event.json
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=2 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=vmactions/freebsd-vm GITHUB_ACTIONS=true GITHUB_ACTOR=azat GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=libevent/libevent GITHUB_REPOSITORY_OWNER=libevent GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=0108159b0b42a1722db3a3f56926e0789588e8b1 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=build GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 GITHUB_ACTION_PATH=/home/github/68246468075/actions/vmactions-freebsd-vm@v1 "${CURRENT_ENV[@]}" INPUT_RELEASE=14.1 INPUT_PREPARE='pkg install -y mbedtls3 cmake python3
' INPUT_USESH=true INPUT_RUN='if [ "DISABLE_THREAD_SUPPORT" == "DISABLE_OPENSSL" ]; then
  EVENT_CMAKE_OPTIONS="-DEVENT__DISABLE_OPENSSL=ON"

elif [ "DISABLE_THREAD_SUPPORT" == "NO_SSL" ]; then
  EVENT_CMAKE_OPTIONS="-DEVENT__DISABLE_OPENSSL=ON -DEVENT__DISABLE_MBEDTLS=ON"

elif [ "DISABLE_THREAD_SUPPORT" == "DISABLE_THREAD_SUPPORT" ]; then
  EVENT_CMAKE_OPTIONS="-DEVENT__DISABLE_THREAD_SUPPORT=ON"

elif [ "DISABLE_THREAD_SUPPORT" == "DISABLE_DEBUG_MODE" ]; then
  EVENT_CMAKE_OPTIONS="-DEVENT__DISABLE_DEBUG_MODE=ON"

elif [ "DISABLE_THREAD_SUPPORT" == "DISABLE_MM_REPLACEMENT" ]; then
  EVENT_CMAKE_OPTIONS="-DEVENT__DISABLE_MM_REPLACEMENT=ON"

elif [ "DISABLE_THREAD_SUPPORT" == "TEST_EXPORT_STATIC" ]; then
  EVENT_CMAKE_OPTIONS="-DEVENT__LIBRARY_TYPE=STATIC -DEVENT__DISABLE_TESTS=ON -DEVENT__DISABLE_SAMPLES=ON"

elif [ "DISABLE_THREAD_SUPPORT" == "TEST_EXPORT_SHARED" ]; then
  EVENT_CMAKE_OPTIONS="-DEVENT__LIBRARY_TYPE=SHARED -DEVENT__DISABLE_TESTS=ON -DEVENT__DISABLE_SAMPLES=ON"

else
  EVENT_CMAKE_OPTIONS=""
fi

mkdir -p build
cd build
echo [cmake]: cmake .. $EVENT_CMAKE_OPTIONS
cmake .. $EVENT_CMAKE_OPTIONS || (rm -rf * && cmake .. $EVENT_CMAKE_OPTIONS)
cmake --build .
' INPUT_OSNAME=FreeBSD INPUT_MEM=6144 INPUT_DISABLE-CACHE=false INPUT_DEBUG-ON-ERROR= INPUT_VNC-PASSWORD= \
echo $(test "$_GITHUB_JOB_STATUS" = "success" && echo true || echo false))
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=2 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=vmactions/freebsd-vm GITHUB_ACTIONS=true GITHUB_ACTOR=azat GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=libevent/libevent GITHUB_REPOSITORY_OWNER=libevent GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=0108159b0b42a1722db3a3f56926e0789588e8b1 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=build GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 GITHUB_ACTION_PATH=/home/github/68246468075/actions/vmactions-freebsd-vm@v1 "${CURRENT_ENV[@]}" INPUT_RELEASE=14.1 INPUT_PREPARE='pkg install -y mbedtls3 cmake python3
' INPUT_USESH=true INPUT_RUN='if [ "DISABLE_THREAD_SUPPORT" == "DISABLE_OPENSSL" ]; then
  EVENT_CMAKE_OPTIONS="-DEVENT__DISABLE_OPENSSL=ON"

elif [ "DISABLE_THREAD_SUPPORT" == "NO_SSL" ]; then
  EVENT_CMAKE_OPTIONS="-DEVENT__DISABLE_OPENSSL=ON -DEVENT__DISABLE_MBEDTLS=ON"

elif [ "DISABLE_THREAD_SUPPORT" == "DISABLE_THREAD_SUPPORT" ]; then
  EVENT_CMAKE_OPTIONS="-DEVENT__DISABLE_THREAD_SUPPORT=ON"

elif [ "DISABLE_THREAD_SUPPORT" == "DISABLE_DEBUG_MODE" ]; then
  EVENT_CMAKE_OPTIONS="-DEVENT__DISABLE_DEBUG_MODE=ON"

elif [ "DISABLE_THREAD_SUPPORT" == "DISABLE_MM_REPLACEMENT" ]; then
  EVENT_CMAKE_OPTIONS="-DEVENT__DISABLE_MM_REPLACEMENT=ON"

elif [ "DISABLE_THREAD_SUPPORT" == "TEST_EXPORT_STATIC" ]; then
  EVENT_CMAKE_OPTIONS="-DEVENT__LIBRARY_TYPE=STATIC -DEVENT__DISABLE_TESTS=ON -DEVENT__DISABLE_SAMPLES=ON"

elif [ "DISABLE_THREAD_SUPPORT" == "TEST_EXPORT_SHARED" ]; then
  EVENT_CMAKE_OPTIONS="-DEVENT__LIBRARY_TYPE=SHARED -DEVENT__DISABLE_TESTS=ON -DEVENT__DISABLE_SAMPLES=ON"

else
  EVENT_CMAKE_OPTIONS=""
fi

mkdir -p build
cd build
echo [cmake]: cmake .. $EVENT_CMAKE_OPTIONS
cmake .. $EVENT_CMAKE_OPTIONS || (rm -rf * && cmake .. $EVENT_CMAKE_OPTIONS)
cmake --build .
' INPUT_OSNAME=FreeBSD INPUT_MEM=6144 INPUT_DISABLE-CACHE=false INPUT_DEBUG-ON-ERROR= INPUT_VNC-PASSWORD= \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run vmactions/freebsd-vm@v1
echo "##[endgroup]"
echo node /home/github/68246468075/actions/vmactions-freebsd-vm@v1/index.js > /home/github/68246468075/steps/bugswarm_cmd.sh
chmod u+x /home/github/68246468075/steps/bugswarm_cmd.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=2 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=vmactions/freebsd-vm GITHUB_ACTIONS=true GITHUB_ACTOR=azat GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=libevent/libevent GITHUB_REPOSITORY_OWNER=libevent GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=0108159b0b42a1722db3a3f56926e0789588e8b1 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=build GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 GITHUB_ACTION_PATH=/home/github/68246468075/actions/vmactions-freebsd-vm@v1 "${CURRENT_ENV[@]}" INPUT_RELEASE=14.1 INPUT_PREPARE='pkg install -y mbedtls3 cmake python3
' INPUT_USESH=true INPUT_RUN='if [ "DISABLE_THREAD_SUPPORT" == "DISABLE_OPENSSL" ]; then
  EVENT_CMAKE_OPTIONS="-DEVENT__DISABLE_OPENSSL=ON"

elif [ "DISABLE_THREAD_SUPPORT" == "NO_SSL" ]; then
  EVENT_CMAKE_OPTIONS="-DEVENT__DISABLE_OPENSSL=ON -DEVENT__DISABLE_MBEDTLS=ON"

elif [ "DISABLE_THREAD_SUPPORT" == "DISABLE_THREAD_SUPPORT" ]; then
  EVENT_CMAKE_OPTIONS="-DEVENT__DISABLE_THREAD_SUPPORT=ON"

elif [ "DISABLE_THREAD_SUPPORT" == "DISABLE_DEBUG_MODE" ]; then
  EVENT_CMAKE_OPTIONS="-DEVENT__DISABLE_DEBUG_MODE=ON"

elif [ "DISABLE_THREAD_SUPPORT" == "DISABLE_MM_REPLACEMENT" ]; then
  EVENT_CMAKE_OPTIONS="-DEVENT__DISABLE_MM_REPLACEMENT=ON"

elif [ "DISABLE_THREAD_SUPPORT" == "TEST_EXPORT_STATIC" ]; then
  EVENT_CMAKE_OPTIONS="-DEVENT__LIBRARY_TYPE=STATIC -DEVENT__DISABLE_TESTS=ON -DEVENT__DISABLE_SAMPLES=ON"

elif [ "DISABLE_THREAD_SUPPORT" == "TEST_EXPORT_SHARED" ]; then
  EVENT_CMAKE_OPTIONS="-DEVENT__LIBRARY_TYPE=SHARED -DEVENT__DISABLE_TESTS=ON -DEVENT__DISABLE_SAMPLES=ON"

else
  EVENT_CMAKE_OPTIONS=""
fi

mkdir -p build
cd build
echo [cmake]: cmake .. $EVENT_CMAKE_OPTIONS
cmake .. $EVENT_CMAKE_OPTIONS || (rm -rf * && cmake .. $EVENT_CMAKE_OPTIONS)
cmake --build .
' INPUT_OSNAME=FreeBSD INPUT_MEM=6144 INPUT_DISABLE-CACHE=false INPUT_DEBUG-ON-ERROR= INPUT_VNC-PASSWORD= \
bash -e /home/github/68246468075/steps/bugswarm_cmd.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=2 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=vmactions/freebsd-vm GITHUB_ACTIONS=true GITHUB_ACTOR=azat GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=libevent/libevent GITHUB_REPOSITORY_OWNER=libevent GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=0108159b0b42a1722db3a3f56926e0789588e8b1 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=build GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 GITHUB_ACTION_PATH=/home/github/68246468075/actions/vmactions-freebsd-vm@v1 "${CURRENT_ENV[@]}" INPUT_RELEASE=14.1 INPUT_PREPARE='pkg install -y mbedtls3 cmake python3
' INPUT_USESH=true INPUT_RUN='if [ "DISABLE_THREAD_SUPPORT" == "DISABLE_OPENSSL" ]; then
  EVENT_CMAKE_OPTIONS="-DEVENT__DISABLE_OPENSSL=ON"

elif [ "DISABLE_THREAD_SUPPORT" == "NO_SSL" ]; then
  EVENT_CMAKE_OPTIONS="-DEVENT__DISABLE_OPENSSL=ON -DEVENT__DISABLE_MBEDTLS=ON"

elif [ "DISABLE_THREAD_SUPPORT" == "DISABLE_THREAD_SUPPORT" ]; then
  EVENT_CMAKE_OPTIONS="-DEVENT__DISABLE_THREAD_SUPPORT=ON"

elif [ "DISABLE_THREAD_SUPPORT" == "DISABLE_DEBUG_MODE" ]; then
  EVENT_CMAKE_OPTIONS="-DEVENT__DISABLE_DEBUG_MODE=ON"

elif [ "DISABLE_THREAD_SUPPORT" == "DISABLE_MM_REPLACEMENT" ]; then
  EVENT_CMAKE_OPTIONS="-DEVENT__DISABLE_MM_REPLACEMENT=ON"

elif [ "DISABLE_THREAD_SUPPORT" == "TEST_EXPORT_STATIC" ]; then
  EVENT_CMAKE_OPTIONS="-DEVENT__LIBRARY_TYPE=STATIC -DEVENT__DISABLE_TESTS=ON -DEVENT__DISABLE_SAMPLES=ON"

elif [ "DISABLE_THREAD_SUPPORT" == "TEST_EXPORT_SHARED" ]; then
  EVENT_CMAKE_OPTIONS="-DEVENT__LIBRARY_TYPE=SHARED -DEVENT__DISABLE_TESTS=ON -DEVENT__DISABLE_SAMPLES=ON"

else
  EVENT_CMAKE_OPTIONS=""
fi

mkdir -p build
cd build
echo [cmake]: cmake .. $EVENT_CMAKE_OPTIONS
cmake .. $EVENT_CMAKE_OPTIONS || (rm -rf * && cmake .. $EVENT_CMAKE_OPTIONS)
cmake --build .
' INPUT_OSNAME=FreeBSD INPUT_MEM=6144 INPUT_DISABLE-CACHE=false INPUT_DEBUG-ON-ERROR= INPUT_VNC-PASSWORD= \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=2 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=vmactions/freebsd-vm GITHUB_ACTIONS=true GITHUB_ACTOR=azat GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=libevent/libevent GITHUB_REPOSITORY_OWNER=libevent GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=0108159b0b42a1722db3a3f56926e0789588e8b1 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=build GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 GITHUB_ACTION_PATH=/home/github/68246468075/actions/vmactions-freebsd-vm@v1 "${CURRENT_ENV[@]}" INPUT_RELEASE=14.1 INPUT_PREPARE='pkg install -y mbedtls3 cmake python3
' INPUT_USESH=true INPUT_RUN='if [ "DISABLE_THREAD_SUPPORT" == "DISABLE_OPENSSL" ]; then
  EVENT_CMAKE_OPTIONS="-DEVENT__DISABLE_OPENSSL=ON"

elif [ "DISABLE_THREAD_SUPPORT" == "NO_SSL" ]; then
  EVENT_CMAKE_OPTIONS="-DEVENT__DISABLE_OPENSSL=ON -DEVENT__DISABLE_MBEDTLS=ON"

elif [ "DISABLE_THREAD_SUPPORT" == "DISABLE_THREAD_SUPPORT" ]; then
  EVENT_CMAKE_OPTIONS="-DEVENT__DISABLE_THREAD_SUPPORT=ON"

elif [ "DISABLE_THREAD_SUPPORT" == "DISABLE_DEBUG_MODE" ]; then
  EVENT_CMAKE_OPTIONS="-DEVENT__DISABLE_DEBUG_MODE=ON"

elif [ "DISABLE_THREAD_SUPPORT" == "DISABLE_MM_REPLACEMENT" ]; then
  EVENT_CMAKE_OPTIONS="-DEVENT__DISABLE_MM_REPLACEMENT=ON"

elif [ "DISABLE_THREAD_SUPPORT" == "TEST_EXPORT_STATIC" ]; then
  EVENT_CMAKE_OPTIONS="-DEVENT__LIBRARY_TYPE=STATIC -DEVENT__DISABLE_TESTS=ON -DEVENT__DISABLE_SAMPLES=ON"

elif [ "DISABLE_THREAD_SUPPORT" == "TEST_EXPORT_SHARED" ]; then
  EVENT_CMAKE_OPTIONS="-DEVENT__LIBRARY_TYPE=SHARED -DEVENT__DISABLE_TESTS=ON -DEVENT__DISABLE_SAMPLES=ON"

else
  EVENT_CMAKE_OPTIONS=""
fi

mkdir -p build
cd build
echo [cmake]: cmake .. $EVENT_CMAKE_OPTIONS
cmake .. $EVENT_CMAKE_OPTIONS || (rm -rf * && cmake .. $EVENT_CMAKE_OPTIONS)
cmake --build .
' INPUT_OSNAME=FreeBSD INPUT_MEM=6144 INPUT_DISABLE-CACHE=false INPUT_DEBUG-ON-ERROR= INPUT_VNC-PASSWORD= \
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=3 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=nick-fields/retry GITHUB_ACTIONS=true GITHUB_ACTOR=azat GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=libevent/libevent GITHUB_REPOSITORY_OWNER=libevent GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=0108159b0b42a1722db3a3f56926e0789588e8b1 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=build GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 GITHUB_ACTION_PATH=/home/github/68246468075/actions/nick-fields-retry@v3 "${CURRENT_ENV[@]}" INPUT_MAX_ATTEMPTS=5 INPUT_TIMEOUT_MINUTES=60 INPUT_SHELL=bash INPUT_COMMAND='ssh freebsd sh <<EOF
cd $GITHUB_WORKSPACE
JOBS=1
export CTEST_PARALLEL_LEVEL=$JOBS
export CTEST_OUTPUT_ON_FAILURE=1
cd build
if [ "DISABLE_THREAD_SUPPORT" == "TEST_EXPORT_STATIC" ]; then
  python3 ../test-export/test-export.py static
elif [ "DISABLE_THREAD_SUPPORT" == "TEST_EXPORT_SHARED" ]; then
  python3 ../test-export/test-export.py shared
else
  cmake --build . --target verify
fi
EOF
' INPUT_RETRY_WAIT_SECONDS=10 INPUT_POLLING_INTERVAL_SECONDS=1 INPUT_WARNING_ON_RETRY=true INPUT_CONTINUE_ON_ERROR=false \
echo $(test "$_GITHUB_JOB_STATUS" = "success" && echo true || echo false))
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=3 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=nick-fields/retry GITHUB_ACTIONS=true GITHUB_ACTOR=azat GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=libevent/libevent GITHUB_REPOSITORY_OWNER=libevent GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=0108159b0b42a1722db3a3f56926e0789588e8b1 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=build GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 GITHUB_ACTION_PATH=/home/github/68246468075/actions/nick-fields-retry@v3 "${CURRENT_ENV[@]}" INPUT_MAX_ATTEMPTS=5 INPUT_TIMEOUT_MINUTES=60 INPUT_SHELL=bash INPUT_COMMAND='ssh freebsd sh <<EOF
cd $GITHUB_WORKSPACE
JOBS=1
export CTEST_PARALLEL_LEVEL=$JOBS
export CTEST_OUTPUT_ON_FAILURE=1
cd build
if [ "DISABLE_THREAD_SUPPORT" == "TEST_EXPORT_STATIC" ]; then
  python3 ../test-export/test-export.py static
elif [ "DISABLE_THREAD_SUPPORT" == "TEST_EXPORT_SHARED" ]; then
  python3 ../test-export/test-export.py shared
else
  cmake --build . --target verify
fi
EOF
' INPUT_RETRY_WAIT_SECONDS=10 INPUT_POLLING_INTERVAL_SECONDS=1 INPUT_WARNING_ON_RETRY=true INPUT_CONTINUE_ON_ERROR=false \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run nick-fields/retry@v3
echo "##[endgroup]"
echo node /home/github/68246468075/actions/nick-fields-retry@v3/dist/index.js > /home/github/68246468075/steps/bugswarm_cmd.sh
chmod u+x /home/github/68246468075/steps/bugswarm_cmd.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=3 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=nick-fields/retry GITHUB_ACTIONS=true GITHUB_ACTOR=azat GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=libevent/libevent GITHUB_REPOSITORY_OWNER=libevent GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=0108159b0b42a1722db3a3f56926e0789588e8b1 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=build GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 GITHUB_ACTION_PATH=/home/github/68246468075/actions/nick-fields-retry@v3 "${CURRENT_ENV[@]}" INPUT_MAX_ATTEMPTS=5 INPUT_TIMEOUT_MINUTES=60 INPUT_SHELL=bash INPUT_COMMAND='ssh freebsd sh <<EOF
cd $GITHUB_WORKSPACE
JOBS=1
export CTEST_PARALLEL_LEVEL=$JOBS
export CTEST_OUTPUT_ON_FAILURE=1
cd build
if [ "DISABLE_THREAD_SUPPORT" == "TEST_EXPORT_STATIC" ]; then
  python3 ../test-export/test-export.py static
elif [ "DISABLE_THREAD_SUPPORT" == "TEST_EXPORT_SHARED" ]; then
  python3 ../test-export/test-export.py shared
else
  cmake --build . --target verify
fi
EOF
' INPUT_RETRY_WAIT_SECONDS=10 INPUT_POLLING_INTERVAL_SECONDS=1 INPUT_WARNING_ON_RETRY=true INPUT_CONTINUE_ON_ERROR=false \
bash -e /home/github/68246468075/steps/bugswarm_cmd.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=3 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=nick-fields/retry GITHUB_ACTIONS=true GITHUB_ACTOR=azat GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=libevent/libevent GITHUB_REPOSITORY_OWNER=libevent GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=0108159b0b42a1722db3a3f56926e0789588e8b1 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=build GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 GITHUB_ACTION_PATH=/home/github/68246468075/actions/nick-fields-retry@v3 "${CURRENT_ENV[@]}" INPUT_MAX_ATTEMPTS=5 INPUT_TIMEOUT_MINUTES=60 INPUT_SHELL=bash INPUT_COMMAND='ssh freebsd sh <<EOF
cd $GITHUB_WORKSPACE
JOBS=1
export CTEST_PARALLEL_LEVEL=$JOBS
export CTEST_OUTPUT_ON_FAILURE=1
cd build
if [ "DISABLE_THREAD_SUPPORT" == "TEST_EXPORT_STATIC" ]; then
  python3 ../test-export/test-export.py static
elif [ "DISABLE_THREAD_SUPPORT" == "TEST_EXPORT_SHARED" ]; then
  python3 ../test-export/test-export.py shared
else
  cmake --build . --target verify
fi
EOF
' INPUT_RETRY_WAIT_SECONDS=10 INPUT_POLLING_INTERVAL_SECONDS=1 INPUT_WARNING_ON_RETRY=true INPUT_CONTINUE_ON_ERROR=false \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=3 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=nick-fields/retry GITHUB_ACTIONS=true GITHUB_ACTOR=azat GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=libevent/libevent GITHUB_REPOSITORY_OWNER=libevent GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=0108159b0b42a1722db3a3f56926e0789588e8b1 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=build GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 GITHUB_ACTION_PATH=/home/github/68246468075/actions/nick-fields-retry@v3 "${CURRENT_ENV[@]}" INPUT_MAX_ATTEMPTS=5 INPUT_TIMEOUT_MINUTES=60 INPUT_SHELL=bash INPUT_COMMAND='ssh freebsd sh <<EOF
cd $GITHUB_WORKSPACE
JOBS=1
export CTEST_PARALLEL_LEVEL=$JOBS
export CTEST_OUTPUT_ON_FAILURE=1
cd build
if [ "DISABLE_THREAD_SUPPORT" == "TEST_EXPORT_STATIC" ]; then
  python3 ../test-export/test-export.py static
elif [ "DISABLE_THREAD_SUPPORT" == "TEST_EXPORT_SHARED" ]; then
  python3 ../test-export/test-export.py shared
else
  cmake --build . --target verify
fi
EOF
' INPUT_RETRY_WAIT_SECONDS=10 INPUT_POLLING_INTERVAL_SECONDS=1 INPUT_WARNING_ON_RETRY=true INPUT_CONTINUE_ON_ERROR=false \
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
   bash -e $ACTIONS_RUNNER_HOOK_JOB_COMPLETED 68246468075 failed
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
