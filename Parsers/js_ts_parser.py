import re
import argparse

class BaseLogAnalyzer:
    _ANSI_RE = re.compile(r'\x1B[@-_][0-?]*[ -/]*[@-~]', re.M)
    _TS_RE   = re.compile(r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d+Z\s+')
    _ACT_RE         = re.compile(r'^\[[\w/ ._-]+\]\s{2,}(?:\|\s?)?')
    _TASK_PREFIX_RE = re.compile(r'^@?[\w][\w/@-]*:[\w][\w-]*:\s+')

    def __init__(self, lines):
        self.lines = lines
        self.did_tests_fail = False
        self.num_tests_failed = 0
        self.num_tests_run = 0
        self.num_tests_passed = 0
        self.num_tests_skipped = 0
        self.num_test_suits_failed = 0
        self.test_duration = 0.0
        self.tests_failed = []
        self.framework = None



    def clean_line(self, line):
        """Strip ANSI codes, GitHub timestamps, act runner prefixes, and task runner prefixes."""
        line = self._ANSI_RE.sub('', line)
        line = self._TS_RE.sub('', line)
        line = self._ACT_RE.sub('', line)
        line = self._TASK_PREFIX_RE.sub('', line)
        return line.strip()

    def analyze(self):
        raise NotImplementedError("Subclasses should implement this method")
    
    def is_applicable(self):
        """Our Analyzers can override this and use to check logs searching for something unique to them 
        and determine if the logfile applies to them"""
        return False

class TAPLogAnalyzer(BaseLogAnalyzer):
    def __init__(self, lines):
        super().__init__(lines)
        self.framework = "tap"
    
    def is_applicable(self):
    # Check for TAP version line, ignoring any leading characters (like timestamps)
        tap_version_pattern = r'TAP version \d+'
        
        # Check for 'ok' or 'not ok' lines, which are typical in TAP outputs
        test_result_pattern = r'^(?:.*?\s)?(ok|not ok) \d+'

        return any(re.search(tap_version_pattern, line) for line in self.lines) or \
            any(re.search(test_result_pattern, line) for line in self.lines)


    def analyze(self):

        tap_test_total = None
        tap_test_fail = None
        tap_test_skip = None
        tap_test_duration = None

        tap_test_failure = re.compile(
            r"not ok \d+ - (?P<name>[^\n]+)\n"
            r"[\s\S]*?"
            r"location:\s*'(?P<file>[^']+)'\n"
            r"[\s\S]*?"
            r"failureType:\s*'(?P<error>[^']+)'"
        )            
        failure_matches = tap_test_failure.finditer("".join(self.lines))
        self.tap_test_failure = []
        for match in failure_matches:
            test_name = match.group("name").strip()
            test_file = match.group("file").strip()
            test_error = match.group("error").strip()
            self.tap_test_failure.append({"file": test_file, "failures": [{"name": test_name, "error": test_error}]})
        
        num_tests_run = 0
        num_tests_failed = 0
        num_tests_skipped = 0
        total_duration = 0.0
        _seen = set()   # deduplicate identical suite results (retries)

        # Collect per-suite data: keyed on the plan line position
        _plan_run = None   # from 1..N
        _pass_n   = None   # from # pass N
        _fail_n   = None   # from # fail N
        _skip_n   = None   # from # skipped N

        def _flush():
            nonlocal _plan_run, _pass_n, _fail_n, _skip_n
            if _plan_run is None and _pass_n is None:
                return
            run  = _plan_run if _plan_run is not None else ((_pass_n or 0) + (_fail_n or 0) + (_skip_n or 0))
            fail = _fail_n or 0
            skip = _skip_n or 0
            sig  = (run, fail, skip)
            nonlocal num_tests_run, num_tests_failed, num_tests_skipped
            if sig not in _seen:
                _seen.add(sig)
                num_tests_run     += run
                num_tests_failed  += fail
                num_tests_skipped += skip
            _plan_run = _pass_n = _fail_n = _skip_n = None

        _ts = re.compile(r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d+Z\s+')
        for line in self.lines:
            clean_line = _ts.sub('', line).strip()
            m_plan     = re.match(r'^1\.\.(\d+)', clean_line)
            m_total    = re.search(r'# tests\s+(\d+)', line)
            m_pass     = re.search(r'# pass\s+(\d+)', line)
            m_fail     = re.search(r'# fail\s+(\d+)', line)
            m_skip     = re.search(r'# skipped\s+(\d+)', line)
            m_duration = re.search(r'# duration_ms\s+([\d.]+)', line)

            if m_plan:
                _flush()                          # flush previous suite
                _plan_run = int(m_plan.group(1))
            if m_total:
                _plan_run = int(m_total.group(1)) # # tests overrides plan
            if m_pass:
                _pass_n = int(m_pass.group(1))
            if m_fail:
                _fail_n = int(m_fail.group(1))
            if m_skip:
                _skip_n = int(m_skip.group(1))
            if m_duration:
                _flush()
                total_duration += float(m_duration.group(1)) / 1000

        _flush()  # flush last suite

        num_tests_passed = num_tests_run - num_tests_failed - num_tests_skipped
        return {
            "framework": self.framework,
            "num_tests_run": num_tests_run,
            "num_tests_failed": num_tests_failed,
            "num_tests_passed": num_tests_passed,
            "num_tests_skipped": num_tests_skipped,
            "test_duration": total_duration,
            "num_test_suits_failed": self.num_test_suits_failed,
            "tests_failed": self.tap_test_failure
        }

class MochaLogAnalyzer(BaseLogAnalyzer):
    def __init__(self, lines):
        super().__init__(lines)
        self.framework = "mocha"
        
        
    def is_applicable(self):
        _ansi = re.compile(r'\x1B[@-_][0-?]*[ -/]*[@-~]', re.M)
        cleaned = [_ansi.sub('', l) for l in self.lines]
        has_mocha   = any(re.search(r'\bmocha\b', l, re.IGNORECASE) for l in cleaned)
        has_jasmine = any(re.search(r'\bjasmine\b', l, re.IGNORECASE) for l in cleaned)
        # Fallback: detect by Mocha summary format
        has_passing = any(re.search(r'\d+ passing \(\d+\w+\)', l) for l in cleaned)
        return (has_mocha or has_passing) and not has_jasmine



    def convert_time_to_sec(self, match):
        time = float(match.group(2))
        unit = match.group(3)
        if unit == 'ms':
            return time / 1000
        if unit == 'm':
            return time * 60
        return time

    def analyze(self):
        def mocha_remove_timestamp(text):
            return re.sub(r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d+Z\s+', '', text)
        non_ascii   = re.compile(r'[^\x00-\x7F]+')

        failure_started = False
        error_started = False
        test_file = ""
        test_name = ""
        prev_line = ""
        prev_2line = ""
        test_error = ""
        _seen_summaries = set()   # deduplicate retry runs
        _pending_passed = None    # buffer passing count until we see pending

        for line in self.lines:
            line = self.clean_line(line)
            line = non_ascii.sub('', line)
            line = mocha_remove_timestamp(line)
            mocha_failing = re.search(r'(\d+) failing$', line)
            mocha_pass_and_time = re.search(r'(\d+) passing \((\d+)(\w+)\)$', line)
            mocha_pending = re.search(r'(\d+) pending$', line)
            mocha_failure = re.search(r'\s*(\d+)\)\s(.*)$', line)
            mocha_error = re.search(r"\s*Error:\s(.*)", line)

            if mocha_failure and self.did_tests_fail and not error_started:
                failure_started = True
                test_file += mocha_failure.group(2)
            elif mocha_failing:
                self.did_tests_fail = True
                self.num_tests_failed += int(mocha_failing.group(1))
                self.num_tests_run += int(mocha_failing.group(1))
            elif mocha_pass_and_time:
                # flush any previous standalone passing run (no pending followed)
                if _pending_passed is not None:
                    p_n, dur = _pending_passed
                    sig = (p_n, 0)
                    if sig not in _seen_summaries:
                        _seen_summaries.add(sig)
                        self.num_tests_passed += p_n
                        self.num_tests_run    += p_n
                        self.test_duration    += dur
                _pending_passed = (int(mocha_pass_and_time.group(1)),
                                   self.convert_time_to_sec(mocha_pass_and_time))
            elif mocha_pending and _pending_passed is not None:
                passed_n, dur = _pending_passed
                pending_n = int(mocha_pending.group(1))
                sig = (passed_n, pending_n)
                if sig not in _seen_summaries:
                    _seen_summaries.add(sig)
                    self.num_tests_passed  += passed_n
                    self.num_tests_skipped += pending_n
                    self.num_tests_run     += passed_n + pending_n
                    self.test_duration     += dur
                _pending_passed = None
            elif mocha_pending:
                pending_n = int(mocha_pending.group(1))
                sig = (0, pending_n)
                if sig not in _seen_summaries:
                    _seen_summaries.add(sig)
                    self.num_tests_skipped += pending_n
                    self.num_tests_run     += pending_n

            if failure_started and not mocha_error and not mocha_failure:
                trimmed_line = mocha_remove_timestamp(line)
                trimmed_line = trimmed_line.strip()
                if not prev_line:
                    prev_line = trimmed_line
                elif not prev_2line:
                    prev_2line = trimmed_line
                else:
                    test_file += " > " + prev_2line
                    prev_2line = prev_line
                    prev_line = trimmed_line
            elif failure_started and mocha_error:
                if prev_2line:
                    test_file += " > " + prev_2line
                test_name = prev_line
                test_error = "Error: " + mocha_error.group(1) + "\n"
                failure_started = False
                error_started = True
            elif error_started:
                trimmed_line = mocha_remove_timestamp(line)
                if (re.search(r'^\s*$', trimmed_line)):
                    for test in self.tests_failed:
                        if test["file"] == test_file:
                            # If the file is already present, append the new failure
                            test["failures"].append({"name": test_name, "error": test_error})
                            break
                    else:
                        # If the file is not found, create a new entry
                        self.tests_failed.append({
                            "file": test_file,
                            "failures": [{"name": test_name, "error": test_error}]
                        })
                    test_file = ""
                    test_name = ""
                    test_error = ""
                    error_started = False
                else:
                    test_error += trimmed_line.strip() + "\n"

        # flush any trailing standalone passing run (no pending line followed)
        if _pending_passed is not None:
            p_n, dur = _pending_passed
            sig = (p_n, 0)
            if sig not in _seen_summaries:
                _seen_summaries.add(sig)
                self.num_tests_passed += p_n
                self.num_tests_run    += p_n
                self.test_duration    += dur

        return {
            "framework": self.framework,
            "num_tests_run": self.num_tests_run,
            "num_tests_failed": self.num_tests_failed,
            "num_tests_passed": self.num_tests_passed,
            "num_tests_skipped": self.num_tests_skipped,
            "test_duration": self.test_duration,
            "num_test_suits_failed": self.num_test_suits_failed,
            "tests_failed": self.tests_failed
        }

class JasmineLogAnalyzer(BaseLogAnalyzer):
    def __init__(self, lines):
        super().__init__(lines)
        self.framework = "jasmine"
    
    def is_applicable(self):
        return any(re.search(r'\bjasmine\b', line, re.IGNORECASE) for line in self.lines)


    def convert_time_to_sec(self, match):
        time = float(match.group(2))
        unit = match.group(3)
        return time

    def analyze(self):
        def jasmine_remove_timestamp(text):
            return re.sub(r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d+Z\s+', '', text)
        failure_started = False
        test_file = ""
        test_name = ""
        test_error = ""
        for line in self.lines:
            line = self.clean_line(line)
            jasmine_failure = re.search(r'Test output for (\/\/\S+):$', line)
            jasmine_pass_and_time = re.search(r'(//\S+)\s+PASSED in (\d+\.\d+|\d+)(\w+)', line)
            jasmine_fail_and_time = re.search(r'(//\S+)\s+FAILED in (\d+\.\d+|\d+)(\w+)', line)
            jasmine_pending = re.search(r'(\d+) pending$', line)
            jasmine_summary = re.search(r'Executed (\d+) out of (\d+) tests?: (\d+) tests? pass[es]? and (\d+) fails? remotely.$', line)
            karma_summary = re.search(r'Executed\s+(\d+)\s+out\s+of\s+(\d+)\s+tests?:(?:\s+(\d+)\s+FAILED?,)?\s*(\d+)\s+tests?\s+pass', line, re.IGNORECASE)
            jasmine_test_end = re.search(r'=====*$', line)

            if jasmine_failure:
                self.did_tests_fail = True
                failure_started = True
                test_file = jasmine_failure.group(1).split(":")[0]
                test_name = jasmine_failure.group(1).split(":")[1]
            elif jasmine_fail_and_time:
                self.did_tests_fail = True
                self.test_duration += self.convert_time_to_sec(jasmine_fail_and_time)
            elif jasmine_pass_and_time:
                self.test_duration += self.convert_time_to_sec(jasmine_pass_and_time)
            elif jasmine_summary:
                self.num_tests_run = int(jasmine_summary.group(2))
                self.num_tests_failed = int(jasmine_summary.group(4))
                self.num_tests_passed += int(jasmine_summary.group(3))
                self.num_tests_skipped = int(jasmine_summary.group(2)) - int(jasmine_summary.group(1))
            elif karma_summary:
                self.num_tests_run = int(karma_summary.group(2))
                self.num_tests_failed = int(karma_summary.group(3)) if karma_summary.group(3) else 0
                self.num_tests_passed = int(karma_summary.group(4))
                self.num_tests_skipped = self.num_tests_run - self.num_tests_passed - self.num_tests_failed
                self.did_tests_fail = self.num_tests_failed > 0
            elif failure_started:
                trimmed_line = jasmine_remove_timestamp(line)
                # Error is multiple lines long, keep going until it reaches its end
                if jasmine_test_end:
                    for test in self.tests_failed:
                        if test["file"] == test_file:
                            # If the file is already present, append the new failure
                            test["failures"].append({"name": test_name, "error": test_error})
                            break
                    else:
                        # If the file is not found, create a new entry
                        self.tests_failed.append({
                            "file": test_file,
                            "failures": [{"name": test_name, "error": test_error}]
                        })
                    # Reset failure information after a match
                    failure_started = False
                    test_file = ""
                    test_name = ""
                    test_error = ""
                else:
                    test_error += trimmed_line
        return {
            "framework": self.framework,
            "num_tests_run": self.num_tests_run,
            "num_tests_failed": self.num_tests_failed,
            "num_tests_passed": self.num_tests_passed,
            "num_tests_skipped": self.num_tests_skipped,
            "test_duration": self.test_duration,
            "num_test_suits_failed": self.num_test_suits_failed,
            "tests_failed": self.tests_failed
        }

class JasmineNpmLogAnalyzer(BaseLogAnalyzer):
    """Parser for npm `jasmine` output: '304 specs, 1 failure'."""

    _SUMMARY_RE = re.compile(
        r'(\d+)\s+specs?,\s+(\d+)\s+failures?(?:,\s+(\d+)\s+pending)?',
        re.IGNORECASE
    )
    _FAILURE_HEADER_RE = re.compile(r'^\s*\d+\)\s+(.+)')

    def __init__(self, lines):
        super().__init__(lines)
        self.framework = "jasmine"

    def is_applicable(self):
        return any(self._SUMMARY_RE.search(self.clean_line(l)) for l in self.lines)

    def analyze(self):
        in_failures = False
        current_name = None
        current_error = []

        def flush(name, error_lines):
            if name is not None:
                self.tests_failed.append({
                    "file": "",
                    "failures": [{"name": name, "error": "\n".join(error_lines)}]
                })

        for raw in self.lines:
            line = self.clean_line(raw)

            summary = self._SUMMARY_RE.search(line)
            if summary:
                self.num_tests_run = int(summary.group(1))
                self.num_tests_failed = int(summary.group(2))
                pending = int(summary.group(3)) if summary.group(3) else 0
                self.num_tests_skipped = pending
                self.num_tests_passed = self.num_tests_run - self.num_tests_failed - pending
                self.did_tests_fail = self.num_tests_failed > 0
                in_failures = False
                flush(current_name, current_error)
                current_name = None
                current_error = []
                continue

            if re.search(r'^Failures?:\s*$', line):
                in_failures = True
                continue

            if in_failures:
                m = self._FAILURE_HEADER_RE.match(line)
                if m:
                    flush(current_name, current_error)
                    current_name = m.group(1).strip()
                    current_error = []
                elif current_name is not None:
                    current_error.append(line)

        flush(current_name, current_error)

        return {
            "framework": self.framework,
            "num_tests_run": self.num_tests_run,
            "num_tests_failed": self.num_tests_failed,
            "num_tests_passed": self.num_tests_passed,
            "num_tests_skipped": self.num_tests_skipped,
            "test_duration": self.test_duration,
            "num_test_suits_failed": self.num_test_suits_failed,
            "tests_failed": self.tests_failed,
        }

class BunTestLogAnalyzer(BaseLogAnalyzer):
    """Parser for Bun test output: 'N pass / N fail / N error' + 'Ran N tests across M files.'"""

    _SUMMARY_RE       = re.compile(r'^Ran\s+(\d+)\s+tests\s+across\s+\d+\s+files.*\[(\d+(?:\.\d+)?)ms\]', re.IGNORECASE)
    _PASS_RE          = re.compile(r'^\s*(\d+)\s+pass\s*$')
    _FAIL_RE          = re.compile(r'^\s*(\d+)\s+fail\s*$')
    _ERROR_RE         = re.compile(r'^\s*(\d+)\s+error\s*$')
    _FAIL_TEST_RE     = re.compile(r'^\(fail\)\s+(.+?)\s+\[\d+(?:\.\d+)?ms\]')
    _FILE_RE          = re.compile(r'^([\w./@-][^\s:]*\.(?:ts|js|tsx|jsx|mts|mjs|cts|cjs))\s*:\s*$', re.IGNORECASE)
    _UNHANDLED_RE     = re.compile(r'^#\s+Unhandled error between tests', re.IGNORECASE)
    _ERROR_MSG_RE     = re.compile(r'^error:\s+(.+)$', re.IGNORECASE)
    _SEPARATOR_RE     = re.compile(r'^-{5,}$')

    def __init__(self, lines):
        super().__init__(lines)
        self.framework = "bun"

    def is_applicable(self):
        return any(self._SUMMARY_RE.search(self.clean_line(l)) for l in self.lines)

    def analyze(self):
        current_file  = ""
        in_unhandled  = False
        sep_count     = 0
        current_error = ""

        for raw in self.lines:
            line = self.clean_line(raw)

            m = self._FILE_RE.match(line)
            if m:
                current_file = m.group(1)
                continue

            if self._UNHANDLED_RE.match(line):
                in_unhandled = True
                sep_count    = 0
                current_error = ""
                continue

            if in_unhandled:
                if self._SEPARATOR_RE.match(line):
                    sep_count += 1
                    if sep_count == 2 and current_error:
                        self.tests_failed.append({
                            "file": current_file,
                            "failures": [{"name": "[unhandled error]", "error": current_error}]
                        })
                        in_unhandled  = False
                        current_file  = ""
                        current_error = ""
                else:
                    m_err = self._ERROR_MSG_RE.match(line)
                    if m_err:
                        current_error = m_err.group(1)
                continue

            m = self._SUMMARY_RE.search(line)
            if m:
                self.num_tests_run = int(m.group(1))
                self.test_duration = float(m.group(2)) / 1000
                continue

            m = self._PASS_RE.match(line)
            if m:
                self.num_tests_passed = int(m.group(1))
                continue

            m = self._FAIL_RE.match(line)
            if m:
                self.num_tests_failed = int(m.group(1))
                self.did_tests_fail = self.num_tests_failed > 0
                continue

            m = self._ERROR_RE.match(line)
            if m:
                self.num_test_suits_failed += int(m.group(1))
                self.did_tests_fail = True
                continue

            m = self._FAIL_TEST_RE.match(line)
            if m:
                self.tests_failed.append({"file": "", "failures": [{"name": m.group(1).strip()}]})

        self.num_tests_skipped = max(0, self.num_tests_run - self.num_tests_passed - self.num_tests_failed)

        return {
            "framework": self.framework,
            "num_tests_run": self.num_tests_run,
            "num_tests_failed": self.num_tests_failed,
            "num_tests_passed": self.num_tests_passed,
            "num_tests_skipped": self.num_tests_skipped,
            "test_duration": self.test_duration,
            "num_test_suits_failed": self.num_test_suits_failed,
            "tests_failed": self.tests_failed,
        }

class JestLogAnalyzer(BaseLogAnalyzer):
    def __init__(self, lines):
        super().__init__(lines)
        self.framework = "jest"

    def is_applicable(self):
        # Primary: "jest" keyword anywhere in the log
        if any(re.search(r'\bjest\b', line, re.IGNORECASE) for line in self.lines):
            return True
        # Fallback: Jest summary format (unique to Jest)
        return any(
            re.search(r'Test Suites:\s+.*\d+\s+total', line, re.IGNORECASE) or
            re.search(r'Tests:\s+.*\d+\s+total', line, re.IGNORECASE)
            for line in self.lines
        )


    def get_int_from_match(self, match):
        return int(re.sub(r'\D', '', match)) if match else 0

    def jest_extract_failing_tests(self):
        captured_lines = []
        capturing = False
        summary_regex = re.compile(r"Summary of all failing tests", re.IGNORECASE)
        stop_regex = re.compile(r"(Test Suites:|Tests:|Snapshots:|Time:)", re.IGNORECASE)

        for line in self.lines:
            stripped_line = line.strip()
            if not capturing and re.search(summary_regex, stripped_line):
                capturing = True
                continue  
            if capturing and re.search(stop_regex, stripped_line):
                break  
            if capturing:
                captured_lines.append(stripped_line)

        def jest_remove_timestamp(text):
            return re.sub(r"^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d+Z\s*", "", text)

        groups = []
        current_group = None
        current_failure = None

        # First check: use "FAIL" lines and the " > " 
        for line in captured_lines:
            clean_line = jest_remove_timestamp(line).strip()
            if not clean_line:
                continue

            if re.search(r"^FAIL\s+", clean_line):
                m = re.search(r"^FAIL\s+(.*)", clean_line)
                file_name = m.group(1).strip() if m else "Unknown"
                current_group = {"file": file_name, "failures": []}
                groups.append(current_group)
                current_failure = None
            elif current_group is not None:
                if " > " in clean_line and not re.match(r"^Error:", clean_line):
                    current_failure = {"name": clean_line, "error": ""}
                    current_group["failures"].append(current_failure)
                elif re.match(r"^Error:", clean_line):
                    if current_failure is not None and current_failure["error"] == "":
                        current_failure["error"] = clean_line

        # Fallback check: if no test names/errors were captured by the first check.
        if not groups or all(len(g["failures"]) == 0 for g in groups):
            fallback_groups = []
            fallback_group = {"file": "Unknown", "failures": []}
            fallback_groups.append(fallback_group)
            for i, line in enumerate(captured_lines):
                clean_line = jest_remove_timestamp(line).strip()

                if re.search(r"^FAIL\s+", clean_line):
                    m = re.search(r"^FAIL\s+(.*)", clean_line)
                    file_name = m.group(1).strip() if m else "Unknown"
                    fallback_group["file"] = file_name

                elif re.match(r"^Error:", clean_line):
                    if i > 0:
                        test_name = jest_remove_timestamp(captured_lines[i - 1]).strip()
                    else:
                        test_name = "Unknown test"
                    error_line = clean_line
                    if i + 1 < len(captured_lines):
                        next_line = jest_remove_timestamp(captured_lines[i + 1]).strip()
                        if next_line and not re.match(r"^Error:", next_line):
                            error_line += " " + next_line
                    fallback_group["failures"].append({"name": test_name, "error": error_line})
            groups = fallback_groups

        self.tests_failed = groups

    def analyze(self):
        _ansi = re.compile(r'\x1B[@-_][0-?]*[ -/]*[@-~]', re.M)
        _ts   = re.compile(r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d+Z\s+')
        for raw_line in self.lines:
            line = _ansi.sub('', _ts.sub('', raw_line))
            jest_tests = re.search(r'Tests:\s+(\d+ failed, )?(\d+ skipped, )?(\d+ passed, )?(\d+ total)', line)
            jest_time = re.search(r'Time:\s+(\d+\.?\d*)\s?s', line)

            # A suite can fail to run (import/setup/compile error) without any
            # individual test failing, e.g. "Test Suites: 21 failed, 1 passed, 22 total".
            jest_suites = re.search(r'Test Suites:.*?(\d+)\s+failed', line)
            if jest_suites:
                self.num_test_suits_failed += int(jest_suites.group(1))
                self.did_tests_fail = True

            if jest_tests:
                jest_total = self.get_int_from_match(jest_tests.group(4))
                if jest_total == 0:
                    continue
                if jest_tests.group(1):
                    self.did_tests_fail = True
                    jest_failed = self.get_int_from_match(jest_tests.group(1))
                    self.num_tests_failed += jest_failed
                if jest_tests.group(2):
                    jest_skipped = self.get_int_from_match(jest_tests.group(2))
                    self.num_tests_skipped += jest_skipped
                if jest_tests.group(3):
                    jest_passed = self.get_int_from_match(jest_tests.group(3))
                    self.num_tests_passed += jest_passed
                if jest_tests.group(4):
                    jest_run = self.get_int_from_match(jest_tests.group(4))
                    self.num_tests_run += jest_run
            if jest_time and self.num_tests_run:
                self.test_duration += float(jest_time.group(1))

        self.jest_extract_failing_tests()

        return {
            "framework": self.framework,
            "num_tests_run": self.num_tests_run,
            "num_tests_failed": self.num_tests_failed,
            "num_tests_passed": self.num_tests_passed,
            "num_tests_skipped": self.num_tests_skipped,
            "test_duration": self.test_duration,
            "num_test_suits_failed": self.num_test_suits_failed,
            "tests_failed": self.tests_failed
        }
        
class QUnitLogAnalyzer(BaseLogAnalyzer):
    def __init__(self, lines):
        super().__init__(lines)
        self.framework = "qunit"
        
    def is_applicable(self):
        return any(re.search(r'\bqunit\b', line, re.IGNORECASE) for line in self.lines)
    
    def analyze(self):
        qunit_test_total = 0
        qunit_test_fail = 0
        qunit_test_skip = 0
        qunit_test_duration = 0
        qunit_test_passed = 0
        test_time_list = []
        test_error_list = []
        test_fails = []
        test_error_go = False
        
        for line in self.lines:
            qunit_test_duration_pattern = re.search(r'Tests finished in (\d+)s (\d+)ms (.)+', line)
            qunit_test_failed_num_pattern = re.search(r'(\d+) tests failed.', line)
            # 2 failed. 1122 passed. 0 skipped.
            qunit_test_summary = re.search(r'(\d+) failed. (\d+) passed. (\d+) skipped', line)
            qunit_error = re.search(r'(\d+)\.(\s)+(.+)', line)
            if qunit_test_duration_pattern:
                seconds = qunit_test_duration_pattern.group(1)
                miliseconds = qunit_test_duration_pattern.group(2)
                qunit_test_duration = seconds + '.' + miliseconds
                test_time_list.append(qunit_test_duration)
            if qunit_test_failed_num_pattern:
                qunit_test_fail = int(qunit_test_failed_num_pattern.group(1))
            if qunit_test_summary:
                qunit_test_passed = int(qunit_test_summary.group(2))
                qunit_test_skip = int(qunit_test_summary.group(3))
                
            if qunit_error:
                test_error_go = True
                if len(test_fails) > 0:
                    test_error_list.append(test_fails)
                    test_fails = []
            if line.startswith("Cleaning up"):
                test_error_go = False
                test_error_list.append(test_fails)
            if test_error_go == True:
                test_fails.append(line)
        qunit_test_total = qunit_test_fail + qunit_test_passed + qunit_test_skip
        
        for test_error in test_error_list:
            test_file = ""
            test_name = ""
            test_error_name = ""
            test_no = ""
            is_test_file = True
            for i in range(len(test_error)):
                line_ = test_error[i]
                qunit_test_failure = re.search(r'(\d+)\.(\s)+(.+)', line_)
                qunit_test_file = re.search(r'(\s+at|@)(\s)*http://localhost:(\d+)/(.+):(\d+):(\d+)', line_)
                qunit_test_error = re.search(r'Died on test (.+):(.+)', line_)
                if qunit_test_failure:
                    test_name = qunit_test_failure.group(3)
                if qunit_test_error:
                    test_no = "Test " + qunit_test_error.group(1)
                    test_error_name = qunit_test_error.group(2)
                if qunit_test_file and is_test_file:
                    test_file = qunit_test_file.group(4)
                    is_test_file = False
            test_descr = test_no + ": " + test_name
            self.tests_failed.append({
                "file": test_file,
                "failures": [{"name": test_descr, "error": test_error_name}]
            })
        
        # for error in test
        return {
            "framework": self.framework,
            "num_tests_run": qunit_test_total,
            "num_tests_failed": qunit_test_fail,
            "num_tests_passed": qunit_test_passed,
            "num_tests_skipped": qunit_test_skip,
            "test_duration": float(qunit_test_duration),
            "num_test_suits_failed": self.num_test_suits_failed,
            "tests_failed": self.tests_failed
        }
    
    def qunit_remove_timestamp(text):
        return re.sub(r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d+Z\s+', '', text)
        
class VitestLogAnalyzer(BaseLogAnalyzer):
    def __init__(self, lines):
        super().__init__(lines)
        self.framework = "vitest"
    
    _TS = re.compile(r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d+Z\s+')
    _ANSI = re.compile(r'\x1B[@-_][0-?]*[ -/]*[@-~]', re.M)

    # One workspace/runner prefix segment ending in a ":" or "|" separator.
    # Handles: "> pkg-name: ", "pkg:task | " (turbo/bun monorepo), and the
    # nektos/act job prefix "[sdk-test/Test (ubuntu-latest, Node 24.x)] | ".
    _WS = re.compile(r'^(?:\[[^\]]*\]|[.>]?\s*[\w@][\w:@/.-]*(?:\s+[\w-]+)?)\s*[:|]\s+')

    def _strip_prefixes(self, line):
        # Peel nested prefixes (act may stack its job prefix on top of the
        # turbo package prefix), one segment per pass.
        for _ in range(4):
            new = self._WS.sub('', line, count=1)
            if new == line:
                break
            line = new
        return line

    def _clean(self, line):
        line = self.clean_line(line)
        line = self._strip_prefixes(line)
        return line

    def is_applicable(self):
        return any(re.search(r'\bvitest\b', line, re.IGNORECASE) for line in self.lines) or \
               any(re.search(r'^\s*Test\s+Files\s+\d+', self._clean(line), re.IGNORECASE) for line in self.lines)


    def convert_time_to_sec(self, match):
        time = float(match.group(1))
        unit = match.group(2)
        if unit == 'ms':
            return time / 1000
        if unit == 'm':
            return time * 60
        return time

    def analyze(self):
        def vitest_remove_timestamp(text):
            return re.sub(r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d+Z\s+', '', text)
        non_ascii      = re.compile(r'[^\x00-\x7F]+')
        # FAIL  path/to/file.spec.ts > suite name > test name
        fail_line      = re.compile(r'FAIL\s+(\S+\.(?:spec|test)\.[a-z]+)\s+>\s+(.+)$', re.IGNORECASE)
        # FAIL  path/to/file.js [ ... ]  — suite-level failure, no individual test
        suite_fail_re  = re.compile(r'^FAIL\s+(\S+)\s*(?:\[.*\])?$', re.IGNORECASE)
        failure_started = False
        suite_failure_started = False
        test_file = ""
        test_name = ""
        test_error = ""
        for line in self.lines:
            line = self.clean_line(line)
            line = non_ascii.sub('', line)
            line = vitest_remove_timestamp(line)
            line = self._strip_prefixes(line)   # strip workspace/runner prefixes

            vitest_failure      = fail_line.search(line)
            vitest_suite_fail   = suite_fail_re.match(line) if not vitest_failure else None
            vitest_error        = re.search(r'(?:AssertionError|Error|TypeError|ReferenceError):\s*(.+)$', line)
            vitest_duration     = re.search(r'Duration\s+(\d+\.\d+|\d+)(\w+)', line)
            vitest_tests_line   = re.search(r'^\s*Tests\s+\d+', line)
            vitest_files_line   = re.search(r'^\s*Test\s+Files\s+', line)
            vitest_errors_line  = re.search(r'^\s*Errors\s+(\d+)\s+error', line)

            if vitest_failure:
                # flush any pending suite-level failure
                if suite_failure_started and test_file:
                    self._save_vitest_failure(test_file, "[suite failure]", test_error.strip())
                    suite_failure_started = False
                # save previous individual failure if pending
                if failure_started and test_file:
                    self._save_vitest_failure(test_file, test_name, test_error)
                self.did_tests_fail = True
                failure_started = True
                suite_failure_started = False
                test_file = vitest_failure.group(1).strip()
                test_name = vitest_failure.group(2).strip()
                test_error = ""
            elif vitest_suite_fail:
                # flush any pending failure first
                if failure_started and test_file:
                    self._save_vitest_failure(test_file, test_name, test_error.strip())
                    failure_started = False
                if suite_failure_started and test_file:
                    self._save_vitest_failure(test_file, "[suite failure]", test_error.strip())
                self.did_tests_fail = True
                suite_failure_started = True
                test_file = vitest_suite_fail.group(1).strip()
                test_name = "[suite failure]"
                test_error = ""
            elif vitest_errors_line:
                self.num_tests_failed += int(vitest_errors_line.group(1))
                self.did_tests_fail = True
            elif vitest_files_line:
                m_files_failed = re.search(r'(\d+)\s+failed', line)
                if m_files_failed:
                    self.num_test_suits_failed += int(m_files_failed.group(1))
                    self.did_tests_fail = True
            elif vitest_duration:
                self.test_duration = self.convert_time_to_sec(vitest_duration)
            elif vitest_tests_line:
                # flush any pending failure before reading summary
                if failure_started and test_file:
                    self._save_vitest_failure(test_file, test_name, test_error)
                    failure_started = False
                    test_file = test_name = test_error = ""
                if suite_failure_started and test_file:
                    self._save_vitest_failure(test_file, "[suite failure]", test_error.strip())
                    suite_failure_started = False
                    test_file = test_name = test_error = ""
                m_total    = re.search(r'\(\s*(\d+)\s*\)', line)
                m_passed   = re.search(r'(\d+)\s+passed', line)
                m_failed   = re.search(r'(\d+)\s+failed\b', line)
                m_exp_fail = re.search(r'(\d+)\s+expected\s+fail', line)
                m_skipped  = re.search(r'(\d+)\s+skipped', line)
                m_todo     = re.search(r'(\d+)\s+todo', line)
                if m_total:
                    self.num_tests_run += int(m_total.group(1))
                if m_passed:
                    self.num_tests_passed += int(m_passed.group(1))
                if m_failed:
                    self.num_tests_failed += int(m_failed.group(1))
                    self.did_tests_fail = True
                if m_skipped:
                    self.num_tests_skipped += int(m_skipped.group(1))
                if m_todo:
                    self.num_tests_skipped += int(m_todo.group(1))
                if m_exp_fail:
                    self.num_tests_skipped += int(m_exp_fail.group(1))
            elif (failure_started or suite_failure_started) and vitest_error:
                test_error += line.strip() + " "
            elif failure_started and line.strip() == "":
                # blank line signals end of error block
                self._save_vitest_failure(test_file, test_name, test_error.strip())
                failure_started = False
                test_file = ""
                test_name = ""
                test_error = ""
            elif suite_failure_started and line.strip() == "":
                if test_error:
                    self._save_vitest_failure(test_file, "[suite failure]", test_error.strip())
                    suite_failure_started = False
                    test_file = ""
                    test_name = ""
                    test_error = ""

        # flush any trailing failure
        if failure_started and test_file:
            self._save_vitest_failure(test_file, test_name, test_error.strip())
        if suite_failure_started and test_file:
            self._save_vitest_failure(test_file, "[suite failure]", test_error.strip())

        return {
            "framework": self.framework,
            "num_tests_run": self.num_tests_run,
            "num_tests_failed": self.num_tests_failed,
            "num_tests_passed": self.num_tests_passed,
            "num_tests_skipped": self.num_tests_skipped,
            "test_duration": self.test_duration,
            "num_test_suits_failed": self.num_test_suits_failed,
            "tests_failed": self.tests_failed
        }

    def _save_vitest_failure(self, file, name, error):
        for entry in self.tests_failed:
            if entry["file"] == file:
                entry["failures"].append({"name": name, "error": error})
                return
        self.tests_failed.append({"file": file, "failures": [{"name": name, "error": error}]})
        

class TypeScriptLogAnalyzer(BaseLogAnalyzer):
    def __init__(self, lines):
        super().__init__(lines)
        self.framework = "typescript"
    
    def is_applicable(self):
    # Check if any line contains "typescript@" followed by a version and "test"
        for line in self.lines:
            if re.search(r'typescript@\d+\.\d+\.\d+\s+test', line):
                return True
        return False

    def analyze(self):
        # Remove timestamps from all lines for easier matching.
        def tscript_remove_timestamp(text):
            return re.sub(r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d+Z\s*', '', text)
    
        cleaned_lines = [tscript_remove_timestamp(line) for line in self.lines]

        # Process summary info: passing, failing, skipped, and duration.
        for line in cleaned_lines:
            # e.g., "97680 passing (12m)"
            pass_match = re.search(r'^\s*(\d+)\s+passing\s+\((\d+)(ms|s|m)\)', line)
            # e.g., "23 failing"
            fail_match = re.search(r'^\s*(\d+)\s+failing', line)
            # e.g., "2 skipped"
            skip_match = re.search(r'^\s*(\d+)\s+skipped', line)
            
            if pass_match:
                count = int(pass_match.group(1))
                self.num_tests_passed = int(pass_match.group(1))
                self.num_tests_run += count
                time_value = int(pass_match.group(2))
                time_unit = pass_match.group(3)
                if time_unit == 'ms':
                    self.test_duration += time_value / 1000
                elif time_unit == 's':
                    self.test_duration += time_value
                elif time_unit == 'm':
                    self.test_duration += time_value * 60
            
            if fail_match:
                self.did_tests_fail = True
                self.num_tests_failed = int(fail_match.group(1))
                self.num_tests_run += self.num_tests_failed
            
            if skip_match:
                self.num_tests_skipped = int(skip_match.group(1))
                self.num_tests_run += self.num_tests_skipped

        # Extract details of failing tests if there are failures.
        failures = []
        if self.num_tests_failed > 0:
            failure_lines = []
            capturing_failures = False

            for line in cleaned_lines:
                # Detect the start of a failure block (e.g., "1)", "2)", etc.)
                if re.match(r'^\s*\d+\)\s*$', line):
                    capturing_failures = True
                    failure_lines.append(line)
                elif capturing_failures:
                    # If the line indicates we've reached the end (e.g. "Error in", "##[error]", or "##[group]"), then stop.
                    if re.match(r'^(Error in|##\[error\]|##\[group\])', line):
                        break
                    failure_lines.append(line)
            
            # Split the captured failure_lines into blocks based on numbered markers.
            current_block = []
            for line in failure_lines:
                if re.match(r'^\s*\d+\)\s*$', line):
                    if current_block:
                        failures.append(self._parse_failure_block(current_block))
                        current_block = []
                else:
                    current_block.append(line)
            if current_block:
                failures.append(self._parse_failure_block(current_block))
        
        self.tests_failed = failures

        return {
            "framework": self.framework,
            "num_tests_run": self.num_tests_run,
            "num_tests_failed": self.num_tests_failed,
            "num_tests_passed": self.num_tests_passed,
            "num_tests_skipped": self.num_tests_skipped,
            "test_duration": self.test_duration,
            "num_test_suits_failed": self.num_test_suits_failed,
            "tests_failed": self.tests_failed
        }

    def _parse_failure_block(self, block_lines):
    
        ## to filter out stack-trace lines with at lines 
        
        # Remove empty lines and lines that start with "at"
        non_empty = [
            line.strip() for line in block_lines 
            if line.strip() and not re.match(r'^at\s+', line.strip())
        ]
        file_field = non_empty[1] if len(non_empty) >= 2 else "Unknown file"
        test_field = non_empty[2] if len(non_empty) >= 3 else "Unknown test"
        error_field = " ".join(non_empty[3:]) if len(non_empty) >= 4 else ""
        return {"file": file_field, "test": test_field, "error": error_field}



def print_results(results, framework):
 
    print(f"\n{'=' * 40}")
    print(f"{framework.upper()} TEST RESULTS")
    print(f"{'=' * 40}")

    print(f"Total Tests Run: {results.get('num_tests_run', 0)}")
    print(f"Total Passed: {results.get('num_tests_passed', 0)}")
    print(f"Total Failed: {results.get('num_tests_failed', 0)}")
    # if results.get('num_tests_passed', 0) != 0:
    #     print(f"Total Passed: {results.get('num_tests_passed', 0)}")
    print(f"Total Skipped: {results.get('num_tests_skipped', 0)}")

    # Format test_duration as a float if possible, otherwise display as is.
    duration = results.get('test_duration', 0)
    try:
        duration = float(duration)
        print(f"Total Duration: {duration:.4f}s")
    except (ValueError, TypeError):
        print(f"Total Duration: {duration}s")

    if results.get('num_tests_failed', 0) > 0:
        print("\nFAILED TESTS:")
        for test in results.get('tests_failed', []):
            # Check if this failure record has a nested "failures" key (for typescript logs)
            if isinstance(test, dict) and 'failures' in test:
                print(f"  - File: {test.get('file', 'Unknown')}")
                for failure in test.get('failures', []):
                    print(f"    • Test: {failure.get('name', 'Unknown test')}")
                    print(f"      Error: {failure.get('error', '')}\n")
            else:
                # Otherwise, treat the test record as a direct failure record
                print(f"  - File: {test.get('file', 'Unknown')}")
                print(f"    • Test: {test.get('test', 'Unknown test')}")
                print(f"      Error: {test.get('error', '')}\n")

    print(f"{'=' * 40}\n")


class SummaryBlockLogAnalyzer(BaseLogAnalyzer):
    """Generic summary-block test reporter format:

        Summary:
          Total number of tests: 1480
          Passed tests:          1478
          Failed tests:             0
          Skipped tests:            2
    """
    def __init__(self, lines):
        super().__init__(lines)
        self.framework = "summary-block"

    def is_applicable(self):
        return any(re.search(r'Total\s+number\s+of\s+tests\s*:\s*\d+', line, re.IGNORECASE)
                   for line in self.lines)

    def analyze(self):
        for line in self.lines:
            m_total   = re.search(r'Total\s+number\s+of\s+tests\s*:\s*(\d+)',  line, re.IGNORECASE)
            m_passed  = re.search(r'Passed\s+tests\s*:\s*(\d+)',               line, re.IGNORECASE)
            m_failed  = re.search(r'Failed\s+tests\s*:\s*(\d+)',               line, re.IGNORECASE)
            m_skipped = re.search(r'Skipped\s+tests\s*:\s*(\d+)',              line, re.IGNORECASE)

            if m_total:
                self.num_tests_run = int(m_total.group(1))
            if m_passed:
                self.num_tests_passed = int(m_passed.group(1))
            if m_failed:
                self.num_tests_failed = int(m_failed.group(1))
                self.did_tests_fail = self.num_tests_failed > 0
            if m_skipped:
                self.num_tests_skipped = int(m_skipped.group(1))

        return {
            "framework": self.framework,
            "num_tests_run": self.num_tests_run,
            "num_tests_failed": self.num_tests_failed,
            "num_tests_passed": self.num_tests_passed,
            "num_tests_skipped": self.num_tests_skipped,
            "test_duration": self.test_duration,
            "num_test_suits_failed": self.num_test_suits_failed,
            "tests_failed": self.tests_failed,
        }


class NodeTestLogAnalyzer(BaseLogAnalyzer):
    """Node.js built-in test runner (node:test) output.

    Format (after ANSI stripping):
        ℹ tests 267
        ℹ pass 265
        ℹ fail 1
        ℹ skipped 1
        ℹ duration_ms 34852.980016
    """
    def __init__(self, lines):
        super().__init__(lines)
        self.framework = "node:test"

    def _clean(self, line):
        line = self.clean_line(line)
        line = re.sub(r'[^\x00-\x7F]+', '', line)  # strip non-ASCII (ℹ, etc.)
        return line.strip()

    def is_applicable(self):
        # duration_ms is unique to node:test; avoid false-positives from Vitest Duration lines
        return any(re.search(r'\bduration_ms\s+[\d.]+', self._clean(l)) for l in self.lines)

    def analyze(self):
        for line in self.lines:
            clean = self._clean(line)
            m_tests    = re.search(r'\btests\s+(\d+)',        clean)
            m_pass     = re.search(r'\bpass\s+(\d+)',         clean)
            m_fail     = re.search(r'\bfail\s+(\d+)',         clean)
            m_skipped  = re.search(r'\bskipped\s+(\d+)',      clean)
            m_duration = re.search(r'\bduration_ms\s+([\d.]+)', clean)

            if m_tests:
                self.num_tests_run = int(m_tests.group(1))
            if m_pass:
                self.num_tests_passed = int(m_pass.group(1))
            if m_fail:
                self.num_tests_failed = int(m_fail.group(1))
                self.did_tests_fail = self.num_tests_failed > 0
            if m_skipped:
                self.num_tests_skipped = int(m_skipped.group(1))
            if m_duration:
                self.test_duration = float(m_duration.group(1)) / 1000

        return {
            "framework": self.framework,
            "num_tests_run": self.num_tests_run,
            "num_tests_failed": self.num_tests_failed,
            "num_tests_passed": self.num_tests_passed,
            "num_tests_skipped": self.num_tests_skipped,
            "test_duration": self.test_duration,
            "num_test_suits_failed": self.num_test_suits_failed,
            "tests_failed": self.tests_failed,
        }


class PytestLogAnalyzer(BaseLogAnalyzer):
    """Handles pytest output that appears in TS/JS repos (e.g. dify, pytest project)."""

    def __init__(self, lines):
        super().__init__(lines)
        self.framework = "pytest"

    _SUMMARY = re.compile(
        r"""=+\s*
        (?:(?P<failed>\d+)\s+failed,?\s*)?
        (?:(?P<passed>\d+)\s+passed,?\s*)?
        (?:(?P<skipped>\d+)\s+skipped,?\s*)?
        (?:\d+\s+(?:xfailed|xpassed|warning[s]?|error[s]?|deselected),?\s*)*
        in\s+[\d.]+s""",
        re.IGNORECASE | re.VERBOSE,
    )
    _ANSI = re.compile(r'\x1B[@-_][0-?]*[ -/]*[@-~]')

    def is_applicable(self):
        return any(
            self._SUMMARY.search(self._ANSI.sub('', line))
            for line in self.lines
        )

    def analyze(self):
        for line in self.lines:
            clean = self._ANSI.sub('', line)
            m = self._SUMMARY.search(clean)
            if m:
                self.num_tests_failed  = int(m.group('failed')  or 0)
                self.num_tests_passed  = int(m.group('passed')  or 0)
                self.num_tests_skipped = int(m.group('skipped') or 0)
                self.num_tests_run     = self.num_tests_failed + self.num_tests_passed + self.num_tests_skipped
                self.did_tests_fail    = self.num_tests_failed > 0
        return {
            "framework":        self.framework,
            "num_tests_run":    self.num_tests_run,
            "num_tests_failed": self.num_tests_failed,
            "num_tests_passed": self.num_tests_passed,
            "num_tests_skipped":self.num_tests_skipped,
            "test_duration":    self.test_duration,
            "num_test_suits_failed": self.num_test_suits_failed,
            "tests_failed":     self.tests_failed,
        }


class JTRLogAnalyzer(BaseLogAnalyzer):
    """jQuery Test Runner (jtr) format.

    Lines look like:
        Tests finished in 905ms at http://...
        14 passed. 1 skipped.
    Or just:
        14 passed. 1 skipped.
        All tests passed!
    """
    _SUMMARY = re.compile(r'(\d+)\s+passed\.\s*(?:(\d+)\s+failed\.)?\s*(?:(\d+)\s+skipped\.)?', re.IGNORECASE)
    _ANSI    = re.compile(r'\x1B[@-_][0-?]*[ -/]*[@-~]', re.M)
    _TS      = re.compile(r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d+Z\s+')
    _FINISH  = re.compile(r'Tests finished in (\d+)ms', re.IGNORECASE)

    def __init__(self, lines):
        super().__init__(lines)
        self.framework = "jtr"

    def _clean(self, line):
        return self.clean_line(line)

    def is_applicable(self):
        return any(self._FINISH.search(self._clean(l)) for l in self.lines) or \
               any(re.search(r'\bjtr\b', l) for l in self.lines)

    def analyze(self):
        seen = set()
        for line in self.lines:
            clean = self._clean(line)
            m = self._SUMMARY.search(clean)
            if m:
                passed  = int(m.group(1))
                failed  = int(m.group(2) or 0)
                skipped = int(m.group(3) or 0)
                sig = (passed, failed, skipped)
                if sig in seen:
                    continue
                seen.add(sig)
                self.num_tests_passed  += passed
                self.num_tests_failed  += failed
                self.num_tests_skipped += skipped
                self.num_tests_run     += passed + failed + skipped
            f = self._FINISH.search(clean)
            if f:
                self.test_duration += int(f.group(1)) / 1000
        return {
            "framework":         self.framework,
            "num_tests_run":     self.num_tests_run,
            "num_tests_passed":  self.num_tests_passed,
            "num_tests_failed":  self.num_tests_failed,
            "num_tests_skipped": self.num_tests_skipped,
            "test_duration":     self.test_duration,
            "num_test_suits_failed": self.num_test_suits_failed,
            "tests_failed":      self.tests_failed,
        }


def detect_analyzer(log_lines):
    analyzers = [
        SummaryBlockLogAnalyzer,
        NodeTestLogAnalyzer,
        TAPLogAnalyzer,
        MochaLogAnalyzer,
        JestLogAnalyzer,
        BunTestLogAnalyzer,
        JasmineNpmLogAnalyzer,
        JasmineLogAnalyzer,
        VitestLogAnalyzer,
        QUnitLogAnalyzer,
        JTRLogAnalyzer,
        TypeScriptLogAnalyzer,
        PytestLogAnalyzer,
    ]
    
    applicable = []
    for AnalyzerClass in analyzers:
        analyzer = AnalyzerClass(log_lines)
        if analyzer.is_applicable():
            applicable.append(analyzer)
    
    if not applicable:
        return None
    
    # For now, we'll just return the first match. Since there can be only one unique ?
    return applicable[0]



def run_all_analyzers(file_path):
    log_lines = read_log_file(file_path)
    analyzers = [
        SummaryBlockLogAnalyzer,
        NodeTestLogAnalyzer,
        TAPLogAnalyzer,
        MochaLogAnalyzer,
        JestLogAnalyzer,
        BunTestLogAnalyzer,
        JasmineNpmLogAnalyzer,
        JasmineLogAnalyzer,
        VitestLogAnalyzer,
        QUnitLogAnalyzer,
        TypeScriptLogAnalyzer
    ]
    
    for AnalyzerClass in analyzers:
        analyzer = AnalyzerClass(log_lines)
        results = analyzer.analyze()
        print_results(results, analyzer.framework)
        

def read_log_file(file_path):
    with open(file_path, 'r', encoding='utf-8') as file:
        return file.readlines()

def analyze_log(file_path):
    log_lines = read_log_file(file_path)
    
    analyzer = detect_analyzer(log_lines)
    
    if analyzer:
        results = analyzer.analyze()
        print_results(results, analyzer.framework)
    else:
        print("No applicable analyzer found for this log.")

    # tap_analyzer = TAPLogAnalyzer(log_lines)
    # mocha_analyzer = MochaLogAnalyzer(log_lines)
    # jest_analyzer = JestLogAnalyzer(log_lines)
    # jasmine_analyzer = JasmineLogAnalyzer(log_lines)
    # vitest_analyzer = VitestLogAnalyzer(log_lines)
    # qunit_analyzer = QUnitLogAnalyzer(log_lines)
    # typescript_analyzer = TypeScriptLogAnalyzer(log_lines)

    # tap_results = tap_analyzer.analyze()
    # mocha_results = mocha_analyzer.analyze()
    # jest_results = jest_analyzer.analyze()
    # jasmine_results = jasmine_analyzer.analyze()
    # vitest_results = vitest_analyzer.analyze()
    # qunit_results = qunit_analyzer.analyze()
    # typescript_results = typescript_analyzer.analyze()

    # print_results(tap_results, "TAP")
    # print_results(mocha_results, "Mocha")
    # print_results(jest_results, "Jest")
    # print_results(jasmine_results, "Jasmine")
    # print_results(vitest_results, "Vitest")
    # print_results(qunit_results, "QUnit")
    # print_results(typescript_results, "TypeScript")

# if __name__ == "__main__":
#     parser = argparse.ArgumentParser(description="Analyze test log files.")
#     parser.add_argument("file_path", help="Path to the log file to analyze")
#     parser.add_argument("--all", action="store_true", help="Run all analyzers instead of detecting one")

#     args = parser.parse_args()

#     if args.all:
#         run_all_analyzers(args.file_path)
#     else:
#         analyze_log(args.file_path)

# log_lines = read_log_file("log.txt")
    
# analyzer = detect_analyzer(log_lines)
    
# if analyzer:
#     results = analyzer.analyze()
#     print(results)
# else:
#     print("No applicable analyzer found for this log.")