#!/usr/bin/env bash
export GITHUB_WORKSPACE=/home/github/build/fastapi/typer

if [[ ! -z "$ACTIONS_RUNNER_HOOK_JOB_STARTED" ]]; then
   echo "A job started hook has been configured by the self-hosted runner administrator"
   echo "##[group]Run '$ACTIONS_RUNNER_HOOK_JOB_STARTED'"
   echo "##[endgroup]"
   bash -e $ACTIONS_RUNNER_HOOK_JOB_STARTED 71552794390 failed
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

cp /home/github/71552794390/event.json /home/github/workflow/event.json
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=0 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=YuriiMotov GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=dont-truncate-traceback-lines GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/dont-truncate-traceback-lines GITHUB_REF_NAME=dont-truncate-traceback-lines GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=fastapi/typer GITHUB_REPOSITORY_OWNER=fastapi GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=c6ecd8c3080f2f68a1195676b0db983ee13b22a7 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Test GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 UV_NO_SYNC=true UV_PYTHON=3.10 UV_RESOLUTION=lowest-direct "${CURRENT_ENV[@]}" GITHUB_CONTEXT="$(/home/github/71552794390/helpers/eval_expression p:'(' f:toJson p:'(' l:'{"token": "DUMMY", "job": "", "ref": "refs/heads/dont-truncate-traceback-lines", "sha": "c6ecd8c3080f2f68a1195676b0db983ee13b22a7", "repository": "fastapi/typer", "repository_owner": "fastapi", "repositoryUrl": "git://github.com/fastapi/typer.git", "run_id": "71552794390", "run_number": 24483384485, "retention_days": "0", "run_attempt": "1", "actor": "YuriiMotov", "triggering_actor": "YuriiMotov", "workflow": "Test", "head_ref": "dont-truncate-traceback-lines", "base_ref": "", "event_name": "push", "event": {"after": "", "base_ref": null, "before": "", "commits": [{"author": {"email": "yurii.motov.monte@gmail.com", "name": "Yurii Motov", "username": "YuriiMotov"}, "committer": {"email": "noreply@github.com", "name": "GitHub", "username": "web-flow"}, "distinct": true, "id": "c6ecd8c3080f2f68a1195676b0db983ee13b22a7", "message": "Add `pretty_exceptions_word_wrap` parameter", "timestamp": "2026-04-15T22:51:20Z", "tree_id": "c58037ac1091c9c9522d745a0e7b0830edb0e372", "url": ""}], "compare": "", "created": false, "deleted": false, "forced": false, "head_commit": {"author": {"email": "yurii.motov.monte@gmail.com", "name": "Yurii Motov", "username": "YuriiMotov"}, "committer": {"email": "noreply@github.com", "name": "GitHub", "username": "web-flow"}, "distinct": true, "id": "c6ecd8c3080f2f68a1195676b0db983ee13b22a7", "message": "Add `pretty_exceptions_word_wrap` parameter", "timestamp": "2026-04-15T22:51:20Z", "tree_id": "c58037ac1091c9c9522d745a0e7b0830edb0e372", "url": ""}, "pusher": {"email": "yurii.motov.monte@gmail.com", "name": "YuriiMotov"}, "ref": "refs/heads/dont-truncate-traceback-lines", "repository": {"allow_forking": true, "archive_url": "https://api.github.com/repos/fastapi/typer/{archive_format}{/ref}", "archived": false, "assignees_url": "https://api.github.com/repos/fastapi/typer/assignees{/user}", "blobs_url": "https://api.github.com/repos/fastapi/typer/git/blobs{/sha}", "branches_url": "https://api.github.com/repos/fastapi/typer/branches{/branch}", "clone_url": "https://github.com/fastapi/typer.git", "collaborators_url": "https://api.github.com/repos/fastapi/typer/collaborators{/collaborator}", "comments_url": "https://api.github.com/repos/fastapi/typer/comments{/number}", "commits_url": "https://api.github.com/repos/fastapi/typer/commits{/sha}", "compare_url": "https://api.github.com/repos/fastapi/typer/compare/{base}...{head}", "contents_url": "https://api.github.com/repos/fastapi/typer/contents/{+path}", "contributors_url": "https://api.github.com/repos/fastapi/typer/contributors", "created_at": 0, "default_branch": "master", "deployments_url": "https://api.github.com/repos/fastapi/typer/deployments", "description": "Typer, build great CLIs. Easy to code. Based on Python type hints.", "disabled": false, "downloads_url": "https://api.github.com/repos/fastapi/typer/downloads", "events_url": "https://api.github.com/repos/fastapi/typer/events", "fork": false, "forks": 0, "forks_count": 0, "forks_url": "https://api.github.com/repos/fastapi/typer/forks", "full_name": "fastapi/typer", "git_commits_url": "https://api.github.com/repos/fastapi/typer/git/commits{/sha}", "git_refs_url": "https://api.github.com/repos/fastapi/typer/git/refs{/sha}", "git_tags_url": "https://api.github.com/repos/fastapi/typer/git/tags{/sha}", "git_url": "git://github.com/fastapi/typer.git", "has_downloads": true, "has_issues": true, "has_pages": true, "has_projects": true, "has_wiki": true, "homepage": null, "hooks_url": "https://api.github.com/repos/fastapi/typer/hooks", "html_url": "https://github.com/fastapi/typer", "id": 229937405, "is_template": false, "issue_comment_url": "https://api.github.com/repos/fastapi/typer/issues/comments{/number}", "issue_events_url": "https://api.github.com/repos/fastapi/typer/issues/events{/number}", "issues_url": "https://api.github.com/repos/fastapi/typer/issues{/number}", "keys_url": "https://api.github.com/repos/fastapi/typer/keys{/key_id}", "labels_url": "https://api.github.com/repos/fastapi/typer/labels{/name}", "language": "", "languages_url": "https://api.github.com/repos/fastapi/typer/languages", "license": null, "master_branch": "master", "merges_url": "https://api.github.com/repos/fastapi/typer/merges", "milestones_url": "https://api.github.com/repos/fastapi/typer/milestones{/number}", "mirror_url": null, "name": "typer", "node_id": "MDEwOlJlcG9zaXRvcnkyMjk5Mzc0MDU=", "notifications_url": "https://api.github.com/repos/fastapi/typer/notifications{?since,all,participating}", "open_issues": 0, "open_issues_count": 0, "owner": {"avatar_url": "https://avatars.githubusercontent.com/u/156354296?v=4", "email": "", "events_url": "https://api.github.com/users/fastapi/events{/privacy}", "followers_url": "https://api.github.com/users/fastapi/followers", "following_url": "https://api.github.com/users/fastapi/following{/other_user}", "gists_url": "https://api.github.com/users/fastapi/gists{/gist_id}", "gravatar_id": "", "html_url": "https://github.com/fastapi", "id": 156354296, "login": "fastapi", "name": "fastapi", "node_id": "O_kgDOCVHG-A", "organizations_url": "https://api.github.com/users/fastapi/orgs", "received_events_url": "https://api.github.com/users/fastapi/received_events", "repos_url": "https://api.github.com/users/fastapi/repos", "site_admin": false, "starred_url": "https://api.github.com/users/fastapi/starred{/owner}{/repo}", "subscriptions_url": "https://api.github.com/users/fastapi/subscriptions", "type": "Organization", "url": "https://api.github.com/users/fastapi"}, "private": false, "pulls_url": "https://api.github.com/repos/fastapi/typer/pulls{/number}", "pushed_at": 0, "releases_url": "https://api.github.com/repos/fastapi/typer/releases{/id}", "size": 0, "ssh_url": "git@github.com:fastapi/typer.git", "stargazers": 0, "stargazers_count": 0, "stargazers_url": "https://api.github.com/repos/fastapi/typer/stargazers", "statuses_url": "https://api.github.com/repos/fastapi/typer/statuses/{sha}", "subscribers_url": "https://api.github.com/repos/fastapi/typer/subscribers", "subscription_url": "https://api.github.com/repos/fastapi/typer/subscription", "svn_url": "https://github.com/fastapi/typer", "tags_url": "https://api.github.com/repos/fastapi/typer/tags", "teams_url": "https://api.github.com/repos/fastapi/typer/teams", "topics": [], "trees_url": "https://api.github.com/repos/fastapi/typer/git/trees{/sha}", "updated_at": "2026-04-15T22:51:20Z", "url": "https://api.github.com/repos/fastapi/typer", "visibility": "public", "watchers": 0, "watchers_count": 0, "web_commit_signoff_required": false}, "sender": {"avatar_url": "https://avatars.githubusercontent.com/u/109919500?v=4", "email": "", "events_url": "https://api.github.com/users/YuriiMotov/events{/privacy}", "followers_url": "https://api.github.com/users/YuriiMotov/followers", "following_url": "https://api.github.com/users/YuriiMotov/following{/other_user}", "gists_url": "https://api.github.com/users/YuriiMotov/gists{/gist_id}", "gravatar_id": "", "html_url": "https://github.com/YuriiMotov", "id": 109919500, "login": "YuriiMotov", "name": "YuriiMotov", "node_id": "U_kgDOBo09DA", "organizations_url": "https://api.github.com/users/YuriiMotov/orgs", "received_events_url": "https://api.github.com/users/YuriiMotov/received_events", "repos_url": "https://api.github.com/users/YuriiMotov/repos", "site_admin": false, "starred_url": "https://api.github.com/users/YuriiMotov/starred{/owner}{/repo}", "subscriptions_url": "https://api.github.com/users/YuriiMotov/subscriptions", "type": "User", "url": "https://api.github.com/users/YuriiMotov"}}, "server_url": "https://github.com", "api_url": "https://api.github.com", "graphql_url": "https://api.github.com/graphql", "ref_name": "dont-truncate-traceback-lines", "ref_protected": "false", "ref_type": "branch", "secret_source": "", "event_path": "/home/github/workflow/event.json", "path": "/home/github/workflow/paths.txt", "env": "/home/github/workflow/envs.txt", "workspace": "", "action": "", "action_repository": "", "action_status": "", "action_path": "", "action_ref": ""}' p:')' p:')')" \
echo $(test "$_GITHUB_JOB_STATUS" = "success" && echo true || echo false))
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=0 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=YuriiMotov GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=dont-truncate-traceback-lines GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/dont-truncate-traceback-lines GITHUB_REF_NAME=dont-truncate-traceback-lines GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=fastapi/typer GITHUB_REPOSITORY_OWNER=fastapi GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=c6ecd8c3080f2f68a1195676b0db983ee13b22a7 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Test GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 UV_NO_SYNC=true UV_PYTHON=3.10 UV_RESOLUTION=lowest-direct "${CURRENT_ENV[@]}" GITHUB_CONTEXT="$(/home/github/71552794390/helpers/eval_expression p:'(' f:toJson p:'(' l:'{"token": "DUMMY", "job": "", "ref": "refs/heads/dont-truncate-traceback-lines", "sha": "c6ecd8c3080f2f68a1195676b0db983ee13b22a7", "repository": "fastapi/typer", "repository_owner": "fastapi", "repositoryUrl": "git://github.com/fastapi/typer.git", "run_id": "71552794390", "run_number": 24483384485, "retention_days": "0", "run_attempt": "1", "actor": "YuriiMotov", "triggering_actor": "YuriiMotov", "workflow": "Test", "head_ref": "dont-truncate-traceback-lines", "base_ref": "", "event_name": "push", "event": {"after": "", "base_ref": null, "before": "", "commits": [{"author": {"email": "yurii.motov.monte@gmail.com", "name": "Yurii Motov", "username": "YuriiMotov"}, "committer": {"email": "noreply@github.com", "name": "GitHub", "username": "web-flow"}, "distinct": true, "id": "c6ecd8c3080f2f68a1195676b0db983ee13b22a7", "message": "Add `pretty_exceptions_word_wrap` parameter", "timestamp": "2026-04-15T22:51:20Z", "tree_id": "c58037ac1091c9c9522d745a0e7b0830edb0e372", "url": ""}], "compare": "", "created": false, "deleted": false, "forced": false, "head_commit": {"author": {"email": "yurii.motov.monte@gmail.com", "name": "Yurii Motov", "username": "YuriiMotov"}, "committer": {"email": "noreply@github.com", "name": "GitHub", "username": "web-flow"}, "distinct": true, "id": "c6ecd8c3080f2f68a1195676b0db983ee13b22a7", "message": "Add `pretty_exceptions_word_wrap` parameter", "timestamp": "2026-04-15T22:51:20Z", "tree_id": "c58037ac1091c9c9522d745a0e7b0830edb0e372", "url": ""}, "pusher": {"email": "yurii.motov.monte@gmail.com", "name": "YuriiMotov"}, "ref": "refs/heads/dont-truncate-traceback-lines", "repository": {"allow_forking": true, "archive_url": "https://api.github.com/repos/fastapi/typer/{archive_format}{/ref}", "archived": false, "assignees_url": "https://api.github.com/repos/fastapi/typer/assignees{/user}", "blobs_url": "https://api.github.com/repos/fastapi/typer/git/blobs{/sha}", "branches_url": "https://api.github.com/repos/fastapi/typer/branches{/branch}", "clone_url": "https://github.com/fastapi/typer.git", "collaborators_url": "https://api.github.com/repos/fastapi/typer/collaborators{/collaborator}", "comments_url": "https://api.github.com/repos/fastapi/typer/comments{/number}", "commits_url": "https://api.github.com/repos/fastapi/typer/commits{/sha}", "compare_url": "https://api.github.com/repos/fastapi/typer/compare/{base}...{head}", "contents_url": "https://api.github.com/repos/fastapi/typer/contents/{+path}", "contributors_url": "https://api.github.com/repos/fastapi/typer/contributors", "created_at": 0, "default_branch": "master", "deployments_url": "https://api.github.com/repos/fastapi/typer/deployments", "description": "Typer, build great CLIs. Easy to code. Based on Python type hints.", "disabled": false, "downloads_url": "https://api.github.com/repos/fastapi/typer/downloads", "events_url": "https://api.github.com/repos/fastapi/typer/events", "fork": false, "forks": 0, "forks_count": 0, "forks_url": "https://api.github.com/repos/fastapi/typer/forks", "full_name": "fastapi/typer", "git_commits_url": "https://api.github.com/repos/fastapi/typer/git/commits{/sha}", "git_refs_url": "https://api.github.com/repos/fastapi/typer/git/refs{/sha}", "git_tags_url": "https://api.github.com/repos/fastapi/typer/git/tags{/sha}", "git_url": "git://github.com/fastapi/typer.git", "has_downloads": true, "has_issues": true, "has_pages": true, "has_projects": true, "has_wiki": true, "homepage": null, "hooks_url": "https://api.github.com/repos/fastapi/typer/hooks", "html_url": "https://github.com/fastapi/typer", "id": 229937405, "is_template": false, "issue_comment_url": "https://api.github.com/repos/fastapi/typer/issues/comments{/number}", "issue_events_url": "https://api.github.com/repos/fastapi/typer/issues/events{/number}", "issues_url": "https://api.github.com/repos/fastapi/typer/issues{/number}", "keys_url": "https://api.github.com/repos/fastapi/typer/keys{/key_id}", "labels_url": "https://api.github.com/repos/fastapi/typer/labels{/name}", "language": "", "languages_url": "https://api.github.com/repos/fastapi/typer/languages", "license": null, "master_branch": "master", "merges_url": "https://api.github.com/repos/fastapi/typer/merges", "milestones_url": "https://api.github.com/repos/fastapi/typer/milestones{/number}", "mirror_url": null, "name": "typer", "node_id": "MDEwOlJlcG9zaXRvcnkyMjk5Mzc0MDU=", "notifications_url": "https://api.github.com/repos/fastapi/typer/notifications{?since,all,participating}", "open_issues": 0, "open_issues_count": 0, "owner": {"avatar_url": "https://avatars.githubusercontent.com/u/156354296?v=4", "email": "", "events_url": "https://api.github.com/users/fastapi/events{/privacy}", "followers_url": "https://api.github.com/users/fastapi/followers", "following_url": "https://api.github.com/users/fastapi/following{/other_user}", "gists_url": "https://api.github.com/users/fastapi/gists{/gist_id}", "gravatar_id": "", "html_url": "https://github.com/fastapi", "id": 156354296, "login": "fastapi", "name": "fastapi", "node_id": "O_kgDOCVHG-A", "organizations_url": "https://api.github.com/users/fastapi/orgs", "received_events_url": "https://api.github.com/users/fastapi/received_events", "repos_url": "https://api.github.com/users/fastapi/repos", "site_admin": false, "starred_url": "https://api.github.com/users/fastapi/starred{/owner}{/repo}", "subscriptions_url": "https://api.github.com/users/fastapi/subscriptions", "type": "Organization", "url": "https://api.github.com/users/fastapi"}, "private": false, "pulls_url": "https://api.github.com/repos/fastapi/typer/pulls{/number}", "pushed_at": 0, "releases_url": "https://api.github.com/repos/fastapi/typer/releases{/id}", "size": 0, "ssh_url": "git@github.com:fastapi/typer.git", "stargazers": 0, "stargazers_count": 0, "stargazers_url": "https://api.github.com/repos/fastapi/typer/stargazers", "statuses_url": "https://api.github.com/repos/fastapi/typer/statuses/{sha}", "subscribers_url": "https://api.github.com/repos/fastapi/typer/subscribers", "subscription_url": "https://api.github.com/repos/fastapi/typer/subscription", "svn_url": "https://github.com/fastapi/typer", "tags_url": "https://api.github.com/repos/fastapi/typer/tags", "teams_url": "https://api.github.com/repos/fastapi/typer/teams", "topics": [], "trees_url": "https://api.github.com/repos/fastapi/typer/git/trees{/sha}", "updated_at": "2026-04-15T22:51:20Z", "url": "https://api.github.com/repos/fastapi/typer", "visibility": "public", "watchers": 0, "watchers_count": 0, "web_commit_signoff_required": false}, "sender": {"avatar_url": "https://avatars.githubusercontent.com/u/109919500?v=4", "email": "", "events_url": "https://api.github.com/users/YuriiMotov/events{/privacy}", "followers_url": "https://api.github.com/users/YuriiMotov/followers", "following_url": "https://api.github.com/users/YuriiMotov/following{/other_user}", "gists_url": "https://api.github.com/users/YuriiMotov/gists{/gist_id}", "gravatar_id": "", "html_url": "https://github.com/YuriiMotov", "id": 109919500, "login": "YuriiMotov", "name": "YuriiMotov", "node_id": "U_kgDOBo09DA", "organizations_url": "https://api.github.com/users/YuriiMotov/orgs", "received_events_url": "https://api.github.com/users/YuriiMotov/received_events", "repos_url": "https://api.github.com/users/YuriiMotov/repos", "site_admin": false, "starred_url": "https://api.github.com/users/YuriiMotov/starred{/owner}{/repo}", "subscriptions_url": "https://api.github.com/users/YuriiMotov/subscriptions", "type": "User", "url": "https://api.github.com/users/YuriiMotov"}}, "server_url": "https://github.com", "api_url": "https://api.github.com", "graphql_url": "https://api.github.com/graphql", "ref_name": "dont-truncate-traceback-lines", "ref_protected": "false", "ref_type": "branch", "secret_source": "", "event_path": "/home/github/workflow/event.json", "path": "/home/github/workflow/paths.txt", "env": "/home/github/workflow/envs.txt", "workspace": "", "action": "", "action_repository": "", "action_status": "", "action_path": "", "action_ref": ""}' p:')' p:')')" \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run 'echo "$GITHUB_CONTEXT"'
echo "##[endgroup]"
echo 'echo "$GITHUB_CONTEXT"' > /home/github/71552794390/steps/bugswarm_0.sh
chmod u+x /home/github/71552794390/steps/bugswarm_0.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=0 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=YuriiMotov GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=dont-truncate-traceback-lines GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/dont-truncate-traceback-lines GITHUB_REF_NAME=dont-truncate-traceback-lines GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=fastapi/typer GITHUB_REPOSITORY_OWNER=fastapi GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=c6ecd8c3080f2f68a1195676b0db983ee13b22a7 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Test GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 UV_NO_SYNC=true UV_PYTHON=3.10 UV_RESOLUTION=lowest-direct "${CURRENT_ENV[@]}" GITHUB_CONTEXT="$(/home/github/71552794390/helpers/eval_expression p:'(' f:toJson p:'(' l:'{"token": "DUMMY", "job": "", "ref": "refs/heads/dont-truncate-traceback-lines", "sha": "c6ecd8c3080f2f68a1195676b0db983ee13b22a7", "repository": "fastapi/typer", "repository_owner": "fastapi", "repositoryUrl": "git://github.com/fastapi/typer.git", "run_id": "71552794390", "run_number": 24483384485, "retention_days": "0", "run_attempt": "1", "actor": "YuriiMotov", "triggering_actor": "YuriiMotov", "workflow": "Test", "head_ref": "dont-truncate-traceback-lines", "base_ref": "", "event_name": "push", "event": {"after": "", "base_ref": null, "before": "", "commits": [{"author": {"email": "yurii.motov.monte@gmail.com", "name": "Yurii Motov", "username": "YuriiMotov"}, "committer": {"email": "noreply@github.com", "name": "GitHub", "username": "web-flow"}, "distinct": true, "id": "c6ecd8c3080f2f68a1195676b0db983ee13b22a7", "message": "Add `pretty_exceptions_word_wrap` parameter", "timestamp": "2026-04-15T22:51:20Z", "tree_id": "c58037ac1091c9c9522d745a0e7b0830edb0e372", "url": ""}], "compare": "", "created": false, "deleted": false, "forced": false, "head_commit": {"author": {"email": "yurii.motov.monte@gmail.com", "name": "Yurii Motov", "username": "YuriiMotov"}, "committer": {"email": "noreply@github.com", "name": "GitHub", "username": "web-flow"}, "distinct": true, "id": "c6ecd8c3080f2f68a1195676b0db983ee13b22a7", "message": "Add `pretty_exceptions_word_wrap` parameter", "timestamp": "2026-04-15T22:51:20Z", "tree_id": "c58037ac1091c9c9522d745a0e7b0830edb0e372", "url": ""}, "pusher": {"email": "yurii.motov.monte@gmail.com", "name": "YuriiMotov"}, "ref": "refs/heads/dont-truncate-traceback-lines", "repository": {"allow_forking": true, "archive_url": "https://api.github.com/repos/fastapi/typer/{archive_format}{/ref}", "archived": false, "assignees_url": "https://api.github.com/repos/fastapi/typer/assignees{/user}", "blobs_url": "https://api.github.com/repos/fastapi/typer/git/blobs{/sha}", "branches_url": "https://api.github.com/repos/fastapi/typer/branches{/branch}", "clone_url": "https://github.com/fastapi/typer.git", "collaborators_url": "https://api.github.com/repos/fastapi/typer/collaborators{/collaborator}", "comments_url": "https://api.github.com/repos/fastapi/typer/comments{/number}", "commits_url": "https://api.github.com/repos/fastapi/typer/commits{/sha}", "compare_url": "https://api.github.com/repos/fastapi/typer/compare/{base}...{head}", "contents_url": "https://api.github.com/repos/fastapi/typer/contents/{+path}", "contributors_url": "https://api.github.com/repos/fastapi/typer/contributors", "created_at": 0, "default_branch": "master", "deployments_url": "https://api.github.com/repos/fastapi/typer/deployments", "description": "Typer, build great CLIs. Easy to code. Based on Python type hints.", "disabled": false, "downloads_url": "https://api.github.com/repos/fastapi/typer/downloads", "events_url": "https://api.github.com/repos/fastapi/typer/events", "fork": false, "forks": 0, "forks_count": 0, "forks_url": "https://api.github.com/repos/fastapi/typer/forks", "full_name": "fastapi/typer", "git_commits_url": "https://api.github.com/repos/fastapi/typer/git/commits{/sha}", "git_refs_url": "https://api.github.com/repos/fastapi/typer/git/refs{/sha}", "git_tags_url": "https://api.github.com/repos/fastapi/typer/git/tags{/sha}", "git_url": "git://github.com/fastapi/typer.git", "has_downloads": true, "has_issues": true, "has_pages": true, "has_projects": true, "has_wiki": true, "homepage": null, "hooks_url": "https://api.github.com/repos/fastapi/typer/hooks", "html_url": "https://github.com/fastapi/typer", "id": 229937405, "is_template": false, "issue_comment_url": "https://api.github.com/repos/fastapi/typer/issues/comments{/number}", "issue_events_url": "https://api.github.com/repos/fastapi/typer/issues/events{/number}", "issues_url": "https://api.github.com/repos/fastapi/typer/issues{/number}", "keys_url": "https://api.github.com/repos/fastapi/typer/keys{/key_id}", "labels_url": "https://api.github.com/repos/fastapi/typer/labels{/name}", "language": "", "languages_url": "https://api.github.com/repos/fastapi/typer/languages", "license": null, "master_branch": "master", "merges_url": "https://api.github.com/repos/fastapi/typer/merges", "milestones_url": "https://api.github.com/repos/fastapi/typer/milestones{/number}", "mirror_url": null, "name": "typer", "node_id": "MDEwOlJlcG9zaXRvcnkyMjk5Mzc0MDU=", "notifications_url": "https://api.github.com/repos/fastapi/typer/notifications{?since,all,participating}", "open_issues": 0, "open_issues_count": 0, "owner": {"avatar_url": "https://avatars.githubusercontent.com/u/156354296?v=4", "email": "", "events_url": "https://api.github.com/users/fastapi/events{/privacy}", "followers_url": "https://api.github.com/users/fastapi/followers", "following_url": "https://api.github.com/users/fastapi/following{/other_user}", "gists_url": "https://api.github.com/users/fastapi/gists{/gist_id}", "gravatar_id": "", "html_url": "https://github.com/fastapi", "id": 156354296, "login": "fastapi", "name": "fastapi", "node_id": "O_kgDOCVHG-A", "organizations_url": "https://api.github.com/users/fastapi/orgs", "received_events_url": "https://api.github.com/users/fastapi/received_events", "repos_url": "https://api.github.com/users/fastapi/repos", "site_admin": false, "starred_url": "https://api.github.com/users/fastapi/starred{/owner}{/repo}", "subscriptions_url": "https://api.github.com/users/fastapi/subscriptions", "type": "Organization", "url": "https://api.github.com/users/fastapi"}, "private": false, "pulls_url": "https://api.github.com/repos/fastapi/typer/pulls{/number}", "pushed_at": 0, "releases_url": "https://api.github.com/repos/fastapi/typer/releases{/id}", "size": 0, "ssh_url": "git@github.com:fastapi/typer.git", "stargazers": 0, "stargazers_count": 0, "stargazers_url": "https://api.github.com/repos/fastapi/typer/stargazers", "statuses_url": "https://api.github.com/repos/fastapi/typer/statuses/{sha}", "subscribers_url": "https://api.github.com/repos/fastapi/typer/subscribers", "subscription_url": "https://api.github.com/repos/fastapi/typer/subscription", "svn_url": "https://github.com/fastapi/typer", "tags_url": "https://api.github.com/repos/fastapi/typer/tags", "teams_url": "https://api.github.com/repos/fastapi/typer/teams", "topics": [], "trees_url": "https://api.github.com/repos/fastapi/typer/git/trees{/sha}", "updated_at": "2026-04-15T22:51:20Z", "url": "https://api.github.com/repos/fastapi/typer", "visibility": "public", "watchers": 0, "watchers_count": 0, "web_commit_signoff_required": false}, "sender": {"avatar_url": "https://avatars.githubusercontent.com/u/109919500?v=4", "email": "", "events_url": "https://api.github.com/users/YuriiMotov/events{/privacy}", "followers_url": "https://api.github.com/users/YuriiMotov/followers", "following_url": "https://api.github.com/users/YuriiMotov/following{/other_user}", "gists_url": "https://api.github.com/users/YuriiMotov/gists{/gist_id}", "gravatar_id": "", "html_url": "https://github.com/YuriiMotov", "id": 109919500, "login": "YuriiMotov", "name": "YuriiMotov", "node_id": "U_kgDOBo09DA", "organizations_url": "https://api.github.com/users/YuriiMotov/orgs", "received_events_url": "https://api.github.com/users/YuriiMotov/received_events", "repos_url": "https://api.github.com/users/YuriiMotov/repos", "site_admin": false, "starred_url": "https://api.github.com/users/YuriiMotov/starred{/owner}{/repo}", "subscriptions_url": "https://api.github.com/users/YuriiMotov/subscriptions", "type": "User", "url": "https://api.github.com/users/YuriiMotov"}}, "server_url": "https://github.com", "api_url": "https://api.github.com", "graphql_url": "https://api.github.com/graphql", "ref_name": "dont-truncate-traceback-lines", "ref_protected": "false", "ref_type": "branch", "secret_source": "", "event_path": "/home/github/workflow/event.json", "path": "/home/github/workflow/paths.txt", "env": "/home/github/workflow/envs.txt", "workspace": "", "action": "", "action_repository": "", "action_status": "", "action_path": "", "action_ref": ""}' p:')' p:')')" \
bash -e /home/github/71552794390/steps/bugswarm_0.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=0 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=YuriiMotov GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=dont-truncate-traceback-lines GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/dont-truncate-traceback-lines GITHUB_REF_NAME=dont-truncate-traceback-lines GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=fastapi/typer GITHUB_REPOSITORY_OWNER=fastapi GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=c6ecd8c3080f2f68a1195676b0db983ee13b22a7 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Test GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 UV_NO_SYNC=true UV_PYTHON=3.10 UV_RESOLUTION=lowest-direct "${CURRENT_ENV[@]}" GITHUB_CONTEXT="$(/home/github/71552794390/helpers/eval_expression p:'(' f:toJson p:'(' l:'{"token": "DUMMY", "job": "", "ref": "refs/heads/dont-truncate-traceback-lines", "sha": "c6ecd8c3080f2f68a1195676b0db983ee13b22a7", "repository": "fastapi/typer", "repository_owner": "fastapi", "repositoryUrl": "git://github.com/fastapi/typer.git", "run_id": "71552794390", "run_number": 24483384485, "retention_days": "0", "run_attempt": "1", "actor": "YuriiMotov", "triggering_actor": "YuriiMotov", "workflow": "Test", "head_ref": "dont-truncate-traceback-lines", "base_ref": "", "event_name": "push", "event": {"after": "", "base_ref": null, "before": "", "commits": [{"author": {"email": "yurii.motov.monte@gmail.com", "name": "Yurii Motov", "username": "YuriiMotov"}, "committer": {"email": "noreply@github.com", "name": "GitHub", "username": "web-flow"}, "distinct": true, "id": "c6ecd8c3080f2f68a1195676b0db983ee13b22a7", "message": "Add `pretty_exceptions_word_wrap` parameter", "timestamp": "2026-04-15T22:51:20Z", "tree_id": "c58037ac1091c9c9522d745a0e7b0830edb0e372", "url": ""}], "compare": "", "created": false, "deleted": false, "forced": false, "head_commit": {"author": {"email": "yurii.motov.monte@gmail.com", "name": "Yurii Motov", "username": "YuriiMotov"}, "committer": {"email": "noreply@github.com", "name": "GitHub", "username": "web-flow"}, "distinct": true, "id": "c6ecd8c3080f2f68a1195676b0db983ee13b22a7", "message": "Add `pretty_exceptions_word_wrap` parameter", "timestamp": "2026-04-15T22:51:20Z", "tree_id": "c58037ac1091c9c9522d745a0e7b0830edb0e372", "url": ""}, "pusher": {"email": "yurii.motov.monte@gmail.com", "name": "YuriiMotov"}, "ref": "refs/heads/dont-truncate-traceback-lines", "repository": {"allow_forking": true, "archive_url": "https://api.github.com/repos/fastapi/typer/{archive_format}{/ref}", "archived": false, "assignees_url": "https://api.github.com/repos/fastapi/typer/assignees{/user}", "blobs_url": "https://api.github.com/repos/fastapi/typer/git/blobs{/sha}", "branches_url": "https://api.github.com/repos/fastapi/typer/branches{/branch}", "clone_url": "https://github.com/fastapi/typer.git", "collaborators_url": "https://api.github.com/repos/fastapi/typer/collaborators{/collaborator}", "comments_url": "https://api.github.com/repos/fastapi/typer/comments{/number}", "commits_url": "https://api.github.com/repos/fastapi/typer/commits{/sha}", "compare_url": "https://api.github.com/repos/fastapi/typer/compare/{base}...{head}", "contents_url": "https://api.github.com/repos/fastapi/typer/contents/{+path}", "contributors_url": "https://api.github.com/repos/fastapi/typer/contributors", "created_at": 0, "default_branch": "master", "deployments_url": "https://api.github.com/repos/fastapi/typer/deployments", "description": "Typer, build great CLIs. Easy to code. Based on Python type hints.", "disabled": false, "downloads_url": "https://api.github.com/repos/fastapi/typer/downloads", "events_url": "https://api.github.com/repos/fastapi/typer/events", "fork": false, "forks": 0, "forks_count": 0, "forks_url": "https://api.github.com/repos/fastapi/typer/forks", "full_name": "fastapi/typer", "git_commits_url": "https://api.github.com/repos/fastapi/typer/git/commits{/sha}", "git_refs_url": "https://api.github.com/repos/fastapi/typer/git/refs{/sha}", "git_tags_url": "https://api.github.com/repos/fastapi/typer/git/tags{/sha}", "git_url": "git://github.com/fastapi/typer.git", "has_downloads": true, "has_issues": true, "has_pages": true, "has_projects": true, "has_wiki": true, "homepage": null, "hooks_url": "https://api.github.com/repos/fastapi/typer/hooks", "html_url": "https://github.com/fastapi/typer", "id": 229937405, "is_template": false, "issue_comment_url": "https://api.github.com/repos/fastapi/typer/issues/comments{/number}", "issue_events_url": "https://api.github.com/repos/fastapi/typer/issues/events{/number}", "issues_url": "https://api.github.com/repos/fastapi/typer/issues{/number}", "keys_url": "https://api.github.com/repos/fastapi/typer/keys{/key_id}", "labels_url": "https://api.github.com/repos/fastapi/typer/labels{/name}", "language": "", "languages_url": "https://api.github.com/repos/fastapi/typer/languages", "license": null, "master_branch": "master", "merges_url": "https://api.github.com/repos/fastapi/typer/merges", "milestones_url": "https://api.github.com/repos/fastapi/typer/milestones{/number}", "mirror_url": null, "name": "typer", "node_id": "MDEwOlJlcG9zaXRvcnkyMjk5Mzc0MDU=", "notifications_url": "https://api.github.com/repos/fastapi/typer/notifications{?since,all,participating}", "open_issues": 0, "open_issues_count": 0, "owner": {"avatar_url": "https://avatars.githubusercontent.com/u/156354296?v=4", "email": "", "events_url": "https://api.github.com/users/fastapi/events{/privacy}", "followers_url": "https://api.github.com/users/fastapi/followers", "following_url": "https://api.github.com/users/fastapi/following{/other_user}", "gists_url": "https://api.github.com/users/fastapi/gists{/gist_id}", "gravatar_id": "", "html_url": "https://github.com/fastapi", "id": 156354296, "login": "fastapi", "name": "fastapi", "node_id": "O_kgDOCVHG-A", "organizations_url": "https://api.github.com/users/fastapi/orgs", "received_events_url": "https://api.github.com/users/fastapi/received_events", "repos_url": "https://api.github.com/users/fastapi/repos", "site_admin": false, "starred_url": "https://api.github.com/users/fastapi/starred{/owner}{/repo}", "subscriptions_url": "https://api.github.com/users/fastapi/subscriptions", "type": "Organization", "url": "https://api.github.com/users/fastapi"}, "private": false, "pulls_url": "https://api.github.com/repos/fastapi/typer/pulls{/number}", "pushed_at": 0, "releases_url": "https://api.github.com/repos/fastapi/typer/releases{/id}", "size": 0, "ssh_url": "git@github.com:fastapi/typer.git", "stargazers": 0, "stargazers_count": 0, "stargazers_url": "https://api.github.com/repos/fastapi/typer/stargazers", "statuses_url": "https://api.github.com/repos/fastapi/typer/statuses/{sha}", "subscribers_url": "https://api.github.com/repos/fastapi/typer/subscribers", "subscription_url": "https://api.github.com/repos/fastapi/typer/subscription", "svn_url": "https://github.com/fastapi/typer", "tags_url": "https://api.github.com/repos/fastapi/typer/tags", "teams_url": "https://api.github.com/repos/fastapi/typer/teams", "topics": [], "trees_url": "https://api.github.com/repos/fastapi/typer/git/trees{/sha}", "updated_at": "2026-04-15T22:51:20Z", "url": "https://api.github.com/repos/fastapi/typer", "visibility": "public", "watchers": 0, "watchers_count": 0, "web_commit_signoff_required": false}, "sender": {"avatar_url": "https://avatars.githubusercontent.com/u/109919500?v=4", "email": "", "events_url": "https://api.github.com/users/YuriiMotov/events{/privacy}", "followers_url": "https://api.github.com/users/YuriiMotov/followers", "following_url": "https://api.github.com/users/YuriiMotov/following{/other_user}", "gists_url": "https://api.github.com/users/YuriiMotov/gists{/gist_id}", "gravatar_id": "", "html_url": "https://github.com/YuriiMotov", "id": 109919500, "login": "YuriiMotov", "name": "YuriiMotov", "node_id": "U_kgDOBo09DA", "organizations_url": "https://api.github.com/users/YuriiMotov/orgs", "received_events_url": "https://api.github.com/users/YuriiMotov/received_events", "repos_url": "https://api.github.com/users/YuriiMotov/repos", "site_admin": false, "starred_url": "https://api.github.com/users/YuriiMotov/starred{/owner}{/repo}", "subscriptions_url": "https://api.github.com/users/YuriiMotov/subscriptions", "type": "User", "url": "https://api.github.com/users/YuriiMotov"}}, "server_url": "https://github.com", "api_url": "https://api.github.com", "graphql_url": "https://api.github.com/graphql", "ref_name": "dont-truncate-traceback-lines", "ref_protected": "false", "ref_type": "branch", "secret_source": "", "event_path": "/home/github/workflow/event.json", "path": "/home/github/workflow/paths.txt", "env": "/home/github/workflow/envs.txt", "workspace": "", "action": "", "action_repository": "", "action_status": "", "action_path": "", "action_ref": ""}' p:')' p:')')" \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=0 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=YuriiMotov GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=dont-truncate-traceback-lines GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/dont-truncate-traceback-lines GITHUB_REF_NAME=dont-truncate-traceback-lines GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=fastapi/typer GITHUB_REPOSITORY_OWNER=fastapi GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=c6ecd8c3080f2f68a1195676b0db983ee13b22a7 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Test GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 UV_NO_SYNC=true UV_PYTHON=3.10 UV_RESOLUTION=lowest-direct "${CURRENT_ENV[@]}" GITHUB_CONTEXT="$(/home/github/71552794390/helpers/eval_expression p:'(' f:toJson p:'(' l:'{"token": "DUMMY", "job": "", "ref": "refs/heads/dont-truncate-traceback-lines", "sha": "c6ecd8c3080f2f68a1195676b0db983ee13b22a7", "repository": "fastapi/typer", "repository_owner": "fastapi", "repositoryUrl": "git://github.com/fastapi/typer.git", "run_id": "71552794390", "run_number": 24483384485, "retention_days": "0", "run_attempt": "1", "actor": "YuriiMotov", "triggering_actor": "YuriiMotov", "workflow": "Test", "head_ref": "dont-truncate-traceback-lines", "base_ref": "", "event_name": "push", "event": {"after": "", "base_ref": null, "before": "", "commits": [{"author": {"email": "yurii.motov.monte@gmail.com", "name": "Yurii Motov", "username": "YuriiMotov"}, "committer": {"email": "noreply@github.com", "name": "GitHub", "username": "web-flow"}, "distinct": true, "id": "c6ecd8c3080f2f68a1195676b0db983ee13b22a7", "message": "Add `pretty_exceptions_word_wrap` parameter", "timestamp": "2026-04-15T22:51:20Z", "tree_id": "c58037ac1091c9c9522d745a0e7b0830edb0e372", "url": ""}], "compare": "", "created": false, "deleted": false, "forced": false, "head_commit": {"author": {"email": "yurii.motov.monte@gmail.com", "name": "Yurii Motov", "username": "YuriiMotov"}, "committer": {"email": "noreply@github.com", "name": "GitHub", "username": "web-flow"}, "distinct": true, "id": "c6ecd8c3080f2f68a1195676b0db983ee13b22a7", "message": "Add `pretty_exceptions_word_wrap` parameter", "timestamp": "2026-04-15T22:51:20Z", "tree_id": "c58037ac1091c9c9522d745a0e7b0830edb0e372", "url": ""}, "pusher": {"email": "yurii.motov.monte@gmail.com", "name": "YuriiMotov"}, "ref": "refs/heads/dont-truncate-traceback-lines", "repository": {"allow_forking": true, "archive_url": "https://api.github.com/repos/fastapi/typer/{archive_format}{/ref}", "archived": false, "assignees_url": "https://api.github.com/repos/fastapi/typer/assignees{/user}", "blobs_url": "https://api.github.com/repos/fastapi/typer/git/blobs{/sha}", "branches_url": "https://api.github.com/repos/fastapi/typer/branches{/branch}", "clone_url": "https://github.com/fastapi/typer.git", "collaborators_url": "https://api.github.com/repos/fastapi/typer/collaborators{/collaborator}", "comments_url": "https://api.github.com/repos/fastapi/typer/comments{/number}", "commits_url": "https://api.github.com/repos/fastapi/typer/commits{/sha}", "compare_url": "https://api.github.com/repos/fastapi/typer/compare/{base}...{head}", "contents_url": "https://api.github.com/repos/fastapi/typer/contents/{+path}", "contributors_url": "https://api.github.com/repos/fastapi/typer/contributors", "created_at": 0, "default_branch": "master", "deployments_url": "https://api.github.com/repos/fastapi/typer/deployments", "description": "Typer, build great CLIs. Easy to code. Based on Python type hints.", "disabled": false, "downloads_url": "https://api.github.com/repos/fastapi/typer/downloads", "events_url": "https://api.github.com/repos/fastapi/typer/events", "fork": false, "forks": 0, "forks_count": 0, "forks_url": "https://api.github.com/repos/fastapi/typer/forks", "full_name": "fastapi/typer", "git_commits_url": "https://api.github.com/repos/fastapi/typer/git/commits{/sha}", "git_refs_url": "https://api.github.com/repos/fastapi/typer/git/refs{/sha}", "git_tags_url": "https://api.github.com/repos/fastapi/typer/git/tags{/sha}", "git_url": "git://github.com/fastapi/typer.git", "has_downloads": true, "has_issues": true, "has_pages": true, "has_projects": true, "has_wiki": true, "homepage": null, "hooks_url": "https://api.github.com/repos/fastapi/typer/hooks", "html_url": "https://github.com/fastapi/typer", "id": 229937405, "is_template": false, "issue_comment_url": "https://api.github.com/repos/fastapi/typer/issues/comments{/number}", "issue_events_url": "https://api.github.com/repos/fastapi/typer/issues/events{/number}", "issues_url": "https://api.github.com/repos/fastapi/typer/issues{/number}", "keys_url": "https://api.github.com/repos/fastapi/typer/keys{/key_id}", "labels_url": "https://api.github.com/repos/fastapi/typer/labels{/name}", "language": "", "languages_url": "https://api.github.com/repos/fastapi/typer/languages", "license": null, "master_branch": "master", "merges_url": "https://api.github.com/repos/fastapi/typer/merges", "milestones_url": "https://api.github.com/repos/fastapi/typer/milestones{/number}", "mirror_url": null, "name": "typer", "node_id": "MDEwOlJlcG9zaXRvcnkyMjk5Mzc0MDU=", "notifications_url": "https://api.github.com/repos/fastapi/typer/notifications{?since,all,participating}", "open_issues": 0, "open_issues_count": 0, "owner": {"avatar_url": "https://avatars.githubusercontent.com/u/156354296?v=4", "email": "", "events_url": "https://api.github.com/users/fastapi/events{/privacy}", "followers_url": "https://api.github.com/users/fastapi/followers", "following_url": "https://api.github.com/users/fastapi/following{/other_user}", "gists_url": "https://api.github.com/users/fastapi/gists{/gist_id}", "gravatar_id": "", "html_url": "https://github.com/fastapi", "id": 156354296, "login": "fastapi", "name": "fastapi", "node_id": "O_kgDOCVHG-A", "organizations_url": "https://api.github.com/users/fastapi/orgs", "received_events_url": "https://api.github.com/users/fastapi/received_events", "repos_url": "https://api.github.com/users/fastapi/repos", "site_admin": false, "starred_url": "https://api.github.com/users/fastapi/starred{/owner}{/repo}", "subscriptions_url": "https://api.github.com/users/fastapi/subscriptions", "type": "Organization", "url": "https://api.github.com/users/fastapi"}, "private": false, "pulls_url": "https://api.github.com/repos/fastapi/typer/pulls{/number}", "pushed_at": 0, "releases_url": "https://api.github.com/repos/fastapi/typer/releases{/id}", "size": 0, "ssh_url": "git@github.com:fastapi/typer.git", "stargazers": 0, "stargazers_count": 0, "stargazers_url": "https://api.github.com/repos/fastapi/typer/stargazers", "statuses_url": "https://api.github.com/repos/fastapi/typer/statuses/{sha}", "subscribers_url": "https://api.github.com/repos/fastapi/typer/subscribers", "subscription_url": "https://api.github.com/repos/fastapi/typer/subscription", "svn_url": "https://github.com/fastapi/typer", "tags_url": "https://api.github.com/repos/fastapi/typer/tags", "teams_url": "https://api.github.com/repos/fastapi/typer/teams", "topics": [], "trees_url": "https://api.github.com/repos/fastapi/typer/git/trees{/sha}", "updated_at": "2026-04-15T22:51:20Z", "url": "https://api.github.com/repos/fastapi/typer", "visibility": "public", "watchers": 0, "watchers_count": 0, "web_commit_signoff_required": false}, "sender": {"avatar_url": "https://avatars.githubusercontent.com/u/109919500?v=4", "email": "", "events_url": "https://api.github.com/users/YuriiMotov/events{/privacy}", "followers_url": "https://api.github.com/users/YuriiMotov/followers", "following_url": "https://api.github.com/users/YuriiMotov/following{/other_user}", "gists_url": "https://api.github.com/users/YuriiMotov/gists{/gist_id}", "gravatar_id": "", "html_url": "https://github.com/YuriiMotov", "id": 109919500, "login": "YuriiMotov", "name": "YuriiMotov", "node_id": "U_kgDOBo09DA", "organizations_url": "https://api.github.com/users/YuriiMotov/orgs", "received_events_url": "https://api.github.com/users/YuriiMotov/received_events", "repos_url": "https://api.github.com/users/YuriiMotov/repos", "site_admin": false, "starred_url": "https://api.github.com/users/YuriiMotov/starred{/owner}{/repo}", "subscriptions_url": "https://api.github.com/users/YuriiMotov/subscriptions", "type": "User", "url": "https://api.github.com/users/YuriiMotov"}}, "server_url": "https://github.com", "api_url": "https://api.github.com", "graphql_url": "https://api.github.com/graphql", "ref_name": "dont-truncate-traceback-lines", "ref_protected": "false", "ref_type": "branch", "secret_source": "", "event_path": "/home/github/workflow/event.json", "path": "/home/github/workflow/paths.txt", "env": "/home/github/workflow/envs.txt", "workspace": "", "action": "", "action_repository": "", "action_status": "", "action_path": "", "action_ref": ""}' p:')' p:')')" \
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=2 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=actions/setup-python GITHUB_ACTIONS=true GITHUB_ACTOR=YuriiMotov GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=dont-truncate-traceback-lines GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/dont-truncate-traceback-lines GITHUB_REF_NAME=dont-truncate-traceback-lines GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=fastapi/typer GITHUB_REPOSITORY_OWNER=fastapi GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=c6ecd8c3080f2f68a1195676b0db983ee13b22a7 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Test GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 UV_NO_SYNC=true GITHUB_ACTION_PATH=/home/github/71552794390/actions/actions-setup-python@v6 UV_PYTHON=3.10 UV_RESOLUTION=lowest-direct "${CURRENT_ENV[@]}" INPUT_PYTHON-VERSION=3.10 INPUT_TOKEN= INPUT_CHECK-LATEST=false INPUT_UPDATE-ENVIRONMENT=true INPUT_ALLOW-PRERELEASES=false INPUT_FREETHREADED=false \
echo $(test "$_GITHUB_JOB_STATUS" = "success" && echo true || echo false))
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=2 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=actions/setup-python GITHUB_ACTIONS=true GITHUB_ACTOR=YuriiMotov GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=dont-truncate-traceback-lines GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/dont-truncate-traceback-lines GITHUB_REF_NAME=dont-truncate-traceback-lines GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=fastapi/typer GITHUB_REPOSITORY_OWNER=fastapi GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=c6ecd8c3080f2f68a1195676b0db983ee13b22a7 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Test GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 UV_NO_SYNC=true GITHUB_ACTION_PATH=/home/github/71552794390/actions/actions-setup-python@v6 UV_PYTHON=3.10 UV_RESOLUTION=lowest-direct "${CURRENT_ENV[@]}" INPUT_PYTHON-VERSION=3.10 INPUT_TOKEN= INPUT_CHECK-LATEST=false INPUT_UPDATE-ENVIRONMENT=true INPUT_ALLOW-PRERELEASES=false INPUT_FREETHREADED=false \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run actions/setup-python@v6
echo "##[endgroup]"
echo node /home/github/71552794390/actions/actions-setup-python@v6/dist/setup/index.js > /home/github/71552794390/steps/bugswarm_cmd.sh
chmod u+x /home/github/71552794390/steps/bugswarm_cmd.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=2 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=actions/setup-python GITHUB_ACTIONS=true GITHUB_ACTOR=YuriiMotov GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=dont-truncate-traceback-lines GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/dont-truncate-traceback-lines GITHUB_REF_NAME=dont-truncate-traceback-lines GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=fastapi/typer GITHUB_REPOSITORY_OWNER=fastapi GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=c6ecd8c3080f2f68a1195676b0db983ee13b22a7 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Test GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 UV_NO_SYNC=true GITHUB_ACTION_PATH=/home/github/71552794390/actions/actions-setup-python@v6 UV_PYTHON=3.10 UV_RESOLUTION=lowest-direct "${CURRENT_ENV[@]}" INPUT_PYTHON-VERSION=3.10 INPUT_TOKEN= INPUT_CHECK-LATEST=false INPUT_UPDATE-ENVIRONMENT=true INPUT_ALLOW-PRERELEASES=false INPUT_FREETHREADED=false \
bash -e /home/github/71552794390/steps/bugswarm_cmd.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=2 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=actions/setup-python GITHUB_ACTIONS=true GITHUB_ACTOR=YuriiMotov GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=dont-truncate-traceback-lines GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/dont-truncate-traceback-lines GITHUB_REF_NAME=dont-truncate-traceback-lines GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=fastapi/typer GITHUB_REPOSITORY_OWNER=fastapi GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=c6ecd8c3080f2f68a1195676b0db983ee13b22a7 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Test GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 UV_NO_SYNC=true GITHUB_ACTION_PATH=/home/github/71552794390/actions/actions-setup-python@v6 UV_PYTHON=3.10 UV_RESOLUTION=lowest-direct "${CURRENT_ENV[@]}" INPUT_PYTHON-VERSION=3.10 INPUT_TOKEN= INPUT_CHECK-LATEST=false INPUT_UPDATE-ENVIRONMENT=true INPUT_ALLOW-PRERELEASES=false INPUT_FREETHREADED=false \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=2 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=actions/setup-python GITHUB_ACTIONS=true GITHUB_ACTOR=YuriiMotov GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=dont-truncate-traceback-lines GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/dont-truncate-traceback-lines GITHUB_REF_NAME=dont-truncate-traceback-lines GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=fastapi/typer GITHUB_REPOSITORY_OWNER=fastapi GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=c6ecd8c3080f2f68a1195676b0db983ee13b22a7 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Test GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 UV_NO_SYNC=true GITHUB_ACTION_PATH=/home/github/71552794390/actions/actions-setup-python@v6 UV_PYTHON=3.10 UV_RESOLUTION=lowest-direct "${CURRENT_ENV[@]}" INPUT_PYTHON-VERSION=3.10 INPUT_TOKEN= INPUT_CHECK-LATEST=false INPUT_UPDATE-ENVIRONMENT=true INPUT_ALLOW-PRERELEASES=false INPUT_FREETHREADED=false \
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=3 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=astral-sh/setup-uv GITHUB_ACTIONS=true GITHUB_ACTOR=YuriiMotov GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=dont-truncate-traceback-lines GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/dont-truncate-traceback-lines GITHUB_REF_NAME=dont-truncate-traceback-lines GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=fastapi/typer GITHUB_REPOSITORY_OWNER=fastapi GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=c6ecd8c3080f2f68a1195676b0db983ee13b22a7 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Test GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 UV_NO_SYNC=true GITHUB_ACTION_PATH=/home/github/71552794390/actions/astral-sh-setup-uv@v7 UV_PYTHON=3.10 UV_RESOLUTION=lowest-direct "${CURRENT_ENV[@]}" INPUT_ENABLE-CACHE=true INPUT_CACHE-DEPENDENCY-GLOB='pyproject.toml
uv.lock
' INPUT_VERSION= INPUT_VERSION-FILE= INPUT_ACTIVATE-ENVIRONMENT=false INPUT_VENV-PATH= INPUT_WORKING-DIRECTORY=${GITHUB_WORKSPACE} INPUT_GITHUB-TOKEN=DUMMY INPUT_RESTORE-CACHE=true INPUT_SAVE-CACHE=true INPUT_CACHE-LOCAL-PATH= INPUT_PRUNE-CACHE=true INPUT_CACHE-PYTHON=false INPUT_IGNORE-NOTHING-TO-CACHE=false INPUT_IGNORE-EMPTY-WORKDIR=false INPUT_ADD-PROBLEM-MATCHERS=true INPUT_RESOLUTION-STRATEGY=highest \
echo $(test "$_GITHUB_JOB_STATUS" = "success" && echo true || echo false))
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=3 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=astral-sh/setup-uv GITHUB_ACTIONS=true GITHUB_ACTOR=YuriiMotov GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=dont-truncate-traceback-lines GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/dont-truncate-traceback-lines GITHUB_REF_NAME=dont-truncate-traceback-lines GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=fastapi/typer GITHUB_REPOSITORY_OWNER=fastapi GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=c6ecd8c3080f2f68a1195676b0db983ee13b22a7 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Test GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 UV_NO_SYNC=true GITHUB_ACTION_PATH=/home/github/71552794390/actions/astral-sh-setup-uv@v7 UV_PYTHON=3.10 UV_RESOLUTION=lowest-direct "${CURRENT_ENV[@]}" INPUT_ENABLE-CACHE=true INPUT_CACHE-DEPENDENCY-GLOB='pyproject.toml
uv.lock
' INPUT_VERSION= INPUT_VERSION-FILE= INPUT_ACTIVATE-ENVIRONMENT=false INPUT_VENV-PATH= INPUT_WORKING-DIRECTORY=${GITHUB_WORKSPACE} INPUT_GITHUB-TOKEN=DUMMY INPUT_RESTORE-CACHE=true INPUT_SAVE-CACHE=true INPUT_CACHE-LOCAL-PATH= INPUT_PRUNE-CACHE=true INPUT_CACHE-PYTHON=false INPUT_IGNORE-NOTHING-TO-CACHE=false INPUT_IGNORE-EMPTY-WORKDIR=false INPUT_ADD-PROBLEM-MATCHERS=true INPUT_RESOLUTION-STRATEGY=highest \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run astral-sh/setup-uv@v7
echo "##[endgroup]"
echo node /home/github/71552794390/actions/astral-sh-setup-uv@v7/dist/setup/index.cjs > /home/github/71552794390/steps/bugswarm_cmd.sh
chmod u+x /home/github/71552794390/steps/bugswarm_cmd.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=3 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=astral-sh/setup-uv GITHUB_ACTIONS=true GITHUB_ACTOR=YuriiMotov GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=dont-truncate-traceback-lines GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/dont-truncate-traceback-lines GITHUB_REF_NAME=dont-truncate-traceback-lines GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=fastapi/typer GITHUB_REPOSITORY_OWNER=fastapi GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=c6ecd8c3080f2f68a1195676b0db983ee13b22a7 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Test GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 UV_NO_SYNC=true GITHUB_ACTION_PATH=/home/github/71552794390/actions/astral-sh-setup-uv@v7 UV_PYTHON=3.10 UV_RESOLUTION=lowest-direct "${CURRENT_ENV[@]}" INPUT_ENABLE-CACHE=true INPUT_CACHE-DEPENDENCY-GLOB='pyproject.toml
uv.lock
' INPUT_VERSION= INPUT_VERSION-FILE= INPUT_ACTIVATE-ENVIRONMENT=false INPUT_VENV-PATH= INPUT_WORKING-DIRECTORY=${GITHUB_WORKSPACE} INPUT_GITHUB-TOKEN=DUMMY INPUT_RESTORE-CACHE=true INPUT_SAVE-CACHE=true INPUT_CACHE-LOCAL-PATH= INPUT_PRUNE-CACHE=true INPUT_CACHE-PYTHON=false INPUT_IGNORE-NOTHING-TO-CACHE=false INPUT_IGNORE-EMPTY-WORKDIR=false INPUT_ADD-PROBLEM-MATCHERS=true INPUT_RESOLUTION-STRATEGY=highest \
bash -e /home/github/71552794390/steps/bugswarm_cmd.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=3 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=astral-sh/setup-uv GITHUB_ACTIONS=true GITHUB_ACTOR=YuriiMotov GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=dont-truncate-traceback-lines GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/dont-truncate-traceback-lines GITHUB_REF_NAME=dont-truncate-traceback-lines GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=fastapi/typer GITHUB_REPOSITORY_OWNER=fastapi GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=c6ecd8c3080f2f68a1195676b0db983ee13b22a7 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Test GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 UV_NO_SYNC=true GITHUB_ACTION_PATH=/home/github/71552794390/actions/astral-sh-setup-uv@v7 UV_PYTHON=3.10 UV_RESOLUTION=lowest-direct "${CURRENT_ENV[@]}" INPUT_ENABLE-CACHE=true INPUT_CACHE-DEPENDENCY-GLOB='pyproject.toml
uv.lock
' INPUT_VERSION= INPUT_VERSION-FILE= INPUT_ACTIVATE-ENVIRONMENT=false INPUT_VENV-PATH= INPUT_WORKING-DIRECTORY=${GITHUB_WORKSPACE} INPUT_GITHUB-TOKEN=DUMMY INPUT_RESTORE-CACHE=true INPUT_SAVE-CACHE=true INPUT_CACHE-LOCAL-PATH= INPUT_PRUNE-CACHE=true INPUT_CACHE-PYTHON=false INPUT_IGNORE-NOTHING-TO-CACHE=false INPUT_IGNORE-EMPTY-WORKDIR=false INPUT_ADD-PROBLEM-MATCHERS=true INPUT_RESOLUTION-STRATEGY=highest \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=3 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY=astral-sh/setup-uv GITHUB_ACTIONS=true GITHUB_ACTOR=YuriiMotov GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=dont-truncate-traceback-lines GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/dont-truncate-traceback-lines GITHUB_REF_NAME=dont-truncate-traceback-lines GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=fastapi/typer GITHUB_REPOSITORY_OWNER=fastapi GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=c6ecd8c3080f2f68a1195676b0db983ee13b22a7 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Test GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 UV_NO_SYNC=true GITHUB_ACTION_PATH=/home/github/71552794390/actions/astral-sh-setup-uv@v7 UV_PYTHON=3.10 UV_RESOLUTION=lowest-direct "${CURRENT_ENV[@]}" INPUT_ENABLE-CACHE=true INPUT_CACHE-DEPENDENCY-GLOB='pyproject.toml
uv.lock
' INPUT_VERSION= INPUT_VERSION-FILE= INPUT_ACTIVATE-ENVIRONMENT=false INPUT_VENV-PATH= INPUT_WORKING-DIRECTORY=${GITHUB_WORKSPACE} INPUT_GITHUB-TOKEN=DUMMY INPUT_RESTORE-CACHE=true INPUT_SAVE-CACHE=true INPUT_CACHE-LOCAL-PATH= INPUT_PRUNE-CACHE=true INPUT_CACHE-PYTHON=false INPUT_IGNORE-NOTHING-TO-CACHE=false INPUT_IGNORE-EMPTY-WORKDIR=false INPUT_ADD-PROBLEM-MATCHERS=true INPUT_RESOLUTION-STRATEGY=highest \
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=4 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=YuriiMotov GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=dont-truncate-traceback-lines GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/dont-truncate-traceback-lines GITHUB_REF_NAME=dont-truncate-traceback-lines GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=fastapi/typer GITHUB_REPOSITORY_OWNER=fastapi GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=c6ecd8c3080f2f68a1195676b0db983ee13b22a7 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Test GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 UV_NO_SYNC=true UV_PYTHON=3.10 UV_RESOLUTION=lowest-direct "${CURRENT_ENV[@]}" \
echo $(test "$_GITHUB_JOB_STATUS" = "success" && echo true || echo false))
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=4 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=YuriiMotov GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=dont-truncate-traceback-lines GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/dont-truncate-traceback-lines GITHUB_REF_NAME=dont-truncate-traceback-lines GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=fastapi/typer GITHUB_REPOSITORY_OWNER=fastapi GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=c6ecd8c3080f2f68a1195676b0db983ee13b22a7 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Test GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 UV_NO_SYNC=true UV_PYTHON=3.10 UV_RESOLUTION=lowest-direct "${CURRENT_ENV[@]}" \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run 'uv sync --no-dev --group tests'
echo "##[endgroup]"
echo 'uv sync --no-dev --group tests' > /home/github/71552794390/steps/bugswarm_4.sh
chmod u+x /home/github/71552794390/steps/bugswarm_4.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=4 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=YuriiMotov GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=dont-truncate-traceback-lines GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/dont-truncate-traceback-lines GITHUB_REF_NAME=dont-truncate-traceback-lines GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=fastapi/typer GITHUB_REPOSITORY_OWNER=fastapi GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=c6ecd8c3080f2f68a1195676b0db983ee13b22a7 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Test GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 UV_NO_SYNC=true UV_PYTHON=3.10 UV_RESOLUTION=lowest-direct "${CURRENT_ENV[@]}" \
bash -e /home/github/71552794390/steps/bugswarm_4.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=4 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=YuriiMotov GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=dont-truncate-traceback-lines GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/dont-truncate-traceback-lines GITHUB_REF_NAME=dont-truncate-traceback-lines GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=fastapi/typer GITHUB_REPOSITORY_OWNER=fastapi GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=c6ecd8c3080f2f68a1195676b0db983ee13b22a7 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Test GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 UV_NO_SYNC=true UV_PYTHON=3.10 UV_RESOLUTION=lowest-direct "${CURRENT_ENV[@]}" \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=4 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=YuriiMotov GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=dont-truncate-traceback-lines GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/dont-truncate-traceback-lines GITHUB_REF_NAME=dont-truncate-traceback-lines GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=fastapi/typer GITHUB_REPOSITORY_OWNER=fastapi GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=c6ecd8c3080f2f68a1195676b0db983ee13b22a7 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Test GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 UV_NO_SYNC=true UV_PYTHON=3.10 UV_RESOLUTION=lowest-direct "${CURRENT_ENV[@]}" \
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=5 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=YuriiMotov GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=dont-truncate-traceback-lines GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/dont-truncate-traceback-lines GITHUB_REF_NAME=dont-truncate-traceback-lines GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=fastapi/typer GITHUB_REPOSITORY_OWNER=fastapi GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=c6ecd8c3080f2f68a1195676b0db983ee13b22a7 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Test GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 UV_NO_SYNC=true UV_PYTHON=3.10 UV_RESOLUTION=lowest-direct "${CURRENT_ENV[@]}" \
echo $(test "$_GITHUB_JOB_STATUS" = "success" && echo true || echo false))
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=5 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=YuriiMotov GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=dont-truncate-traceback-lines GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/dont-truncate-traceback-lines GITHUB_REF_NAME=dont-truncate-traceback-lines GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=fastapi/typer GITHUB_REPOSITORY_OWNER=fastapi GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=c6ecd8c3080f2f68a1195676b0db983ee13b22a7 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Test GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 UV_NO_SYNC=true UV_PYTHON=3.10 UV_RESOLUTION=lowest-direct "${CURRENT_ENV[@]}" \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run 'mkdir coverage'
echo "##[endgroup]"
echo 'mkdir coverage' > /home/github/71552794390/steps/bugswarm_5.sh
chmod u+x /home/github/71552794390/steps/bugswarm_5.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=5 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=YuriiMotov GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=dont-truncate-traceback-lines GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/dont-truncate-traceback-lines GITHUB_REF_NAME=dont-truncate-traceback-lines GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=fastapi/typer GITHUB_REPOSITORY_OWNER=fastapi GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=c6ecd8c3080f2f68a1195676b0db983ee13b22a7 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Test GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 UV_NO_SYNC=true UV_PYTHON=3.10 UV_RESOLUTION=lowest-direct "${CURRENT_ENV[@]}" \
bash -e /home/github/71552794390/steps/bugswarm_5.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=5 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=YuriiMotov GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=dont-truncate-traceback-lines GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/dont-truncate-traceback-lines GITHUB_REF_NAME=dont-truncate-traceback-lines GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=fastapi/typer GITHUB_REPOSITORY_OWNER=fastapi GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=c6ecd8c3080f2f68a1195676b0db983ee13b22a7 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Test GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 UV_NO_SYNC=true UV_PYTHON=3.10 UV_RESOLUTION=lowest-direct "${CURRENT_ENV[@]}" \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=5 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=YuriiMotov GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=dont-truncate-traceback-lines GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/dont-truncate-traceback-lines GITHUB_REF_NAME=dont-truncate-traceback-lines GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=fastapi/typer GITHUB_REPOSITORY_OWNER=fastapi GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=c6ecd8c3080f2f68a1195676b0db983ee13b22a7 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Test GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 UV_NO_SYNC=true UV_PYTHON=3.10 UV_RESOLUTION=lowest-direct "${CURRENT_ENV[@]}" \
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=6 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=YuriiMotov GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=dont-truncate-traceback-lines GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/dont-truncate-traceback-lines GITHUB_REF_NAME=dont-truncate-traceback-lines GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=fastapi/typer GITHUB_REPOSITORY_OWNER=fastapi GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=c6ecd8c3080f2f68a1195676b0db983ee13b22a7 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Test GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 UV_NO_SYNC=true UV_PYTHON=3.10 UV_RESOLUTION=lowest-direct "${CURRENT_ENV[@]}" \
echo $(test "$_GITHUB_JOB_STATUS" = "success" && echo true || echo false))
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=6 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=YuriiMotov GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=dont-truncate-traceback-lines GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/dont-truncate-traceback-lines GITHUB_REF_NAME=dont-truncate-traceback-lines GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=fastapi/typer GITHUB_REPOSITORY_OWNER=fastapi GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=c6ecd8c3080f2f68a1195676b0db983ee13b22a7 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Test GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 UV_NO_SYNC=true UV_PYTHON=3.10 UV_RESOLUTION=lowest-direct "${CURRENT_ENV[@]}" \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run 'uv run bash scripts/test-files.sh'
echo "##[endgroup]"
echo 'uv run bash scripts/test-files.sh' > /home/github/71552794390/steps/bugswarm_6.sh
chmod u+x /home/github/71552794390/steps/bugswarm_6.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=6 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=YuriiMotov GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=dont-truncate-traceback-lines GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/dont-truncate-traceback-lines GITHUB_REF_NAME=dont-truncate-traceback-lines GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=fastapi/typer GITHUB_REPOSITORY_OWNER=fastapi GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=c6ecd8c3080f2f68a1195676b0db983ee13b22a7 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Test GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 UV_NO_SYNC=true UV_PYTHON=3.10 UV_RESOLUTION=lowest-direct "${CURRENT_ENV[@]}" \
bash -e /home/github/71552794390/steps/bugswarm_6.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=6 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=YuriiMotov GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=dont-truncate-traceback-lines GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/dont-truncate-traceback-lines GITHUB_REF_NAME=dont-truncate-traceback-lines GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=fastapi/typer GITHUB_REPOSITORY_OWNER=fastapi GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=c6ecd8c3080f2f68a1195676b0db983ee13b22a7 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Test GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 UV_NO_SYNC=true UV_PYTHON=3.10 UV_RESOLUTION=lowest-direct "${CURRENT_ENV[@]}" \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=6 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=YuriiMotov GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=dont-truncate-traceback-lines GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/dont-truncate-traceback-lines GITHUB_REF_NAME=dont-truncate-traceback-lines GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=fastapi/typer GITHUB_REPOSITORY_OWNER=fastapi GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=c6ecd8c3080f2f68a1195676b0db983ee13b22a7 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Test GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 UV_NO_SYNC=true UV_PYTHON=3.10 UV_RESOLUTION=lowest-direct "${CURRENT_ENV[@]}" \
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

