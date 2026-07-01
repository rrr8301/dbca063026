#!/usr/bin/env bash
export GITHUB_WORKSPACE=/home/github/build/RustPython/RustPython

if [[ ! -z "$ACTIONS_RUNNER_HOOK_JOB_STARTED" ]]; then
   echo "A job started hook has been configured by the self-hosted runner administrator"
   echo "##[group]Run '$ACTIONS_RUNNER_HOOK_JOB_STARTED'"
   echo "##[endgroup]"
   bash -e $ACTIONS_RUNNER_HOOK_JOB_STARTED 79426228203 passed
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

cp /home/github/79426228203/event.json /home/github/workflow/event.json
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=1 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=dtolnay/rust-toolchain GITHUB_ACTIONS=true GITHUB_ACTOR=youknowone GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/main GITHUB_REF_NAME=main GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=RustPython/RustPython GITHUB_REPOSITORY_OWNER=RustPython GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=99bfbad8ee804980f6e5cd749ca937328bf2f819 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_ARGS='--no-default-features --features stdlib,importlib,stdio,encodings,sqlite,ssl-rustls-aws-lc,host_env' CARGO_ARGS_NO_SSL='--no-default-features --features stdlib,importlib,stdio,encodings,sqlite,host_env' WORKSPACE_EXCLUDES='--exclude rustpython_wasm --exclude rustpython-compiler-source --exclude rustpython-venvlauncher' X86_64_PC_WINDOWS_MSVC_OPENSSL_LIB_DIR='C:\Program Files\OpenSSL\lib\VC\x64\MD' X86_64_PC_WINDOWS_MSVC_OPENSSL_INCLUDE_DIR='C:\Program Files\OpenSSL\include' CARGO_INCREMENTAL=0 CARGO_PROFILE_TEST_DEBUG=0 CARGO_PROFILE_DEV_DEBUG=0 CARGO_PROFILE_RELEASE_DEBUG=0 CARGO_TERM_COLOR=always CI=true GITHUB_ACTION_PATH=/home/github/79426228203/actions/dtolnay-rust-toolchain@stable RUST_BACKTRACE=full "${CURRENT_ENV[@]}" INPUT_TOOLCHAIN=stable \
echo $(test "$_GITHUB_JOB_STATUS" = "success" && echo true || echo false))
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=1 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=dtolnay/rust-toolchain GITHUB_ACTIONS=true GITHUB_ACTOR=youknowone GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/main GITHUB_REF_NAME=main GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=RustPython/RustPython GITHUB_REPOSITORY_OWNER=RustPython GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=99bfbad8ee804980f6e5cd749ca937328bf2f819 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_ARGS='--no-default-features --features stdlib,importlib,stdio,encodings,sqlite,ssl-rustls-aws-lc,host_env' CARGO_ARGS_NO_SSL='--no-default-features --features stdlib,importlib,stdio,encodings,sqlite,host_env' WORKSPACE_EXCLUDES='--exclude rustpython_wasm --exclude rustpython-compiler-source --exclude rustpython-venvlauncher' X86_64_PC_WINDOWS_MSVC_OPENSSL_LIB_DIR='C:\Program Files\OpenSSL\lib\VC\x64\MD' X86_64_PC_WINDOWS_MSVC_OPENSSL_INCLUDE_DIR='C:\Program Files\OpenSSL\include' CARGO_INCREMENTAL=0 CARGO_PROFILE_TEST_DEBUG=0 CARGO_PROFILE_DEV_DEBUG=0 CARGO_PROFILE_RELEASE_DEBUG=0 CARGO_TERM_COLOR=always CI=true GITHUB_ACTION_PATH=/home/github/79426228203/actions/dtolnay-rust-toolchain@stable RUST_BACKTRACE=full "${CURRENT_ENV[@]}" INPUT_TOOLCHAIN=stable \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run dtolnay/rust-toolchain@stable
echo "##[endgroup]"
echo /home/github/79426228203/steps/bugswarm_1_composite.sh > /home/github/79426228203/steps/bugswarm_1.sh
chmod u+x /home/github/79426228203/steps/bugswarm_1.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=1 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=dtolnay/rust-toolchain GITHUB_ACTIONS=true GITHUB_ACTOR=youknowone GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/main GITHUB_REF_NAME=main GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=RustPython/RustPython GITHUB_REPOSITORY_OWNER=RustPython GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=99bfbad8ee804980f6e5cd749ca937328bf2f819 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_ARGS='--no-default-features --features stdlib,importlib,stdio,encodings,sqlite,ssl-rustls-aws-lc,host_env' CARGO_ARGS_NO_SSL='--no-default-features --features stdlib,importlib,stdio,encodings,sqlite,host_env' WORKSPACE_EXCLUDES='--exclude rustpython_wasm --exclude rustpython-compiler-source --exclude rustpython-venvlauncher' X86_64_PC_WINDOWS_MSVC_OPENSSL_LIB_DIR='C:\Program Files\OpenSSL\lib\VC\x64\MD' X86_64_PC_WINDOWS_MSVC_OPENSSL_INCLUDE_DIR='C:\Program Files\OpenSSL\include' CARGO_INCREMENTAL=0 CARGO_PROFILE_TEST_DEBUG=0 CARGO_PROFILE_DEV_DEBUG=0 CARGO_PROFILE_RELEASE_DEBUG=0 CARGO_TERM_COLOR=always CI=true GITHUB_ACTION_PATH=/home/github/79426228203/actions/dtolnay-rust-toolchain@stable RUST_BACKTRACE=full "${CURRENT_ENV[@]}" INPUT_TOOLCHAIN=stable \
bash -e /home/github/79426228203/steps/bugswarm_1.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=1 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=dtolnay/rust-toolchain GITHUB_ACTIONS=true GITHUB_ACTOR=youknowone GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/main GITHUB_REF_NAME=main GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=RustPython/RustPython GITHUB_REPOSITORY_OWNER=RustPython GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=99bfbad8ee804980f6e5cd749ca937328bf2f819 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_ARGS='--no-default-features --features stdlib,importlib,stdio,encodings,sqlite,ssl-rustls-aws-lc,host_env' CARGO_ARGS_NO_SSL='--no-default-features --features stdlib,importlib,stdio,encodings,sqlite,host_env' WORKSPACE_EXCLUDES='--exclude rustpython_wasm --exclude rustpython-compiler-source --exclude rustpython-venvlauncher' X86_64_PC_WINDOWS_MSVC_OPENSSL_LIB_DIR='C:\Program Files\OpenSSL\lib\VC\x64\MD' X86_64_PC_WINDOWS_MSVC_OPENSSL_INCLUDE_DIR='C:\Program Files\OpenSSL\include' CARGO_INCREMENTAL=0 CARGO_PROFILE_TEST_DEBUG=0 CARGO_PROFILE_DEV_DEBUG=0 CARGO_PROFILE_RELEASE_DEBUG=0 CARGO_TERM_COLOR=always CI=true GITHUB_ACTION_PATH=/home/github/79426228203/actions/dtolnay-rust-toolchain@stable RUST_BACKTRACE=full "${CURRENT_ENV[@]}" INPUT_TOOLCHAIN=stable \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=1 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=dtolnay/rust-toolchain GITHUB_ACTIONS=true GITHUB_ACTOR=youknowone GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/main GITHUB_REF_NAME=main GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=RustPython/RustPython GITHUB_REPOSITORY_OWNER=RustPython GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=99bfbad8ee804980f6e5cd749ca937328bf2f819 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_ARGS='--no-default-features --features stdlib,importlib,stdio,encodings,sqlite,ssl-rustls-aws-lc,host_env' CARGO_ARGS_NO_SSL='--no-default-features --features stdlib,importlib,stdio,encodings,sqlite,host_env' WORKSPACE_EXCLUDES='--exclude rustpython_wasm --exclude rustpython-compiler-source --exclude rustpython-venvlauncher' X86_64_PC_WINDOWS_MSVC_OPENSSL_LIB_DIR='C:\Program Files\OpenSSL\lib\VC\x64\MD' X86_64_PC_WINDOWS_MSVC_OPENSSL_INCLUDE_DIR='C:\Program Files\OpenSSL\include' CARGO_INCREMENTAL=0 CARGO_PROFILE_TEST_DEBUG=0 CARGO_PROFILE_DEV_DEBUG=0 CARGO_PROFILE_RELEASE_DEBUG=0 CARGO_TERM_COLOR=always CI=true GITHUB_ACTION_PATH=/home/github/79426228203/actions/dtolnay-rust-toolchain@stable RUST_BACKTRACE=full "${CURRENT_ENV[@]}" INPUT_TOOLCHAIN=stable \
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=3 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=RustPython/RustPython GITHUB_ACTIONS=true GITHUB_ACTOR=youknowone GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/main GITHUB_REF_NAME=main GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=RustPython/RustPython GITHUB_REPOSITORY_OWNER=RustPython GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=99bfbad8ee804980f6e5cd749ca937328bf2f819 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_ARGS='--no-default-features --features stdlib,importlib,stdio,encodings,sqlite,ssl-rustls-aws-lc,host_env' CARGO_ARGS_NO_SSL='--no-default-features --features stdlib,importlib,stdio,encodings,sqlite,host_env' WORKSPACE_EXCLUDES='--exclude rustpython_wasm --exclude rustpython-compiler-source --exclude rustpython-venvlauncher' X86_64_PC_WINDOWS_MSVC_OPENSSL_LIB_DIR='C:\Program Files\OpenSSL\lib\VC\x64\MD' X86_64_PC_WINDOWS_MSVC_OPENSSL_INCLUDE_DIR='C:\Program Files\OpenSSL\include' CARGO_INCREMENTAL=0 CARGO_PROFILE_TEST_DEBUG=0 CARGO_PROFILE_DEV_DEBUG=0 CARGO_PROFILE_RELEASE_DEBUG=0 CARGO_TERM_COLOR=always CI=true GITHUB_ACTION_PATH=/home/github/79426228203/actions/RustPython-RustPython/./.github/actions/install-macos-deps RUST_BACKTRACE=full "${CURRENT_ENV[@]}" INPUT_AUTOCONF=true INPUT_AUTOMAKE=true INPUT_LIBTOOL=true INPUT_OPENSSL=false \
echo $(test "$_GITHUB_JOB_STATUS" = "success" && echo true || echo false))
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=3 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=RustPython/RustPython GITHUB_ACTIONS=true GITHUB_ACTOR=youknowone GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/main GITHUB_REF_NAME=main GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=RustPython/RustPython GITHUB_REPOSITORY_OWNER=RustPython GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=99bfbad8ee804980f6e5cd749ca937328bf2f819 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_ARGS='--no-default-features --features stdlib,importlib,stdio,encodings,sqlite,ssl-rustls-aws-lc,host_env' CARGO_ARGS_NO_SSL='--no-default-features --features stdlib,importlib,stdio,encodings,sqlite,host_env' WORKSPACE_EXCLUDES='--exclude rustpython_wasm --exclude rustpython-compiler-source --exclude rustpython-venvlauncher' X86_64_PC_WINDOWS_MSVC_OPENSSL_LIB_DIR='C:\Program Files\OpenSSL\lib\VC\x64\MD' X86_64_PC_WINDOWS_MSVC_OPENSSL_INCLUDE_DIR='C:\Program Files\OpenSSL\include' CARGO_INCREMENTAL=0 CARGO_PROFILE_TEST_DEBUG=0 CARGO_PROFILE_DEV_DEBUG=0 CARGO_PROFILE_RELEASE_DEBUG=0 CARGO_TERM_COLOR=always CI=true GITHUB_ACTION_PATH=/home/github/79426228203/actions/RustPython-RustPython/./.github/actions/install-macos-deps RUST_BACKTRACE=full "${CURRENT_ENV[@]}" INPUT_AUTOCONF=true INPUT_AUTOMAKE=true INPUT_LIBTOOL=true INPUT_OPENSSL=false \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run ./.github/actions/install-macos-deps
echo "##[endgroup]"
echo /home/github/79426228203/steps/bugswarm_3_composite.sh > /home/github/79426228203/steps/bugswarm_3.sh
chmod u+x /home/github/79426228203/steps/bugswarm_3.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=3 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=RustPython/RustPython GITHUB_ACTIONS=true GITHUB_ACTOR=youknowone GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/main GITHUB_REF_NAME=main GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=RustPython/RustPython GITHUB_REPOSITORY_OWNER=RustPython GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=99bfbad8ee804980f6e5cd749ca937328bf2f819 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_ARGS='--no-default-features --features stdlib,importlib,stdio,encodings,sqlite,ssl-rustls-aws-lc,host_env' CARGO_ARGS_NO_SSL='--no-default-features --features stdlib,importlib,stdio,encodings,sqlite,host_env' WORKSPACE_EXCLUDES='--exclude rustpython_wasm --exclude rustpython-compiler-source --exclude rustpython-venvlauncher' X86_64_PC_WINDOWS_MSVC_OPENSSL_LIB_DIR='C:\Program Files\OpenSSL\lib\VC\x64\MD' X86_64_PC_WINDOWS_MSVC_OPENSSL_INCLUDE_DIR='C:\Program Files\OpenSSL\include' CARGO_INCREMENTAL=0 CARGO_PROFILE_TEST_DEBUG=0 CARGO_PROFILE_DEV_DEBUG=0 CARGO_PROFILE_RELEASE_DEBUG=0 CARGO_TERM_COLOR=always CI=true GITHUB_ACTION_PATH=/home/github/79426228203/actions/RustPython-RustPython/./.github/actions/install-macos-deps RUST_BACKTRACE=full "${CURRENT_ENV[@]}" INPUT_AUTOCONF=true INPUT_AUTOMAKE=true INPUT_LIBTOOL=true INPUT_OPENSSL=false \
bash -e /home/github/79426228203/steps/bugswarm_3.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=3 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=RustPython/RustPython GITHUB_ACTIONS=true GITHUB_ACTOR=youknowone GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/main GITHUB_REF_NAME=main GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=RustPython/RustPython GITHUB_REPOSITORY_OWNER=RustPython GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=99bfbad8ee804980f6e5cd749ca937328bf2f819 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_ARGS='--no-default-features --features stdlib,importlib,stdio,encodings,sqlite,ssl-rustls-aws-lc,host_env' CARGO_ARGS_NO_SSL='--no-default-features --features stdlib,importlib,stdio,encodings,sqlite,host_env' WORKSPACE_EXCLUDES='--exclude rustpython_wasm --exclude rustpython-compiler-source --exclude rustpython-venvlauncher' X86_64_PC_WINDOWS_MSVC_OPENSSL_LIB_DIR='C:\Program Files\OpenSSL\lib\VC\x64\MD' X86_64_PC_WINDOWS_MSVC_OPENSSL_INCLUDE_DIR='C:\Program Files\OpenSSL\include' CARGO_INCREMENTAL=0 CARGO_PROFILE_TEST_DEBUG=0 CARGO_PROFILE_DEV_DEBUG=0 CARGO_PROFILE_RELEASE_DEBUG=0 CARGO_TERM_COLOR=always CI=true GITHUB_ACTION_PATH=/home/github/79426228203/actions/RustPython-RustPython/./.github/actions/install-macos-deps RUST_BACKTRACE=full "${CURRENT_ENV[@]}" INPUT_AUTOCONF=true INPUT_AUTOMAKE=true INPUT_LIBTOOL=true INPUT_OPENSSL=false \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=3 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=RustPython/RustPython GITHUB_ACTIONS=true GITHUB_ACTOR=youknowone GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/main GITHUB_REF_NAME=main GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=RustPython/RustPython GITHUB_REPOSITORY_OWNER=RustPython GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=99bfbad8ee804980f6e5cd749ca937328bf2f819 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_ARGS='--no-default-features --features stdlib,importlib,stdio,encodings,sqlite,ssl-rustls-aws-lc,host_env' CARGO_ARGS_NO_SSL='--no-default-features --features stdlib,importlib,stdio,encodings,sqlite,host_env' WORKSPACE_EXCLUDES='--exclude rustpython_wasm --exclude rustpython-compiler-source --exclude rustpython-venvlauncher' X86_64_PC_WINDOWS_MSVC_OPENSSL_LIB_DIR='C:\Program Files\OpenSSL\lib\VC\x64\MD' X86_64_PC_WINDOWS_MSVC_OPENSSL_INCLUDE_DIR='C:\Program Files\OpenSSL\include' CARGO_INCREMENTAL=0 CARGO_PROFILE_TEST_DEBUG=0 CARGO_PROFILE_DEV_DEBUG=0 CARGO_PROFILE_RELEASE_DEBUG=0 CARGO_TERM_COLOR=always CI=true GITHUB_ACTION_PATH=/home/github/79426228203/actions/RustPython-RustPython/./.github/actions/install-macos-deps RUST_BACKTRACE=full "${CURRENT_ENV[@]}" INPUT_AUTOCONF=true INPUT_AUTOMAKE=true INPUT_LIBTOOL=true INPUT_OPENSSL=false \
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=4 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=youknowone GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/main GITHUB_REF_NAME=main GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=RustPython/RustPython GITHUB_REPOSITORY_OWNER=RustPython GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=99bfbad8ee804980f6e5cd749ca937328bf2f819 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_ARGS='--no-default-features --features stdlib,importlib,stdio,encodings,sqlite,ssl-rustls-aws-lc,host_env' CARGO_ARGS_NO_SSL='--no-default-features --features stdlib,importlib,stdio,encodings,sqlite,host_env' WORKSPACE_EXCLUDES='--exclude rustpython_wasm --exclude rustpython-compiler-source --exclude rustpython-venvlauncher' X86_64_PC_WINDOWS_MSVC_OPENSSL_LIB_DIR='C:\Program Files\OpenSSL\lib\VC\x64\MD' X86_64_PC_WINDOWS_MSVC_OPENSSL_INCLUDE_DIR='C:\Program Files\OpenSSL\include' CARGO_INCREMENTAL=0 CARGO_PROFILE_TEST_DEBUG=0 CARGO_PROFILE_DEV_DEBUG=0 CARGO_PROFILE_RELEASE_DEBUG=0 CARGO_TERM_COLOR=always CI=true RUST_BACKTRACE=full "${CURRENT_ENV[@]}" INSTA_WORKSPACE_ROOT=${GITHUB_WORKSPACE} \
echo $(test "$_GITHUB_JOB_STATUS" = "success" && echo true || echo false))
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=4 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=youknowone GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/main GITHUB_REF_NAME=main GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=RustPython/RustPython GITHUB_REPOSITORY_OWNER=RustPython GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=99bfbad8ee804980f6e5cd749ca937328bf2f819 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_ARGS='--no-default-features --features stdlib,importlib,stdio,encodings,sqlite,ssl-rustls-aws-lc,host_env' CARGO_ARGS_NO_SSL='--no-default-features --features stdlib,importlib,stdio,encodings,sqlite,host_env' WORKSPACE_EXCLUDES='--exclude rustpython_wasm --exclude rustpython-compiler-source --exclude rustpython-venvlauncher' X86_64_PC_WINDOWS_MSVC_OPENSSL_LIB_DIR='C:\Program Files\OpenSSL\lib\VC\x64\MD' X86_64_PC_WINDOWS_MSVC_OPENSSL_INCLUDE_DIR='C:\Program Files\OpenSSL\include' CARGO_INCREMENTAL=0 CARGO_PROFILE_TEST_DEBUG=0 CARGO_PROFILE_DEV_DEBUG=0 CARGO_PROFILE_RELEASE_DEBUG=0 CARGO_TERM_COLOR=always CI=true RUST_BACKTRACE=full "${CURRENT_ENV[@]}" INSTA_WORKSPACE_ROOT=${GITHUB_WORKSPACE} \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run 'cargo test --workspace --exclude rustpython-capi '"$(test -v "CURRENT_ENV_MAP[WORKSPACE_EXCLUDES]" && echo "${CURRENT_ENV_MAP[WORKSPACE_EXCLUDES]}" || echo '--exclude rustpython_wasm --exclude rustpython-compiler-source --exclude rustpython-venvlauncher')"' --features threading '"$(test -v "CURRENT_ENV_MAP[CARGO_ARGS]" && echo "${CURRENT_ENV_MAP[CARGO_ARGS]}" || echo '--no-default-features --features stdlib,importlib,stdio,encodings,sqlite,ssl-rustls-aws-lc,host_env')"
echo "##[endgroup]"
echo 'cargo test --workspace --exclude rustpython-capi '"$(test -v "CURRENT_ENV_MAP[WORKSPACE_EXCLUDES]" && echo "${CURRENT_ENV_MAP[WORKSPACE_EXCLUDES]}" || echo '--exclude rustpython_wasm --exclude rustpython-compiler-source --exclude rustpython-venvlauncher')"' --features threading '"$(test -v "CURRENT_ENV_MAP[CARGO_ARGS]" && echo "${CURRENT_ENV_MAP[CARGO_ARGS]}" || echo '--no-default-features --features stdlib,importlib,stdio,encodings,sqlite,ssl-rustls-aws-lc,host_env')" > /home/github/79426228203/steps/bugswarm_4.sh
chmod u+x /home/github/79426228203/steps/bugswarm_4.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=4 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=youknowone GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/main GITHUB_REF_NAME=main GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=RustPython/RustPython GITHUB_REPOSITORY_OWNER=RustPython GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=99bfbad8ee804980f6e5cd749ca937328bf2f819 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_ARGS='--no-default-features --features stdlib,importlib,stdio,encodings,sqlite,ssl-rustls-aws-lc,host_env' CARGO_ARGS_NO_SSL='--no-default-features --features stdlib,importlib,stdio,encodings,sqlite,host_env' WORKSPACE_EXCLUDES='--exclude rustpython_wasm --exclude rustpython-compiler-source --exclude rustpython-venvlauncher' X86_64_PC_WINDOWS_MSVC_OPENSSL_LIB_DIR='C:\Program Files\OpenSSL\lib\VC\x64\MD' X86_64_PC_WINDOWS_MSVC_OPENSSL_INCLUDE_DIR='C:\Program Files\OpenSSL\include' CARGO_INCREMENTAL=0 CARGO_PROFILE_TEST_DEBUG=0 CARGO_PROFILE_DEV_DEBUG=0 CARGO_PROFILE_RELEASE_DEBUG=0 CARGO_TERM_COLOR=always CI=true RUST_BACKTRACE=full "${CURRENT_ENV[@]}" INSTA_WORKSPACE_ROOT=${GITHUB_WORKSPACE} \
bash -e /home/github/79426228203/steps/bugswarm_4.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=4 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=youknowone GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/main GITHUB_REF_NAME=main GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=RustPython/RustPython GITHUB_REPOSITORY_OWNER=RustPython GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=99bfbad8ee804980f6e5cd749ca937328bf2f819 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_ARGS='--no-default-features --features stdlib,importlib,stdio,encodings,sqlite,ssl-rustls-aws-lc,host_env' CARGO_ARGS_NO_SSL='--no-default-features --features stdlib,importlib,stdio,encodings,sqlite,host_env' WORKSPACE_EXCLUDES='--exclude rustpython_wasm --exclude rustpython-compiler-source --exclude rustpython-venvlauncher' X86_64_PC_WINDOWS_MSVC_OPENSSL_LIB_DIR='C:\Program Files\OpenSSL\lib\VC\x64\MD' X86_64_PC_WINDOWS_MSVC_OPENSSL_INCLUDE_DIR='C:\Program Files\OpenSSL\include' CARGO_INCREMENTAL=0 CARGO_PROFILE_TEST_DEBUG=0 CARGO_PROFILE_DEV_DEBUG=0 CARGO_PROFILE_RELEASE_DEBUG=0 CARGO_TERM_COLOR=always CI=true RUST_BACKTRACE=full "${CURRENT_ENV[@]}" INSTA_WORKSPACE_ROOT=${GITHUB_WORKSPACE} \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=4 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=youknowone GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/main GITHUB_REF_NAME=main GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=RustPython/RustPython GITHUB_REPOSITORY_OWNER=RustPython GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=99bfbad8ee804980f6e5cd749ca937328bf2f819 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_ARGS='--no-default-features --features stdlib,importlib,stdio,encodings,sqlite,ssl-rustls-aws-lc,host_env' CARGO_ARGS_NO_SSL='--no-default-features --features stdlib,importlib,stdio,encodings,sqlite,host_env' WORKSPACE_EXCLUDES='--exclude rustpython_wasm --exclude rustpython-compiler-source --exclude rustpython-venvlauncher' X86_64_PC_WINDOWS_MSVC_OPENSSL_LIB_DIR='C:\Program Files\OpenSSL\lib\VC\x64\MD' X86_64_PC_WINDOWS_MSVC_OPENSSL_INCLUDE_DIR='C:\Program Files\OpenSSL\include' CARGO_INCREMENTAL=0 CARGO_PROFILE_TEST_DEBUG=0 CARGO_PROFILE_DEV_DEBUG=0 CARGO_PROFILE_RELEASE_DEBUG=0 CARGO_TERM_COLOR=always CI=true RUST_BACKTRACE=full "${CURRENT_ENV[@]}" INSTA_WORKSPACE_ROOT=${GITHUB_WORKSPACE} \
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=5 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=youknowone GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/main GITHUB_REF_NAME=main GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=RustPython/RustPython GITHUB_REPOSITORY_OWNER=RustPython GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=99bfbad8ee804980f6e5cd749ca937328bf2f819 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_ARGS='--no-default-features --features stdlib,importlib,stdio,encodings,sqlite,ssl-rustls-aws-lc,host_env' CARGO_ARGS_NO_SSL='--no-default-features --features stdlib,importlib,stdio,encodings,sqlite,host_env' WORKSPACE_EXCLUDES='--exclude rustpython_wasm --exclude rustpython-compiler-source --exclude rustpython-venvlauncher' X86_64_PC_WINDOWS_MSVC_OPENSSL_LIB_DIR='C:\Program Files\OpenSSL\lib\VC\x64\MD' X86_64_PC_WINDOWS_MSVC_OPENSSL_INCLUDE_DIR='C:\Program Files\OpenSSL\include' CARGO_INCREMENTAL=0 CARGO_PROFILE_TEST_DEBUG=0 CARGO_PROFILE_DEV_DEBUG=0 CARGO_PROFILE_RELEASE_DEBUG=0 CARGO_TERM_COLOR=always CI=true RUST_BACKTRACE=full "${CURRENT_ENV[@]}" \
echo "$(/home/github/79426228203/helpers/eval_expression p:'(' f:success p:'(' p:')' p:')' o:'&&' p:'(' s:Linux o:'!=' s:Windows p:')')")
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=5 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=youknowone GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/main GITHUB_REF_NAME=main GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=RustPython/RustPython GITHUB_REPOSITORY_OWNER=RustPython GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=99bfbad8ee804980f6e5cd749ca937328bf2f819 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_ARGS='--no-default-features --features stdlib,importlib,stdio,encodings,sqlite,ssl-rustls-aws-lc,host_env' CARGO_ARGS_NO_SSL='--no-default-features --features stdlib,importlib,stdio,encodings,sqlite,host_env' WORKSPACE_EXCLUDES='--exclude rustpython_wasm --exclude rustpython-compiler-source --exclude rustpython-venvlauncher' X86_64_PC_WINDOWS_MSVC_OPENSSL_LIB_DIR='C:\Program Files\OpenSSL\lib\VC\x64\MD' X86_64_PC_WINDOWS_MSVC_OPENSSL_INCLUDE_DIR='C:\Program Files\OpenSSL\include' CARGO_INCREMENTAL=0 CARGO_PROFILE_TEST_DEBUG=0 CARGO_PROFILE_DEV_DEBUG=0 CARGO_PROFILE_RELEASE_DEBUG=0 CARGO_TERM_COLOR=always CI=true RUST_BACKTRACE=full "${CURRENT_ENV[@]}" \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run 'cargo test'
echo "##[endgroup]"
echo 'cargo test' > /home/github/79426228203/steps/bugswarm_5.sh
chmod u+x /home/github/79426228203/steps/bugswarm_5.sh

