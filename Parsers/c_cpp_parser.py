import re


class BaseLogAnalyzer:
    _ANSI_RE = re.compile(r'\x1B[@-_][0-?]*[ -/]*[@-~]', re.M)
    # GitHub Actions timestamp: 2026-04-05T08:32:09.123456Z
    _TS_RE   = re.compile(r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d+Z\s+')
    # act runner prefix: [job-name]   |  (with optional leading spaces/icons)
    _ACT_RE  = re.compile(r'^\[[\w/ ._-]+\]\s{2,}(?:\|\s?)?')
    # CTest per-test output prefix: "N: " where N is the test index
    _CTEST_PREFIX_RE = re.compile(r'^\d+: ')

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
        self.tests_passed = []
        self.tests_run = []
        self.framework = None

    def clean_line(self, line):
        """Strip ANSI codes, GitHub timestamps, and act runner prefixes."""
        line = self._ANSI_RE.sub('', line)
        line = self._TS_RE.sub('', line)
        line = self._ACT_RE.sub('', line)
        return line.strip()

    def _is_ctest_embedded(self, raw):
        """Return True if this line is embedded inside a CTest per-test output block (prefixed with 'N: ')."""
        stripped_ansi = self._ANSI_RE.sub('', raw)
        return bool(self._CTEST_PREFIX_RE.match(stripped_ansi))

    def analyze(self):
        raise NotImplementedError("Subclasses should implement this method")

    def is_applicable(self):
        """Our Analyzers can override this and use to check logs searching for something unique to them
        and determine if the logfile applies to them"""
        return False

        
class CTEST_LogAnalyzer(BaseLogAnalyzer):
    def __init__(self, lines):
        super().__init__(lines)
        self.framework = "CTest"
    
    def is_applicable(self):
        run_test_pattern = re.compile(
            r"^\s*(?P<pct>\d+(?:\.\d+)?)%\s*tests?\s*passed,\s*"
            r"(?P<failed>\d+)\s*tests?\s*failed\s*out\s*of\s*(?P<total>\d+)\s*$",
            re.IGNORECASE
        )
        for raw in self.lines:
            line = self.clean_line(raw)
            if run_test_pattern.match(line):
                return True
        return False
    
    def get_int_from_match(self, match):
        return int(re.sub(r'\D', '', match)) if match else 0
    
    def analyze(self):
        SKIPPED_HDR = re.compile(r"^\s*The following tests did not run:\s*$")
        item_skipped = re.compile(r"^\s*(\d+)\s*-\s*(.*?)\s*\(([^)]+)\)")
        FAILED_HDR = re.compile(r"^\s*The following tests FAILED:\s*$")
        item_failed = re.compile(r"^\s*(\d+)\s*-\s*(.*?)\s*\(([^)]+)\)")
        c_test_pattern = re.compile(
            r"^\s*(?P<pct>\d+(?:\.\d+)?)%\s*tests?\s*passed,\s*"
            r"(?P<failed>\d+)\s*tests?\s*failed\s*out\s*of\s*(?P<total>\d+)\s*$",
            re.IGNORECASE
        )
        c_test_duration_pattern = re.compile(
            r"^Total\s+Test\s+time\s*\(real\)\s*=\s*(?P<time>[\d.]+)\s*sec",
            re.IGNORECASE
        )
        skipped_section = False
        Failed_section = False
        for raw in self.lines:
            # jest_tests = re.search(r'Tests:\s+(\d+ failed, )?(\d+ skipped, )?(\d+ passed, )?(\d+ total)', line)
            # jest_time = re.search(r'Time:\s+(\d+\.?\d*)\s?s', line)
            # Total Test time (real) =  64.25 sec
            # 99% tests passed, 1 tests failed out of 3601
            line = self.clean_line(raw)
            c_tests = c_test_pattern.search(line)
            c_duration = c_test_duration_pattern.search(line)
            # SKIPPED_HDR = re.compile(r"^\s*The following tests did not run:\s*$")
            # item_skipped = re.compile(r"^\s*(\d+)\s*-\s*(.*?)\s*\(([^)]+)\)\s*$")
            # FAILED_HDR = re.compile(r"^\s*The following tests FAILED:\s*$")
            # item_failed = re.compile(r"^\s*(\d+)\s*-\s*(.*?)\s*\(([^)]+)\)\s*$")
            
            if c_tests:
                c_total = int(c_tests.group("total"))
                self.num_tests_run += c_total
                
                c_failed = int(c_tests.group("failed"))
                self.num_tests_failed += c_failed
            
            if c_duration:
                self.test_duration += float(c_duration.group("time"))
            
            
            if SKIPPED_HDR.match(line):
                skipped_section = True
                continue
            
            if FAILED_HDR.match(line):
                Failed_section = True
                skipped_section = False
                continue
            
            if skipped_section == True:
                item_skipped_ = item_skipped.search(line)
                if item_skipped_:
                    self.tests_skipped.append(item_skipped_.group(2))
            elif Failed_section == True:
                item_failed_ = item_failed.search(line)
                if item_failed_:
                    self.tests_failed.append(item_failed_.group(2))
                    
            self.num_tests_skipped = len(self.tests_skipped)
            self.num_tests_passed = self.num_tests_run - self.num_tests_skipped - self.num_tests_failed
                    
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
                    
        


class GTest_LogAnalyzer(BaseLogAnalyzer):
    def __init__(self, lines):
        super().__init__(lines)
        self.framework = "GTest"
    
    def is_applicable(self):
        global_pattern = re.compile(
            r"\[\=+\]\s*"
            r"(?P<tests>\d+)\s+tests?\s+from\s+(?P<cases>\d+)\s+test\s+(?:cases?|suites?)\s+ran\.\s*"
            r"\((?P<time>[\d.]+)\s*ms\s*total\)",
            re.IGNORECASE
        )
        suite_pattern = re.compile(
            r"\[\-+\]\s*(?P<tests>\d+)\s+tests?\s+from\s+(?P<suite>\S+)\s+\((?P<time>[\d.]+)\s*ms\s*total\)",
            re.IGNORECASE
        )
        for raw in self.lines:
            if self._is_ctest_embedded(raw):
                continue
            line = self.clean_line(raw)
            if global_pattern.search(line) or suite_pattern.search(line):
                return True
        return False
            
    
    def get_int_from_match(self, match):
        return int(re.sub(r'\D', '', match)) if match else 0

    def analyze(self):
        passed_pattern = re.compile(r"\s*\[\s*PASSED\s*\]\s*(?P<passed>\d+)\s+tests?", re.IGNORECASE)
        failed_count_pattern = re.compile(r"\s*\[\s*FAILED\s*\]\s*(?P<failed>\d+)\s+tests?", re.IGNORECASE)
        skipped_pattern = re.compile(r"\s*\[\s*SKIPSTAT\s*\]\s*(?P<skipped>\d+)\s+tests?\s+skipped", re.IGNORECASE)
        skipped_summary_pattern = re.compile(r"\s*\[\s*SKIPPED\s*\]\s*(?P<skipped>\d+)\s+tests?,?\s+listed\s+below", re.IGNORECASE)
        failed_test_pattern = re.compile(
            r"\s*\[\s*FAILED\s*\]\s+(?P<name>[\w:./-]+)", re.IGNORECASE
        )
        global_run_pattern = re.compile(
            r"\[\=+\]\s*"
            r"(?P<tests>\d+)\s+tests?\s+from\s+(?P<cases>\d+)\s+test\s+(?:cases?|suites?)\s+ran\.\s*"
            r"\((?P<time>[\d.]+)\s*ms\s*total\)",
            re.IGNORECASE
        )
        suite_run_pattern = re.compile(
            r"\[\-+\]\s*(?P<tests>\d+)\s+tests?\s+from\s+(?P<suite>\S+)\s+\((?P<time>[\d.]+)\s*ms\s*total\)",
            re.IGNORECASE
        )
        has_global = any(
            global_run_pattern.search(self.clean_line(r)) for r in self.lines
            if not self._is_ctest_embedded(r)
        )
        for raw in self.lines:
            if self._is_ctest_embedded(raw):
                continue
            line = self.clean_line(raw)
            c_passed = passed_pattern.search(line)
            c_failed = failed_count_pattern.search(line)
            c_skipped = skipped_pattern.search(line) or skipped_summary_pattern.search(line)
            c_failed_test = failed_test_pattern.search(line)
            c_tests_run = global_run_pattern.search(line)
            c_suite_run = suite_run_pattern.search(line) if not has_global else None

            if c_passed:
                c_passed_num = int(c_passed.group("passed"))
                self.num_tests_passed += c_passed_num

            if c_failed:
                c_failed_num = int(c_failed.group("failed"))
                self.num_tests_failed += c_failed_num

            if c_skipped:
                c_skipped_num = int(c_skipped.group("skipped"))
                self.num_tests_skipped += c_skipped_num

            if c_failed_test:
                self.tests_failed.append(c_failed_test.group("name"))

            if c_tests_run:
                self.num_tests_run += int(c_tests_run.group("tests"))
                self.test_duration += float(c_tests_run.group("time"))

            if c_suite_run:
                self.num_tests_run += int(c_suite_run.group("tests"))
                self.test_duration += float(c_suite_run.group("time"))
                
        return {
            "framework": self.framework,
            "num_tests_run": self.num_tests_run,
            "num_tests_failed": self.num_tests_failed,
            "num_tests_passed": self.num_tests_passed,
            "num_tests_skipped": self.num_tests_skipped,
            "tests_failed": self.tests_failed,
            "tests_skipped": self.tests_skipped,
            "test_duration": self.test_duration/1000
        }
                
            
class NinjaLogAnalyzer(BaseLogAnalyzer):
    def __init__(self, lines):
        super().__init__(lines)
        self.framework = "Ninja"

    def is_applicable(self):
        # Ninja build progress lines: [N/M] ...
        # Ninja build-stop line: "ninja: build stopped: subcommand failed."
        progress_pattern = re.compile(r'^\[\d+/\d+\]')
        stopped_pattern  = re.compile(r'ninja:\s+build\s+stopped', re.IGNORECASE)
        for raw in self.lines:
            line = self.clean_line(raw)
            if progress_pattern.match(line) or stopped_pattern.search(line):
                return True
        return False

    def get_int_from_match(self, match):
        return int(re.sub(r'\D', '', match)) if match else 0

    def analyze(self):
        # Ninja reports failed build targets as "FAILED: path/to/target"
        # and overall progress as "[N/M] ..."
        progress_pattern = re.compile(r'^\[(\d+)/(\d+)\]')
        failed_pattern   = re.compile(r'^FAILED:\s+(.+)$')

        max_total = 0
        for raw in self.lines:
            line = self.clean_line(raw).strip()

            m = progress_pattern.match(line)
            if m:
                total = int(m.group(2))
                if total > max_total:
                    max_total = total

            f = failed_pattern.match(line)
            if f:
                self.tests_failed.append(f.group(1).strip())

        self.num_tests_failed  = len(self.tests_failed)
        self.num_tests_run     = max_total if max_total else self.num_tests_failed
        self.num_tests_passed  = max(0, self.num_tests_run - self.num_tests_failed)

        return {
            "framework":        self.framework,
            "num_tests_run":    self.num_tests_run,
            "num_tests_failed": self.num_tests_failed,
            "num_tests_passed": self.num_tests_passed,
            "num_tests_skipped":self.num_tests_skipped,
            "tests_failed":     self.tests_failed,
            "tests_skipped":    self.tests_skipped,
            "test_duration":    self.test_duration,
        }
                
class GitTest_Loganalyzer(BaseLogAnalyzer):
    def __init__(self, lines):
        super().__init__(lines)
        self.framework = "GitTest"
    
    _MESON_OK_RE   = re.compile(r'^\s*Ok\s*:\s*\d+',   re.IGNORECASE)
    _MESON_FAIL_RE = re.compile(r'^\s*Fail(?:ed)?\s*:\s*\d+', re.IGNORECASE)

    def is_applicable(self):
        run_test_pattern = re.compile(
            r'^\s*(?P<idx>\d+)\/(?P<total>\d+)\s+'
            r'(?P<module>\S+)\s*\/\s*(?P<name>\S+)\s+'
            r'(?P<status>OK|FAIL|ERROR|SKIP)\s+'
            r'(?P<secs>\d+(?:\.\d+)?)s\s*$'
        )
        has_match = False
        has_meson_ok = has_meson_fail = False
        for raw in self.lines:
            line = self.clean_line(raw)
            if run_test_pattern.match(line):
                has_match = True
            if self._MESON_OK_RE.match(line):
                has_meson_ok = True
            if self._MESON_FAIL_RE.match(line):
                has_meson_fail = True
        # Defer to MesonLoganalyzer when Meson summary block is present
        if has_meson_ok and has_meson_fail:
            return False
        return has_match

    def get_int_from_match(self, match):
        return int(re.sub(r'\D', '', match)) if match else 0

    def analyze(self):
        run_test_pattern = re.compile(
            r'^\s*(?P<idx>\d+)\/(?P<total>\d+)\s+'
            r'(?P<module>\S+)\s*\/\s*(?P<name>\S+)\s+'
            r'(?P<status>OK|FAIL|ERROR|SKIP)\s+'
            r'(?P<secs>\d+(?:\.\d+)?)s\s*$'
        )
        for raw in self.lines:
            line = self.clean_line(raw)
            m = run_test_pattern.match(line)
            if m:
                status = m.group('status')
                name   = m.group('module') + '/' + m.group('name')
                self.test_duration += float(m.group('secs'))
                if status == 'OK':
                    self.num_tests_passed += 1
                elif status in ('FAIL', 'ERROR'):
                    self.num_tests_failed += 1
                    self.tests_failed.append(name)
                elif status == 'SKIP':
                    self.num_tests_skipped += 1
        self.num_tests_run = self.num_tests_passed + self.num_tests_failed + self.num_tests_skipped
        return {
            "framework":         self.framework,
            "num_tests_run":     self.num_tests_run,
            "num_tests_passed":  self.num_tests_passed,
            "num_tests_failed":  self.num_tests_failed,
            "num_tests_skipped": self.num_tests_skipped,
            "tests_failed":      self.tests_failed,
            "tests_skipped":     self.tests_skipped,
            "test_duration":     self.test_duration,
        }


class MesonLoganalyzer(BaseLogAnalyzer):
    # Summary block patterns
    _OK_RE       = re.compile(r'^\s*Ok\s*:\s*(\d+)',                re.IGNORECASE)
    _FAIL_RE     = re.compile(r'^\s*Fail(?:ed)?\s*:\s*(\d+)',       re.IGNORECASE)
    _SKIP_RE     = re.compile(r'^\s*Skipped?\s*:\s*(\d+)',          re.IGNORECASE)
    _XFAIL_RE    = re.compile(r'^\s*Expected\s+Fail\s*:\s*(\d+)',   re.IGNORECASE)
    _XPASS_RE    = re.compile(r'^\s*Unexpected\s+Pass\s*:\s*(\d+)', re.IGNORECASE)
    _TIMEOUT_RE  = re.compile(r'^\s*Timeout\s*:\s*(\d+)',           re.IGNORECASE)
    # Per-test line: " IDX/TOTAL  module [/ or -] name  STATUS  N.NNs [extra]"
    _LINE_RE = re.compile(
        r'^\s*\d+/\d+\s+\S.*?\s+'
        r'(OK|FAIL|ERROR|SKIP|EXPECTEDFAIL|UNEXPECTEDPASS|TIMEOUT)\s+'
        r'(\d+(?:\.\d+)?)s',
        re.IGNORECASE
    )

    def __init__(self, lines):
        super().__init__(lines)
        self.framework = "Meson"
        self.num_tests_xfailed = 0
        self.num_tests_xpassed = 0
        self.num_tests_timeout = 0

    def is_applicable(self):
        has_ok = has_fail = False
        for raw in self.lines:
            if self._is_ctest_embedded(raw):
                continue
            line = self.clean_line(raw)
            if self._OK_RE.match(line):
                has_ok = True
            if self._FAIL_RE.match(line):
                has_fail = True
            if has_ok and has_fail:
                return True
        return False

    def analyze(self):
        for raw in self.lines:
            if self._is_ctest_embedded(raw):
                continue
            line = self.clean_line(raw)

            # Summary block
            m = self._OK_RE.match(line)
            if m:
                self.num_tests_passed = int(m.group(1))
                continue
            m = self._FAIL_RE.match(line)
            if m:
                self.num_tests_failed = int(m.group(1))
                continue
            m = self._SKIP_RE.match(line)
            if m:
                self.num_tests_skipped = int(m.group(1))
                continue
            m = self._XFAIL_RE.match(line)
            if m:
                self.num_tests_xfailed = int(m.group(1))
                continue
            m = self._XPASS_RE.match(line)
            if m:
                self.num_tests_xpassed = int(m.group(1))
                continue
            m = self._TIMEOUT_RE.match(line)
            if m:
                self.num_tests_timeout = int(m.group(1))
                continue

            # Per-test lines — collect failed names and duration
            m = self._LINE_RE.match(line)
            if m:
                status = m.group(1).upper()
                self.test_duration += float(m.group(2))
                if status in ("FAIL", "ERROR", "UNEXPECTEDPASS"):
                    # extract test name: everything between index and status
                    # handles both "module / name" and "module - name" separators
                    name_match = re.match(r'^\s*\d+/\d+\s+(.*?)\s+(?:OK|FAIL|ERROR|SKIP|EXPECTEDFAIL|UNEXPECTEDPASS|TIMEOUT)\s', line, re.IGNORECASE)
                    if name_match:
                        self.tests_failed.append(name_match.group(1).strip())

        # Grand total = all categories
        self.num_tests_run = (
            self.num_tests_passed + self.num_tests_failed +
            self.num_tests_skipped + self.num_tests_xfailed +
            self.num_tests_xpassed + self.num_tests_timeout
        )

        return {
            "framework":           self.framework,
            "num_tests_run":       self.num_tests_run,
            "num_tests_passed":    self.num_tests_passed,
            "num_tests_failed":    self.num_tests_failed,
            "num_tests_skipped":   self.num_tests_skipped,
            "num_tests_xfailed":   self.num_tests_xfailed,
            "num_tests_xpassed":   self.num_tests_xpassed,
            "num_tests_timeout":   self.num_tests_timeout,
            "tests_failed":        self.tests_failed,
            "tests_skipped":       self.tests_skipped,
            "test_duration":       self.test_duration,
        }
        
class CLibTAPLogAnalyzer(BaseLogAnalyzer):
    """General TAP (Test Anything Protocol) parser for C library test runners (e.g. libuv).

    Format:
        1..N                        (plan — total expected tests)
        ok 1 - get_loadavg          (pass)
        ok 2 - get_memory           (pass)
        not ok 3 - timer_run        (fail)
        ok 4 - tcp_connect # SKIP   (skip via directive)
    """
    _PLAN     = re.compile(r'^1\.\.(\d+)')
    _OK       = re.compile(r'^ok\s+\d+\s*(?:-\s*(.+?))?(?:\s+#.*)?$',     re.IGNORECASE)
    _NOT_OK   = re.compile(r'^not ok\s+\d+\s*(?:-\s*(.+?))?(?:\s+#.*)?$', re.IGNORECASE)
    _SKIP_DIR = re.compile(r'#\s*SKIP',  re.IGNORECASE)
    _TODO_DIR = re.compile(r'#\s*TODO',  re.IGNORECASE)

    def __init__(self, lines):
        super().__init__(lines)
        self.framework = "TAP"

    def is_applicable(self):
        has_plan = has_ok = False
        for raw in self.lines:
            if self._is_ctest_embedded(raw):
                continue
            line = self.clean_line(raw)
            if self._PLAN.match(line):
                has_plan = True
            if self._OK.match(line) or self._NOT_OK.match(line):
                has_ok = True
            if has_plan and has_ok:
                return True
        return False

    def analyze(self):
        for raw in self.lines:
            if self._is_ctest_embedded(raw):
                continue
            line = self.clean_line(raw).strip()

            m = self._PLAN.match(line)
            if m:
                self.num_tests_run = int(m.group(1))
                continue

            # not ok must be checked before ok (prefix match)
            m = self._NOT_OK.match(line)
            if m:
                name = (m.group(1) or '').strip()
                if self._SKIP_DIR.search(line) or self._TODO_DIR.search(line):
                    self.num_tests_skipped += 1
                    if name:
                        self.tests_skipped.append(name)
                else:
                    self.num_tests_failed += 1
                    if name:
                        self.tests_failed.append(name)
                continue

            m = self._OK.match(line)
            if m:
                if self._SKIP_DIR.search(line) or self._TODO_DIR.search(line):
                    self.num_tests_skipped += 1
                else:
                    self.num_tests_passed += 1
                continue

        # If no plan line found, derive total from individual results
        if self.num_tests_run == 0:
            self.num_tests_run = self.num_tests_passed + self.num_tests_failed + self.num_tests_skipped

        self.did_tests_fail = self.num_tests_failed > 0
        return {
            "framework":         self.framework,
            "num_tests_run":     self.num_tests_run,
            "num_tests_passed":  self.num_tests_passed,
            "num_tests_failed":  self.num_tests_failed,
            "num_tests_skipped": self.num_tests_skipped,
            "tests_failed":      self.tests_failed,
            "tests_skipped":     self.tests_skipped,
            "test_duration":     self.test_duration,
        }


class ProveTAPLogAnalyzer(BaseLogAnalyzer):
    """Parser for TAP output produced by pg_regress / prove / similar C test runners.

    Format:
        ok 1         - bit                                        21 ms
        not ok 3     - cast                                       58 ms
        1..14
        # All 14 tests passed.          (or)
        # 2 of 14 tests failed.
    """
    def __init__(self, lines):
        super().__init__(lines)
        self.framework = "ProveTAP"

    def is_applicable(self):
        all_passed  = re.compile(r'^#\s+All\s+\d+\s+tests?\s+passed',          re.IGNORECASE)
        some_failed = re.compile(r'^#\s+\d+\s+of\s+\d+\s+tests?\s+failed',     re.IGNORECASE)
        for raw in self.lines:
            if self._is_ctest_embedded(raw):
                continue
            line = self.clean_line(raw)
            if all_passed.search(line) or some_failed.search(line):
                return True
        return False

    def analyze(self):
        ok_line       = re.compile(r'^ok\s+\d+\s+-\s+(\S+)\s+(\d+)\s+ms',       re.IGNORECASE)
        not_ok_line   = re.compile(r'^not ok\s+\d+\s+-\s+(\S+)\s+(\d+)\s+ms',   re.IGNORECASE)
        plan_line     = re.compile(r'^1\.\.(\d+)')
        all_passed    = re.compile(r'^#\s+All\s+(\d+)\s+tests?\s+passed',        re.IGNORECASE)
        some_failed   = re.compile(r'^#\s+(\d+)\s+of\s+(\d+)\s+tests?\s+failed', re.IGNORECASE)

        for raw in self.lines:
            if self._is_ctest_embedded(raw):
                continue
            line = self.clean_line(raw).strip()

            m = not_ok_line.match(line)
            if m:
                self.num_tests_failed += 1
                self.did_tests_fail = True
                self.tests_failed.append({"file": m.group(1), "failures": [{"name": m.group(1), "error": ""}]})
                self.test_duration += int(m.group(2)) / 1000
                continue

            m = ok_line.match(line)
            if m:
                self.num_tests_passed += 1
                self.test_duration += int(m.group(2)) / 1000
                continue

            m = plan_line.match(line)
            if m:
                self.num_tests_run = int(m.group(1))
                continue

            m = all_passed.search(line)
            if m:
                self.num_tests_run = int(m.group(1))
                continue

            m = some_failed.search(line)
            if m:
                self.num_tests_failed = int(m.group(1))
                self.num_tests_run    = int(m.group(2))
                self.did_tests_fail   = True

        if self.num_tests_run == 0:
            self.num_tests_run = self.num_tests_passed + self.num_tests_failed
        self.num_tests_passed = self.num_tests_run - self.num_tests_failed - self.num_tests_skipped

        return {
            "framework":         self.framework,
            "num_tests_run":     self.num_tests_run,
            "num_tests_failed":  self.num_tests_failed,
            "num_tests_passed":  self.num_tests_passed,
            "num_tests_skipped": self.num_tests_skipped,
            "tests_failed":      self.tests_failed,
            "tests_skipped":     self.tests_skipped,
            "test_duration":     self.test_duration,
        }


class BazelLogAnalyzer(BaseLogAnalyzer):
    def __init__(self, lines):
        super().__init__(lines)
        self.framework = "Bazel"
    
    def is_applicable(self):
        run_test_pattern = re.compile(
            r'^\s*(?P<label>//\S+)\s+'
            r'(?:\([^)]*\)\s*)?'
            r'(?P<status>PASSED|FAILED TO BUILD|FAILED|SKIPPED)'
            r'(?:\s+in\s+(?P<secs>\d+(?:\.\d+)?)s)?\s*$'
        )
        for raw in self.lines:
            line = self.clean_line(raw)
            if run_test_pattern.match(line):
                return True
        return False
    
    def get_int_from_match(self, match):
        return int(re.sub(r'\D', '', match)) if match else 0
    
    def analyze(self):
        run_test_pattern = re.compile(
            r'^\s*(?P<label>//\S+)\s+'
            r'(?:\([^)]*\)\s*)?'               # optional "(cached)" or similar
            r'(?P<status>PASSED|FAILED TO BUILD|FAILED|SKIPPED)'
            r'(?:\s+in\s+(?P<secs>\d+(?:\.\d+)?)s)?\s*$'
        )
        for raw in self.lines:
            line = self.clean_line(raw)
            run_test = run_test_pattern.match(line)
            if run_test:
                label  = run_test.group('label')
                status = run_test.group('status')
                secs   = run_test.group("secs")
                self.test_duration += float(secs) if secs else 0.0

                if status == "PASSED":
                    self.num_tests_passed += 1
                    self.tests_passed.append(label)
                elif status in ("FAILED", "FAILED TO BUILD"):
                    self.num_tests_failed += 1
                    self.tests_failed.append(label)
                elif status == "SKIPPED":
                    self.num_tests_skipped += 1
                    self.tests_skipped.append(label)

        self.tests_run     = self.tests_passed + self.tests_failed + self.tests_skipped
        self.num_tests_run = len(self.tests_run)
        return {
            "framework":        self.framework,
            "num_tests_run":    self.num_tests_run,
            "num_tests_failed": self.num_tests_failed,
            "num_tests_passed": self.num_tests_passed,
            "num_tests_skipped":self.num_tests_skipped,
            "tests_failed":     self.tests_failed,
            "tests_skipped":    self.tests_skipped,
            "test_duration":    self.test_duration,   # Bazel reports seconds, no /1000
        }
            
class HardSoftErrorLogAnalyzer(BaseLogAnalyzer):
    """Parser for test runners that emit a summary with Hard/Soft error counts.

    Format:
        FAIL       encodings/some_test_fail.re
        PASS       encodings/some_test_pass.re
        -----------------
        All:         1781
        Ran:         1781
        Passed:      1772
        Soft errors: 0
        Hard errors: 9
    """
    _HARD = re.compile(r'^Hard\s+errors:\s+(\d+)', re.IGNORECASE)
    _SOFT = re.compile(r'^Soft\s+errors:\s+(\d+)', re.IGNORECASE)
    _ALL  = re.compile(r'^All:\s+(\d+)',            re.IGNORECASE)
    _RAN  = re.compile(r'^Ran:\s+(\d+)',            re.IGNORECASE)
    _PASS = re.compile(r'^Passed:\s+(\d+)',         re.IGNORECASE)
    _FAIL_LINE = re.compile(r'^FAIL\s+(\S+)',       re.IGNORECASE)

    def __init__(self, lines):
        super().__init__(lines)
        self.framework = "HardSoftError"

    def is_applicable(self):
        for raw in self.lines:
            line = self.clean_line(raw).strip()
            if self._HARD.match(line) or self._SOFT.match(line):
                return True
        return False

    def analyze(self):
        ran = all_ = None
        for raw in self.lines:
            line = self.clean_line(raw).strip()

            m = self._HARD.match(line)
            if m:
                self.num_tests_failed = int(m.group(1))
                if self.num_tests_failed > 0:
                    self.did_tests_fail = True
                continue

            m = self._ALL.match(line)
            if m:
                all_ = int(m.group(1))
                continue

            m = self._RAN.match(line)
            if m:
                ran = int(m.group(1))
                continue

            m = self._PASS.match(line)
            if m:
                self.num_tests_passed = int(m.group(1))
                continue

            m = self._FAIL_LINE.match(line)
            if m:
                self.tests_failed.append(m.group(1))

        self.num_tests_run = ran if ran is not None else (all_ if all_ is not None else 0)
        skipped = (all_ - ran) if (all_ is not None and ran is not None and all_ > ran) else 0
        self.num_tests_skipped = skipped

        return {
            "framework":         self.framework,
            "num_tests_run":     self.num_tests_run,
            "num_tests_passed":  self.num_tests_passed,
            "num_tests_failed":  self.num_tests_failed,
            "num_tests_skipped": self.num_tests_skipped,
            "tests_failed":      self.tests_failed,
            "tests_skipped":     self.tests_skipped,
            "test_duration":     self.test_duration,
        }


class AutotoolsLogAnalyzer(BaseLogAnalyzer):
    """Handles Automake/Autotools testsuite summary blocks:
        ====...====
        Testsuite summary for "..."
        ====...====
        # TOTAL: N
        # PASS:  N
        # SKIP:  N
        # XFAIL: N
        # FAIL:  N
        # XPASS: N
        # ERROR: N
    Multiple suites in one log are aggregated.
    """
    _HEADER = re.compile(r'^Testsuite summary for\b', re.IGNORECASE)
    _TOTAL  = re.compile(r'^#\s+TOTAL:\s+(\d+)',  re.IGNORECASE)
    _PASS   = re.compile(r'^#\s+PASS:\s+(\d+)',   re.IGNORECASE)
    _FAIL   = re.compile(r'^#\s+FAIL:\s+(\d+)',   re.IGNORECASE)
    _SKIP   = re.compile(r'^#\s+SKIP:\s+(\d+)',   re.IGNORECASE)
    _XFAIL  = re.compile(r'^#\s+XFAIL:\s+(\d+)',  re.IGNORECASE)
    _ERROR  = re.compile(r'^#\s+ERROR:\s+(\d+)',  re.IGNORECASE)

    def __init__(self, lines):
        super().__init__(lines)
        self.framework = "Autotools"

    def is_applicable(self):
        return any(
            self._HEADER.search(self.clean_line(l))
            for l in self.lines if not self._is_ctest_embedded(l)
        )

    def analyze(self):
        total = passed = failed = skipped = xfail = error = 0
        for raw in self.lines:
            if self._is_ctest_embedded(raw):
                continue
            line = self.clean_line(raw)
            m = self._TOTAL.match(line);  total   += int(m.group(1)) if m else 0
            m = self._PASS.match(line);   passed  += int(m.group(1)) if m else 0
            m = self._FAIL.match(line);   failed  += int(m.group(1)) if m else 0
            m = self._SKIP.match(line);   skipped += int(m.group(1)) if m else 0
            m = self._XFAIL.match(line);  xfail   += int(m.group(1)) if m else 0
            m = self._ERROR.match(line);  error   += int(m.group(1)) if m else 0

        self.num_tests_run     = total
        self.num_tests_passed  = passed
        self.num_tests_failed  = failed + error
        self.num_tests_skipped = skipped + xfail
        return {
            "framework":         self.framework,
            "num_tests_run":     self.num_tests_run,
            "num_tests_passed":  self.num_tests_passed,
            "num_tests_failed":  self.num_tests_failed,
            "num_tests_skipped": self.num_tests_skipped,
            "tests_failed":      [],
            "tests_skipped":     [],
            "test_duration":     self.test_duration,
        }


class Radare2LogAnalyzer(BaseLogAnalyzer):
    """Radare2 r2r test runner format.

    Each line: [N/M]  module/name  CUMOK OK  CUMBR BR  CUMXX XX  CUMSK SK  CUMFX FX
    The last such line holds the final cumulative counts.
    OK = passed, XX = failed (unexpected), SK = skipped, BR = broken (expected failure).
    """
    _LINE = re.compile(
        r'^\s*\[\s*\d+/\d+\]\s+\S+\s+'
        r'(\d+)\s+OK\s+(\d+)\s+BR\s+(\d+)\s+XX\s+(\d+)\s+SK\s+(\d+)\s+FX',
        re.IGNORECASE
    )
    _ANSI = re.compile(r'\x1B[@-_][0-?]*[ -/]*[@-~]', re.M)
    _TS   = re.compile(r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d+Z\s+')

    def __init__(self, lines):
        super().__init__(lines)
        self.framework = "radare2-r2r"

    def _clean(self, line):
        return self.clean_line(line)

    def is_applicable(self):
        return any(self._LINE.search(self._clean(l)) for l in self.lines)

    def analyze(self):
        last_ok = last_xx = last_sk = last_br = 0
        for raw in self.lines:
            m = self._LINE.search(self._clean(raw))
            if m:
                last_ok, last_br, last_xx, last_sk = int(m.group(1)), int(m.group(2)), int(m.group(3)), int(m.group(4))
        self.num_tests_passed  = last_ok
        self.num_tests_failed  = last_xx
        self.num_tests_skipped = last_sk
        self.num_tests_run     = last_ok + last_xx + last_sk + last_br
        self.did_tests_fail    = last_xx > 0
        return {
            "framework":         self.framework,
            "num_tests_run":     self.num_tests_run,
            "num_tests_passed":  self.num_tests_passed,
            "num_tests_failed":  self.num_tests_failed,
            "num_tests_skipped": self.num_tests_skipped,
            "tests_failed":      self.tests_failed,
            "tests_skipped":     self.tests_skipped,
            "test_duration":     self.test_duration,
        }


class ShellTestLogAnalyzer(BaseLogAnalyzer):
    """Shell-based test runners that emit: FAILED N / N tests! or PASSED N / N tests!

    Seen in: zstd cli-tests, and similar Makefile-driven shell test suites.
    """
    _SUMMARY = re.compile(r'(FAILED|PASSED)\s+(\d+)\s*/\s*(\d+)\s+tests?', re.IGNORECASE)
    _FAIL_LINE = re.compile(r'^FAIL:\s+(\S+)', re.IGNORECASE)
    _ANSI = re.compile(r'\x1B[@-_][0-?]*[ -/]*[@-~]', re.M)
    _TS   = re.compile(r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d+Z\s+')

    def __init__(self, lines):
        super().__init__(lines)
        self.framework = "shell-tests"

    def _clean(self, line):
        return self.clean_line(line)

    def is_applicable(self):
        return any(self._SUMMARY.search(self._clean(l)) for l in self.lines)

    def analyze(self):
        for raw in self.lines:
            line = self._clean(raw)
            m = self._SUMMARY.search(line)
            if m:
                verdict, failed_or_passed, total = m.group(1), int(m.group(2)), int(m.group(3))
                if verdict.upper() == "FAILED":
                    self.num_tests_failed = failed_or_passed
                    self.num_tests_run    = total
                else:
                    self.num_tests_passed = failed_or_passed
                    self.num_tests_run    = total
            f = self._FAIL_LINE.match(line)
            if f:
                self.tests_failed.append({"file": f.group(1), "failures": []})
        if self.num_tests_passed == 0:
            self.num_tests_passed = self.num_tests_run - self.num_tests_failed
        self.did_tests_fail = self.num_tests_failed > 0
        return {
            "framework":         self.framework,
            "num_tests_run":     self.num_tests_run,
            "num_tests_passed":  self.num_tests_passed,
            "num_tests_failed":  self.num_tests_failed,
            "num_tests_skipped": self.num_tests_skipped,
            "tests_failed":      self.tests_failed,
            "tests_skipped":     self.tests_skipped,
            "test_duration":     self.test_duration,
        }


class CatBoostLogAnalyzer(BaseLogAnalyzer):
    """CatBoost test summary: [ FAIL N | WARN N | SKIP N | PASS N ]"""
    _SUMMARY = re.compile(
        r'\[\s*FAIL\s+(?P<fail>\d+)\s*\|\s*WARN\s+\d+\s*\|\s*SKIP\s+(?P<skip>\d+)\s*\|\s*PASS\s+(?P<pass>\d+)\s*\]',
        re.IGNORECASE
    )
    _ANSI = re.compile(r'\x1B[@-_][0-?]*[ -/]*[@-~]', re.M)
    _TS   = re.compile(r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d+Z\s+')

    def __init__(self, lines):
        super().__init__(lines)
        self.framework = "catboost"

    def _clean(self, line):
        return self.clean_line(line)

    def is_applicable(self):
        return any(self._SUMMARY.search(self._clean(l)) for l in self.lines)

    def analyze(self):
        for raw in self.lines:
            m = self._SUMMARY.search(self._clean(raw))
            if m:
                self.num_tests_failed  = int(m.group('fail'))
                self.num_tests_skipped = int(m.group('skip'))
                self.num_tests_passed  = int(m.group('pass'))
                self.num_tests_run     = self.num_tests_failed + self.num_tests_passed + self.num_tests_skipped
                self.did_tests_fail    = self.num_tests_failed > 0
        return {
            "framework":         self.framework,
            "num_tests_run":     self.num_tests_run,
            "num_tests_passed":  self.num_tests_passed,
            "num_tests_failed":  self.num_tests_failed,
            "num_tests_skipped": self.num_tests_skipped,
            "tests_failed":      self.tests_failed,
            "tests_skipped":     self.tests_skipped,
            "test_duration":     self.test_duration,
        }


class MRubyLogAnalyzer(BaseLogAnalyzer):
    """mruby test runner format (appears once per suite, multiple suites accumulate):

        Total: 1682
           OK: 1673
           KO: 0
        Crash: 0
      Warning: 0
         Skip: 9
         Time: 1.31 seconds
    """
    _TOTAL    = re.compile(r'^\s*Total:\s*(\d+)',          re.IGNORECASE)
    _OK       = re.compile(r'^\s*OK:\s*(\d+)',             re.IGNORECASE)
    _KO       = re.compile(r'^\s*KO:\s*(\d+)',             re.IGNORECASE)
    _SKIP     = re.compile(r'^\s*Skip:\s*(\d+)',           re.IGNORECASE)
    _TIME     = re.compile(r'^\s*Time:\s*([\d.]+)',        re.IGNORECASE)
    _FAIL_LINE= re.compile(r'^Fail:\s+(.+?)(?:\s+\(.*\))?$', re.IGNORECASE)
    _ANSI  = re.compile(r'\x1B[@-_][0-?]*[ -/]*[@-~]', re.M)
    _TS    = re.compile(r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d+Z\s+')

    def __init__(self, lines):
        super().__init__(lines)
        self.framework = "mruby"

    def _clean(self, line):
        return self.clean_line(line)

    def is_applicable(self):
        return any(self._KO.match(self._clean(l)) for l in self.lines)

    def analyze(self):
        for line in self.lines:
            clean = self._clean(line)
            m = self._TOTAL.match(clean)
            if m:
                self.num_tests_run     += int(m.group(1))
            m = self._OK.match(clean)
            if m:
                self.num_tests_passed  += int(m.group(1))
            m = self._KO.match(clean)
            if m:
                self.num_tests_failed  += int(m.group(1))
            m = self._SKIP.match(clean)
            if m:
                self.num_tests_skipped += int(m.group(1))
            m = self._TIME.match(clean)
            if m:
                self.test_duration     += float(m.group(1))
            m = self._FAIL_LINE.match(clean)
            if m:
                self.tests_failed.append(m.group(1).strip())
        return {
            "framework":         self.framework,
            "num_tests_run":     self.num_tests_run,
            "num_tests_passed":  self.num_tests_passed,
            "num_tests_failed":  self.num_tests_failed,
            "num_tests_skipped": self.num_tests_skipped,
            "tests_failed":      self.tests_failed,
            "tests_skipped":     self.tests_skipped,
            "test_duration":     self.test_duration,
        }


class MicroPythonLogAnalyzer(BaseLogAnalyzer):
    """MicroPython test runner format:

        1086 tests performed (32354 individual testcases)
        1082 tests passed
        24 tests skipped: file1.py file2.py ...
        4 tests failed: file1.py file2.py ...
    """
    _PERFORMED = re.compile(r'^(\d+)\s+tests?\s+performed', re.IGNORECASE)
    _PASSED    = re.compile(r'^(\d+)\s+tests?\s+passed',    re.IGNORECASE)
    _SKIPPED   = re.compile(r'^(\d+)\s+tests?\s+skipped(?::\s*(.*))?', re.IGNORECASE)
    _FAILED    = re.compile(r'^(\d+)\s+tests?\s+failed(?::\s*(.*))?',  re.IGNORECASE)
    _ANSI = re.compile(r'\x1B[@-_][0-?]*[ -/]*[@-~]', re.M)
    _TS   = re.compile(r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d+Z\s+')

    def __init__(self, lines):
        super().__init__(lines)
        self.framework = "micropython"

    def _clean(self, line):
        return self.clean_line(line)

    def is_applicable(self):
        return any(self._PERFORMED.match(self._clean(l)) for l in self.lines)

    def analyze(self):
        for line in self.lines:
            clean = self._clean(line)
            m = self._PERFORMED.match(clean)
            if m:
                self.num_tests_run += int(m.group(1))
            m = self._PASSED.match(clean)
            if m:
                self.num_tests_passed += int(m.group(1))
            m = self._SKIPPED.match(clean)
            if m:
                self.num_tests_skipped += int(m.group(1))
            m = self._FAILED.match(clean)
            if m:
                self.num_tests_failed += int(m.group(1))
                if m.group(2):
                    for f in m.group(2).split():
                        self.tests_failed.append(f.strip())
        return {
            "framework":         self.framework,
            "num_tests_run":     self.num_tests_run,
            "num_tests_passed":  self.num_tests_passed,
            "num_tests_failed":  self.num_tests_failed,
            "num_tests_skipped": self.num_tests_skipped,
            "tests_failed":      self.tests_failed,
            "tests_skipped":     self.tests_skipped,
            "test_duration":     self.test_duration,
        }


class PerlHarnessLogAnalyzer(BaseLogAnalyzer):
    """Perl Test::Harness summary format.

    Individual lines:
        ../lib/vars.t ........ ok
        ../lib/foo.t ......... FAILED 1-3, 5
    Summary:
        All tests successful.
        Failed 2/10 test scripts.  3/20 subtests failed.
        Files=2944, Tests=1380165, 417 wallclock secs (...)
        Result: PASS  |  Result: FAIL
    """
    _STATS   = re.compile(r'Files=(\d+),\s*Tests=(\d+),', re.IGNORECASE)
    _RESULT  = re.compile(r'^Result:\s+(PASS|FAIL)',       re.IGNORECASE)
    _FAIL_SUM= re.compile(
        r'Failed\s+\d+/\d+\s+test\s+scripts?[.,].*?(\d+)/(\d+)\s+subtests?\s+failed',
        re.IGNORECASE
    )
    _FAIL_LINE = re.compile(r'^\s*(\S+\.t\b.*?)\s+FAILED', re.IGNORECASE)
    _ANSI    = re.compile(r'\x1B[@-_][0-?]*[ -/]*[@-~]', re.M)
    _TS      = re.compile(r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d+Z\s+')

    def __init__(self, lines):
        super().__init__(lines)
        self.framework = "perl-harness"

    def _clean(self, line):
        return self.clean_line(line)

    def is_applicable(self):
        for raw in self.lines:
            line = self._clean(raw)
            if self._STATS.search(line) or self._RESULT.match(line):
                return True
        return False

    def analyze(self):
        for raw in self.lines:
            line = self._clean(raw)

            m = self._STATS.search(line)
            if m:
                self.num_tests_run = int(m.group(2))
                continue

            m = self._RESULT.match(line)
            if m:
                if m.group(1).upper() == "PASS":
                    self.num_tests_passed = self.num_tests_run
                self.did_tests_fail = m.group(1).upper() == "FAIL"
                continue

            m = self._FAIL_SUM.search(line)
            if m:
                self.num_tests_failed = int(m.group(1))
                continue

            m = self._FAIL_LINE.match(line)
            if m:
                self.tests_failed.append(m.group(1).strip())

        if self.num_tests_passed == 0 and self.num_tests_run > 0:
            self.num_tests_passed = self.num_tests_run - self.num_tests_failed

        return {
            "framework":         self.framework,
            "num_tests_run":     self.num_tests_run,
            "num_tests_passed":  self.num_tests_passed,
            "num_tests_failed":  self.num_tests_failed,
            "num_tests_skipped": self.num_tests_skipped,
            "tests_failed":      self.tests_failed,
            "tests_skipped":     self.tests_skipped,
            "test_duration":     self.test_duration,
        }


class ZstdTestLogAnalyzer(BaseLogAnalyzer):
    """Parser for zstd-style shell test suites.

    Individual test lines:
        ✓ Test N PASSED: <description>
        ✗ Test N FAILED: <description>
    Summary lines (optional):
        All tests completed successfully!
        N / N tests passed.
    """
    _PASS_LINE    = re.compile(r'[✓✔]?\s*Test\s+(\d+)\s+PASSED[:\s]',  re.IGNORECASE)
    _FAIL_LINE    = re.compile(r'[✗✘×]?\s*Test\s+(\d+)\s+FAILED[:\s]', re.IGNORECASE)
    _ALL_PASSED   = re.compile(r'All\s+tests\s+completed\s+successfully', re.IGNORECASE)
    _SUMMARY      = re.compile(r'(\d+)\s*/\s*(\d+)\s+tests?\s+passed',  re.IGNORECASE)
    _ANSI         = re.compile(r'\x1B[@-_][0-?]*[ -/]*[@-~]', re.M)
    _TS           = re.compile(r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d+Z\s+')

    def __init__(self, lines):
        super().__init__(lines)
        self.framework = "zstd-tests"

    def _clean(self, line):
        return self.clean_line(line)

    def is_applicable(self):
        for raw in self.lines:
            line = self._clean(raw)
            if self._PASS_LINE.search(line) or self._FAIL_LINE.search(line) or self._ALL_PASSED.search(line):
                return True
        return False

    def analyze(self):
        passed_tests = set()
        failed_tests = set()

        for raw in self.lines:
            line = self._clean(raw)

            m = self._PASS_LINE.search(line)
            if m:
                passed_tests.add(int(m.group(1)))
                continue

            m = self._FAIL_LINE.search(line)
            if m:
                idx = int(m.group(1))
                failed_tests.add(idx)
                self.tests_failed.append(f"Test {idx}")
                continue

            m = self._SUMMARY.search(line)
            if m:
                self.num_tests_passed = int(m.group(1))
                self.num_tests_run    = int(m.group(2))

        # If no explicit summary line, derive from individual test lines
        if self.num_tests_run == 0:
            self.num_tests_passed = len(passed_tests)
            self.num_tests_failed = len(failed_tests)
            self.num_tests_run    = len(passed_tests | failed_tests)
        else:
            self.num_tests_failed = self.num_tests_run - self.num_tests_passed

        self.did_tests_fail = self.num_tests_failed > 0
        return {
            "framework":         self.framework,
            "num_tests_run":     self.num_tests_run,
            "num_tests_passed":  self.num_tests_passed,
            "num_tests_failed":  self.num_tests_failed,
            "num_tests_skipped": self.num_tests_skipped,
            "tests_failed":      self.tests_failed,
            "tests_skipped":     self.tests_skipped,
            "test_duration":     self.test_duration,
        }


class DuckDBLogAnalyzer(BaseLogAnalyzer):
    """DuckDB custom test runner format:

        found 4411 tests
        config: workers=48, ...
        .................................................. [100%]
        all tests passed in 97s
        (or: N tests failed)
    """
    _FOUND   = re.compile(r'^found\s+(\d+)\s+tests?', re.IGNORECASE)
    _PASSED  = re.compile(r'^all\s+tests?\s+passed\s+in\s+([\d.]+)s', re.IGNORECASE)
    _FAILED  = re.compile(r'^(\d+)\s+tests?\s+failed', re.IGNORECASE)
    _ANSI = re.compile(r'\x1B[@-_][0-?]*[ -/]*[@-~]', re.M)
    _TS   = re.compile(r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d+Z\s+')

    def __init__(self, lines):
        super().__init__(lines)
        self.framework = "duckdb"

    def _clean(self, line):
        return self.clean_line(line)

    def is_applicable(self):
        for raw in self.lines:
            line = self._clean(raw)
            if self._PASSED.match(line) or self._FOUND.match(line):
                return True
        return False

    def analyze(self):
        for raw in self.lines:
            line = self._clean(raw)
            m = self._FOUND.match(line)
            if m:
                self.num_tests_run = int(m.group(1))
                continue
            m = self._PASSED.match(line)
            if m:
                self.test_duration = float(m.group(1))
                self.num_tests_passed = self.num_tests_run
                continue
            m = self._FAILED.match(line)
            if m:
                self.num_tests_failed += int(m.group(1))

        if self.num_tests_passed == 0 and self.num_tests_run > 0:
            self.num_tests_passed = self.num_tests_run - self.num_tests_failed
        self.did_tests_fail = self.num_tests_failed > 0
        return {
            "framework":         self.framework,
            "num_tests_run":     self.num_tests_run,
            "num_tests_passed":  self.num_tests_passed,
            "num_tests_failed":  self.num_tests_failed,
            "num_tests_skipped": self.num_tests_skipped,
            "tests_failed":      self.tests_failed,
            "tests_skipped":     self.tests_skipped,
            "test_duration":     self.test_duration,
        }


class CCVLogAnalyzer(BaseLogAnalyzer):
    """CCV / cnnp test runner format:

        [20/45] [RUN] extract one output each feed into different feed-forward ...
        [20/45] [PASS] extract one output each feed into different feed-forward
        [21/45] [FAIL] some test name
    """
    _LINE = re.compile(
        r'^\[(\d+)/(\d+)\]\s+\[(PASS|FAIL|RUN)\]\s+(.+?)(?:\s+\.\.\.)?\s*$',
        re.IGNORECASE
    )
    _ANSI = re.compile(r'\x1B[@-_][0-?]*[ -/]*[@-~]', re.M)
    _TS   = re.compile(r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d+Z\s+')

    def __init__(self, lines):
        super().__init__(lines)
        self.framework = "ccv"

    def _clean(self, line):
        return self.clean_line(line)

    def is_applicable(self):
        for raw in self.lines:
            if self._LINE.match(self._clean(raw)):
                return True
        return False

    def analyze(self):
        max_total = 0
        for raw in self.lines:
            m = self._LINE.match(self._clean(raw))
            if not m:
                continue
            idx, total, status, name = int(m.group(1)), int(m.group(2)), m.group(3).upper(), m.group(4).strip()
            if total > max_total:
                max_total = total
            if status == 'PASS':
                self.num_tests_passed += 1
            elif status == 'FAIL':
                self.num_tests_failed += 1
                self.tests_failed.append(name)

        self.num_tests_run = self.num_tests_passed + self.num_tests_failed
        self.did_tests_fail = self.num_tests_failed > 0
        return {
            "framework":         self.framework,
            "num_tests_run":     self.num_tests_run,
            "num_tests_passed":  self.num_tests_passed,
            "num_tests_failed":  self.num_tests_failed,
            "num_tests_skipped": self.num_tests_skipped,
            "tests_failed":      self.tests_failed,
            "tests_skipped":     self.tests_skipped,
            "test_duration":     self.test_duration,
        }


class CapnProtoLogAnalyzer(BaseLogAnalyzer):
    """Cap'n Proto test runner format:

        [ TEST ] capnp/compat/json-test.c++:199: null pointer field
        [ PASS ] capnp/compat/json-test.c++:199: null pointer field (28.904μs)
        [ FAIL ] capnp/compat/json-test.c++:199: some test (1.2ms)
        1308 test(s) passed
    """
    _PASS_LINE    = re.compile(r'^\[\s*PASS\s*\]\s+(.+?)\s+\([\d.]+\s*(?:μs|ms|ns|s)\)', re.IGNORECASE)
    _FAIL_LINE    = re.compile(r'^\[\s*FAIL\s*\]\s+(.+?)\s+\([\d.]+\s*(?:μs|ms|ns|s)\)', re.IGNORECASE)
    _SUMMARY      = re.compile(r'^(\d+)\s+tests?\(s\)?\s+passed', re.IGNORECASE)
    _ANSI = re.compile(r'\x1B[@-_][0-?]*[ -/]*[@-~]', re.M)
    _TS   = re.compile(r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d+Z\s+')

    def __init__(self, lines):
        super().__init__(lines)
        self.framework = "capnproto"

    def _clean(self, line):
        return self.clean_line(line)

    def is_applicable(self):
        for raw in self.lines:
            line = self._clean(raw)
            if self._PASS_LINE.match(line) or self._FAIL_LINE.match(line) or self._SUMMARY.match(line):
                return True
        return False

    def analyze(self):
        duration_re = re.compile(r'\(([\d.]+)\s*(μs|ms|ns|s)\)$')
        summary_found = False

        for raw in self.lines:
            line = self._clean(raw)

            m = self._SUMMARY.match(line)
            if m:
                self.num_tests_passed = int(m.group(1))
                summary_found = True
                continue

            m = self._PASS_LINE.match(line)
            if m and not summary_found:
                self.num_tests_passed += 1
                d = duration_re.search(line)
                if d:
                    val, unit = float(d.group(1)), d.group(2)
                    self.test_duration += val / 1e6 if unit == 'μs' else val / 1e3 if unit == 'ms' else val / 1e9 if unit == 'ns' else val
                continue

            m = self._FAIL_LINE.match(line)
            if m:
                self.num_tests_failed += 1
                self.tests_failed.append(m.group(1).strip())

        self.num_tests_run = self.num_tests_passed + self.num_tests_failed
        self.did_tests_fail = self.num_tests_failed > 0
        return {
            "framework":         self.framework,
            "num_tests_run":     self.num_tests_run,
            "num_tests_passed":  self.num_tests_passed,
            "num_tests_failed":  self.num_tests_failed,
            "num_tests_skipped": self.num_tests_skipped,
            "tests_failed":      self.tests_failed,
            "tests_skipped":     self.tests_skipped,
            "test_duration":     self.test_duration,
        }


class MNNTestLogAnalyzer(BaseLogAnalyzer):
    """MNN test runner format:

        √√√ all tests passed.
        TEST_NAME_UNIT: 单元测试
        TEST_CASE_AMOUNT_UNIT: {"blocked":0,"failed":0,"passed":357,"skipped":0}
        TEST_CASE={"name":"单元测试","failed":0,"passed":357}
    """
    _AMOUNT = re.compile(
        r'TEST_CASE_AMOUNT_\w+:\s*\{"blocked"\s*:\s*(?P<blocked>\d+)\s*,\s*"failed"\s*:\s*(?P<failed>\d+)\s*,\s*"passed"\s*:\s*(?P<passed>\d+)\s*,\s*"skipped"\s*:\s*(?P<skipped>\d+)\s*\}',
        re.IGNORECASE
    )
    _ANSI = re.compile(r'\x1B[@-_][0-?]*[ -/]*[@-~]', re.M)
    _TS   = re.compile(r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d+Z\s+')

    def __init__(self, lines):
        super().__init__(lines)
        self.framework = "MNN"

    def _clean(self, line):
        return self.clean_line(line)

    def is_applicable(self):
        return any(self._AMOUNT.search(self._clean(l)) for l in self.lines)

    def analyze(self):
        for raw in self.lines:
            m = self._AMOUNT.search(self._clean(raw))
            if m:
                self.num_tests_passed  += int(m.group('passed'))
                self.num_tests_failed  += int(m.group('failed'))
                self.num_tests_skipped += int(m.group('skipped'))
        self.num_tests_run = self.num_tests_passed + self.num_tests_failed + self.num_tests_skipped
        self.did_tests_fail = self.num_tests_failed > 0
        return {
            "framework":         self.framework,
            "num_tests_run":     self.num_tests_run,
            "num_tests_passed":  self.num_tests_passed,
            "num_tests_failed":  self.num_tests_failed,
            "num_tests_skipped": self.num_tests_skipped,
            "tests_failed":      self.tests_failed,
            "tests_skipped":     self.tests_skipped,
            "test_duration":     self.test_duration,
        }


class UnityLogAnalyzer(BaseLogAnalyzer):
    """ThrowTheSwitch/Unity test framework.

    Individual result lines:
        file.c:LINE:test_name:PASS
        file.c:LINE:test_name:FAIL: message
        file.c:LINE:test_name:IGNORE
    Suite summary line:
        N Tests M Failures K Ignored
    """
    _SUMMARY_RE = re.compile(r'^(\d+)\s+Tests\s+(\d+)\s+Failures\s+(\d+)\s+Ignored\s*$')
    _RESULT_RE  = re.compile(r'^[\w./\-]+\.c:\d+:(\w+):(PASS|FAIL|IGNORE)(?::\s*(.*))?$')

    def __init__(self, lines):
        super().__init__(lines)
        self.framework = "Unity"

    def is_applicable(self):
        for raw in self.lines:
            if self._SUMMARY_RE.search(self.clean_line(raw)):
                return True
        return False

    def analyze(self):
        seen_pass   = set()
        seen_fail   = set()
        seen_ignore = set()

        for raw in self.lines:
            line = self.clean_line(raw)
            m = self._RESULT_RE.match(line)
            if m:
                name, result = m.group(1), m.group(2)
                if result == "PASS":
                    seen_pass.add(name)
                elif result == "FAIL":
                    seen_fail.add(name)
                    if name not in self.tests_failed:
                        self.tests_failed.append(name)
                elif result == "IGNORE":
                    seen_ignore.add(name)

        self.num_tests_passed  = len(seen_pass)
        self.num_tests_failed  = len(seen_fail)
        self.num_tests_skipped = len(seen_ignore)
        self.num_tests_run     = self.num_tests_passed + self.num_tests_failed + self.num_tests_skipped

        return {
            "framework":         self.framework,
            "num_tests_run":     self.num_tests_run,
            "num_tests_passed":  self.num_tests_passed,
            "num_tests_failed":  self.num_tests_failed,
            "num_tests_skipped": self.num_tests_skipped,
            "tests_failed":      self.tests_failed,
            "tests_skipped":     self.tests_skipped,
            "test_duration":     self.test_duration,
        }


class LLVMLitLogAnalyzer(BaseLogAnalyzer):
    """LLVM lit test runner (used by torch-mlir, llvm-project, etc.).

    Summary pattern:
        Total Discovered Tests: N
          Passed:  N (X%)
          Failed:  N (X%)
          Skipped: N (X%)
          ...
    Failed test lines:
        FAILED: SuiteName :: path/to/test.py
    """
    _TOTAL_RE    = re.compile(r'Total Discovered Tests:\s*(\d+)')
    # After clean_line, these will be at line start.
    # Require the trailing (X%) to distinguish lit summary from GTest "Passed: N" lines.
    _PASSED_RE   = re.compile(r'^Passed\s*:\s*(\d+)\s*\(', re.IGNORECASE)
    _FAILED_RE   = re.compile(r'^Failed\s*:\s*(\d+)\s*\(', re.IGNORECASE)
    _XFAIL_RE    = re.compile(r'^Expectedly\s+Failed\s*:\s*(\d+)\s*\(', re.IGNORECASE)
    _SKIPPED_RE  = re.compile(r'^(?:Skipped|Unsupported|Unresolved)\s*:\s*(\d+)\s*\(', re.IGNORECASE)
    _FAIL_RE     = re.compile(r'(?:FAILED|FAIL):\s+\S+\s*::\s+(.+)')
    _TIME_RE     = re.compile(r'Testing Time:\s*([\d.]+)s')

    def __init__(self, lines):
        super().__init__(lines)
        self.framework = "LLVMLit"

    def is_applicable(self):
        for raw in self.lines:
            if self._TOTAL_RE.search(self.clean_line(raw)):
                return True
        return False

    def analyze(self):
        # Collect per-suite blocks, each starting at a "Total Discovered Tests:" line
        suites = []
        current = None
        for raw in self.lines:
            line = self.clean_line(raw)  # strips timestamps, ANSI, and whitespace

            m = self._TOTAL_RE.search(line)
            if m:
                if current:
                    suites.append(current)
                current = {'total': int(m.group(1)), 'passed': 0, 'failed': 0,
                           'skipped': 0, 'xfail': 0, 'duration': 0.0}
                continue
            if current is None:
                continue
            m = self._PASSED_RE.match(line)
            if m:
                current['passed'] = int(m.group(1))
            m = self._FAILED_RE.match(line)
            if m:
                current['failed'] = int(m.group(1))
            m = self._XFAIL_RE.match(line)
            if m:
                current['xfail'] += int(m.group(1))
            m = self._SKIPPED_RE.match(line)
            if m:
                current['skipped'] += int(m.group(1))
            m = self._TIME_RE.search(line)
            if m:
                current['duration'] = float(m.group(1))
        if current:
            suites.append(current)

        # Collect failed test names (strip trailing count like " (7 of 48)")
        _TRIM_RE = re.compile(r'\s*\(\d+\s+of\s+\d+\)\s*$')
        for raw in self.lines:
            line = self.clean_line(raw)
            m = self._FAIL_RE.search(line)
            if m:
                name = _TRIM_RE.sub('', m.group(1)).strip()
                if name not in self.tests_failed:
                    self.tests_failed.append(name)

        # Sum across suites (xfail = expected failures, treated as skipped)
        self.num_tests_run     = sum(s['total']    for s in suites)
        self.num_tests_passed  = sum(s['passed']   for s in suites)
        self.num_tests_failed  = sum(s['failed']   for s in suites)
        self.num_tests_skipped = sum(s['skipped'] + s['xfail'] for s in suites)
        self.test_duration     = sum(s['duration'] for s in suites)

        return {
            "framework":         self.framework,
            "num_tests_run":     self.num_tests_run,
            "num_tests_passed":  self.num_tests_passed,
            "num_tests_failed":  self.num_tests_failed,
            "num_tests_skipped": self.num_tests_skipped,
            "tests_failed":      self.tests_failed,
            "tests_skipped":     self.tests_skipped,
            "test_duration":     self.test_duration,
        }


class CsoundLogAnalyzer(BaseLogAnalyzer):
    """Csound custom test runner.

    Summary lines (anywhere in log):
        Tests Passed: N
        Tests Failed: N

    Failed test lines:
        [FAIL] - Test N: <description>
    """
    _PASSED_RE = re.compile(r'^Tests Passed:\s*(\d+)', re.IGNORECASE)
    _FAILED_RE = re.compile(r'^Tests Failed:\s*(\d+)', re.IGNORECASE)
    _FAIL_RE   = re.compile(r'\[FAIL\]\s*-\s*Test\s*\d+:\s*(.+)')

    def __init__(self, lines):
        super().__init__(lines)
        self.framework = "Csound"

    def is_applicable(self):
        for raw in self.lines:
            if self._PASSED_RE.match(self.clean_line(raw)):
                return True
        return False

    def analyze(self):
        passed = failed = 0
        for raw in self.lines:
            line = self.clean_line(raw)
            m = self._PASSED_RE.match(line)
            if m:
                passed = int(m.group(1))
            m = self._FAILED_RE.match(line)
            if m:
                failed = int(m.group(1))
            m = self._FAIL_RE.search(line)
            if m:
                name = m.group(1).strip()
                if name not in self.tests_failed:
                    self.tests_failed.append(name)

        self.num_tests_passed  = passed
        self.num_tests_failed  = failed
        self.num_tests_run     = passed + failed
        self.num_tests_skipped = 0

        return {
            "framework":         self.framework,
            "num_tests_run":     self.num_tests_run,
            "num_tests_passed":  self.num_tests_passed,
            "num_tests_failed":  self.num_tests_failed,
            "num_tests_skipped": self.num_tests_skipped,
            "tests_failed":      self.tests_failed,
            "tests_skipped":     self.tests_skipped,
            "test_duration":     self.test_duration,
        }


# def detect_analyzer(log_lines):
#     analyzers = [
#         CTEST_LogAnalyzer,
#         GTest_LogAnalyzer,
#         GitTest_Loganalyzer
#     ]
    
#     applicable = []
#     for AnalyzerClass in analyzers:
#         analyzer = AnalyzerClass(log_lines)
#         if analyzer.is_applicable():
#             applicable.append(analyzer)
    
#     if not applicable:
#         return None
    
#     # For now, we'll just return the first match. Since there can be only one unique ?
#     return applicable[0]
        
# def read_log_file(file_path):
#     with open(file_path, 'r', encoding='utf-8') as file:
#         return file.readlines()

# log_lines = read_log_file("log.txt")
    
# analyzer = detect_analyzer(log_lines)
    
# if analyzer:
#     results = analyzer.analyze()
#     print(results)
# else:
#     print("No applicable analyzer found for this log.")   
                
                

