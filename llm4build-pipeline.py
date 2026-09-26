from openai import OpenAI
from together import Together
from anthropic import Anthropic
import subprocess
from pathlib import Path
from typing import Optional, Tuple

import os
import yaml
import re
import sys
import docker
import time
from markdown_it import MarkdownIt
import os
import json
import subprocess
import tempfile
from typing import Dict, Any


import logging
from urllib.parse import urlparse
from utils.common import log
from utils.log_downloader import download_log
from utils.common.credentials import GITHUB_TOKENS, OPENAI_TOKEN, TOGETHER_TOKEN, CLAUDE_TOKEN
from utils.common.github_wrapper import GitHubWrapper
from Executor import Executor
from utils.utils import find_correct_yaml_file, find_yaml_by_job_key, tree_to_string, find_readme_file, git_clone_to_folder, get_directory_structure, find_path_in_tree
from utils.utils import download_github_zip, unzip_file, reset_repo, is_resettable, download_and_overlay_repo
from job import generate_input_file, find_dict_by_key
import requests
import shutil
import json
from important_files import collect_local_action_ymls_from_content, get_repo_languages
from prompts import initial_prompt, feedback_prompt, yaml_reducer_prompt, yaml_merger, feedback_prompt_for_test
from typing import Dict, Any, Optional
from installation_file_list import rust_installation_files, javascript_installation_files, c_cpp_installation_files, JAVA_CONFIG_FILES, python_installation_files, go_installation_files
from installation_file_list import has_tests_run
from Parsers.javaParsers import JavaMavenLogAnalyser, JavaGradleLoganalyzer
from Parsers.pythonParser import PytestLogAnalyzer, UnitTestLogAnalyzer
from Parsers.rustParser import RustLogAnalyzer, NextTestLogAnalyzer
from Parsers.c_cpp_parser import CTEST_LogAnalyzer, GTest_LogAnalyzer, GitTest_Loganalyzer, AutotoolsLogAnalyzer, ProveTAPLogAnalyzer, HardSoftErrorLogAnalyzer, NinjaLogAnalyzer, MesonLoganalyzer, BazelLogAnalyzer, Radare2LogAnalyzer, ShellTestLogAnalyzer, CatBoostLogAnalyzer, MRubyLogAnalyzer, MicroPythonLogAnalyzer, PerlHarnessLogAnalyzer, ZstdTestLogAnalyzer, DuckDBLogAnalyzer, CCVLogAnalyzer, CapnProtoLogAnalyzer, MNNTestLogAnalyzer, CLibTAPLogAnalyzer
from Parsers.js_ts_parser import JestLogAnalyzer, JasmineLogAnalyzer, MochaLogAnalyzer, TypeScriptLogAnalyzer, TAPLogAnalyzer, VitestLogAnalyzer, NodeTestLogAnalyzer, SummaryBlockLogAnalyzer
from Parsers.go_parser import GoLogAnalyzer, GoRaceLogAnalyzer, GotestfmtLogAnalyzer
import argparse

install_files_dict = {
    "java": JAVA_CONFIG_FILES,
    "python": python_installation_files,
    "javascript": javascript_installation_files,
    "typescript": javascript_installation_files,
    "rust": rust_installation_files,
    "go": go_installation_files,
    "c": c_cpp_installation_files,
    "c++": c_cpp_installation_files
}

MODEL_PRICING = {
    "gpt-4o": {
        "prompt": 2.5,        # $2.50 / 1M tokens
        "completion": 10.0,   # $10.00 / 1M tokens
    },
    "gpt-4o-mini": {
        "prompt": 0.15,       # $0.15 / 1M tokens
        "completion": 0.60,   # $0.60 / 1M tokens
    },
    "gpt-4.1": {
        "prompt": 2.0,        # $2.00 / 1M tokens
        "completion": 8.0,    # $8.00 / 1M tokens
    },
    "gpt-4.1-mini": {
        "prompt": 0.40,       # $0.40 / 1M tokens
        "completion": 1.60,   # $1.60 / 1M tokens
    },
    "deepseek-ai/DeepSeek-V3": {
        "prompt": 0.27,       # $0.27 / 1M input tokens
        "completion": 1.10,   # $1.10 / 1M output tokens
    },
    "claude-haiku-4-5-20251001": {
        "prompt": 0.8,        # $0.80 / 1M input tokens
        "completion": 4.0,    # $4.00 / 1M output tokens
    },
    "claude-3.7-sonnet-20250219": {
        "prompt": 3.0,        # $3.00 / 1M input tokens
        "completion": 15.0,   # $15.00 / 1M output tokens
    },
}

def parse_url(url):
    # https://github.com/<owner>/<repo-name>/actions/runs/<run_id>
    # https://github.com/<owner>/<repo-name>/actions/runs/<run_id>/jobs/<job_id>
    # pattern = r'https://github.com/([^/]+/[^/]+)/actions/runs/(\d+)(?:/jobs/(\d+))?'
    match = re.match(r'https://github.com/([^/]+/[^/]+)/actions/runs/(\d+)(?:/job/(\d+))?', url)
    if match:
        return match.group(1), match.group(2), match.group(3)
    return None, None, None

def get_job_json(repo, run_id, job_id):
    github_wrapper = GitHubWrapper(GITHUB_TOKENS)
    status, json_data = github_wrapper.get('https://api.github.com/repos/{}/actions/jobs/{}'.format(repo, job_id))

    if status is None or not status.ok:
        log.error('Invalid GitHub Actions URL')
        return {}

    return json_data

    return {}

def extract_dockerfile_and_script(text):
    dockerfile_pattern = re.compile(r"```Dockerfile(.*?)```", re.DOTALL | re.IGNORECASE)
    bash_script_pattern = re.compile(r"```bash(.*?)```", re.DOTALL | re.IGNORECASE)

    dockerfile_match = dockerfile_pattern.search(text)
    bash_script_match = bash_script_pattern.search(text)

    dockerfile_content = dockerfile_match.group(1).strip() if dockerfile_match else ""
    bash_script_content = bash_script_match.group(1).strip() if bash_script_match else ""

    return dockerfile_content, bash_script_content