STEP_CONDITION=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=7 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=YuriiMotov GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=dont-truncate-traceback-lines GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/dont-truncate-traceback-lines GITHUB_REF_NAME=dont-truncate-traceback-lines GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=fastapi/typer GITHUB_REPOSITORY_OWNER=fastapi GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=c6ecd8c3080f2f68a1195676b0db983ee13b22a7 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Test GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 UV_NO_SYNC=true UV_PYTHON=3.10 UV_RESOLUTION=lowest-direct "${CURRENT_ENV[@]}" COVERAGE_FILE=coverage/.coverage.Linux-py3.10 CONTEXT=Linux-py3.10 \
echo $(test "$_GITHUB_JOB_STATUS" = "success" && echo true || echo false))
if [[ "$STEP_CONDITION" = "true" ]]; then

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_STARTED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=7 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=YuriiMotov GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=dont-truncate-traceback-lines GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/dont-truncate-traceback-lines GITHUB_REF_NAME=dont-truncate-traceback-lines GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=fastapi/typer GITHUB_REPOSITORY_OWNER=fastapi GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=c6ecd8c3080f2f68a1195676b0db983ee13b22a7 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Test GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 UV_NO_SYNC=true UV_PYTHON=3.10 UV_RESOLUTION=lowest-direct "${CURRENT_ENV[@]}" COVERAGE_FILE=coverage/.coverage.Linux-py3.10 CONTEXT=Linux-py3.10 \
bash -e $ACTIONS_RUNNER_HOOK_STEP_STARTED
   set -o allexport
   source /etc/reproducer-environment
   set +o allexport
