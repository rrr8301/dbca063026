import argparse
import json
import os
import re
import shutil
import subprocess
import sys
import threading
import time
from pathlib import Path
from typing import Any, Dict, Optional

from utils.common.credentials import OPENAI_TOKEN, GITHUB_TOKENS

# ---------------------------------------------------------------------------
# Constants
# ---------------------------------------------------------------------------

DEFAULT_MODEL       = "gpt-4o"

# Per-model OpenAI pricing in USD per 1M tokens: (input, cached_input, output).
# The bare "gpt-4o" alias bills at the 2024-08-06 rate ($2.50 / $1.25 / $10),
# NOT the launch rate ($5 / $15). Cached input is ~50% of input.
PRICES = {
    "gpt-4o":                 (2.50, 1.25, 10.00),
    "gpt-4o-2024-11-20":      (2.50, 1.25, 10.00),
    "gpt-4o-2024-08-06":      (2.50, 1.25, 10.00),
    "gpt-4o-2024-05-13":      (5.00, 5.00, 15.00),  # launch rate, no cache discount
    "gpt-4o-mini":            (0.15, 0.075, 0.60),
    "gpt-4o-mini-2024-07-18": (0.15, 0.075, 0.60),
}
DEFAULT_PRICE = (2.50, 1.25, 10.00)  # fall back to gpt-4o rate for unknown models

FINAL_STATUS_RE = re.compile(r"\bFINAL_STATUS\s*=\s*(SUCCESS|FAIL)\b", re.IGNORECASE)

# Heuristic signatures that a test runner actually executed and produced results.
# Per the agent prompt, "SUCCESS = tests ran (output visible)" — so once any of
# these appears in command output we treat the task as done and stop retrying,
# regardless of the FINAL_STATUS the agent printed.
TESTS_RAN_RE = re.compile(
    r"""
      \b\d+\s+passed\b                     # pytest "5 passed"
    | \b\d+\s+failed\b                     # pytest "3 failed"
    | \bRan\s+\d+\s+tests?\b               # unittest "Ran 12 tests in"
    | \btest\s+result:\s*(?:ok|FAILED)\b   # cargo "test result: ok."
    | \bTests\s+run:\s*\d+                 # maven surefire
    | \bTest\s+Suites:\s*\d+               # jest
    | ^\s*Tests:\s+\d+                     # jest summary
    | \b\d+\s+passing\b                    # mocha "10 passing"
    | \b\d+\s+failing\b                    # mocha
    | ^---\s+(?:PASS|FAIL):                # go test verbose
    | ^(?:ok|FAIL)\s+\S+\s+[\d.]+s         # go test package result
    | \b\d+%\s+tests\s+passed\b            # ctest
    | \bcollected\s+\d+\s+items?\b         # pytest collection
    | \b\d+\s+tests?\s+completed\b         # gradle
    | \b\d+\s+subtests?\s+passed\b         # git/sharness "247 subtests passed"
    | ^\s*\d+/\d+\s+\S+\s+(?:OK|FAIL)\b     # git prove "11/1045 git:unit-tests OK"
    """,
    re.IGNORECASE | re.VERBOSE | re.MULTILINE,
)

# ---------------------------------------------------------------------------
# Prompt builder — agent does everything from the raw URL
# ---------------------------------------------------------------------------

