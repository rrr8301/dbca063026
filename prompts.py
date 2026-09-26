from typing import Optional, Tuple

# Prompt for initial CoT reasoning and generation
def initial_prompt(yaml_content, readme_content="", installation_file_paths=""):
    return f"""You are a DevOps engineer tasked with converting a GitHub Actions job into a Dockerfile and a bash script (`run.sh`). You will first reason step-by-step through the job's requirements and environment, and then generate the scripts.
You need to build the repository at first. The yaml file or files related to the job will also be given here to get help.

Follow these steps:

1. Parse the job configuration: Identify the job name, `runs-on` OS, language setup (e.g., Python, Java), matrix (if any), and key steps.
2. Choose the base image:
   - If the matrix or job config contains a `docker_image` field (e.g., `docker_image: zulip/ci:jammy`), use that value directly as the `FROM` image. Do NOT `docker pull` inside `run.sh` — the host pulls it during `docker build`.
   - Otherwise, infer a suitable base image from `runs-on` (e.g., `ubuntu:22.04`, `ubuntu:24.04`).
3. Determine the language and version: Extract this from the job (e.g., `setup-python@v5`) or fallback to the README or config files.
4. Identify required packages:
     i. Extract `apt`, `brew`, or other OS-level packages from setup steps or install commands.
    ii. Identify `pip`, `npm`, `gem`, `go`, or other language-specific packages.
   iii. Always install `git` — it is almost always required for fetching dependencies or submodules. Also include other build tools like `cmake`, `ninja`, `g++`, `make`, `conda`, `playwrite`, `clang`, `cargo`, `curl`, `wget` etc.
   iv. include testing packages like `uv`, `pytest`, `maven` etc
    v. If any Gradle subproject uses the Android plugin (e.g. an `android-tests` module), install the Android SDK cmdline-tools + requested `platforms;android-XX` and `build-tools;XX.Y.Z` (default android-33 / 30.0.3) and set `ANDROID_HOME`. Without it, Android subprojects silently drop their `testDebugUnitTest` tasks from `build`.
   vi. Don't trust distro packages for build tools (`mvn`, `gradle`, `node`, `python`, `go`, `cargo`, `cmake`, etc.) — apt/yum versions are usually too old and break plugins. Install the workflow's pinned version via official binary or a version manager (`nvm`, `pyenv`, `rustup`, etc.); if unpinned, match the `ubuntu-latest` runner default.
5. Handle unsupported GitHub Actions — apply these rules per action:

   SKIP ENTIRELY (remove the step, no replacement needed):
   - actions/cache                    - Docker layer cache is sufficient; no replacement needed
   - actions/upload-artifact          - no artifact upload in local build
   - codecov/codecov-action           - no external coverage reporting
   - coverallsapp/github-action       - no external coverage reporting
   - softprops/action-gh-release      - no release publishing
   - docker/login-action              - no registry auth needed
   - docker/build-push-action         - not applicable in local build
   - github/codeql-action             - skip static analysis
   - Mozilla-Actions/sccache-action   - skip; if sccache is referenced in run commands, remove it or replace with a direct compiler call

   REPLACE (do not run inside the container):
   - any `docker pull` / `docker run` step  - running Docker inside a Docker container is not supported.
                                               If the step pulls a custom CI image, use that image as the `FROM`
                                               base in the Dockerfile instead. If the step runs a container to
                                               execute tests, replicate those commands directly in `run.sh`.

   SIMULATE OR SKIP (use judgment based on context):
   - actions/download-artifact        - if the artifact is a build output of a prior job, build it
                                        from source in run.sh instead of downloading it;
                                        if it is external or opaque, skip it and note the assumption
6. Handle or ignore secret variables. Focus on test execution related workflow only
7. Resolve artifacts:
   i. Simulate or make assumptions for downloaded wheels/binaries.
8. Write the Dockerfile:
   - Use base image
   - As the FIRST instruction after `FROM`, set `ENV DEBIAN_FRONTEND=noninteractive`
   - Set TZ to UTC and install tzdata noninteractively (set `ENV TZ=UTC`, write `/etc/timezone` and the `/etc/localtime` symlink BEFORE installing tzdata, and rely on `DEBIAN_FRONTEND=noninteractive`)
   - Set `ENV CI=true`, `ENV GITHUB_ACTIONS=true`
   - Always set locale to UTF-8 to avoid encoding failures
   - Install dependencies
   - Create work directory
   - Copy repo
   - After copying the repo, always add `RUN git config --global --add safe.directory '*'` 
   - Install packages
   - Include alternatives for the unsupported actions (if any)
   - Copy run.sh, make it executable
   - Always create a non-root user (e.g. `RUN useradd -m testuser`), transfer workspace ownership (`RUN chown -R testuser /workspace`), and switch to it before the entrypoint (`USER testuser`). 
   - set run.sh as entrypoint (provide the full path of run.sh)
9. Write the run.sh:
   - start with `#!/bin/bash`, do not start with `# run.sh`
   - Activate envs
   - Instead of clone, try to copy the repo inside the container. If cloning is needed, checkout to the branch and reset to the commit sha
   - Install project deps
   - Run tests using the EXACT command(s) from the YAML `run:` steps. Do NOT substitute with a generic test runner (e.g. do not replace `python scripts/ci/run-crt-tests` with `pytest tests/`). Copy the command verbatim from the YAML.
   - Ensure that all test cases are executed, even if some fail. Do not let test failures skip the rest of the test suite.
   - Do not use any flag that skips test execution (e.g. `-DskipTests` / `-Dmaven.test.skip` in Maven, `-x test` in Gradle, `--no-run` in Cargo, `--collect-only` in pytest, `npm install --ignore-scripts` if the test script lives there, or a Makefile target that builds only). If a build-only step is required first, follow it with a separate command that actually runs the tests. 
   - If using `tox`, always pass `-e py<major><minor>` (e.g. `-e py312`) matching the configured Python version. Never run `tox` without `-e` as it will execute all environments.
   - For Maven projects: (a) always append `-Drat.skip=true -Dlicense.skip=true` to every `mvn` command to avoid false RAT license failures from build artifacts in the workspace; (b) never use `./mvnw` — always use system `mvn` to avoid SHA-256 validation failures at runtime.
10. Use placeholders when needed.

Format:

Dockerfile
```Dockerfile
<your Dockerfile>
```

run.sh
```bash
<your run.sh>
```

---YAML---
{yaml_content}

---INSTALLATION FILE PATHS---
{installation_file_paths if installation_file_paths else "None found."}
"""