# def run_pipeline():
def get_directory_tree_as_string(path):
    structure = get_directory_structure(path)
    lines = tree_to_string(structure)
    return '\n'.join(lines)

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

# def call_openai(prompt, model="gpt-4o"):
#     client = OpenAI(api_key=OPENAI_TOKEN)  # prefer this var name
#     resp = client.chat.completions.create(
#         model=model,
#         messages=[{"role": "user", "content": prompt}],
#         temperature=0.0,
#     )
#     return resp.choices[0].message.content


def get_source_info_from_run(owner: str, repo: str, run_id: str, github_token: str):
    """
    Returns the source repo and branch for a GitHub Actions run, whether it's from a PR or direct push.
    """
    url = f"https://api.github.com/repos/{owner}/{repo}/actions/runs/{run_id}"
    headers = {"Authorization": f"Bearer {github_token}"}
    
    resp = requests.get(url, headers=headers)
    resp.raise_for_status()
    data = resp.json()

    return data["head_repository"]["full_name"]


def has_local_uses(yaml_content: str) -> bool:
    """
    Return True if any 'uses:' line refers to a local/.repo path containing '/.github/'.
    Handles lines like:
      - uses: ./.github/actions/foo
      - uses: repo/.github/actions/bar
    """
    pattern = re.compile(
        r'^\s*(?:-\s*)?uses:\s*[^#\n]*/\.github/',  # allow leading "- ", then any path with "/.github/"
        re.IGNORECASE | re.MULTILINE
    )
    return bool(pattern.search(yaml_content))

def extract_intra_repo_links(text):
    md = MarkdownIt()
    tokens = md.parse(text)

    urls = []

    # --- A) Markdown links + images ---
    for token in tokens:
        # standard links: [text](href)
        if token.type == "inline" and token.children:
            for child in token.children:
                if child.type == "link_open":
                    href = child.attrs.get("href")
                    if href:
                        urls.append(href)
                # images: ![alt](src)
                if child.type == "image":
                    src = child.attrs.get("src")
                    if src:
                        urls.append(src)

    # --- B) reStructuredText image blocks + :target: ---
    # Matches:
    # .. image:: <URL-or-path>
    #    :target: <URL-or-path>
    # (target is optional; we capture both)
    img_block_re = re.compile(
        r"^\.\.\s+image::\s+(\S+)\s*$"
        r"(?:[\r\n]+[ \t]*:target:\s*(\S+))?",
        re.MULTILINE
    )
    for m in img_block_re.finditer(text):
        img_url, target_url = m.group(1), m.group(2)
        urls.append(img_url)
        if target_url:
            urls.append(target_url)

    # --- Post-process into intra-repo paths like your original logic ---
    intra_repo = set()
    for link in urls:
        link = link.split('#')[0].strip()
        if not link:
            continue

        # Case 1: relative paths (e.g., CONTRIBUTING.md)
        if not re.match(r'^https?://', link):
            intra_repo.add(link)
            continue

        parsed = urlparse(link)
        host = parsed.netloc.lower()

        # Accept github.com and www.github.com
        if host.endswith("github.com"):
            path = parsed.path

            # /blob/ style links → extract path after /blob/
            if "/blob/" in path:
                intra_repo.add(path.split("/blob/", 1)[-1])
                continue

            # /actions/workflows/*.yml|yaml (badges often point here via :target:)
            if "/actions/workflows/" in path:
                filename = path.split("/actions/workflows/", 1)[-1]
                # normalize to repo path
                if filename.endswith((".yml", ".yaml")):
                    intra_repo.add(f".github/workflows/{filename}")
                else:
                    # badge .svg or others → try to strip the trailing /badge.svg
                    if filename.endswith("/badge.svg"):
                        filename = filename[:-len("/badge.svg")]
                    if filename.endswith((".yml", ".yaml")):
                        intra_repo.add(f".github/workflows/{filename}")

    return sorted(intra_repo)
                        
def filter_test_ymls(yml_dict, keywords=("test", "build", "ci")):
    filtered = {}
    for yml_file, name in yml_dict.items():
        combined = f"{yml_file} {name}".lower()
        if any(keyword.lower() in combined for keyword in keywords):
            filtered[yml_file] = name
    return filtered


def list_yml_names(project_path, workflows_dir=".github/workflows"):
    yml_to_name = {}
    
    full_path = os.path.join(project_path, workflows_dir)
    if not os.path.exists(full_path):
        return {}

    for filename in os.listdir(full_path):
        if filename.endswith(".yml") or filename.endswith(".yaml"):
            filepath = os.path.join(full_path, filename)
            try:
                with open(filepath, "r") as f:
                    data = yaml.safe_load(f)
                    name = data.get("name", "Unnamed Workflow")
                    yml_to_name[filename] = name
            except Exception as e:
                yml_to_name[filename] = f"Error: {e}"

    return yml_to_name

def list_yml_names_given(project_path, yml_path):
    yml_to_name = {}
    
    full_path = os.path.join(project_path, yml_path)
    if not os.path.exists(full_path):
        return {}

    # for filename in os.listdir(full_path):
    if full_path.endswith(".yml") or full_path.endswith(".yaml"):
        # filepath = os.path.join(full_path, full_path)
        try:
            with open(full_path, "r") as f:
                data = yaml.safe_load(f)
                name = data.get("name", "Unnamed Workflow")
                yml_to_name[full_path] = name
        except Exception as e:
            yml_to_name[full_path] = f"Error: {e}"

    return yml_to_name

