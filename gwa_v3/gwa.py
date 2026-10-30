"""Graph Workflow Analyzer (GWA).

Replaces the LLM YAML reducer with a static analysis whose representations are

    workflow YAML + job metadata --(target resolution)--> target job + matrix
    workflow YAML + repository manifests --(construction)--> typed semantic graph
    typed semantic graph --(target-specific backward slice)--> sliced graph
    sliced graph --(specification)--> execution specification

1. Target resolution is preprocessing on the YAML: it maps the GitHub API job
   to its YAML job key and matrix assignment.
2. Graph construction adds jobs, steps, actions, commands, workflows and
   resources (job outputs, artifacts, runtimes, repository manifests, ...)
   with typed edges. Nodes carry normalised, execution-relevant attributes and
   provenance (source file, job key, step index); edges carry the field and
   expression they come from. The original YAML stays on job and step nodes
   only as `raw_config`, for lossless reconstruction.
3. Backward slicing reads only the graph and returns the sliced subgraph.
4. The execution specification is generated from the sliced graph alone,
   without rereading the YAML or the repository.

Edge convention: a dependency edge points from the prerequisite to the node
that relies on it (needed job -> dependent job, producer -> resource ->
consumer), so slicing walks edges backwards. Every edge has a `dependency`
class:
  structural   CONTAINS, EXECUTES, USES, CALLS
  control      NEEDS -- no filesystem or state crosses it; whether the needed
               job is executed or only recorded as an ordering constraint is
               the slicing semantics (`semantics`, recorded in the spec)
  order        PRECEDES -- step sequence; kept steps keep their predecessors
               because an earlier step's shell side effects may be needed
  data, artifact, environment, manifest
               PRODUCES / CONSUMES / CONFIGURES through a resource node --
               mandatory: the slicer pulls the producer in

GWA-v3 adds Shell-Aware Dependency Analysis (gwa_shell.py): every `run:`
script is parsed into a Shell Command IR (one `shell_command` node per simple
command, under the step's `command` node), and the files, repository checkouts
and package environments the commands read, write or install become resource
edges with provenance (`command`) and a confidence (explicit / implicit /
possible). File reads are linked to the latest earlier writer in the same job
(reaching definitions), else to the repository file. This replaces v2's
regular expressions over raw `run:` text. Slicing policy is unchanged: the
shell analysis makes dependencies more precise; it removes no step.

GWA reads only the repository and the job's API metadata, never the job's
historical CI log, so it can run before or without one.
"""
import fnmatch
import hashlib
import json
import os
import re
from collections import Counter, deque

import networkx as nx
import yaml

from .gwa_conditions import FALSE, Partial, Unknown, evaluate, resolve_condition, to_string
from .gwa_shell import MANAGER, analyze_script
from utils.construct_job_config import build_combinations


# ── GitHub Actions-aware YAML loading ─────────────────────────────────────────
class _GHALoader(yaml.SafeLoader):
    """SafeLoader without YAML 1.1's yes/no/on/off booleans.

    PyYAML reads the top-level `on:` key as True; GitHub reads it as the
    string "on". Only true/false stay booleans, as in YAML 1.2.
    """


_BOOL_TAG = "tag:yaml.org,2002:bool"
_GHALoader.yaml_implicit_resolvers = {
    first: [(tag, regexp) for tag, regexp in resolvers if tag != _BOOL_TAG]
    for first, resolvers in yaml.SafeLoader.yaml_implicit_resolvers.items()
}
_GHALoader.add_implicit_resolver(
    _BOOL_TAG, re.compile(r"^(?:true|True|TRUE|false|False|FALSE)$"), list("tTfF"))


def load_workflow_yaml(text):
    return yaml.load(text, Loader=_GHALoader)


# ── Expression references ─────────────────────────────────────────────────────
EXPRESSION = re.compile(r"\$\{\{(.*?)\}\}", re.DOTALL)
NEEDS_OUTPUT = re.compile(r"\bneeds\.([A-Za-z0-9_-]+)\.outputs\.([A-Za-z0-9_-]+)")
STEP_OUTPUT = re.compile(r"\bsteps\.([A-Za-z0-9_-]+)\.outputs\.([A-Za-z0-9_-]+)")
STEP_STATUS = re.compile(r"\bsteps\.([A-Za-z0-9_-]+)\.(?:outcome|conclusion)\b")
MATRIX_REF = re.compile(r"\bmatrix\.([A-Za-z0-9_-]+)")
INPUT_REF = re.compile(r"\binputs\.([A-Za-z0-9_-]+)")
SECRET_REF = re.compile(r"\bsecrets\.([A-Za-z0-9_]+)")
WRITES_ENV_FILE = re.compile(r"\$\{?GITHUB_(?:ENV|PATH)\}?")

JOB_FIELDS = ("if", "env", "runs-on", "container", "services", "strategy", "with",
              "secrets", "environment", "defaults")
STEP_FIELDS = ("if", "run", "with", "env", "working-directory", "shell")

MAX_CALL_DEPTH = 3        # nested reusable workflows / composite actions followed

# action (owner/repo[/path], no ref) -> (runtime, version inputs in priority order)
RUNTIME_ACTIONS = {
    "actions/setup-python": ("python", ("python-version", "python-version-file")),
    "actions/setup-node": ("node", ("node-version", "node-version-file")),
    "actions/setup-java": ("java", ("java-version", "java-version-file")),
    "actions/setup-go": ("go", ("go-version", "go-version-file")),
    "actions/setup-dotnet": ("dotnet", ("dotnet-version", "global-json-file")),
    "ruby/setup-ruby": ("ruby", ("ruby-version",)),
    "dtolnay/rust-toolchain": ("rust", ("toolchain",)),
    "actions-rs/toolchain": ("rust", ("toolchain",)),
    "actions-rust-lang/setup-rust-toolchain": ("rust", ("toolchain",)),
    "conda-incubator/setup-miniconda": ("python", ("python-version",)),
    "oven-sh/setup-bun": ("bun", ("bun-version", "bun-version-file")),
    "denoland/setup-deno": ("deno", ("deno-version",)),
    "shivammathur/setup-php": ("php", ("php-version",)),
    "erlef/setup-beam": ("erlang", ("otp-version",)),
    "haskell-actions/setup": ("ghc", ("ghc-version",)),
}
TOOL_ACTIONS = {
    "astral-sh/setup-uv": "uv",
    "pnpm/action-setup": "pnpm",
    "gradle/actions/setup-gradle": "gradle",
    "gradle/gradle-build-action": "gradle",
    "snok/install-poetry": "poetry",
    "abatilo/actions-poetry": "poetry",
    "conda-incubator/setup-miniconda": "conda",
    "mamba-org/setup-micromamba": "micromamba",
    "lukka/get-cmake": "cmake",
    "jwlawson/actions-setup-cmake": "cmake",
    "seanmiddleditch/gha-setup-ninja": "ninja",
    "bazelbuild/setup-bazelisk": "bazel",
    "bazel-contrib/setup-bazel": "bazel",
    "arduino/setup-protoc": "protoc",
    "taiki-e/install-action": "cargo-tools",
}
ROLE_ACTIONS = {
    "checkout": ("actions/checkout",),
    "cache": ("actions/cache", "Swatinem/rust-cache", "hendrikmuhs/ccache-action",
              "Mozilla-Actions/sccache-action"),
    "artifact_upload": ("actions/upload-artifact",),
    "artifact_download": ("actions/download-artifact",),
    "reporting": ("codecov/codecov-action", "coverallsapp/github-action", "github/codeql-action",
                  "actions/upload-pages-artifact", "softprops/action-gh-release",
                  "docker/login-action", "docker/build-push-action",
                  "EnricoMi/publish-unit-test-result-action", "dorny/test-reporter"),
}
PACKAGE_MANAGER_COMMANDS = {
    "pip": r"\bpip3?\s+install\b|\bpython[0-9.]*\s+-m\s+pip\b",
    "uv": r"\buv\s+(?:pip|sync|run|venv|tool|lock|add)\b|\buvx\b",
    "poetry": r"\bpoetry\s",
    "pdm": r"\bpdm\s",
    "hatch": r"\bhatch\s",
    "tox": r"\btox\b",
    "nox": r"\bnox\b",
    "conda": r"\b(?:conda|mamba|micromamba)\s",
    "npm": r"\bnpm\s|\bnpx\s",
    "yarn": r"\byarn\b",
    "pnpm": r"\bpnpm\b",
    "bun": r"\bbun\s",
    "maven": r"\bmvn\b|\./mvnw\b",
    "gradle": r"\bgradle\b|\./gradlew\b",
    "cargo": r"\bcargo\s",
    "go": r"\bgo\s+(?:build|test|mod|install|vet|run|generate|get)\b",
    "cmake": r"\bcmake\b",
    "make": r"(?:^|[\s;&|(])make\b",
    "meson": r"\bmeson\b",
    "ninja": r"\bninja\b",
    "bazel": r"\bbazel(?:isk)?\b",
    "apt": r"\bapt(?:-get)?\s+(?:-\S+\s+)*install\b",
    "brew": r"\bbrew\s+install\b",
    "vcpkg": r"\bvcpkg\b",
    "conan": r"\bconan\b",
    "dotnet": r"\bdotnet\s",
}

# ── repository manifests ──────────────────────────────────────────────────────
DEPENDENCY_FILES = {
    "requirements.txt", "pyproject.toml", "setup.py", "setup.cfg", "Pipfile", "Pipfile.lock",
    "poetry.lock", "uv.lock", "pdm.lock", "tox.ini", "noxfile.py", "environment.yml",
    "environment.yaml", ".python-version", "package.json", "package-lock.json", "yarn.lock",
    "pnpm-lock.yaml", "bun.lockb", ".nvmrc", ".node-version", "go.mod", "go.sum", "Cargo.toml",
    "Cargo.lock", "rust-toolchain", "rust-toolchain.toml", "pom.xml", "build.gradle",
    "build.gradle.kts", "settings.gradle", "settings.gradle.kts", "gradle.properties",
    ".java-version", ".sdkmanrc", "CMakeLists.txt", "Makefile", "meson.build", "configure.ac",
    "conanfile.txt", "conanfile.py", "vcpkg.json", "WORKSPACE", "MODULE.bazel", ".bazelversion",
    "global.json", ".tool-versions", "Gemfile", "Gemfile.lock", "composer.json",
}
DEPENDENCY_FILE_PATTERNS = ("requirements*.txt", "requirements*.in", "constraints*.txt")
# files whose first line is the version a setup action reads
VERSION_FILES = (".python-version", ".nvmrc", ".node-version", ".java-version", ".bazelversion")
SKIP_DIRS = {".git", "node_modules", "__pycache__", ".tox", "venv", ".venv", "build", "dist",
             "target", "vendor", "third_party", "3rdparty", "external"}
REQUIREMENT_FILE_ARG = re.compile(r"(?:^|\s)(?:-r|--requirement|-c|--constraint)(?:=|\s+)([^\s;&|'\"]+)")
PIP_COMMAND = re.compile(r"\bpip3?\b|\buv\s+pip\b|\bpip-sync\b")     # where -r / -c name a file
# Conservative inference: a command that implicitly reads manifests in its
# working directory. Only manifests that exist there get an edge.
INFERRED_MANIFESTS = (
    (r"\bpip3?\s+install\b[^\n;&|]*\s(?:-e\s+)?\.(?:\[[^\]\s]*\])?(?=\s|$)",
     ("pyproject.toml", "setup.py", "setup.cfg")),
    (r"\bpoetry\s+install\b", ("pyproject.toml", "poetry.lock")),
    (r"\buv\s+(?:sync|run)\b", ("pyproject.toml", "uv.lock")),
    (r"\bpdm\s+(?:install|sync)\b", ("pyproject.toml", "pdm.lock")),
    (r"\bpipenv\s+(?:install|sync)\b", ("Pipfile", "Pipfile.lock")),
    (r"\btox\b", ("tox.ini", "pyproject.toml", "setup.cfg")),
    (r"\bnox\b", ("noxfile.py",)),
    (r"\bnpm\s+(?:ci|install|i)\b", ("package.json", "package-lock.json")),
    (r"\bnpm\s+(?:run|test|t)\b", ("package.json",)),
    (r"\byarn\b", ("package.json", "yarn.lock")),
    (r"\bpnpm\s+(?:install|i)\b", ("package.json", "pnpm-lock.yaml")),
    (r"\bbun\s+install\b", ("package.json", "bun.lockb")),
    (r"\bcargo\s+(?:build|test|nextest|check|run|clippy|bench)\b",
     ("Cargo.toml", "Cargo.lock", "rust-toolchain.toml", "rust-toolchain")),
    (r"\bgo\s+(?:build|test|mod|install|vet|run|generate)\b", ("go.mod", "go.sum")),
    (r"\bmvn\b|\./mvnw\b", ("pom.xml",)),
    (r"\bgradle\b|\./gradlew\b", ("build.gradle", "build.gradle.kts", "settings.gradle",
                                  "settings.gradle.kts", "gradle.properties")),
    (r"\bcmake\b", ("CMakeLists.txt",)),
    (r"(?:^|[\s;&|(])make\b", ("Makefile",)),
    (r"\bmeson\b", ("meson.build",)),
    (r"\./configure\b|\bautoreconf\b", ("configure.ac",)),
    (r"\bbazel(?:isk)?\b", ("MODULE.bazel", "WORKSPACE", ".bazelversion")),
    (r"\bconan\s+install\b", ("conanfile.txt", "conanfile.py")),
    (r"\bvcpkg\b", ("vcpkg.json",)),
    (r"\bdotnet\s", ("global.json",)),
    (r"\bbundle\s+(?:install|exec)\b", ("Gemfile", "Gemfile.lock")),
)