def build_agent_prompt(link: str, work_dir: str, image_name: str) -> str:
    return f"""
You are a CI build reproducer agent. Your sole task is to reproduce a GitHub Actions CI job
inside a Docker container by writing a Dockerfile and run.sh, building the image, and running it.
Do NOT modify any source files or test files inside the cloned repository — only fix the
Dockerfile and run.sh to make the environment work correctly.

GitHub Actions Job URL : {link}
Working directory      : {work_dir}
Docker image name      : {image_name}
GitHub token           : already set as $GITHUB_TOKEN in your environment

---

## PHASE 1 — Gather context (do this once)

1. Parse the URL to extract owner, repo, run_id, job_id.

2. Fetch job metadata:
   curl -s -H "Authorization: token $GITHUB_TOKEN" \\
        https://api.github.com/repos/<owner>/<repo>/actions/jobs/<job_id> \\
        > {work_dir}/job.json
   Extract: head_sha, job name.

3. Clone the repo at the exact commit:
   git clone https://github.com/<owner>/<repo>.git {work_dir}/repo
   cd {work_dir}/repo && git checkout <head_sha>

4. Read the workflow YAML in {work_dir}/repo/.github/workflows/ and extract for the target job:
   - OS (runs-on), language + exact runtime version, all install/build/test steps, env vars.

---

## PHASE 2 — Write Dockerfile and run.sh

HOW TO WRITE THESE FILES (important): create them as real files on disk. If you
have a file-editing/apply-patch tool, use it. If you write them from the shell,
use a SINGLE-QUOTED heredoc so nothing is expanded or mangled:
    cat > {work_dir}/Dockerfile <<'DOCKERFILE_EOF'
    ...exact file contents...
    DOCKERFILE_EOF
Do NOT assemble these files with escaped `echo`/`printf` or a double-quoted
heredoc — escaped quotes corrupt the contents and make `docker build` fail with
a parse error. After writing each file, verify it with `cat {work_dir}/Dockerfile`
and `cat {work_dir}/run.sh` before building.

**Dockerfile** (write to {work_dir}/Dockerfile):
- FROM image matching runs-on (from job meta-data)
- ENV DEBIAN_FRONTEND=noninteractive
- Install system deps and exact language runtime
- WORKDIR /app → COPY repo/ /app/
- Install project dependencies (pip/npm/cargo/mvn/gradle/go mod/…)
- COPY run.sh /run.sh → RUN chmod +x /run.sh → ENTRYPOINT ["/run.sh"]
- Skip: actions/checkout, actions/cache, actions/upload-artifact, codecov/*
- Do NOT use sudo inside the container
- Set required env vars with ENV

**run.sh** (write to {work_dir}/run.sh):
- #!/usr/bin/env bash
- Use the EXACT test commands from the workflow YAML (do not substitute with generic runners)
- Run all tests even if some fail (use || true where needed)
- Print FINAL_STATUS = SUCCESS when tests pass, FINAL_STATUS = FAIL otherwise

---

## PHASE 3 — Build, run, and iterate until SUCCESS

**Build:**
  cd {work_dir} && docker build -t {image_name} .

**Run:**
  docker run --rm {image_name} 2>&1 | tee {work_dir}/run_output.log

**After each run:**
- If tests ran (even if some failed) → print FINAL_STATUS = SUCCESS and stop.
  * "Tests ran" means the test runner was invoked and produced results (pass, fail, or partial).
- If tests did NOT run (build error, dependency missing, container crash before tests) → refine:
  * Missing package/dep   → add to Dockerfile
  * Wrong runtime version → fix FROM or install step
  * Wrong test command    → re-read YAML and fix run.sh
  * Build failure         → fix Dockerfile RUN steps
- Rewrite the complete Dockerfile and run.sh (never patch partially), rebuild, and rerun.
- Never repeat a fix that already failed — always try a different approach.
- NEVER modify source or test files in the repo — only Dockerfile and run.sh.
- Only print FINAL_STATUS = FAIL if all reasonable approaches to get tests running are exhausted.

---

## Rules
- Always end with exactly one of: FINAL_STATUS = SUCCESS  or  FINAL_STATUS = FAIL
- Never skip PHASE 1 — the job metadata and YAML are essential context
- Every retry must change something meaningful in Dockerfile or run.sh
- Do not hard-code paths that only exist on the GitHub runner
- NEVER edit, patch, or delete any file inside {work_dir}/repo/ — the codebase is read-only
- SUCCESS = tests ran (output visible), not tests all passed
"""


# ---------------------------------------------------------------------------
# URL parser
# ---------------------------------------------------------------------------

