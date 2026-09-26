import os
import sys
import re
import shutil
import yaml
import zipfile

# from utils.utils import read_log_file
import requests
import os
import git
from git import GitDB, Repo
from utils.common import log
from utils.common.credentials import GITHUB_TOKENS, OPENAI_TOKEN
import openai

PYTHON_files = ['setup.py', 'pyproject.toml', 'requirement.txt', 'Pipfile', 'Pipefile.lock', 'environment.yml', 'tox.ini', 'pytest.ini', 'setup.cfg']



def is_archive(repo, commit):
    session = requests.session()
    session.headers = {'Authorization': 'token {}'.format(GITHUB_TOKENS[0])}
    response = session.head('https://github.com/{}/commit/{}'.format(repo, commit))

    return response.status_code != 404


def is_resettable(repo, commit, project_clone_path='project_path'):
    repo_name = repo.split('/')[-1]
    repo_path = os.path.abspath(os.path.join(project_clone_path, repo_name))

    # Clone repo
    if os.path.isdir(repo_path):
        log.info('Clone of repo {} already exists.'.format(repo))

        # Explicitly set odbt, or else Repo.iter_commits fails with a broken pipe. (I don't know why.)
        # (Possibly related: https://github.com/gitpython-developers/GitPython/issues/427)
        repo_obj = Repo(repo_path, odbt=GitDB)
    else:
        log.info('Cloning repo {}'.format(repo))
        repo_obj = Repo.clone_from('https://github.com/{}'.format(repo), repo_path, odbt=GitDB)

    # Fetch refs for all pulls and PRs
    log.info('Checking if a build is resettable...')
    try:
        repo_obj.remote('origin').fetch('refs/pull/*/head:refs/remotes/origin/pr/*')
    except Exception as e:
        log.warning('Could not fetch PR refs (some may be unavailable): {}'.format(e))
        return False

    # Get all shas — HEAD may not exist if default branch is not master
    try:
        shas = [commit.hexsha for commit in repo_obj.iter_commits(branches='', remotes='')]
    except (ValueError, Exception):
        try:
            shas = [commit.hexsha for commit in repo_obj.iter_commits('--remotes')]
        except Exception:
            return False
    return commit in shas


def clean_log_file(log_txt):
    """
    Clean log text by removing ANSI escape sequences and timestamps.
    """
    ansi_escape = re.compile(r'''
        \x1B  # ESC
        \[    # [
        [0-?]*  # 0 or more characters from 0 to ?
        [ -/]*  # 0 or more characters from space to /
        [@-~]   # 1 character from @ to ~
    ''', re.VERBOSE)

    cleaned_log_output = ansi_escape.sub('', log_txt)

    timestamp_pattern = re.compile(r'\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d+Z\s+')

    modified_log = timestamp_pattern.sub('', cleaned_log_output)
    
    return modified_log

def ask_chatgpt(query, system_message, token, model="gpt-4.1-mini"):
    # Read the OpenAI API token from a file
    # Set up the OpenAI API key
    openai.api_key = token

    # Construct the messages for the Chat Completion API
    messages = [
        {"role": "system", "content": system_message},
        {"role": "user", "content": query}
    ]

    # Call the OpenAI API for chat completion
    response = openai.ChatCompletion.create(
        model=model,
        messages=messages,
        temperature=0
    )

    # Extract and return the content of the assistant's response
    return response["choices"][0]["message"]["content"]

    

def read_log_file(file_path):
    with open(file_path, 'r') as file:
        log = file.read()
        
    log = clean_log_file(log)
    return log

# def git_clone_to_folder(project_clone_path, owner, branch, commit_sha):
#     try:
#         if not os.path.exists(project_clone_path):
#             os.makedirs(project_clone_path)
#         log.info('cloning repo... {}'.format(owner.split('/')[-1]))
#         repo = git.Repo.clone_from(
#             'https://github.com/{}'.format(owner), 
#             '{}/{}'.format(project_clone_path, owner.split('/')[-1]), odbt=git.GitDB
#         )
#         log.info('cloning done')
#         if branch:
#             log.info(f'Checking out to the branch {branch}')
#             try:
#                 repo.git.fetch('--all')  # Fetch all remote refs
#                 repo.git.checkout(branch)
#                 log.info(f'Checked out to branch {branch}')
#             except git.exc.GitCommandError:
#                 log.info(f'Branch {branch} not found locally, trying to check out from origin...')
#                 try:
#                     repo.git.checkout(f'origin/{branch}', b=branch)
#                 except Exception as e:
#                     log.error(f'Failed to check out branch: {branch}')
#                     raise e
#         if commit_sha:
#             log.info(f'Resetting to commit {commit_sha}')
#             repo.git.reset('--hard', commit_sha)
#             log.info(f'Reset to {commit_sha}')
#     except Exception as e:
#         log.info("Repo already cloned ")
#         log.info(e)
        