pushd $(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=5 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=youknowone GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/main GITHUB_REF_NAME=main GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=RustPython/RustPython GITHUB_REPOSITORY_OWNER=RustPython GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=99bfbad8ee804980f6e5cd749ca937328bf2f819 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_ARGS='--no-default-features --features stdlib,importlib,stdio,encodings,sqlite,ssl-rustls-aws-lc,host_env' CARGO_ARGS_NO_SSL='--no-default-features --features stdlib,importlib,stdio,encodings,sqlite,host_env' WORKSPACE_EXCLUDES='--exclude rustpython_wasm --exclude rustpython-compiler-source --exclude rustpython-venvlauncher' X86_64_PC_WINDOWS_MSVC_OPENSSL_LIB_DIR='C:\Program Files\OpenSSL\lib\VC\x64\MD' X86_64_PC_WINDOWS_MSVC_OPENSSL_INCLUDE_DIR='C:\Program Files\OpenSSL\include' CARGO_INCREMENTAL=0 CARGO_PROFILE_TEST_DEBUG=0 CARGO_PROFILE_DEV_DEBUG=0 CARGO_PROFILE_RELEASE_DEBUG=0 CARGO_TERM_COLOR=always CI=true RUST_BACKTRACE=full "${CURRENT_ENV[@]}" \
echo crates/capi) > /dev/null
EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=5 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=youknowone GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/main GITHUB_REF_NAME=main GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=RustPython/RustPython GITHUB_REPOSITORY_OWNER=RustPython GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=99bfbad8ee804980f6e5cd749ca937328bf2f819 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_ARGS='--no-default-features --features stdlib,importlib,stdio,encodings,sqlite,ssl-rustls-aws-lc,host_env' CARGO_ARGS_NO_SSL='--no-default-features --features stdlib,importlib,stdio,encodings,sqlite,host_env' WORKSPACE_EXCLUDES='--exclude rustpython_wasm --exclude rustpython-compiler-source --exclude rustpython-venvlauncher' X86_64_PC_WINDOWS_MSVC_OPENSSL_LIB_DIR='C:\Program Files\OpenSSL\lib\VC\x64\MD' X86_64_PC_WINDOWS_MSVC_OPENSSL_INCLUDE_DIR='C:\Program Files\OpenSSL\include' CARGO_INCREMENTAL=0 CARGO_PROFILE_TEST_DEBUG=0 CARGO_PROFILE_DEV_DEBUG=0 CARGO_PROFILE_RELEASE_DEBUG=0 CARGO_TERM_COLOR=always CI=true RUST_BACKTRACE=full "${CURRENT_ENV[@]}" \
bash -e /home/github/79426228203/steps/bugswarm_5.sh
EXIT_CODE=$?
popd > /dev/null

