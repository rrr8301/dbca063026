import re

class BaseLogAnalyzer:
    _ANSI_RE     = re.compile(r'\x1B[@-_][0-?]*[ -/]*[@-~]', re.M)
    _TS_RE       = re.compile(r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d+Z\s+')
    _ACT_RE      = re.compile(r'^\[[\w/ ._-]+\]\s{2,}(?:\|\s?)?')
    _FLINK_TS_RE = re.compile(r'^[A-Z][a-z]{2}\s+\d{1,2}\s+\d{2}:\d{2}:\d{2}\s+\d{2}:\d{2}:\d{2}\.\d+\s+')

    def __init__(self, lines):
        self.lines = lines
        self.did_tests_fail = False
        self.num_tests_failed = 0
        self.num_tests_run = 0
        self.num_tests_passed = 0
        self.num_tests_skipped = 0
        self.test_duration = 0.0
        self.tests_failed = []
        self.tests_skipped = []
        self.framework = None



    def clean_line(self, line):
        """Strip ANSI codes, GitHub/Flink timestamps, and act runner prefixes."""
        line = self._ANSI_RE.sub('', line)
        line = self._TS_RE.sub('', line)
        line = self._FLINK_TS_RE.sub('', line)
        line = self._ACT_RE.sub('', line)
        return line.strip()

    def analyze(self):
        raise NotImplementedError("Subclasses should implement this method")
    
    def is_applicable(self):
        """Our Analyzers can override this and use to check logs searching for something unique to them 
        and determine if the logfile applies to them"""
        return False

        
class RustLogAnalyzer(BaseLogAnalyzer):
    _ANSI_ONLY_RE = re.compile(r'\x1B[@-_][0-?]*[ -/]*[@-~]', re.M)

    # libtest summary line. The "measured" segment is optional (some harnesses
    # omit it) and nextest's libtest-compat aggregate adds "across N groups,"
    # before "finished in".
    _RESULT_RE = re.compile(
        r'test result:\s+(?P<status>ok|FAILED)\.\s+'
        r'(?P<passed>\d+) passed;\s+(?P<failed>\d+) failed;\s+(?P<ignored>\d+) ignored;'
        r'(?:\s+(?P<measured>\d+) measured;)?'
        r'\s+(?P<filtered>\d+) filtered out;'
        r'(?:\s+across \d+ groups?,)?'
        r'\s+finished in (?P<dur>\d+\.?\d*)\s?s'
    )

    # clippy / compiletest (ui_test) summary: status "FAIL", "failed" listed
    # BEFORE "passed", and no "filtered out"/"finished in" tail, e.g.
    #   test result: FAIL. 1 failed; 1795 passed; 5 ignored
    # The leading "\d+ failed;" requirement makes this mutually exclusive with
    # the standard libtest line above (which always lists "passed" first).
    _RESULT_CLIPPY_RE = re.compile(
        r'test result:\s+(?:ok|FAIL|FAILED)\.\s+'
        r'(?P<failed>\d+)\s+failed;\s+'
        r'(?P<passed>\d+)\s+passed'
        r'(?:;\s+(?P<ignored>\d+)\s+ignored)?'
    )

    def __init__(self, lines):
        super().__init__(lines)
        self.framework = "cargo"

    def _is_nextest_indented(self, raw):
        """Return True if this line is indented inside a nextest stdout/stderr block."""
        stripped_ansi = self._ANSI_ONLY_RE.sub('', raw)
        return stripped_ansi.startswith('    ') or stripped_ansi.startswith('\t')

    def is_applicable(self):
        for raw in self.lines:
            if self._is_nextest_indented(raw):
                continue
            line = self.clean_line(raw)
            if self._RESULT_RE.search(line) or self._RESULT_CLIPPY_RE.search(line):
                return True
        return False

    def get_int_from_match(self, match):
        return int(re.sub(r'\D', '', match)) if match else 0

    def analyze(self):
        _RESULT_RE = self._RESULT_RE
        _FAILED_RE  = re.compile(r'^test\s+(?P<name>.+)\s+\.\.\.\s+FAILED\s*$', re.IGNORECASE)
        _IGNORED_RE = re.compile(r'^test\s+(?P<name>.+)\s+\.\.\.\s+ignored\s*$', re.IGNORECASE)

        run_results = []  # (passed, failed, ignored, filtered_out) per test result line

        for raw in self.lines:
            # Skip lines that are indented inside nextest stdout/stderr blocks
            if self._is_nextest_indented(raw):
                continue
            line = self.clean_line(raw)

            m = _FAILED_RE.match(line)
            if m:
                self.tests_failed.append(m.group("name").strip())

            m = _IGNORED_RE.match(line)
            if m:
                self.tests_skipped.append(m.group("name").strip())

            rust_tests = _RESULT_RE.search(line)
            if rust_tests:
                p, f, i, filt = (int(rust_tests.group("passed")), int(rust_tests.group("failed")),
                                 int(rust_tests.group("ignored")), int(rust_tests.group("filtered")))
                self.num_tests_passed += p
                self.num_tests_failed += f
                self.num_tests_skipped += i + filt
                self.num_tests_run = self.num_tests_passed + self.num_tests_failed + self.num_tests_skipped
                self.test_duration += float(rust_tests.group("dur"))
                run_results.append((p, f, i, filt))
            else:
                # clippy/compiletest format (no filtered/duration; failed first)
                clippy = self._RESULT_CLIPPY_RE.search(line)
                if clippy:
                    p = int(clippy.group("passed"))
                    f = int(clippy.group("failed"))
                    i = int(clippy.group("ignored") or 0)
                    self.num_tests_passed += p
                    self.num_tests_failed += f
                    self.num_tests_skipped += i
                    self.num_tests_run = self.num_tests_passed + self.num_tests_failed + self.num_tests_skipped
                    run_results.append((p, f, i, 0))

        # clippy/compiletest list failing UI tests under an uppercase
        # "FAILURES:" header (distinct from libtest's lowercase "failures:"),
        # since they emit no streaming "test ... FAILED" lines. Capture those
        # file-path names. Scoped to the uppercase header so standard cargo
        # logs (which already capture names from streaming lines) are untouched.
        if not self.tests_failed:
            in_fail_block = False
            for raw in self.lines:
                s = self.clean_line(raw).strip()
                if s == "FAILURES:":
                    in_fail_block = True
                    continue
                if in_fail_block:
                    if not s or s.lower().startswith("test result:"):
                        in_fail_block = False
                        continue
                    self.tests_failed.append(s)

        # Detect K-fold repeated runs (e.g. mdbook testing multiple language builds).
        # The per-chapter (passed, failed, ignored, filtered) sequence repeats identically.
        dedup_applied = False
        n = len(run_results)
        if n >= 2:
            for k in range(2, n + 1):
                if n % k == 0:
                    chunk = n // k
                    first = run_results[:chunk]
                    if all(run_results[i * chunk:(i + 1) * chunk] == first for i in range(1, k)):
                        self.num_tests_run      //= k
                        self.num_tests_failed   //= k
                        self.num_tests_passed   //= k
                        self.num_tests_skipped  //= k
                        self.test_duration      /= k
                        per = len(self.tests_failed) // k
                        self.tests_failed  = self.tests_failed[:per]
                        per = len(self.tests_skipped) // k
                        self.tests_skipped = self.tests_skipped[:per]
                        dedup_applied = True
                        break

        # Fallback: deduplicate by exact name (handles same-name repeated runs
        # not caught by the sequence check above).
        if not dedup_applied:
            unique_failed  = list(dict.fromkeys(self.tests_failed))
            unique_skipped = list(dict.fromkeys(self.tests_skipped))
            raw_failed = len(self.tests_failed)
            dedup_failed = len(unique_failed)
            if dedup_failed > 0 and raw_failed > dedup_failed:
                factor = raw_failed / dedup_failed
                if factor == int(factor):
                    factor = int(factor)
                    self.num_tests_run      //= factor
                    self.num_tests_failed   //= factor
                    self.num_tests_passed   //= factor
                    self.num_tests_skipped  //= factor
                    self.test_duration      /= factor
            self.tests_failed  = unique_failed
            self.tests_skipped = unique_skipped

        return {
            "framework": self.framework,
            "num_tests_run": self.num_tests_run,
            "num_tests_failed": self.num_tests_failed,
            "num_tests_passed": self.num_tests_passed,
            "num_tests_skipped": self.num_tests_skipped,
            "tests_failed": self.tests_failed,
            "tests_skipped": self.tests_skipped,
            "test_duration": self.test_duration
        }


class NextTestLogAnalyzer(BaseLogAnalyzer):
    def __init__(self, lines):
        super().__init__(lines)
        self.framework = "nexttest"
        
    def is_applicable(self):
        NEXTTEST_SUMMARY_RE = re.compile(
            r"""^\s*Summary\s*\[\s*(?P<secs>\d+(?:\.\d+)?)s\]\s*
                (?P<run>\d+)(?:\s*/\s*\d+)?\s+tests\s+run:\s*
                (?P<passed>\d+)\s+passed
                (?:\s*\([^)]*\))?
                (?:,\s*(?P<failed>\d+)\s+failed(?:\s*\([^)]*\))?)?
                (?:,\s*(?P<skipped>\d+)\s+skipped)?
                \s*$""",
            re.VERBOSE,
        )
        for raw in self.lines:
            # jest_tests = re.search(r'Tests:\s+(\d+ failed, )?(\d+ skipped, )?(\d+ passed, )?(\d+ total)', line)
            # jest_time = re.search(r'Time:\s+(\d+\.?\d*)\s?s', line)
            line = self.clean_line(raw)
            rust_tests = NEXTTEST_SUMMARY_RE.match(line)
            if rust_tests:
                return True
        return False
    
    def analyze(self):
        NEXTTEST_SUMMARY_RE = re.compile(
            r"""^\s*Summary\s*\[\s*(?P<secs>\d+(?:\.\d+)?)s\]\s*
                (?P<run>\d+)(?:\s*/\s*\d+)?\s+tests\s+run:\s*
                (?P<passed>\d+)\s+passed
                (?:\s*\([^)]*\))?
                (?:,\s*(?P<failed>\d+)\s+failed(?:\s*\([^)]*\))?)?
                (?:,\s*(?P<skipped>\d+)\s+skipped)?
                \s*$""",
            re.VERBOSE,
        )

        NEXTEST_FAIL_RE = re.compile(
            r'FAIL\s*\[\s*(?P<secs>\d+(?:\.\d+)?)s\s*\]\s*'
            r'\(\s*(?P<idx>\d+)\s*/\s*(?P<total>\d+)\s*\)\s*'
            r'(?P<name>.+)$'
        )
        for raw in self.lines:
            # jest_tests = re.search(r'Tests:\s+(\d+ failed, )?(\d+ skipped, )?(\d+ passed, )?(\d+ total)', line)
            # jest_time = re.search(r'Time:\s+(\d+\.?\d*)\s?s', line)
            line = self.clean_line(raw)
            rust_tests = NEXTTEST_SUMMARY_RE.match(line)
            if rust_tests:
                failed = int(rust_tests.group("failed")) if rust_tests.group("failed") is not None else 0
                skipped = int(rust_tests.group("skipped")) if rust_tests.group("skipped") is not None else 0
                passed = int(rust_tests.group("passed"))
                self.num_tests_failed += failed
                self.num_tests_skipped += skipped
                self.num_tests_passed += passed
                self.num_tests_run += failed + passed + skipped
                self.test_duration = float(rust_tests.group("secs"))
                
            rust_test_fail = NEXTEST_FAIL_RE.search(line)
            if rust_test_fail:
                name = rust_test_fail.group("name")
                # nextest prints each FAIL both in streaming output and in the
                # post-Summary recap, so dedupe while preserving first-seen order
                if name not in self.tests_failed:
                    self.tests_failed.append(name)
                
        return {
            "framework": self.framework,
            "num_tests_run": self.num_tests_run,
            "num_tests_failed": self.num_tests_failed,
            "num_tests_passed": self.num_tests_passed,
            "num_tests_skipped": self.num_tests_skipped,
            "tests_failed": self.tests_failed,
            "tests_skipped": self.tests_skipped,
            "test_duration": self.test_duration
        }
                
# def detect_analyzer(log_lines):
#     analyzers = [
#         RustLogAnalyzer,
#         NextTestLogAnalyzer
#     ]
    
#     applicable = []
#     for AnalyzerClass in analyzers:
#         analyzer = AnalyzerClass(log_lines)
#         if analyzer.is_applicable():
#             applicable.append(analyzer)
    
#     if not applicable:
#         return None
    
#     # For now, we'll just return the first match. Since there can be only one unique ?
#     return applicable
        
# def read_log_file(file_path):
#     with open(file_path, 'r', encoding='utf-8') as file:
#         return file.readlines()

# log_lines = read_log_file("log_.txt")
    
# analyzer = detect_analyzer(log_lines)
# results_list = [] 
# if analyzer:
#     for a in analyzer:
#         results = a.analyze()
#         results_list.append(results)
#     print(results_list)
# else:
#     print("No applicable analyzer found for this log.")
    