def download_and_overlay_repo(project_clone_path, owner, repo_name, commit_sha, repo_dir):
    """
    Fallback when the commit SHA is no longer reachable via git fetch.
    Downloads the archive ZIP from GitHub, overlays its contents onto repo_dir
    (preserving the .git dir), then makes a dummy commit so git diff works.
    Mirrors setup_repo.py download_repo() logic.
    """
    zip_path = os.path.join(project_clone_path, '{}-{}.zip'.format(repo_name, commit_sha[:7]))
    extract_dir = os.path.join(project_clone_path, '_archive_tmp_{}'.format(commit_sha[:7]))

    try:
        log.info('SHA not reachable via git. Downloading archive for {}/{} at {}'.format(
            owner, repo_name, commit_sha))
        download_github_zip(owner, repo_name, commit_sha, zip_path)

        os.makedirs(extract_dir, exist_ok=True)
        unzip_file(zip_path, extract_dir)

        # GitHub archive layouts:
        #   archive/<sha>.zip  -> "<repo_name>-<full_sha>/"
        #   API zipball/<sha>  -> "<owner>-<repo_name>-<short_sha>/"
        # Either way, the inner dir name embeds <repo_name> and the SHA, so we
        # verify both before trusting the extracted content.
        extracted_entries = [
            e for e in os.listdir(extract_dir)
            if os.path.isdir(os.path.join(extract_dir, e))
        ]
        if not extracted_entries:
            raise Exception('Archive extraction produced no output in {}'.format(extract_dir))

        expected_archive_name = '{}-{}'.format(repo_name, commit_sha)
        short_sha = commit_sha[:7]
        match = next(
            (e for e in extracted_entries
             if e == expected_archive_name
             or (repo_name in e and (commit_sha in e or short_sha in e))),
            None,
        )
        if match is None:
            raise Exception(
                'Archive for {}/{} at {} extracted unexpected dirs {!r}; '
                'none reference repo+SHA. Refusing to overlay to avoid using wrong content.'.format(
                    owner, repo_name, commit_sha, extracted_entries))
        extracted_repo_dir = os.path.join(extract_dir, match)
        log.info('Using extracted directory: {}'.format(match))

        # Backup .git, wipe repo_dir, copy archive contents, restore .git
        git_backup = os.path.join(project_clone_path, '.git_backup_{}'.format(commit_sha[:7]))
        shutil.copytree(os.path.join(repo_dir, '.git'), git_backup)
        shutil.rmtree(repo_dir)
        shutil.copytree(extracted_repo_dir, repo_dir)
        shutil.copytree(git_backup, os.path.join(repo_dir, '.git'))

        # Stage everything and make a dummy commit so git diff reflects the SHA
        repo = git.Repo(repo_dir)
        repo.git.add(all=True)
        repo.git.commit(
            '--allow-empty',
            message='Dummy commit reflecting sha {}'.format(commit_sha)
        )
        log.info('Archive overlay complete for SHA {}'.format(commit_sha))
        return repo

    finally:
        if os.path.exists(zip_path):
            os.remove(zip_path)
        if os.path.exists(extract_dir):
            shutil.rmtree(extract_dir)
        git_backup = os.path.join(project_clone_path, '.git_backup_{}'.format(commit_sha[:7]))
        if os.path.exists(git_backup):
            shutil.rmtree(git_backup)


def git_clone_to_folder(project_clone_path, owner_repo, branch, commit_sha=None):
    parts = owner_repo.split('/')
    if len(parts) != 2 or not all(parts):
        raise ValueError(
            "owner_repo must be in 'owner/repo' format, got {!r}".format(owner_repo))
    owner_name, repo_name = parts
    repo_dir = os.path.join(project_clone_path, repo_name)

    def _clone_fresh():
        os.makedirs(project_clone_path, exist_ok=True)
        log.info('Cloning repo {}'.format(owner_repo))
        return git.Repo.clone_from(
            'https://github.com/{}'.format(owner_repo),
            repo_dir, odbt=git.GitDB
        )

    # --- Clone if not already present, or re-clone if existing dir is not a valid repo ---
    if not os.path.exists(repo_dir):
        repo = _clone_fresh()
    else:
        try:
            repo = git.Repo(repo_dir, odbt=git.GitDB)
            log.info('Repo already cloned {}'.format(owner_repo))
        except (git.exc.InvalidGitRepositoryError, git.exc.NoSuchPathError):
            log.info('Existing path {} is not a valid git repo; removing and re-cloning'.format(repo_dir))
            shutil.rmtree(repo_dir)
            repo = _clone_fresh()

    # --- Checkout branch (best-effort; SHA reset below is the authoritative step) ---
    if branch:
        try:
            repo.git.fetch('--all')
            try:
                repo.git.checkout(branch)
                log.info('Checked out branch {}'.format(branch))
            except git.exc.GitCommandError:
                log.info('Branch {} not found locally, trying origin...'.format(branch))
                repo.git.checkout('-b', branch, 'origin/{}'.format(branch))
                log.info('Checked out branch {} from origin'.format(branch))
        except git.exc.GitCommandError as e:
            log.info('Failed to check out branch {}. Will rely on SHA reset.'.format(branch))
            log.info(e)

    # --- Reset to the specific commit SHA ---
    if commit_sha:
        resettable = False

        # Check locally first to avoid a slow/hanging fetch on large repos
        try:
            repo.git.cat_file('-e', '{}^{{commit}}'.format(commit_sha))
            sha_local = True
        except git.exc.GitCommandError:
            sha_local = False

        if sha_local:
            log.info('SHA {} found locally, resetting directly'.format(commit_sha))
            try:
                repo.git.reset('--hard', commit_sha)
                resettable = True
            except git.exc.GitCommandError as e:
                log.info('Local reset failed: {}'.format(e))

        if not resettable:
            log.info('SHA {} not in local history, fetching from remote'.format(commit_sha))
            try:
                repo.remote().fetch(commit_sha)
                repo.head.reset(commit_sha, index=True, working_tree=True)
                resettable = True
            except git.exc.GitCommandError:
                log.info('fetch failed for SHA {}. Will download archive.'.format(commit_sha))

        if not resettable:
            # SHA is gone from the remote — download from GitHub archive (like download_repo in setup_repo.py)
            repo = download_and_overlay_repo(
                project_clone_path, owner_name, repo_name, commit_sha, repo_dir)

    try:
        repo.git.submodule('update', '--init', '--recursive')
    except git.exc.GitCommandError as e:
        log.warning('Submodule update failed (some submodules may be missing): {}'.format(e))
                
