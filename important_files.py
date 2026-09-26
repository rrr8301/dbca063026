import os
import yaml
from collections import deque
from typing import Dict, Tuple, Iterable, Any
from utils.common.credentials import GITHUB_TOKENS

import requests

def get_fork_info_from_run(owner: str, repo: str, run_id: str, github_token: str):
    """
    Fetches the forked repository and branch name from a GitHub Actions run ID.
    
    Parameters:
        owner (str): The owner of the main repository (e.g., 'pallets')
        repo (str): The name of the main repository (e.g., 'click')
        run_id (str): The GitHub Actions workflow run ID
        github_token (str): GitHub personal access token (with `repo` scope)
    
    Returns:
        List[Tuple[str, str]]: A list of (repo_full_name, branch) pairs, 
                               one for each associated pull request
    """
    url = f"https://api.github.com/repos/{owner}/{repo}/actions/runs/{run_id}"
    headers = {"Authorization": f"Bearer {github_token}"}
    
    resp = requests.get(url, headers=headers)
    resp.raise_for_status()
    data = resp.json()

    prs = data.get("pull_requests", [])
    if not prs:
        print("No pull request information associated with this run.")
        return []

    fork_info = []
    for pr in prs:
        head = pr["head"]
        fork_repo = head["repo"]["full_name"]
        fork_branch = head["ref"]
        fork_info.append((fork_repo, fork_branch))

    return fork_info


JAVA_CONFIG_FILES = [
    "pom.xml", 
    "pom-test.xml", 
    "pom-release.xml", 
    "pom-dev.xml", 
    "pom-build.xml",
    "build-pom.xml",
    "alt-pom.xml", 
    "build.gradle", 
    "build.gradle.kts", 
    "build-dev.gradle"
    ]
python_installation_files = [
    # Dependency files
    "requirements.txt",
    "requirements-dev.txt",
    "requirements-test.txt",
    "requirements-prod.txt",
    "requirements-ci.txt",
    "build_requirements.txt",
    "test_requirements.txt"

    # Packaging configs
    "setup.py",
    "setup.cfg",
    "pyproject.toml",

    # Environment managers
    "Pipfile",
    "Pipfile.lock",
    "environment.yml",   # Conda

    # Testing / automation
    "tox.ini",
    "pytest.ini",

    # Linting / formatting configs
    ".flake8",
    ".pylintrc",
    "mypy.ini",

    # Optional build helpers
    "Makefile", 
    "uv",
    "uv.lock"
]

javascript_installation_files = [
    # Dependency managers
    "package.json",
    "package-lock.json",   # npm lock file
    "yarn.lock",           # Yarn lock file
    "pnpm-lock.yaml",      # pnpm lock file

    # Build / bundler configs
    "webpack.config.js",
    "rollup.config.js",
    "vite.config.js",
    "gulpfile.js",
    "gruntfile.js",

    # TypeScript config
    "tsconfig.json",
    "tsconfig.build.json",

    # Linting / formatting
    ".eslintrc.js",
    ".eslintrc.json",
    ".eslintrc.yml",
    ".prettierrc",
    ".prettierrc.js",
    ".prettierrc.json",

    # Testing
    "jest.config.js",
    "jest.config.ts",
    "mocha.opts",
    "karma.conf.js",

    # Environment / runtime
    ".nvmrc",        # Node version
    ".npmrc",        # npm config
    ".yarnrc.yml",   # yarn config

    # Other common project files
    "babel.config.js",
    "babel.config.json",
    "next.config.js",
    "nuxt.config.js"
]

go_installation_files = [
    # Dependency management
    "go.mod",        # Defines module path & dependencies
    "go.sum",        # Checksums for dependencies
    "Gopkg.toml",    # Old (dep tool)
    "Gopkg.lock",    # Old (dep tool)
    "glide.yaml",    # Very old (Glide)
    "glide.lock",    # Very old (Glide)

    # Build / tooling
    "Makefile",      # Often used for build/test commands
    "Dockerfile",    # Containerized builds/tests

    # Testing configs
    ".golangci.yml",    # golangci-lint config
    ".golangci.yaml",
    ".golangci.toml",
    ".golangci.json",

    # CI / task runners
    "Taskfile.yml",     # Task runner for Go
    "magefile.go",      # Mage (Make alternative in Go)

    # Environment
    ".go-version",      # Node-style version pinning, used by some tools
    ".tool-versions"    # asdf-vm version file (may include Go)
]