def call_openai(prompt, model="gpt-4o"):
    client = OpenAI(api_key=OPENAI_TOKEN)  # prefer this var name
    # Strip null bytes and other control characters that make JSON invalid
    prompt = re.sub(r'[\x00-\x08\x0b\x0c\x0e-\x1f\x7f]', '', prompt)
    resp = client.chat.completions.create(
        model=model,
        messages=[{"role": "user", "content": prompt}],
        temperature=0.0,
    )
    
    content = resp.choices[0].message.content
    usage = resp.usage
    prompt_tokens = usage.prompt_tokens
    completion_tokens = usage.completion_tokens
    
    total_tokens = getattr(usage, "total_tokens", prompt_tokens + completion_tokens)

    pricing = MODEL_PRICING[model]
    cost = (
        (prompt_tokens / 1_000_000) * pricing["prompt"] +
        (completion_tokens / 1_000_000) * pricing["completion"]
    )
    
    return {
        "content": content,
        "cost": cost,
        "input_tokens":  prompt_tokens,
        "output_tokens": completion_tokens,
        "total_tokens":  total_tokens,
    }


def call_together(prompt, model="deepseek-ai/DeepSeek-V3"):
    client = Together(api_key=TOGETHER_TOKEN)
    resp = client.chat.completions.create(
        model=model,
        messages=[{"role": "user", "content": prompt}],
        temperature=0.0,
    )
    content = resp.choices[0].message.content

    # ---- cost calculation ----
    usage = resp.usage
    prompt_tokens = usage.prompt_tokens
    completion_tokens = usage.completion_tokens
    total_tokens = getattr(usage, "total_tokens", prompt_tokens + completion_tokens)

    pricing = MODEL_PRICING[model]
    cost = (
        (prompt_tokens / 1_000_000) * pricing["prompt"] +
        (completion_tokens / 1_000_000) * pricing["completion"]
    )
    return {
        "content": content,
        "cost": cost,
        "input_tokens":  prompt_tokens,
        "output_tokens": completion_tokens,
        "total_tokens":  total_tokens,
    }


def call_claude(prompt, model="claude-haiku-4-5-20251001"):
    client = Anthropic(api_key=CLAUDE_TOKEN)

    resp = client.messages.create(
        model=model,
        max_tokens=4096,
        temperature=0.0,
        messages=[
            {"role": "user", "content": prompt}
        ]
    )

    content = resp.content[0].text
    input_tokens  = resp.usage.input_tokens
    output_tokens = resp.usage.output_tokens
    total_tokens  = input_tokens + output_tokens

    pricing = MODEL_PRICING[model]
    cost = (
        (input_tokens  / 1_000_000) * pricing["prompt"] +
        (output_tokens / 1_000_000) * pricing["completion"]
    )

    return {
        "content": content,
        "cost": round(cost, 6),
        "input_tokens":  input_tokens,
        "output_tokens": output_tokens,
        "total_tokens":  total_tokens,
    }


# $/1M tokens
MODEL_PRICING_CODEX = {
    "gpt-4o": {"prompt": 2.5, "completion": 10.0},
    "gpt-4o-mini": {"prompt": 0.15, "completion": 0.60},
    "gpt-4.1": {"prompt": 2.0, "completion": 8.0},
    "gpt-4.1-mini": {"prompt": 0.40, "completion": 1.60},
    "deepseek-ai/DeepSeek-V3": {"prompt": 0.27, "completion": 1.10},
    "claude-haiku-4-5-20251001": {"prompt": 0.8, "completion": 4.0},
    "claude-3-7-sonnet-20250219": {"prompt": 3.0, "completion": 15.0},
}

def _extract_usage_from_jsonl(jsonl_text: str) -> tuple[int, int]:
    in_tokens = 0
    out_tokens = 0
    for line in jsonl_text.splitlines():
        line = line.strip()
        if not line:
            continue
        try:
            evt = json.loads(line)
        except Exception:
            continue

        usage = evt.get("usage") or evt.get("tokens") or evt.get("token_usage")
        if isinstance(usage, dict):
            in_tokens += int(usage.get("input_tokens", usage.get("prompt_tokens", 0)) or 0)
            out_tokens += int(usage.get("output_tokens", usage.get("completion_tokens", 0)) or 0)

    return in_tokens, out_tokens


def call_codex(prompt: str, model: str = "gpt-4o") -> Dict[str, Any]:
    """
    Codex CLI equivalent of call_openai():
      - returns final message content (from --output-last-message file)
      - returns cost computed from usage tokens in --json output
    """
    env = os.environ.copy()
    env["OPENAI_API_KEY"] = OPENAI_TOKEN

    with tempfile.TemporaryDirectory() as td:
        last_msg_path = os.path.join(td, "last_message.txt")

        cmd = [
            "codex", "exec",
            "--model", model,
            "--sandbox", "workspace-write",
            "--json",
            "--output-last-message", last_msg_path,
            prompt,
        ]

        proc = subprocess.run(
            cmd,
            text=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            env=env,
        )

        if proc.returncode != 0:
            raise RuntimeError(f"Codex failed:\n{proc.stderr}")

        # 1) Content: read last assistant message from file (most reliable)
        content = ""
        if os.path.exists(last_msg_path):
            content = open(last_msg_path, "r", encoding="utf-8", errors="replace").read().strip()

        # 2) Usage: parse JSONL from stdout
        prompt_tokens, completion_tokens = _extract_usage_from_jsonl(proc.stdout)

        # 3) Cost: compute with your pricing table
        pricing = MODEL_PRICING_CODEX[model]
        cost = (prompt_tokens / 1_000_000.0) * pricing["prompt"] + (completion_tokens / 1_000_000.0) * pricing["completion"]

        return {
            "content": content,
            "cost": round(cost, 6),
            "usage": {
                "prompt_tokens": prompt_tokens,
                "completion_tokens": completion_tokens,
                "total_tokens": prompt_tokens + completion_tokens,
            },
            "stderr": proc.stderr.strip(),
        }



def is_github_repo(url: str) -> bool:
    url = url.strip()
    https_pat = re.compile(r'^https?://github\.com/[^/]+/[^/]+(?:\.git)?/?$')
    ssh_pat   = re.compile(r'^git@github\.com:[^/]+/[^/]+(?:\.git)?$')
    return bool(https_pat.match(url) or ssh_pat.match(url))