def get_pr_from_original_log(log_path):
        if os.path.isfile(log_path):
            try:
                with open(log_path, 'r') as file:
                    for i, line in enumerate(file):
                        match = re.search(r'Job defined at: .*@.*/(\d+)/merge', line, re.M)
                        if match:
                            return match.group(1)
                        if i >= 4:
                            # Only check the first 5 lines.
                            break
            except FileNotFoundError:
                pass
        return None


def get_pr_merge_from_original_log(log_path):
    """
    Detect a GitHub Actions PR build directly from the actions/checkout step's
    'HEAD is now at <short> Merge <head_sha> into <base_sha>' line. Returns
    {"head_sha": ..., "base_sha": ...} when found, else None. The short merge
    sha isn't returned because hashes won't match locally — we recreate the
    merge from base + head instead.
    """
    if not os.path.isfile(log_path):
        return None
    try:
        with open(log_path, 'r') as file:
            for line in file:
                m = re.search(
                    r'HEAD is now at\s+[0-9a-f]{7,40}\s+Merge\s+([0-9a-f]{40})\s+into\s+([0-9a-f]{40})',
                    line,
                )
                if m:
                    return {"head_sha": m.group(1), "base_sha": m.group(2)}
    except OSError:
        pass
    return None

def get_pr_shas(owner, repo, pr_number, token):
    url = f"https://api.github.com/repos/{owner}/{repo}/pulls/{pr_number}"

    headers = {
        "Authorization": f"Bearer {token}",
        "Accept": "application/vnd.github+json"
    }

    response = requests.get(url, headers=headers)

    if response.status_code != 200:
        raise Exception(f"GitHub API error: {response.status_code} - {response.text}")

    data = response.json()

    return {
        "merge_sha": data.get("merge_commit_sha"),   # None if not merged
        "head_sha": data["head"]["sha"],
        "base_sha": data["base"]["sha"]
    }
                
