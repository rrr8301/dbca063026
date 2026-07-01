#!/usr/bin/env bash
export GITHUB_WORKSPACE=/home/github/build/uber/NullAway

if [[ ! -z "$ACTIONS_RUNNER_HOOK_JOB_STARTED" ]]; then
   echo "A job started hook has been configured by the self-hosted runner administrator"
   echo "##[group]Run '$ACTIONS_RUNNER_HOOK_JOB_STARTED'"
   echo "##[endgroup]"
   bash -e $ACTIONS_RUNNER_HOOK_JOB_STARTED 65725769130 passed
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

cp /home/github/65725769130/event.json /home/github/workflow/event.json
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=1 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=actions/setup-java GITHUB_ACTIONS=true GITHUB_ACTOR=msridhar GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=test-libmodel-varargs-new GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/test-libmodel-varargs-new GITHUB_REF_NAME=test-libmodel-varargs-new GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=uber/NullAway GITHUB_REPOSITORY_OWNER=uber GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=c7127813910286d0967b7a5b26a0486d98bfba5d GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Continuous integration' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 GITHUB_ACTION_PATH=/home/github/65725769130/actions/actions-setup-java@v5 "${CURRENT_ENV[@]}" INPUT_JAVA-VERSION=25 INPUT_DISTRIBUTION=zulu INPUT_OVERWRITE-SETTINGS=False INPUT_TOKEN= INPUT_JAVA-PACKAGE=jdk INPUT_CHECK-LATEST=false INPUT_SERVER-ID=github INPUT_SERVER-USERNAME=GITHUB_ACTOR INPUT_SERVER-PASSWORD=GITHUB_TOKEN INPUT_JOB-STATUS="${_GITHUB_JOB_STATUS}" \
echo $(test "$_GITHUB_JOB_STATUS" = "success" && echo true || echo false))
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=1 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=actions/setup-java GITHUB_ACTIONS=true GITHUB_ACTOR=msridhar GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=test-libmodel-varargs-new GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/test-libmodel-varargs-new GITHUB_REF_NAME=test-libmodel-varargs-new GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=uber/NullAway GITHUB_REPOSITORY_OWNER=uber GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=c7127813910286d0967b7a5b26a0486d98bfba5d GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Continuous integration' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 GITHUB_ACTION_PATH=/home/github/65725769130/actions/actions-setup-java@v5 "${CURRENT_ENV[@]}" INPUT_JAVA-VERSION=25 INPUT_DISTRIBUTION=zulu INPUT_OVERWRITE-SETTINGS=False INPUT_TOKEN= INPUT_JAVA-PACKAGE=jdk INPUT_CHECK-LATEST=false INPUT_SERVER-ID=github INPUT_SERVER-USERNAME=GITHUB_ACTOR INPUT_SERVER-PASSWORD=GITHUB_TOKEN INPUT_JOB-STATUS="${_GITHUB_JOB_STATUS}" \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run actions/setup-java@v5
echo "##[endgroup]"
echo node /home/github/65725769130/actions/actions-setup-java@v5/dist/setup/index.js > /home/github/65725769130/steps/bugswarm_cmd.sh
chmod u+x /home/github/65725769130/steps/bugswarm_cmd.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=1 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=actions/setup-java GITHUB_ACTIONS=true GITHUB_ACTOR=msridhar GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=test-libmodel-varargs-new GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/test-libmodel-varargs-new GITHUB_REF_NAME=test-libmodel-varargs-new GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=uber/NullAway GITHUB_REPOSITORY_OWNER=uber GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=c7127813910286d0967b7a5b26a0486d98bfba5d GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Continuous integration' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 GITHUB_ACTION_PATH=/home/github/65725769130/actions/actions-setup-java@v5 "${CURRENT_ENV[@]}" INPUT_JAVA-VERSION=25 INPUT_DISTRIBUTION=zulu INPUT_OVERWRITE-SETTINGS=False INPUT_TOKEN= INPUT_JAVA-PACKAGE=jdk INPUT_CHECK-LATEST=false INPUT_SERVER-ID=github INPUT_SERVER-USERNAME=GITHUB_ACTOR INPUT_SERVER-PASSWORD=GITHUB_TOKEN INPUT_JOB-STATUS="${_GITHUB_JOB_STATUS}" \
bash -e /home/github/65725769130/steps/bugswarm_cmd.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=1 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=actions/setup-java GITHUB_ACTIONS=true GITHUB_ACTOR=msridhar GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=test-libmodel-varargs-new GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/test-libmodel-varargs-new GITHUB_REF_NAME=test-libmodel-varargs-new GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=uber/NullAway GITHUB_REPOSITORY_OWNER=uber GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=c7127813910286d0967b7a5b26a0486d98bfba5d GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Continuous integration' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 GITHUB_ACTION_PATH=/home/github/65725769130/actions/actions-setup-java@v5 "${CURRENT_ENV[@]}" INPUT_JAVA-VERSION=25 INPUT_DISTRIBUTION=zulu INPUT_OVERWRITE-SETTINGS=False INPUT_TOKEN= INPUT_JAVA-PACKAGE=jdk INPUT_CHECK-LATEST=false INPUT_SERVER-ID=github INPUT_SERVER-USERNAME=GITHUB_ACTOR INPUT_SERVER-PASSWORD=GITHUB_TOKEN INPUT_JOB-STATUS="${_GITHUB_JOB_STATUS}" \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=1 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=actions/setup-java GITHUB_ACTIONS=true GITHUB_ACTOR=msridhar GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=test-libmodel-varargs-new GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/test-libmodel-varargs-new GITHUB_REF_NAME=test-libmodel-varargs-new GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=uber/NullAway GITHUB_REPOSITORY_OWNER=uber GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=c7127813910286d0967b7a5b26a0486d98bfba5d GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Continuous integration' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 GITHUB_ACTION_PATH=/home/github/65725769130/actions/actions-setup-java@v5 "${CURRENT_ENV[@]}" INPUT_JAVA-VERSION=25 INPUT_DISTRIBUTION=zulu INPUT_OVERWRITE-SETTINGS=False INPUT_TOKEN= INPUT_JAVA-PACKAGE=jdk INPUT_CHECK-LATEST=false INPUT_SERVER-ID=github INPUT_SERVER-USERNAME=GITHUB_ACTOR INPUT_SERVER-PASSWORD=GITHUB_TOKEN INPUT_JOB-STATUS="${_GITHUB_JOB_STATUS}" \
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=2 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=gradle/actions GITHUB_ACTIONS=true GITHUB_ACTOR=msridhar GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=test-libmodel-varargs-new GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/test-libmodel-varargs-new GITHUB_REF_NAME=test-libmodel-varargs-new GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=uber/NullAway GITHUB_REPOSITORY_OWNER=uber GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=c7127813910286d0967b7a5b26a0486d98bfba5d GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Continuous integration' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 GITHUB_ACTION_PATH=/home/github/65725769130/actions/gradle-actions@v5/setup-gradle "${CURRENT_ENV[@]}" INPUT_CACHE-DISABLED=false INPUT_CACHE-READ-ONLY="$(/home/github/65725769130/helpers/eval_expression p:'(' l:'{"allow_forking": true, "archive_url": "https://api.github.com/repos/uber/NullAway/{archive_format}{/ref}", "archived": false, "assignees_url": "https://api.github.com/repos/uber/NullAway/assignees{/user}", "blobs_url": "https://api.github.com/repos/uber/NullAway/git/blobs{/sha}", "branches_url": "https://api.github.com/repos/uber/NullAway/branches{/branch}", "clone_url": "https://github.com/uber/NullAway.git", "collaborators_url": "https://api.github.com/repos/uber/NullAway/collaborators{/collaborator}", "comments_url": "https://api.github.com/repos/uber/NullAway/comments{/number}", "commits_url": "https://api.github.com/repos/uber/NullAway/commits{/sha}", "compare_url": "https://api.github.com/repos/uber/NullAway/compare/{base}...{head}", "contents_url": "https://api.github.com/repos/uber/NullAway/contents/{+path}", "contributors_url": "https://api.github.com/repos/uber/NullAway/contributors", "created_at": 0, "default_branch": "master", "deployments_url": "https://api.github.com/repos/uber/NullAway/deployments", "description": "A tool to help eliminate NullPointerExceptions (NPEs) in your Java code with low build-time overhead", "disabled": false, "downloads_url": "https://api.github.com/repos/uber/NullAway/downloads", "events_url": "https://api.github.com/repos/uber/NullAway/events", "fork": false, "forks": 0, "forks_count": 0, "forks_url": "https://api.github.com/repos/uber/NullAway/forks", "full_name": "uber/NullAway", "git_commits_url": "https://api.github.com/repos/uber/NullAway/git/commits{/sha}", "git_refs_url": "https://api.github.com/repos/uber/NullAway/git/refs{/sha}", "git_tags_url": "https://api.github.com/repos/uber/NullAway/git/tags{/sha}", "git_url": "git://github.com/uber/NullAway.git", "has_downloads": true, "has_issues": true, "has_pages": true, "has_projects": true, "has_wiki": true, "homepage": null, "hooks_url": "https://api.github.com/repos/uber/NullAway/hooks", "html_url": "https://github.com/uber/NullAway", "id": 102137661, "is_template": false, "issue_comment_url": "https://api.github.com/repos/uber/NullAway/issues/comments{/number}", "issue_events_url": "https://api.github.com/repos/uber/NullAway/issues/events{/number}", "issues_url": "https://api.github.com/repos/uber/NullAway/issues{/number}", "keys_url": "https://api.github.com/repos/uber/NullAway/keys{/key_id}", "labels_url": "https://api.github.com/repos/uber/NullAway/labels{/name}", "language": "", "languages_url": "https://api.github.com/repos/uber/NullAway/languages", "license": null, "master_branch": "master", "merges_url": "https://api.github.com/repos/uber/NullAway/merges", "milestones_url": "https://api.github.com/repos/uber/NullAway/milestones{/number}", "mirror_url": null, "name": "NullAway", "node_id": "MDEwOlJlcG9zaXRvcnkxMDIxMzc2NjE=", "notifications_url": "https://api.github.com/repos/uber/NullAway/notifications{?since,all,participating}", "open_issues": 0, "open_issues_count": 0, "owner": {"avatar_url": "https://avatars.githubusercontent.com/u/538264?v=4", "email": "", "events_url": "https://api.github.com/users/uber/events{/privacy}", "followers_url": "https://api.github.com/users/uber/followers", "following_url": "https://api.github.com/users/uber/following{/other_user}", "gists_url": "https://api.github.com/users/uber/gists{/gist_id}", "gravatar_id": "", "html_url": "https://github.com/uber", "id": 538264, "login": "uber", "name": "uber", "node_id": "MDEyOk9yZ2FuaXphdGlvbjUzODI2NA==", "organizations_url": "https://api.github.com/users/uber/orgs", "received_events_url": "https://api.github.com/users/uber/received_events", "repos_url": "https://api.github.com/users/uber/repos", "site_admin": false, "starred_url": "https://api.github.com/users/uber/starred{/owner}{/repo}", "subscriptions_url": "https://api.github.com/users/uber/subscriptions", "type": "Organization", "url": "https://api.github.com/users/uber"}, "private": false, "pulls_url": "https://api.github.com/repos/uber/NullAway/pulls{/number}", "pushed_at": 0, "releases_url": "https://api.github.com/repos/uber/NullAway/releases{/id}", "size": 0, "ssh_url": "git@github.com:uber/NullAway.git", "stargazers": 0, "stargazers_count": 0, "stargazers_url": "https://api.github.com/repos/uber/NullAway/stargazers", "statuses_url": "https://api.github.com/repos/uber/NullAway/statuses/{sha}", "subscribers_url": "https://api.github.com/repos/uber/NullAway/subscribers", "subscription_url": "https://api.github.com/repos/uber/NullAway/subscription", "svn_url": "https://github.com/uber/NullAway", "tags_url": "https://api.github.com/repos/uber/NullAway/tags", "teams_url": "https://api.github.com/repos/uber/NullAway/teams", "topics": [], "trees_url": "https://api.github.com/repos/uber/NullAway/git/trees{/sha}", "updated_at": "2026-03-04T14:36:38Z", "url": "https://api.github.com/repos/uber/NullAway", "visibility": "public", "watchers": 0, "watchers_count": 0, "web_commit_signoff_required": false}' o:'!=' l:'' p:')' o:'&&' p:'(' s:test-libmodel-varargs-new o:'!=' s:master p:')')" INPUT_CACHE-WRITE-ONLY=false INPUT_CACHE-OVERWRITE-EXISTING=false INPUT_CACHE-CLEANUP=on-success INPUT_GRADLE-HOME-CACHE-INCLUDES='caches
notifications
' INPUT_ADD-JOB-SUMMARY=always INPUT_ADD-JOB-SUMMARY-AS-PR-COMMENT=never INPUT_DEPENDENCY-GRAPH=disabled INPUT_DEPENDENCY-GRAPH-REPORT-DIR=dependency-graph-reports INPUT_DEPENDENCY-GRAPH-CONTINUE-ON-FAILURE=true INPUT_BUILD-SCAN-PUBLISH=false INPUT_VALIDATE-WRAPPERS=true INPUT_ALLOW-SNAPSHOT-WRAPPERS=false INPUT_GRADLE-HOME-CACHE-STRICT-MATCH=false INPUT_WORKFLOW-JOB-CONTEXT="$(/home/github/65725769130/helpers/eval_expression p:'(' f:toJSON p:'(' l:'{"os": "ubuntu-latest"}' p:')' p:')')" INPUT_GITHUB-TOKEN=DUMMY \
echo $(test "$_GITHUB_JOB_STATUS" = "success" && echo true || echo false))
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=2 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=gradle/actions GITHUB_ACTIONS=true GITHUB_ACTOR=msridhar GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=test-libmodel-varargs-new GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/test-libmodel-varargs-new GITHUB_REF_NAME=test-libmodel-varargs-new GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=uber/NullAway GITHUB_REPOSITORY_OWNER=uber GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=c7127813910286d0967b7a5b26a0486d98bfba5d GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Continuous integration' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 GITHUB_ACTION_PATH=/home/github/65725769130/actions/gradle-actions@v5/setup-gradle "${CURRENT_ENV[@]}" INPUT_CACHE-DISABLED=false INPUT_CACHE-READ-ONLY="$(/home/github/65725769130/helpers/eval_expression p:'(' l:'{"allow_forking": true, "archive_url": "https://api.github.com/repos/uber/NullAway/{archive_format}{/ref}", "archived": false, "assignees_url": "https://api.github.com/repos/uber/NullAway/assignees{/user}", "blobs_url": "https://api.github.com/repos/uber/NullAway/git/blobs{/sha}", "branches_url": "https://api.github.com/repos/uber/NullAway/branches{/branch}", "clone_url": "https://github.com/uber/NullAway.git", "collaborators_url": "https://api.github.com/repos/uber/NullAway/collaborators{/collaborator}", "comments_url": "https://api.github.com/repos/uber/NullAway/comments{/number}", "commits_url": "https://api.github.com/repos/uber/NullAway/commits{/sha}", "compare_url": "https://api.github.com/repos/uber/NullAway/compare/{base}...{head}", "contents_url": "https://api.github.com/repos/uber/NullAway/contents/{+path}", "contributors_url": "https://api.github.com/repos/uber/NullAway/contributors", "created_at": 0, "default_branch": "master", "deployments_url": "https://api.github.com/repos/uber/NullAway/deployments", "description": "A tool to help eliminate NullPointerExceptions (NPEs) in your Java code with low build-time overhead", "disabled": false, "downloads_url": "https://api.github.com/repos/uber/NullAway/downloads", "events_url": "https://api.github.com/repos/uber/NullAway/events", "fork": false, "forks": 0, "forks_count": 0, "forks_url": "https://api.github.com/repos/uber/NullAway/forks", "full_name": "uber/NullAway", "git_commits_url": "https://api.github.com/repos/uber/NullAway/git/commits{/sha}", "git_refs_url": "https://api.github.com/repos/uber/NullAway/git/refs{/sha}", "git_tags_url": "https://api.github.com/repos/uber/NullAway/git/tags{/sha}", "git_url": "git://github.com/uber/NullAway.git", "has_downloads": true, "has_issues": true, "has_pages": true, "has_projects": true, "has_wiki": true, "homepage": null, "hooks_url": "https://api.github.com/repos/uber/NullAway/hooks", "html_url": "https://github.com/uber/NullAway", "id": 102137661, "is_template": false, "issue_comment_url": "https://api.github.com/repos/uber/NullAway/issues/comments{/number}", "issue_events_url": "https://api.github.com/repos/uber/NullAway/issues/events{/number}", "issues_url": "https://api.github.com/repos/uber/NullAway/issues{/number}", "keys_url": "https://api.github.com/repos/uber/NullAway/keys{/key_id}", "labels_url": "https://api.github.com/repos/uber/NullAway/labels{/name}", "language": "", "languages_url": "https://api.github.com/repos/uber/NullAway/languages", "license": null, "master_branch": "master", "merges_url": "https://api.github.com/repos/uber/NullAway/merges", "milestones_url": "https://api.github.com/repos/uber/NullAway/milestones{/number}", "mirror_url": null, "name": "NullAway", "node_id": "MDEwOlJlcG9zaXRvcnkxMDIxMzc2NjE=", "notifications_url": "https://api.github.com/repos/uber/NullAway/notifications{?since,all,participating}", "open_issues": 0, "open_issues_count": 0, "owner": {"avatar_url": "https://avatars.githubusercontent.com/u/538264?v=4", "email": "", "events_url": "https://api.github.com/users/uber/events{/privacy}", "followers_url": "https://api.github.com/users/uber/followers", "following_url": "https://api.github.com/users/uber/following{/other_user}", "gists_url": "https://api.github.com/users/uber/gists{/gist_id}", "gravatar_id": "", "html_url": "https://github.com/uber", "id": 538264, "login": "uber", "name": "uber", "node_id": "MDEyOk9yZ2FuaXphdGlvbjUzODI2NA==", "organizations_url": "https://api.github.com/users/uber/orgs", "received_events_url": "https://api.github.com/users/uber/received_events", "repos_url": "https://api.github.com/users/uber/repos", "site_admin": false, "starred_url": "https://api.github.com/users/uber/starred{/owner}{/repo}", "subscriptions_url": "https://api.github.com/users/uber/subscriptions", "type": "Organization", "url": "https://api.github.com/users/uber"}, "private": false, "pulls_url": "https://api.github.com/repos/uber/NullAway/pulls{/number}", "pushed_at": 0, "releases_url": "https://api.github.com/repos/uber/NullAway/releases{/id}", "size": 0, "ssh_url": "git@github.com:uber/NullAway.git", "stargazers": 0, "stargazers_count": 0, "stargazers_url": "https://api.github.com/repos/uber/NullAway/stargazers", "statuses_url": "https://api.github.com/repos/uber/NullAway/statuses/{sha}", "subscribers_url": "https://api.github.com/repos/uber/NullAway/subscribers", "subscription_url": "https://api.github.com/repos/uber/NullAway/subscription", "svn_url": "https://github.com/uber/NullAway", "tags_url": "https://api.github.com/repos/uber/NullAway/tags", "teams_url": "https://api.github.com/repos/uber/NullAway/teams", "topics": [], "trees_url": "https://api.github.com/repos/uber/NullAway/git/trees{/sha}", "updated_at": "2026-03-04T14:36:38Z", "url": "https://api.github.com/repos/uber/NullAway", "visibility": "public", "watchers": 0, "watchers_count": 0, "web_commit_signoff_required": false}' o:'!=' l:'' p:')' o:'&&' p:'(' s:test-libmodel-varargs-new o:'!=' s:master p:')')" INPUT_CACHE-WRITE-ONLY=false INPUT_CACHE-OVERWRITE-EXISTING=false INPUT_CACHE-CLEANUP=on-success INPUT_GRADLE-HOME-CACHE-INCLUDES='caches
notifications
' INPUT_ADD-JOB-SUMMARY=always INPUT_ADD-JOB-SUMMARY-AS-PR-COMMENT=never INPUT_DEPENDENCY-GRAPH=disabled INPUT_DEPENDENCY-GRAPH-REPORT-DIR=dependency-graph-reports INPUT_DEPENDENCY-GRAPH-CONTINUE-ON-FAILURE=true INPUT_BUILD-SCAN-PUBLISH=false INPUT_VALIDATE-WRAPPERS=true INPUT_ALLOW-SNAPSHOT-WRAPPERS=false INPUT_GRADLE-HOME-CACHE-STRICT-MATCH=false INPUT_WORKFLOW-JOB-CONTEXT="$(/home/github/65725769130/helpers/eval_expression p:'(' f:toJSON p:'(' l:'{"os": "ubuntu-latest"}' p:')' p:')')" INPUT_GITHUB-TOKEN=DUMMY \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run gradle/actions/setup-gradle@v5
echo "##[endgroup]"
echo node /home/github/65725769130/actions/gradle-actions@v5/setup-gradle/../dist/setup-gradle/main/index.js > /home/github/65725769130/steps/bugswarm_cmd.sh
chmod u+x /home/github/65725769130/steps/bugswarm_cmd.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=2 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=gradle/actions GITHUB_ACTIONS=true GITHUB_ACTOR=msridhar GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=test-libmodel-varargs-new GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/test-libmodel-varargs-new GITHUB_REF_NAME=test-libmodel-varargs-new GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=uber/NullAway GITHUB_REPOSITORY_OWNER=uber GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=c7127813910286d0967b7a5b26a0486d98bfba5d GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Continuous integration' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 GITHUB_ACTION_PATH=/home/github/65725769130/actions/gradle-actions@v5/setup-gradle "${CURRENT_ENV[@]}" INPUT_CACHE-DISABLED=false INPUT_CACHE-READ-ONLY="$(/home/github/65725769130/helpers/eval_expression p:'(' l:'{"allow_forking": true, "archive_url": "https://api.github.com/repos/uber/NullAway/{archive_format}{/ref}", "archived": false, "assignees_url": "https://api.github.com/repos/uber/NullAway/assignees{/user}", "blobs_url": "https://api.github.com/repos/uber/NullAway/git/blobs{/sha}", "branches_url": "https://api.github.com/repos/uber/NullAway/branches{/branch}", "clone_url": "https://github.com/uber/NullAway.git", "collaborators_url": "https://api.github.com/repos/uber/NullAway/collaborators{/collaborator}", "comments_url": "https://api.github.com/repos/uber/NullAway/comments{/number}", "commits_url": "https://api.github.com/repos/uber/NullAway/commits{/sha}", "compare_url": "https://api.github.com/repos/uber/NullAway/compare/{base}...{head}", "contents_url": "https://api.github.com/repos/uber/NullAway/contents/{+path}", "contributors_url": "https://api.github.com/repos/uber/NullAway/contributors", "created_at": 0, "default_branch": "master", "deployments_url": "https://api.github.com/repos/uber/NullAway/deployments", "description": "A tool to help eliminate NullPointerExceptions (NPEs) in your Java code with low build-time overhead", "disabled": false, "downloads_url": "https://api.github.com/repos/uber/NullAway/downloads", "events_url": "https://api.github.com/repos/uber/NullAway/events", "fork": false, "forks": 0, "forks_count": 0, "forks_url": "https://api.github.com/repos/uber/NullAway/forks", "full_name": "uber/NullAway", "git_commits_url": "https://api.github.com/repos/uber/NullAway/git/commits{/sha}", "git_refs_url": "https://api.github.com/repos/uber/NullAway/git/refs{/sha}", "git_tags_url": "https://api.github.com/repos/uber/NullAway/git/tags{/sha}", "git_url": "git://github.com/uber/NullAway.git", "has_downloads": true, "has_issues": true, "has_pages": true, "has_projects": true, "has_wiki": true, "homepage": null, "hooks_url": "https://api.github.com/repos/uber/NullAway/hooks", "html_url": "https://github.com/uber/NullAway", "id": 102137661, "is_template": false, "issue_comment_url": "https://api.github.com/repos/uber/NullAway/issues/comments{/number}", "issue_events_url": "https://api.github.com/repos/uber/NullAway/issues/events{/number}", "issues_url": "https://api.github.com/repos/uber/NullAway/issues{/number}", "keys_url": "https://api.github.com/repos/uber/NullAway/keys{/key_id}", "labels_url": "https://api.github.com/repos/uber/NullAway/labels{/name}", "language": "", "languages_url": "https://api.github.com/repos/uber/NullAway/languages", "license": null, "master_branch": "master", "merges_url": "https://api.github.com/repos/uber/NullAway/merges", "milestones_url": "https://api.github.com/repos/uber/NullAway/milestones{/number}", "mirror_url": null, "name": "NullAway", "node_id": "MDEwOlJlcG9zaXRvcnkxMDIxMzc2NjE=", "notifications_url": "https://api.github.com/repos/uber/NullAway/notifications{?since,all,participating}", "open_issues": 0, "open_issues_count": 0, "owner": {"avatar_url": "https://avatars.githubusercontent.com/u/538264?v=4", "email": "", "events_url": "https://api.github.com/users/uber/events{/privacy}", "followers_url": "https://api.github.com/users/uber/followers", "following_url": "https://api.github.com/users/uber/following{/other_user}", "gists_url": "https://api.github.com/users/uber/gists{/gist_id}", "gravatar_id": "", "html_url": "https://github.com/uber", "id": 538264, "login": "uber", "name": "uber", "node_id": "MDEyOk9yZ2FuaXphdGlvbjUzODI2NA==", "organizations_url": "https://api.github.com/users/uber/orgs", "received_events_url": "https://api.github.com/users/uber/received_events", "repos_url": "https://api.github.com/users/uber/repos", "site_admin": false, "starred_url": "https://api.github.com/users/uber/starred{/owner}{/repo}", "subscriptions_url": "https://api.github.com/users/uber/subscriptions", "type": "Organization", "url": "https://api.github.com/users/uber"}, "private": false, "pulls_url": "https://api.github.com/repos/uber/NullAway/pulls{/number}", "pushed_at": 0, "releases_url": "https://api.github.com/repos/uber/NullAway/releases{/id}", "size": 0, "ssh_url": "git@github.com:uber/NullAway.git", "stargazers": 0, "stargazers_count": 0, "stargazers_url": "https://api.github.com/repos/uber/NullAway/stargazers", "statuses_url": "https://api.github.com/repos/uber/NullAway/statuses/{sha}", "subscribers_url": "https://api.github.com/repos/uber/NullAway/subscribers", "subscription_url": "https://api.github.com/repos/uber/NullAway/subscription", "svn_url": "https://github.com/uber/NullAway", "tags_url": "https://api.github.com/repos/uber/NullAway/tags", "teams_url": "https://api.github.com/repos/uber/NullAway/teams", "topics": [], "trees_url": "https://api.github.com/repos/uber/NullAway/git/trees{/sha}", "updated_at": "2026-03-04T14:36:38Z", "url": "https://api.github.com/repos/uber/NullAway", "visibility": "public", "watchers": 0, "watchers_count": 0, "web_commit_signoff_required": false}' o:'!=' l:'' p:')' o:'&&' p:'(' s:test-libmodel-varargs-new o:'!=' s:master p:')')" INPUT_CACHE-WRITE-ONLY=false INPUT_CACHE-OVERWRITE-EXISTING=false INPUT_CACHE-CLEANUP=on-success INPUT_GRADLE-HOME-CACHE-INCLUDES='caches
notifications
' INPUT_ADD-JOB-SUMMARY=always INPUT_ADD-JOB-SUMMARY-AS-PR-COMMENT=never INPUT_DEPENDENCY-GRAPH=disabled INPUT_DEPENDENCY-GRAPH-REPORT-DIR=dependency-graph-reports INPUT_DEPENDENCY-GRAPH-CONTINUE-ON-FAILURE=true INPUT_BUILD-SCAN-PUBLISH=false INPUT_VALIDATE-WRAPPERS=true INPUT_ALLOW-SNAPSHOT-WRAPPERS=false INPUT_GRADLE-HOME-CACHE-STRICT-MATCH=false INPUT_WORKFLOW-JOB-CONTEXT="$(/home/github/65725769130/helpers/eval_expression p:'(' f:toJSON p:'(' l:'{"os": "ubuntu-latest"}' p:')' p:')')" INPUT_GITHUB-TOKEN=DUMMY \
bash -e /home/github/65725769130/steps/bugswarm_cmd.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=2 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=gradle/actions GITHUB_ACTIONS=true GITHUB_ACTOR=msridhar GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=test-libmodel-varargs-new GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/test-libmodel-varargs-new GITHUB_REF_NAME=test-libmodel-varargs-new GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=uber/NullAway GITHUB_REPOSITORY_OWNER=uber GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=c7127813910286d0967b7a5b26a0486d98bfba5d GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Continuous integration' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 GITHUB_ACTION_PATH=/home/github/65725769130/actions/gradle-actions@v5/setup-gradle "${CURRENT_ENV[@]}" INPUT_CACHE-DISABLED=false INPUT_CACHE-READ-ONLY="$(/home/github/65725769130/helpers/eval_expression p:'(' l:'{"allow_forking": true, "archive_url": "https://api.github.com/repos/uber/NullAway/{archive_format}{/ref}", "archived": false, "assignees_url": "https://api.github.com/repos/uber/NullAway/assignees{/user}", "blobs_url": "https://api.github.com/repos/uber/NullAway/git/blobs{/sha}", "branches_url": "https://api.github.com/repos/uber/NullAway/branches{/branch}", "clone_url": "https://github.com/uber/NullAway.git", "collaborators_url": "https://api.github.com/repos/uber/NullAway/collaborators{/collaborator}", "comments_url": "https://api.github.com/repos/uber/NullAway/comments{/number}", "commits_url": "https://api.github.com/repos/uber/NullAway/commits{/sha}", "compare_url": "https://api.github.com/repos/uber/NullAway/compare/{base}...{head}", "contents_url": "https://api.github.com/repos/uber/NullAway/contents/{+path}", "contributors_url": "https://api.github.com/repos/uber/NullAway/contributors", "created_at": 0, "default_branch": "master", "deployments_url": "https://api.github.com/repos/uber/NullAway/deployments", "description": "A tool to help eliminate NullPointerExceptions (NPEs) in your Java code with low build-time overhead", "disabled": false, "downloads_url": "https://api.github.com/repos/uber/NullAway/downloads", "events_url": "https://api.github.com/repos/uber/NullAway/events", "fork": false, "forks": 0, "forks_count": 0, "forks_url": "https://api.github.com/repos/uber/NullAway/forks", "full_name": "uber/NullAway", "git_commits_url": "https://api.github.com/repos/uber/NullAway/git/commits{/sha}", "git_refs_url": "https://api.github.com/repos/uber/NullAway/git/refs{/sha}", "git_tags_url": "https://api.github.com/repos/uber/NullAway/git/tags{/sha}", "git_url": "git://github.com/uber/NullAway.git", "has_downloads": true, "has_issues": true, "has_pages": true, "has_projects": true, "has_wiki": true, "homepage": null, "hooks_url": "https://api.github.com/repos/uber/NullAway/hooks", "html_url": "https://github.com/uber/NullAway", "id": 102137661, "is_template": false, "issue_comment_url": "https://api.github.com/repos/uber/NullAway/issues/comments{/number}", "issue_events_url": "https://api.github.com/repos/uber/NullAway/issues/events{/number}", "issues_url": "https://api.github.com/repos/uber/NullAway/issues{/number}", "keys_url": "https://api.github.com/repos/uber/NullAway/keys{/key_id}", "labels_url": "https://api.github.com/repos/uber/NullAway/labels{/name}", "language": "", "languages_url": "https://api.github.com/repos/uber/NullAway/languages", "license": null, "master_branch": "master", "merges_url": "https://api.github.com/repos/uber/NullAway/merges", "milestones_url": "https://api.github.com/repos/uber/NullAway/milestones{/number}", "mirror_url": null, "name": "NullAway", "node_id": "MDEwOlJlcG9zaXRvcnkxMDIxMzc2NjE=", "notifications_url": "https://api.github.com/repos/uber/NullAway/notifications{?since,all,participating}", "open_issues": 0, "open_issues_count": 0, "owner": {"avatar_url": "https://avatars.githubusercontent.com/u/538264?v=4", "email": "", "events_url": "https://api.github.com/users/uber/events{/privacy}", "followers_url": "https://api.github.com/users/uber/followers", "following_url": "https://api.github.com/users/uber/following{/other_user}", "gists_url": "https://api.github.com/users/uber/gists{/gist_id}", "gravatar_id": "", "html_url": "https://github.com/uber", "id": 538264, "login": "uber", "name": "uber", "node_id": "MDEyOk9yZ2FuaXphdGlvbjUzODI2NA==", "organizations_url": "https://api.github.com/users/uber/orgs", "received_events_url": "https://api.github.com/users/uber/received_events", "repos_url": "https://api.github.com/users/uber/repos", "site_admin": false, "starred_url": "https://api.github.com/users/uber/starred{/owner}{/repo}", "subscriptions_url": "https://api.github.com/users/uber/subscriptions", "type": "Organization", "url": "https://api.github.com/users/uber"}, "private": false, "pulls_url": "https://api.github.com/repos/uber/NullAway/pulls{/number}", "pushed_at": 0, "releases_url": "https://api.github.com/repos/uber/NullAway/releases{/id}", "size": 0, "ssh_url": "git@github.com:uber/NullAway.git", "stargazers": 0, "stargazers_count": 0, "stargazers_url": "https://api.github.com/repos/uber/NullAway/stargazers", "statuses_url": "https://api.github.com/repos/uber/NullAway/statuses/{sha}", "subscribers_url": "https://api.github.com/repos/uber/NullAway/subscribers", "subscription_url": "https://api.github.com/repos/uber/NullAway/subscription", "svn_url": "https://github.com/uber/NullAway", "tags_url": "https://api.github.com/repos/uber/NullAway/tags", "teams_url": "https://api.github.com/repos/uber/NullAway/teams", "topics": [], "trees_url": "https://api.github.com/repos/uber/NullAway/git/trees{/sha}", "updated_at": "2026-03-04T14:36:38Z", "url": "https://api.github.com/repos/uber/NullAway", "visibility": "public", "watchers": 0, "watchers_count": 0, "web_commit_signoff_required": false}' o:'!=' l:'' p:')' o:'&&' p:'(' s:test-libmodel-varargs-new o:'!=' s:master p:')')" INPUT_CACHE-WRITE-ONLY=false INPUT_CACHE-OVERWRITE-EXISTING=false INPUT_CACHE-CLEANUP=on-success INPUT_GRADLE-HOME-CACHE-INCLUDES='caches
notifications
' INPUT_ADD-JOB-SUMMARY=always INPUT_ADD-JOB-SUMMARY-AS-PR-COMMENT=never INPUT_DEPENDENCY-GRAPH=disabled INPUT_DEPENDENCY-GRAPH-REPORT-DIR=dependency-graph-reports INPUT_DEPENDENCY-GRAPH-CONTINUE-ON-FAILURE=true INPUT_BUILD-SCAN-PUBLISH=false INPUT_VALIDATE-WRAPPERS=true INPUT_ALLOW-SNAPSHOT-WRAPPERS=false INPUT_GRADLE-HOME-CACHE-STRICT-MATCH=false INPUT_WORKFLOW-JOB-CONTEXT="$(/home/github/65725769130/helpers/eval_expression p:'(' f:toJSON p:'(' l:'{"os": "ubuntu-latest"}' p:')' p:')')" INPUT_GITHUB-TOKEN=DUMMY \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=2 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=gradle/actions GITHUB_ACTIONS=true GITHUB_ACTOR=msridhar GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=test-libmodel-varargs-new GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/test-libmodel-varargs-new GITHUB_REF_NAME=test-libmodel-varargs-new GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=uber/NullAway GITHUB_REPOSITORY_OWNER=uber GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=c7127813910286d0967b7a5b26a0486d98bfba5d GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Continuous integration' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 GITHUB_ACTION_PATH=/home/github/65725769130/actions/gradle-actions@v5/setup-gradle "${CURRENT_ENV[@]}" INPUT_CACHE-DISABLED=false INPUT_CACHE-READ-ONLY="$(/home/github/65725769130/helpers/eval_expression p:'(' l:'{"allow_forking": true, "archive_url": "https://api.github.com/repos/uber/NullAway/{archive_format}{/ref}", "archived": false, "assignees_url": "https://api.github.com/repos/uber/NullAway/assignees{/user}", "blobs_url": "https://api.github.com/repos/uber/NullAway/git/blobs{/sha}", "branches_url": "https://api.github.com/repos/uber/NullAway/branches{/branch}", "clone_url": "https://github.com/uber/NullAway.git", "collaborators_url": "https://api.github.com/repos/uber/NullAway/collaborators{/collaborator}", "comments_url": "https://api.github.com/repos/uber/NullAway/comments{/number}", "commits_url": "https://api.github.com/repos/uber/NullAway/commits{/sha}", "compare_url": "https://api.github.com/repos/uber/NullAway/compare/{base}...{head}", "contents_url": "https://api.github.com/repos/uber/NullAway/contents/{+path}", "contributors_url": "https://api.github.com/repos/uber/NullAway/contributors", "created_at": 0, "default_branch": "master", "deployments_url": "https://api.github.com/repos/uber/NullAway/deployments", "description": "A tool to help eliminate NullPointerExceptions (NPEs) in your Java code with low build-time overhead", "disabled": false, "downloads_url": "https://api.github.com/repos/uber/NullAway/downloads", "events_url": "https://api.github.com/repos/uber/NullAway/events", "fork": false, "forks": 0, "forks_count": 0, "forks_url": "https://api.github.com/repos/uber/NullAway/forks", "full_name": "uber/NullAway", "git_commits_url": "https://api.github.com/repos/uber/NullAway/git/commits{/sha}", "git_refs_url": "https://api.github.com/repos/uber/NullAway/git/refs{/sha}", "git_tags_url": "https://api.github.com/repos/uber/NullAway/git/tags{/sha}", "git_url": "git://github.com/uber/NullAway.git", "has_downloads": true, "has_issues": true, "has_pages": true, "has_projects": true, "has_wiki": true, "homepage": null, "hooks_url": "https://api.github.com/repos/uber/NullAway/hooks", "html_url": "https://github.com/uber/NullAway", "id": 102137661, "is_template": false, "issue_comment_url": "https://api.github.com/repos/uber/NullAway/issues/comments{/number}", "issue_events_url": "https://api.github.com/repos/uber/NullAway/issues/events{/number}", "issues_url": "https://api.github.com/repos/uber/NullAway/issues{/number}", "keys_url": "https://api.github.com/repos/uber/NullAway/keys{/key_id}", "labels_url": "https://api.github.com/repos/uber/NullAway/labels{/name}", "language": "", "languages_url": "https://api.github.com/repos/uber/NullAway/languages", "license": null, "master_branch": "master", "merges_url": "https://api.github.com/repos/uber/NullAway/merges", "milestones_url": "https://api.github.com/repos/uber/NullAway/milestones{/number}", "mirror_url": null, "name": "NullAway", "node_id": "MDEwOlJlcG9zaXRvcnkxMDIxMzc2NjE=", "notifications_url": "https://api.github.com/repos/uber/NullAway/notifications{?since,all,participating}", "open_issues": 0, "open_issues_count": 0, "owner": {"avatar_url": "https://avatars.githubusercontent.com/u/538264?v=4", "email": "", "events_url": "https://api.github.com/users/uber/events{/privacy}", "followers_url": "https://api.github.com/users/uber/followers", "following_url": "https://api.github.com/users/uber/following{/other_user}", "gists_url": "https://api.github.com/users/uber/gists{/gist_id}", "gravatar_id": "", "html_url": "https://github.com/uber", "id": 538264, "login": "uber", "name": "uber", "node_id": "MDEyOk9yZ2FuaXphdGlvbjUzODI2NA==", "organizations_url": "https://api.github.com/users/uber/orgs", "received_events_url": "https://api.github.com/users/uber/received_events", "repos_url": "https://api.github.com/users/uber/repos", "site_admin": false, "starred_url": "https://api.github.com/users/uber/starred{/owner}{/repo}", "subscriptions_url": "https://api.github.com/users/uber/subscriptions", "type": "Organization", "url": "https://api.github.com/users/uber"}, "private": false, "pulls_url": "https://api.github.com/repos/uber/NullAway/pulls{/number}", "pushed_at": 0, "releases_url": "https://api.github.com/repos/uber/NullAway/releases{/id}", "size": 0, "ssh_url": "git@github.com:uber/NullAway.git", "stargazers": 0, "stargazers_count": 0, "stargazers_url": "https://api.github.com/repos/uber/NullAway/stargazers", "statuses_url": "https://api.github.com/repos/uber/NullAway/statuses/{sha}", "subscribers_url": "https://api.github.com/repos/uber/NullAway/subscribers", "subscription_url": "https://api.github.com/repos/uber/NullAway/subscription", "svn_url": "https://github.com/uber/NullAway", "tags_url": "https://api.github.com/repos/uber/NullAway/tags", "teams_url": "https://api.github.com/repos/uber/NullAway/teams", "topics": [], "trees_url": "https://api.github.com/repos/uber/NullAway/git/trees{/sha}", "updated_at": "2026-03-04T14:36:38Z", "url": "https://api.github.com/repos/uber/NullAway", "visibility": "public", "watchers": 0, "watchers_count": 0, "web_commit_signoff_required": false}' o:'!=' l:'' p:')' o:'&&' p:'(' s:test-libmodel-varargs-new o:'!=' s:master p:')')" INPUT_CACHE-WRITE-ONLY=false INPUT_CACHE-OVERWRITE-EXISTING=false INPUT_CACHE-CLEANUP=on-success INPUT_GRADLE-HOME-CACHE-INCLUDES='caches
notifications
' INPUT_ADD-JOB-SUMMARY=always INPUT_ADD-JOB-SUMMARY-AS-PR-COMMENT=never INPUT_DEPENDENCY-GRAPH=disabled INPUT_DEPENDENCY-GRAPH-REPORT-DIR=dependency-graph-reports INPUT_DEPENDENCY-GRAPH-CONTINUE-ON-FAILURE=true INPUT_BUILD-SCAN-PUBLISH=false INPUT_VALIDATE-WRAPPERS=true INPUT_ALLOW-SNAPSHOT-WRAPPERS=false INPUT_GRADLE-HOME-CACHE-STRICT-MATCH=false INPUT_WORKFLOW-JOB-CONTEXT="$(/home/github/65725769130/helpers/eval_expression p:'(' f:toJSON p:'(' l:'{"os": "ubuntu-latest"}' p:')' p:')')" INPUT_GITHUB-TOKEN=DUMMY \
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=3 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=msridhar GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=test-libmodel-varargs-new GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/test-libmodel-varargs-new GITHUB_REF_NAME=test-libmodel-varargs-new GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=uber/NullAway GITHUB_REPOSITORY_OWNER=uber GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=c7127813910286d0967b7a5b26a0486d98bfba5d GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Continuous integration' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 "${CURRENT_ENV[@]}" \
echo $(test "$_GITHUB_JOB_STATUS" = "success" && echo true || echo false))
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=3 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=msridhar GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=test-libmodel-varargs-new GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/test-libmodel-varargs-new GITHUB_REF_NAME=test-libmodel-varargs-new GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=uber/NullAway GITHUB_REPOSITORY_OWNER=uber GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=c7127813910286d0967b7a5b26a0486d98bfba5d GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Continuous integration' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 "${CURRENT_ENV[@]}" \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run './gradlew build'
echo "##[endgroup]"
echo './gradlew build' > /home/github/65725769130/steps/bugswarm_3.sh
chmod u+x /home/github/65725769130/steps/bugswarm_3.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=3 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=msridhar GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=test-libmodel-varargs-new GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/test-libmodel-varargs-new GITHUB_REF_NAME=test-libmodel-varargs-new GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=uber/NullAway GITHUB_REPOSITORY_OWNER=uber GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=c7127813910286d0967b7a5b26a0486d98bfba5d GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Continuous integration' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 "${CURRENT_ENV[@]}" \
bash -e /home/github/65725769130/steps/bugswarm_3.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=3 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=msridhar GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=test-libmodel-varargs-new GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/test-libmodel-varargs-new GITHUB_REF_NAME=test-libmodel-varargs-new GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=uber/NullAway GITHUB_REPOSITORY_OWNER=uber GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=c7127813910286d0967b7a5b26a0486d98bfba5d GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Continuous integration' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 "${CURRENT_ENV[@]}" \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=3 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=msridhar GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=test-libmodel-varargs-new GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/test-libmodel-varargs-new GITHUB_REF_NAME=test-libmodel-varargs-new GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=uber/NullAway GITHUB_REPOSITORY_OWNER=uber GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=c7127813910286d0967b7a5b26a0486d98bfba5d GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Continuous integration' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 "${CURRENT_ENV[@]}" \
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=4 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=msridhar GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=test-libmodel-varargs-new GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/test-libmodel-varargs-new GITHUB_REF_NAME=test-libmodel-varargs-new GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=uber/NullAway GITHUB_REPOSITORY_OWNER=uber GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=c7127813910286d0967b7a5b26a0486d98bfba5d GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Continuous integration' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 "${CURRENT_ENV[@]}" \
echo "$(/home/github/65725769130/helpers/eval_expression p:'(' f:success p:'(' p:')' p:')' o:'&&' p:'(' s:Linux o:== s:Linux p:')')")
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=4 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=msridhar GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=test-libmodel-varargs-new GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/test-libmodel-varargs-new GITHUB_REF_NAME=test-libmodel-varargs-new GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=uber/NullAway GITHUB_REPOSITORY_OWNER=uber GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=c7127813910286d0967b7a5b26a0486d98bfba5d GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Continuous integration' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 "${CURRENT_ENV[@]}" \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run './gradlew shellcheck'
echo "##[endgroup]"
echo './gradlew shellcheck' > /home/github/65725769130/steps/bugswarm_4.sh
chmod u+x /home/github/65725769130/steps/bugswarm_4.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=4 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=msridhar GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=test-libmodel-varargs-new GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/test-libmodel-varargs-new GITHUB_REF_NAME=test-libmodel-varargs-new GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=uber/NullAway GITHUB_REPOSITORY_OWNER=uber GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=c7127813910286d0967b7a5b26a0486d98bfba5d GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Continuous integration' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 "${CURRENT_ENV[@]}" \
bash -e /home/github/65725769130/steps/bugswarm_4.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=4 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=msridhar GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=test-libmodel-varargs-new GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/test-libmodel-varargs-new GITHUB_REF_NAME=test-libmodel-varargs-new GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=uber/NullAway GITHUB_REPOSITORY_OWNER=uber GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=c7127813910286d0967b7a5b26a0486d98bfba5d GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Continuous integration' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 "${CURRENT_ENV[@]}" \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=4 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=msridhar GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=test-libmodel-varargs-new GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/test-libmodel-varargs-new GITHUB_REF_NAME=test-libmodel-varargs-new GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=uber/NullAway GITHUB_REPOSITORY_OWNER=uber GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=c7127813910286d0967b7a5b26a0486d98bfba5d GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Continuous integration' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 "${CURRENT_ENV[@]}" \
bash -e $ACTIONS_RUNNER_HOOK_STEP_COMPLETED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