def copy_contents(src_dir, dst_dir):
    os.makedirs(dst_dir, exist_ok=True)

    for item in os.listdir(src_dir):
        s = os.path.join(src_dir, item)
        d = os.path.join(dst_dir, item)

        if os.path.isdir(s):
            shutil.copytree(s, d, dirs_exist_ok=True)  # copy subdirectory
        else:
            shutil.copy2(s, d)  # copy file

def detect_analyzer(log_lines):
    analyzers = [
        JavaMavenLogAnalyser,
        JavaGradleLoganalyzer,
        PytestLogAnalyzer,
        UnitTestLogAnalyzer,
        RustLogAnalyzer,
        NextTestLogAnalyzer,
        JasmineLogAnalyzer,
        JestLogAnalyzer,
        MochaLogAnalyzer,
        SummaryBlockLogAnalyzer,
        NodeTestLogAnalyzer,
        CTEST_LogAnalyzer,
        GTest_LogAnalyzer,
        GitTest_Loganalyzer,
        AutotoolsLogAnalyzer,
        ProveTAPLogAnalyzer,
        CLibTAPLogAnalyzer,
        HardSoftErrorLogAnalyzer,
        NinjaLogAnalyzer,
        MesonLoganalyzer,
        BazelLogAnalyzer,
        Radare2LogAnalyzer,
        ShellTestLogAnalyzer,
        CatBoostLogAnalyzer,
        MRubyLogAnalyzer,
        MicroPythonLogAnalyzer,
        PerlHarnessLogAnalyzer,
        ZstdTestLogAnalyzer,
        DuckDBLogAnalyzer,
        CCVLogAnalyzer,
        CapnProtoLogAnalyzer,
        MNNTestLogAnalyzer,
        VitestLogAnalyzer,
        TAPLogAnalyzer,
        TypeScriptLogAnalyzer,
        GoLogAnalyzer,
        GoRaceLogAnalyzer,
        GotestfmtLogAnalyzer,
    ]
    
    applicable = []
    for AnalyzerClass in analyzers:
        analyzer = AnalyzerClass(log_lines)
        if analyzer.is_applicable():
            applicable.append(analyzer)
    
    if not applicable:
        return None
    
    # For now, we'll just return the first match. Since there can be only one unique ?
    return applicable

def latest_dir(path):
    # Full paths of only directories
    dirs = [
        os.path.join(path, d)
        for d in os.listdir(path)
        if os.path.isdir(os.path.join(path, d))
    ]
    if not dirs:
        return None

    # Sort by creation time (newest last)
    latest = max(dirs, key=os.path.getctime)
    return latest

def read_log_file(file_path):
    if not os.path.exists(file_path):
        log.warning('Log file not found: {}'.format(file_path))
        return []
    with open(file_path, 'r', encoding='utf-8') as file:
        return file.readlines()
    
def filter_steps(steps):
    return [s for s in steps if s.get("conclusion") in ("success", "failure")]


def get_steps(data):
    if isinstance(data, list):
        data = data[0]
    return filter_steps(data.get("steps", []))

def parse_args():
    p = argparse.ArgumentParser()
    p.add_argument('--task', help='task type')
    p.add_argument('--link',
                   help='GitHub Actions job URL to reproduce (e.g. https://github.com/<owner>/<repo>/actions/runs/<run_id>/job/<job_id>)')
    p.add_argument('--model',
                   help='provide the model name')
    p.add_argument("--cli", help='provide the model name')
    p.add_argument("--output_folder",
                   default="output",
                   help="provide output folder")
    # p.add_argument('-t', '--token',
    #                help='The GitHub token to make requests with. Defaults to the first entry in '
    #                     '`bugswarm.common.credentials.GITHUB_TOKENS`.')
    return p.parse_args()

    