# - If using `tox`, always pass `-e py<major><minor>` (e.g. `-e py312`) matching the configured Python version. Never run `tox` without `-e` as it will execute all environments.
#    - If using `uv`, always set `UV_PYTHON_DOWNLOADS=never` to prevent uv from auto-downloading Python versions not installed in the image.
#    - If running browser-based tests (e.g. with `jtr`, Karma, Playwright, Puppeteer) inside Docker, do NOT pass Chrome/Chromium flags like `--no-sandbox` as CLI arguments to the test runner — they are not `jtr`/Karma flags. Instead set `export CHROMIUM_FLAGS="--no-sandbox --disable-dev-shm-usage"` before the test command.
# ---README---
# {readme_content}
# Prompt for feedback-based revision    - Always create a non-root user (e.g. `RUN useradd -m testuser`), transfer workspace ownership (`RUN chown -R testuser /workspace`), and switch to it before the entrypoint (`USER testuser`). 

def feedback_prompt(dockerfile, run_script, error_log, yaml):
    return f"""You generated the following Dockerfile and run.sh, but they failed to execute due to the error log given below.

---Dockerfile---
```Dockerfile
{dockerfile}
```

---run.sh---
```bash
{run_script}
```

---Execution Error Log: ---
```
{error_log}
```

--YAML--
{yaml}

Please revise necessary scripts to fix the issue according to the error log.
Error log will tell from which scripts error produces. Please modify necessary
scripts to run all the test cases. Do not skip any remaining tests and never
introduce any flag that skips test execution across any language or build tool.
Always keep enforcer skipping flag and license skipping flag if it was added
earlier, do not try to remove those. For Maven projects: always use system `mvn`
(never `./mvnw`) and always append `-Drat.skip=true -Dlicense.skip=true` to every
`mvn` command. If using `tox`, always pass `-e py<major><minor>` (e.g. `-e py312`)
matching the configured Python version. Never run `tox` without `-e`.

Do not change or replace any runtime or language version (e.g., Python, Java, Node,
Go, Rust, etc.) specified in the job name, matrix, or configuration. For example,
if the configuration requires python3.14, JDK 17, or Node 20, you must keep exactly
those versions. You may add supporting packages or flags, but the versions of core
runtimes must remain unchanged. Please skip those test files which are mentioned to be
skipped in the yaml file. For TCP/port-443 timeouts use a pre-built image (e.g. `python:3.11-slim`)
or a higher Ubuntu version. If tests are listed but show no pass/fail counts, the wrong task
name was used — check the project config (`turbo.json`, `nx.json`, `Makefile`, `Justfile`,
`build.gradle`, `Cargo.toml`) and use the task that actually runs tests.
Set run.sh as entrypoint (provide the full path of run.sh)

Dockerfile
```Dockerfile
<revised>
```

run.sh
```bash
<revised>
```
"""

