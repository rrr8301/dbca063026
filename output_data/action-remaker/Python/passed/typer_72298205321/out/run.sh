#!/usr/bin/env bash
export GITHUB_WORKSPACE=/home/github/build/fastapi/typer

if [[ ! -z "$ACTIONS_RUNNER_HOOK_JOB_STARTED" ]]; then
   echo "A job started hook has been configured by the self-hosted runner administrator"
   echo "##[group]Run '$ACTIONS_RUNNER_HOOK_JOB_STARTED'"
   echo "##[endgroup]"
   bash -e $ACTIONS_RUNNER_HOOK_JOB_STARTED 72298205321 passed
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

cp /home/github/72298205321/event.json /home/github/workflow/event.json
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=0 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=svlandeg GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=fastapi/typer GITHUB_REPOSITORY_OWNER=fastapi GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=22a86d3f267c26865b239bb9c4c14f232af3baa3 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Test GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 UV_NO_SYNC=true UV_PYTHON=3.14 UV_RESOLUTION=highest "${CURRENT_ENV[@]}" GITHUB_CONTEXT="$(/home/github/72298205321/helpers/eval_expression p:'(' f:toJson p:'(' l:'{"token": "DUMMY", "job": "", "ref": "refs/heads/master", "sha": "22a86d3f267c26865b239bb9c4c14f232af3baa3", "repository": "fastapi/typer", "repository_owner": "fastapi", "repositoryUrl": "git://github.com/fastapi/typer.git", "run_id": "72298205321", "run_number": 24717678590, "retention_days": "0", "run_attempt": "1", "actor": "svlandeg", "triggering_actor": "svlandeg", "workflow": "Test", "head_ref": "", "base_ref": "", "event_name": "push", "event": {"after": "", "base_ref": null, "before": "", "commits": [{"author": {"email": "49699333+dependabot[bot]@users.noreply.github.com", "name": "dependabot[bot]", "username": "svlandeg"}, "committer": {"email": "noreply@github.com", "name": "GitHub", "username": "web-flow"}, "distinct": true, "id": "22a86d3f267c26865b239bb9c4c14f232af3baa3", "message": "\u2b06 Bump pydantic-settings from 2.13.1 to 2.14.0 (#1713)\n\nSigned-off-by: dependabot[bot] <support@github.com>\nCo-authored-by: dependabot[bot] <49699333+dependabot[bot]@users.noreply.github.com>", "timestamp": "2026-04-21T10:34:28Z", "tree_id": "5c99a6e77acca8373d0beaff11b56c74a70e1eda", "url": ""}], "compare": "", "created": false, "deleted": false, "forced": false, "head_commit": {"author": {"email": "49699333+dependabot[bot]@users.noreply.github.com", "name": "dependabot[bot]", "username": "svlandeg"}, "committer": {"email": "noreply@github.com", "name": "GitHub", "username": "web-flow"}, "distinct": true, "id": "22a86d3f267c26865b239bb9c4c14f232af3baa3", "message": "\u2b06 Bump pydantic-settings from 2.13.1 to 2.14.0 (#1713)\n\nSigned-off-by: dependabot[bot] <support@github.com>\nCo-authored-by: dependabot[bot] <49699333+dependabot[bot]@users.noreply.github.com>", "timestamp": "2026-04-21T10:34:28Z", "tree_id": "5c99a6e77acca8373d0beaff11b56c74a70e1eda", "url": ""}, "pusher": {"email": "49699333+dependabot[bot]@users.noreply.github.com", "name": "svlandeg"}, "ref": "refs/heads/master", "repository": {"allow_forking": true, "archive_url": "https://api.github.com/repos/fastapi/typer/{archive_format}{/ref}", "archived": false, "assignees_url": "https://api.github.com/repos/fastapi/typer/assignees{/user}", "blobs_url": "https://api.github.com/repos/fastapi/typer/git/blobs{/sha}", "branches_url": "https://api.github.com/repos/fastapi/typer/branches{/branch}", "clone_url": "https://github.com/fastapi/typer.git", "collaborators_url": "https://api.github.com/repos/fastapi/typer/collaborators{/collaborator}", "comments_url": "https://api.github.com/repos/fastapi/typer/comments{/number}", "commits_url": "https://api.github.com/repos/fastapi/typer/commits{/sha}", "compare_url": "https://api.github.com/repos/fastapi/typer/compare/{base}...{head}", "contents_url": "https://api.github.com/repos/fastapi/typer/contents/{+path}", "contributors_url": "https://api.github.com/repos/fastapi/typer/contributors", "created_at": 0, "default_branch": "master", "deployments_url": "https://api.github.com/repos/fastapi/typer/deployments", "description": "Typer, build great CLIs. Easy to code. Based on Python type hints.", "disabled": false, "downloads_url": "https://api.github.com/repos/fastapi/typer/downloads", "events_url": "https://api.github.com/repos/fastapi/typer/events", "fork": false, "forks": 0, "forks_count": 0, "forks_url": "https://api.github.com/repos/fastapi/typer/forks", "full_name": "fastapi/typer", "git_commits_url": "https://api.github.com/repos/fastapi/typer/git/commits{/sha}", "git_refs_url": "https://api.github.com/repos/fastapi/typer/git/refs{/sha}", "git_tags_url": "https://api.github.com/repos/fastapi/typer/git/tags{/sha}", "git_url": "git://github.com/fastapi/typer.git", "has_downloads": true, "has_issues": true, "has_pages": true, "has_projects": true, "has_wiki": true, "homepage": null, "hooks_url": "https://api.github.com/repos/fastapi/typer/hooks", "html_url": "https://github.com/fastapi/typer", "id": 229937405, "is_template": false, "issue_comment_url": "https://api.github.com/repos/fastapi/typer/issues/comments{/number}", "issue_events_url": "https://api.github.com/repos/fastapi/typer/issues/events{/number}", "issues_url": "https://api.github.com/repos/fastapi/typer/issues{/number}", "keys_url": "https://api.github.com/repos/fastapi/typer/keys{/key_id}", "labels_url": "https://api.github.com/repos/fastapi/typer/labels{/name}", "language": "", "languages_url": "https://api.github.com/repos/fastapi/typer/languages", "license": null, "master_branch": "master", "merges_url": "https://api.github.com/repos/fastapi/typer/merges", "milestones_url": "https://api.github.com/repos/fastapi/typer/milestones{/number}", "mirror_url": null, "name": "typer", "node_id": "MDEwOlJlcG9zaXRvcnkyMjk5Mzc0MDU=", "notifications_url": "https://api.github.com/repos/fastapi/typer/notifications{?since,all,participating}", "open_issues": 0, "open_issues_count": 0, "owner": {"avatar_url": "https://avatars.githubusercontent.com/u/156354296?v=4", "email": "", "events_url": "https://api.github.com/users/fastapi/events{/privacy}", "followers_url": "https://api.github.com/users/fastapi/followers", "following_url": "https://api.github.com/users/fastapi/following{/other_user}", "gists_url": "https://api.github.com/users/fastapi/gists{/gist_id}", "gravatar_id": "", "html_url": "https://github.com/fastapi", "id": 156354296, "login": "fastapi", "name": "fastapi", "node_id": "O_kgDOCVHG-A", "organizations_url": "https://api.github.com/users/fastapi/orgs", "received_events_url": "https://api.github.com/users/fastapi/received_events", "repos_url": "https://api.github.com/users/fastapi/repos", "site_admin": false, "starred_url": "https://api.github.com/users/fastapi/starred{/owner}{/repo}", "subscriptions_url": "https://api.github.com/users/fastapi/subscriptions", "type": "Organization", "url": "https://api.github.com/users/fastapi"}, "private": false, "pulls_url": "https://api.github.com/repos/fastapi/typer/pulls{/number}", "pushed_at": 0, "releases_url": "https://api.github.com/repos/fastapi/typer/releases{/id}", "size": 0, "ssh_url": "git@github.com:fastapi/typer.git", "stargazers": 0, "stargazers_count": 0, "stargazers_url": "https://api.github.com/repos/fastapi/typer/stargazers", "statuses_url": "https://api.github.com/repos/fastapi/typer/statuses/{sha}", "subscribers_url": "https://api.github.com/repos/fastapi/typer/subscribers", "subscription_url": "https://api.github.com/repos/fastapi/typer/subscription", "svn_url": "https://github.com/fastapi/typer", "tags_url": "https://api.github.com/repos/fastapi/typer/tags", "teams_url": "https://api.github.com/repos/fastapi/typer/teams", "topics": [], "trees_url": "https://api.github.com/repos/fastapi/typer/git/trees{/sha}", "updated_at": "2026-04-21T10:34:28Z", "url": "https://api.github.com/repos/fastapi/typer", "visibility": "public", "watchers": 0, "watchers_count": 0, "web_commit_signoff_required": false}, "sender": {"avatar_url": "https://avatars.githubusercontent.com/u/8796347?v=4", "email": "", "events_url": "https://api.github.com/users/svlandeg/events{/privacy}", "followers_url": "https://api.github.com/users/svlandeg/followers", "following_url": "https://api.github.com/users/svlandeg/following{/other_user}", "gists_url": "https://api.github.com/users/svlandeg/gists{/gist_id}", "gravatar_id": "", "html_url": "https://github.com/svlandeg", "id": 8796347, "login": "svlandeg", "name": "svlandeg", "node_id": "MDQ6VXNlcjg3OTYzNDc=", "organizations_url": "https://api.github.com/users/svlandeg/orgs", "received_events_url": "https://api.github.com/users/svlandeg/received_events", "repos_url": "https://api.github.com/users/svlandeg/repos", "site_admin": false, "starred_url": "https://api.github.com/users/svlandeg/starred{/owner}{/repo}", "subscriptions_url": "https://api.github.com/users/svlandeg/subscriptions", "type": "User", "url": "https://api.github.com/users/svlandeg"}}, "server_url": "https://github.com", "api_url": "https://api.github.com", "graphql_url": "https://api.github.com/graphql", "ref_name": "master", "ref_protected": "false", "ref_type": "branch", "secret_source": "", "event_path": "/home/github/workflow/event.json", "path": "/home/github/workflow/paths.txt", "env": "/home/github/workflow/envs.txt", "workspace": "", "action": "", "action_repository": "", "action_status": "", "action_path": "", "action_ref": ""}' p:')' p:')')" \
echo $(test "$_GITHUB_JOB_STATUS" = "success" && echo true || echo false))
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=0 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=svlandeg GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=fastapi/typer GITHUB_REPOSITORY_OWNER=fastapi GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=22a86d3f267c26865b239bb9c4c14f232af3baa3 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Test GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 UV_NO_SYNC=true UV_PYTHON=3.14 UV_RESOLUTION=highest "${CURRENT_ENV[@]}" GITHUB_CONTEXT="$(/home/github/72298205321/helpers/eval_expression p:'(' f:toJson p:'(' l:'{"token": "DUMMY", "job": "", "ref": "refs/heads/master", "sha": "22a86d3f267c26865b239bb9c4c14f232af3baa3", "repository": "fastapi/typer", "repository_owner": "fastapi", "repositoryUrl": "git://github.com/fastapi/typer.git", "run_id": "72298205321", "run_number": 24717678590, "retention_days": "0", "run_attempt": "1", "actor": "svlandeg", "triggering_actor": "svlandeg", "workflow": "Test", "head_ref": "", "base_ref": "", "event_name": "push", "event": {"after": "", "base_ref": null, "before": "", "commits": [{"author": {"email": "49699333+dependabot[bot]@users.noreply.github.com", "name": "dependabot[bot]", "username": "svlandeg"}, "committer": {"email": "noreply@github.com", "name": "GitHub", "username": "web-flow"}, "distinct": true, "id": "22a86d3f267c26865b239bb9c4c14f232af3baa3", "message": "\u2b06 Bump pydantic-settings from 2.13.1 to 2.14.0 (#1713)\n\nSigned-off-by: dependabot[bot] <support@github.com>\nCo-authored-by: dependabot[bot] <49699333+dependabot[bot]@users.noreply.github.com>", "timestamp": "2026-04-21T10:34:28Z", "tree_id": "5c99a6e77acca8373d0beaff11b56c74a70e1eda", "url": ""}], "compare": "", "created": false, "deleted": false, "forced": false, "head_commit": {"author": {"email": "49699333+dependabot[bot]@users.noreply.github.com", "name": "dependabot[bot]", "username": "svlandeg"}, "committer": {"email": "noreply@github.com", "name": "GitHub", "username": "web-flow"}, "distinct": true, "id": "22a86d3f267c26865b239bb9c4c14f232af3baa3", "message": "\u2b06 Bump pydantic-settings from 2.13.1 to 2.14.0 (#1713)\n\nSigned-off-by: dependabot[bot] <support@github.com>\nCo-authored-by: dependabot[bot] <49699333+dependabot[bot]@users.noreply.github.com>", "timestamp": "2026-04-21T10:34:28Z", "tree_id": "5c99a6e77acca8373d0beaff11b56c74a70e1eda", "url": ""}, "pusher": {"email": "49699333+dependabot[bot]@users.noreply.github.com", "name": "svlandeg"}, "ref": "refs/heads/master", "repository": {"allow_forking": true, "archive_url": "https://api.github.com/repos/fastapi/typer/{archive_format}{/ref}", "archived": false, "assignees_url": "https://api.github.com/repos/fastapi/typer/assignees{/user}", "blobs_url": "https://api.github.com/repos/fastapi/typer/git/blobs{/sha}", "branches_url": "https://api.github.com/repos/fastapi/typer/branches{/branch}", "clone_url": "https://github.com/fastapi/typer.git", "collaborators_url": "https://api.github.com/repos/fastapi/typer/collaborators{/collaborator}", "comments_url": "https://api.github.com/repos/fastapi/typer/comments{/number}", "commits_url": "https://api.github.com/repos/fastapi/typer/commits{/sha}", "compare_url": "https://api.github.com/repos/fastapi/typer/compare/{base}...{head}", "contents_url": "https://api.github.com/repos/fastapi/typer/contents/{+path}", "contributors_url": "https://api.github.com/repos/fastapi/typer/contributors", "created_at": 0, "default_branch": "master", "deployments_url": "https://api.github.com/repos/fastapi/typer/deployments", "description": "Typer, build great CLIs. Easy to code. Based on Python type hints.", "disabled": false, "downloads_url": "https://api.github.com/repos/fastapi/typer/downloads", "events_url": "https://api.github.com/repos/fastapi/typer/events", "fork": false, "forks": 0, "forks_count": 0, "forks_url": "https://api.github.com/repos/fastapi/typer/forks", "full_name": "fastapi/typer", "git_commits_url": "https://api.github.com/repos/fastapi/typer/git/commits{/sha}", "git_refs_url": "https://api.github.com/repos/fastapi/typer/git/refs{/sha}", "git_tags_url": "https://api.github.com/repos/fastapi/typer/git/tags{/sha}", "git_url": "git://github.com/fastapi/typer.git", "has_downloads": true, "has_issues": true, "has_pages": true, "has_projects": true, "has_wiki": true, "homepage": null, "hooks_url": "https://api.github.com/repos/fastapi/typer/hooks", "html_url": "https://github.com/fastapi/typer", "id": 229937405, "is_template": false, "issue_comment_url": "https://api.github.com/repos/fastapi/typer/issues/comments{/number}", "issue_events_url": "https://api.github.com/repos/fastapi/typer/issues/events{/number}", "issues_url": "https://api.github.com/repos/fastapi/typer/issues{/number}", "keys_url": "https://api.github.com/repos/fastapi/typer/keys{/key_id}", "labels_url": "https://api.github.com/repos/fastapi/typer/labels{/name}", "language": "", "languages_url": "https://api.github.com/repos/fastapi/typer/languages", "license": null, "master_branch": "master", "merges_url": "https://api.github.com/repos/fastapi/typer/merges", "milestones_url": "https://api.github.com/repos/fastapi/typer/milestones{/number}", "mirror_url": null, "name": "typer", "node_id": "MDEwOlJlcG9zaXRvcnkyMjk5Mzc0MDU=", "notifications_url": "https://api.github.com/repos/fastapi/typer/notifications{?since,all,participating}", "open_issues": 0, "open_issues_count": 0, "owner": {"avatar_url": "https://avatars.githubusercontent.com/u/156354296?v=4", "email": "", "events_url": "https://api.github.com/users/fastapi/events{/privacy}", "followers_url": "https://api.github.com/users/fastapi/followers", "following_url": "https://api.github.com/users/fastapi/following{/other_user}", "gists_url": "https://api.github.com/users/fastapi/gists{/gist_id}", "gravatar_id": "", "html_url": "https://github.com/fastapi", "id": 156354296, "login": "fastapi", "name": "fastapi", "node_id": "O_kgDOCVHG-A", "organizations_url": "https://api.github.com/users/fastapi/orgs", "received_events_url": "https://api.github.com/users/fastapi/received_events", "repos_url": "https://api.github.com/users/fastapi/repos", "site_admin": false, "starred_url": "https://api.github.com/users/fastapi/starred{/owner}{/repo}", "subscriptions_url": "https://api.github.com/users/fastapi/subscriptions", "type": "Organization", "url": "https://api.github.com/users/fastapi"}, "private": false, "pulls_url": "https://api.github.com/repos/fastapi/typer/pulls{/number}", "pushed_at": 0, "releases_url": "https://api.github.com/repos/fastapi/typer/releases{/id}", "size": 0, "ssh_url": "git@github.com:fastapi/typer.git", "stargazers": 0, "stargazers_count": 0, "stargazers_url": "https://api.github.com/repos/fastapi/typer/stargazers", "statuses_url": "https://api.github.com/repos/fastapi/typer/statuses/{sha}", "subscribers_url": "https://api.github.com/repos/fastapi/typer/subscribers", "subscription_url": "https://api.github.com/repos/fastapi/typer/subscription", "svn_url": "https://github.com/fastapi/typer", "tags_url": "https://api.github.com/repos/fastapi/typer/tags", "teams_url": "https://api.github.com/repos/fastapi/typer/teams", "topics": [], "trees_url": "https://api.github.com/repos/fastapi/typer/git/trees{/sha}", "updated_at": "2026-04-21T10:34:28Z", "url": "https://api.github.com/repos/fastapi/typer", "visibility": "public", "watchers": 0, "watchers_count": 0, "web_commit_signoff_required": false}, "sender": {"avatar_url": "https://avatars.githubusercontent.com/u/8796347?v=4", "email": "", "events_url": "https://api.github.com/users/svlandeg/events{/privacy}", "followers_url": "https://api.github.com/users/svlandeg/followers", "following_url": "https://api.github.com/users/svlandeg/following{/other_user}", "gists_url": "https://api.github.com/users/svlandeg/gists{/gist_id}", "gravatar_id": "", "html_url": "https://github.com/svlandeg", "id": 8796347, "login": "svlandeg", "name": "svlandeg", "node_id": "MDQ6VXNlcjg3OTYzNDc=", "organizations_url": "https://api.github.com/users/svlandeg/orgs", "received_events_url": "https://api.github.com/users/svlandeg/received_events", "repos_url": "https://api.github.com/users/svlandeg/repos", "site_admin": false, "starred_url": "https://api.github.com/users/svlandeg/starred{/owner}{/repo}", "subscriptions_url": "https://api.github.com/users/svlandeg/subscriptions", "type": "User", "url": "https://api.github.com/users/svlandeg"}}, "server_url": "https://github.com", "api_url": "https://api.github.com", "graphql_url": "https://api.github.com/graphql", "ref_name": "master", "ref_protected": "false", "ref_type": "branch", "secret_source": "", "event_path": "/home/github/workflow/event.json", "path": "/home/github/workflow/paths.txt", "env": "/home/github/workflow/envs.txt", "workspace": "", "action": "", "action_repository": "", "action_status": "", "action_path": "", "action_ref": ""}' p:')' p:')')" \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run 'echo "$GITHUB_CONTEXT"'
echo "##[endgroup]"
echo 'echo "$GITHUB_CONTEXT"' > /home/github/72298205321/steps/bugswarm_0.sh
chmod u+x /home/github/72298205321/steps/bugswarm_0.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=0 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=svlandeg GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=fastapi/typer GITHUB_REPOSITORY_OWNER=fastapi GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=22a86d3f267c26865b239bb9c4c14f232af3baa3 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Test GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 UV_NO_SYNC=true UV_PYTHON=3.14 UV_RESOLUTION=highest "${CURRENT_ENV[@]}" GITHUB_CONTEXT="$(/home/github/72298205321/helpers/eval_expression p:'(' f:toJson p:'(' l:'{"token": "DUMMY", "job": "", "ref": "refs/heads/master", "sha": "22a86d3f267c26865b239bb9c4c14f232af3baa3", "repository": "fastapi/typer", "repository_owner": "fastapi", "repositoryUrl": "git://github.com/fastapi/typer.git", "run_id": "72298205321", "run_number": 24717678590, "retention_days": "0", "run_attempt": "1", "actor": "svlandeg", "triggering_actor": "svlandeg", "workflow": "Test", "head_ref": "", "base_ref": "", "event_name": "push", "event": {"after": "", "base_ref": null, "before": "", "commits": [{"author": {"email": "49699333+dependabot[bot]@users.noreply.github.com", "name": "dependabot[bot]", "username": "svlandeg"}, "committer": {"email": "noreply@github.com", "name": "GitHub", "username": "web-flow"}, "distinct": true, "id": "22a86d3f267c26865b239bb9c4c14f232af3baa3", "message": "\u2b06 Bump pydantic-settings from 2.13.1 to 2.14.0 (#1713)\n\nSigned-off-by: dependabot[bot] <support@github.com>\nCo-authored-by: dependabot[bot] <49699333+dependabot[bot]@users.noreply.github.com>", "timestamp": "2026-04-21T10:34:28Z", "tree_id": "5c99a6e77acca8373d0beaff11b56c74a70e1eda", "url": ""}], "compare": "", "created": false, "deleted": false, "forced": false, "head_commit": {"author": {"email": "49699333+dependabot[bot]@users.noreply.github.com", "name": "dependabot[bot]", "username": "svlandeg"}, "committer": {"email": "noreply@github.com", "name": "GitHub", "username": "web-flow"}, "distinct": true, "id": "22a86d3f267c26865b239bb9c4c14f232af3baa3", "message": "\u2b06 Bump pydantic-settings from 2.13.1 to 2.14.0 (#1713)\n\nSigned-off-by: dependabot[bot] <support@github.com>\nCo-authored-by: dependabot[bot] <49699333+dependabot[bot]@users.noreply.github.com>", "timestamp": "2026-04-21T10:34:28Z", "tree_id": "5c99a6e77acca8373d0beaff11b56c74a70e1eda", "url": ""}, "pusher": {"email": "49699333+dependabot[bot]@users.noreply.github.com", "name": "svlandeg"}, "ref": "refs/heads/master", "repository": {"allow_forking": true, "archive_url": "https://api.github.com/repos/fastapi/typer/{archive_format}{/ref}", "archived": false, "assignees_url": "https://api.github.com/repos/fastapi/typer/assignees{/user}", "blobs_url": "https://api.github.com/repos/fastapi/typer/git/blobs{/sha}", "branches_url": "https://api.github.com/repos/fastapi/typer/branches{/branch}", "clone_url": "https://github.com/fastapi/typer.git", "collaborators_url": "https://api.github.com/repos/fastapi/typer/collaborators{/collaborator}", "comments_url": "https://api.github.com/repos/fastapi/typer/comments{/number}", "commits_url": "https://api.github.com/repos/fastapi/typer/commits{/sha}", "compare_url": "https://api.github.com/repos/fastapi/typer/compare/{base}...{head}", "contents_url": "https://api.github.com/repos/fastapi/typer/contents/{+path}", "contributors_url": "https://api.github.com/repos/fastapi/typer/contributors", "created_at": 0, "default_branch": "master", "deployments_url": "https://api.github.com/repos/fastapi/typer/deployments", "description": "Typer, build great CLIs. Easy to code. Based on Python type hints.", "disabled": false, "downloads_url": "https://api.github.com/repos/fastapi/typer/downloads", "events_url": "https://api.github.com/repos/fastapi/typer/events", "fork": false, "forks": 0, "forks_count": 0, "forks_url": "https://api.github.com/repos/fastapi/typer/forks", "full_name": "fastapi/typer", "git_commits_url": "https://api.github.com/repos/fastapi/typer/git/commits{/sha}", "git_refs_url": "https://api.github.com/repos/fastapi/typer/git/refs{/sha}", "git_tags_url": "https://api.github.com/repos/fastapi/typer/git/tags{/sha}", "git_url": "git://github.com/fastapi/typer.git", "has_downloads": true, "has_issues": true, "has_pages": true, "has_projects": true, "has_wiki": true, "homepage": null, "hooks_url": "https://api.github.com/repos/fastapi/typer/hooks", "html_url": "https://github.com/fastapi/typer", "id": 229937405, "is_template": false, "issue_comment_url": "https://api.github.com/repos/fastapi/typer/issues/comments{/number}", "issue_events_url": "https://api.github.com/repos/fastapi/typer/issues/events{/number}", "issues_url": "https://api.github.com/repos/fastapi/typer/issues{/number}", "keys_url": "https://api.github.com/repos/fastapi/typer/keys{/key_id}", "labels_url": "https://api.github.com/repos/fastapi/typer/labels{/name}", "language": "", "languages_url": "https://api.github.com/repos/fastapi/typer/languages", "license": null, "master_branch": "master", "merges_url": "https://api.github.com/repos/fastapi/typer/merges", "milestones_url": "https://api.github.com/repos/fastapi/typer/milestones{/number}", "mirror_url": null, "name": "typer", "node_id": "MDEwOlJlcG9zaXRvcnkyMjk5Mzc0MDU=", "notifications_url": "https://api.github.com/repos/fastapi/typer/notifications{?since,all,participating}", "open_issues": 0, "open_issues_count": 0, "owner": {"avatar_url": "https://avatars.githubusercontent.com/u/156354296?v=4", "email": "", "events_url": "https://api.github.com/users/fastapi/events{/privacy}", "followers_url": "https://api.github.com/users/fastapi/followers", "following_url": "https://api.github.com/users/fastapi/following{/other_user}", "gists_url": "https://api.github.com/users/fastapi/gists{/gist_id}", "gravatar_id": "", "html_url": "https://github.com/fastapi", "id": 156354296, "login": "fastapi", "name": "fastapi", "node_id": "O_kgDOCVHG-A", "organizations_url": "https://api.github.com/users/fastapi/orgs", "received_events_url": "https://api.github.com/users/fastapi/received_events", "repos_url": "https://api.github.com/users/fastapi/repos", "site_admin": false, "starred_url": "https://api.github.com/users/fastapi/starred{/owner}{/repo}", "subscriptions_url": "https://api.github.com/users/fastapi/subscriptions", "type": "Organization", "url": "https://api.github.com/users/fastapi"}, "private": false, "pulls_url": "https://api.github.com/repos/fastapi/typer/pulls{/number}", "pushed_at": 0, "releases_url": "https://api.github.com/repos/fastapi/typer/releases{/id}", "size": 0, "ssh_url": "git@github.com:fastapi/typer.git", "stargazers": 0, "stargazers_count": 0, "stargazers_url": "https://api.github.com/repos/fastapi/typer/stargazers", "statuses_url": "https://api.github.com/repos/fastapi/typer/statuses/{sha}", "subscribers_url": "https://api.github.com/repos/fastapi/typer/subscribers", "subscription_url": "https://api.github.com/repos/fastapi/typer/subscription", "svn_url": "https://github.com/fastapi/typer", "tags_url": "https://api.github.com/repos/fastapi/typer/tags", "teams_url": "https://api.github.com/repos/fastapi/typer/teams", "topics": [], "trees_url": "https://api.github.com/repos/fastapi/typer/git/trees{/sha}", "updated_at": "2026-04-21T10:34:28Z", "url": "https://api.github.com/repos/fastapi/typer", "visibility": "public", "watchers": 0, "watchers_count": 0, "web_commit_signoff_required": false}, "sender": {"avatar_url": "https://avatars.githubusercontent.com/u/8796347?v=4", "email": "", "events_url": "https://api.github.com/users/svlandeg/events{/privacy}", "followers_url": "https://api.github.com/users/svlandeg/followers", "following_url": "https://api.github.com/users/svlandeg/following{/other_user}", "gists_url": "https://api.github.com/users/svlandeg/gists{/gist_id}", "gravatar_id": "", "html_url": "https://github.com/svlandeg", "id": 8796347, "login": "svlandeg", "name": "svlandeg", "node_id": "MDQ6VXNlcjg3OTYzNDc=", "organizations_url": "https://api.github.com/users/svlandeg/orgs", "received_events_url": "https://api.github.com/users/svlandeg/received_events", "repos_url": "https://api.github.com/users/svlandeg/repos", "site_admin": false, "starred_url": "https://api.github.com/users/svlandeg/starred{/owner}{/repo}", "subscriptions_url": "https://api.github.com/users/svlandeg/subscriptions", "type": "User", "url": "https://api.github.com/users/svlandeg"}}, "server_url": "https://github.com", "api_url": "https://api.github.com", "graphql_url": "https://api.github.com/graphql", "ref_name": "master", "ref_protected": "false", "ref_type": "branch", "secret_source": "", "event_path": "/home/github/workflow/event.json", "path": "/home/github/workflow/paths.txt", "env": "/home/github/workflow/envs.txt", "workspace": "", "action": "", "action_repository": "", "action_status": "", "action_path": "", "action_ref": ""}' p:')' p:')')" \
bash -e /home/github/72298205321/steps/bugswarm_0.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=0 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=svlandeg GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=fastapi/typer GITHUB_REPOSITORY_OWNER=fastapi GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=22a86d3f267c26865b239bb9c4c14f232af3baa3 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Test GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 UV_NO_SYNC=true UV_PYTHON=3.14 UV_RESOLUTION=highest "${CURRENT_ENV[@]}" GITHUB_CONTEXT="$(/home/github/72298205321/helpers/eval_expression p:'(' f:toJson p:'(' l:'{"token": "DUMMY", "job": "", "ref": "refs/heads/master", "sha": "22a86d3f267c26865b239bb9c4c14f232af3baa3", "repository": "fastapi/typer", "repository_owner": "fastapi", "repositoryUrl": "git://github.com/fastapi/typer.git", "run_id": "72298205321", "run_number": 24717678590, "retention_days": "0", "run_attempt": "1", "actor": "svlandeg", "triggering_actor": "svlandeg", "workflow": "Test", "head_ref": "", "base_ref": "", "event_name": "push", "event": {"after": "", "base_ref": null, "before": "", "commits": [{"author": {"email": "49699333+dependabot[bot]@users.noreply.github.com", "name": "dependabot[bot]", "username": "svlandeg"}, "committer": {"email": "noreply@github.com", "name": "GitHub", "username": "web-flow"}, "distinct": true, "id": "22a86d3f267c26865b239bb9c4c14f232af3baa3", "message": "\u2b06 Bump pydantic-settings from 2.13.1 to 2.14.0 (#1713)\n\nSigned-off-by: dependabot[bot] <support@github.com>\nCo-authored-by: dependabot[bot] <49699333+dependabot[bot]@users.noreply.github.com>", "timestamp": "2026-04-21T10:34:28Z", "tree_id": "5c99a6e77acca8373d0beaff11b56c74a70e1eda", "url": ""}], "compare": "", "created": false, "deleted": false, "forced": false, "head_commit": {"author": {"email": "49699333+dependabot[bot]@users.noreply.github.com", "name": "dependabot[bot]", "username": "svlandeg"}, "committer": {"email": "noreply@github.com", "name": "GitHub", "username": "web-flow"}, "distinct": true, "id": "22a86d3f267c26865b239bb9c4c14f232af3baa3", "message": "\u2b06 Bump pydantic-settings from 2.13.1 to 2.14.0 (#1713)\n\nSigned-off-by: dependabot[bot] <support@github.com>\nCo-authored-by: dependabot[bot] <49699333+dependabot[bot]@users.noreply.github.com>", "timestamp": "2026-04-21T10:34:28Z", "tree_id": "5c99a6e77acca8373d0beaff11b56c74a70e1eda", "url": ""}, "pusher": {"email": "49699333+dependabot[bot]@users.noreply.github.com", "name": "svlandeg"}, "ref": "refs/heads/master", "repository": {"allow_forking": true, "archive_url": "https://api.github.com/repos/fastapi/typer/{archive_format}{/ref}", "archived": false, "assignees_url": "https://api.github.com/repos/fastapi/typer/assignees{/user}", "blobs_url": "https://api.github.com/repos/fastapi/typer/git/blobs{/sha}", "branches_url": "https://api.github.com/repos/fastapi/typer/branches{/branch}", "clone_url": "https://github.com/fastapi/typer.git", "collaborators_url": "https://api.github.com/repos/fastapi/typer/collaborators{/collaborator}", "comments_url": "https://api.github.com/repos/fastapi/typer/comments{/number}", "commits_url": "https://api.github.com/repos/fastapi/typer/commits{/sha}", "compare_url": "https://api.github.com/repos/fastapi/typer/compare/{base}...{head}", "contents_url": "https://api.github.com/repos/fastapi/typer/contents/{+path}", "contributors_url": "https://api.github.com/repos/fastapi/typer/contributors", "created_at": 0, "default_branch": "master", "deployments_url": "https://api.github.com/repos/fastapi/typer/deployments", "description": "Typer, build great CLIs. Easy to code. Based on Python type hints.", "disabled": false, "downloads_url": "https://api.github.com/repos/fastapi/typer/downloads", "events_url": "https://api.github.com/repos/fastapi/typer/events", "fork": false, "forks": 0, "forks_count": 0, "forks_url": "https://api.github.com/repos/fastapi/typer/forks", "full_name": "fastapi/typer", "git_commits_url": "https://api.github.com/repos/fastapi/typer/git/commits{/sha}", "git_refs_url": "https://api.github.com/repos/fastapi/typer/git/refs{/sha}", "git_tags_url": "https://api.github.com/repos/fastapi/typer/git/tags{/sha}", "git_url": "git://github.com/fastapi/typer.git", "has_downloads": true, "has_issues": true, "has_pages": true, "has_projects": true, "has_wiki": true, "homepage": null, "hooks_url": "https://api.github.com/repos/fastapi/typer/hooks", "html_url": "https://github.com/fastapi/typer", "id": 229937405, "is_template": false, "issue_comment_url": "https://api.github.com/repos/fastapi/typer/issues/comments{/number}", "issue_events_url": "https://api.github.com/repos/fastapi/typer/issues/events{/number}", "issues_url": "https://api.github.com/repos/fastapi/typer/issues{/number}", "keys_url": "https://api.github.com/repos/fastapi/typer/keys{/key_id}", "labels_url": "https://api.github.com/repos/fastapi/typer/labels{/name}", "language": "", "languages_url": "https://api.github.com/repos/fastapi/typer/languages", "license": null, "master_branch": "master", "merges_url": "https://api.github.com/repos/fastapi/typer/merges", "milestones_url": "https://api.github.com/repos/fastapi/typer/milestones{/number}", "mirror_url": null, "name": "typer", "node_id": "MDEwOlJlcG9zaXRvcnkyMjk5Mzc0MDU=", "notifications_url": "https://api.github.com/repos/fastapi/typer/notifications{?since,all,participating}", "open_issues": 0, "open_issues_count": 0, "owner": {"avatar_url": "https://avatars.githubusercontent.com/u/156354296?v=4", "email": "", "events_url": "https://api.github.com/users/fastapi/events{/privacy}", "followers_url": "https://api.github.com/users/fastapi/followers", "following_url": "https://api.github.com/users/fastapi/following{/other_user}", "gists_url": "https://api.github.com/users/fastapi/gists{/gist_id}", "gravatar_id": "", "html_url": "https://github.com/fastapi", "id": 156354296, "login": "fastapi", "name": "fastapi", "node_id": "O_kgDOCVHG-A", "organizations_url": "https://api.github.com/users/fastapi/orgs", "received_events_url": "https://api.github.com/users/fastapi/received_events", "repos_url": "https://api.github.com/users/fastapi/repos", "site_admin": false, "starred_url": "https://api.github.com/users/fastapi/starred{/owner}{/repo}", "subscriptions_url": "https://api.github.com/users/fastapi/subscriptions", "type": "Organization", "url": "https://api.github.com/users/fastapi"}, "private": false, "pulls_url": "https://api.github.com/repos/fastapi/typer/pulls{/number}", "pushed_at": 0, "releases_url": "https://api.github.com/repos/fastapi/typer/releases{/id}", "size": 0, "ssh_url": "git@github.com:fastapi/typer.git", "stargazers": 0, "stargazers_count": 0, "stargazers_url": "https://api.github.com/repos/fastapi/typer/stargazers", "statuses_url": "https://api.github.com/repos/fastapi/typer/statuses/{sha}", "subscribers_url": "https://api.github.com/repos/fastapi/typer/subscribers", "subscription_url": "https://api.github.com/repos/fastapi/typer/subscription", "svn_url": "https://github.com/fastapi/typer", "tags_url": "https://api.github.com/repos/fastapi/typer/tags", "teams_url": "https://api.github.com/repos/fastapi/typer/teams", "topics": [], "trees_url": "https://api.github.com/repos/fastapi/typer/git/trees{/sha}", "updated_at": "2026-04-21T10:34:28Z", "url": "https://api.github.com/repos/fastapi/typer", "visibility": "public", "watchers": 0, "watchers_count": 0, "web_commit_signoff_required": false}, "sender": {"avatar_url": "https://avatars.githubusercontent.com/u/8796347?v=4", "email": "", "events_url": "https://api.github.com/users/svlandeg/events{/privacy}", "followers_url": "https://api.github.com/users/svlandeg/followers", "following_url": "https://api.github.com/users/svlandeg/following{/other_user}", "gists_url": "https://api.github.com/users/svlandeg/gists{/gist_id}", "gravatar_id": "", "html_url": "https://github.com/svlandeg", "id": 8796347, "login": "svlandeg", "name": "svlandeg", "node_id": "MDQ6VXNlcjg3OTYzNDc=", "organizations_url": "https://api.github.com/users/svlandeg/orgs", "received_events_url": "https://api.github.com/users/svlandeg/received_events", "repos_url": "https://api.github.com/users/svlandeg/repos", "site_admin": false, "starred_url": "https://api.github.com/users/svlandeg/starred{/owner}{/repo}", "subscriptions_url": "https://api.github.com/users/svlandeg/subscriptions", "type": "User", "url": "https://api.github.com/users/svlandeg"}}, "server_url": "https://github.com", "api_url": "https://api.github.com", "graphql_url": "https://api.github.com/graphql", "ref_name": "master", "ref_protected": "false", "ref_type": "branch", "secret_source": "", "event_path": "/home/github/workflow/event.json", "path": "/home/github/workflow/paths.txt", "env": "/home/github/workflow/envs.txt", "workspace": "", "action": "", "action_repository": "", "action_status": "", "action_path": "", "action_ref": ""}' p:')' p:')')" \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=0 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=svlandeg GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=fastapi/typer GITHUB_REPOSITORY_OWNER=fastapi GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=22a86d3f267c26865b239bb9c4c14f232af3baa3 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Test GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 UV_NO_SYNC=true UV_PYTHON=3.14 UV_RESOLUTION=highest "${CURRENT_ENV[@]}" GITHUB_CONTEXT="$(/home/github/72298205321/helpers/eval_expression p:'(' f:toJson p:'(' l:'{"token": "DUMMY", "job": "", "ref": "refs/heads/master", "sha": "22a86d3f267c26865b239bb9c4c14f232af3baa3", "repository": "fastapi/typer", "repository_owner": "fastapi", "repositoryUrl": "git://github.com/fastapi/typer.git", "run_id": "72298205321", "run_number": 24717678590, "retention_days": "0", "run_attempt": "1", "actor": "svlandeg", "triggering_actor": "svlandeg", "workflow": "Test", "head_ref": "", "base_ref": "", "event_name": "push", "event": {"after": "", "base_ref": null, "before": "", "commits": [{"author": {"email": "49699333+dependabot[bot]@users.noreply.github.com", "name": "dependabot[bot]", "username": "svlandeg"}, "committer": {"email": "noreply@github.com", "name": "GitHub", "username": "web-flow"}, "distinct": true, "id": "22a86d3f267c26865b239bb9c4c14f232af3baa3", "message": "\u2b06 Bump pydantic-settings from 2.13.1 to 2.14.0 (#1713)\n\nSigned-off-by: dependabot[bot] <support@github.com>\nCo-authored-by: dependabot[bot] <49699333+dependabot[bot]@users.noreply.github.com>", "timestamp": "2026-04-21T10:34:28Z", "tree_id": "5c99a6e77acca8373d0beaff11b56c74a70e1eda", "url": ""}], "compare": "", "created": false, "deleted": false, "forced": false, "head_commit": {"author": {"email": "49699333+dependabot[bot]@users.noreply.github.com", "name": "dependabot[bot]", "username": "svlandeg"}, "committer": {"email": "noreply@github.com", "name": "GitHub", "username": "web-flow"}, "distinct": true, "id": "22a86d3f267c26865b239bb9c4c14f232af3baa3", "message": "\u2b06 Bump pydantic-settings from 2.13.1 to 2.14.0 (#1713)\n\nSigned-off-by: dependabot[bot] <support@github.com>\nCo-authored-by: dependabot[bot] <49699333+dependabot[bot]@users.noreply.github.com>", "timestamp": "2026-04-21T10:34:28Z", "tree_id": "5c99a6e77acca8373d0beaff11b56c74a70e1eda", "url": ""}, "pusher": {"email": "49699333+dependabot[bot]@users.noreply.github.com", "name": "svlandeg"}, "ref": "refs/heads/master", "repository": {"allow_forking": true, "archive_url": "https://api.github.com/repos/fastapi/typer/{archive_format}{/ref}", "archived": false, "assignees_url": "https://api.github.com/repos/fastapi/typer/assignees{/user}", "blobs_url": "https://api.github.com/repos/fastapi/typer/git/blobs{/sha}", "branches_url": "https://api.github.com/repos/fastapi/typer/branches{/branch}", "clone_url": "https://github.com/fastapi/typer.git", "collaborators_url": "https://api.github.com/repos/fastapi/typer/collaborators{/collaborator}", "comments_url": "https://api.github.com/repos/fastapi/typer/comments{/number}", "commits_url": "https://api.github.com/repos/fastapi/typer/commits{/sha}", "compare_url": "https://api.github.com/repos/fastapi/typer/compare/{base}...{head}", "contents_url": "https://api.github.com/repos/fastapi/typer/contents/{+path}", "contributors_url": "https://api.github.com/repos/fastapi/typer/contributors", "created_at": 0, "default_branch": "master", "deployments_url": "https://api.github.com/repos/fastapi/typer/deployments", "description": "Typer, build great CLIs. Easy to code. Based on Python type hints.", "disabled": false, "downloads_url": "https://api.github.com/repos/fastapi/typer/downloads", "events_url": "https://api.github.com/repos/fastapi/typer/events", "fork": false, "forks": 0, "forks_count": 0, "forks_url": "https://api.github.com/repos/fastapi/typer/forks", "full_name": "fastapi/typer", "git_commits_url": "https://api.github.com/repos/fastapi/typer/git/commits{/sha}", "git_refs_url": "https://api.github.com/repos/fastapi/typer/git/refs{/sha}", "git_tags_url": "https://api.github.com/repos/fastapi/typer/git/tags{/sha}", "git_url": "git://github.com/fastapi/typer.git", "has_downloads": true, "has_issues": true, "has_pages": true, "has_projects": true, "has_wiki": true, "homepage": null, "hooks_url": "https://api.github.com/repos/fastapi/typer/hooks", "html_url": "https://github.com/fastapi/typer", "id": 229937405, "is_template": false, "issue_comment_url": "https://api.github.com/repos/fastapi/typer/issues/comments{/number}", "issue_events_url": "https://api.github.com/repos/fastapi/typer/issues/events{/number}", "issues_url": "https://api.github.com/repos/fastapi/typer/issues{/number}", "keys_url": "https://api.github.com/repos/fastapi/typer/keys{/key_id}", "labels_url": "https://api.github.com/repos/fastapi/typer/labels{/name}", "language": "", "languages_url": "https://api.github.com/repos/fastapi/typer/languages", "license": null, "master_branch": "master", "merges_url": "https://api.github.com/repos/fastapi/typer/merges", "milestones_url": "https://api.github.com/repos/fastapi/typer/milestones{/number}", "mirror_url": null, "name": "typer", "node_id": "MDEwOlJlcG9zaXRvcnkyMjk5Mzc0MDU=", "notifications_url": "https://api.github.com/repos/fastapi/typer/notifications{?since,all,participating}", "open_issues": 0, "open_issues_count": 0, "owner": {"avatar_url": "https://avatars.githubusercontent.com/u/156354296?v=4", "email": "", "events_url": "https://api.github.com/users/fastapi/events{/privacy}", "followers_url": "https://api.github.com/users/fastapi/followers", "following_url": "https://api.github.com/users/fastapi/following{/other_user}", "gists_url": "https://api.github.com/users/fastapi/gists{/gist_id}", "gravatar_id": "", "html_url": "https://github.com/fastapi", "id": 156354296, "login": "fastapi", "name": "fastapi", "node_id": "O_kgDOCVHG-A", "organizations_url": "https://api.github.com/users/fastapi/orgs", "received_events_url": "https://api.github.com/users/fastapi/received_events", "repos_url": "https://api.github.com/users/fastapi/repos", "site_admin": false, "starred_url": "https://api.github.com/users/fastapi/starred{/owner}{/repo}", "subscriptions_url": "https://api.github.com/users/fastapi/subscriptions", "type": "Organization", "url": "https://api.github.com/users/fastapi"}, "private": false, "pulls_url": "https://api.github.com/repos/fastapi/typer/pulls{/number}", "pushed_at": 0, "releases_url": "https://api.github.com/repos/fastapi/typer/releases{/id}", "size": 0, "ssh_url": "git@github.com:fastapi/typer.git", "stargazers": 0, "stargazers_count": 0, "stargazers_url": "https://api.github.com/repos/fastapi/typer/stargazers", "statuses_url": "https://api.github.com/repos/fastapi/typer/statuses/{sha}", "subscribers_url": "https://api.github.com/repos/fastapi/typer/subscribers", "subscription_url": "https://api.github.com/repos/fastapi/typer/subscription", "svn_url": "https://github.com/fastapi/typer", "tags_url": "https://api.github.com/repos/fastapi/typer/tags", "teams_url": "https://api.github.com/repos/fastapi/typer/teams", "topics": [], "trees_url": "https://api.github.com/repos/fastapi/typer/git/trees{/sha}", "updated_at": "2026-04-21T10:34:28Z", "url": "https://api.github.com/repos/fastapi/typer", "visibility": "public", "watchers": 0, "watchers_count": 0, "web_commit_signoff_required": false}, "sender": {"avatar_url": "https://avatars.githubusercontent.com/u/8796347?v=4", "email": "", "events_url": "https://api.github.com/users/svlandeg/events{/privacy}", "followers_url": "https://api.github.com/users/svlandeg/followers", "following_url": "https://api.github.com/users/svlandeg/following{/other_user}", "gists_url": "https://api.github.com/users/svlandeg/gists{/gist_id}", "gravatar_id": "", "html_url": "https://github.com/svlandeg", "id": 8796347, "login": "svlandeg", "name": "svlandeg", "node_id": "MDQ6VXNlcjg3OTYzNDc=", "organizations_url": "https://api.github.com/users/svlandeg/orgs", "received_events_url": "https://api.github.com/users/svlandeg/received_events", "repos_url": "https://api.github.com/users/svlandeg/repos", "site_admin": false, "starred_url": "https://api.github.com/users/svlandeg/starred{/owner}{/repo}", "subscriptions_url": "https://api.github.com/users/svlandeg/subscriptions", "type": "User", "url": "https://api.github.com/users/svlandeg"}}, "server_url": "https://github.com", "api_url": "https://api.github.com", "graphql_url": "https://api.github.com/graphql", "ref_name": "master", "ref_protected": "false", "ref_type": "branch", "secret_source": "", "event_path": "/home/github/workflow/event.json", "path": "/home/github/workflow/paths.txt", "env": "/home/github/workflow/envs.txt", "workspace": "", "action": "", "action_repository": "", "action_status": "", "action_path": "", "action_ref": ""}' p:')' p:')')" \
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=2 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=actions/setup-python GITHUB_ACTIONS=true GITHUB_ACTOR=svlandeg GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=fastapi/typer GITHUB_REPOSITORY_OWNER=fastapi GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=22a86d3f267c26865b239bb9c4c14f232af3baa3 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Test GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 UV_NO_SYNC=true GITHUB_ACTION_PATH=/home/github/72298205321/actions/actions-setup-python@a309ff8b426b58ec0e2a45f0f869d46889d02405 UV_PYTHON=3.14 UV_RESOLUTION=highest "${CURRENT_ENV[@]}" INPUT_PYTHON-VERSION=3.14 INPUT_TOKEN= INPUT_CHECK-LATEST=false INPUT_UPDATE-ENVIRONMENT=true INPUT_ALLOW-PRERELEASES=false INPUT_FREETHREADED=false \
echo $(test "$_GITHUB_JOB_STATUS" = "success" && echo true || echo false))
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=2 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=actions/setup-python GITHUB_ACTIONS=true GITHUB_ACTOR=svlandeg GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=fastapi/typer GITHUB_REPOSITORY_OWNER=fastapi GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=22a86d3f267c26865b239bb9c4c14f232af3baa3 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Test GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 UV_NO_SYNC=true GITHUB_ACTION_PATH=/home/github/72298205321/actions/actions-setup-python@a309ff8b426b58ec0e2a45f0f869d46889d02405 UV_PYTHON=3.14 UV_RESOLUTION=highest "${CURRENT_ENV[@]}" INPUT_PYTHON-VERSION=3.14 INPUT_TOKEN= INPUT_CHECK-LATEST=false INPUT_UPDATE-ENVIRONMENT=true INPUT_ALLOW-PRERELEASES=false INPUT_FREETHREADED=false \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run actions/setup-python@a309ff8b426b58ec0e2a45f0f869d46889d02405
echo "##[endgroup]"
echo node /home/github/72298205321/actions/actions-setup-python@a309ff8b426b58ec0e2a45f0f869d46889d02405/dist/setup/index.js > /home/github/72298205321/steps/bugswarm_cmd.sh
chmod u+x /home/github/72298205321/steps/bugswarm_cmd.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=2 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=actions/setup-python GITHUB_ACTIONS=true GITHUB_ACTOR=svlandeg GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=fastapi/typer GITHUB_REPOSITORY_OWNER=fastapi GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=22a86d3f267c26865b239bb9c4c14f232af3baa3 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Test GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 UV_NO_SYNC=true GITHUB_ACTION_PATH=/home/github/72298205321/actions/actions-setup-python@a309ff8b426b58ec0e2a45f0f869d46889d02405 UV_PYTHON=3.14 UV_RESOLUTION=highest "${CURRENT_ENV[@]}" INPUT_PYTHON-VERSION=3.14 INPUT_TOKEN= INPUT_CHECK-LATEST=false INPUT_UPDATE-ENVIRONMENT=true INPUT_ALLOW-PRERELEASES=false INPUT_FREETHREADED=false \
bash -e /home/github/72298205321/steps/bugswarm_cmd.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=2 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=actions/setup-python GITHUB_ACTIONS=true GITHUB_ACTOR=svlandeg GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=fastapi/typer GITHUB_REPOSITORY_OWNER=fastapi GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=22a86d3f267c26865b239bb9c4c14f232af3baa3 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Test GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 UV_NO_SYNC=true GITHUB_ACTION_PATH=/home/github/72298205321/actions/actions-setup-python@a309ff8b426b58ec0e2a45f0f869d46889d02405 UV_PYTHON=3.14 UV_RESOLUTION=highest "${CURRENT_ENV[@]}" INPUT_PYTHON-VERSION=3.14 INPUT_TOKEN= INPUT_CHECK-LATEST=false INPUT_UPDATE-ENVIRONMENT=true INPUT_ALLOW-PRERELEASES=false INPUT_FREETHREADED=false \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=2 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=actions/setup-python GITHUB_ACTIONS=true GITHUB_ACTOR=svlandeg GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=fastapi/typer GITHUB_REPOSITORY_OWNER=fastapi GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=22a86d3f267c26865b239bb9c4c14f232af3baa3 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Test GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 UV_NO_SYNC=true GITHUB_ACTION_PATH=/home/github/72298205321/actions/actions-setup-python@a309ff8b426b58ec0e2a45f0f869d46889d02405 UV_PYTHON=3.14 UV_RESOLUTION=highest "${CURRENT_ENV[@]}" INPUT_PYTHON-VERSION=3.14 INPUT_TOKEN= INPUT_CHECK-LATEST=false INPUT_UPDATE-ENVIRONMENT=true INPUT_ALLOW-PRERELEASES=false INPUT_FREETHREADED=false \
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=3 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=astral-sh/setup-uv GITHUB_ACTIONS=true GITHUB_ACTOR=svlandeg GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=fastapi/typer GITHUB_REPOSITORY_OWNER=fastapi GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=22a86d3f267c26865b239bb9c4c14f232af3baa3 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Test GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 UV_NO_SYNC=true GITHUB_ACTION_PATH=/home/github/72298205321/actions/astral-sh-setup-uv@08807647e7069bb48b6ef5acd8ec9567f424441b UV_PYTHON=3.14 UV_RESOLUTION=highest "${CURRENT_ENV[@]}" INPUT_ENABLE-CACHE=true INPUT_CACHE-DEPENDENCY-GLOB='pyproject.toml
uv.lock
' INPUT_VERSION= INPUT_VERSION-FILE= INPUT_ACTIVATE-ENVIRONMENT=false INPUT_VENV-PATH= INPUT_NO-PROJECT=false INPUT_WORKING-DIRECTORY=${GITHUB_WORKSPACE} INPUT_GITHUB-TOKEN=DUMMY INPUT_RESTORE-CACHE=true INPUT_SAVE-CACHE=true INPUT_CACHE-LOCAL-PATH= INPUT_PRUNE-CACHE=true INPUT_CACHE-PYTHON=false INPUT_IGNORE-NOTHING-TO-CACHE=false INPUT_IGNORE-EMPTY-WORKDIR=false INPUT_ADD-PROBLEM-MATCHERS=true INPUT_RESOLUTION-STRATEGY=highest \
echo $(test "$_GITHUB_JOB_STATUS" = "success" && echo true || echo false))
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=3 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=astral-sh/setup-uv GITHUB_ACTIONS=true GITHUB_ACTOR=svlandeg GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=fastapi/typer GITHUB_REPOSITORY_OWNER=fastapi GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=22a86d3f267c26865b239bb9c4c14f232af3baa3 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Test GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 UV_NO_SYNC=true GITHUB_ACTION_PATH=/home/github/72298205321/actions/astral-sh-setup-uv@08807647e7069bb48b6ef5acd8ec9567f424441b UV_PYTHON=3.14 UV_RESOLUTION=highest "${CURRENT_ENV[@]}" INPUT_ENABLE-CACHE=true INPUT_CACHE-DEPENDENCY-GLOB='pyproject.toml
uv.lock
' INPUT_VERSION= INPUT_VERSION-FILE= INPUT_ACTIVATE-ENVIRONMENT=false INPUT_VENV-PATH= INPUT_NO-PROJECT=false INPUT_WORKING-DIRECTORY=${GITHUB_WORKSPACE} INPUT_GITHUB-TOKEN=DUMMY INPUT_RESTORE-CACHE=true INPUT_SAVE-CACHE=true INPUT_CACHE-LOCAL-PATH= INPUT_PRUNE-CACHE=true INPUT_CACHE-PYTHON=false INPUT_IGNORE-NOTHING-TO-CACHE=false INPUT_IGNORE-EMPTY-WORKDIR=false INPUT_ADD-PROBLEM-MATCHERS=true INPUT_RESOLUTION-STRATEGY=highest \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run astral-sh/setup-uv@08807647e7069bb48b6ef5acd8ec9567f424441b
echo "##[endgroup]"
echo node /home/github/72298205321/actions/astral-sh-setup-uv@08807647e7069bb48b6ef5acd8ec9567f424441b/dist/setup/index.cjs > /home/github/72298205321/steps/bugswarm_cmd.sh
chmod u+x /home/github/72298205321/steps/bugswarm_cmd.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=3 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=astral-sh/setup-uv GITHUB_ACTIONS=true GITHUB_ACTOR=svlandeg GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=fastapi/typer GITHUB_REPOSITORY_OWNER=fastapi GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=22a86d3f267c26865b239bb9c4c14f232af3baa3 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Test GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 UV_NO_SYNC=true GITHUB_ACTION_PATH=/home/github/72298205321/actions/astral-sh-setup-uv@08807647e7069bb48b6ef5acd8ec9567f424441b UV_PYTHON=3.14 UV_RESOLUTION=highest "${CURRENT_ENV[@]}" INPUT_ENABLE-CACHE=true INPUT_CACHE-DEPENDENCY-GLOB='pyproject.toml
uv.lock
' INPUT_VERSION= INPUT_VERSION-FILE= INPUT_ACTIVATE-ENVIRONMENT=false INPUT_VENV-PATH= INPUT_NO-PROJECT=false INPUT_WORKING-DIRECTORY=${GITHUB_WORKSPACE} INPUT_GITHUB-TOKEN=DUMMY INPUT_RESTORE-CACHE=true INPUT_SAVE-CACHE=true INPUT_CACHE-LOCAL-PATH= INPUT_PRUNE-CACHE=true INPUT_CACHE-PYTHON=false INPUT_IGNORE-NOTHING-TO-CACHE=false INPUT_IGNORE-EMPTY-WORKDIR=false INPUT_ADD-PROBLEM-MATCHERS=true INPUT_RESOLUTION-STRATEGY=highest \
bash -e /home/github/72298205321/steps/bugswarm_cmd.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=3 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=astral-sh/setup-uv GITHUB_ACTIONS=true GITHUB_ACTOR=svlandeg GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=fastapi/typer GITHUB_REPOSITORY_OWNER=fastapi GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=22a86d3f267c26865b239bb9c4c14f232af3baa3 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Test GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 UV_NO_SYNC=true GITHUB_ACTION_PATH=/home/github/72298205321/actions/astral-sh-setup-uv@08807647e7069bb48b6ef5acd8ec9567f424441b UV_PYTHON=3.14 UV_RESOLUTION=highest "${CURRENT_ENV[@]}" INPUT_ENABLE-CACHE=true INPUT_CACHE-DEPENDENCY-GLOB='pyproject.toml
uv.lock
' INPUT_VERSION= INPUT_VERSION-FILE= INPUT_ACTIVATE-ENVIRONMENT=false INPUT_VENV-PATH= INPUT_NO-PROJECT=false INPUT_WORKING-DIRECTORY=${GITHUB_WORKSPACE} INPUT_GITHUB-TOKEN=DUMMY INPUT_RESTORE-CACHE=true INPUT_SAVE-CACHE=true INPUT_CACHE-LOCAL-PATH= INPUT_PRUNE-CACHE=true INPUT_CACHE-PYTHON=false INPUT_IGNORE-NOTHING-TO-CACHE=false INPUT_IGNORE-EMPTY-WORKDIR=false INPUT_ADD-PROBLEM-MATCHERS=true INPUT_RESOLUTION-STRATEGY=highest \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=3 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=astral-sh/setup-uv GITHUB_ACTIONS=true GITHUB_ACTOR=svlandeg GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=fastapi/typer GITHUB_REPOSITORY_OWNER=fastapi GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=22a86d3f267c26865b239bb9c4c14f232af3baa3 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Test GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 UV_NO_SYNC=true GITHUB_ACTION_PATH=/home/github/72298205321/actions/astral-sh-setup-uv@08807647e7069bb48b6ef5acd8ec9567f424441b UV_PYTHON=3.14 UV_RESOLUTION=highest "${CURRENT_ENV[@]}" INPUT_ENABLE-CACHE=true INPUT_CACHE-DEPENDENCY-GLOB='pyproject.toml
uv.lock
' INPUT_VERSION= INPUT_VERSION-FILE= INPUT_ACTIVATE-ENVIRONMENT=false INPUT_VENV-PATH= INPUT_NO-PROJECT=false INPUT_WORKING-DIRECTORY=${GITHUB_WORKSPACE} INPUT_GITHUB-TOKEN=DUMMY INPUT_RESTORE-CACHE=true INPUT_SAVE-CACHE=true INPUT_CACHE-LOCAL-PATH= INPUT_PRUNE-CACHE=true INPUT_CACHE-PYTHON=false INPUT_IGNORE-NOTHING-TO-CACHE=false INPUT_IGNORE-EMPTY-WORKDIR=false INPUT_ADD-PROBLEM-MATCHERS=true INPUT_RESOLUTION-STRATEGY=highest \
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=4 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=svlandeg GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=fastapi/typer GITHUB_REPOSITORY_OWNER=fastapi GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=22a86d3f267c26865b239bb9c4c14f232af3baa3 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Test GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 UV_NO_SYNC=true UV_PYTHON=3.14 UV_RESOLUTION=highest "${CURRENT_ENV[@]}" \
echo $(test "$_GITHUB_JOB_STATUS" = "success" && echo true || echo false))
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=4 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=svlandeg GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=fastapi/typer GITHUB_REPOSITORY_OWNER=fastapi GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=22a86d3f267c26865b239bb9c4c14f232af3baa3 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Test GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 UV_NO_SYNC=true UV_PYTHON=3.14 UV_RESOLUTION=highest "${CURRENT_ENV[@]}" \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run 'uv sync --no-dev --group tests'
echo "##[endgroup]"
echo 'uv sync --no-dev --group tests' > /home/github/72298205321/steps/bugswarm_4.sh
chmod u+x /home/github/72298205321/steps/bugswarm_4.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=4 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=svlandeg GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=fastapi/typer GITHUB_REPOSITORY_OWNER=fastapi GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=22a86d3f267c26865b239bb9c4c14f232af3baa3 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Test GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 UV_NO_SYNC=true UV_PYTHON=3.14 UV_RESOLUTION=highest "${CURRENT_ENV[@]}" \
bash -e /home/github/72298205321/steps/bugswarm_4.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=4 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=svlandeg GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=fastapi/typer GITHUB_REPOSITORY_OWNER=fastapi GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=22a86d3f267c26865b239bb9c4c14f232af3baa3 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Test GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 UV_NO_SYNC=true UV_PYTHON=3.14 UV_RESOLUTION=highest "${CURRENT_ENV[@]}" \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=4 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=svlandeg GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=fastapi/typer GITHUB_REPOSITORY_OWNER=fastapi GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=22a86d3f267c26865b239bb9c4c14f232af3baa3 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Test GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 UV_NO_SYNC=true UV_PYTHON=3.14 UV_RESOLUTION=highest "${CURRENT_ENV[@]}" \
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=5 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=svlandeg GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=fastapi/typer GITHUB_REPOSITORY_OWNER=fastapi GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=22a86d3f267c26865b239bb9c4c14f232af3baa3 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Test GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 UV_NO_SYNC=true UV_PYTHON=3.14 UV_RESOLUTION=highest "${CURRENT_ENV[@]}" \
echo $(test "$_GITHUB_JOB_STATUS" = "success" && echo true || echo false))
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=5 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=svlandeg GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=fastapi/typer GITHUB_REPOSITORY_OWNER=fastapi GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=22a86d3f267c26865b239bb9c4c14f232af3baa3 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Test GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 UV_NO_SYNC=true UV_PYTHON=3.14 UV_RESOLUTION=highest "${CURRENT_ENV[@]}" \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run 'mkdir coverage'
echo "##[endgroup]"
echo 'mkdir coverage' > /home/github/72298205321/steps/bugswarm_5.sh
chmod u+x /home/github/72298205321/steps/bugswarm_5.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=5 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=svlandeg GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=fastapi/typer GITHUB_REPOSITORY_OWNER=fastapi GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=22a86d3f267c26865b239bb9c4c14f232af3baa3 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Test GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 UV_NO_SYNC=true UV_PYTHON=3.14 UV_RESOLUTION=highest "${CURRENT_ENV[@]}" \
bash -e /home/github/72298205321/steps/bugswarm_5.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=5 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=svlandeg GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=fastapi/typer GITHUB_REPOSITORY_OWNER=fastapi GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=22a86d3f267c26865b239bb9c4c14f232af3baa3 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Test GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 UV_NO_SYNC=true UV_PYTHON=3.14 UV_RESOLUTION=highest "${CURRENT_ENV[@]}" \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=5 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=svlandeg GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=fastapi/typer GITHUB_REPOSITORY_OWNER=fastapi GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=22a86d3f267c26865b239bb9c4c14f232af3baa3 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Test GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 UV_NO_SYNC=true UV_PYTHON=3.14 UV_RESOLUTION=highest "${CURRENT_ENV[@]}" \
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=6 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=svlandeg GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=fastapi/typer GITHUB_REPOSITORY_OWNER=fastapi GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=22a86d3f267c26865b239bb9c4c14f232af3baa3 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Test GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 UV_NO_SYNC=true UV_PYTHON=3.14 UV_RESOLUTION=highest "${CURRENT_ENV[@]}" \
echo $(test "$_GITHUB_JOB_STATUS" = "success" && echo true || echo false))
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=6 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=svlandeg GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=fastapi/typer GITHUB_REPOSITORY_OWNER=fastapi GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=22a86d3f267c26865b239bb9c4c14f232af3baa3 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Test GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 UV_NO_SYNC=true UV_PYTHON=3.14 UV_RESOLUTION=highest "${CURRENT_ENV[@]}" \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run 'uv run bash scripts/test-files.sh'
echo "##[endgroup]"
echo 'uv run bash scripts/test-files.sh' > /home/github/72298205321/steps/bugswarm_6.sh
chmod u+x /home/github/72298205321/steps/bugswarm_6.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=6 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=svlandeg GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=fastapi/typer GITHUB_REPOSITORY_OWNER=fastapi GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=22a86d3f267c26865b239bb9c4c14f232af3baa3 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Test GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 UV_NO_SYNC=true UV_PYTHON=3.14 UV_RESOLUTION=highest "${CURRENT_ENV[@]}" \
bash -e /home/github/72298205321/steps/bugswarm_6.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=6 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=svlandeg GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=fastapi/typer GITHUB_REPOSITORY_OWNER=fastapi GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=22a86d3f267c26865b239bb9c4c14f232af3baa3 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Test GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 UV_NO_SYNC=true UV_PYTHON=3.14 UV_RESOLUTION=highest "${CURRENT_ENV[@]}" \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=6 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=svlandeg GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=fastapi/typer GITHUB_REPOSITORY_OWNER=fastapi GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=22a86d3f267c26865b239bb9c4c14f232af3baa3 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Test GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 UV_NO_SYNC=true UV_PYTHON=3.14 UV_RESOLUTION=highest "${CURRENT_ENV[@]}" \
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=7 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=svlandeg GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=fastapi/typer GITHUB_REPOSITORY_OWNER=fastapi GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=22a86d3f267c26865b239bb9c4c14f232af3baa3 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Test GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 UV_NO_SYNC=true UV_PYTHON=3.14 UV_RESOLUTION=highest "${CURRENT_ENV[@]}" COVERAGE_FILE=coverage/.coverage.Linux-py3.14 CONTEXT=Linux-py3.14 \
echo $(test "$_GITHUB_JOB_STATUS" = "success" && echo true || echo false))
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=7 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=svlandeg GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=fastapi/typer GITHUB_REPOSITORY_OWNER=fastapi GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=22a86d3f267c26865b239bb9c4c14f232af3baa3 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Test GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 UV_NO_SYNC=true UV_PYTHON=3.14 UV_RESOLUTION=highest "${CURRENT_ENV[@]}" COVERAGE_FILE=coverage/.coverage.Linux-py3.14 CONTEXT=Linux-py3.14 \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run 'uv run bash scripts/test.sh'
echo "##[endgroup]"
echo 'uv run bash scripts/test.sh' > /home/github/72298205321/steps/bugswarm_7.sh
chmod u+x /home/github/72298205321/steps/bugswarm_7.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=7 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=svlandeg GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=fastapi/typer GITHUB_REPOSITORY_OWNER=fastapi GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=22a86d3f267c26865b239bb9c4c14f232af3baa3 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Test GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 UV_NO_SYNC=true UV_PYTHON=3.14 UV_RESOLUTION=highest "${CURRENT_ENV[@]}" COVERAGE_FILE=coverage/.coverage.Linux-py3.14 CONTEXT=Linux-py3.14 \
bash -e /home/github/72298205321/steps/bugswarm_7.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=7 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=svlandeg GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=fastapi/typer GITHUB_REPOSITORY_OWNER=fastapi GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=22a86d3f267c26865b239bb9c4c14f232af3baa3 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Test GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 UV_NO_SYNC=true UV_PYTHON=3.14 UV_RESOLUTION=highest "${CURRENT_ENV[@]}" COVERAGE_FILE=coverage/.coverage.Linux-py3.14 CONTEXT=Linux-py3.14 \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=7 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=svlandeg GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF='' GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/master GITHUB_REF_NAME=master GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=fastapi/typer GITHUB_REPOSITORY_OWNER=fastapi GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=22a86d3f267c26865b239bb9c4c14f232af3baa3 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Test GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 UV_NO_SYNC=true UV_PYTHON=3.14 UV_RESOLUTION=highest "${CURRENT_ENV[@]}" COVERAGE_FILE=coverage/.coverage.Linux-py3.14 CONTEXT=Linux-py3.14 \
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
   bash -e $ACTIONS_RUNNER_HOOK_JOB_COMPLETED 72298205321 passed
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