# resource type -> dependency class of the edges through it
RESOURCE_DEPENDENCY = {
    "job_output": "data", "step_output": "data", "input": "data",
    "artifact": "artifact",
    "dependency_manifest": "manifest", "version_file": "manifest",
    "runtime": "environment", "tool": "environment", "env_file": "environment",
    "matrix": "environment", "env": "environment", "runner": "environment",
    "container": "environment", "service": "environment",
    # shell-aware dependency analysis (GWA-v3)
    "repository_file": "data", "workspace_file": "data", "checkout": "data",
    "package_environment": "environment",
}
# resource types a kept step's PRODUCES edge keeps even with no kept consumer
ENVIRONMENT_RESOURCES = {"runtime", "tool", "env_file", "package_environment"}
CONFIDENCE_RANK = {"explicit": 0, "implicit": 1, "possible": 2}
# kinds of command whose run depends on system packages installed earlier in the job
SYSTEM_CONSUMERS = {"build", "test_execution", "script_execution", "static_analysis"}
# job roles in the slice, weakest first; a job is upgraded, never downgraded
ROLE_RANK = {"ordering_only": 0, "call_site": 1, "data_predecessor": 1, "artifact_producer": 1,
             "control_predecessor": 2, "target": 3}
# what reproducing the slice does with a job of each role
JOB_EXECUTION = {
    "target": "execute_all_steps",
    "control_predecessor": "execute_all_steps",
    "data_predecessor": "execute_until_producer",
    "artifact_producer": "execute_until_producer",
    "call_site": "resolve_inputs_only",
    "ordering_only": "record_constraint_only",
}

# Slicing semantics. "target_execution" reproduces what the target job needs
# to run; "strict_workflow" also reproduces the scheduling of the workflow,
# where a job runs only after (and usually only if) the jobs it needs succeed.
SEMANTICS = ("target_execution", "strict_workflow")
SEMANTICS_RULES = [
    {"dependency": "NEEDS, no consumed output",
     "strict_workflow": "execute predecessor", "target_execution": "record ordering constraint"},
    {"dependency": "NEEDS with consumed output",
     "strict_workflow": "execute producer", "target_execution": "execute producer"},
    {"dependency": "artifact producer",
     "strict_workflow": "execute producer", "target_execution": "execute producer"},
    {"dependency": "target-job setup steps",
     "strict_workflow": "preserve", "target_execution": "preserve"},
]
# a dependent whose `if:` calls one of these runs whatever its needs concluded
STATUS_FUNCTION = re.compile(r"\b(?:always|failure|cancelled)\s*\(")


def _requires_success(condition, needed):
    """Whether a job needing `needed` runs only if `needed` succeeded.

    True: the default gate (no status function in `if:`). False: a status
    function makes it run regardless. "conditional": its `if:` tests
    needs.<needed>.result itself -- the condition decides.
    """
    if condition and re.search(rf"\bneeds\.{re.escape(needed)}\.result\b", condition):
        return "conditional"
    if condition and STATUS_FUNCTION.search(condition):
        return False
    return True


def _action_name(uses):
    """`owner/repo/path@ref` -> `owner/repo/path`."""
    return uses.split("@", 1)[0].strip()


def _action_ref(uses):
    return uses.split("@", 1)[1].strip() if "@" in uses else ""


def _matches_action(uses, names):
    name = _action_name(uses).lower()
    return any(name == n.lower() or name.startswith(n.lower() + "/") for n in names)


def _matched_action(uses, table):
    return next(n for n in table if _matches_action(uses, (n,)))


def _as_list(value):
    if value is None:
        return []
    return value if isinstance(value, list) else [value]


def _strings(value):
    """Every string inside a nested YAML value."""
    if isinstance(value, str):
        yield value
    elif isinstance(value, dict):
        for k, v in value.items():
            yield from _strings(k)
            yield from _strings(v)
    elif isinstance(value, list):
        for item in value:
            yield from _strings(item)


def _expression_text(field, value):
    """The expression text of a field: all of `if:`, only `${{ }}` elsewhere."""
    if field == "if":
        return "\n".join(_strings(value)) if not isinstance(value, bool) else ""
    return "\n".join(m for s in _strings(value) for m in EXPRESSION.findall(s))


def _secrets(value):
    return sorted({name for text in _strings(value) for name in SECRET_REF.findall(text)})


def _scalar(value):
    """A matrix or input value as GitHub renders it into a string."""
    if isinstance(value, bool):
        return "true" if value else "false"
    if value is None:
        return ""
    if isinstance(value, (dict, list)):
        return json.dumps(value)
    return str(value)


_MISSING = object()


def _lookup(mapping, dotted):
    current = mapping
    for part in dotted.split("."):
        if not isinstance(current, dict) or part not in current:
            return _MISSING
        current = current[part]
    return current


def render(value, matrix=None, inputs=None, complete=False):
    """Substitute `${{ matrix.x }}` and `${{ inputs.x }}` where the value is known.

    With `complete`, `matrix` is the job's whole assignment: a key it lacks
    renders empty, as GitHub evaluates a missing matrix property (a key only
    some `include:` entries define, for instance).
    """
    if isinstance(value, str):
        def substitute(m):
            expr = m.group(1).strip()
            ref = re.fullmatch(r"matrix\.([A-Za-z0-9_.-]+)", expr)
            if ref and matrix:
                found = _lookup(matrix, ref.group(1))
                if found is not _MISSING:
                    return _scalar(found)
                if complete:
                    return ""
            ref = re.fullmatch(r"inputs\.([A-Za-z0-9_-]+)", expr)
            if ref and inputs and ref.group(1) in inputs:
                known = inputs[ref.group(1)]
                if not (isinstance(known, str) and EXPRESSION.search(known)):
                    return _scalar(known)
            return m.group(0)
        return EXPRESSION.sub(substitute, value)
    if isinstance(value, dict):
        return {k: render(v, matrix, inputs, complete) for k, v in value.items()}
    if isinstance(value, list):
        return [render(v, matrix, inputs, complete) for v in value]
    return value


def _missing_matrix_keys(value, matrix):
    """Plain `matrix.<path>` references `matrix` has no value for."""
    return sorted({ref for text in _strings(value) for expr in EXPRESSION.findall(text)
                   for ref in re.findall(r"^\s*matrix\.([A-Za-z0-9_.-]+)\s*$", expr)
                   if _lookup(matrix, ref) is _MISSING})


def _matrix_assignment(matrix):
    """`matrix` if it is one assignment ({"python": "3.12"}), else None.

    A strategy definition ({"python": ["3.10", "3.12"]}, include/exclude)
    is not an assignment.
    """
    if not isinstance(matrix, dict) or not matrix:
        return None
    if "include" in matrix or "exclude" in matrix:
        return None
    if any(isinstance(v, list) for v in matrix.values()):
        return None
    return matrix


def _partial_match(assignment, combination):
    return all(_scalar(combination.get(k)) == _scalar(v) for k, v in assignment.items()
               if k in combination)


def _evaluated(base, combination):
    """`${{ }}` expressions over the matrix evaluated with GitHub's semantics
    (`matrix.python.version || matrix.python`, `format(...)`, conditionals); an
    expression that needs another context stays for template matching."""
    def substitute(m):
        try:
            value, _ = evaluate(m.group(1).strip(), {"matrix": combination})
        except Exception:            # an expression the evaluator does not parse
            return m.group(0)
        return m.group(0) if isinstance(value, Unknown) else to_string(value)
    return EXPRESSION.sub(substitute, base)


def _matrix_from_name(api_name, matrix):
    """A runtime-computed matrix's assignment read back from the API job name.

    GitHub names a matrix job "<base> (v1, v2, ...)" with one value per matrix
    key in declaration order, so the values are known even when the key lists
    are expressions (e.g. `fromJSON(needs.x.outputs.y)`). None if they don't line up.
    """
    if not isinstance(matrix, dict):
        return None
    keys = [k for k in matrix if k not in ("include", "exclude")]
    found = re.search(r"\(([^()]*)\)\s*$", api_name.split(" / ")[-1])
    if not keys or not found:
        return None
    values = [v.strip() for v in found.group(1).split(",")]
    return dict(zip(keys, values)) if len(values) == len(keys) else None


def _job_api_name(base, combination, default_keys):
    """The name GitHub gives one matrix combination of a job.

    A name with expressions is interpolated: plain matrix references
    (nested `matrix.a.b` included), then any other expression over the matrix
    alone, evaluated (`matrix.python.version || matrix.python`); expressions
    that need another context stay for template matching. A name without any
    is followed by the default keys' values.
    """
    if EXPRESSION.search(base):
        return _evaluated(render(base, combination), combination).strip()

    def shown(value):        # an object value is listed by its values: "java (11, a, b)"
        if isinstance(value, dict):
            return ", ".join(shown(v) for v in value.values())
        return _scalar(value)

    values = [shown(combination[k]) for k in default_keys
              if k in combination and combination[k] != ""]
    return f"{base} ({', '.join(values)})" if values else base


def _name_template_regex(template):
    """A job-name template with unknown expressions as a regex."""
    parts = EXPRESSION.split(template)
    # EXPRESSION.split alternates literal text and expression bodies; whitespace
    # is loose because an expression that renders empty leaves a gap or a trim
    pattern = "".join(re.escape(p).replace(r"\ ", r"\s*") if i % 2 == 0 else ".*?"
                      for i, p in enumerate(parts))
    return re.compile(r"^\s*" + pattern + r"\s*$")


def _declared_inputs(workflow):
    triggers = workflow.get("on")
    if not isinstance(triggers, dict):
        return {}
    inputs = {}
    for trigger in ("workflow_call", "workflow_dispatch"):
        spec = triggers.get(trigger)
        if isinstance(spec, dict) and isinstance(spec.get("inputs"), dict):
            for name, definition in spec["inputs"].items():
                inputs.setdefault(name, definition if isinstance(definition, dict) else {})
    return inputs


def _merged_defaults(*sources):
    merged = {}
    for source in sources:
        if isinstance(source, dict) and isinstance(source.get("run"), dict):
            merged.update(source["run"])
    return merged


# ── canonical serialization ───────────────────────────────────────────────────
# Attributes that are bulk input or traversal bookkeeping, not graph semantics.
CANONICAL_DROP = ("raw_config", "text", "matrix_context", "input_context", "slice_order",
                  "shell_ir")       # the shell IR is in the graph as shell_command nodes


def _canonical_json(value):
    return json.dumps(value, sort_keys=True, separators=(",", ":"), default=str)


def canonical_graph(graph):
    """The graph as JSON-ready data that depends only on its content.

    Nodes sorted by id, edges by (source, target, type), attribute keys sorted
    on output; insertion order and traversal bookkeeping do not show.
    """
    nodes = []
    for node in sorted(graph.nodes):
        attrs = {k: v for k, v in graph.nodes[node].items() if k not in CANONICAL_DROP}
        if "slice_reasons" in attrs:
            attrs["slice_reasons"] = sorted(attrs["slice_reasons"])
        nodes.append({"id": node, **attrs})
    edges = sorted(({"source": u, "target": v, **attrs} for u, v, attrs in graph.edges(data=True)),
                   key=lambda e: (e["source"], e["target"], e["type"], _canonical_json(e)))
    return {"nodes": nodes, "edges": edges}


def fingerprint(value):
    """A short content hash of a JSON-ready value."""
    return hashlib.sha256(_canonical_json(value).encode()).hexdigest()[:16]