def parse_url(url: str):
    match = re.match(
        r'https://github\.com/([^/]+)/([^/]+)/actions/runs/(\d+)(?:/job/(\d+))?', url
    )
    if match:
        return match.group(1), match.group(2), match.group(3), match.group(4)
    return None, None, None, None


# ---------------------------------------------------------------------------
# Cost helper
# ---------------------------------------------------------------------------

def compute_cost(
    input_tokens:        int,
    output_tokens:       int,
    model:               str = DEFAULT_MODEL,
    cached_input_tokens: int = 0,
) -> float:
    """Cost in USD. `input_tokens` is the gross input (cached + uncached); the
    cached portion is billed at the discounted cached rate."""
    p_in, p_cached, p_out = PRICES.get(model, DEFAULT_PRICE)
    uncached_in = max(0, input_tokens - cached_input_tokens)
    return round(
        (uncached_in         / 1_000_000) * p_in +
        (cached_input_tokens / 1_000_000) * p_cached +
        (output_tokens       / 1_000_000) * p_out,
        6,
    )


# ---------------------------------------------------------------------------
# App-server JSON-RPC session
# ---------------------------------------------------------------------------

class AppServerSession:
    def __init__(
        self,
        work_dir:       str,
        model:          str   = DEFAULT_MODEL,
        token_limit:    int   = 0,
        cost_limit_usd: float = 2.0,
        timeout:        int   = 3600,
        extra_env:      Optional[Dict[str, str]] = None,
    ):
        self.work_dir       = work_dir
        self.model          = model
        self.token_limit    = token_limit
        self.cost_limit_usd = cost_limit_usd
        self.timeout        = timeout
        self.extra_env      = extra_env or {}

        self._req_id   = 0
        self._lock     = threading.Lock()
        self._pending: Dict[int, threading.Event] = {}
        self._results:  Dict[int, Any]            = {}

        self.input_tokens  = 0
        self.output_tokens = 0
        self.total_tokens  = 0
        self.cached_input_tokens = 0
        self.cost_usd      = 0.0
        self._token_payload_logged = False

        self.thread_id:    Optional[str] = None
        self.turn_id:      Optional[str] = None
        self.final_status: str           = "UNKNOWN"
        self.tests_ran     = False
        self.turn_done     = threading.Event()
        self.interrupted   = False

        self._proc:          Optional[subprocess.Popen] = None
        self._reader_thread: Optional[threading.Thread] = None
        self._status_thread: Optional[threading.Thread] = None

    def _next_id(self) -> int:
        with self._lock:
            self._req_id += 1
            return self._req_id

    def _send(self, msg: dict) -> None:
        line = json.dumps(msg) + "\n"
        self._proc.stdin.write(line)
        self._proc.stdin.flush()

    def request(self, method: str, params: dict) -> Any:
        req_id = self._next_id()
        evt    = threading.Event()
        with self._lock:
            self._pending[req_id] = evt
        self._send({"id": req_id, "method": method, "params": params})
        evt.wait(timeout=60)
        with self._lock:
            result = self._results.pop(req_id, None)
        return result

    def _respond(self, req_id: Any, result: dict) -> None:
        self._send({"id": req_id, "result": result})

    def _reader(self) -> None:
        for raw in self._proc.stdout:
            line = raw.strip()
            if not line:
                continue
            try:
                msg = json.loads(line)
            except Exception:
                print(f"[RAW] {line}", flush=True)
                continue

            msg_id = msg.get("id")
            method = msg.get("method", "")
            params = msg.get("params", {})
            result = msg.get("result")
            error  = msg.get("error")

            if msg_id is not None and result is not None:
                with self._lock:
                    if msg_id in self._pending:
                        self._results[msg_id] = result
                        self._pending[msg_id].set()
                continue

            if msg_id is not None and error is not None:
                print(f"[ERR] id={msg_id} error={error}", flush=True)
                with self._lock:
                    if msg_id in self._pending:
                        self._results[msg_id] = None
                        self._pending[msg_id].set()
                continue

            # Handlers must never kill the reader thread — an unhandled
            # exception here would stop draining stdout and hang the run.
            try:
                if msg_id is not None and method:
                    self._handle_server_request(msg_id, method, params)
                    continue

                if method:
                    self._handle_notification(method, params)
            except Exception as exc:
                print(f"[READER] handler error for method={method!r}: {exc}", flush=True)

    @staticmethod
    def _print_output(text: str, label: str = "OUT") -> None:
        lines   = text.strip().splitlines()
        preview = "\n  ".join(lines[:20])
        suffix  = f"\n  … ({len(lines) - 20} more lines)" if len(lines) > 20 else ""
        print(f"[{label}]\n  {preview}{suffix}", flush=True)

    def _handle_server_request(self, req_id: Any, method: str, params: dict) -> None:
        if method in (
            "item/commandExecution/requestApproval",
            "item/fileChange/requestApproval",
            "item/permissions/requestApproval",
            "execCommandApproval",
            "applyPatchApproval",
        ):
            raw = params.get("command") or params.get("patch") or params.get("policy") or ""
            cmd = str(raw)[:80]
            print(f"\n[APPROVE] {method} {cmd}", flush=True)
            self._respond(req_id, {"decision": "acceptForSession"})
        else:
            self._respond(req_id, {})

    def _handle_notification(self, method: str, params: dict) -> None:
        if method == "thread/tokenUsage/updated":
            # One-time dump of the raw payload so the exact field names
            # (esp. the cached-input key) can be confirmed on a live run.
            if not self._token_payload_logged:
                self._token_payload_logged = True
                print(f"[TOKENS-RAW] {json.dumps(params.get('tokenUsage', {}))}", flush=True)
            total = params.get("tokenUsage", {}).get("total", {})
            self.input_tokens  = total.get("inputTokens",  0)
            self.output_tokens = total.get("outputTokens", 0)
            self.total_tokens  = total.get("totalTokens",  0)
            # Cached input is reported under a few possible key spellings; absent
            # → 0 (no discount, i.e. conservative over-estimate).
            self.cached_input_tokens = (
                total.get("cachedInputTokens")
                or total.get("cached_input_tokens")
                or total.get("cachedTokens")
                or 0
            )
            self.cost_usd = compute_cost(
                self.input_tokens, self.output_tokens,
                self.model, self.cached_input_tokens,
            )
            print(
                f"[COST] Running total: ${self.cost_usd:.4f} / ${self.cost_limit_usd:.2f}"
                f"  |  tokens: {self.total_tokens:,}"
                + (f" / {self.token_limit:,}" if self.token_limit > 0 else ""),
                flush=True,
            )
            if self.token_limit > 0 and self.total_tokens >= self.token_limit:
                print(f"\n[TOKENS] Limit {self.token_limit:,} exceeded — interrupting.", flush=True)
                self._interrupt()
            if self.cost_limit_usd > 0 and self.cost_usd >= self.cost_limit_usd:
                print(f"\n[COST] Limit ${self.cost_limit_usd:.2f} exceeded — interrupting.", flush=True)
                self._interrupt()

        elif method == "turn/started":
            turn_id = params.get("turn", {}).get("id", "?")
            print(f"\n[SESSION] turn started  id={turn_id}  model={self.model}", flush=True)

        elif method == "turn/completed":
            status = params.get("turn", {}).get("status", "?")
            print(f"\n[RESULT] {status}  final_status={self.final_status}", flush=True)
            if self.final_status == "UNKNOWN":
                self.final_status = "FAIL"
            self.turn_done.set()

        elif method == "turn/failed":
            err = params.get("error", params)
            print(f"\n[RESULT] failed  error={err}", flush=True)
            if self.final_status == "UNKNOWN":
                self.final_status = "FAIL"
            self.turn_done.set()

        elif method == "item/streaming":
            item  = params.get("item", {})
            delta = params.get("delta", "")
            if item.get("type") in ("message", "agentMessage") and delta:
                print(delta, end="", flush=True)

        elif method == "item/completed":
            item  = params.get("item", {})
            itype = item.get("type", "")

            if itype in ("command_execution", "commandExecution"):
                cmd    = item.get("command", "")
                output = item.get("output",  "")
                code   = item.get("exit_code")
                print(f"\n[EXEC] {cmd}", flush=True)
                if output:
                    label = "ERR" if (code not in (None, 0)) else "OUT"
                    self._print_output(output, label)
                    if code not in (None, 0):
                        print(f"[EXIT] {code}", flush=True)
                    m = FINAL_STATUS_RE.search(output)
                    if m:
                        self.final_status = m.group(1).upper()
                        print(f"[STATUS] FINAL_STATUS={self.final_status}", flush=True)
                    # Tests actually executed → success criterion met. Stop the
                    # turn (and the retry loop) regardless of FINAL_STATUS.
                    if not self.tests_ran and TESTS_RAN_RE.search(output):
                        self.tests_ran = True
                        if self.final_status != "SUCCESS":
                            print(
                                f"[TESTS] execution detected — overriding status "
                                f"{self.final_status} -> SUCCESS",
                                flush=True,
                            )
                            self.final_status = "SUCCESS"
                        print("[TESTS] test execution detected — interrupting turn", flush=True)
                        self._interrupt()

            elif itype in ("message", "agentMessage"):
                # "agentMessage" uses "text"; older "message" type uses "content"
                text = item.get("text", "") or item.get("content", "")
                if text:
                    preview = text[:500] + ("…" if len(text) > 500 else "")
                    print(f"\n[AGENT] {preview}", flush=True)
                    m = FINAL_STATUS_RE.search(text)
                    if m:
                        self.final_status = m.group(1).upper()
                        print(f"[STATUS] FINAL_STATUS={self.final_status}", flush=True)

            elif itype == "file_change":
                path   = item.get("path", "?")
                change = item.get("change_type", "write")
                print(f"\n[TOOL] file_change({change}: {path})", flush=True)

            else:
                print(f"\n[TOOL] {itype}  {json.dumps(item)[:160]}", flush=True)

        elif method in ("thread/created", "item/created"):
            pass

        elif method == "error":
            print(f"\n[ERR] {params}", flush=True)

    def _interrupt(self) -> None:
        if self.interrupted or not self.thread_id or not self.turn_id:
            return
        self.interrupted = True
        try:
            self.request("turn/interrupt", {
                "threadId": self.thread_id,
                "turnId":   self.turn_id,
            })
        except Exception as exc:
            print(f"[INTERRUPT] failed: {exc}", flush=True)
        self.turn_done.set()

    def _status_watcher(self, start: float) -> None:
        while not self.turn_done.wait(timeout=10):
            elapsed = time.time() - start
            limit_str = f"/{self.token_limit:,}" if self.token_limit > 0 else ""
            print(
                f"\n[STATUS] elapsed={elapsed:.0f}s"
                f"  tokens={self.total_tokens:,}{limit_str}"
                f"  cost=${self.cost_usd:.4f}",
                flush=True,
            )

    def start(self) -> None:
        env = os.environ.copy()
        env["OPENAI_API_KEY"] = OPENAI_TOKEN
        env.update(self.extra_env)
        # RVM shell functions cause codex shell snapshot validation to fail
        # ("syntax error near unexpected token '('"). Strip them from the env.
        for key in [k for k in env if k.startswith("rvm") or k.startswith("GEM_") or k.startswith("RUBY")]:
            env.pop(key, None)
        env.pop("BASH_ENV", None)
        env["DISABLE_RVM"] = "1"
        # Use the codex-bundled bwrap (supports --perms, needed for workspaceWrite + networkAccess).
        _bundled_bwrap = "/usr/lib/node_modules/@openai/codex/node_modules/@openai/codex-linux-x64/vendor/x86_64-unknown-linux-musl/codex-resources"
        env["PATH"] = _bundled_bwrap + ":" + env.get("PATH", "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin")

        self._proc = subprocess.Popen(
            ["codex", "app-server", "--listen", "stdio://"],
            stdin=subprocess.PIPE,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
            env=env,
        )

        def _drain_stderr():
            for line in self._proc.stderr:
                line = line.rstrip()
                if line:
                    print(f"[CODEX-ERR] {line}", flush=True)
        threading.Thread(target=_drain_stderr, daemon=True).start()

        self._reader_thread = threading.Thread(target=self._reader, daemon=True)
        self._reader_thread.start()

        init_resp = self.request("initialize", {
            "clientInfo": {"name": "codex_appserver_backup", "version": "1.0"}
        })
        print(f"[SESSION] initialize: {json.dumps(init_resp)[:300]}", flush=True)

        resp = self.request("thread/start", {
            "cwd":   self.work_dir,
            "model": self.model,
        })
        print(f"[SESSION] thread/start: {json.dumps(resp)[:300]}", flush=True)
        if resp is None:
            raise RuntimeError("thread/start failed — check [CODEX-ERR] lines above")
        self.thread_id = resp.get("thread", {}).get("id") or resp.get("threadId")
        print(f"[SESSION] thread_id={self.thread_id}  model={self.model}", flush=True)

    def run_turn(self, prompt: str) -> None:
        self.turn_done.clear()
        self.interrupted = False
        resp = self.request("turn/start", {
            "threadId": self.thread_id,
            "input":    [{"type": "text", "text": prompt}],
        })
        if resp is None:
            raise RuntimeError("turn/start failed")
        self.turn_id = resp.get("turn", {}).get("id")
        print(f"[SESSION] turn_id={self.turn_id}", flush=True)

    def wait_for_completion(self, timeout: int) -> None:
        start = time.time()
        self._status_thread = threading.Thread(
            target=self._status_watcher, args=(start,), daemon=True
        )
        self._status_thread.start()
        done = self.turn_done.wait(timeout=timeout)
        if not done:
            print(f"\n[TIMEOUT] {timeout}s elapsed — interrupting.", flush=True)
            self._interrupt()
            self.final_status = "TIMEOUT"

    def close(self) -> None:
        try:
            if self._proc:
                self._proc.stdin.close()
                self._proc.wait(timeout=5)
        except Exception:
            pass