def reset_repo(project_clone_path, log_path, owner, head_sha):
    pr_merge = get_pr_merge_from_original_log(log_path)
    pr = None if pr_merge else get_pr_from_original_log(log_path)
    repo = git.Repo(project_clone_path)

    # Track what HEAD should look like after the reset so we can verify it.
    expected_head_sha = None        # exact SHA HEAD must equal
    expected_merge_parents = None   # (base_sha, head_sha) when HEAD is a merge commit

    if pr_merge is not None:
        # GitHub Actions PR build: original CI ran the merge of head into base.
        # Recreate that locally so the tested tree matches what CI tested.
        pr_head = pr_merge["head_sha"]
        pr_base = pr_merge["base_sha"]
        log.info('Detected PR merge from log: head={} base={}. Recreating merge locally.'.format(
            pr_head, pr_base))
        repo.remote().fetch(pr_head)
        repo.remote().fetch(pr_base)
        repo.head.reset(pr_base, index=True, working_tree=True)
        # Use a synthetic identity so the merge succeeds even without user.* config.
        repo.git.merge(
            pr_head, '--no-ff',
            '-m', 'Merge {} into {}'.format(pr_head, pr_base),
            env={'GIT_AUTHOR_NAME': 'CI', 'GIT_AUTHOR_EMAIL': 'ci@local',
                 'GIT_COMMITTER_NAME': 'CI', 'GIT_COMMITTER_EMAIL': 'ci@local'},
        )
        expected_merge_parents = (pr_base, pr_head)
    elif pr is None:
        # Non-PR build: reset directly to the head SHA
        log.info('Resetting to head SHA {}'.format(head_sha))
        repo.remote().fetch(head_sha)
        repo.head.reset(head_sha, index=True, working_tree=True)
        expected_head_sha = head_sha
    else:
        shas = get_pr_shas(owner.split('/')[0], owner.split('/')[-1], int(pr), GITHUB_TOKENS[0])
        merge_sha = shas["merge_sha"]
        base_sha = shas["base_sha"]

        # merge_sha is None when the PR was never merged — skip straight to fallback
        if merge_sha:
            try:
                log.info('Resetting to merge SHA {}'.format(merge_sha))
                repo.remote().fetch(merge_sha)
                repo.head.reset(merge_sha, index=True, working_tree=True)
                expected_head_sha = merge_sha
            except git.GitCommandError:
                log.info('Cannot reset to merge SHA. Falling back to base+head.')
                merge_sha = None  # fall through to the base+head block below

        if not merge_sha:
            # Fallback: reset to the base SHA and merge the head SHA
            log.info('Resetting to base {} and merging head {}'.format(base_sha, head_sha))
            repo.remote().fetch(head_sha)
            repo.remote().fetch(base_sha)
            repo.head.reset(base_sha, index=True, working_tree=True)
            repo.git.merge(head_sha)
            expected_merge_parents = (base_sha, head_sha)

    # Verify the reset actually landed where we expected. Without this check,
    # a silently-failing reset leaves HEAD on the default branch and the run
    # uses code from a different commit than the original CI.
    actual_head = repo.head.commit.hexsha
    if expected_head_sha is not None:
        if actual_head != expected_head_sha:
            raise RepoSetupError(
                'reset_repo: HEAD is {} but expected {} for {}'.format(
                    actual_head, expected_head_sha, owner))
    elif expected_merge_parents is not None:
        parents = tuple(p.hexsha for p in repo.head.commit.parents)
        if set(expected_merge_parents) - set(parents):
            raise RepoSetupError(
                'reset_repo: HEAD {} parents {} do not include expected base+head {} for {}'.format(
                    actual_head, parents, expected_merge_parents, owner))

    try:
        repo.git.submodule('update', '--init')
    except git.exc.GitCommandError as e:
        log.warning('Submodule update failed (some submodules may be missing): {}'.format(e))


def setup_repo(repo, head_sha, original_log_path, project_clone_path='project_path', cloned_repos=None):
    """
    Replicates BugSwarm setup_repo logic for a single-threaded pipeline.

    Steps:
      1. Clone the repo if not already present; skip if a previous clone attempt failed.
      2. Detect PR from original log; resolve merge/base/head SHAs.
      3. If resettable: reset to merge_sha (PR) or head_sha (push), with fallback.
      4. If not resettable: download GitHub archive and overlay.
      5. Update submodules.

    Args:
        repo: 'owner/repo_name' string
        head_sha: commit SHA from the CI job
        original_log_path: path to the original CI log (used to detect PR number)
        project_clone_path: root directory for cloned repos (default 'project_path')
        cloned_repos: dict tracking clone outcomes {repo: 1=ok, -1=failed} (shared across calls)

    Returns:
        repo_dir path on success.

    Raises:
        RepoSetupError on unrecoverable failure.
    """
    if cloned_repos is None:
        cloned_repos = {}

    owner = repo.split('/')[0]
    repo_name = repo.split('/')[-1]
    repo_dir = os.path.join(project_clone_path, repo_name)

    # --- 1. Clone (skip if previously failed) ---
    if cloned_repos.get(repo) == -1:
        raise RepoSetupError('Previously failed to clone {}. Skipping.'.format(repo))

    if cloned_repos.get(repo) != 1:
        try:
            if os.path.isdir(repo_dir):
                log.info('Repo {} already cloned.'.format(repo))
                git.Repo(repo_dir, odbt=git.GitDB)
            else:
                log.info('Cloning repo {}'.format(repo))
                os.makedirs(project_clone_path, exist_ok=True)
                cloned = git.Repo.clone_from(
                    'https://github.com/{}'.format(repo), repo_dir, odbt=git.GitDB
                )
                with cloned.config_writer('repository') as cw:
                    cw.add_section('user')
                    cw.set('user', 'name', 'LLM4Build')
                    cw.set('user', 'email', 'llm4build@local')
            cloned_repos[repo] = 1
        except Exception as e:
            cloned_repos[repo] = -1
            raise RepoSetupError('Failed to clone {}: {!r}'.format(repo, e))

    # --- 2. Detect PR and resolve SHAs ---
    pr_number = get_pr_from_original_log(original_log_path)
    merge_sha = None
    base_sha = None

    if pr_number:
        try:
            shas = get_pr_shas(owner, repo_name, int(pr_number), GITHUB_TOKENS[0])
            merge_sha = shas.get('merge_sha')
            base_sha  = shas.get('base_sha')
            log.info('PR #{}: merge_sha={} base_sha={} head_sha={}'.format(
                pr_number, merge_sha, base_sha, head_sha))
        except Exception as e:
            log.warning('Could not fetch PR SHAs for PR #{}: {}'.format(pr_number, e))

    # --- 3 & 4. Reset or download ---
    repo_obj = git.Repo(repo_dir, odbt=git.GitDB)

    if is_resettable(repo, head_sha, project_clone_path):
        if pr_number and merge_sha:
            # PR job: try merge SHA first
            try:
                log.info('Resetting to merge SHA {}'.format(merge_sha))
                repo_obj.remote().fetch(merge_sha)
                repo_obj.head.reset(merge_sha, index=True, working_tree=True)
            except git.GitCommandError:
                # Fallback: reset to base and merge head
                log.info('merge SHA failed. Resetting to base {} and merging head {}'.format(base_sha, head_sha))
                repo_obj.remote().fetch(head_sha)
                repo_obj.remote().fetch(base_sha)
                repo_obj.head.reset(base_sha, index=True, working_tree=True)
                repo_obj.git.merge(head_sha)
        else:
            # Push job: reset directly to head SHA
            log.info('Resetting to head SHA {}'.format(head_sha))
            try:
                repo_obj.git.cat_file('-e', '{}^{{commit}}'.format(head_sha))
                repo_obj.git.reset('--hard', head_sha)
            except git.GitCommandError:
                repo_obj.remote().fetch(head_sha)
                repo_obj.head.reset(head_sha, index=True, working_tree=True)
    else:
        log.info('SHA {} not resettable. Downloading archive.'.format(head_sha))
        target_sha = merge_sha if (pr_number and merge_sha) else head_sha
        download_and_overlay_repo(project_clone_path, owner, repo_name, target_sha, repo_dir)

    # --- 5. Submodules ---
    try:
        repo_obj = git.Repo(repo_dir, odbt=git.GitDB)
        repo_obj.git.submodule('update', '--init')
    except git.GitCommandError as e:
        log.warning('Submodule update failed: {}'.format(e))

    log.info('Repo {} set up at {}'.format(repo, repo_dir))
    return repo_dir


