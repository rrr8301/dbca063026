import sys
import os
import logging
import subprocess
import shutil
import yaml

from utils.common import log
from utils.common.credentials import GITHUB_TOKENS
from utils.common.github_wrapper import GitHubWrapper
from utils.utils import git_clone_to_folder, reset_repo
from utils.log_downloader import download_log
from job import generate_input_file, find_dict_by_key

PROJECT_CLONE_PATH = 'project_path'
OUTPUT_DIR = 'act_output'  # default when no argument given


def get_job_and_run_info(repo, job_id, github_wrapper):
    """Fetch job + run metadata from GitHub API."""
    status, job_data = github_wrapper.get(
        f'https://api.github.com/repos/{repo}/actions/jobs/{job_id}'
    )
    if status is None or not status.ok:
        raise RuntimeError(f'Failed to get job info for job_id={job_id}')

    run_id = job_data['run_id']
    job_name = job_data['name']   # display name; may include matrix info

    status, run_data = github_wrapper.get(
        f'https://api.github.com/repos/{repo}/actions/runs/{run_id}'
    )
    if status is None or not status.ok:
        raise RuntimeError(f'Failed to get run info for run_id={run_id}')

    return {
        'run_id':        run_data['id'],
        'job_name':      job_name,
        'head_sha':      run_data['head_sha'],
        'head_branch':   run_data['head_branch'],
        'workflow_path': run_data['path'],   # e.g. '.github/workflows/ci.yml'
        'event':         run_data['event'],  # e.g. 'push', 'pull_request'
    }


def get_matrix_flags(repo, job_id):
    """Return --matrix key:value flags for act based on the job's matrix config."""
    try:
        json_file = generate_input_file(repo, job_id)
    except SystemExit:
        return []

    failed_config = json_file['failed_build']['jobs'][0]['config']
    passed_config = json_file['passed_build']['jobs'][0]['config']

    matrix = find_dict_by_key(failed_config, 'matrix')
    if not matrix:
        matrix = find_dict_by_key(passed_config, 'matrix')

    flags = []
    for key, value in matrix.items():
        flags += ['--matrix', f'{key}:{value}']
    return flags


def find_job_key(project_path, workflow_path, job_display_name):
    """Find the YAML job key matching a GitHub API display name.

    Tries three strategies in order:
      1. Exact match on job key == display name
      2. Job key is a substring of display name or vice-versa
      3. Any word overlap between display name and job key
    Returns the best matching job key, or None.
    """
    full_wf_path = os.path.join(project_path, workflow_path.lstrip('/'))
    if not os.path.isfile(full_wf_path):
        return None
    try:
        with open(full_wf_path) as f:
            data = yaml.safe_load(f)
        jobs = data.get('jobs', {}) if isinstance(data, dict) else {}
        if not isinstance(jobs, dict):
            return None

        dn = job_display_name.lower()
        # 1. Exact
        if job_display_name in jobs:
            return job_display_name
        # 2. Substring
        for key in jobs:
            kl = key.lower()
            if kl in dn or dn in kl:
                return key
        # 3. Word overlap
        import re as _re
        dn_words = set(_re.sub(r'[^\w]', ' ', dn).split())
        for key in jobs:
            kl_words = set(_re.sub(r'[^\w]', ' ', key.lower()).split())
            if dn_words & kl_words:
                return key
    except Exception:
        pass
    return None