fi

update_current_env "$LAST_JOB_NAME"
LAST_JOB_NAME="JACOCO_REPORT"
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=5 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=msridhar GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=test-libmodel-varargs-new GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/test-libmodel-varargs-new GITHUB_REF_NAME=test-libmodel-varargs-new GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=uber/NullAway GITHUB_REPOSITORY_OWNER=uber GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=c7127813910286d0967b7a5b26a0486d98bfba5d GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Continuous integration' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 "${CURRENT_ENV[@]}" \
echo "$(/home/github/65725769130/helpers/eval_expression p:'(' f:success p:'(' p:')' p:')' o:'&&' p:'(' p:'(' s:Linux o:== s:Linux p:')' o:'&&' p:'(' s:uber/NullAway o:== s:uber/NullAway p:')' p:')')")
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=5 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=msridhar GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=test-libmodel-varargs-new GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/test-libmodel-varargs-new GITHUB_REF_NAME=test-libmodel-varargs-new GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=uber/NullAway GITHUB_REPOSITORY_OWNER=uber GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=c7127813910286d0967b7a5b26a0486d98bfba5d GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Continuous integration' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 "${CURRENT_ENV[@]}" \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run './gradlew codeCoverageReport'
echo "##[endgroup]"
echo './gradlew codeCoverageReport' > /home/github/65725769130/steps/bugswarm_5.sh
chmod u+x /home/github/65725769130/steps/bugswarm_5.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=5 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=msridhar GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=test-libmodel-varargs-new GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/test-libmodel-varargs-new GITHUB_REF_NAME=test-libmodel-varargs-new GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=uber/NullAway GITHUB_REPOSITORY_OWNER=uber GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=c7127813910286d0967b7a5b26a0486d98bfba5d GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Continuous integration' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 "${CURRENT_ENV[@]}" \
bash -e /home/github/65725769130/steps/bugswarm_5.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=5 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=msridhar GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=test-libmodel-varargs-new GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/test-libmodel-varargs-new GITHUB_REF_NAME=test-libmodel-varargs-new GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=uber/NullAway GITHUB_REPOSITORY_OWNER=uber GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=c7127813910286d0967b7a5b26a0486d98bfba5d GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Continuous integration' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 "${CURRENT_ENV[@]}" \
echo true)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

  _CONTEXT_STEPS_JACOCO_REPORT_OUTCOME=failure
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    _CONTEXT_STEPS_JACOCO_REPORT_CONCLUSION=failure
  else
    _CONTEXT_STEPS_JACOCO_REPORT_CONCLUSION=success
  fi