csharp_installation_files = [
    # Project / solution files
    "*.csproj",       # C# project file (defines dependencies, build settings)
    "*.vbproj",       # VB.NET project file
    "*.fsproj",       # F# project file
    "*.sln",          # Solution file (groups projects)

    # Package management
    "packages.config",  # Old NuGet dependency list
    "NuGet.config",     # NuGet sources/credentials
    "global.json",      # Pin SDK version
    "Directory.Packages.props",  # Central package version management
    "Directory.Build.props",     # Shared MSBuild properties
    "Directory.Build.targets",   # Shared MSBuild targets

    # .NET CLI / runtime
    ".dotnet-tools.json",   # Local dotnet tool manifest
    "dotnet-tools.json",    # Sometimes used interchangeably
    ".config/dotnet-tools.json",  # Alternate location

    # Build / automation
    "Cakefile",        # Cake (C# Makefile alternative)
    "build.cake",      # Cake build script
    "build.ps1",       # PowerShell build script
    "build.sh",        # Shell build script
    "Makefile",        # Sometimes used in cross-platform repos

    # Testing
    "xunit.runner.json",   # xUnit test config
    "nunit.config",        # NUnit config
    "mstest.runsettings",  # MSTest run settings

    # Editor / linting / analyzers
    ".editorconfig",       # Code style/linting
    "stylecop.json",       # StyleCop analyzer config
    "ruleset.json",        # Roslyn analyzer rules
    "sonar-project.properties"  # SonarQube config
]

rust_installation_files = [
    # Dependency management & project metadata
    "Cargo.toml",          # Main Rust project manifest
    "Cargo.lock",          # Lock file for dependencies
    "rust-toolchain",      # Pin Rust version (rustup override file)
    "rust-toolchain.toml", # Advanced toolchain config
    ".cargo/config",       # Cargo config (deprecated form)
    ".cargo/config.toml",  # Cargo config (modern form)

    # Workspace / multi-crate setup
    "Cargo.workspace.toml", # Alternative workspace manifests
    "Cargo.nix",            # Nix-based Cargo integration

    # Build / automation
    "Makefile",             # Often wraps cargo build/test
    "Justfile",             # Just task runner
    "Taskfile.yml",         # Task runner configs
    "build.rs",             # Cargo build script
    "cross.toml",           # Cross-compilation config (cross-rs)
    "rust-project.json",    # rust-analyzer project definition
    "bazel.build",          # Some projects integrate with Bazel

    # Testing / coverage
    "Cargo.toml" ,          # Integration/unit tests defined here under [dev-dependencies]
    ".tarpaulin.toml",      # Tarpaulin coverage tool config
    ".grcov.yml",           # grcov coverage tool config
    ".nextest.toml",        # cargo-nextest test runner config
    ".proptest-regressions",# Proptest regression test outputs
    "fuzz/Cargo.toml",      # cargo-fuzz setup for fuzz testing

    # Linting / formatting
    "rustfmt.toml",         # rustfmt config
    ".rustfmt.toml",        # alt rustfmt config
    "Clippy.toml",          # clippy lint config (unofficial, supported by cargo-clippy)
    ".clippy.toml",         # alt clippy config

    # Environment / version managers
    ".rust-version",        # Rust version (alternative to rust-toolchain)
    ".tool-versions",       # asdf-vm toolchain version file (may include Rust)

    # CI / metadata
    "deny.toml",            # cargo-deny config (dependency audit)
    ".cargo-husky.toml",    # cargo-husky git hook configs
    ".audit.toml",          # cargo-audit config
    "audit.toml",           # sometimes not dotted
]

