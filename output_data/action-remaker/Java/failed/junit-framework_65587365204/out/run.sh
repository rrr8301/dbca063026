#!/usr/bin/env bash
export GITHUB_WORKSPACE=/home/github/build/junit-team/junit-framework

if [[ ! -z "$ACTIONS_RUNNER_HOOK_JOB_STARTED" ]]; then
   echo "A job started hook has been configured by the self-hosted runner administrator"
   echo "##[group]Run '$ACTIONS_RUNNER_HOOK_JOB_STARTED'"
   echo "##[endgroup]"
   bash -e $ACTIONS_RUNNER_HOOK_JOB_STARTED 65587365204 failed
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

cp /home/github/65587365204/event.json /home/github/workflow/event.json
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=1 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=graalvm/setup-graalvm GITHUB_ACTIONS=true GITHUB_ACTOR='renovate[bot]' GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=renovate/main-org.graalvm.buildtools.native-0.x GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/renovate/main-org.graalvm.buildtools.native-0.x GITHUB_REF_NAME=renovate/main-org.graalvm.buildtools.native-0.x GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=junit-team/junit-framework GITHUB_REPOSITORY_OWNER=junit-team GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=4a9c2d97f948ce06ad929ba1c8c55fe3849922c6 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 DEVELOCITY_ACCESS_KEY= GITHUB_ACTION_PATH=/home/github/65587365204/actions/graalvm-setup-graalvm@54b4f5a65c1a84b2fdfdc2078fe43df32819e4b1 "${CURRENT_ENV[@]}" INPUT_DISTRIBUTION=graalvm-community INPUT_VERSION=latest INPUT_JAVA-VERSION=21 INPUT_JAVA-PACKAGE=jdk INPUT_COMPONENTS= INPUT_GITHUB-TOKEN=DUMMY INPUT_SET-JAVA-HOME=true INPUT_CHECK-FOR-UPDATES=true INPUT_NATIVE-IMAGE-MUSL=false INPUT_NATIVE-IMAGE-JOB-REPORTS=false INPUT_NATIVE-IMAGE-PR-REPORTS=false INPUT_NATIVE-IMAGE-PR-REPORTS-UPDATE-EXISTING=false INPUT_NATIVE-IMAGE-ENABLE-SBOM=false \
echo $(test "$_GITHUB_JOB_STATUS" = "success" && echo true || echo false))
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=1 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=graalvm/setup-graalvm GITHUB_ACTIONS=true GITHUB_ACTOR='renovate[bot]' GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=renovate/main-org.graalvm.buildtools.native-0.x GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/renovate/main-org.graalvm.buildtools.native-0.x GITHUB_REF_NAME=renovate/main-org.graalvm.buildtools.native-0.x GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=junit-team/junit-framework GITHUB_REPOSITORY_OWNER=junit-team GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=4a9c2d97f948ce06ad929ba1c8c55fe3849922c6 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 DEVELOCITY_ACCESS_KEY= GITHUB_ACTION_PATH=/home/github/65587365204/actions/graalvm-setup-graalvm@54b4f5a65c1a84b2fdfdc2078fe43df32819e4b1 "${CURRENT_ENV[@]}" INPUT_DISTRIBUTION=graalvm-community INPUT_VERSION=latest INPUT_JAVA-VERSION=21 INPUT_JAVA-PACKAGE=jdk INPUT_COMPONENTS= INPUT_GITHUB-TOKEN=DUMMY INPUT_SET-JAVA-HOME=true INPUT_CHECK-FOR-UPDATES=true INPUT_NATIVE-IMAGE-MUSL=false INPUT_NATIVE-IMAGE-JOB-REPORTS=false INPUT_NATIVE-IMAGE-PR-REPORTS=false INPUT_NATIVE-IMAGE-PR-REPORTS-UPDATE-EXISTING=false INPUT_NATIVE-IMAGE-ENABLE-SBOM=false \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run graalvm/setup-graalvm@54b4f5a65c1a84b2fdfdc2078fe43df32819e4b1
echo "##[endgroup]"
echo node /home/github/65587365204/actions/graalvm-setup-graalvm@54b4f5a65c1a84b2fdfdc2078fe43df32819e4b1/dist/main.js > /home/github/65587365204/steps/bugswarm_cmd.sh
chmod u+x /home/github/65587365204/steps/bugswarm_cmd.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=1 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=graalvm/setup-graalvm GITHUB_ACTIONS=true GITHUB_ACTOR='renovate[bot]' GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=renovate/main-org.graalvm.buildtools.native-0.x GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/renovate/main-org.graalvm.buildtools.native-0.x GITHUB_REF_NAME=renovate/main-org.graalvm.buildtools.native-0.x GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=junit-team/junit-framework GITHUB_REPOSITORY_OWNER=junit-team GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=4a9c2d97f948ce06ad929ba1c8c55fe3849922c6 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 DEVELOCITY_ACCESS_KEY= GITHUB_ACTION_PATH=/home/github/65587365204/actions/graalvm-setup-graalvm@54b4f5a65c1a84b2fdfdc2078fe43df32819e4b1 "${CURRENT_ENV[@]}" INPUT_DISTRIBUTION=graalvm-community INPUT_VERSION=latest INPUT_JAVA-VERSION=21 INPUT_JAVA-PACKAGE=jdk INPUT_COMPONENTS= INPUT_GITHUB-TOKEN=DUMMY INPUT_SET-JAVA-HOME=true INPUT_CHECK-FOR-UPDATES=true INPUT_NATIVE-IMAGE-MUSL=false INPUT_NATIVE-IMAGE-JOB-REPORTS=false INPUT_NATIVE-IMAGE-PR-REPORTS=false INPUT_NATIVE-IMAGE-PR-REPORTS-UPDATE-EXISTING=false INPUT_NATIVE-IMAGE-ENABLE-SBOM=false \
bash -e /home/github/65587365204/steps/bugswarm_cmd.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=1 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=graalvm/setup-graalvm GITHUB_ACTIONS=true GITHUB_ACTOR='renovate[bot]' GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=renovate/main-org.graalvm.buildtools.native-0.x GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/renovate/main-org.graalvm.buildtools.native-0.x GITHUB_REF_NAME=renovate/main-org.graalvm.buildtools.native-0.x GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=junit-team/junit-framework GITHUB_REPOSITORY_OWNER=junit-team GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=4a9c2d97f948ce06ad929ba1c8c55fe3849922c6 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 DEVELOCITY_ACCESS_KEY= GITHUB_ACTION_PATH=/home/github/65587365204/actions/graalvm-setup-graalvm@54b4f5a65c1a84b2fdfdc2078fe43df32819e4b1 "${CURRENT_ENV[@]}" INPUT_DISTRIBUTION=graalvm-community INPUT_VERSION=latest INPUT_JAVA-VERSION=21 INPUT_JAVA-PACKAGE=jdk INPUT_COMPONENTS= INPUT_GITHUB-TOKEN=DUMMY INPUT_SET-JAVA-HOME=true INPUT_CHECK-FOR-UPDATES=true INPUT_NATIVE-IMAGE-MUSL=false INPUT_NATIVE-IMAGE-JOB-REPORTS=false INPUT_NATIVE-IMAGE-PR-REPORTS=false INPUT_NATIVE-IMAGE-PR-REPORTS-UPDATE-EXISTING=false INPUT_NATIVE-IMAGE-ENABLE-SBOM=false \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=1 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=graalvm/setup-graalvm GITHUB_ACTIONS=true GITHUB_ACTOR='renovate[bot]' GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=renovate/main-org.graalvm.buildtools.native-0.x GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/renovate/main-org.graalvm.buildtools.native-0.x GITHUB_REF_NAME=renovate/main-org.graalvm.buildtools.native-0.x GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=junit-team/junit-framework GITHUB_REPOSITORY_OWNER=junit-team GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=4a9c2d97f948ce06ad929ba1c8c55fe3849922c6 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 DEVELOCITY_ACCESS_KEY= GITHUB_ACTION_PATH=/home/github/65587365204/actions/graalvm-setup-graalvm@54b4f5a65c1a84b2fdfdc2078fe43df32819e4b1 "${CURRENT_ENV[@]}" INPUT_DISTRIBUTION=graalvm-community INPUT_VERSION=latest INPUT_JAVA-VERSION=21 INPUT_JAVA-PACKAGE=jdk INPUT_COMPONENTS= INPUT_GITHUB-TOKEN=DUMMY INPUT_SET-JAVA-HOME=true INPUT_CHECK-FOR-UPDATES=true INPUT_NATIVE-IMAGE-MUSL=false INPUT_NATIVE-IMAGE-JOB-REPORTS=false INPUT_NATIVE-IMAGE-PR-REPORTS=false INPUT_NATIVE-IMAGE-PR-REPORTS-UPDATE-EXISTING=false INPUT_NATIVE-IMAGE-ENABLE-SBOM=false \
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=2 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=junit-team/junit-framework GITHUB_ACTIONS=true GITHUB_ACTOR='renovate[bot]' GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=renovate/main-org.graalvm.buildtools.native-0.x GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/renovate/main-org.graalvm.buildtools.native-0.x GITHUB_REF_NAME=renovate/main-org.graalvm.buildtools.native-0.x GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=junit-team/junit-framework GITHUB_REPOSITORY_OWNER=junit-team GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=4a9c2d97f948ce06ad929ba1c8c55fe3849922c6 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 DEVELOCITY_ACCESS_KEY= GITHUB_ACTION_PATH=/home/github/65587365204/actions/junit-team-junit-framework/./.github/actions/main-build "${CURRENT_ENV[@]}" INPUT_ENCRYPTIONKEY= INPUT_ARGUMENTS=':platform-tooling-support-tests:test \
build \
jacocoRootReport \
--no-configuration-cache # Disable configuration cache due to https://github.com/diffplug/spotless/issues/2318
' \
echo $(test "$_GITHUB_JOB_STATUS" = "success" && echo true || echo false))
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=2 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=junit-team/junit-framework GITHUB_ACTIONS=true GITHUB_ACTOR='renovate[bot]' GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=renovate/main-org.graalvm.buildtools.native-0.x GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/renovate/main-org.graalvm.buildtools.native-0.x GITHUB_REF_NAME=renovate/main-org.graalvm.buildtools.native-0.x GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=junit-team/junit-framework GITHUB_REPOSITORY_OWNER=junit-team GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=4a9c2d97f948ce06ad929ba1c8c55fe3849922c6 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 DEVELOCITY_ACCESS_KEY= GITHUB_ACTION_PATH=/home/github/65587365204/actions/junit-team-junit-framework/./.github/actions/main-build "${CURRENT_ENV[@]}" INPUT_ENCRYPTIONKEY= INPUT_ARGUMENTS=':platform-tooling-support-tests:test \
build \
jacocoRootReport \
--no-configuration-cache # Disable configuration cache due to https://github.com/diffplug/spotless/issues/2318
' \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run ./.github/actions/main-build
echo "##[endgroup]"
echo /home/github/65587365204/steps/bugswarm_2_composite.sh > /home/github/65587365204/steps/bugswarm_2.sh
chmod u+x /home/github/65587365204/steps/bugswarm_2.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=2 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=junit-team/junit-framework GITHUB_ACTIONS=true GITHUB_ACTOR='renovate[bot]' GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=renovate/main-org.graalvm.buildtools.native-0.x GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/renovate/main-org.graalvm.buildtools.native-0.x GITHUB_REF_NAME=renovate/main-org.graalvm.buildtools.native-0.x GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=junit-team/junit-framework GITHUB_REPOSITORY_OWNER=junit-team GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=4a9c2d97f948ce06ad929ba1c8c55fe3849922c6 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 DEVELOCITY_ACCESS_KEY= GITHUB_ACTION_PATH=/home/github/65587365204/actions/junit-team-junit-framework/./.github/actions/main-build "${CURRENT_ENV[@]}" INPUT_ENCRYPTIONKEY= INPUT_ARGUMENTS=':platform-tooling-support-tests:test \
build \
jacocoRootReport \
--no-configuration-cache # Disable configuration cache due to https://github.com/diffplug/spotless/issues/2318
' \
bash -e /home/github/65587365204/steps/bugswarm_2.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=2 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=junit-team/junit-framework GITHUB_ACTIONS=true GITHUB_ACTOR='renovate[bot]' GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=renovate/main-org.graalvm.buildtools.native-0.x GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/renovate/main-org.graalvm.buildtools.native-0.x GITHUB_REF_NAME=renovate/main-org.graalvm.buildtools.native-0.x GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=junit-team/junit-framework GITHUB_REPOSITORY_OWNER=junit-team GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=4a9c2d97f948ce06ad929ba1c8c55fe3849922c6 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 DEVELOCITY_ACCESS_KEY= GITHUB_ACTION_PATH=/home/github/65587365204/actions/junit-team-junit-framework/./.github/actions/main-build "${CURRENT_ENV[@]}" INPUT_ENCRYPTIONKEY= INPUT_ARGUMENTS=':platform-tooling-support-tests:test \
build \
jacocoRootReport \
--no-configuration-cache # Disable configuration cache due to https://github.com/diffplug/spotless/issues/2318
' \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=2 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=junit-team/junit-framework GITHUB_ACTIONS=true GITHUB_ACTOR='renovate[bot]' GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=renovate/main-org.graalvm.buildtools.native-0.x GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/renovate/main-org.graalvm.buildtools.native-0.x GITHUB_REF_NAME=renovate/main-org.graalvm.buildtools.native-0.x GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=junit-team/junit-framework GITHUB_REPOSITORY_OWNER=junit-team GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=4a9c2d97f948ce06ad929ba1c8c55fe3849922c6 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=CI GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 DEVELOCITY_ACCESS_KEY= GITHUB_ACTION_PATH=/home/github/65587365204/actions/junit-team-junit-framework/./.github/actions/main-build "${CURRENT_ENV[@]}" INPUT_ENCRYPTIONKEY= INPUT_ARGUMENTS=':platform-tooling-support-tests:test \
build \
jacocoRootReport \
--no-configuration-cache # Disable configuration cache due to https://github.com/diffplug/spotless/issues/2318
' \
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
   bash -e $ACTIONS_RUNNER_HOOK_JOB_COMPLETED 65587365204 failed
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