if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=5 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=youknowone GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/main GITHUB_REF_NAME=main GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=RustPython/RustPython GITHUB_REPOSITORY_OWNER=RustPython GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=99bfbad8ee804980f6e5cd749ca937328bf2f819 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_ARGS='--no-default-features --features stdlib,importlib,stdio,encodings,sqlite,ssl-rustls-aws-lc,host_env' CARGO_ARGS_NO_SSL='--no-default-features --features stdlib,importlib,stdio,encodings,sqlite,host_env' WORKSPACE_EXCLUDES='--exclude rustpython_wasm --exclude rustpython-compiler-source --exclude rustpython-venvlauncher' X86_64_PC_WINDOWS_MSVC_OPENSSL_LIB_DIR='C:\Program Files\OpenSSL\lib\VC\x64\MD' X86_64_PC_WINDOWS_MSVC_OPENSSL_INCLUDE_DIR='C:\Program Files\OpenSSL\include' CARGO_INCREMENTAL=0 CARGO_PROFILE_TEST_DEBUG=0 CARGO_PROFILE_DEV_DEBUG=0 CARGO_PROFILE_RELEASE_DEBUG=0 CARGO_TERM_COLOR=always CI=true RUST_BACKTRACE=full "${CURRENT_ENV[@]}" \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=5 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=youknowone GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/main GITHUB_REF_NAME=main GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=RustPython/RustPython GITHUB_REPOSITORY_OWNER=RustPython GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=99bfbad8ee804980f6e5cd749ca937328bf2f819 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_ARGS='--no-default-features --features stdlib,importlib,stdio,encodings,sqlite,ssl-rustls-aws-lc,host_env' CARGO_ARGS_NO_SSL='--no-default-features --features stdlib,importlib,stdio,encodings,sqlite,host_env' WORKSPACE_EXCLUDES='--exclude rustpython_wasm --exclude rustpython-compiler-source --exclude rustpython-venvlauncher' X86_64_PC_WINDOWS_MSVC_OPENSSL_LIB_DIR='C:\Program Files\OpenSSL\lib\VC\x64\MD' X86_64_PC_WINDOWS_MSVC_OPENSSL_INCLUDE_DIR='C:\Program Files\OpenSSL\include' CARGO_INCREMENTAL=0 CARGO_PROFILE_TEST_DEBUG=0 CARGO_PROFILE_DEV_DEBUG=0 CARGO_PROFILE_RELEASE_DEBUG=0 CARGO_TERM_COLOR=always CI=true RUST_BACKTRACE=full "${CURRENT_ENV[@]}" \
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=6 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=youknowone GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/main GITHUB_REF_NAME=main GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=RustPython/RustPython GITHUB_REPOSITORY_OWNER=RustPython GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=99bfbad8ee804980f6e5cd749ca937328bf2f819 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_ARGS='--no-default-features --features stdlib,importlib,stdio,encodings,sqlite,ssl-rustls-aws-lc,host_env' CARGO_ARGS_NO_SSL='--no-default-features --features stdlib,importlib,stdio,encodings,sqlite,host_env' WORKSPACE_EXCLUDES='--exclude rustpython_wasm --exclude rustpython-compiler-source --exclude rustpython-venvlauncher' X86_64_PC_WINDOWS_MSVC_OPENSSL_LIB_DIR='C:\Program Files\OpenSSL\lib\VC\x64\MD' X86_64_PC_WINDOWS_MSVC_OPENSSL_INCLUDE_DIR='C:\Program Files\OpenSSL\include' CARGO_INCREMENTAL=0 CARGO_PROFILE_TEST_DEBUG=0 CARGO_PROFILE_DEV_DEBUG=0 CARGO_PROFILE_RELEASE_DEBUG=0 CARGO_TERM_COLOR=always CI=true RUST_BACKTRACE=full "${CURRENT_ENV[@]}" \
echo "$(/home/github/79426228203/helpers/eval_expression p:'(' f:success p:'(' p:')' p:')' o:'&&' p:'(' s:Linux o:== s:Linux p:')')")
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=6 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=youknowone GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/main GITHUB_REF_NAME=main GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=RustPython/RustPython GITHUB_REPOSITORY_OWNER=RustPython GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=99bfbad8ee804980f6e5cd749ca937328bf2f819 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_ARGS='--no-default-features --features stdlib,importlib,stdio,encodings,sqlite,ssl-rustls-aws-lc,host_env' CARGO_ARGS_NO_SSL='--no-default-features --features stdlib,importlib,stdio,encodings,sqlite,host_env' WORKSPACE_EXCLUDES='--exclude rustpython_wasm --exclude rustpython-compiler-source --exclude rustpython-venvlauncher' X86_64_PC_WINDOWS_MSVC_OPENSSL_LIB_DIR='C:\Program Files\OpenSSL\lib\VC\x64\MD' X86_64_PC_WINDOWS_MSVC_OPENSSL_INCLUDE_DIR='C:\Program Files\OpenSSL\include' CARGO_INCREMENTAL=0 CARGO_PROFILE_TEST_DEBUG=0 CARGO_PROFILE_DEV_DEBUG=0 CARGO_PROFILE_RELEASE_DEBUG=0 CARGO_TERM_COLOR=always CI=true RUST_BACKTRACE=full "${CURRENT_ENV[@]}" \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run 'cargo check -p rustpython-vm --no-default-features --features compiler'
echo "##[endgroup]"
echo 'cargo check -p rustpython-vm --no-default-features --features compiler
cargo check -p rustpython-stdlib --no-default-features --features compiler
cargo build --no-default-features --features stdlib,importlib,stdio,encodings,freeze-stdlib
' > /home/github/79426228203/steps/bugswarm_6.sh
chmod u+x /home/github/79426228203/steps/bugswarm_6.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=6 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=youknowone GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/main GITHUB_REF_NAME=main GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=RustPython/RustPython GITHUB_REPOSITORY_OWNER=RustPython GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=99bfbad8ee804980f6e5cd749ca937328bf2f819 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_ARGS='--no-default-features --features stdlib,importlib,stdio,encodings,sqlite,ssl-rustls-aws-lc,host_env' CARGO_ARGS_NO_SSL='--no-default-features --features stdlib,importlib,stdio,encodings,sqlite,host_env' WORKSPACE_EXCLUDES='--exclude rustpython_wasm --exclude rustpython-compiler-source --exclude rustpython-venvlauncher' X86_64_PC_WINDOWS_MSVC_OPENSSL_LIB_DIR='C:\Program Files\OpenSSL\lib\VC\x64\MD' X86_64_PC_WINDOWS_MSVC_OPENSSL_INCLUDE_DIR='C:\Program Files\OpenSSL\include' CARGO_INCREMENTAL=0 CARGO_PROFILE_TEST_DEBUG=0 CARGO_PROFILE_DEV_DEBUG=0 CARGO_PROFILE_RELEASE_DEBUG=0 CARGO_TERM_COLOR=always CI=true RUST_BACKTRACE=full "${CURRENT_ENV[@]}" \
bash -e /home/github/79426228203/steps/bugswarm_6.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=6 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=youknowone GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/main GITHUB_REF_NAME=main GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=RustPython/RustPython GITHUB_REPOSITORY_OWNER=RustPython GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=99bfbad8ee804980f6e5cd749ca937328bf2f819 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_ARGS='--no-default-features --features stdlib,importlib,stdio,encodings,sqlite,ssl-rustls-aws-lc,host_env' CARGO_ARGS_NO_SSL='--no-default-features --features stdlib,importlib,stdio,encodings,sqlite,host_env' WORKSPACE_EXCLUDES='--exclude rustpython_wasm --exclude rustpython-compiler-source --exclude rustpython-venvlauncher' X86_64_PC_WINDOWS_MSVC_OPENSSL_LIB_DIR='C:\Program Files\OpenSSL\lib\VC\x64\MD' X86_64_PC_WINDOWS_MSVC_OPENSSL_INCLUDE_DIR='C:\Program Files\OpenSSL\include' CARGO_INCREMENTAL=0 CARGO_PROFILE_TEST_DEBUG=0 CARGO_PROFILE_DEV_DEBUG=0 CARGO_PROFILE_RELEASE_DEBUG=0 CARGO_TERM_COLOR=always CI=true RUST_BACKTRACE=full "${CURRENT_ENV[@]}" \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=6 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=youknowone GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/main GITHUB_REF_NAME=main GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=RustPython/RustPython GITHUB_REPOSITORY_OWNER=RustPython GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=99bfbad8ee804980f6e5cd749ca937328bf2f819 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_ARGS='--no-default-features --features stdlib,importlib,stdio,encodings,sqlite,ssl-rustls-aws-lc,host_env' CARGO_ARGS_NO_SSL='--no-default-features --features stdlib,importlib,stdio,encodings,sqlite,host_env' WORKSPACE_EXCLUDES='--exclude rustpython_wasm --exclude rustpython-compiler-source --exclude rustpython-venvlauncher' X86_64_PC_WINDOWS_MSVC_OPENSSL_LIB_DIR='C:\Program Files\OpenSSL\lib\VC\x64\MD' X86_64_PC_WINDOWS_MSVC_OPENSSL_INCLUDE_DIR='C:\Program Files\OpenSSL\include' CARGO_INCREMENTAL=0 CARGO_PROFILE_TEST_DEBUG=0 CARGO_PROFILE_DEV_DEBUG=0 CARGO_PROFILE_RELEASE_DEBUG=0 CARGO_TERM_COLOR=always CI=true RUST_BACKTRACE=full "${CURRENT_ENV[@]}" \
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=7 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=youknowone GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/main GITHUB_REF_NAME=main GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=RustPython/RustPython GITHUB_REPOSITORY_OWNER=RustPython GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=99bfbad8ee804980f6e5cd749ca937328bf2f819 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_ARGS='--no-default-features --features stdlib,importlib,stdio,encodings,sqlite,ssl-rustls-aws-lc,host_env' CARGO_ARGS_NO_SSL='--no-default-features --features stdlib,importlib,stdio,encodings,sqlite,host_env' WORKSPACE_EXCLUDES='--exclude rustpython_wasm --exclude rustpython-compiler-source --exclude rustpython-venvlauncher' X86_64_PC_WINDOWS_MSVC_OPENSSL_LIB_DIR='C:\Program Files\OpenSSL\lib\VC\x64\MD' X86_64_PC_WINDOWS_MSVC_OPENSSL_INCLUDE_DIR='C:\Program Files\OpenSSL\include' CARGO_INCREMENTAL=0 CARGO_PROFILE_TEST_DEBUG=0 CARGO_PROFILE_DEV_DEBUG=0 CARGO_PROFILE_RELEASE_DEBUG=0 CARGO_TERM_COLOR=always CI=true RUST_BACKTRACE=full "${CURRENT_ENV[@]}" \
echo "$(/home/github/79426228203/helpers/eval_expression p:'(' f:success p:'(' p:')' p:')' o:'&&' p:'(' s:Linux o:== s:Linux p:')')")
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=7 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=youknowone GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/main GITHUB_REF_NAME=main GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=RustPython/RustPython GITHUB_REPOSITORY_OWNER=RustPython GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=99bfbad8ee804980f6e5cd749ca937328bf2f819 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_ARGS='--no-default-features --features stdlib,importlib,stdio,encodings,sqlite,ssl-rustls-aws-lc,host_env' CARGO_ARGS_NO_SSL='--no-default-features --features stdlib,importlib,stdio,encodings,sqlite,host_env' WORKSPACE_EXCLUDES='--exclude rustpython_wasm --exclude rustpython-compiler-source --exclude rustpython-venvlauncher' X86_64_PC_WINDOWS_MSVC_OPENSSL_LIB_DIR='C:\Program Files\OpenSSL\lib\VC\x64\MD' X86_64_PC_WINDOWS_MSVC_OPENSSL_INCLUDE_DIR='C:\Program Files\OpenSSL\include' CARGO_INCREMENTAL=0 CARGO_PROFILE_TEST_DEBUG=0 CARGO_PROFILE_DEV_DEBUG=0 CARGO_PROFILE_RELEASE_DEBUG=0 CARGO_TERM_COLOR=always CI=true RUST_BACKTRACE=full "${CURRENT_ENV[@]}" \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run 'target/debug/rustpython extra_tests/snippets/sandbox_smoke.py'
echo "##[endgroup]"
echo 'target/debug/rustpython extra_tests/snippets/sandbox_smoke.py
target/debug/rustpython extra_tests/snippets/stdlib_re.py
' > /home/github/79426228203/steps/bugswarm_7.sh
chmod u+x /home/github/79426228203/steps/bugswarm_7.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=7 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=youknowone GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/main GITHUB_REF_NAME=main GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=RustPython/RustPython GITHUB_REPOSITORY_OWNER=RustPython GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=99bfbad8ee804980f6e5cd749ca937328bf2f819 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_ARGS='--no-default-features --features stdlib,importlib,stdio,encodings,sqlite,ssl-rustls-aws-lc,host_env' CARGO_ARGS_NO_SSL='--no-default-features --features stdlib,importlib,stdio,encodings,sqlite,host_env' WORKSPACE_EXCLUDES='--exclude rustpython_wasm --exclude rustpython-compiler-source --exclude rustpython-venvlauncher' X86_64_PC_WINDOWS_MSVC_OPENSSL_LIB_DIR='C:\Program Files\OpenSSL\lib\VC\x64\MD' X86_64_PC_WINDOWS_MSVC_OPENSSL_INCLUDE_DIR='C:\Program Files\OpenSSL\include' CARGO_INCREMENTAL=0 CARGO_PROFILE_TEST_DEBUG=0 CARGO_PROFILE_DEV_DEBUG=0 CARGO_PROFILE_RELEASE_DEBUG=0 CARGO_TERM_COLOR=always CI=true RUST_BACKTRACE=full "${CURRENT_ENV[@]}" \
bash -e /home/github/79426228203/steps/bugswarm_7.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=7 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=youknowone GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/main GITHUB_REF_NAME=main GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=RustPython/RustPython GITHUB_REPOSITORY_OWNER=RustPython GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=99bfbad8ee804980f6e5cd749ca937328bf2f819 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_ARGS='--no-default-features --features stdlib,importlib,stdio,encodings,sqlite,ssl-rustls-aws-lc,host_env' CARGO_ARGS_NO_SSL='--no-default-features --features stdlib,importlib,stdio,encodings,sqlite,host_env' WORKSPACE_EXCLUDES='--exclude rustpython_wasm --exclude rustpython-compiler-source --exclude rustpython-venvlauncher' X86_64_PC_WINDOWS_MSVC_OPENSSL_LIB_DIR='C:\Program Files\OpenSSL\lib\VC\x64\MD' X86_64_PC_WINDOWS_MSVC_OPENSSL_INCLUDE_DIR='C:\Program Files\OpenSSL\include' CARGO_INCREMENTAL=0 CARGO_PROFILE_TEST_DEBUG=0 CARGO_PROFILE_DEV_DEBUG=0 CARGO_PROFILE_RELEASE_DEBUG=0 CARGO_TERM_COLOR=always CI=true RUST_BACKTRACE=full "${CURRENT_ENV[@]}" \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=7 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=youknowone GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/main GITHUB_REF_NAME=main GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=RustPython/RustPython GITHUB_REPOSITORY_OWNER=RustPython GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=99bfbad8ee804980f6e5cd749ca937328bf2f819 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_ARGS='--no-default-features --features stdlib,importlib,stdio,encodings,sqlite,ssl-rustls-aws-lc,host_env' CARGO_ARGS_NO_SSL='--no-default-features --features stdlib,importlib,stdio,encodings,sqlite,host_env' WORKSPACE_EXCLUDES='--exclude rustpython_wasm --exclude rustpython-compiler-source --exclude rustpython-venvlauncher' X86_64_PC_WINDOWS_MSVC_OPENSSL_LIB_DIR='C:\Program Files\OpenSSL\lib\VC\x64\MD' X86_64_PC_WINDOWS_MSVC_OPENSSL_INCLUDE_DIR='C:\Program Files\OpenSSL\include' CARGO_INCREMENTAL=0 CARGO_PROFILE_TEST_DEBUG=0 CARGO_PROFILE_DEV_DEBUG=0 CARGO_PROFILE_RELEASE_DEBUG=0 CARGO_TERM_COLOR=always CI=true RUST_BACKTRACE=full "${CURRENT_ENV[@]}" \
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=8 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=youknowone GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/main GITHUB_REF_NAME=main GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=RustPython/RustPython GITHUB_REPOSITORY_OWNER=RustPython GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=99bfbad8ee804980f6e5cd749ca937328bf2f819 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_ARGS='--no-default-features --features stdlib,importlib,stdio,encodings,sqlite,ssl-rustls-aws-lc,host_env' CARGO_ARGS_NO_SSL='--no-default-features --features stdlib,importlib,stdio,encodings,sqlite,host_env' WORKSPACE_EXCLUDES='--exclude rustpython_wasm --exclude rustpython-compiler-source --exclude rustpython-venvlauncher' X86_64_PC_WINDOWS_MSVC_OPENSSL_LIB_DIR='C:\Program Files\OpenSSL\lib\VC\x64\MD' X86_64_PC_WINDOWS_MSVC_OPENSSL_INCLUDE_DIR='C:\Program Files\OpenSSL\include' CARGO_INCREMENTAL=0 CARGO_PROFILE_TEST_DEBUG=0 CARGO_PROFILE_DEV_DEBUG=0 CARGO_PROFILE_RELEASE_DEBUG=0 CARGO_TERM_COLOR=always CI=true RUST_BACKTRACE=full "${CURRENT_ENV[@]}" \
echo "$(/home/github/79426228203/helpers/eval_expression p:'(' f:success p:'(' p:')' p:')' o:'&&' p:'(' s:Linux o:== s:Linux p:')')")
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=8 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=youknowone GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/main GITHUB_REF_NAME=main GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=RustPython/RustPython GITHUB_REPOSITORY_OWNER=RustPython GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=99bfbad8ee804980f6e5cd749ca937328bf2f819 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_ARGS='--no-default-features --features stdlib,importlib,stdio,encodings,sqlite,ssl-rustls-aws-lc,host_env' CARGO_ARGS_NO_SSL='--no-default-features --features stdlib,importlib,stdio,encodings,sqlite,host_env' WORKSPACE_EXCLUDES='--exclude rustpython_wasm --exclude rustpython-compiler-source --exclude rustpython-venvlauncher' X86_64_PC_WINDOWS_MSVC_OPENSSL_LIB_DIR='C:\Program Files\OpenSSL\lib\VC\x64\MD' X86_64_PC_WINDOWS_MSVC_OPENSSL_INCLUDE_DIR='C:\Program Files\OpenSSL\include' CARGO_INCREMENTAL=0 CARGO_PROFILE_TEST_DEBUG=0 CARGO_PROFILE_DEV_DEBUG=0 CARGO_PROFILE_RELEASE_DEBUG=0 CARGO_TERM_COLOR=always CI=true RUST_BACKTRACE=full "${CURRENT_ENV[@]}" \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run 'cargo build --no-default-features --features ssl-openssl'
echo "##[endgroup]"
echo 'cargo build --no-default-features --features ssl-openssl' > /home/github/79426228203/steps/bugswarm_8.sh
chmod u+x /home/github/79426228203/steps/bugswarm_8.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=8 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=youknowone GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/main GITHUB_REF_NAME=main GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=RustPython/RustPython GITHUB_REPOSITORY_OWNER=RustPython GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=99bfbad8ee804980f6e5cd749ca937328bf2f819 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_ARGS='--no-default-features --features stdlib,importlib,stdio,encodings,sqlite,ssl-rustls-aws-lc,host_env' CARGO_ARGS_NO_SSL='--no-default-features --features stdlib,importlib,stdio,encodings,sqlite,host_env' WORKSPACE_EXCLUDES='--exclude rustpython_wasm --exclude rustpython-compiler-source --exclude rustpython-venvlauncher' X86_64_PC_WINDOWS_MSVC_OPENSSL_LIB_DIR='C:\Program Files\OpenSSL\lib\VC\x64\MD' X86_64_PC_WINDOWS_MSVC_OPENSSL_INCLUDE_DIR='C:\Program Files\OpenSSL\include' CARGO_INCREMENTAL=0 CARGO_PROFILE_TEST_DEBUG=0 CARGO_PROFILE_DEV_DEBUG=0 CARGO_PROFILE_RELEASE_DEBUG=0 CARGO_TERM_COLOR=always CI=true RUST_BACKTRACE=full "${CURRENT_ENV[@]}" \
bash -e /home/github/79426228203/steps/bugswarm_8.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=8 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=youknowone GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/main GITHUB_REF_NAME=main GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=RustPython/RustPython GITHUB_REPOSITORY_OWNER=RustPython GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=99bfbad8ee804980f6e5cd749ca937328bf2f819 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_ARGS='--no-default-features --features stdlib,importlib,stdio,encodings,sqlite,ssl-rustls-aws-lc,host_env' CARGO_ARGS_NO_SSL='--no-default-features --features stdlib,importlib,stdio,encodings,sqlite,host_env' WORKSPACE_EXCLUDES='--exclude rustpython_wasm --exclude rustpython-compiler-source --exclude rustpython-venvlauncher' X86_64_PC_WINDOWS_MSVC_OPENSSL_LIB_DIR='C:\Program Files\OpenSSL\lib\VC\x64\MD' X86_64_PC_WINDOWS_MSVC_OPENSSL_INCLUDE_DIR='C:\Program Files\OpenSSL\include' CARGO_INCREMENTAL=0 CARGO_PROFILE_TEST_DEBUG=0 CARGO_PROFILE_DEV_DEBUG=0 CARGO_PROFILE_RELEASE_DEBUG=0 CARGO_TERM_COLOR=always CI=true RUST_BACKTRACE=full "${CURRENT_ENV[@]}" \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=8 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=youknowone GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/main GITHUB_REF_NAME=main GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=RustPython/RustPython GITHUB_REPOSITORY_OWNER=RustPython GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=99bfbad8ee804980f6e5cd749ca937328bf2f819 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_ARGS='--no-default-features --features stdlib,importlib,stdio,encodings,sqlite,ssl-rustls-aws-lc,host_env' CARGO_ARGS_NO_SSL='--no-default-features --features stdlib,importlib,stdio,encodings,sqlite,host_env' WORKSPACE_EXCLUDES='--exclude rustpython_wasm --exclude rustpython-compiler-source --exclude rustpython-venvlauncher' X86_64_PC_WINDOWS_MSVC_OPENSSL_LIB_DIR='C:\Program Files\OpenSSL\lib\VC\x64\MD' X86_64_PC_WINDOWS_MSVC_OPENSSL_INCLUDE_DIR='C:\Program Files\OpenSSL\include' CARGO_INCREMENTAL=0 CARGO_PROFILE_TEST_DEBUG=0 CARGO_PROFILE_DEV_DEBUG=0 CARGO_PROFILE_RELEASE_DEBUG=0 CARGO_TERM_COLOR=always CI=true RUST_BACKTRACE=full "${CURRENT_ENV[@]}" \
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=9 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=youknowone GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/main GITHUB_REF_NAME=main GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=RustPython/RustPython GITHUB_REPOSITORY_OWNER=RustPython GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=99bfbad8ee804980f6e5cd749ca937328bf2f819 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_ARGS='--no-default-features --features stdlib,importlib,stdio,encodings,sqlite,ssl-rustls-aws-lc,host_env' CARGO_ARGS_NO_SSL='--no-default-features --features stdlib,importlib,stdio,encodings,sqlite,host_env' WORKSPACE_EXCLUDES='--exclude rustpython_wasm --exclude rustpython-compiler-source --exclude rustpython-venvlauncher' X86_64_PC_WINDOWS_MSVC_OPENSSL_LIB_DIR='C:\Program Files\OpenSSL\lib\VC\x64\MD' X86_64_PC_WINDOWS_MSVC_OPENSSL_INCLUDE_DIR='C:\Program Files\OpenSSL\include' CARGO_INCREMENTAL=0 CARGO_PROFILE_TEST_DEBUG=0 CARGO_PROFILE_DEV_DEBUG=0 CARGO_PROFILE_RELEASE_DEBUG=0 CARGO_TERM_COLOR=always CI=true RUST_BACKTRACE=full "${CURRENT_ENV[@]}" \
echo "$(/home/github/79426228203/helpers/eval_expression p:'(' f:success p:'(' p:')' p:')' o:'&&' p:'(' s:Linux o:== s:Linux p:')')")
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=9 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=youknowone GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/main GITHUB_REF_NAME=main GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=RustPython/RustPython GITHUB_REPOSITORY_OWNER=RustPython GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=99bfbad8ee804980f6e5cd749ca937328bf2f819 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_ARGS='--no-default-features --features stdlib,importlib,stdio,encodings,sqlite,ssl-rustls-aws-lc,host_env' CARGO_ARGS_NO_SSL='--no-default-features --features stdlib,importlib,stdio,encodings,sqlite,host_env' WORKSPACE_EXCLUDES='--exclude rustpython_wasm --exclude rustpython-compiler-source --exclude rustpython-venvlauncher' X86_64_PC_WINDOWS_MSVC_OPENSSL_LIB_DIR='C:\Program Files\OpenSSL\lib\VC\x64\MD' X86_64_PC_WINDOWS_MSVC_OPENSSL_INCLUDE_DIR='C:\Program Files\OpenSSL\include' CARGO_INCREMENTAL=0 CARGO_PROFILE_TEST_DEBUG=0 CARGO_PROFILE_DEV_DEBUG=0 CARGO_PROFILE_RELEASE_DEBUG=0 CARGO_TERM_COLOR=always CI=true RUST_BACKTRACE=full "${CURRENT_ENV[@]}" \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run 'cargo build --no-default-features --features ssl-openssl-vendor'
echo "##[endgroup]"
echo 'cargo build --no-default-features --features ssl-openssl-vendor' > /home/github/79426228203/steps/bugswarm_9.sh
chmod u+x /home/github/79426228203/steps/bugswarm_9.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=9 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=youknowone GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/main GITHUB_REF_NAME=main GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=RustPython/RustPython GITHUB_REPOSITORY_OWNER=RustPython GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=99bfbad8ee804980f6e5cd749ca937328bf2f819 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_ARGS='--no-default-features --features stdlib,importlib,stdio,encodings,sqlite,ssl-rustls-aws-lc,host_env' CARGO_ARGS_NO_SSL='--no-default-features --features stdlib,importlib,stdio,encodings,sqlite,host_env' WORKSPACE_EXCLUDES='--exclude rustpython_wasm --exclude rustpython-compiler-source --exclude rustpython-venvlauncher' X86_64_PC_WINDOWS_MSVC_OPENSSL_LIB_DIR='C:\Program Files\OpenSSL\lib\VC\x64\MD' X86_64_PC_WINDOWS_MSVC_OPENSSL_INCLUDE_DIR='C:\Program Files\OpenSSL\include' CARGO_INCREMENTAL=0 CARGO_PROFILE_TEST_DEBUG=0 CARGO_PROFILE_DEV_DEBUG=0 CARGO_PROFILE_RELEASE_DEBUG=0 CARGO_TERM_COLOR=always CI=true RUST_BACKTRACE=full "${CURRENT_ENV[@]}" \
bash -e /home/github/79426228203/steps/bugswarm_9.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=9 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=youknowone GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/main GITHUB_REF_NAME=main GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=RustPython/RustPython GITHUB_REPOSITORY_OWNER=RustPython GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=99bfbad8ee804980f6e5cd749ca937328bf2f819 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_ARGS='--no-default-features --features stdlib,importlib,stdio,encodings,sqlite,ssl-rustls-aws-lc,host_env' CARGO_ARGS_NO_SSL='--no-default-features --features stdlib,importlib,stdio,encodings,sqlite,host_env' WORKSPACE_EXCLUDES='--exclude rustpython_wasm --exclude rustpython-compiler-source --exclude rustpython-venvlauncher' X86_64_PC_WINDOWS_MSVC_OPENSSL_LIB_DIR='C:\Program Files\OpenSSL\lib\VC\x64\MD' X86_64_PC_WINDOWS_MSVC_OPENSSL_INCLUDE_DIR='C:\Program Files\OpenSSL\include' CARGO_INCREMENTAL=0 CARGO_PROFILE_TEST_DEBUG=0 CARGO_PROFILE_DEV_DEBUG=0 CARGO_PROFILE_RELEASE_DEBUG=0 CARGO_TERM_COLOR=always CI=true RUST_BACKTRACE=full "${CURRENT_ENV[@]}" \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=9 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=youknowone GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/main GITHUB_REF_NAME=main GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=RustPython/RustPython GITHUB_REPOSITORY_OWNER=RustPython GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=99bfbad8ee804980f6e5cd749ca937328bf2f819 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_ARGS='--no-default-features --features stdlib,importlib,stdio,encodings,sqlite,ssl-rustls-aws-lc,host_env' CARGO_ARGS_NO_SSL='--no-default-features --features stdlib,importlib,stdio,encodings,sqlite,host_env' WORKSPACE_EXCLUDES='--exclude rustpython_wasm --exclude rustpython-compiler-source --exclude rustpython-venvlauncher' X86_64_PC_WINDOWS_MSVC_OPENSSL_LIB_DIR='C:\Program Files\OpenSSL\lib\VC\x64\MD' X86_64_PC_WINDOWS_MSVC_OPENSSL_INCLUDE_DIR='C:\Program Files\OpenSSL\include' CARGO_INCREMENTAL=0 CARGO_PROFILE_TEST_DEBUG=0 CARGO_PROFILE_DEV_DEBUG=0 CARGO_PROFILE_RELEASE_DEBUG=0 CARGO_TERM_COLOR=always CI=true RUST_BACKTRACE=full "${CURRENT_ENV[@]}" \
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=10 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=youknowone GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/main GITHUB_REF_NAME=main GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=RustPython/RustPython GITHUB_REPOSITORY_OWNER=RustPython GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=99bfbad8ee804980f6e5cd749ca937328bf2f819 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_ARGS='--no-default-features --features stdlib,importlib,stdio,encodings,sqlite,ssl-rustls-aws-lc,host_env' CARGO_ARGS_NO_SSL='--no-default-features --features stdlib,importlib,stdio,encodings,sqlite,host_env' WORKSPACE_EXCLUDES='--exclude rustpython_wasm --exclude rustpython-compiler-source --exclude rustpython-venvlauncher' X86_64_PC_WINDOWS_MSVC_OPENSSL_LIB_DIR='C:\Program Files\OpenSSL\lib\VC\x64\MD' X86_64_PC_WINDOWS_MSVC_OPENSSL_INCLUDE_DIR='C:\Program Files\OpenSSL\include' CARGO_INCREMENTAL=0 CARGO_PROFILE_TEST_DEBUG=0 CARGO_PROFILE_DEV_DEBUG=0 CARGO_PROFILE_RELEASE_DEBUG=0 CARGO_TERM_COLOR=always CI=true RUST_BACKTRACE=full "${CURRENT_ENV[@]}" \
echo "$(/home/github/79426228203/helpers/eval_expression p:'(' f:success p:'(' p:')' p:')' o:'&&' p:'(' s:Linux o:== s:Linux p:')')")
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=10 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=youknowone GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/main GITHUB_REF_NAME=main GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=RustPython/RustPython GITHUB_REPOSITORY_OWNER=RustPython GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=99bfbad8ee804980f6e5cd749ca937328bf2f819 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_ARGS='--no-default-features --features stdlib,importlib,stdio,encodings,sqlite,ssl-rustls-aws-lc,host_env' CARGO_ARGS_NO_SSL='--no-default-features --features stdlib,importlib,stdio,encodings,sqlite,host_env' WORKSPACE_EXCLUDES='--exclude rustpython_wasm --exclude rustpython-compiler-source --exclude rustpython-venvlauncher' X86_64_PC_WINDOWS_MSVC_OPENSSL_LIB_DIR='C:\Program Files\OpenSSL\lib\VC\x64\MD' X86_64_PC_WINDOWS_MSVC_OPENSSL_INCLUDE_DIR='C:\Program Files\OpenSSL\include' CARGO_INCREMENTAL=0 CARGO_PROFILE_TEST_DEBUG=0 CARGO_PROFILE_DEV_DEBUG=0 CARGO_PROFILE_RELEASE_DEBUG=0 CARGO_TERM_COLOR=always CI=true RUST_BACKTRACE=full "${CURRENT_ENV[@]}" \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run 'cargo run --manifest-path example_projects/barebone/Cargo.toml'
echo "##[endgroup]"
echo 'cargo run --manifest-path example_projects/barebone/Cargo.toml
cargo run --manifest-path example_projects/frozen_stdlib/Cargo.toml
' > /home/github/79426228203/steps/bugswarm_10.sh
chmod u+x /home/github/79426228203/steps/bugswarm_10.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=10 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=youknowone GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/main GITHUB_REF_NAME=main GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=RustPython/RustPython GITHUB_REPOSITORY_OWNER=RustPython GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=99bfbad8ee804980f6e5cd749ca937328bf2f819 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_ARGS='--no-default-features --features stdlib,importlib,stdio,encodings,sqlite,ssl-rustls-aws-lc,host_env' CARGO_ARGS_NO_SSL='--no-default-features --features stdlib,importlib,stdio,encodings,sqlite,host_env' WORKSPACE_EXCLUDES='--exclude rustpython_wasm --exclude rustpython-compiler-source --exclude rustpython-venvlauncher' X86_64_PC_WINDOWS_MSVC_OPENSSL_LIB_DIR='C:\Program Files\OpenSSL\lib\VC\x64\MD' X86_64_PC_WINDOWS_MSVC_OPENSSL_INCLUDE_DIR='C:\Program Files\OpenSSL\include' CARGO_INCREMENTAL=0 CARGO_PROFILE_TEST_DEBUG=0 CARGO_PROFILE_DEV_DEBUG=0 CARGO_PROFILE_RELEASE_DEBUG=0 CARGO_TERM_COLOR=always CI=true RUST_BACKTRACE=full "${CURRENT_ENV[@]}" \
bash -e /home/github/79426228203/steps/bugswarm_10.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=10 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=youknowone GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/main GITHUB_REF_NAME=main GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=RustPython/RustPython GITHUB_REPOSITORY_OWNER=RustPython GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=99bfbad8ee804980f6e5cd749ca937328bf2f819 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_ARGS='--no-default-features --features stdlib,importlib,stdio,encodings,sqlite,ssl-rustls-aws-lc,host_env' CARGO_ARGS_NO_SSL='--no-default-features --features stdlib,importlib,stdio,encodings,sqlite,host_env' WORKSPACE_EXCLUDES='--exclude rustpython_wasm --exclude rustpython-compiler-source --exclude rustpython-venvlauncher' X86_64_PC_WINDOWS_MSVC_OPENSSL_LIB_DIR='C:\Program Files\OpenSSL\lib\VC\x64\MD' X86_64_PC_WINDOWS_MSVC_OPENSSL_INCLUDE_DIR='C:\Program Files\OpenSSL\include' CARGO_INCREMENTAL=0 CARGO_PROFILE_TEST_DEBUG=0 CARGO_PROFILE_DEV_DEBUG=0 CARGO_PROFILE_RELEASE_DEBUG=0 CARGO_TERM_COLOR=always CI=true RUST_BACKTRACE=full "${CURRENT_ENV[@]}" \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=10 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=youknowone GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/main GITHUB_REF_NAME=main GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=RustPython/RustPython GITHUB_REPOSITORY_OWNER=RustPython GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=99bfbad8ee804980f6e5cd749ca937328bf2f819 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_ARGS='--no-default-features --features stdlib,importlib,stdio,encodings,sqlite,ssl-rustls-aws-lc,host_env' CARGO_ARGS_NO_SSL='--no-default-features --features stdlib,importlib,stdio,encodings,sqlite,host_env' WORKSPACE_EXCLUDES='--exclude rustpython_wasm --exclude rustpython-compiler-source --exclude rustpython-venvlauncher' X86_64_PC_WINDOWS_MSVC_OPENSSL_LIB_DIR='C:\Program Files\OpenSSL\lib\VC\x64\MD' X86_64_PC_WINDOWS_MSVC_OPENSSL_INCLUDE_DIR='C:\Program Files\OpenSSL\include' CARGO_INCREMENTAL=0 CARGO_PROFILE_TEST_DEBUG=0 CARGO_PROFILE_DEV_DEBUG=0 CARGO_PROFILE_RELEASE_DEBUG=0 CARGO_TERM_COLOR=always CI=true RUST_BACKTRACE=full "${CURRENT_ENV[@]}" \
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=11 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=youknowone GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/main GITHUB_REF_NAME=main GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=RustPython/RustPython GITHUB_REPOSITORY_OWNER=RustPython GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=99bfbad8ee804980f6e5cd749ca937328bf2f819 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_ARGS='--no-default-features --features stdlib,importlib,stdio,encodings,sqlite,ssl-rustls-aws-lc,host_env' CARGO_ARGS_NO_SSL='--no-default-features --features stdlib,importlib,stdio,encodings,sqlite,host_env' WORKSPACE_EXCLUDES='--exclude rustpython_wasm --exclude rustpython-compiler-source --exclude rustpython-venvlauncher' X86_64_PC_WINDOWS_MSVC_OPENSSL_LIB_DIR='C:\Program Files\OpenSSL\lib\VC\x64\MD' X86_64_PC_WINDOWS_MSVC_OPENSSL_INCLUDE_DIR='C:\Program Files\OpenSSL\include' CARGO_INCREMENTAL=0 CARGO_PROFILE_TEST_DEBUG=0 CARGO_PROFILE_DEV_DEBUG=0 CARGO_PROFILE_RELEASE_DEBUG=0 CARGO_TERM_COLOR=always CI=true RUST_BACKTRACE=full "${CURRENT_ENV[@]}" PYTHONPATH=scripts \
echo "$(/home/github/79426228203/helpers/eval_expression p:'(' f:success p:'(' p:')' p:')' o:'&&' p:'(' s:Linux o:== s:Linux p:')')")
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=11 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=youknowone GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/main GITHUB_REF_NAME=main GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=RustPython/RustPython GITHUB_REPOSITORY_OWNER=RustPython GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=99bfbad8ee804980f6e5cd749ca937328bf2f819 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_ARGS='--no-default-features --features stdlib,importlib,stdio,encodings,sqlite,ssl-rustls-aws-lc,host_env' CARGO_ARGS_NO_SSL='--no-default-features --features stdlib,importlib,stdio,encodings,sqlite,host_env' WORKSPACE_EXCLUDES='--exclude rustpython_wasm --exclude rustpython-compiler-source --exclude rustpython-venvlauncher' X86_64_PC_WINDOWS_MSVC_OPENSSL_LIB_DIR='C:\Program Files\OpenSSL\lib\VC\x64\MD' X86_64_PC_WINDOWS_MSVC_OPENSSL_INCLUDE_DIR='C:\Program Files\OpenSSL\include' CARGO_INCREMENTAL=0 CARGO_PROFILE_TEST_DEBUG=0 CARGO_PROFILE_DEV_DEBUG=0 CARGO_PROFILE_RELEASE_DEBUG=0 CARGO_TERM_COLOR=always CI=true RUST_BACKTRACE=full "${CURRENT_ENV[@]}" PYTHONPATH=scripts \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run 'cargo run -- -m unittest discover -s scripts/update_lib/tests -v'
echo "##[endgroup]"
echo 'cargo run -- -m unittest discover -s scripts/update_lib/tests -v' > /home/github/79426228203/steps/bugswarm_11.sh
chmod u+x /home/github/79426228203/steps/bugswarm_11.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=11 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=youknowone GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/main GITHUB_REF_NAME=main GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=RustPython/RustPython GITHUB_REPOSITORY_OWNER=RustPython GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=99bfbad8ee804980f6e5cd749ca937328bf2f819 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_ARGS='--no-default-features --features stdlib,importlib,stdio,encodings,sqlite,ssl-rustls-aws-lc,host_env' CARGO_ARGS_NO_SSL='--no-default-features --features stdlib,importlib,stdio,encodings,sqlite,host_env' WORKSPACE_EXCLUDES='--exclude rustpython_wasm --exclude rustpython-compiler-source --exclude rustpython-venvlauncher' X86_64_PC_WINDOWS_MSVC_OPENSSL_LIB_DIR='C:\Program Files\OpenSSL\lib\VC\x64\MD' X86_64_PC_WINDOWS_MSVC_OPENSSL_INCLUDE_DIR='C:\Program Files\OpenSSL\include' CARGO_INCREMENTAL=0 CARGO_PROFILE_TEST_DEBUG=0 CARGO_PROFILE_DEV_DEBUG=0 CARGO_PROFILE_RELEASE_DEBUG=0 CARGO_TERM_COLOR=always CI=true RUST_BACKTRACE=full "${CURRENT_ENV[@]}" PYTHONPATH=scripts \
bash -e /home/github/79426228203/steps/bugswarm_11.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=11 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=youknowone GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/main GITHUB_REF_NAME=main GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=RustPython/RustPython GITHUB_REPOSITORY_OWNER=RustPython GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=99bfbad8ee804980f6e5cd749ca937328bf2f819 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_ARGS='--no-default-features --features stdlib,importlib,stdio,encodings,sqlite,ssl-rustls-aws-lc,host_env' CARGO_ARGS_NO_SSL='--no-default-features --features stdlib,importlib,stdio,encodings,sqlite,host_env' WORKSPACE_EXCLUDES='--exclude rustpython_wasm --exclude rustpython-compiler-source --exclude rustpython-venvlauncher' X86_64_PC_WINDOWS_MSVC_OPENSSL_LIB_DIR='C:\Program Files\OpenSSL\lib\VC\x64\MD' X86_64_PC_WINDOWS_MSVC_OPENSSL_INCLUDE_DIR='C:\Program Files\OpenSSL\include' CARGO_INCREMENTAL=0 CARGO_PROFILE_TEST_DEBUG=0 CARGO_PROFILE_DEV_DEBUG=0 CARGO_PROFILE_RELEASE_DEBUG=0 CARGO_TERM_COLOR=always CI=true RUST_BACKTRACE=full "${CURRENT_ENV[@]}" PYTHONPATH=scripts \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=11 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=youknowone GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/main GITHUB_REF_NAME=main GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=RustPython/RustPython GITHUB_REPOSITORY_OWNER=RustPython GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=99bfbad8ee804980f6e5cd749ca937328bf2f819 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 CARGO_ARGS='--no-default-features --features stdlib,importlib,stdio,encodings,sqlite,ssl-rustls-aws-lc,host_env' CARGO_ARGS_NO_SSL='--no-default-features --features stdlib,importlib,stdio,encodings,sqlite,host_env' WORKSPACE_EXCLUDES='--exclude rustpython_wasm --exclude rustpython-compiler-source --exclude rustpython-venvlauncher' X86_64_PC_WINDOWS_MSVC_OPENSSL_LIB_DIR='C:\Program Files\OpenSSL\lib\VC\x64\MD' X86_64_PC_WINDOWS_MSVC_OPENSSL_INCLUDE_DIR='C:\Program Files\OpenSSL\include' CARGO_INCREMENTAL=0 CARGO_PROFILE_TEST_DEBUG=0 CARGO_PROFILE_DEV_DEBUG=0 CARGO_PROFILE_RELEASE_DEBUG=0 CARGO_TERM_COLOR=always CI=true RUST_BACKTRACE=full "${CURRENT_ENV[@]}" PYTHONPATH=scripts \
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
   bash -e $ACTIONS_RUNNER_HOOK_JOB_COMPLETED 79426228203 passed
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