class RepoSetupError(Exception):
    pass


def extract_workflow_name(file_path):
    try:
        with open(file_path, 'r') as f:
            data = yaml.safe_load(f)
            if not isinstance(data, dict):
                return None
            return data.get('name')
    except Exception as e:
        print(f"Error reading {file_path}: {e}")
        return None

def read_yaml_file(file_path):
    try:
        with open(file_path, 'r') as f:
            data = yaml.safe_load(f)
            return data
    except Exception as e:
        print(f"Failed to read YAML file {file_path}: {e}")
        return None

def find_correct_yaml_file(project_clone_path, repo_name, w_name):
    workflows_dir = os.path.join(project_clone_path, repo_name, ".github", "workflows")
    yaml_files = []
    if os.path.isdir(workflows_dir):
        for file in os.listdir(workflows_dir):
            if file.endswith('.yml') or file.endswith('.yaml'):
                yaml_files.append(os.path.join(workflows_dir, file))

    for file in yaml_files:
        workflow_name = extract_workflow_name(file)
        if str(workflow_name) == w_name:
            return file
    return None

def find_yaml_by_job_key(project_clone_path, repo_name, job_name_specific):
    """Fallback: match workflow YAML by job key when workflow name is dynamic."""
    # job_name_specific is e.g. 'build-and-test / cmake-linux-x86_64'
    job_key = job_name_specific.split(' / ')[0].strip()
    workflows_dir = os.path.join(project_clone_path, repo_name, ".github", "workflows")
    if not os.path.isdir(workflows_dir):
        return None

    candidates = []
    for filename in os.listdir(workflows_dir):
        if not (filename.endswith('.yml') or filename.endswith('.yaml')):
            continue
        filepath = os.path.join(workflows_dir, filename)
        try:
            with open(filepath, 'r') as f:
                data = yaml.safe_load(f)
            if not isinstance(data, dict):
                continue
            jobs = data.get('jobs', {})
            if not isinstance(jobs, dict):
                continue
            # Exact job key match
            if job_key in jobs:
                return filepath
            # Fuzzy: job key appears as substring of any job key in YAML
            for k in jobs:
                if job_key.lower() in k.lower() or k.lower() in job_key.lower():
                    return filepath
            # Fuzzy: any word from job_name_specific matches a job key
            words = set(re.sub(r'[^\w]', ' ', job_name_specific.lower()).split())
            for k in jobs:
                if set(re.sub(r'[^\w]', ' ', k.lower()).split()) & words:
                    candidates.append(filepath)
                    break
        except Exception:
            continue

    # Return first fuzzy candidate if no exact match found
    return candidates[0] if candidates else None

def find_readme_file(repo_path):
    try:
        for fname in os.listdir(repo_path):
            if fname.lower().startswith("readme") or fname.lower().endswith("readme"):
                full_path = os.path.join(repo_path, fname)
                if os.path.isfile(full_path):
                    return full_path
    except Exception as e:
        print(f"Error accessing {repo_path}: {e}")

    return None