def run_act(project_path, workflow_path, event, log_path, matrix_flags=None, job_key=None):
    """
    Run `act` on the cloned repo, streaming output to console in real-time.
    After the job completes, the full output is written to log_path.

    Note: to restrict to one job, add '-j <yaml_job_id>' where yaml_job_id is
    the key under `jobs:` in the workflow file (not the display name from the
    GitHub API).  The display name is logged so you can identify the key.
    """
    cmd = [
        'act', event,
        '-W', workflow_path,
        '--directory', project_path,
    ]
    if job_key:
        cmd += ['-j', job_key]
    if matrix_flags:
        cmd += matrix_flags
    log.info(f'Running: {" ".join(cmd)}')

    os.makedirs(os.path.dirname(log_path), exist_ok=True)
    lines = []
    with open(log_path, 'w') as f:
        f.write(f'# command: {" ".join(cmd)}\n\n')
        with subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True) as proc:
            for line in proc.stdout:
                print(line, end='', flush=True)
                lines.append(line)
            proc.wait()
        rc = proc.returncode
        f.writelines(lines)

    return rc


def main():
    if len(sys.argv) not in (2, 3):
        print(f'Usage: python3 {sys.argv[0]} <input_file> [folder]')
        return 1

    input_file = sys.argv[1]
    output_dir = sys.argv[2] if len(sys.argv) == 3 else OUTPUT_DIR
    log.config_logging(getattr(logging, 'INFO', None))
    github_wrapper = GitHubWrapper(GITHUB_TOKENS)

    entries = []
    with open(input_file) as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            parts = line.split()
            if len(parts) != 2:
                log.warning(f'Skipping malformed line: {line!r}')
                continue
            entries.append((parts[0], parts[1]))

    log.info(f'Processing {len(entries)} entries from {input_file}')

    for repo, job_id in entries:
        repo_name = repo.split('/')[-1]
        log.info(f'=== {repo} job_id={job_id} ===')

        # Output structure: <output_dir>/<repo_name>_<job_id>/out/
        out_dir  = os.path.join(output_dir, f'{repo_name}_{job_id}', 'out')
        os.makedirs(out_dir, exist_ok=True)
        act_log_path  = os.path.join(out_dir, 'log.txt')
        orig_log_path = os.path.join(out_dir, f'{repo_name}-{job_id}.log')

        try:
            info = get_job_and_run_info(repo, job_id, github_wrapper)
        except Exception as e:
            log.error(f'GitHub API error for {repo} {job_id}: {e}')
            with open(act_log_path, 'w') as f:
                f.write(f'GitHub API error: {e}\n')
            continue

        log.info(f'  head_sha    = {info["head_sha"]}')
        log.info(f'  head_branch = {info["head_branch"]}')
        log.info(f'  workflow    = {info["workflow_path"]}')
        log.info(f'  event       = {info["event"]}')
        log.info(f'  job_name    = {info["job_name"]}')

        # Download original GitHub log
        try:
            download_log(job_id, orig_log_path, repo=repo)
            log.info(f'  original log saved: {orig_log_path}')
        except Exception as e:
            log.warning(f'  could not download original log: {e}')

        project_path = os.path.join(PROJECT_CLONE_PATH, repo_name)

        try:
            # Clone (no-op if already present) then reset to the exact commit
            git_clone_to_folder(PROJECT_CLONE_PATH, repo, info['head_branch'])
            reset_repo(project_path, '/dev/null', repo, info['head_sha'])

            matrix_flags = get_matrix_flags(repo, job_id)
            if matrix_flags:
                log.info(f'  matrix      = {" ".join(matrix_flags)}')

            job_key = find_job_key(project_path, info['workflow_path'], info['job_name'])
            if job_key:
                log.info(f'  job_key     = {job_key}')
            else:
                log.warning(f'  job_key not found for display name: {info["job_name"]} — running all jobs')

            rc = run_act(project_path, info['workflow_path'], info['event'], act_log_path, matrix_flags, job_key)

            status_msg = 'succeeded' if rc == 0 else f'exited with code {rc}'
            log.info(f'  act {status_msg} — log: {act_log_path}')
        finally:
            # Always clean up cloned repo and intermediates for this job
            for path in [
                project_path,
                os.path.join('intermediates', 'tmp'),
            ]:
                if os.path.exists(path):
                    shutil.rmtree(path)
                    log.info(f'  removed {path}')


if __name__ == '__main__':
    sys.exit(main())
