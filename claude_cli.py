import argparse
import glob as _glob
import json
import os
import re
import shutil
import subprocess
import sys
import threading
import time
from pathlib import Path
from typing import Any, Dict, List

from utils.common.credentials import CLAUDE_TOKEN, GITHUB_TOKENS
from codex_app_server_cli_backup import build_agent_prompt, parse_url, TESTS_RAN_RE

# ---------------------------------------------------------------------------
# Constants
# ---------------------------------------------------------------------------

DEFAULT_MODEL        = "claude-haiku-4-5-20251001"
PRICE_INPUT_PER_1M   = 0.8
PRICE_OUTPUT_PER_1M  = 4.0

FINAL_STATUS_RE = re.compile(r"\bFINAL_STATUS\s*=\s*(SUCCESS|FAIL)\b", re.IGNORECASE)

# Re-prompt sent when the agent stops before tests ran — mirrors the codex
# baseline so both harnesses get the same give-up-recovery policy. Note: each
# `claude -p` is a fresh session, so the retry re-reads the working directory
# rather than continuing in-context.
RETRY_PROMPT = (
    "You stopped before the token limit was reached. "
    "The task is not done yet. "
    "Check what you have done so far in the working directory, "
    "then continue improving the Dockerfile and run.sh, rebuild the Docker image, "
    "run it, and keep iterating until the tests pass. "
    "Do NOT give up — keep trying until FINAL_STATUS = SUCCESS or you truly run out of tokens."
)

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

def ensure_api_key() -> str:
    key = CLAUDE_TOKEN
    if not key:
        raise RuntimeError("CLAUDE_TOKEN not set in credentials.py")
    return key


def compute_cost(input_tokens: int, output_tokens: int) -> float:
    return round(
        (input_tokens  / 1_000_000) * PRICE_INPUT_PER_1M +
        (output_tokens / 1_000_000) * PRICE_OUTPUT_PER_1M,
        6,
    )


def _find_claude_bin() -> str:
    candidates = _glob.glob(
        os.path.expanduser("~/.vscode-server/extensions/anthropic.claude-code-*/resources/native-binary/claude")
    )
    return sorted(candidates)[-1] if candidates else "claude"


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