def find_all_docker_files(repo_path):
    docker_files = []
    try:
        for dirpath, _, filenames in os.walk(repo_path):
            for filename in filenames:
                if 'dockerfile' in filename.lower():
                    docker_files.append(os.path.join(dirpath, filename))
    except Exception as e:
        print(f"Error accessing {repo_path}: {e}")

    return docker_files

def get_directory_structure(root_path):
    if not os.path.isdir(root_path):
        raise ValueError(f"{root_path} is not valid directory")
    
    return {os.path.basename(root_path): build_tree(root_path)}
    
def build_tree(path):
    tree = {}
    for entry in sorted(os.listdir(path)):
        full_path = os.path.join(path, entry)
        if os.path.islink(full_path):
            tree[entry] = None
        elif os.path.isdir(full_path):
            tree[entry] = build_tree(full_path)
        else:
            tree[entry] = None
    return tree

def tree_to_string(tree, indent=''):
    lines = []
    total = len(tree)
    for i, (key, value) in enumerate(tree.items()):
        is_last = (i == total - 1)
        connector = '└-- ' if is_last else '|-- '
        lines.append(indent + connector + key)
        if isinstance(value, dict):
            new_indent = indent + ('    ' if is_last else '│   ')
            lines.extend(tree_to_string(value, new_indent))
    return lines

def get_directory_tree_as_string(path):
    structure = get_directory_structure(path)
    lines = tree_to_string(structure)
    return '\n'.join(lines)

def call_openai(prompt, model="gpt-4o"):
    openai.api_key = OPENAI_TOKEN
    response = openai.ChatCompletion.create(
        model=model,
        messages=[{"role": "user", "content": prompt}],
        temperature=0.0
    )
    return response['choices'][0]['message']['content']

def download_github_zip(owner: str, repo: str, commit_sha: str, output_file: str) -> None:
    # Try authenticated API endpoint first (works for archived/inaccessible commits)
    token = GITHUB_TOKENS[0] if GITHUB_TOKENS else None
    headers = {"Authorization": f"token {token}"} if token else {}
    api_url = f"https://api.github.com/repos/{owner}/{repo}/zipball/{commit_sha}"
    response = requests.get(api_url, headers=headers, stream=True, allow_redirects=True)

    if response.status_code != 200:
        # Fall back to public archive URL
        url = f"https://github.com/{owner}/{repo}/archive/{commit_sha}.zip"
        response = requests.get(url, stream=True)

    if response.status_code != 200:
        print("no download")
        raise Exception(f"Failed to download zip: {response.status_code} {response.reason}")

    with open(output_file, "wb") as f:
        for chunk in response.iter_content(chunk_size=8192):
            f.write(chunk)

    print(f"ZIP file downloaded: {output_file}")
    
def unzip_file(zip_path: str, extract_to: str = "project_path") -> None:
    if not os.path.exists(zip_path):
        raise FileNotFoundError(f"ZIP file not found: {zip_path}")

    with zipfile.ZipFile(zip_path, 'r') as zip_ref:
        zip_ref.extractall(extract_to)
        print(f"Extracted '{zip_path}' to '{extract_to}'")



def find_path_in_tree(tree, target_name, current_path=""):
    """Recursively search the tree for the target and return its full path."""
    for name, subtree in tree.items():
        new_path = os.path.join(current_path, name)

        if name == target_name:
            return new_path

        if isinstance(subtree, dict):
            result = find_path_in_tree(subtree, target_name, new_path)
            if result:
                return result

    return None


def find_dict_by_key(data, target_key):
    if not isinstance(data, dict):
        return None

    for key, value in data.items():
        if key == target_key and isinstance(value, dict):
            return value
        elif isinstance(value, dict):
            result = find_dict_by_key(value, target_key)
            if result:
                return result
        elif isinstance(value, list):
            for item in value:
                if isinstance(item, dict):
                    result = find_dict_by_key(item, target_key)
                    if result:
                        return result
    return None


# if __name__ == '__main__':
#     path = sys.argv[1]
#     target = sys.argv[2]
#     tree_str = get_directory_tree_as_string(path)
#     tree = get_directory_structure(path)
#     structure = get_directory_structure(path)
#     all_paths = []
#     for file in PYTHON_files:
#         full_path = find_path_in_tree(structure, file)
#         if full_path is not None:
#             all_paths.append(full_path)
            
#     full_path = find_path_in_tree(tree, target)

#     if full_path:
#         print(f"Found: {full_path}")
#     else:
#         print(f"{target} not found.")
#     print(tree_str)
#     print("\n".join(all_paths))