# If using `tox`, always pass `-e py<major><minor>` (e.g. `-e py312`) matching the configured Python version. Never run `tox` without `-e`.
# If using `uv`, always set `UV_PYTHON_DOWNLOADS=never` to prevent auto-downloading other Python versions.


def yaml_reducer_prompt(yaml_content, job_name, matrix, completed_steps=""):
    if isinstance(completed_steps, list):
        completed_steps = "\n".join(s.get("name", "") for s in completed_steps)
    return f"""Your task is to generate a yaml  from a given yml script. You will be given job name, completed steps and other matrices. Your will 
build yaml script based on the job name and matrices. Please do not include other jobs and skipped steps as we will consider the given 
particular job and completed steps. If matrix is unavailable or empty dict, please consider it from the name of the job(if there is any 
descriptive name). Please replace the matrices in the commands if possible. 

Output format:
    YAML file
    ```yamlfile
    <your reduced yamlfile>
    ```

    ---YAML---
    {yaml_content}

    ---Job name---
    {job_name}

    ---Matrix---
    {matrix}
    
    ---Completed steps---
    {completed_steps}
"""


def yaml_merger(yaml_content_list):
    yaml_content = ""
    
    for yaml in yaml_content_list:
        yaml_content = yaml_content + '\n' + yaml
    
    return f"""You are an expert CI/CD engineer. Given a GitHub Actions workflow YAML, your task is to simplify it into 
a minimal form. The reduced workflow must contain only a single job that runs on ubuntu-22.04 with one stable language 
version (for example, Python 3.12, Node 20, or JDK 17). Remove all matrix strategies, extra OS targets, and dependency 
variants. The job should set up the chosen runtime, install dependencies in the simplest way (such as pip install, npm ci, 
mvn install), build the repository, build the repository and then run all available test types (unit, integration, smoke, and end-to-end) 
together using the project’s default test runner. Try to keep the command same as the original yaml file. If the original workflow includes coverage or artifact upload steps 
(e.g., Codecov, JUnit reports, coverage.xml), preserve them; otherwise, skip extras. Return only the final, valid GitHub 
Actions YAML file without any explanations or commentary.
    
    YAML file
    ```yamlfile
    <your merged yamlfile>
    ```

    ---YAML Files---
    {yaml_content}
    """