c_cpp_installation_files = [
    # Build systems
    "Makefile",              # Classic make build file
    "GNUmakefile",           # GNU Make convention
    "makefile",              # lowercase variant
    "CMakeLists.txt",        # CMake build definition
    "*.cmake",               # CMake modules/configs
    "meson.build",           # Meson build definition
    "meson_options.txt",     # Meson options
    "configure",             # Autotools configure script
    "configure.ac",          # Autoconf input
    "config.h.in",           # Autotools config header template
    "config.h",              # Generated config header
    "autogen.sh",            # Script to bootstrap autotools
    "bootstrap",             # Often used for autoconf bootstrap
    "SConstruct",            # SCons build script
    "SConscript",            # SCons sub-project script
    "wscript",               # Waf build script
    "BUILD",                 # Bazel build file
    "WORKSPACE",             # Bazel workspace
    "BUILD.bazel",           # Bazel build file (explicit extension)
    "*.bzl",                 # Bazel/Starlark extensions

    # Dependency management
    "conanfile.txt",         # Conan dependencies
    "conanfile.py",          # Conan recipes
    "vcpkg.json",            # vcpkg manifest mode
    "vcpkg-configuration.json", # vcpkg registries config
    "vcpkg-lock.json",       # vcpkg lock file
    "hunter.cmake",          # Hunter package manager for CMake
    "CPackConfig.cmake",     # Packaging config
    "CPackSourceConfig.cmake",

    # Testing
    "CTestTestfile.cmake",   # CTest test definitions
    ".cppunit.xml",          # CppUnit config
    "gtest.xml",             # GoogleTest report/config
    "CatchConfig.cmake",     # Catch2 CMake config

    # Toolchain / environment
    "toolchain.cmake",       # Toolchain file for cross-compilation
    ".clang-format",         # Code formatting
    ".clang-tidy",           # Linting / static analysis
    ".ccls",                 # ccls LSP config
    "compile_commands.json", # Compilation database
    ".codecov.yml",          # Code coverage
    ".gcov",                 # Gcov profiling configs
    ".lcovrc",               # Lcov configuration

    # IDE / project configs (commonly checked in)
    "*.pro",                 # Qt qmake project
    "*.pri",                 # Qt include project file
    "*.qbs",                 # Qt Qbs build
    ".project",              # Eclipse CDT project
    ".cproject",             # Eclipse CDT build
    "*.vcxproj",             # Visual Studio C++ project
    "*.vcxproj.filters",     # VS project filters
    "*.sln",                 # Visual Studio solution
    "*.dsp", "*.dsw",        # Old Visual Studio workspace/project
    "*.cbp",                 # Code::Blocks project
    "*.dev",                 # Dev-C++ project
    "*.kdev4", "*.kdevelop", # KDevelop project

    # Scripts for build/test automation
    "build.sh",
    "build.bat",
    "run_tests.sh",
    "test.sh"
]

def collect_local_action_ymls(project_path: str, workflow_file: str) -> Dict[str, str]:
    project_root = os.path.abspath(project_path)
    start_abs = os.path.abspath(os.path.join(project_root, workflow_file))

    collected: Dict[str, str] = {}
    visited_abs = set()

    def rel_key(abs_path: str) -> str:
        return os.path.relpath(abs_path, project_root).replace("\\", "/")

    def is_local_uses(v: Any) -> bool:
        return isinstance(v, str) and (
            v.startswith("./") or v.startswith("../") or v.startswith(".github/")
        )

    def find_uses(node: Any) -> Iterable[str]:
        if isinstance(node, dict):
            for k, v in node.items():
                if k == "uses" and is_local_uses(v):
                    yield v.strip()
                else:
                    yield from find_uses(v)
        elif isinstance(node, list):
            for item in node:
                yield from find_uses(item)

    def resolve_to_abs_file(uses_ref: str) -> Tuple[str, str]:
        """
        Build absolute path from project root per rule:
          project_root / <uses_ref>[ / action.yml ]
        - If ref starts with "./", remove EXACTLY the first two chars.
        - If no .yml/.yaml specified, assume it's a directory → append action.yml,
          then fallback to action.yaml if needed.
        Returns (abs_target, rel_key_for_target).
        """
        ref = uses_ref
        if ref.startswith("./"):
            ref = ref[2:]  # <-- critical fix (do NOT use lstrip)

        candidate = os.path.abspath(os.path.join(project_root, ref))

        # If no explicit file extension, treat as directory → action.yml / action.yaml
        if not (candidate.endswith(".yml") or candidate.endswith(".yaml")):
            yml = os.path.join(candidate, "action.yml")
            yaml_path = os.path.join(candidate, "action.yaml")
            if os.path.isfile(yml):
                return yml, rel_key(yml)
            if os.path.isfile(yaml_path):
                return yaml_path, rel_key(yaml_path)
            # Neither exists; report the .yml key consistently
            return yml, rel_key(yml)

        return candidate, rel_key(candidate)

    def dfs(abs_file: str):
        abs_file = os.path.abspath(abs_file)
        if abs_file in visited_abs:
            return
        visited_abs.add(abs_file)

        key = rel_key(abs_file)

        if not os.path.isfile(abs_file):
            # if missing action.yml, try action.yaml
            if abs_file.endswith("action.yml"):
                alt = abs_file[:-4] + "yaml"
                if os.path.isfile(alt):
                    dfs(alt)
                    return
            collected[key] = f"# File not found: {abs_file}"
            return

        # Read and store raw
        try:
            with open(abs_file, "r", encoding="utf-8") as f:
                raw = f.read()
            collected[key] = raw
        except Exception as e:
            collected[key] = f"# Could not read: {e}"
            return

        # Parse and recurse nested local uses
        try:
            data = yaml.safe_load(raw)
        except Exception as e:
            collected[key] = f"# YAML parse error: {e}\n" + raw
            return

        if isinstance(data, (dict, list)):
            for ref in set(find_uses(data)):
                target_abs, _ = resolve_to_abs_file(ref)
                # final pre-check: if action.yml missing, try .yaml
                if not os.path.isfile(target_abs) and target_abs.endswith("action.yml"):
                    alt = target_abs[:-4] + "yaml"
                    if os.path.isfile(alt):
                        target_abs = alt
                dfs(target_abs)

    dfs(start_abs)
    return collected