"""
def clone_project_repo_if_not_exists(utils, job):
    if not utils.check_if_project_repo_exist(job.repo):
        os.makedirs(utils.get_repo_storage_dir(job), exist_ok=True)
        git.Repo.clone_from(utils.construct_github_repo_url(job.repo), utils.get_repo_storage_dir(job))
        repo = git.Repo(utils.get_repo_storage_dir(job))
        with repo.config_writer('repository') as cw:
            cw.add_section('user')
            cw.set('user', 'name', 'BugSwarm')
            cw.set('user', 'email', 'dev.bugswarm@gmail.com')

    with tarfile.open(utils.get_project_storage_repo_tar_path(job), 'w') as tar:
        tar.add(utils.get_repo_storage_dir(job), arcname=job.repo)


def copy_and_reset_repo(job, utils):
    log.info('Copying and resetting the repository.')
    retry_count = 0
    max_retries = 3
    last_error = None

    while True:
        if retry_count > max_retries:
            raise RepoSetupError('Max retries exceeded for untarring repo {}: {}.'.format(job.repo, repr(last_error)))

        try:
            # Copy repository from stored project repositories to the workspace repository directory by untar-ing the
            # storage repository tar file into the workspace directory.
            repo_tar_obj = tarfile.TarFile(name=utils.get_project_storage_repo_tar_path(job))
            utils.clean_workspace_job_dir(job)
            # TODO: This line causes missing or bad subsequent header
            repo_tar_obj.extractall(utils.get_workspace_sha_dir(job))
            break
        except Exception as e:
            last_error = e
            log.info('Failed to extract the repository due to {}'.format(repr(e)))
            retry_count += 1
            time.sleep(5)
            continue

    # git reset the workspace repository.
    repo = git.Repo(utils.get_reproducing_repo_dir(job))

    if job.is_pr:
        # We're in a PR job pair; reset to the merge SHA
        try:
            # git fetch origin <merge-sha>
            # git reset --hard <merge-sha>
            log.info('Resetting to merge SHA {}'.format(job.travis_merge_sha))
            repo.remote().fetch(job.travis_merge_sha)
            repo.head.reset(job.travis_merge_sha, index=True, working_tree=True)
        except git.GitCommandError:
            # Fallback: reset to the  base SHA and merge the head SHA
            # git fetch origin <head-sha>
            # git fetch origin <base-sha>
            # git reset --hard <base-sha>
            # git merge <head-sha>
            log.info('Cannot reset to merge SHA. Resetting to base {} and merging head {}'.format(
                job.base_sha, job.sha))
            repo.remote().fetch(job.sha)
            repo.remote().fetch(job.base_sha)
            repo.head.reset(job.base_sha, index=True, working_tree=True)
            repo.git.merge(job.sha)
    else:
        # git fetch origin <head-sha>
        # git reset --hard <head-sha>
        log.info('Resetting to head SHA {}'.format(job.sha))
        repo.remote().fetch(job.sha)
        repo.head.reset(job.sha, index=True, working_tree=True)

    # Check out all the submodules.
    repo.git.submodule('update', '--init')


def download_repo(job, utils):
    # Make the workspace repository directory.
    # Note: We have no way to check out the correct version of submodule!
    job_archive_dir = utils.get_stored_repo_archives_path(job)
    repo_untar_name = utils.get_job_archive_extracted_filename(job)
    repo_tar_path = utils.get_project_storage_repo_archive_path(job)
    target_sha = job.travis_merge_sha if job.is_pr else job.sha

    os.makedirs(job_archive_dir, exist_ok=True)
    retry_count = 0
    max_retries = 3
    last_error = None

    while True:
        if retry_count > max_retries:
            raise RepoSetupError(
                'Max retries exceeded for downloading tar.gz file for repo {}: {}.'.format(job.repo, last_error))

        try:
            # Download the repository.
            if not os.path.exists(repo_tar_path):
                src = utils.construct_github_archive_repo_sha_url(job.repo, target_sha)
                log.debug('Downloading the repository from the GitHub archive at {}.'.format(src))
                urllib.request.urlretrieve(src, repo_tar_path)

            # Copy repository from stored project repositories to the workspace repository directory by
            # untar-ing the storage repository tar file into the workspace directory.
            with tarfile.open(repo_tar_path) as repo_tar_obj:
                repo_tar_obj.extractall(job_archive_dir)
            break
        except Exception as e:
            last_error = e
            log.info('Failed to download the repository due to {}'.format(repr(e)))
            retry_count += 1

            if os.path.exists(repo_tar_path):
                os.remove(repo_tar_path)
            time.sleep(5)
            continue

    distutils.dir_util.copy_tree(os.path.join(job_archive_dir, repo_untar_name),
                                 utils.get_reproducing_repo_dir(job))

    # Copy the .git dir so we're still in a git repository
    distutils.dir_util.copy_tree(os.path.join(utils.get_repo_storage_dir(job), '.git'),
                                 os.path.join(utils.get_reproducing_repo_dir(job), '.git'))

    # Make a commit so "git diff" outputs what you'd expect
    # Slight inconsistency: if the repo has `.git_archival.txt` in the root, that will differ from the version in the
    # actual commit. Unavoidable when downloading repo archives, unfortunately.
    repo = git.Repo(utils.get_reproducing_repo_dir(job))
    repo.git.add(all=True)
    repo.git.commit(message='Dummy commit reflecting sha {}'.format(target_sha))
    
    def get_pr_from_original_log(self, job) -> Optional[str]:
        if os.path.isfile(self.get_orig_log_path(job.job_id)):
            try:
                with open(self.get_orig_log_path(job.job_id), 'r') as file:
                    for i, line in enumerate(file):
                        match = re.search(r'Job defined at: .*@.*/(\d+)/merge', line, re.M)
                        if match:
                            return match.group(1)
                        if i >= 4:
                            # Only check the first 5 lines.
                            break
            except FileNotFoundError:
                pass
        return None

    def get_job_image_from_original_log(self, job_id: int) -> Optional[str]:
        if os.path.isfile(self.get_orig_log_path(job_id)):
            try:
                with open(self.get_orig_log_path(job_id), 'r') as file:
                    is_runner_image_group = False

                    for i, line in enumerate(file):
                        if len(line) <= 29:
                            # Timestamp
                            continue

                        log_line = line[29:]
                        if is_runner_image_group:
                            match = re.search(r'(Image|Environment): (\S+)', log_line, re.M)
                            if match:
                                return match.group(2)
                            else:
                                return None
                        elif log_line.startswith('##[group]Runner Image'):
                            # New group name
                            is_runner_image_group = True
                        elif log_line.startswith('##[group]Virtual Environment'):
                            # Old group name
                            is_runner_image_group = True

            except FileNotFoundError:
                pass
        return None
        
def download_and_overlay_repo(project_clone_path, owner, repo_name, commit_sha, repo_dir):
    
    Fallback when the commit SHA is no longer reachable via git fetch.
    Downloads the archive ZIP from GitHub, overlays its contents onto repo_dir
    (preserving the .git dir), then makes a dummy commit so git diff works.
    Mirrors setup_repo.py download_repo() logic.
    zip_path = os.path.join(project_clone_path, '{}-{}.zip'.format(repo_name, commit_sha[:7]))
    extract_dir = os.path.join(project_clone_path, '_archive_tmp_{}'.format(commit_sha[:7]))

    try:
        log.info('SHA not reachable via git. Downloading archive for {}/{} at {}'.format(
            owner, repo_name, commit_sha))
        download_github_zip(owner, repo_name, commit_sha, zip_path)

        os.makedirs(extract_dir, exist_ok=True)
        unzip_file(zip_path, extract_dir)

        # GitHub extracts as "<repo_name>-<full_commit_sha>/"  e.g. "flask-abc1234.../"
        expected_name = '{}-{}'.format(repo_name, commit_sha)
        extracted_entries = os.listdir(extract_dir)
        if not extracted_entries:
            raise Exception('Archive extraction produced no output in {}'.format(extract_dir))
        # Match by expected name first, fall back to first entry
        match = next((e for e in extracted_entries if e == expected_name), extracted_entries[0])
        extracted_repo_dir = os.path.join(extract_dir, match)
        log.info('Using extracted directory: {}'.format(match))

        # Backup .git (and .github if present), wipe repo_dir, copy archive contents, restore both
        git_backup    = os.path.join(project_clone_path, '.git_backup_{}'.format(commit_sha[:7]))
        github_backup = os.path.join(project_clone_path, '.github_backup_{}'.format(commit_sha[:7]))
        shutil.copytree(os.path.join(repo_dir, '.git'), git_backup)
        github_src = os.path.join(repo_dir, '.github')
        if os.path.isdir(github_src):
            shutil.copytree(github_src, github_backup)
        shutil.rmtree(repo_dir)
        shutil.copytree(extracted_repo_dir, repo_dir)
        shutil.copytree(git_backup, os.path.join(repo_dir, '.git'))

        # If archive didn't include .github, restore it from the pre-wipe backup
        if not os.path.isdir(os.path.join(extracted_repo_dir, '.github')):
            if os.path.isdir(github_backup):
                shutil.copytree(github_backup, os.path.join(repo_dir, '.github'))
                log.info('.github not in archive — restored from clone')

        # Stage everything and make a dummy commit so git diff reflects the SHA
        repo = git.Repo(repo_dir)
        repo.git.add(all=True)
        repo.git.commit(
            '--allow-empty',
            message='Dummy commit reflecting sha {}'.format(commit_sha)
        )
        log.info('Archive overlay complete for SHA {}'.format(commit_sha))
        return repo

    finally:
        if os.path.exists(zip_path):
            os.remove(zip_path)
        if os.path.exists(extract_dir):
            shutil.rmtree(extract_dir)
        git_backup = os.path.join(project_clone_path, '.git_backup_{}'.format(commit_sha[:7]))
        if os.path.exists(git_backup):
            shutil.rmtree(git_backup)
        github_backup = os.path.join(project_clone_path, '.github_backup_{}'.format(commit_sha[:7]))
        if os.path.exists(github_backup):
            shutil.rmtree(github_backup)

"""