class GraphWorkflowAnalyzer:
    def __init__(self, repo_path, workflow_path, job_metadata, matrix, semantics="target_execution",
                 conditions="static"):
        """`job_metadata` is the API job, optionally with the API run under "run" (event,
        branch, pull requests), which Static Condition Resolution reads. `conditions`:
        "static" resolves `if:` conditions and prunes statically false steps; "off" keeps
        every step (GWA-v1 behaviour)."""
        if semantics not in SEMANTICS:
            raise ValueError(f"semantics must be one of {SEMANTICS}")
        if conditions not in ("static", "off"):
            raise ValueError("conditions must be 'static' or 'off'")
        self.repo_path = repo_path
        self.workflow_path = workflow_path
        self.job_metadata = job_metadata or {}
        self.matrix = matrix or {}
        self.semantics = semantics
        self.conditions = conditions
        self.graph = nx.MultiDiGraph(
            job_metadata={k: self.job_metadata.get(k) for k in ("id", "name", "labels")},
            semantics=semantics, conditions=conditions, unresolved=[], diagnostics=[])
        # YAML-side registry: filled by target resolution, read only while building
        self._job_defs = {}

    # ── driver ────────────────────────────────────────────────────────────────
    def analyze(self):
        workflow = self.load_workflow()
        target_job = self.resolve_target_job(workflow)          # YAML -> target
        self.build_job_graph(workflow, target_job)              # YAML -> graph
        self.build_step_graph(workflow)
        self.resolve_actions(workflow)
        self.add_repository_manifests()
        self.analyze_shell()                                    # run scripts -> Shell Command IR
        self.analyze_data_dependencies(workflow)
        if self.conditions == "static":
            self.resolve_conditions()                           # graph -> condition-annotated graph
        self.sliced = self.backward_slice(target_job["node"])    # graph -> sliced graph
        spec = self.build_execution_spec(self.sliced)           # sliced graph -> spec
        from .gwa_validation import validate_slice
        spec["validation"] = validate_slice(self.graph, self.sliced, spec)
        return spec

    def load_workflow(self):
        with open(self.workflow_path, encoding="utf-8", errors="replace") as f:
            workflow = load_workflow_yaml(f.read())
        if not isinstance(workflow, dict) or not isinstance(workflow.get("jobs"), dict):
            raise ValueError(f"{self.workflow_path} is not a workflow with jobs")
        return workflow

    def _rel(self, path):
        try:
            return os.path.relpath(path, self.repo_path)
        except ValueError:
            return path

    def _unresolved(self, kind, detail, node=None):
        entry = {"kind": kind, "detail": detail}
        if node:
            entry["node"] = node
        if entry not in self.graph.graph["unresolved"]:
            self.graph.graph["unresolved"].append(entry)

    # ── Stage 1 (preprocessing): target resolution on the YAML ────────────────
    def _collect_jobs(self, workflow, path, scope="", depth=0, caller=None):
        """Register every job, following local reusable-workflow calls.

        Jobs of a called workflow get the caller's key as a scope prefix
        ("call/"), so jobs with the same key in two files stay distinct.
        """
        for key, job in (workflow.get("jobs") or {}).items():
            if not isinstance(job, dict):
                continue
            node = f"job:{scope}{key}"
            self._job_defs[node] = {"key": key, "scope": scope, "def": job, "workflow": workflow,
                                    "workflow_path": path, "caller": caller, "callee": None}
            uses = job.get("uses")
            if not isinstance(uses, str):
                continue
            if uses.startswith("./") and depth < MAX_CALL_DEPTH:
                called_path = os.path.join(self.repo_path, uses[2:].split("@", 1)[0])
                try:
                    with open(called_path, encoding="utf-8", errors="replace") as f:
                        called = load_workflow_yaml(f.read())
                except OSError:
                    self._unresolved("reusable_workflow", f"{uses} not found in the repository", node)
                    continue
                if isinstance(called, dict):
                    self._job_defs[node]["callee"] = called_path
                    self._collect_jobs(called, called_path, f"{scope}{key}/", depth + 1, node)
            else:
                self._unresolved("reusable_workflow",
                                 f"{uses} is not in this repository; its jobs are not analyzed", node)

    def _api_names(self, node):
        """[(API job name, matrix combination or None if unexpandable, caller's combination)]."""
        info = self._job_defs[node]
        job = info["def"]
        base = str(job.get("name", info["key"]))
        strategy = job.get("strategy") if isinstance(job.get("strategy"), dict) else {}
        matrix = strategy.get("matrix")
        if matrix is None:
            names = [(base, {})]
        elif not isinstance(matrix, dict) or any(
                not isinstance(v, list) for k, v in matrix.items()):
            names = [(base, None)]              # computed at runtime, e.g. fromJSON(...)
        else:
            try:
                defaults = [k for k in matrix if k not in ("include", "exclude")]
                names = []
                for combo in build_combinations(matrix):
                    # GitHub lists either the matrix keys' values or, with `include:`-added
                    # keys, those followed by the added ones: accept both forms
                    every = defaults + [k for k in combo if k not in defaults]
                    for keys in (defaults, every):
                        name = _job_api_name(base, combo, keys)
                        if (name, combo) not in names:
                            names.append((name, combo))
            except Exception:  # noqa: BLE001 -- a malformed matrix is just unexpandable
                names = [(base, None)]
        if info["caller"]:
            # a called job's API name is "<caller name> / <callee name>"
            return [(f"{caller_name} / {name}", combo, caller_combo)
                    for caller_name, caller_combo, _ in self._api_names(info["caller"])
                    for name, combo in names]
        return [(name, combo, None) for name, combo in names]

    def resolve_target_job(self, workflow):
        self._collect_jobs(workflow, self.workflow_path)
        api_name = str(self.job_metadata.get("name") or "").strip()
        given = _matrix_assignment(self.matrix)
        runnable = [n for n, i in self._job_defs.items() if not isinstance(i["def"].get("uses"), str)]

        candidates = [(n, name, combo, caller_combo) for n in runnable
                      for name, combo, caller_combo in self._api_names(n)]

        def pick(matches, how):
            if given and len(matches) > 1:
                narrowed = [m for m in matches if m[2] and _partial_match(given, m[2])]
                matches = narrowed or matches
            node, _, combo, caller_combo = matches[0]
            if len(matches) > 1:
                self._unresolved("job_resolution",
                                 f"{len(matches)} jobs match {api_name!r} ({how}); took {node}", node)
            return node, combo, caller_combo, how

        resolved = None
        exact = [c for c in candidates if c[1] == api_name]
        if exact:
            resolved = pick(exact, "exact API name")
        if not resolved:
            # most literal text first: a name that is only `${{ inputs.x }}` matches anything
            templated = sorted((c for c in candidates if _name_template_regex(c[1]).match(api_name)),
                               key=lambda c: -len(EXPRESSION.sub("", c[1])))
            if templated:
                resolved = pick(templated, "name template")
        if not resolved and " / " in api_name:
            # the pipeline may already have switched to the called workflow
            tail = api_name.split(" / ", 1)[1]
            tailed = [c for c in candidates if c[1] == tail or _name_template_regex(c[1]).match(tail)]
            if tailed:
                resolved = pick(tailed, "reusable-workflow job name")
        if not resolved:
            base = api_name.split(" / ")[-1].split(" (")[0].strip()
            keyed = [c for c in candidates
                     if base in (self._job_defs[c[0]]["key"],
                                 str(self._job_defs[c[0]]["def"].get("name", "")))]
            if keyed:
                resolved = pick(keyed, "job key or base name")
        if not resolved:
            if not runnable:
                raise ValueError(f"no runnable job in {self.workflow_path}")
            node = runnable[0]
            self._unresolved("job_resolution",
                             f"no job matches {api_name!r}; fell back to the first job {node}", node)
            resolved = (node, None, None, "fallback")

        node, combo, caller_combo, how = resolved
        if combo is None:
            strategy = self._job_defs[node]["def"].get("strategy")
            combo = given or (isinstance(strategy, dict)
                              and _matrix_from_name(api_name, strategy.get("matrix"))) or {}
            if isinstance(strategy, dict) and "matrix" in strategy and not combo:
                self._unresolved("matrix", "the job's matrix could not be expanded and no "
                                           "assignment was supplied", node)
        info = self._job_defs[node]
        return {"node": node, "job_key": info["key"], "scope": info["scope"],
                "api_name": api_name, "matrix": combo, "caller_matrix": caller_combo or {},
                "resolved_by": how}

    # ── Stage 2: graph construction ───────────────────────────────────────────
    def _edge(self, u, v, kind, dependency, **provenance):
        self.graph.add_edge(u, v, key=kind, type=kind, dependency=dependency,
                            **{k: p for k, p in provenance.items() if p is not None})

    def _inputs_for(self, job_node, caller_matrix=None):
        """Known `inputs.*` values of a called job: caller `with:` over declared defaults."""
        info = self._job_defs[job_node]
        values = {name: d["default"] for name, d in _declared_inputs(info["workflow"]).items()
                  if isinstance(d, dict) and "default" in d}
        if info["caller"]:
            values.update(render(self._job_defs[info["caller"]]["def"].get("with") or {}, caller_matrix))
        return values

    def build_job_graph(self, workflow, target_job):
        """Workflow and job nodes, with each job's resolved context.

        The target carries its matrix assignment; the job that calls the
        target's reusable workflow carries the caller's assignment. Other jobs'
        matrix combinations are unknown and stay unrendered.
        """
        self.graph.graph["target"] = dict(target_job)
        target = target_job["node"]
        direct_caller = self._job_defs[target]["caller"]
        for node, info in self._job_defs.items():
            source = self._rel(info["workflow_path"])
            wf_node = f"workflow:{info['scope']}{source}"
            if wf_node not in self.graph:
                self.graph.add_node(wf_node, type="reusable_workflow" if info["caller"] else "workflow",
                                    source_file=source, scope=info["scope"],
                                    declared_inputs=_declared_inputs(info["workflow"]))
                if info["caller"]:
                    self._edge(info["caller"], wf_node, "CALLS", "structural")

            if node == target:
                matrix, inputs = target_job["matrix"], self._inputs_for(node, target_job["caller_matrix"])
            elif node == direct_caller:
                matrix, inputs = target_job["caller_matrix"] or None, self._inputs_for(node)
            else:
                matrix, inputs = None, self._inputs_for(node)
            # a resolved assignment is the job's whole matrix: absent keys render empty
            complete = bool(matrix)
            job = render(info["def"], matrix, inputs, complete)
            label = f"{info['scope']}{info['key']}"

            workflow_env = render(info["workflow"].get("env"), matrix, inputs, complete)
            env = dict(workflow_env) if isinstance(workflow_env, dict) else {}
            job_env = job.get("env")
            env_expression = None
            if isinstance(job_env, dict):
                env.update(job_env)
            elif job_env:            # e.g. env: ${{ fromJSON(...) }}
                env_expression = job_env
                self._unresolved("env", f"{label} env is an expression: {job_env!r}"[:200], node)
            strategy = info["def"].get("strategy")
            combinations = {}                   # canonical json -> combination; None: unexpandable
            for _, combo, _ in self._api_names(node):
                if combo is None:
                    combinations = None
                    break
                combinations.setdefault(_canonical_json(combo), combo)
            self.graph.add_node(
                node, type="job", job_key=info["key"], scope=info["scope"], label=label,
                source_file=source, name=str(job.get("name", info["key"])),
                matrix=matrix if matrix is not None else None,
                has_matrix=isinstance(strategy, dict) and "matrix" in strategy,
                matrix_combinations=None if combinations is None else list(combinations.values()),
                runs_on=job.get("runs-on"), container=job.get("container"),
                services=job.get("services"), environment=job.get("environment"),
                condition=job.get("if"), needs=_as_list(job.get("needs")),
                outputs=job.get("outputs"), env=env, env_expression=env_expression,
                defaults_run=render(_merged_defaults(info["workflow"].get("defaults"),
                                                     info["def"].get("defaults")), matrix, inputs, complete),
                matrix_complete=complete,
                # GitHub evaluates these to "": recorded so an audit can see them
                matrix_rendered_empty=_missing_matrix_keys(info["def"], matrix) if complete else [],
                uses=job.get("uses"), call_with=job.get("with"),
                timeout_minutes=job.get("timeout-minutes"),
                continue_on_error=job.get("continue-on-error"),
                secrets=_secrets({k: v for k, v in job.items() if k != "steps"}),
                matrix_context=matrix, input_context=inputs,
                raw_config=info["def"])
            self._edge(wf_node, node, "CONTAINS", "structural")
            if isinstance(info["def"].get("uses"), str) and not info["callee"]:
                external = f"workflow:{info['def']['uses']}"
                self.graph.add_node(external, type="reusable_workflow", source_file=info["def"]["uses"],
                                    external=True)
                self._edge(node, external, "CALLS", "structural")

        for node, info in self._job_defs.items():
            condition = info["def"].get("if")
            condition = None if condition is None else str(condition)
            for needed in _as_list(info["def"].get("needs")):
                dependency = f"job:{info['scope']}{needed}"
                if dependency in self._job_defs:
                    self._edge(dependency, node, "NEEDS", "control", field="needs",
                               requires_success=_requires_success(condition, needed),
                               condition=condition)
                else:
                    self._unresolved("needs", f"{node} needs unknown job {needed!r}", node)

    def _jobs(self):
        return [n for n, a in self.graph.nodes(data=True) if a.get("type") == "job"]

    def _job_steps(self, job_node):
        return sorted((n for n, a in self.graph.nodes(data=True)
                       if a.get("type") == "step" and a["job"] == job_node),
                      key=lambda n: self.graph.nodes[n]["index"])

    def build_step_graph(self, workflow):
        for job_node in self._jobs():
            job = self.graph.nodes[job_node]
            previous = None
            for index, raw in enumerate(job["raw_config"].get("steps") or []):
                if not isinstance(raw, dict):
                    continue
                step = render(raw, job["matrix_context"], job["input_context"], job["matrix_complete"])
                step_node = f"step:{job['label']}:{index}"
                run = step.get("run") if isinstance(step.get("run"), str) else None
                uses = step["uses"].strip() if isinstance(step.get("uses"), str) else None
                label = step.get("name") or uses or ((run or "").strip().splitlines() or [""])[0][:80]
                self.graph.add_node(
                    step_node, type="step", job=job_node, job_key=job["job_key"], scope=job["scope"],
                    job_label=job["label"], index=index, source_file=job["source_file"],
                    kind="run" if run is not None else ("action" if uses else "other"),
                    role="command", name=str(label), display_name=step.get("name"),
                    step_id=raw.get("id"), command=run, uses=uses, with_=step.get("with"),
                    env=step.get("env"), working_directory=step.get("working-directory"),
                    shell=step.get("shell"), condition=step.get("if"),
                    continue_on_error=step.get("continue-on-error"),
                    timeout_minutes=step.get("timeout-minutes"),
                    present=[k for k in raw],          # which fields the YAML declared
                    action=None, expanded_steps=None, secrets=_secrets(step), raw_config=raw)
                self._edge(job_node, step_node, "CONTAINS", "structural")
                if previous:
                    # conservative: later steps may rely on earlier steps' shell side effects
                    self._edge(previous, step_node, "PRECEDES", "order")
                if run is not None:
                    command = f"command:{job['label']}:{index}"
                    self.graph.add_node(command, type="command", text=run, job=job_node, index=index,
                                        source_file=job["source_file"])
                    self._edge(step_node, command, "EXECUTES", "structural")
                if uses:
                    action = f"action:{uses}"
                    if action not in self.graph:
                        self.graph.add_node(action, type="action", uses=uses,
                                            name=_action_name(uses), ref=_action_ref(uses))
                    self._edge(step_node, action, "USES", "structural")
                previous = step_node

    # ── actions ───────────────────────────────────────────────────────────────
    def _load_local_action(self, uses, checkout_paths=()):
        """A local action's definition.

        `./x` is relative to the workspace; a job that checks the repository
        out under `path: source` refers to its actions as `./source/...`.
        """
        relative = os.path.normpath(uses[2:].split("@", 1)[0])
        candidates = [relative] + [relative[len(p) + 1:] for p in checkout_paths
                                   if relative.startswith(p + os.sep)]
        for candidate in candidates:
            for name in ("action.yml", "action.yaml"):
                path = os.path.join(self.repo_path, candidate, name)
                if os.path.isfile(path):
                    with open(path, encoding="utf-8", errors="replace") as f:
                        return load_workflow_yaml(f.read()), path
        return None, None

    def _checkout_paths(self, job_node):
        """The `path:` each checkout step of a job puts the repository under."""
        paths = []
        for step in self._job_steps(job_node):
            attrs = self.graph.nodes[step]
            if attrs["uses"] and _matches_action(attrs["uses"], ("actions/checkout",)):
                path = (attrs["with_"] or {}).get("path")
                if isinstance(path, str) and path.strip() and not EXPRESSION.search(path):
                    paths.append(os.path.normpath(path.strip()))
        return paths

    def _expand_composite(self, uses, depth, checkout_paths=()):
        """The steps of a local composite action, nested local ones expanded."""
        action, path = self._load_local_action(uses, checkout_paths)
        if not isinstance(action, dict):
            return None, None
        runs = action.get("runs") if isinstance(action.get("runs"), dict) else {}
        kind = str(runs.get("using", "unknown"))
        if kind != "composite":
            return {"kind": kind, "path": self._rel(path)}, None
        steps = []
        for step in runs.get("steps") or []:
            if not isinstance(step, dict):
                continue
            entry = {k: step[k] for k in ("name", "id", "if", "run", "shell", "uses", "with", "env",
                                          "working-directory") if k in step}
            inner = step.get("uses")
            if isinstance(inner, str) and inner.startswith("./") and depth < MAX_CALL_DEPTH:
                info, nested = self._expand_composite(inner, depth + 1, checkout_paths)
                entry["action"] = info
                if nested:
                    entry["expanded"] = nested
            steps.append(entry)
        return {"kind": "composite", "path": self._rel(path),
                "inputs": action.get("inputs") or {}}, steps

    @staticmethod
    def _classify(uses):
        if uses.startswith("./"):
            return "local_action"
        if uses.startswith("docker://"):
            return "docker_action"
        for role, names in ROLE_ACTIONS.items():
            if _matches_action(uses, names):
                return role
        if _matches_action(uses, RUNTIME_ACTIONS):
            return "runtime_setup"
        if _matches_action(uses, TOOL_ACTIONS):
            return "tool_setup"
        return "other_action"

    def resolve_actions(self, workflow):
        for step_node in [n for n, a in self.graph.nodes(data=True) if a.get("type") == "step"]:
            step = self.graph.nodes[step_node]
            uses = step["uses"]
            if uses:
                step["role"] = self._classify(uses)
                action_node = f"action:{uses}"
                if step["role"] == "local_action":
                    action, expanded = self._expand_composite(uses, 1, self._checkout_paths(step["job"]))
                    if action is None:
                        self._unresolved("action", f"local action {uses} has no action.yml", step_node)
                        action = {"kind": "missing"}
                    step["action"] = action
                    if expanded:
                        # inside a composite action `inputs` are the action's: its defaults
                        # overridden by this step's `with:`
                        declared = action.get("inputs") or {}
                        action_inputs = {name: d["default"] for name, d in declared.items()
                                         if isinstance(d, dict) and "default" in d}
                        action_inputs.update(step["with_"] or {})
                        job = self.graph.nodes[step["job"]]
                        step["expanded_steps"] = render(expanded, job["matrix_context"], action_inputs,
                                                        job["matrix_complete"])
                    self.graph.nodes[action_node].update(kind=action["kind"], local=True,
                                                         path=action.get("path"))
                else:
                    step["action"] = {"kind": "docker" if uses.startswith("docker://") else "remote",
                                      "name": _action_name(uses), "ref": _action_ref(uses)}
                    self.graph.nodes[action_node].update(kind=step["action"]["kind"], local=False)
            step["package_managers"] = self._step_package_managers(step)

    @staticmethod
    def _walk(step):
        """The step itself and every expanded composite step inside it, in order."""
        yield {"uses": step.get("uses"), "with": step.get("with_"), "run": step.get("command")}
        stack = list(reversed(step.get("expanded_steps") or []))
        while stack:
            entry = stack.pop()
            yield entry
            stack.extend(reversed(entry.get("expanded") or []))

    def _step_package_managers(self, step):
        found = {}
        analyses = step.get("shell_ir") or {}
        for position, entry in enumerate(self._walk(step)):
            uses = entry.get("uses")
            if isinstance(uses, str) and _matches_action(uses, TOOL_ACTIONS):
                tool = TOOL_ACTIONS[_matched_action(uses, TOOL_ACTIONS)]
                found.setdefault(tool, {"name": tool, "source": "action", "evidence": uses})
            run = entry.get("run")
            parsed = analyses.get("step" if position == 0 else f"composite:{position}")
            if parsed is not None and parsed["parsed_by"] != "unsupported":
                for command in parsed["commands"]:
                    for program in [command["program"]] + [v.split()[0] for v in command["via"]]:
                        name = MANAGER.get(program)
                        if name and name not in found:
                            found[name] = {"name": name, "source": "command", "evidence": command["text"][:120]}
                    for item in command["installs"]:
                        name = MANAGER.get(item["manager"], item["manager"])
                        if name not in found:
                            found[name] = {"name": name, "source": "command", "evidence": command["text"][:120]}
            elif isinstance(run, str):
                for name, pattern in PACKAGE_MANAGER_COMMANDS.items():
                    match = re.search(pattern, run, re.MULTILINE)
                    if match and name not in found:
                        found[name] = {"name": name, "source": "command",
                                       "evidence": match.group(0).strip()}
        return list(found.values())

    # ── repository manifests ──────────────────────────────────────────────────
    def _manifest(self, path, how=None):
        """The resource node of a repository file, created on first reference."""
        path = os.path.normpath(path.strip("'\""))       # "./a/../b.txt" -> "b.txt"
        node = f"file:{path}"
        if node not in self.graph:
            full = os.path.join(self.repo_path, path)
            exists = os.path.isfile(full)
            attrs = {"type": "resource", "resource_type": "dependency_manifest", "path": path,
                     "exists": exists, "discovered_by": how or "repository scan"}
            if os.path.basename(path) in VERSION_FILES:
                attrs["resource_type"] = "version_file"
                attrs["version"] = None
                if exists:
                    with open(full, encoding="utf-8", errors="replace") as f:
                        lines = [line.strip() for line in f.read(4096).splitlines()
                                 if line.strip() and not line.startswith("#")]
                    attrs["version"] = lines[0] if lines else None
            self.graph.add_node(node, **attrs)
        return node

    def add_repository_manifests(self):
        """Every dependency manifest near the repository root, as an unconnected resource.

        A manifest enters a slice only through a CONSUMES edge from a step
        that references it, explicitly or by conservative inference.
        """
        root = os.path.abspath(self.repo_path)
        root_depth = root.rstrip(os.sep).count(os.sep)
        for directory, subdirs, names in os.walk(root):
            subdirs[:] = sorted(d for d in subdirs if d not in SKIP_DIRS and not d.startswith("."))
            if directory.rstrip(os.sep).count(os.sep) - root_depth >= 2:
                subdirs[:] = []
            for name in sorted(names):
                if name in DEPENDENCY_FILES or any(fnmatch.fnmatch(name, p)
                                                   for p in DEPENDENCY_FILE_PATTERNS):
                    self._manifest(os.path.relpath(os.path.join(directory, name), root))

    # ── Stage 2b: dependency analysis ─────────────────────────────────────────
    def _resource(self, rid, resource_type, **attrs):
        if rid not in self.graph:
            self.graph.add_node(rid, type="resource", resource_type=resource_type, **attrs)
        return rid

    def _flow(self, producer, resource, consumer=None, kind="CONSUMES", **provenance):
        """producer -PRODUCES-> resource -kind-> consumer, classed by the resource type."""
        dependency = RESOURCE_DEPENDENCY[self.graph.nodes[resource]["resource_type"]]
        if producer is not None:
            self._edge(producer, resource, "PRODUCES", dependency)
        if consumer is not None:
            self._edge(resource, consumer, kind, dependency, **provenance)

    def analyze_data_dependencies(self, workflow):
        self._step_ids = {(a["job"], a["step_id"]): n for n, a in self.graph.nodes(data=True)
                          if a.get("type") == "step" and a.get("step_id")}
        for job_node in self._jobs():
            job = self.graph.nodes[job_node]
            consumers = [(job_node, field, _expression_text(field, job["raw_config"][field]))
                         for field in JOB_FIELDS if job["raw_config"].get(field) is not None]
            for step_node in self._job_steps(job_node):
                raw = self.graph.nodes[step_node]["raw_config"]
                consumers += [(step_node, field, _expression_text(field, raw[field]))
                              for field in STEP_FIELDS if raw.get(field) is not None]
            for consumer, field, text in consumers:
                self._link_job_outputs(job, consumer, field, text)
                self._link_step_outputs(job_node, consumer, field, text)
                self._link_inputs(job, consumer, field, text)
                for key in sorted(set(MATRIX_REF.findall(text))):
                    matrix = self._resource(f"resource:matrix:{job['label']}.{key}", "matrix", name=key)
                    self._flow(None, matrix, consumer, "CONFIGURES", field=field,
                               expression=f"matrix.{key}")
            self._link_environment(job_node, job)
        self._link_artifacts()
        self._link_manifests()
        self._link_shell_dependencies()

    def _link_job_outputs(self, job, consumer, field, text):
        """needs.<job>.outputs.<name>: a data dependency on another job."""
        for producer_key, output in sorted(set(NEEDS_OUTPUT.findall(text))):
            producer = f"job:{job['scope']}{producer_key}"
            expression = f"needs.{producer_key}.outputs.{output}"
            resource = self._resource(f"resource:output:{job['scope']}{producer_key}.{output}",
                                      "job_output", job=producer, name=output)
            self._flow(None, resource, consumer, field=field, expression=expression)
            if producer not in self.graph:
                self._unresolved("job_output", f"{expression}: no job {producer_key!r}", consumer)
                continue
            outputs = self.graph.nodes[producer]["raw_config"].get("outputs") or {}
            if output not in outputs:
                self._unresolved("job_output", f"{producer} declares no output {output!r}", consumer)
                self._flow(producer, resource)
                continue
            linked = False
            for step_id, _ in sorted(set(STEP_OUTPUT.findall(
                    "\n".join(EXPRESSION.findall(str(outputs[output])))))):
                step = self._step_ids.get((producer, step_id))
                if step:
                    self._flow(step, resource)
                    linked = True
            if not linked:
                # a literal, an env value or a called workflow's output: the job produces it
                self._flow(producer, resource)

    def _link_step_outputs(self, job_node, consumer, field, text):
        """steps.<id>.outputs.<name> and steps.<id>.outcome inside one job."""
        references = {(s, o) for s, o in STEP_OUTPUT.findall(text)}
        references |= {(s, None) for s in STEP_STATUS.findall(text)}
        for step_id, output in sorted(references, key=lambda r: (r[0], r[1] or "")):
            producer = self._step_ids.get((job_node, step_id))
            label = f"{step_id}.{output}" if output else f"{step_id}.outcome"
            resource = self._resource(f"resource:step-output:{job_node[4:]}:{label}", "step_output",
                                      job=job_node, name=label)
            self._flow(producer, resource, consumer, field=field, expression=f"steps.{label}")
            if not producer:
                self._unresolved("step_output", f"steps.{label}: no step with id {step_id!r} "
                                                f"in {job_node}", consumer)

    def _link_inputs(self, job, consumer, field, text):
        """inputs.<name> in a called workflow comes from the caller's `with:`."""
        names = sorted(set(INPUT_REF.findall(text)))
        if not names:
            return
        workflow = next(u for u, _, k in self.graph.in_edges(f"job:{job['label']}", keys=True)
                        if k == "CONTAINS")
        declared = self.graph.nodes[workflow]["declared_inputs"]
        caller = next((u for u, _, k in self.graph.in_edges(workflow, keys=True) if k == "CALLS"), None)
        passed = (self.graph.nodes[caller]["raw_config"].get("with") or {}) if caller else {}
        for name in names:
            resource = self._resource(f"resource:input:{job['scope']}{name}", "input", name=name)
            producer = caller if caller and name in passed else None
            self._flow(producer, resource, consumer, field=field, expression=f"inputs.{name}")
            if producer is None and "default" not in (declared.get(name) or {}):
                self._unresolved("input", f"inputs.{name} has no caller value or default", consumer)

    def _setup_occurrences(self, step):
        """(position, uses, with) of each runtime/tool setup in a step and its composite expansion."""
        for position, entry in enumerate(self._walk(step)):
            uses = entry.get("uses")
            if isinstance(uses, str):
                yield position, uses, entry.get("with") or {}

    def _runtime_resource(self, step_node, step, position, uses, arguments):
        runtime, keys = RUNTIME_ACTIONS[_matched_action(uses, RUNTIME_ACTIONS)]
        version, from_key = None, None
        for key in keys:
            if key in arguments:
                version, from_key = arguments[key], key
                break
        if version is None and _matches_action(uses, ("dtolnay/rust-toolchain",)):
            version, from_key = _action_ref(uses), "ref"            # @stable, @1.75.0
        attrs = {"runtime": runtime, "version": version, "action": uses,
                 "source": f"{step['job_label']} step {step['index']}",
                 "position": [step["index"], position], "job": step["job"]}
        for extra in ("distribution", "architecture", "cache"):
            if extra in arguments:
                attrs[extra] = arguments[extra]
        resource = self._resource(f"resource:runtime:{step_node[5:]}.{position}", "runtime", **attrs)
        if from_key and from_key.endswith("-file") and isinstance(version, str):
            version_file = self._manifest(version, f"with.{from_key}")
            self._flow(None, version_file, step_node, field=f"with.{from_key}", expression=version)
            file_attrs = self.graph.nodes[version_file]
            if not file_attrs["exists"]:
                self._unresolved("runtime", f"version file {version} is not in the repository")
            self.graph.nodes[resource].update(version_file=version, version=file_attrs.get("version"))
        return resource

    def _link_environment(self, job_node, job):
        """Runner, container, services, env and set-up steps as CONFIGURES edges."""
        for label in _as_list(job["raw_config"].get("runs-on")):
            if isinstance(label, dict):                     # runs-on: {group:, labels:}
                label = json.dumps(label, sort_keys=True)
            runner = self._resource(f"resource:runner:{label}", "runner", name=str(label))
            self._flow(None, runner, job_node, "CONFIGURES", field="runs-on")
        container = job["raw_config"].get("container")
        if container:
            image = container.get("image") if isinstance(container, dict) else container
            resource = self._resource(f"resource:container:{image}", "container", image=str(image))
            self._flow(None, resource, job_node, "CONFIGURES", field="container")
        services = job["raw_config"].get("services")
        for name, service in (services.items() if isinstance(services, dict) else []):
            image = service.get("image") if isinstance(service, dict) else service
            resource = self._resource(f"resource:service:{job['label']}.{name}", "service",
                                      name=name, image=str(image))
            self._flow(None, resource, job_node, "CONFIGURES", field="services")
        workflow = next(u for u, _, k in self.graph.in_edges(job_node, keys=True) if k == "CONTAINS")
        workflow_env = self._job_defs[job_node]["workflow"].get("env")
        for level, env in (("workflow", workflow_env), ("job", job["raw_config"].get("env"))):
            for variable in (env if isinstance(env, dict) else {}):
                owner = self.graph.nodes[workflow]["scope"] + "workflow" if level == "workflow" \
                    else job["label"]
                resource = self._resource(f"resource:env:{owner}.{variable}", "env",
                                          name=variable, level=level)
                self._flow(None, resource, job_node, "CONFIGURES", field="env")

        steps = self._job_steps(job_node)
        for position, step_node in enumerate(steps):
            step = self.graph.nodes[step_node]
            produced = []
            for sub, uses, arguments in self._setup_occurrences(step):
                if _matches_action(uses, RUNTIME_ACTIONS):
                    produced.append(self._runtime_resource(step_node, step, sub, uses, arguments))
                elif sub == 0 and _matches_action(uses, TOOL_ACTIONS):
                    tool = TOOL_ACTIONS[_matched_action(uses, TOOL_ACTIONS)]
                    produced.append(self._resource(f"resource:tool:{step_node[5:]}", "tool", name=tool,
                                                   action=uses))
            if step["command"] is not None and WRITES_ENV_FILE.search(step["command"]):
                # writes $GITHUB_ENV / $GITHUB_PATH: every later step sees the change
                produced.append(self._resource(f"resource:env-file:{step_node[5:]}", "env_file"))
            for resource in produced:
                self._flow(step_node, resource)
                for consumer in steps[position + 1:]:
                    self._flow(None, resource, consumer, "CONFIGURES")

    def _link_artifacts(self):
        uploads, downloads = [], []
        for step_node, step in self.graph.nodes(data=True):
            if step.get("type") != "step" or not step["uses"]:
                continue
            arguments = step["raw_config"].get("with") or {}
            if step["role"] == "artifact_upload":
                uploads.append((step_node, str(arguments.get("name", "artifact"))))
            elif step["role"] == "artifact_download":
                downloads.append((step_node, arguments))
        for step_node, name in uploads:
            resource = self._resource(f"resource:artifact:{name}", "artifact", name=name)
            self._flow(step_node, resource)
        for step_node, arguments in downloads:
            if "run-id" in arguments or "repository" in arguments:
                self._unresolved("artifact", "downloads an artifact from another workflow run",
                                 step_node)
                continue
            wanted = arguments.get("name") or arguments.get("pattern")
            wanted = EXPRESSION.sub("*", str(wanted)) if wanted else "*"
            matched = [n for s, n in uploads
                       if fnmatch.fnmatch(EXPRESSION.sub("*", n), wanted) or fnmatch.fnmatch(n, wanted)]
            if not matched:
                self._unresolved("artifact", f"artifact {wanted!r} is not uploaded by this "
                                             f"workflow (another workflow or run)", step_node)
            for name in matched:
                self._flow(None, f"resource:artifact:{name}", step_node, field="with",
                           expression=wanted)

    def _working_directory(self, step):
        directory = step["working_directory"] or \
            (self.graph.nodes[step["job"]]["defaults_run"] or {}).get("working-directory") or "."
        return "." if EXPRESSION.search(str(directory)) else str(directory)

    def _glob_manifests(self, pattern):
        """The scanned repository manifests a glob such as `**/go.sum` matches."""
        pattern = pattern[2:] if pattern.startswith("./") else pattern
        patterns = {pattern, pattern[3:]} if pattern.startswith("**/") else {pattern}  # ** spans root too
        return [n for n, a in self.graph.nodes(data=True)
                if a.get("resource_type") in ("dependency_manifest", "version_file") and a["exists"]
                and any(fnmatch.fnmatch(a["path"], p) for p in patterns)]

    def _link_manifests(self):
        """Manifests an action step names in `with.cache-dependency-path`. What `run:`
        commands read is the shell analysis's (_link_shell_dependencies)."""
        for step_node, step in list(self.graph.nodes(data=True)):
            if step.get("type") != "step":
                continue
            for entry in self._walk(step):
                for key, value in (entry.get("with") or {}).items():
                    if not (isinstance(value, str) and key == "cache-dependency-path"):
                        continue
                    for line in (line.strip() for line in value.splitlines()):
                        if not line or EXPRESSION.search(line):
                            continue
                        if any(c in line for c in "*?["):
                            matches = self._glob_manifests(line)
                        else:
                            matches = [self._manifest(line, f"with.{key}")]
                        for manifest in matches:
                            self._flow(None, manifest, step_node, field=f"with.{key}",
                                       expression=line, inferred=False)

    # ── Stage 2b': shell-aware dependency analysis (GWA-v3) ───────────────────
    def _shell_env(self, job, step, entry=None):
        """Literal environment values a script sees (job, step, composite entry)."""
        env = {}
        for source in (job.get("env"), step.get("env"), (entry or {}).get("env")):
            if isinstance(source, dict):
                env.update({str(k): (str(v) if isinstance(v, (str, int, float, bool)) else None)
                            for k, v in source.items()})
        return env

    @staticmethod
    def _static_directory(directory):
        """A working-directory as a workspace-relative path; None if it depends on the run.
        `${{ github.workspace }}` and $GITHUB_WORKSPACE are the workspace root."""
        directory = str(directory or ".")
        directory = re.sub(r"^(?:\$\{\{\s*github\.workspace\s*\}\}|\$\{?GITHUB_WORKSPACE\}?)/?", "./", directory)
        if EXPRESSION.search(directory) or "$" in directory or directory.startswith(("/", "~")):
            return None
        return os.path.normpath(directory)

    def analyze_shell(self):
        """Parse every `run:` script (and those of expanded composite steps) into the
        Shell Command IR; one `shell_command` node per command, EXECUTED by the
        step's `command` node (or the step, for composite steps)."""
        g = self.graph
        target = g.graph["target"]["node"]
        metadata_labels = list(self.job_metadata.get("labels") or [])
        for job_node in self._jobs():
            job = g.nodes[job_node]
            labels = metadata_labels if job_node == target and metadata_labels else _as_list(job["runs_on"])
            runner_os = self._runner_context(labels).get("os")
            default_shell = (job["defaults_run"] or {}).get("shell")
            for step_node in self._job_steps(job_node):
                step = g.nodes[step_node]
                analyses = {}
                if step["command"] is not None:
                    cwd = self._static_directory(step["working_directory"] or
                                                 (job["defaults_run"] or {}).get("working-directory"))
                    analyses["step"] = analyze_script(step["command"], step["shell"] or default_shell, runner_os,
                                                      cwd, self._shell_env(job, step))
                for position, entry in enumerate(self._walk(step)):
                    if position == 0 or not isinstance(entry.get("run"), str):
                        continue
                    analyses[f"composite:{position}"] = analyze_script(
                        entry["run"], entry.get("shell"), runner_os, self._static_directory(entry.get("working-directory")),
                        self._shell_env(job, step, entry), os.path.normpath(step["uses"][2:].split("@", 1)[0]))
                if not analyses:
                    continue
                step["shell_ir"] = analyses
                for origin, analysis in analyses.items():
                    parent = f"command:{job['label']}:{step['index']}" if origin == "step" else step_node
                    for command in analysis["commands"]:
                        node = f"shell:{job['label']}:{step['index']}:" + \
                               (f"{command['position']}" if origin == "step" else f"{origin}:{command['position']}")
                        g.add_node(node, type="shell_command", job=job_node, step=step_node, origin=origin,
                                   source_file=job["source_file"], **command)
                        command["node"] = node
                        self._edge(parent, node, "EXECUTES", "structural")
                    if analysis["parsed_by"] == "unsupported":
                        self._unresolved("shell", f"{step_node} ({origin}): shell {analysis['declared_shell']!r} "
                                                  f"is not analysed; its dependencies are unknown", step_node)
                    for error in analysis["parse_errors"]:
                        self._unresolved("shell", f"{step_node} ({origin}): shell syntax not fully parsed "
                                                  f"({error}); later commands may be missing", step_node)
                step["package_managers"] = self._step_package_managers(step)

    def _repository_path(self, path, checkouts):
        """The repository-relative path of workspace path `path` under one of the
        checkouts (their `path:` prefixes), and whether it exists; None if none applies."""
        for _, _, prefix in reversed(checkouts):
            if prefix in (".", ""):
                rel = path
            elif path == prefix or path.startswith(prefix + "/"):
                rel = os.path.relpath(path, prefix)
            else:
                continue
            full = os.path.join(self.repo_path, rel)
            return rel, os.path.exists(full)
        return None, False

    def _file_resource(self, rel, exists, installs=False):
        """A repository file read by a command: a dependency manifest if its name says so or an
        installation reads it (`pip install -r test.txt`), else a plain repository file."""
        name = os.path.basename(rel)
        if installs and not os.path.isdir(os.path.join(self.repo_path, rel)) or \
                name in DEPENDENCY_FILES or name in VERSION_FILES or \
                any(fnmatch.fnmatch(name, p) for p in DEPENDENCY_FILE_PATTERNS):
            return self._manifest(rel, "shell analysis")
        node = f"file:{rel}"
        if node not in self.graph:
            self.graph.add_node(node, type="resource", resource_type="repository_file", path=rel,
                                exists=exists, directory=os.path.isdir(os.path.join(self.repo_path, rel)),
                                discovered_by="shell analysis")
        return node

    def _link_read(self, read, path, ancestor, command, local, writes, checkouts, link, job_node, label, step_node):
        """Link one read of `path`; True when the read is accounted for (by an earlier command of the
        step, an earlier step's write or a repository file), False to try the next candidate."""
        g = self.graph
        why = read["why"] + (f" (nearest {read['name']} above {read['base']})" if ancestor else "")
        if any(path == p or (d and path.startswith(p + "/")) for p, d in local):
            read["satisfied_by"] = "earlier command in this step"
            return True
        exact = next((w for w in reversed(writes) if path == w["path"] or
                      (w["directory"] and w["path"] != "." and path.startswith(w["path"] + "/"))), None)
        partial = [w for w in writes if w is not exact and
                   ((w["directory"] and w["path"] == ".") or
                    (read.get("directory") and w["path"].startswith(path + "/")))]
        for w in ([exact] if exact else []) + partial[-1:]:
            resource = self._resource(
                f"resource:workspace_file:{label}:{w['path']}@{g.nodes[w['step']]['index']}",
                "workspace_file", path=w["path"], directory=w["directory"], job=job_node)
            confidence = max(read["confidence"], w["confidence"], key=CONFIDENCE_RANK.get)
            if w is not exact:
                confidence = "possible"
            link(resource, "CONSUMES", command, confidence, f"{why}; written by {w['step']} ({w['why']})")
            read.setdefault("linked", []).append(resource)
        if exact:
            return True
        rel, exists = self._repository_path(path, checkouts)
        if rel is None:
            if read["confidence"] == "explicit" and not partial:
                command["unresolved"].append(f"reads {path}: no earlier checkout or step provides it")
            return read["confidence"] == "explicit"
        if not exists and read["confidence"] != "explicit":
            return False                              # a convention file that is not there
        resource = self._file_resource(rel, exists, command["kind"] == "dependency_installation"
                                       and not read.get("directory"))
        link(resource, "CONSUMES", command, read["confidence"], why)
        checkout = next(c for c in reversed(checkouts) if self._repository_path(path, [c])[0] is not None)
        link(checkout[1], "CONSUMES", command, read["confidence"], f"repository file {rel}")
        read.setdefault("linked", []).append(resource)
        if ancestor:
            read["found_at"] = rel
        if not exists:
            self._unresolved("shell", f"{step_node} reads {rel}, which is not in the repository "
                                      f"at this commit and no earlier step writes it", step_node)
        return True

    def _link_shell_dependencies(self):
        """Resource edges from the Shell Command IR, per job in step order:
          - a read is linked to the latest earlier step in the job that writes the
            path (or a directory containing it): a reaching definition. Writes
            earlier in the same step need no edge;
          - otherwise to the repository file, through the latest earlier checkout
            of this repository; implicit reads only of files that exist;
          - an install produces a package environment; later commands of that
            ecosystem (and build / test commands, for system packages) consume it.
        Every edge carries the command it comes from and a confidence."""
        g = self.graph
        for job_node in self._jobs():
            label = g.nodes[job_node]["label"]
            writes, environments, checkouts = [], {}, []
            for step_node in self._job_steps(job_node):
                step = g.nodes[step_node]
                linked = set()

                def link(resource, kind, command, confidence, why, path=None):
                    key = (resource, kind)
                    attrs = {"field": "run", "expression": command["text"][:200], "command": command["node"],
                             "confidence": confidence, "inferred": confidence != "explicit", "why": why}
                    if key in linked:
                        edge = g.edges[resource, step_node, kind]
                        if CONFIDENCE_RANK[confidence] < CONFIDENCE_RANK[edge["confidence"]]:
                            edge.update(attrs)
                        return
                    linked.add(key)
                    self._flow(None, resource, step_node, kind, **attrs)

                uses = step["uses"] or ""
                if uses and _matches_action(uses, ("actions/checkout",)):
                    with_ = step["with_"] or {}
                    prefix = with_.get("path") if isinstance(with_.get("path"), str) else "."
                    prefix = None if EXPRESSION.search(prefix) else os.path.normpath(prefix.strip() or ".")
                    other = with_.get("repository")
                    if prefix is not None and not other:
                        resource = self._resource(f"resource:checkout:{label}@{step['index']}", "checkout",
                                                  path=prefix, job=job_node)
                        self._flow(step_node, resource)
                        checkouts.append((step_node, resource, prefix))
                    elif prefix is not None:                  # another repository: its files are writes
                        writes.append({"path": prefix, "directory": True, "step": step_node,
                                       "confidence": "explicit", "why": f"checkout of {other}"})
                elif uses and _matches_action(uses, ("actions/download-artifact",)):
                    path = (step["with_"] or {}).get("path") or "."
                    if isinstance(path, str) and not EXPRESSION.search(path):
                        writes.append({"path": os.path.normpath(path), "directory": True, "step": step_node,
                                       "confidence": "explicit", "why": "artifact download"})

                commands = [c for analysis in (step.get("shell_ir") or {}).values() for c in analysis["commands"]]
                local = []                                 # (path, directory) written earlier in this step
                for command in commands:
                    for read in command["reads"]:
                        # a configuration file the program looks up from its directory upwards
                        # (Cargo.lock, go.mod, rust-toolchain.toml, ...): the nearest one counts
                        candidates = [(read["path"], False)]
                        base = read.get("base")
                        while read.get("search") == "upward" and base not in (None, ".", ""):
                            base = os.path.dirname(base) or "."
                            candidates.append((os.path.normpath(os.path.join(base, read["name"])), True))
                        for path, ancestor in candidates:
                            if self._link_read(read, path, ancestor, command, local, writes, checkouts, link,
                                               job_node, label, step_node):
                                break
                    local += [(w["path"], w.get("directory", False)) for w in command["writes"]]
                    for ecosystem in sorted(set(command["uses"]) |
                                            ({"system"} if command["kind"] in SYSTEM_CONSUMERS else set())):
                        for resource in environments.get(ecosystem, []):
                            link(resource, "CONFIGURES", command, "implicit",
                                 f"{command['program']} runs in the {ecosystem} environment")
                for command in commands:
                    for w in command["writes"]:
                        writes.append({"path": w["path"], "directory": w.get("directory", False),
                                       "step": step_node, "confidence": w["confidence"], "why": w["why"]})
                        resource = self._resource(f"resource:workspace_file:{label}:{w['path']}@{step['index']}",
                                                  "workspace_file", path=w["path"],
                                                  directory=w.get("directory", False), job=job_node)
                        if not any(e == "PRODUCES" for _, _, e in g.in_edges(resource, keys=True)):
                            self._edge(step_node, resource, "PRODUCES", "data", command=command["node"],
                                       confidence=w["confidence"], why=w["why"])
                    for item in command["installs"]:
                        if item.get("isolated"):              # tox: its own environments
                            continue
                        resource = self._resource(
                            f"resource:package_environment:{label}:{item['ecosystem']}@{step['index']}",
                            "package_environment", ecosystem=item["ecosystem"], job=job_node)
                        if not any(e == "PRODUCES" for _, _, e in g.in_edges(resource, keys=True)):
                            self._edge(step_node, resource, "PRODUCES", "environment", command=command["node"],
                                       confidence="explicit", why=f"{item['manager']} install")
                        if resource not in environments.setdefault(item["ecosystem"], []):
                            environments[item["ecosystem"]].append(resource)
                # workspace-file writes that come from actions (downloads, other checkouts)
                for w in writes:
                    if w["step"] == step_node:
                        resource = self._resource(
                            f"resource:workspace_file:{label}:{w['path']}@{step['index']}",
                            "workspace_file", path=w["path"], directory=w["directory"], job=job_node)
                        if not any(e == "PRODUCES" for _, _, e in g.in_edges(resource, keys=True)):
                            self._edge(step_node, resource, "PRODUCES", "data", confidence=w["confidence"],
                                       why=w["why"])

    # ── Stage 2c: Static Condition Resolution (SCR) ───────────────────────────
    def _github_context(self):
        """`github.*` known from the API run: event, repository, branch, pull request.

        For a push the API does not say whether the pushed ref was a branch or
        a tag, so `github.ref` stays unknown there; `ref_name` is known.
        `github.repository` and `repository_owner` stay unknown too: the API
        reports a repository's current name, and a renamed or transferred
        repository ran under its old one (react-native's facebook/ -> react/).
        """
        run = self.job_metadata.get("run") or {}
        known = Partial()
        event = run.get("event")
        if event:
            known["event_name"] = event
        if run.get("name"):
            known["workflow"] = run["name"]
        branch = run.get("head_branch")
        if event in ("pull_request", "pull_request_target"):
            if branch:
                known["head_ref"] = branch
            pulls = run.get("pull_requests") or []
            if pulls:
                known["base_ref"] = ((pulls[0].get("base") or {}).get("ref"))
                if event == "pull_request":
                    known["ref"] = f"refs/pull/{pulls[0]['number']}/merge"
                    known["ref_name"] = f"{pulls[0]['number']}/merge"
        elif event:
            known["head_ref"] = ""           # set only for pull request events
            known["base_ref"] = ""
            if branch:
                known["ref_name"] = branch
        return known

    @staticmethod
    def _runner_context(labels):
        """`runner.os` / `runner.arch` from runner labels, when they determine them."""
        oses, arches = set(), set()
        for label in labels:
            if not isinstance(label, str) or EXPRESSION.search(label):
                return Partial()
            name = label.lower()
            if name.startswith("ubuntu") or name == "linux":
                oses.add("Linux")
            elif name.startswith("windows"):
                oses.add("Windows")
            elif name.startswith("macos"):
                oses.add("macOS")
            if name.endswith("-arm") or "arm64" in name or name.endswith("-xlarge"):
                arches.add("ARM64")
            elif re.fullmatch(r"ubuntu-(?:latest|\d+\.\d+)|windows-(?:latest|\d+)|macos-13(?:-large)?|"
                              r"macos-\d+-large", name):
                arches.add("X64")
            elif re.fullmatch(r"macos-(?:latest|1[4-9]|2\d)", name):
                arches.add("ARM64")
        context = Partial()
        if len(oses) == 1:
            context["os"] = oses.pop()
        if len(arches) == 1:
            context["arch"] = arches.pop()
        return context

    def _env_context(self, job, step, earlier):
        """`env.*` for a step's `if:`: literal workflow, job and step env, unless an earlier step may
        have changed it (a `$GITHUB_ENV` write, or an action, which can write it too)."""
        if job["env_expression"] is not None:
            return Unknown(why="job env is an expression")
        values = dict(job["env"] or {})
        values.update(step["env"] if isinstance(step["env"], dict) else {})
        overwritten, may_set_any = set(), False
        for previous in earlier:
            attrs = self.graph.nodes[previous]
            if attrs["uses"]:
                may_set_any = True
            command = attrs["command"] or ""
            if WRITES_ENV_FILE.search(command):
                may_set_any = True
                overwritten |= set(re.findall(r"\b([A-Za-z_][A-Za-z0-9_]*)=", command))
        context = Partial() if may_set_any else {}
        for name, value in values.items():
            if name in overwritten or (isinstance(value, str) and EXPRESSION.search(value)):
                context[name] = Unknown(why=f"env.{name}")
            else:
                context[name] = value
        return context

    def _inputs_context(self, job, github):
        if job["scope"]:                     # a called workflow: the caller's `with:` and defaults
            return Partial({k: v for k, v in (job["input_context"] or {}).items()
                            if not (isinstance(v, str) and EXPRESSION.search(v))})
        event = github.get("event_name")
        if event is None or event == "workflow_dispatch":
            return Unknown(why="inputs")       # dispatch inputs are not in the run metadata
        return {}                            # other events have no inputs

    def resolve_conditions(self):
        """Annotate every job and step with TRUE / FALSE / UNKNOWN and the evidence.

        Nodes are annotated, not removed: the slicer leaves FALSE steps out of
        the executable slice, and the full graph keeps them for provenance.
        Each level sees only the contexts GitHub provides there: a job's `if:`
        has github, needs, vars and inputs; a step's adds matrix, runner, env,
        steps, job, strategy and secrets (needs, vars, steps, job, strategy and
        secrets are never known statically).
        """
        g = self.graph
        github = self._github_context()
        target = g.graph["target"]["node"]
        metadata_labels = list(self.job_metadata.get("labels") or [])
        for job_node in self._jobs():
            job = g.nodes[job_node]
            inputs = self._inputs_context(job, github)
            result, evidence = resolve_condition(job["raw_config"].get("if"), {"github": github, "inputs": inputs})
            job["condition_result"], job["condition_evidence"] = result, evidence
            labels = metadata_labels if job_node == target and metadata_labels else _as_list(job["runs_on"])
            runner = self._runner_context(labels)
            if job["matrix_complete"]:
                matrix = job["matrix_context"]
            elif not job["has_matrix"]:
                matrix = {}
            else:
                matrix = Unknown(why="matrix")
            steps = self._job_steps(job_node)
            for position, step_node in enumerate(steps):
                step = g.nodes[step_node]
                contexts = {"github": github, "inputs": inputs, "matrix": matrix, "runner": runner,
                            "env": self._env_context(job, step, steps[:position])}
                result, evidence = resolve_condition(step["raw_config"].get("if"), contexts)
                if job["condition_result"] == FALSE:
                    result, evidence = FALSE, dict(evidence, job_condition=job["condition_evidence"])
                step["condition_result"], step["condition_evidence"] = result, evidence

        # the target ran: a statically false gate on it means the evaluator or its inputs are wrong
        if g.nodes[target]["condition_result"] == FALSE:
            self._diagnose("contradiction", f"{target}'s own condition evaluates FALSE, but the job ran",
                           target)
        for needed, _, attrs in g.in_edges(target, data=True):
            if attrs["type"] == "NEEDS" and attrs.get("requires_success") is True and \
                    g.nodes[needed].get("condition_result") == FALSE:
                self._diagnose("contradiction", f"{target} requires {needed} to succeed, but {needed}'s "
                                                f"condition evaluates FALSE (it would be skipped)", needed)

    def _diagnose(self, kind, detail, node=None):
        entry = {"kind": kind, "detail": detail, **({"node": node} if node else {})}
        if entry not in self.graph.graph["diagnostics"]:
            self.graph.graph["diagnostics"].append(entry)

    # ── Stage 3: target-specific backward slice (graph only) ──────────────────
    def backward_slice(self, target):
        """The subgraph the target's execution depends on.

        Rules, all on typed edges:
          - the target job keeps every step (no step-level elimination yet);
          - a kept node keeps the resources it CONSUMES or is CONFIGURED by,
            and each resource keeps its producer (data, artifact, environment
            and manifest dependencies are mandatory);
          - a kept step keeps its PRECEDES predecessors (setup side effects),
            its job, and the environment resources it produces;
          - a kept job keeps the jobs it NEEDS. Under target-execution
            semantics (the default) they are ordering-only: no state crosses
            a NEEDS edge, so their steps are not reproduced and the spec
            records the constraint. Under strict-workflow semantics they are
            control predecessors and every one of their steps is reproduced;
          - a kept job in a called workflow keeps its caller (the call site).
        With Static Condition Resolution, a step whose condition (or whose
        job's) is statically FALSE never runs:
          - it is left out of the executable slice and recorded as pruned;
          - a PRECEDES chain continues past it to the nearest step that can run;
          - it does not satisfy a dependency; a kept consumer whose resource
            has only FALSE producers gets a diagnostic. UNKNOWN steps are kept.
        Each kept node records its role and why it was kept.
        """
        g = self.graph
        kept, order, queue = {}, [], deque()
        pruned = {}

        def is_false(node):
            attrs = g.nodes[node]
            if attrs.get("condition_result") == FALSE:
                return True
            return attrs.get("type") == "step" and g.nodes[attrs["job"]].get("condition_result") == FALSE

        def prune(node, reason):
            if node not in pruned:
                attrs = g.nodes[node]
                pruned[node] = {"job": g.nodes[attrs["job"]]["label"], "index": attrs["index"],
                                "name": attrs["name"], "condition": attrs["raw_config"].get("if"),
                                "evidence": attrs.get("condition_evidence"), "reason": reason}

        def keep(node, reason, role=None):
            entry = kept.get(node)
            changed = entry is None
            if changed:
                entry = kept[node] = {"role": role, "reasons": []}
                order.append(node)
            elif role and ROLE_RANK.get(role, -1) > ROLE_RANK.get(entry["role"], -1):
                entry["role"], changed = role, True
            if reason and reason not in entry["reasons"]:
                entry["reasons"].append(reason)
            if changed:
                queue.append(node)

        def follow_dependencies(consumer):
            for resource, _, kind in g.in_edges(consumer, keys=True):
                if kind in ("CONSUMES", "CONFIGURES"):
                    keep(resource, f"{kind.lower()} by {consumer}")

        keep(target, "target job", "target")
        while queue:
            node = queue.popleft()
            attrs = g.nodes[node]
            kind = attrs.get("type")
            if kind == "job":
                if kept[node]["role"] == "ordering_only":
                    continue
                if kept[node]["role"] in ("target", "control_predecessor"):
                    for _, step, edge in g.out_edges(node, keys=True):
                        if edge != "CONTAINS":
                            continue
                        if is_false(step):
                            prune(step, "condition is statically FALSE")
                        else:
                            keep(step, f"{kept[node]['role']} job: every step that can run is kept")
                follow_dependencies(node)
                for needed, _, edge in g.in_edges(node, keys=True):
                    if edge != "NEEDS":
                        continue
                    if self.semantics == "strict_workflow":
                        keep(needed, f"needed by {node} (strict workflow: executed)",
                             "control_predecessor")
                    elif needed not in kept:
                        keep(needed, f"needed by {node} (ordering only)", "ordering_only")
                for workflow, _, edge in g.in_edges(node, keys=True):
                    if edge == "CONTAINS":
                        keep(workflow, f"contains {node}")
                        for caller, _, call in g.in_edges(workflow, keys=True):
                            if call == "CALLS":
                                keep(caller, f"calls the reusable workflow containing {node}",
                                     "call_site")
            elif kind == "step":
                if attrs["job"] not in kept:
                    keep(attrs["job"], f"contains {node}")
                follow_dependencies(node)
                for _, target_node, edge in g.out_edges(node, keys=True):
                    if edge in ("EXECUTES", "USES"):
                        keep(target_node, f"{edge.lower()} by {node}")
                    elif edge == "PRODUCES" and \
                            g.nodes[target_node].get("resource_type") in ENVIRONMENT_RESOURCES:
                        keep(target_node, f"produced by {node}")
                for previous, _, edge in g.in_edges(node, keys=True):
                    if edge != "PRECEDES":
                        continue
                    passed = []                 # statically false steps cannot have side effects
                    while previous is not None and is_false(previous):
                        passed.append(previous)
                        prune(previous, "condition is statically FALSE")
                        previous = next((u for u, _, e in g.in_edges(previous, keys=True) if e == "PRECEDES"), None)
                    if previous is not None:
                        keep(previous, f"precedes {node} (possible setup side effects)"
                                       + (f", past statically false {', '.join(passed)}" if passed else ""))
            elif kind == "command":
                for _, child, edge in g.out_edges(node, keys=True):
                    if edge == "EXECUTES":
                        keep(child, f"executed by {node}")
            elif kind == "resource":
                resource_type = attrs["resource_type"]
                producers = [u for u, _, e in g.in_edges(node, keys=True) if e == "PRODUCES"]
                unreachable = [p for p in producers if is_false(p)]
                for producer in unreachable:
                    if g.nodes[producer]["type"] == "step":
                        prune(producer, f"produces {node} but its condition is statically FALSE")
                # an install that cannot run is not a missing prerequisite: the later commands
                # run without it, so only files and data get the diagnostic
                if producers and len(unreachable) == len(producers) and resource_type != "package_environment":
                    consumers = sorted(v for _, v, e in g.out_edges(node, keys=True)
                                       if e in ("CONSUMES", "CONFIGURES") and v in kept)
                    self._diagnose("unreachable_producer",
                                   f"{node} is produced only by statically false {', '.join(unreachable)}; "
                                   f"kept consumers: {', '.join(consumers[:5])}"
                                   + (f" and {len(consumers) - 5} more" if len(consumers) > 5 else ""), node)
                for producer in producers:
                    if producer in unreachable:
                        continue
                    producer_job = producer if g.nodes[producer]["type"] == "job" else \
                        g.nodes[producer]["job"]
                    role = {"artifact": "artifact_producer", "input": "call_site",
                            "job_output": "data_predecessor"}.get(resource_type)
                    reason = f"produces {node[len('resource:'):] if node.startswith('resource:') else node}"
                    keep(producer_job, reason, role)
                    if producer != producer_job:
                        keep(producer, reason)

        sliced = g.subgraph(kept).copy()
        sliced.graph = {key: value for key, value in g.graph.items()}
        sliced.graph["target"] = dict(g.graph["target"], node=target)
        sliced.graph["pruned"] = {n: p for n, p in pruned.items() if n not in kept}
        sliced.graph["diagnostics"] = list(g.graph["diagnostics"])
        for position, node in enumerate(order):
            sliced.nodes[node]["slice_order"] = position
            sliced.nodes[node]["slice_reasons"] = kept[node]["reasons"]
            if kept[node]["role"]:
                sliced.nodes[node]["slice_role"] = kept[node]["role"]
        return sliced

    # ── Stage 4: execution specification (sliced graph only) ──────────────────
    @staticmethod
    def _job_order(sliced):
        jobs = [n for n, a in sliced.nodes(data=True) if a.get("type") == "job"]
        target = sliced.graph["target"]["node"]

        def owner(node):
            attrs = sliced.nodes[node]
            return node if attrs.get("type") == "job" else attrs.get("job")

        precedence = nx.DiGraph()
        precedence.add_nodes_from(jobs)
        precedence.add_edges_from((u, v) for u, v, k in sliced.edges(keys=True) if k == "NEEDS")
        for resource, attrs in sliced.nodes(data=True):
            if attrs.get("type") != "resource":
                continue
            producers = {owner(u) for u, _, k in sliced.in_edges(resource, keys=True) if k == "PRODUCES"}
            consumers = {owner(v) for _, v, k in sliced.out_edges(resource, keys=True) if k == "CONSUMES"}
            precedence.add_edges_from((p, c) for p in producers for c in consumers
                                      if p and c and p != c and p in precedence and c in precedence)
        # dependencies first; independent jobs by label, so the order is canonical
        try:
            ordered = list(nx.lexicographical_topological_sort(
                precedence, key=lambda n: sliced.nodes[n]["label"]))
        except nx.NetworkXUnfeasible:
            ordered = sorted(jobs, key=lambda n: sliced.nodes[n]["label"])
        return [n for n in ordered if n != target] + [target]

    @staticmethod
    def _steps_kept(role, indices, pruned=()):
        if role in ("target", "control_predecessor"):
            return f"all except statically false {sorted(pruned)}" if pruned else "all"
        if not indices:
            return "none"
        if indices == list(range(indices[-1] + 1)):
            return f"0-{indices[-1]}"
        return indices

    @staticmethod
    def _step_entry(step):
        entry = {"job": step["job_label"], "index": step["index"], "role": step["role"]}
        fields = (("name", "display_name", "name"), ("id", "step_id", "id"), ("if", "condition", "if"),
                  ("uses", "uses", "uses"), ("with", "with_", "with"), ("run", "command", "run"),
                  ("shell", "shell", "shell"),
                  ("working_directory", "working_directory", "working-directory"),
                  ("env", "env", "env"), ("continue_on_error", "continue_on_error", "continue-on-error"),
                  ("timeout_minutes", "timeout_minutes", "timeout-minutes"))
        for key, attribute, declared in fields:
            if declared in step["present"]:
                entry[key] = step[attribute]
        if step["action"]:
            entry["action"] = step["action"]
        if step["expanded_steps"]:
            entry["expanded_steps"] = step["expanded_steps"]
        if "condition_result" in step and "if" in step["present"]:
            evidence = step["condition_evidence"]
            entry["condition_result"] = step["condition_result"]
            entry["condition_evidence"] = {k: evidence[k] for k in ("resolved", "unknown", "status_functions",
                                                                    "implicit_status", "error") if evidence.get(k)}
        return entry

    def build_execution_spec(self, sliced):
        g = sliced
        target_info = g.graph["target"]
        target = target_info["node"]
        metadata = g.graph["job_metadata"]
        unresolved = list(g.graph["unresolved"])

        def note(kind, detail, node=None):
            entry = {"kind": kind, "detail": detail, **({"node": node} if node else {})}
            if entry not in unresolved:
                unresolved.append(entry)

        job_order = self._job_order(g)
        step_nodes = {job: sorted((n for n, a in g.nodes(data=True)
                                   if a.get("type") == "step" and a["job"] == job),
                                  key=lambda n: g.nodes[n]["index"]) for job in job_order}
        jobs, steps = [], []
        for job_node in job_order:
            job = g.nodes[job_node]
            role = job.get("slice_role")
            indices = [g.nodes[s]["index"] for s in step_nodes[job_node]]
            pruned_here = [p["index"] for p in g.graph.get("pruned", {}).values() if p["job"] == job["label"]]
            entry = {"job": job["label"], "name": job["name"], "role": role,
                     "execution": JOB_EXECUTION.get(role, "execute_until_producer"),
                     "workflow": job["source_file"], "runs_on": job["runs_on"], "needs": job["needs"],
                     "steps_kept": self._steps_kept(role, indices, pruned_here), "reasons": job["slice_reasons"]}
            if "condition_result" in job and job["raw_config"].get("if") is not None:
                entry["condition_result"] = job["condition_result"]
            for key, attribute in (("if", "condition"), ("container", "container"),
                                   ("services", "services"), ("environment", "environment"),
                                   ("outputs", "outputs"), ("with", "call_with"),
                                   ("timeout_minutes", "timeout_minutes"),
                                   ("continue_on_error", "continue_on_error")):
                if job[attribute] is not None:
                    entry[key] = job[attribute]
            if job["env_expression"] is not None:
                entry["env_expression"] = job["env_expression"]
            if job["env"]:
                entry["env"] = job["env"]
            if job["defaults_run"]:
                entry["defaults_run"] = job["defaults_run"]
            if job["matrix"] is not None and (job_node == target or job["matrix"]):
                entry["matrix"] = job["matrix"]
            elif job["has_matrix"] and role != "ordering_only":
                note("matrix", f"{job['label']} has a matrix; which combination produced the "
                               f"needed output is not known", job_node)
            jobs.append(entry)
            steps += [self._step_entry(g.nodes[s]) for s in step_nodes[job_node]]

        target_job = g.nodes[target]
        runners = []
        for label in _as_list(target_job["runs_on"]) + list(metadata.get("labels") or []):
            label = label if isinstance(label, str) else json.dumps(label, sort_keys=True)
            if label not in runners:
                runners.append(label)
        for item in _strings(target_job["runs_on"]):
            if EXPRESSION.search(item):
                note("runner", f"runs-on {item!r} is an unresolved expression", target)

        job_rank = {job: i for i, job in enumerate(job_order)}
        runtimes = []
        for node, attrs in sorted(((n, a) for n, a in g.nodes(data=True)
                                   if a.get("resource_type") == "runtime"),
                                  key=lambda na: (job_rank.get(na[1]["job"], -1), na[1]["position"])):
            item = {k: attrs[k] for k in ("runtime", "version", "action", "source", "version_file",
                                          "distribution", "architecture", "cache") if k in attrs}
            if isinstance(item["version"], str) and EXPRESSION.search(item["version"]):
                note("runtime", f"{item['runtime']} version {item['version']!r} is an unresolved "
                                f"expression", item["source"])
            runtimes.append(item)

        package_managers = {}
        for job_node in job_order:
            for step in step_nodes[job_node]:
                for manager in g.nodes[step]["package_managers"]:
                    package_managers.setdefault(manager["name"], manager)

        dependency_files = []
        for node, attrs in sorted(g.nodes(data=True), key=lambda na: str(na[1].get("path"))):
            if attrs.get("resource_type") not in ("dependency_manifest", "version_file"):
                continue
            uses = [(v, a) for _, v, a in g.out_edges(node, data=True) if a["type"] == "CONSUMES"]
            confidences = [a["confidence"] for _, a in uses if "confidence" in a] + \
                ["explicit" for _, a in uses if "confidence" not in a and not a.get("inferred")]
            dependency_files.append({
                "path": attrs["path"], "exists": attrs["exists"],
                "source": "inferred" if all(a.get("inferred") for _, a in uses) else "referenced",
                "confidence": min(confidences, key=CONFIDENCE_RANK.get) if confidences else "implicit",
                "read_by": sorted({v for v, _ in uses}),
                "evidence": sorted({a.get("expression", "") for _, a in uses} - {""}),
            })

        reproduced = {n for n, a in g.nodes(data=True)
                      if a.get("type") == "job" and a.get("slice_role") != "ordering_only"}

        # every NEEDS edge into a reproduced job: executed or only recorded, per the semantics
        ordering_constraints = []
        for after in job_order:
            if after not in reproduced:
                continue
            for before, _, attrs in g.in_edges(after, data=True):
                if attrs["type"] != "NEEDS":
                    continue
                constraint = {"before": g.nodes[before]["label"], "after": g.nodes[after]["label"],
                              "requires_success": attrs["requires_success"],
                              "before_reproduced": before in reproduced}
                if attrs.get("condition"):
                    constraint["condition"] = attrs["condition"]
                ordering_constraints.append(constraint)
        label_rank = {g.nodes[job]["label"]: rank for job, rank in job_rank.items()}
        ordering_constraints.sort(key=lambda c: (label_rank[c["after"]], c["before"]))

        def affects_slice(item):
            node = item.get("node") or ""
            if node.startswith("job:"):
                return node in reproduced
            if node.startswith("step:"):
                return node in g
            return True

        pruned = sorted(g.graph.get("pruned", {}).values(), key=lambda p: (label_rank.get(p["job"], -1), p["index"]))
        execution_slice = {
            "jobs": jobs,
            "steps": steps,
            "required_outputs": self._crossings(g, "job_output"),
            "required_artifacts": self._crossings(g, "artifact"),
            "ordering_constraints": ordering_constraints,
            "pruned_steps": pruned,
            "diagnostics": sorted(g.graph.get("diagnostics", []),
                                  key=lambda d: (d["kind"], d.get("node", ""), d["detail"])),
        }
        # condition decisions over the explicit `if:`s of the steps the slice considered
        decided = Counter(a["condition_result"] for _, a in g.nodes(data=True)
                          if a.get("type") == "step" and "condition_result" in a
                          and a["raw_config"].get("if") is not None)
        decided[FALSE] += sum(1 for p in pruned if p["condition"] is not None)
        workflow_graph, slice_graph = canonical_graph(self.graph), canonical_graph(g)
        shell_analysis = self._shell_spec(g, job_order, step_nodes)
        return {
            "fingerprints": {"workflow_graph": fingerprint(workflow_graph),
                             "slice_graph": fingerprint(slice_graph),
                             "execution_slice": fingerprint(execution_slice)},
            "target": {
                "job_id": metadata.get("id"),
                "job_name": target_info["api_name"],
                "workflow": target_job["source_file"],
                "yaml_job_id": target_info["job_key"],
                "scope": target_info["scope"] or None,
                "matrix": target_info["matrix"] or {},
                "caller_matrix": target_info["caller_matrix"] or None,
                "resolved_by": target_info["resolved_by"],
            },
            "slice_semantics": {"mode": g.graph["semantics"], "rules": SEMANTICS_RULES},
            "condition_resolution": {"mode": g.graph.get("conditions", "off"),
                                     "decisions": {k: decided.get(k, 0) for k in ("TRUE", "FALSE", "UNKNOWN")}},
            "workflow_graph": workflow_graph,
            "slice_graph": slice_graph,
            "execution_slice": execution_slice,
            "shell_analysis": shell_analysis,
            "environment_constraints": {
                "runner": runners,
                "containers": [{"job": j["job"], "container": j["container"]}
                               for j in jobs if j.get("container")],
                "services": [{"job": j["job"], "name": name, "service": service}
                             for j in jobs for name, service in (j.get("services") or {}).items()],
                "runtimes": runtimes,
                "package_managers": sorted(package_managers.values(), key=lambda m: m["name"]),
                "dependency_files": dependency_files,
                "secrets_referenced": sorted({s for _, a in g.nodes(data=True)
                                              if a.get("type") in ("job", "step")
                                              for s in a.get("secrets") or []}),
            },
            "unresolved_dependencies": sorted(
                (u for u in unresolved if affects_slice(u)),
                key=lambda u: (u["kind"], u.get("node", ""), u["detail"])),
        }

    @staticmethod
    def _shell_spec(g, job_order, step_nodes):
        """The Shell Command IR of the kept steps, and the shell-derived dependency edges."""
        steps, summary = [], Counter()
        for job_node in job_order:
            for step_node in step_nodes[job_node]:
                analyses = g.nodes[step_node].get("shell_ir")
                if not analyses:
                    continue
                for origin, analysis in sorted(analyses.items()):
                    summary[f"parsed_by:{analysis['parsed_by']}"] += 1
                    commands = []
                    for c in analysis["commands"]:
                        summary["commands"] += 1
                        summary[f"kind:{c['kind']}"] += 1
                        summary["commands_with_unresolved"] += bool(c["unresolved"])
                        commands.append({k: c[k] for k in ("position", "line", "text", "program", "kind", "cwd",
                                                           "guarded", "via", "reads", "writes", "installs", "uses",
                                                           "unresolved") if c.get(k) not in (None, [], False)}
                                        | ({"cwd": None} if c["cwd"] is None else {}))
                    steps.append({"job": g.nodes[job_node]["label"], "index": g.nodes[step_node]["index"],
                                  "origin": origin, "shell": analysis["shell"], "parsed_by": analysis["parsed_by"],
                                  **({"parse_errors": analysis["parse_errors"]} if analysis["parse_errors"] else {}),
                                  **({"unresolved": analysis["unresolved"]} if analysis["unresolved"] else {}),
                                  "commands": commands})
        edges = sorted(({"resource": u, "consumer": v, "type": k, "confidence": a["confidence"],
                         "command": a["command"], "why": a.get("why")}
                        for u, v, k, a in g.edges(keys=True, data=True) if "command" in a and k != "EXECUTES"
                        and k != "PRODUCES"), key=lambda e: (e["consumer"], e["resource"], e["type"]))
        for edge in edges:
            summary[f"edges:{edge['confidence']}"] += 1
        return {"analyzer": "gwa_shell (tree-sitter-bash; lexical pwsh / cmd)",
                "summary": dict(sorted(summary.items())), "steps": steps, "dependencies": edges}

    @staticmethod
    def _crossings(sliced, resource_type):
        """Producer -> consumer pairs of one resource type that cross jobs."""
        def owner(node):
            attrs = sliced.nodes[node]
            return node if attrs.get("type") == "job" else attrs.get("job")

        crossings = []
        for resource, attrs in sliced.nodes(data=True):
            if attrs.get("resource_type") != resource_type:
                continue
            for producer, _, k in sliced.in_edges(resource, keys=True):
                for _, consumer, c in sliced.out_edges(resource, keys=True):
                    if k == "PRODUCES" and c == "CONSUMES" and owner(producer) != owner(consumer):
                        crossings.append({"resource": resource[len("resource:"):],
                                          "producer": producer, "consumer": consumer})
        return sorted(crossings, key=lambda c: (c["resource"], c["producer"], c["consumer"]))