def claude_exec(
    work_dir:       str,
    prompt:         str,
    out_dir:        Path,
    model:          str   = DEFAULT_MODEL,
    token_limit:    int   = 100000,
    cost_limit_usd: float = 2.0,
    timeout:        int   = 3600,
    github_token:   str   = "",
) -> Dict[str, Any]:

    out_dir.mkdir(parents=True, exist_ok=True)
    (out_dir / "prompt.txt").write_text(prompt, encoding="utf-8")

    tee = _Tee(out_dir / "agent_log.txt")

    claude_bin = _find_claude_bin()

    env = os.environ.copy()
    env["ANTHROPIC_API_KEY"] = ensure_api_key()
    if github_token:
        env["GITHUB_TOKEN"] = github_token

    start            = time.time()
    timed_out        = False
    cost_exceeded    = False
    token_limit_hit  = False
    tests_ran        = False
    api_error        = False
    final_status     = "UNKNOWN"
    # Cumulative across all attempts (each `claude -p` is a fresh session).
    total_input_tok  = 0
    total_output_tok = 0
    accumulated_cost = 0.0
    all_stdout_lines: List[str] = []
    stderr_lines:     List[str] = []

    def _run_attempt(turn_prompt: str) -> None:
        """Run one `claude -p` invocation, folding its usage into the cumulative
        totals and updating the shared status flags."""
        nonlocal timed_out, cost_exceeded, token_limit_hit, tests_ran, final_status
        nonlocal total_input_tok, total_output_tok, accumulated_cost, api_error

        cmd = [
            claude_bin,
            "-p", turn_prompt,
            "--allowedTools", "Bash,Read,Edit,Write",
            "--output-format", "stream-json",
            "--verbose",
            "--model", model,
        ]

        process = subprocess.Popen(
            cmd,
            cwd=work_dir,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
            env=env,
        )

        def _read_stderr():
            for line in process.stderr:
                stderr_lines.append(line)
                print(f"[CLAUDE-ERR] {line.rstrip()}", flush=True)

        threading.Thread(target=_read_stderr, daemon=True).start()

        # Per-attempt usage (a fresh session reports its own running totals).
        attempt_in   = 0
        attempt_out  = 0
        attempt_cost = 0.0
        stop          = False

        for raw_line in process.stdout:
            if time.time() - start > timeout:
                process.kill()
                timed_out = True
                break

            line = raw_line.rstrip("\n")
            all_stdout_lines.append(line)

            try:
                evt = json.loads(line)
                etype = evt.get("type", "")

                # Print assistant text live
                if etype == "assistant":
                    for block in evt.get("message", {}).get("content", []):
                        if block.get("type") == "text":
                            print(block["text"], end="", flush=True)
                        elif block.get("type") == "tool_use":
                            print(f"\n[TOOL] {block.get('name')} {json.dumps(block.get('input',{}))[:120]}", flush=True)

                # Print tool results
                if etype == "user":
                    for block in evt.get("message", {}).get("content", []):
                        if block.get("type") == "tool_result":
                            raw = block.get("content", "")
                            text = raw if isinstance(raw, str) else "\n".join(
                                b.get("text", "") for b in raw if isinstance(b, dict)
                            )
                            lines = text.strip().splitlines()
                            preview = "\n  ".join(lines[:20])
                            suffix  = f"\n  … ({len(lines)-20} more)" if len(lines) > 20 else ""
                            print(f"[RESULT]\n  {preview}{suffix}", flush=True)

                            # Check for FINAL_STATUS in tool output
                            m = FINAL_STATUS_RE.search(text)
                            if m:
                                final_status = m.group(1).upper()
                                print(f"[STATUS] FINAL_STATUS={final_status}", flush=True)

                            # Tests actually executed → success criterion met.
                            # Stop the attempt (and the retry loop) regardless
                            # of the FINAL_STATUS the agent printed.
                            if not tests_ran and TESTS_RAN_RE.search(text):
                                tests_ran = True
                                if final_status != "SUCCESS":
                                    print(
                                        f"[TESTS] execution detected — overriding status "
                                        f"{final_status} -> SUCCESS",
                                        flush=True,
                                    )
                                    final_status = "SUCCESS"
                                print("[TESTS] test execution detected — stopping attempt", flush=True)
                                process.kill()
                                stop = True
                                break
                    if stop:
                        break

                # Track token usage
                if etype == "assistant":
                    usage = evt.get("message", {}).get("usage", {})
                    if usage:
                        attempt_in  += usage.get("input_tokens", 0)
                        attempt_in  += usage.get("cache_creation_input_tokens", 0)
                        attempt_out += usage.get("output_tokens", 0)
                        attempt_cost = compute_cost(attempt_in, attempt_out)

                elif etype == "result":
                    # Prefer the authoritative session cost when reported.
                    cost = evt.get("total_cost_usd")
                    if cost is not None:
                        attempt_cost = float(cost)
                    result_text = evt.get("result", "")
                    m = FINAL_STATUS_RE.search(result_text)
                    if m:
                        final_status = m.group(1).upper()
                    # An API/billing failure (e.g. "Credit balance is too low")
                    # is reported as is_error=True with no FINAL_STATUS. Surface
                    # it instead of silently falling through to UNKNOWN — and do
                    # not retry, since it's an account-wide wall.
                    if evt.get("is_error") and not m and not tests_ran:
                        api_error = True
                        print(f"[API-ERROR] result is_error=True: {result_text[:200]}", flush=True)

                if etype in ("assistant", "result"):
                    total_so_far = (total_input_tok + total_output_tok
                                    + attempt_in + attempt_out)
                    live_cost = accumulated_cost + attempt_cost
                    print(
                        f"\n[COST] ${live_cost:.4f} / ${cost_limit_usd:.2f}"
                        f"  |  tokens: {total_so_far:,}"
                        + (f" / {token_limit:,}" if token_limit > 0 else ""),
                        flush=True,
                    )
                    if live_cost > cost_limit_usd:
                        print(f"\n[COST] Limit exceeded — stopping.", flush=True)
                        process.kill()
                        cost_exceeded = True
                        break
                    if token_limit > 0 and total_so_far >= token_limit:
                        print(f"\n[TOKENS] Limit {token_limit:,} exceeded — stopping.", flush=True)
                        process.kill()
                        token_limit_hit = True
                        break

            except json.JSONDecodeError:
                if line.strip():
                    print(f"[RAW] {line}", flush=True)

        # Reap the process (whether it ended on its own or we killed it).
        try:
            process.wait(timeout=5)
        except Exception:
            pass

        # Fold this attempt's usage into the cumulative totals.
        total_input_tok  += attempt_in
        total_output_tok += attempt_out
        accumulated_cost += attempt_cost

    turn = 0
    try:
        while True:
            remaining = timeout - (time.time() - start)
            if remaining <= 0:
                timed_out = True
                final_status = "TIMEOUT"
                break

            turn_prompt = prompt if turn == 0 else RETRY_PROMPT
            print(f"\n[TURN] attempt={turn}", flush=True)
            _run_attempt(turn_prompt)

            # Stop as soon as tests actually executed — do not retry further.
            if tests_ran:
                print("\n[STOP] Tests executed — stopping (no more retries).", flush=True)
                break

            # Stop if done or hard-limited
            if final_status == "SUCCESS":
                break
            if cost_exceeded or token_limit_hit or timed_out:
                break
            # API/billing error — retrying just re-hits the same wall.
            if api_error:
                print("\n[STOP] API error (e.g. credit exhausted) — not retrying.", flush=True)
                break

            # Agent gave up early — retry only if enough tokens remain.
            if final_status in ("UNKNOWN", "FAIL"):
                total_so_far = total_input_tok + total_output_tok
                headroom = token_limit - total_so_far if token_limit > 0 else 999_999
                min_headroom = max(30_000, token_limit // 3) if token_limit > 0 else 30_000
                if headroom < min_headroom:
                    print(
                        f"\n[STOP] Only {headroom:,} tokens left — not enough to retry. Stopping.",
                        flush=True,
                    )
                    break
                print(
                    f"\n[RETRY] Agent stopped early "
                    f"(status={final_status}, tokens={total_so_far}). Retrying.",
                    flush=True,
                )
                final_status = "UNKNOWN"
                turn += 1
                continue

            break

    finally:
        pass

    duration = time.time() - start

    # Determine final status
    if final_status == "UNKNOWN":
        if api_error:
            final_status = "API_ERROR"
        elif cost_exceeded:
            final_status = "COST_LIMIT"
        elif token_limit_hit:
            final_status = "TOKEN_LIMIT"
        elif timed_out:
            final_status = "TIMEOUT"
        else:
            # Scan trace for FINAL_STATUS
            for l in reversed(all_stdout_lines):
                try:
                    evt = json.loads(l)
                    for block in evt.get("message", {}).get("content", []):
                        if block.get("type") == "text":
                            m = FINAL_STATUS_RE.search(block.get("text", ""))
                            if m:
                                final_status = m.group(1).upper()
                                break
                except Exception:
                    pass
                if final_status != "UNKNOWN":
                    break

    # Save trace and stderr
    (out_dir / "claude_trace.jsonl").write_text("\n".join(all_stdout_lines), encoding="utf-8")
    (out_dir / "claude_stderr.txt").write_text("".join(stderr_lines), encoding="utf-8")

    result = {
        "final_status":     final_status,
        "tests_ran":        tests_ran,
        "attempts":         turn + 1,
        "api_error":        api_error,
        "timed_out":        timed_out,
        "cost_exceeded":    cost_exceeded,
        "token_limit_hit":  token_limit_hit,
        "duration_seconds": round(duration, 3),
        "input_tokens":     total_input_tok,
        "output_tokens":    total_output_tok,
        "total_tokens":     total_input_tok + total_output_tok,
        "cost_usd":         accumulated_cost,
    }
    (out_dir / "result.json").write_text(json.dumps(result, indent=2), encoding="utf-8")

    # Copy artifacts from work_dir → out_dir
    work_path = Path(work_dir)
    for fname in ("Dockerfile", "run.sh"):
        dst = out_dir / fname
        if dst.is_file():
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
            matches = list(work_path.rglob("run_output.log"))
            if matches:
                shutil.copy2(matches[0], log_dst)
                print(f"[SAVE] log.txt copied from {matches[0]}", flush=True)

    tee.close()
    return result


# ---------------------------------------------------------------------------
# CLI entry point
# ---------------------------------------------------------------------------

def main():
    parser = argparse.ArgumentParser(
        description="Claude Code CLI agent — provide only a GitHub Actions job URL."
    )
    parser.add_argument("link",
                        help="GitHub Actions job URL")
    parser.add_argument("--out",         default=None,
                        help="Output directory (default: auto-derived from repo+job_id).")
    parser.add_argument("--model",       default=DEFAULT_MODEL,
                        help=f"Claude model (default: {DEFAULT_MODEL}).")
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
              Path(f"output/claude_cli_backup/{repo}_{job_id}/out").resolve()

    # work_dir inside trusted project directory so Claude can write freely
    script_dir = Path(__file__).resolve().parent
    work_dir = str(script_dir / "claude_workdir" / f"{repo}_{job_id}")
    Path(work_dir).mkdir(parents=True, exist_ok=True)
    print(f"[SETUP] work_dir : {work_dir}")

    github_token = GITHUB_TOKENS[0] if GITHUB_TOKENS else ""

    prompt = build_agent_prompt(
        link=args.link,
        work_dir=work_dir,
        image_name=image_name,
    )

    print(f"Starting Claude agent for: {owner}/{repo}  job={job_id}")
    print(f"  output   : {out_dir}")
    print(f"  image    : {image_name}")
    print(f"  model    : {args.model}")
    print(f"  timeout  : {args.timeout}s")
    print(f"  cost lim : ${args.cost_limit:.2f}")
    print(f"  tok lim  : {args.token_limit:,}" if args.token_limit > 0 else "  tok lim  : disabled")

    result = claude_exec(
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


# Example:
#   python claude_cli_backup.py \
#     "https://github.com/pallets/flask/actions/runs/24007687136/job/70014021145"

if __name__ == "__main__":
    main()