def collect_local_action_ymls_from_content(project_path: str, workflow_yaml_text: str) -> Dict[str, str]:
    """
    Parse a workflow YAML *string* and recursively collect all local action YAML files
    referenced via `uses:` (to any depth).

    Resolution rule (per your spec):
      ABS = project_root / <uses_path> [ / action.yml ]
      If 'action.yml' doesn't exist, try 'action.yaml'.

    Only local refs are followed:
      - starts with "./"
      - starts with "../"
      - starts with ".github/"

    Returns:
      { "<relpath from project root>": "<raw YAML content or error marker>" }
    """
    project_root = os.path.abspath(project_path)
    collected: Dict[str, str] = {}
    visited_abs: set[str] = set()

    def rel_key(abs_path: str) -> str:
        return os.path.relpath(abs_path, project_root).replace("\\", "/")

    def is_local_uses(v: Any) -> bool:
        return isinstance(v, str) and (
            v.startswith("./") or v.startswith("../") or v.startswith(".github/")
        )

    def find_uses(node: Any) -> Iterable[str]:
        """Yield all local `uses` strings anywhere in the YAML structure."""
        if isinstance(node, dict):
            for k, v in node.items():
                if k == "uses" and is_local_uses(v):
                    yield v.strip()
                else:
                    yield from find_uses(v)
        elif isinstance(node, list):
            for item in node:
                yield from find_uses(item)

    def to_abs_action_file(uses_ref: str) -> str:
        """
        Build absolute path from project root:
          project_root / <uses_ref> [ / action.yml ]
        - If ref starts with "./", remove EXACTLY the first two chars (keep '.github/...').
        - If no .yml/.yaml specified, assume directory → append action.yml,
          then fallback to action.yaml if needed (handled by caller too).
        """
        ref = uses_ref
        if ref.startswith("./"):
            ref = ref[2:]  # critical: do NOT use lstrip("./")

        candidate = os.path.abspath(os.path.join(project_root, ref))

        if not (candidate.endswith(".yml") or candidate.endswith(".yaml")):
            # treat as a directory, prefer action.yml, fallback to action.yaml later
            candidate = os.path.join(candidate, "action.yml")

        return candidate

    def crawl_action_file(abs_file: str):
        """DFS into an action file, storing it and following its nested local `uses`."""
        abs_file = os.path.abspath(abs_file)
        if abs_file in visited_abs:
            return
        visited_abs.add(abs_file)

        # Fallback to .yaml if .yml missing (directory case)
        if not os.path.isfile(abs_file) and abs_file.endswith("action.yml"):
            alt = abs_file[:-4] + "yaml"
            if os.path.isfile(alt):
                abs_file = alt

        key = rel_key(abs_file)
        if not os.path.isfile(abs_file):
            collected[key] = f"# File not found: {abs_file}"
            return

        try:
            with open(abs_file, "r", encoding="utf-8") as f:
                raw = f.read()
            collected[key] = raw
        except Exception as e:
            collected[key] = f"# Could not read: {e}"
            return

        # Parse and follow nested local uses
        try:
            data = yaml.safe_load(raw)
        except Exception as e:
            collected[key] = f"# YAML parse error: {e}\n" + raw
            return

        if isinstance(data, (dict, list)):
            for ref in set(find_uses(data)):
                target_abs = to_abs_action_file(ref)
                # If action.yml missing, try .yaml before recursing
                if not os.path.isfile(target_abs) and target_abs.endswith("action.yml"):
                    alt = target_abs[:-4] + "yaml"
                    if os.path.isfile(alt):
                        target_abs = alt
                crawl_action_file(target_abs)

    # Seed from the workflow YAML *content*
    try:
        root = yaml.safe_load(workflow_yaml_text)
    except Exception as e:
        # Can't parse the workflow; return empty mapping with a hint
        return { "<workflow>": f"# YAML parse error: {e}" }

    if isinstance(root, (dict, list)):
        for ref in set(find_uses(root)):
            target_abs = to_abs_action_file(ref)
            if not os.path.isfile(target_abs) and target_abs.endswith("action.yml"):
                alt = target_abs[:-4] + "yaml"
                if os.path.isfile(alt):
                    target_abs = alt
            crawl_action_file(target_abs)

    return collected