else
  _CONTEXT_STEPS_JACOCO_REPORT_OUTCOME=success
  _CONTEXT_STEPS_JACOCO_REPORT_CONCLUSION=success
fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=5 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=msridhar GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=test-libmodel-varargs-new GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/test-libmodel-varargs-new GITHUB_REF_NAME=test-libmodel-varargs-new GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=uber/NullAway GITHUB_REPOSITORY_OWNER=uber GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=c7127813910286d0967b7a5b26a0486d98bfba5d GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Continuous integration' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 "${CURRENT_ENV[@]}" \
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=7 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=msridhar GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=test-libmodel-varargs-new GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/test-libmodel-varargs-new GITHUB_REF_NAME=test-libmodel-varargs-new GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=uber/NullAway GITHUB_REPOSITORY_OWNER=uber GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=c7127813910286d0967b7a5b26a0486d98bfba5d GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Continuous integration' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 "${CURRENT_ENV[@]}" \
echo "$(/home/github/65725769130/helpers/eval_expression p:'(' f:success p:'(' p:')' p:')' o:'&&' p:'(' s:${_CONTEXT_STEPS_JACOCO_REPORT_OUTCOME} o:== s:success p:')')")
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=7 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=msridhar GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=test-libmodel-varargs-new GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/test-libmodel-varargs-new GITHUB_REF_NAME=test-libmodel-varargs-new GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=uber/NullAway GITHUB_REPOSITORY_OWNER=uber GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=c7127813910286d0967b7a5b26a0486d98bfba5d GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Continuous integration' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 "${CURRENT_ENV[@]}" \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run '# See https://github.com/codecov/codecov-action/issues/1851'
echo "##[endgroup]"
echo '# See https://github.com/codecov/codecov-action/issues/1851
rm -rf codecov codecov.SHA256SUM codecov.SHA256SUM.sig
' > /home/github/65725769130/steps/bugswarm_7.sh
chmod u+x /home/github/65725769130/steps/bugswarm_7.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=7 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=msridhar GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=test-libmodel-varargs-new GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/test-libmodel-varargs-new GITHUB_REF_NAME=test-libmodel-varargs-new GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=uber/NullAway GITHUB_REPOSITORY_OWNER=uber GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=c7127813910286d0967b7a5b26a0486d98bfba5d GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Continuous integration' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 "${CURRENT_ENV[@]}" \
bash -e /home/github/65725769130/steps/bugswarm_7.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=7 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=msridhar GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=test-libmodel-varargs-new GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/test-libmodel-varargs-new GITHUB_REF_NAME=test-libmodel-varargs-new GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=uber/NullAway GITHUB_REPOSITORY_OWNER=uber GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=c7127813910286d0967b7a5b26a0486d98bfba5d GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Continuous integration' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 "${CURRENT_ENV[@]}" \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=7 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=msridhar GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=test-libmodel-varargs-new GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/test-libmodel-varargs-new GITHUB_REF_NAME=test-libmodel-varargs-new GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=uber/NullAway GITHUB_REPOSITORY_OWNER=uber GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=c7127813910286d0967b7a5b26a0486d98bfba5d GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Continuous integration' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 "${CURRENT_ENV[@]}" \
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=8 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=msridhar GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=test-libmodel-varargs-new GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/test-libmodel-varargs-new GITHUB_REF_NAME=test-libmodel-varargs-new GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=uber/NullAway GITHUB_REPOSITORY_OWNER=uber GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=c7127813910286d0967b7a5b26a0486d98bfba5d GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Continuous integration' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 "${CURRENT_ENV[@]}" ORG_GRADLE_PROJECT_VERSION_NAME=0.0.0.1-LOCAL ORG_GRADLE_PROJECT_RELEASE_SIGNING_ENABLED=false \
echo $(test "$_GITHUB_JOB_STATUS" = "success" && echo true || echo false))
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=8 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=msridhar GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=test-libmodel-varargs-new GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/test-libmodel-varargs-new GITHUB_REF_NAME=test-libmodel-varargs-new GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=uber/NullAway GITHUB_REPOSITORY_OWNER=uber GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=c7127813910286d0967b7a5b26a0486d98bfba5d GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Continuous integration' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 "${CURRENT_ENV[@]}" ORG_GRADLE_PROJECT_VERSION_NAME=0.0.0.1-LOCAL ORG_GRADLE_PROJECT_RELEASE_SIGNING_ENABLED=false \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run './gradlew publishToMavenLocal'
echo "##[endgroup]"
echo './gradlew publishToMavenLocal' > /home/github/65725769130/steps/bugswarm_8.sh
chmod u+x /home/github/65725769130/steps/bugswarm_8.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=8 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=msridhar GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=test-libmodel-varargs-new GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/test-libmodel-varargs-new GITHUB_REF_NAME=test-libmodel-varargs-new GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=uber/NullAway GITHUB_REPOSITORY_OWNER=uber GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=c7127813910286d0967b7a5b26a0486d98bfba5d GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Continuous integration' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 "${CURRENT_ENV[@]}" ORG_GRADLE_PROJECT_VERSION_NAME=0.0.0.1-LOCAL ORG_GRADLE_PROJECT_RELEASE_SIGNING_ENABLED=false \
bash -e /home/github/65725769130/steps/bugswarm_8.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=8 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=msridhar GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=test-libmodel-varargs-new GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/test-libmodel-varargs-new GITHUB_REF_NAME=test-libmodel-varargs-new GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=uber/NullAway GITHUB_REPOSITORY_OWNER=uber GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=c7127813910286d0967b7a5b26a0486d98bfba5d GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Continuous integration' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 "${CURRENT_ENV[@]}" ORG_GRADLE_PROJECT_VERSION_NAME=0.0.0.1-LOCAL ORG_GRADLE_PROJECT_RELEASE_SIGNING_ENABLED=false \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=8 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=msridhar GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=test-libmodel-varargs-new GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/test-libmodel-varargs-new GITHUB_REF_NAME=test-libmodel-varargs-new GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=uber/NullAway GITHUB_REPOSITORY_OWNER=uber GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=c7127813910286d0967b7a5b26a0486d98bfba5d GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Continuous integration' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 "${CURRENT_ENV[@]}" ORG_GRADLE_PROJECT_VERSION_NAME=0.0.0.1-LOCAL ORG_GRADLE_PROJECT_RELEASE_SIGNING_ENABLED=false \
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=9 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=msridhar GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=test-libmodel-varargs-new GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/test-libmodel-varargs-new GITHUB_REF_NAME=test-libmodel-varargs-new GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=uber/NullAway GITHUB_REPOSITORY_OWNER=uber GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=c7127813910286d0967b7a5b26a0486d98bfba5d GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Continuous integration' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 "${CURRENT_ENV[@]}" \
echo $(test "$_GITHUB_JOB_STATUS" = "success" && echo true || echo false))
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=9 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=msridhar GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=test-libmodel-varargs-new GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/test-libmodel-varargs-new GITHUB_REF_NAME=test-libmodel-varargs-new GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=uber/NullAway GITHUB_REPOSITORY_OWNER=uber GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=c7127813910286d0967b7a5b26a0486d98bfba5d GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Continuous integration' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 "${CURRENT_ENV[@]}" \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run ./.buildscript/check_git_clean.sh
echo "##[endgroup]"
echo ./.buildscript/check_git_clean.sh > /home/github/65725769130/steps/bugswarm_9.sh
chmod u+x /home/github/65725769130/steps/bugswarm_9.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=9 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=msridhar GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=test-libmodel-varargs-new GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/test-libmodel-varargs-new GITHUB_REF_NAME=test-libmodel-varargs-new GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=uber/NullAway GITHUB_REPOSITORY_OWNER=uber GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=c7127813910286d0967b7a5b26a0486d98bfba5d GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Continuous integration' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 "${CURRENT_ENV[@]}" \
bash -e /home/github/65725769130/steps/bugswarm_9.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=9 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=msridhar GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=test-libmodel-varargs-new GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/test-libmodel-varargs-new GITHUB_REF_NAME=test-libmodel-varargs-new GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=uber/NullAway GITHUB_REPOSITORY_OWNER=uber GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=c7127813910286d0967b7a5b26a0486d98bfba5d GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Continuous integration' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 "${CURRENT_ENV[@]}" \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=9 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=msridhar GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=test-libmodel-varargs-new GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/test-libmodel-varargs-new GITHUB_REF_NAME=test-libmodel-varargs-new GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=uber/NullAway GITHUB_REPOSITORY_OWNER=uber GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=c7127813910286d0967b7a5b26a0486d98bfba5d GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW='Continuous integration' GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 "${CURRENT_ENV[@]}" \
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
   bash -e $ACTIONS_RUNNER_HOOK_JOB_COMPLETED 65725769130 passed
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