def initial_prompt_for_cfg(build_cmds, install_cmds, test_cmds, language):
    return f"""You are tasked with writing a dockerfile and bash script by giving a list of build, install and test commands. You will first 
reason step by step by the commands and generate the script so that the scripts will build the repository at first successfully and test it. 

Follow the steps
1. Infer the base image. Choose ubuntu-22.04
2. Separate the commands according to the language and which is necessary for building the repo, installing package and executes tests.
3. Identify required packages from the commands:
    i. Extract `apt`, or other OS-level packages from setup steps or install commands.
    ii. Identify `pip`, `npm`, `gem`, `go`, or other language-specific packages.
    iii. Include extra build tools like `cmake`, `ninja`, `g++`, `make`, `conda`, `playwrite`, `clang`, `cargo` etc.
4. Write the Dockerfile:
- Use base image
- Set TZ to Pacific Time (America/Los_Angeles) automatically and noninteractively so no tzdata prompts appear during build
- Install dependencies
- Create work directory
- Copy repo
- Install packages
- Include alternatives for the unsupported actions (if any)
- Copy run.sh, make it executable and set as entrypoint (provide full path of run.sh)
5. Write the run.sh:
- Activate envs
- Install project deps
- Add license headers if necessary
- Run tests
- Ensure that all test cases are executed, even if some fail. Do not let test failures skip the rest of the test suite.


Format:

Dockerfile
```Dockerfile
<your Dockerfile>
```

run.sh
```bash
<your run.sh>
```

---Build commands---
{build_cmds}

---Install commands---
{install_cmds}

---Test Commands---
{test_cmds}

---language---
{language}

"""

def feedback_prompt_for_test(dockerfile, run_script, error_log):
    return f"""You generated the following Dockerfile and run.sh, but they failed to execute due to the error log given below.

---Dockerfile---
```Dockerfile
{dockerfile}
```

---run.sh---
```bash
{run_script}
```

---Execution Error Log: ---
```
{error_log}
```

Please revise necessary scripts to fix the issue according to the error log.
Error log will tell from which scripts error produces. Please modify necessary
scripts to run all the test cases. Do not skip any remaining tests. Always keep
enforcer skipping flag and license skipping flag if it was added earlier, do not
try to remove those. For Maven projects: always use system `mvn` (never `./mvnw`)
and always append `-Drat.skip=true -Dlicense.skip=true` to every `mvn` command.
If the error log contains permission-related errors (e.g. `Permission denied`, `Operation not permitted`),
switch the Dockerfile to run as root: remove the `RUN useradd`, `RUN chown`, and `USER testuser` lines
and do not introduce any non-root user. Otherwise, keep the existing non-root user setup unchanged.
Set run.sh as entrypoint (provide the full path of run.sh)

Dockerfile
```Dockerfile
<revised>
```

run.sh
```bash
<revised>
```
"""

def build_codex_prompt(
    repo_path: str,
    job_name: str,
    image_name: str,
) -> str:
    workflow_dir = f"{repo_path}/.github/workflows"
    return f"""
You are a CI build reproducer agent. Reproduce a GitHub Actions job inside Docker — write Dockerfile and run.sh, build the image, run it, read the logs, fix errors, and retry until tests pass.

## Inputs
- Repo path     : {repo_path}
- Workflow dir  : {workflow_dir}
- Job name      : {job_name}
- Image name    : {image_name}

---

## Loop (keep iterating until SUCCESS or tokens exhausted)

### PHASE 1 — Read YAML (first attempt only)
Find and read the workflow YAML in `{workflow_dir}/` that defines job `{job_name}`.
Extract: OS (`runs-on`), language + exact version, all install/build/test steps, env vars.

### PHASE 2 — Write Dockerfile + run.sh
Write both files into `{repo_path}/`.

**Dockerfile:**
- `FROM` image matching `runs-on` (default `ubuntu:22.04`)
- `ENV DEBIAN_FRONTEND=noninteractive`
- Install system deps, language runtime, build tools via `apt-get`
- `WORKDIR /app` → `COPY . /app`
- Install project deps (pip/npm/cargo/mvn/etc.)
- `COPY run.sh /run.sh` → `RUN chmod +x /run.sh` → `ENTRYPOINT ["/run.sh"]`
- Skip: `actions/checkout`, `actions/cache`, `actions/upload-artifact`, `codecov/*`
- For Maven projects: always use system `mvn` (never `./mvnw`) and append `-Drat.skip=true -Dlicense.skip=true`

**run.sh:**
- `#!/bin/bash`
- `set -uo pipefail` (NOT `set -e` — all tests must run even if some fail)
- Run ALL test commands verbatim from the YAML; use `|| true` so one failure doesn't abort the rest
- Print `FINAL_STATUS = SUCCESS` if tests pass, `FINAL_STATUS = FAIL` otherwise

### PHASE 3 — Build
```
docker build -t {image_name} {repo_path}
```
On failure: fix Dockerfile, go back to PHASE 3.

### PHASE 4 — Run
```
docker run --rm {image_name} 2>&1 | tee run_log.txt
```
Read `run_log.txt`.

### PHASE 5 — Evaluate and iterate
- If `FINAL_STATUS = SUCCESS` found → done, print `FINAL_STATUS = SUCCESS` and stop.
- Otherwise diagnose the failure and fix:
  * Missing dependency      → add to Dockerfile
  * Wrong runtime version   → fix FROM or install step
  * Wrong test command      → re-read YAML and fix run.sh
  * Build error             → fix Dockerfile RUN steps
- Rewrite the COMPLETE Dockerfile and run.sh, rebuild, and rerun.
- Never repeat a fix that already failed — try a different approach.
- Keep iterating until tests pass. Do NOT stop after a fixed number of attempts.
- Only print `FINAL_STATUS = FAIL` if all reasonable approaches are exhausted.

## Rules
1. Never change the runtime version from the YAML.
2. Never skip tests unless the YAML says to.
3. Never repeat a fix that already failed.
4. Always write the COMPLETE Dockerfile and run.sh when updating.
"""