# # Example usage
# if __name__ == "__main__":
#     with open("project_path/react-native/.github/workflows/test-all.yml", "r") as file:
#         content = file.read()
#     ymls = collect_local_action_ymls_from_content("project_path/react-native",content)
#     for k, v in ymls.items():
#         print(f"\n=== {k} ===\n{v}...\n")

def get_source_info_from_run(owner: str, repo: str, run_id: str, github_token: str):
    """
    Returns the source repo and branch for a GitHub Actions run, whether it's from a PR or direct push.
    """
    url = f"https://api.github.com/repos/{owner}/{repo}/actions/runs/{run_id}"
    headers = {"Authorization": f"Bearer {github_token}"}
    
    resp = requests.get(url, headers=headers)
    resp.raise_for_status()
    data = resp.json()

    event_type = data.get("event")
    prs = data.get("pull_requests", [])
    print("prs ",prs)
    if prs:
        pr = prs[0]
        fork_repo = pr["head"]["repo"]["name"]
        fork_branch = pr["head"]["ref"]
        return {"source": "pull_request", "repo": fork_repo, "branch": fork_branch}

    # Case 2: Push or other direct events
    head_branch = data.get("head_branch")
    head_repo = data.get("repository", {}).get("full_name", f"{owner}/{repo}")
    return {"source": event_type, "repo": head_repo, "branch": head_branch}


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

def get_directory_structure(root_path):
    if not os.path.isdir(root_path):
        raise ValueError(f"{root_path} is not valid directory")
    
    return {os.path.basename(root_path): build_tree(root_path)}

def build_tree(path):
    tree = {}
    for entry in sorted(os.listdir(path)):
        full_path = os.path.join(path, entry)
        if os.path.isdir(full_path):
            tree[entry] = build_tree(full_path)
        else:
            tree[entry] = None
    return tree


API = "https://api.github.com"
HEADERS = {
    "Accept": "application/vnd.github+json",
    **({"Authorization": f"Bearer {GITHUB_TOKENS[0]}"})
}

def get_repo_languages(owner: str, repo: str):
    """
    Returns {"owner","repo","total_bytes", "languages":[{"name","bytes","percent"}]}
    """
    url = f"{API}/repos/{owner}/{repo}/languages"
    r = requests.get(url, headers=HEADERS, timeout=30)
    if r.status_code == 403 and r.headers.get("X-RateLimit-Remaining") == "0":
        reset = int(r.headers.get("X-RateLimit-Reset", "0"))
        raise RuntimeError(f"Rate limit exceeded. Resets at epoch {reset}.")
    r.raise_for_status()
    raw = r.json()  # {"Python": 123, "Shell": 45, ...}
    total = max(sum(raw.values()), 1)
    langs = [
        {"name": k, "bytes": v, "percent": round(v / total * 100, 2)}
        for k, v in sorted(raw.items(), key=lambda kv: kv[1], reverse=True)
    ]
    return {"owner": owner, "repo": repo, "total_bytes": total, "languages": langs}
# get_source_info_from_run("pallets", "click", 17126026224, GITHUB_TOKENS[0])
# path = "project_path/pytest/"
# tree_str = get_directory_tree_as_string(path)
# tree = get_directory_structure(path)
# structure = get_directory_structure(path)
# all_paths = []
# for file in python_installation_files:
#     full_path = find_path_in_tree(structure, file)
#     if full_path is not None:
#         all_paths.append(full_path)

# path_string = "\n".join(all_paths)
# print(path_string)
# owner = "pallets"
# repo = "click"
# run_id = "17343032757"


# # forks = get_fork_info_from_run(owner, repo, run_id, GITHUB_TOKENS[0])
# forks = get_source_info_from_run(owner, repo, run_id, GITHUB_TOKENS[0])
# print(forks)
# languages_dict = get_repo_languages("google", "libphonenumber")
# ll = languages_dict['languages']
# languages = []
# for l in ll:
#     if l['percent'] > 5:
#         languages.append(l['name'])
# print(languages)