def main():
    log.config_logging(getattr(logging, 'INFO', None))
    args = parse_args()
    task = args.task
    link = args.link
    model = args.model
    _model_aliases = {"gpt4o": "gpt-4o", "gpt4omini": "gpt-4o-mini", "gpt-4o-mini": "gpt-4o-mini", "gpt-4o": "gpt-4o"}
    model = _model_aliases.get(model, model)
    cli = args.cli
    output_folder = args.output_folder
    total_api_cost = 0.0
    total_tokens = 0
    total_input_tokens = 0
    total_output_tokens = 0
    if task == 'latest_build':
        repo_link = args.link
        repo_link_parts = repo_link.split("/")
        owner = repo_link_parts[-2]
        repo_name = repo_link_parts[-1].split(".")[0]
        
        # clone the repository
        project_clone_path = "project_path"
        git_clone_to_folder(project_clone_path, f"{owner}/{repo_name}", None, None)
        # get the workflow file
        project_path = os.path.join(project_clone_path, repo_name)
        readme_path = find_readme_file(project_path)
        
        readme_content = ""
        read_me = find_readme_file(project_path)
        if read_me:
            with open(read_me, "r") as file:
                readme_content = file.read()
        
        links = extract_intra_repo_links(readme_content)
        print("links",links, project_path)
        yaml_files = []
        for l in links:
            if l.endswith('yml') or l.endswith('yaml'):
                if os.path.exists(os.path.join(project_path, l)):
                    yaml_files.append(l)
        
        print(yaml_files)
        yml_paths = []
        if len(yaml_files) > 0:
            yml_to_name = []
            workflow_name = []
            for y in yaml_files:
                k = list_yml_names_given(project_path, y)
                yml_to_name.append(k)
                workflow_name.append(list(k.values())[0])
                yml_paths.append(list(k.keys())[0])
        yaml_file_dict = list_yml_names(project_path, workflows_dir=".github/workflows")
        yaml_file_dict_filtered = filter_test_ymls(yaml_file_dict, keywords=("test", "build", "ci", "linux", "main"))
        yaml_files = list(yaml_file_dict_filtered.keys())
        for y in yaml_files:
            yaml_path = os.path.join("project_path", repo_name, ".github/workflows", y)
            yml_paths.append(yaml_path)
        yml_content = []
        for yml in yml_paths:
            with open(yml, 'r') as file:
                content = file.read()
            yml_content.append(content)
        
        new_yml_content = set(yml_content)
        new_yml_set_to_add = set(yml_content)
        for cont in new_yml_content:
            # print("local uses ", has_local_uses(cont))
            if has_local_uses(cont):
                new_dict = collect_local_action_ymls_from_content(project_path, cont)
                # local_files_list = list(new_dict.keys())
                for k, v in new_dict.items():
                    new_yml_set_to_add.add(v)
        yaml_content = list(new_yml_set_to_add)
        # print("jjjj ", yaml_content)  
        if model in ("gpt-4o", "gpt-4o-mini", "gpt-4.1", "gpt-4.1-mini"):
            yaml_output_ = call_openai(yaml_merger(yaml_content), model=model)
            yaml_output = yaml_output_["content"]
            total_api_cost = total_api_cost + yaml_output_["cost"]
            total_tokens        = total_tokens        + yaml_output_["total_tokens"]
            total_input_tokens  = total_input_tokens  + yaml_output_.get("input_tokens",  0)
            total_output_tokens = total_output_tokens + yaml_output_.get("output_tokens", 0)
        elif model in ("claude-haiku-4-5-20251001", "claude-3-7-sonnet-20250219"):
            yaml_output_ = call_claude(yaml_merger(yaml_content), model=model)
            yaml_output = yaml_output_["content"]
            total_api_cost = total_api_cost + yaml_output_["cost"]
            total_tokens        = total_tokens        + yaml_output_["total_tokens"]
            total_input_tokens  = total_input_tokens  + yaml_output_.get("input_tokens",  0)
            total_output_tokens = total_output_tokens + yaml_output_.get("output_tokens", 0)
        else:
            yaml_output_ = call_together(yaml_merger(yaml_content))
            yaml_output = yaml_output_["content"]
            total_api_cost = total_api_cost + yaml_output_["cost"]
            total_tokens        = total_tokens        + yaml_output_["total_tokens"]
            total_input_tokens  = total_input_tokens  + yaml_output_.get("input_tokens",  0)
            total_output_tokens = total_output_tokens + yaml_output_.get("output_tokens", 0)
        # print(yaml_output)
        yaml_pattern = re.compile(r"```yaml(.*?)```", re.DOTALL | re.IGNORECASE)
        yaml_match = yaml_pattern.search(yaml_output)
        yaml_file_content = yaml_match.group(1).strip() if yaml_match else None
        repo_path = f"project_path/{repo_name}/"
        image_name = f"{repo_name.lower()}_{model}_main:latest"
    else:
        repo, run_id, job_id = parse_url(args.link)
        print(repo)
        print(run_id)
        print(job_id)
        if repo is None:
            log.error('This is not a valid GitHub Actions URL.')
            return 1
        job = get_job_json(repo, run_id, job_id)
        print("job ", job)
        job_name = job.get("workflow_name") or job.get("name", "")
        job_name_specific = job["name"]
        print(repo)
        project = repo.split("/")[-1]
        owner = repo.split("/")[0]
        repo_name = project
        # print(project)
        # print(owner)
        original_log_path = 'original_logs/{}-{}.log'.format(project ,job_id)
        download_log(job_id, 'original_logs/{}-{}.log'.format(project ,job_id), repo=repo)
            
        # download_github_zip(owner, project, job['head_sha'], "project_path/code-{}.zip".format(project))
        # unzip_file("project_path/code-{}.zip".format(project))
            # get the workflow file
        project_clone_path = "project_path"
        git_clone_to_folder(project_clone_path, f"{owner}/{repo_name}", job["head_branch"])
        repo_dir = os.path.join(project_clone_path, repo_name)
        if is_resettable(repo, job['head_sha'], project_clone_path):
            try:
                reset_repo(repo_dir, original_log_path, repo, job['head_sha'])
            except Exception as e:
                log.warning('reset_repo failed ({}), falling back to archive download.'.format(e))
                download_and_overlay_repo(project_clone_path, owner, repo_name, job['head_sha'], repo_dir)
        else:
            log.info('Commit {} is not resettable. Falling back to archive download.'.format(job['head_sha']))
            download_and_overlay_repo(project_clone_path, owner, repo_name, job['head_sha'], repo_dir)
        project_path = repo_dir
        # correct_yaml_file = find_correct_yaml_file(project_clone_path, f"{project}-{job['head_sha']}", job_name)
        correct_yaml_file = find_correct_yaml_file(project_clone_path, project, job_name)
        if correct_yaml_file is None:
            correct_yaml_file = find_correct_yaml_file(project_clone_path, project, job_name_specific)
        if correct_yaml_file is None:
            correct_yaml_file = find_yaml_by_job_key(project_clone_path, project, job_name_specific)
        print("correct ", correct_yaml_file)
        if correct_yaml_file is None:
            log.error(f"Could not find a matching workflow YAML for '{job_name}' / '{job_name_specific}' in {project_clone_path}/{project}. Skipping.")
            return 1
        with open(correct_yaml_file, "r") as f:
            yaml_content = f.read()

        # job_name_specific uses "parent / child" when the parent job delegates to a
        # reusable workflow. Follow the local uses: reference so the LLM receives
        # the file with actual steps instead of just the delegation stub.
        if ' / ' in job_name_specific:
            try:
                _wf_data = yaml.safe_load(yaml_content)
                _jobs = _wf_data.get('jobs', {}) if isinstance(_wf_data, dict) else {}
                _job_key = job_name_specific.split(' / ')[0].strip()
                _job_entry = _jobs.get(_job_key, {}) if isinstance(_jobs, dict) else {}
                _uses = _job_entry.get('uses', '') if isinstance(_job_entry, dict) else ''
                if _uses.startswith('./.github/'):  # local reference only, not org/repo/...
                    _ref_path = os.path.join(project_clone_path, project, _uses[2:])
                    if os.path.isfile(_ref_path):
                        correct_yaml_file = _ref_path
                        with open(correct_yaml_file, 'r') as f:
                            yaml_content = f.read()
                        print("correct (resolved reusable workflow) ", correct_yaml_file)
            except Exception:
                pass
            
        readme_content = ""
        read_me = find_readme_file(project_path)
        if read_me:
            with open(read_me, "r") as file:
                readme_content = file.read()
            
        json_file = generate_input_file(repo, job_id, None)
        p = json_file['failed_build']['jobs'][0]['config']
        q = json_file['passed_build']['jobs'][0]['config']
        mat_p = find_dict_by_key(q, "matrix")
        mat_q = find_dict_by_key(p, "matrix")
            
        mat_k = {}
        if mat_p is not None:
            mat_k = mat_p
        elif mat_q is not None:
            mat_k = mat_q
        
        completed_steps = get_steps(job)
        if model in ("gpt-4o", "gpt-4o-mini", "gpt-4.1", "gpt-4.1-mini"):
            yaml_output_ = call_openai(yaml_reducer_prompt(yaml_content, job_name_specific, mat_k, completed_steps), model=model)
            yaml_output = yaml_output_["content"]
            total_api_cost = total_api_cost + yaml_output_["cost"]
            total_tokens = total_tokens + yaml_output_["total_tokens"]
            total_input_tokens = total_input_tokens  + yaml_output_.get("input_tokens",  0)
            total_output_tokens = total_output_tokens + yaml_output_.get("output_tokens", 0)
        elif model in ("claude-haiku-4-5-20251001", "claude-3-7-sonnet-20250219"):
            print(yaml_reducer_prompt(yaml_content, job_name_specific, mat_k, completed_steps))
            yaml_output_ = call_claude(yaml_reducer_prompt(yaml_content, job_name_specific, mat_k, completed_steps), model=model)
            yaml_output = yaml_output_["content"]
            total_api_cost = total_api_cost + yaml_output_["cost"]
            total_tokens        = total_tokens + yaml_output_["total_tokens"]
            total_input_tokens  = total_input_tokens  + yaml_output_.get("input_tokens",  0)
            total_output_tokens = total_output_tokens + yaml_output_.get("output_tokens", 0)
            print("tot ", total_tokens)
        else:
            yaml_output_ = call_together(yaml_reducer_prompt(yaml_content, job_name_specific, mat_k, completed_steps))
            yaml_output = yaml_output_["content"]
            total_api_cost = total_api_cost + yaml_output_["cost"]
            total_tokens  = total_tokens + yaml_output_["total_tokens"]
            total_input_tokens  = total_input_tokens  + yaml_output_.get("input_tokens",  0)
            total_output_tokens = total_output_tokens + yaml_output_.get("output_tokens", 0)
        # print("yyy\n", yaml_output)
        yaml_pattern = re.compile(r"```(yamlfile|yaml)(.*?)```", re.DOTALL | re.IGNORECASE)
        yaml_match = yaml_pattern.search(yaml_output)
        yaml_content = yaml_match.group(2).strip() if yaml_match else None
        # print(yaml_reducer_prompt(yaml_content, job_name_specific, mat_k, completed_steps))
        # print("reduced yaml\n",yaml_content)
        # exit(1)
            
        if yaml_content is None:
            exit(1)
                
        local_uses = has_local_uses(yaml_content)
        print("llll ",local_uses)
        content = yaml_content
        if local_uses:
            new_dict = collect_local_action_ymls_from_content(project_path, yaml_content)
            # local_files_list = list(new_dict.keys())
            for k, v in new_dict.items():
                content = content + f"\n=== {k} ===\n{v}\n"
            # else:
            #     content = yaml_content
            
        # print(content)
        yaml_file_content = content
        # os.remove("project_path/code-{}.zip".format(project))
        repo_path = repo_dir
        image_name = "{}_{}_{}".format(project.lower(), model, job_id)
            # tree_str = get_directory_tree_as_string(repo_path)
            # tree = get_directory_structure(repo_path)
    language_list = list(install_files_dict.keys())
    lang_metadata = get_repo_languages(owner, repo_name)
    languages = lang_metadata["languages"]
    langs = []
    for l in languages:
        if l['name'].lower() in language_list:
            langs.append(l['name'].lower())
    
    installation_files = []
    for k in langs:
        installation_files += install_files_dict[k]
    installation_files = list(set(installation_files))
    print("image name ", image_name)
    structure = get_directory_structure(repo_path)
    all_paths = []
    for file in installation_files:
        full_path = find_path_in_tree(structure, file)
        if full_path is not None:
            all_paths.append(full_path)

    path_string = "\n".join(all_paths)

    runs_on = ""
    try:
        parsed_yaml = yaml.safe_load(yaml_file_content)
        if parsed_yaml and "jobs" in parsed_yaml:
            first_job = next(iter(parsed_yaml["jobs"].values()), {})
            runs_on = first_job.get("runs-on", "")
            if isinstance(runs_on, list):
                runs_on = " ".join(runs_on)
    except Exception:
        pass

    max_retries = 20
    if args.task == "historical_build":
        ext = str(job_id)
    else:
        ext = "master"
    for attempt in range(max_retries):
        print(f"\nAttempt {attempt}...")
            
        if attempt == 0:
            if cli is None:
                if model in ("gpt-4o", "gpt-4o-mini", "gpt-4.1", "gpt-4.1-mini"):
                    result_ = call_openai(initial_prompt(yaml_file_content, readme_content, path_string), model=model)
                    result = result_["content"]
                    total_api_cost = total_api_cost + result_["cost"]
                    total_tokens        = total_tokens        + result_["total_tokens"]
                    total_input_tokens  = total_input_tokens  + result_.get("input_tokens",  0)
                    total_output_tokens = total_output_tokens + result_.get("output_tokens", 0)
                elif model in ("claude-haiku-4-5-20251001", "claude-3-7-sonnet-20250219"):
                    result_ = call_claude(initial_prompt(yaml_file_content, readme_content, path_string), model=model)
                    result = result_["content"]
                    total_api_cost = total_api_cost + result_["cost"]
                    total_tokens        = total_tokens        + result_["total_tokens"]
                    total_input_tokens  = total_input_tokens  + result_.get("input_tokens",  0)
                    total_output_tokens = total_output_tokens + result_.get("output_tokens", 0)
                else:
                    result_ = call_together(initial_prompt(yaml_file_content, readme_content, path_string))
                    result = result_["content"]
                    total_api_cost = total_api_cost + result_["cost"]
                    total_tokens        = total_tokens        + result_["total_tokens"]
                    total_input_tokens  = total_input_tokens  + result_.get("input_tokens",  0)
                    total_output_tokens = total_output_tokens + result_.get("output_tokens", 0)
            else:
                if model in ("gpt-4o", "gpt-4o-mini", "gpt-4.1", "gpt-4.1-mini"):
                    # call_codex
                    # codex_prompt = build_codex_prompt(correct_yaml_file, job_name)
                    # codex_out, codex_err = run_codex_generate(workdir=Path(project_path), prompt=codex_prompt, model=model, sandbox="workspace-write")
                    # print(codex_out)
                    # print(codex_err)
                    result_ = call_codex(initial_prompt(yaml_file_content, readme_content, path_string, runs_on))
                    print("ppp ", result_)
                    result = result_["content"]
                    print("popop", result)
                    total_api_cost = total_api_cost + result_["cost"]
                    total_tokens        = total_tokens        + result_["total_tokens"]
                    total_input_tokens  = total_input_tokens  + result_.get("input_tokens",  0)
                    total_output_tokens = total_output_tokens + result_.get("output_tokens", 0)
        else:
            print("cli ", cli)
            print(attempt)
            print("error prompt \n")
            print(error_prompt)
            if cli is None:
                if model in ("gpt-4o", "gpt-4o-mini", "gpt-4.1", "gpt-4.1-mini"):
                    result_ = call_openai(error_prompt, model=model)
                    result = result_["content"]
                    total_api_cost = total_api_cost + result_["cost"]
                    total_tokens        = total_tokens        + result_["total_tokens"]
                    total_input_tokens  = total_input_tokens  + result_.get("input_tokens",  0)
                    total_output_tokens = total_output_tokens + result_.get("output_tokens", 0)
                elif model in ("claude-haiku-4-5-20251001", "claude-3-7-sonnet-20250219"):
                    result_ = call_claude(error_prompt, model=model)
                    result = result_["content"]
                    total_api_cost = total_api_cost + result_["cost"]
                    total_tokens        = total_tokens        + result_["total_tokens"]
                    total_input_tokens  = total_input_tokens  + result_.get("input_tokens",  0)
                    total_output_tokens = total_output_tokens + result_.get("output_tokens", 0)
                else:
                    result_ = call_together(error_prompt)
                    result = result_["content"]
                    total_api_cost = total_api_cost + result_["cost"]
            else:
                if model in ("gpt-4o", "gpt-4o-mini", "gpt-4.1", "gpt-4.1-mini"):
                    result_ = call_codex(error_prompt)
                    result = result_["content"]
                    print("popop", result)
                    total_api_cost = total_api_cost + result_["cost"]
                    total_tokens = total_tokens        + yaml_output_["total_tokens"]
                    total_input_tokens = total_input_tokens  + yaml_output_.get("input_tokens",  0)
                    total_output_tokens = total_output_tokens + yaml_output_.get("output_tokens", 0)
                
        # ── Per-attempt token usage ───────────────────────────────────────────
        attempt_input  = result_.get("input_tokens",  0)
        attempt_output = result_.get("output_tokens", 0)
        attempt_total = result_.get("total_tokens",  0)
        attempt_cost = result_.get("cost", 0.0)
        print(f"[ATTEMPT {attempt} TOKENS] input={attempt_input:,}  output={attempt_output:,}  "
              f"total={attempt_total:,}  cost=${attempt_cost:.6f}")
        print(f"[CUMULATIVE TOKENS]        input={total_input_tokens:,}  output={total_output_tokens:,}  "
              f"total={total_tokens:,}  cost=${total_api_cost:.6f}")

        # output_directory = args.output_folder
        if cli is None:
            if model == "gpt-4o":
                output_ = os.path.join(output_folder, 'gpt4o')
            elif model == "gpt-4o-mini":
                output_ = os.path.join(output_folder, 'gpt4o-mini')
            elif model == "deepseek-ai/DeepSeek-V3":
                output_ = os.path.join(output_folder, 'deepseekV3')
            elif model == "claude-haiku-4.5-20251001":
                output_ = os.path.join(output_folder, 'claude-4-5-haiku-20251001')
            else:
                output_ = os.path.join(output_folder, model.replace('/', '_') if model else 'unknown')
        else:
            output_ = os.path.join(output_folder, 'codex')
        dockerfile_content, bash_content = extract_dockerfile_and_script(result)
        output_path = os.path.join(output_, "{}_{}".format(repo_name, ext), "run_{}".format(str(attempt)))
        if not os.path.exists(output_path):
            os.makedirs(output_path)
        dockerfile_path = os.path.join(output_path, "Dockerfile")
        bashscript_path = os.path.join(output_path, "run.sh")
        log_path = os.path.join(output_path, "log.txt")
        docker_log_path = os.path.join(output_path, "docker_log.txt")
            
        with open(dockerfile_path, 'w') as f1:
            f1.write(dockerfile_content)
                
        with open(bashscript_path, 'w') as f2:
            f2.write(bash_content)

        tokens_path = os.path.join(output_path, "tokens.json")
        with open(tokens_path, 'w') as f3:
            json.dump({
                "attempt": attempt,
                "input_tokens":       result_.get("input_tokens",  0),
                "output_tokens":      result_.get("output_tokens", 0),
                "total_tokens":       result_.get("total_tokens",  0),
                "cost_usd":           round(float(result_.get("cost", 0.0)), 6),
                "cumulative_input_tokens":  total_input_tokens,
                "cumulative_output_tokens": total_output_tokens,
                "cumulative_total_tokens":  total_tokens,
                "cumulative_cost_usd":      round(float(total_api_cost), 6),
            }, f3, indent=2)

            # Executor
            # executes all the commands - docker image, test executions
        executor = Executor(dockerfile_path, bashscript_path, log_path, project_path, docker_log_path)
        build_info = executor.execute(image_name)
            
        error_prompt = ""
        log_lines = build_info.get("log_lines", [])

        if has_tests_run(log_lines):
            print("Tests have run, stopping retries.")
            break

        if build_info["success"] == False:
            if not log_lines:
                # Docker build failed — container never started
                raw_error = build_info.get("error_log", build_info.get("error", ""))
                error_lines = raw_error.splitlines()[-80:]
                error_msg = "Error from docker build\n" + "\n".join(error_lines)
            else:
                # Container ran but exited with a non-zero code
                log_ = log_lines[-80:]
                error_msg = "Error from run.sh\n\n***Tests have not been run***\n\n" + "\n".join(log_)
            print("Error message: ")
            print(error_msg)
            if cli is None:
                if args.task == "historical_build":
                    error_prompt = feedback_prompt(dockerfile_content, bash_content, error_msg, yaml_file_content)
                else:
                    error_prompt = feedback_prompt_for_test(dockerfile_content, bash_content, error_msg)
            # else:
            #     error_prompt = feedback_prompt_for_codex(dockerfile_content, bash_content, error_msg)
        else:
            exit_code = build_info.get("exit_code", 1)
            success = (exit_code == 0)
            print("Success:", success)

            log_ = log_lines[-80:]
            log_text = "\n".join(log_)
            if not success:
                log_text = "The Tests have not been run\nError from run.sh\n" + log_text
            if cli is None:
                if args.task == "historical_build":
                    error_prompt = feedback_prompt(dockerfile_content, bash_content, log_text, yaml_file_content)
                else:
                    error_prompt = feedback_prompt_for_test(dockerfile_content, bash_content, log_text)
            # else:
            #     error_prompt = feedback_prompt_for_codex(dockerfile_content, bash_content, log_text)
    
                    
    output_dir = os.path.join(output_, "{}_{}".format(repo_name, ext))
    output_path = latest_dir(output_dir)
    src_path = output_path
    dst_path = os.path.join(output_dir, "out")
    copy_contents(src_path, dst_path)
    src_log = 'original_logs/{}-{}.log'.format(project, job_id)
    if os.path.exists(src_log):
        shutil.copy(src_log, dst_path)
    else:
        log.warning('Original log not found: {}'.format(src_log))
    output_log = os.path.join(output_, "{}_{}".format(repo_name, ext), "out", "log.txt")
    log_lines = read_log_file(output_log)
    
    SOURCE_EXTENSIONS = {
        '.py', '.java', '.c', '.cpp', '.cc', '.cxx', '.h', '.hpp',
        '.js', '.ts', '.jsx', '.tsx', '.mjs', '.cjs',
        '.go', '.rs', '.rb', '.php', '.cs', '.swift', '.kt', '.scala',
        '.sh', '.bash', '.r', '.m', '.lua', '.pl', '.ex', '.exs',
    }
    SKIP_DIRS = {'.git', 'node_modules', '__pycache__', '.tox', 'venv', '.venv', 'build', 'dist'}

    def count_repo_loc(repo_dir):
        total = 0
        for root, dirs, files in os.walk(repo_dir):
            dirs[:] = [d for d in dirs if d not in SKIP_DIRS]
            for fname in files:
                if os.path.splitext(fname)[1].lower() in SOURCE_EXTENSIONS:
                    try:
                        with open(os.path.join(root, fname), 'r', errors='replace') as f:
                            total += sum(1 for _ in f)
                    except Exception:
                        pass
        return total

    repo_loc = count_repo_loc(repo_path)

    original_log_path = os.path.join(dst_path, '{}-{}.log'.format(project, job_id))
    original_log_num_lines = 0
    if os.path.exists(original_log_path):
        with open(original_log_path, 'r', errors='replace') as f:
            original_log_num_lines = sum(1 for _ in f)

    analyzer = detect_analyzer(log_lines)
    if analyzer:
        results_list = []
        for a in analyzer:
            results = a.analyze()
            cost_key = 'cost_claude' if model and 'claude' in model else 'cost_gpt'
            results[cost_key]        = total_api_cost
            results['input_tokens']  = total_input_tokens
            results['output_tokens'] = total_output_tokens
            results['total_tokens']  = total_tokens
            results['repo_loc'] = repo_loc
            results['original_log_num_lines'] = original_log_num_lines
            results_list.append(results)

        if os.path.exists(original_log_path):
            original_log_lines = read_log_file(original_log_path)
            original_analyzer = detect_analyzer(original_log_lines)
            if original_analyzer:
                original_results_list = []
                for a in original_analyzer:
                    original_results_list.append(a.analyze())
                results_list[0]['original_log_results'] = original_results_list

        output_json_path = os.path.join(output_, "{}_{}".format(repo_name, ext), "out", "out.json")
        with open(output_json_path, "w") as f:
            json.dump(results_list, f, indent=2)
    print('total cost ', total_api_cost)
    print('total input_tokens ', total_input_tokens)
    print('total output_tokens ', total_output_tokens)
    print('total tokens ', total_tokens)
    print('TOKENS_SUMMARY: ' + json.dumps({
        "input_tokens": total_input_tokens,
        "output_tokens": total_output_tokens,
        "total_tokens": total_tokens,
        "cost_usd": round(float(total_api_cost), 6),
    }))

    if os.path.exists(repo_path):
        shutil.rmtree(repo_path)
        print(f'Deleted cloned repository: {repo_path}')

    # subprocess.run(['docker', 'rmi', '-f', image_name], capture_output=True)
    # print(f'Deleted Docker image: {image_name}')

    
if __name__ == '__main__':
    start_time = time.time()

    exit_code = main()

    end_time = time.time()
    elapsed_time = end_time - start_time

    print(f"Execution time: {elapsed_time:.2f} seconds")
    sys.exit(exit_code)         

# def main():
#     return