# ---------------------------------------------------------------------------
# Tee stdout → file
# ---------------------------------------------------------------------------

class _Tee:
    def __init__(self, log_path: Path):
        self._stdout = sys.stdout
        self._file   = log_path.open("w", encoding="utf-8", buffering=1)
        sys.stdout   = self

    def write(self, data):
        self._stdout.write(data)
        self._file.write(data)

    def flush(self):
        self._stdout.flush()
        self._file.flush()

    def close(self):
        sys.stdout = self._stdout
        self._file.close()


# ---------------------------------------------------------------------------
# Main executor
# ---------------------------------------------------------------------------

def appserver_exec(
    work_dir:       str,
    prompt:         str,
    out_dir:        Path,
    model:          str   = DEFAULT_MODEL,
    token_limit:    int   = 0,
    cost_limit_usd: float = 2.0,
    timeout:        int   = 3600,
    github_token:   str   = "",
) -> Dict[str, Any]:

    out_dir.mkdir(parents=True, exist_ok=True)
    (out_dir / "prompt.txt").write_text(prompt, encoding="utf-8")

    tee = _Tee(out_dir / "agent_log.txt")

    extra_env = {}
    if github_token:
        extra_env["GITHUB_TOKEN"] = github_token

    session = AppServerSession(
        work_dir=work_dir,
        model=model,
        token_limit=token_limit,
        cost_limit_usd=cost_limit_usd,
        timeout=timeout,
        extra_env=extra_env,
    )

    RETRY_PROMPT = (
        "You stopped before the token limit was reached. "
        "The task is not done yet. "
        "Check what you have done so far in the working directory, "
        "then continue improving the Dockerfile and run.sh, rebuild the Docker image, "
        "run it, and keep iterating until the tests pass. "
        "Do NOT give up — keep trying until FINAL_STATUS = SUCCESS or you truly run out of tokens."
    )

    start = time.time()
    turn = 0
    try:
        session.start()
        while True:
            remaining = timeout - (time.time() - start)
            if remaining <= 0:
                session.final_status = "TIMEOUT"
                break

            turn_prompt = prompt if turn == 0 else RETRY_PROMPT
            print(f"\n[TURN] attempt={turn}", flush=True)
            session.run_turn(turn_prompt)
            session.wait_for_completion(int(remaining))

            # Stop as soon as tests actually executed — do not retry further.
            if session.tests_ran:
                print("\n[STOP] Tests executed — stopping (no more retries).", flush=True)
                break

            # Stop if done or hard-limited
            if session.final_status == "SUCCESS":
                break
            if session.interrupted:
                break
            if session.final_status == "TIMEOUT":
                break

            # If tokens are exhausted, stop
            if token_limit > 0 and session.total_tokens >= token_limit:
                break

            # Agent gave up early — retry only if enough tokens remain
            if session.final_status in ("UNKNOWN", "FAIL"):
                headroom = token_limit - session.total_tokens if token_limit > 0 else 999_999
                min_headroom = max(30_000, token_limit // 3) if token_limit > 0 else 30_000
                if headroom < min_headroom:
                    print(
                        f"\n[STOP] Only {headroom:,} tokens left — not enough to retry. Stopping.",
                        flush=True,
                    )
                    break
                print(
                    f"\n[RETRY] Agent stopped early "
                    f"(status={session.final_status}, tokens={session.total_tokens}). Retrying.",
                    flush=True,
                )
                session.final_status = "UNKNOWN"
                turn += 1
                continue

            break

    finally:
        session.close()
        tee.close()

    duration = time.time() - start

    result = {
        "final_status":     session.final_status,
        "interrupted":      session.interrupted,
        "duration_seconds": round(duration, 3),
        "input_tokens":         session.input_tokens,
        "output_tokens":        session.output_tokens,
        "total_tokens":         session.total_tokens,
        "cached_input_tokens":  session.cached_input_tokens,
        "model":                session.model,
        "cost_usd":             session.cost_usd,
    }
    (out_dir / "result.json").write_text(json.dumps(result, indent=2), encoding="utf-8")

    # Copy artifacts from work_dir → out_dir (always, even on token-limit stop)
    work_path = Path(work_dir)

    # Dockerfile and run.sh — search work_dir recursively
    for fname in ("Dockerfile", "run.sh"):
        dst = out_dir / fname
        if dst.is_file():
            print(f"[SAVE] {fname} already in {out_dir}", flush=True)
            continue
        src = work_path / fname
        if src.is_file():
            shutil.copy2(src, dst)
            print(f"[SAVE] {fname} copied from {src}", flush=True)
        else:
            matches = list(work_path.rglob(fname))
            if matches:
                shutil.copy2(matches[0], dst)
                print(f"[SAVE] {fname} copied from {matches[0]}", flush=True)
            else:
                print(f"[SAVE] {fname} not found", flush=True)

    # Container run output → log.txt
    log_dst = out_dir / "log.txt"
    if not log_dst.is_file():
        for candidate in ("run_output.log", "run.log"):
            src = work_path / candidate
            if src.is_file():
                shutil.copy2(src, log_dst)
                print(f"[SAVE] log.txt copied from {src}", flush=True)
                break
        else:
            # fall back: search recursively for any run_output.log
            matches = list(work_path.rglob("run_output.log"))
            if matches:
                shutil.copy2(matches[0], log_dst)
                print(f"[SAVE] log.txt copied from {matches[0]}", flush=True)
            else:
                print(f"[SAVE] log.txt not found in {work_dir}", flush=True)

    # If final_status is still UNKNOWN, scan log.txt for FINAL_STATUS = SUCCESS/FAIL
    # (run.sh prints it; the agent may not echo it in its last message text)
    if result["final_status"] == "UNKNOWN" and log_dst.is_file():
        log_text = log_dst.read_text(encoding="utf-8", errors="replace")
        for line in reversed(log_text.splitlines()):
            m = FINAL_STATUS_RE.search(line)
            if m:
                result["final_status"] = m.group(1).upper()
                print(f"[SAVE] final_status resolved from log.txt: {result['final_status']}", flush=True)
                (out_dir / "result.json").write_text(json.dumps(result, indent=2), encoding="utf-8")
                break

    return result


# ---------------------------------------------------------------------------
# CLI entry point
# ---------------------------------------------------------------------------

def main():
    parser = argparse.ArgumentParser(
        description="Codex app-server agent — provide only a GitHub Actions job URL."
    )
    parser.add_argument("link",
                        help="GitHub Actions job URL")
    parser.add_argument("--out",         default=None,
                        help="Output directory (default: auto-derived from repo+job_id).")
    parser.add_argument("--model",       default=DEFAULT_MODEL,
                        help=f"Codex model (default: {DEFAULT_MODEL}).")
    parser.add_argument("--timeout",     type=int,   default=3600,
                        help="Hard timeout in seconds (default 3600).")
    parser.add_argument("--cost_limit",  type=float, default=2.0,
                        help="Max API cost in USD (default 2.0).")
    parser.add_argument("--token_limit", type=int,   default=150000,
                        help="Max total tokens (default 150000).")
    args = parser.parse_args()

    owner, repo, run_id, job_id = parse_url(args.link)
    if owner is None:
        print(f"ERROR: Not a valid GitHub Actions job URL: {args.link}")
        raise SystemExit(1)

    image_name = f"{repo.lower()}_{job_id}:latest"

    out_dir = Path(args.out).resolve() if args.out else \
              Path(f"output_appserver_backup/{repo}_{job_id}/out").resolve()

    script_dir = Path(__file__).resolve().parent
    work_dir = str(script_dir / "codex_workdir" / f"{repo}_{job_id}")
    Path(work_dir).mkdir(parents=True, exist_ok=True)
    print(f"[SETUP] work_dir : {work_dir}")

    github_token = GITHUB_TOKENS[0] if GITHUB_TOKENS else ""

    prompt = build_agent_prompt(
        link=args.link,
        work_dir=work_dir,
        image_name=image_name,
    )

    print(f"Starting Codex agent for: {owner}/{repo}  job={job_id}")
    print(f"  output   : {out_dir}")
    print(f"  image    : {image_name}")
    print(f"  model    : {args.model}")
    print(f"  timeout  : {args.timeout}s")
    print(f"  cost lim : ${args.cost_limit:.2f}")
    print(f"  tok lim  : {args.token_limit:,}" if args.token_limit > 0 else "  tok lim  : disabled")

    result = appserver_exec(
        work_dir=work_dir,
        prompt=prompt,
        out_dir=out_dir,
        model=args.model,
        token_limit=args.token_limit,
        cost_limit_usd=args.cost_limit,
        timeout=args.timeout,
        github_token=github_token,
    )

    print(f"\nAgent finished — FINAL_STATUS: {result['final_status']}")
    print(f"Duration : {result['duration_seconds']}s")
    print(f"Tokens   : {result['total_tokens']:,}  (cost: ${result['cost_usd']:.4f})")
    print(json.dumps(result))

    # Remove cloned repo to free disk space (artifacts already copied to out_dir)
    repo_path = Path(work_dir) / "repo"
    if repo_path.is_dir():
        shutil.rmtree(repo_path)
        print(f"[CLEANUP] Removed {repo_path}")


# Example usage:
#   python codex_app_server_cli_backup.py \
#     "https://github.com/pallets/flask/actions/runs/24007687136/job/70014021145"
#
#   python codex_app_server_cli_backup.py \
#     "https://github.com/pallets/flask/actions/runs/24007687136/job/70014021145" \
#     --out output/flask_70014021145 --cost_limit 3.0

if __name__ == "__main__":
    main()