def build_codex_prompt_yaml_only(
    repo_path: str,
    job_name: str,
    image_name: str,
) -> str:
    """
    Like build_codex_prompt but restricts the agent to reading ONLY the workflow
    YAML — no other repo files. The agent finds and reads the YAML itself (PHASE 1),
    then proceeds directly to writing Dockerfile/run.sh without further exploration.
    """
    workflow_dir = f"{repo_path}/.github/workflows"
    return f"""
You are a CI build reproducer agent. Reproduce a GitHub Actions job inside Docker — write Dockerfile and run.sh, build the image, run it, read the logs, fix errors, and retry until tests pass.

## Inputs
- Repo path     : {repo_path}
- Workflow dir  : {workflow_dir}
- Job name      : {job_name}
- Image name    : {image_name}

---

## Loop (keep iterating until SUCCESS or tokens exhausted)

### PHASE 1 — Read YAML only (first attempt only — read ONE file, then stop reading)
Find and read the workflow YAML in `{workflow_dir}/` that defines job `{job_name}`.
Extract: OS (`runs-on`), language + exact version, all install/build/test steps, env vars.
After reading the YAML, do NOT read any other files from the repository.

### PHASE 2 — Write Dockerfile + run.sh in ONE single command
Write BOTH files with a single shell command (use file_edit or a heredoc) to minimise
the number of LLM turns between builds.

**Dockerfile rules:**
- `FROM` image matching `runs-on` (default `ubuntu:22.04`)
- `ENV DEBIAN_FRONTEND=noninteractive`
- Install system deps, language runtime, build tools via `apt-get`
- `WORKDIR /app` → `COPY . /app`
- Install project deps (pip/npm/cargo/mvn/etc.)
- `COPY run.sh /run.sh` → `RUN chmod +x /run.sh` → `ENTRYPOINT ["/run.sh"]`
- Skip: `actions/checkout`, `actions/cache`, `actions/upload-artifact`, `codecov/*`
- For Maven projects: always use system `mvn` (never `./mvnw`) and append `-Drat.skip=true -Dlicense.skip=true`

**run.sh rules:**
- `#!/bin/bash`
- `set -uo pipefail` (NOT `set -e` — all tests must run even if some fail)
- Run ALL test commands verbatim from the YAML; use `|| true` so one failure doesn't abort the rest
- Print `FINAL_STATUS = SUCCESS` if tests pass, `FINAL_STATUS = FAIL` otherwise

**Important:** When fixing errors, always rewrite BOTH Dockerfile and run.sh together
in a single command — never edit one file per LLM turn.


### PHASE 3 — Build + Run in ONE single command (zero LLM calls while docker runs)
Run this exact one-liner so that the entire build+run is a single tool call.
No LLM turn happens while docker is executing.
```
docker build -t {image_name} {repo_path} > /tmp/build.log 2>&1; BUILD_EXIT=$?; if [ $BUILD_EXIT -ne 0 ]; then echo "BUILD FAILED (exit $BUILD_EXIT)"; tail -n 60 /tmp/build.log; else docker run --rm {image_name} > run_log.txt 2>&1; RUN_EXIT=$?; echo "RUN DONE (exit $RUN_EXIT)"; tail -n 60 run_log.txt; fi
```

### PHASE 4 — Evaluate and iterate
- If `FINAL_STATUS = SUCCESS` found in the output → done, print `FINAL_STATUS = SUCCESS` and stop.
- Otherwise diagnose the failure and fix:
  * Missing dependency      → add to Dockerfile
  * Wrong runtime version   → fix FROM or install step
  * Wrong test command      → re-check the YAML (re-read it if needed)
  * Build error             → fix Dockerfile RUN steps
- Rewrite BOTH Dockerfile and run.sh together in one command, then go back to PHASE 3.
- Never repeat a fix that already failed — try a different approach.
- Keep iterating until tests pass. Do NOT stop after a fixed number of attempts.
- Only print `FINAL_STATUS = FAIL` if all reasonable approaches are exhausted.

## Rules
1. Never change the runtime version from the YAML.
2. Never skip tests unless the YAML says to.
3. Never repeat a fix that already failed.
4. Always write BOTH Dockerfile and run.sh together in one command.
5. Only read the workflow YAML — do NOT read other repo files (source code, configs, etc.).
6. Run docker build + run as a single one-liner as shown above — never as separate commands.
7. When reading any log file, always use `tail -n 60 <file>` — never `cat`.
"""
def feedback_prompt_for_codex(dockerfile, run_script, error_log):
    return f"""
You are revising a reproducible CI build environment.

Your previous Dockerfile and run.sh failed during execution. The contents are given below

---Dockerfile---
```Dockerfile
{dockerfile}
```

---run.sh---
```bash
{run_script}
```


You MUST revise ONLY what is necessary to fix the errors shown below.

======================
ERROR LOG (last 50 lines)
======================
{error_log}
======================

MANDATORY RULES:

1. You MUST NOT change any runtime or language versions specified in:
   - job name
   - matrix configuration
   - YAML configuration
   - existing Dockerfile
   Examples:
   - If python3.14 is required, keep python3.14.
   - If JDK 17 is required, keep JDK 17.
   - If Node 20 is required, keep Node 20.
   - If Go 1.22 is required, keep Go 1.22.
   - If Rust toolchain is pinned, keep it unchanged.

2. You MUST NOT skip any test cases.
   - All tests must be executed.
   - Only skip tests that are explicitly marked to be skipped in the YAML file.
   - Do NOT introduce new skip flags.
   - Do NOT disable test suites.

3. If enforcer skipping flags or license skipping flags were added earlier,
   you MUST preserve them. Do NOT remove them.

4. You may:
   - Add missing system packages.
   - Add build dependencies.
   - Add environment variables.
   - Add necessary flags.
   - Add virtual environments (if needed).
   - Add missing tools (e.g., make, cmake, pip, pytest, maven plugins, etc.)

5. Keep the build deterministic and non-interactive:
   - Use DEBIAN_FRONTEND=noninteractive where appropriate.
   - Avoid prompts.

6. Only modify what is required to fix the error.

7. The repository contents are already copied into /app (or working directory).
   Do NOT clone again.

8. Do NOT output explanations.
   Do NOT output plans.
   Do NOT output reasoning.
   Output ONLY the required code blocks.

==================================================
STRICT OUTPUT CONTRACT (REQUIRED FORMAT)
==================================================

You MUST output EXACTLY two code blocks in this exact order:

Dockerfile
```Dockerfile
<FULL REVISED DOCKERFILE CONTENT HERE>
```

bashscript
```bash
<FULL REVISED bash CONTENT HERE>
```
"""