fi

echo "##[group]"Run 'uv run bash scripts/test.sh'
echo "##[endgroup]"
echo 'uv run bash scripts/test.sh' > /home/github/71552794390/steps/bugswarm_7.sh
chmod u+x /home/github/71552794390/steps/bugswarm_7.sh


EXIT_CODE=0
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=7 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=YuriiMotov GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=dont-truncate-traceback-lines GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/dont-truncate-traceback-lines GITHUB_REF_NAME=dont-truncate-traceback-lines GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=fastapi/typer GITHUB_REPOSITORY_OWNER=fastapi GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=c6ecd8c3080f2f68a1195676b0db983ee13b22a7 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Test GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 UV_NO_SYNC=true UV_PYTHON=3.10 UV_RESOLUTION=lowest-direct "${CURRENT_ENV[@]}" COVERAGE_FILE=coverage/.coverage.Linux-py3.10 CONTEXT=Linux-py3.10 \
bash -e /home/github/71552794390/steps/bugswarm_7.sh
EXIT_CODE=$?


if [[ $EXIT_CODE != 0 ]]; then
  CONTINUE_ON_ERROR=$(env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=7 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=YuriiMotov GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=dont-truncate-traceback-lines GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/dont-truncate-traceback-lines GITHUB_REF_NAME=dont-truncate-traceback-lines GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=fastapi/typer GITHUB_REPOSITORY_OWNER=fastapi GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=c6ecd8c3080f2f68a1195676b0db983ee13b22a7 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Test GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 UV_NO_SYNC=true UV_PYTHON=3.10 UV_RESOLUTION=lowest-direct "${CURRENT_ENV[@]}" COVERAGE_FILE=coverage/.coverage.Linux-py3.10 CONTEXT=Linux-py3.10 \
echo false)
  if [[ "$CONTINUE_ON_ERROR" != "true" ]]; then 
    export _GITHUB_JOB_STATUS=failure
  fi
  echo "" && echo "##[error]Process completed with exit code $EXIT_CODE."

fi

if [[ ! -z "$ACTIONS_RUNNER_HOOK_STEP_COMPLETED" ]]; then
env CI=true GITHUB_TOKEN=DUMMY GITHUB_ACTION=7 GITHUB_ACTION_PATH='' GITHUB_ACTION_REPOSITORY='' GITHUB_ACTIONS=true GITHUB_ACTOR=YuriiMotov GITHUB_API_URL=https://api.github.com GITHUB_BASE_REF='' GITHUB_ENV=/home/github/workflow/envs.txt GITHUB_EVENT_NAME=push GITHUB_EVENT_PATH=/home/github/workflow/event.json GITHUB_GRAPHQL_URL=https://api.github.com/graphql GITHUB_HEAD_REF=dont-truncate-traceback-lines GITHUB_JOB='' GITHUB_PATH=/home/github/workflow/paths.txt GITHUB_REF=refs/heads/dont-truncate-traceback-lines GITHUB_REF_NAME=dont-truncate-traceback-lines GITHUB_REF_PROTECTED=false GITHUB_REF_TYPE=branch GITHUB_REPOSITORY=fastapi/typer GITHUB_REPOSITORY_OWNER=fastapi GITHUB_RETENTION_DAYS=0 GITHUB_RUN_ATTEMPT=1 GITHUB_RUN_ID=1 GITHUB_RUN_NUMBER=1 GITHUB_SERVER_URL=https://github.com GITHUB_SHA=c6ecd8c3080f2f68a1195676b0db983ee13b22a7 GITHUB_STEP_SUMMARY='' GITHUB_WORKFLOW=Test GITHUB_OUTPUT=/home/github/workflow/output.txt GITHUB_STATE=/home/github/workflow/state.txt RUNNER_ARCH=X64 RUNNER_NAME='Bugswarm GitHub Actions Runner' RUNNER_OS=Linux RUNNER_TEMP=/tmp RUNNER_TOOL_CACHE=/opt/hostedtoolcache RUNNER_DEBUG=1 UV_NO_SYNC=true UV_PYTHON=3.10 UV_RESOLUTION=lowest-direct "${CURRENT_ENV[@]}" COVERAGE_FILE=coverage/.coverage.Linux-py3.10 CONTEXT=Linux-py3.10 \
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
   bash -e $ACTIONS_RUNNER_HOOK_JOB_COMPLETED 71552794390 failed
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
