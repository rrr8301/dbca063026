import re

class BaseLogAnalyzer:
    _ANSI_RE = re.compile(r'\x1B[@-_][0-?]*[ -/]*[@-~]', re.M)
    _TS_RE   = re.compile(r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d+Z\s+')
    _ACT_RE  = re.compile(r'^\[[\w/ ._-]+\]\s{2,}(?:\|\s?)?')

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
        """Strip ANSI codes, GitHub timestamps, and act runner prefixes."""
        line = self._ANSI_RE.sub('', line)
        line = self._TS_RE.sub('', line)
        line = self._ACT_RE.sub('', line)
        return line.strip()

    def analyze(self):
        raise NotImplementedError("Subclasses should implement this method")
    
    def is_applicable(self):
        """Our Analyzers can override this and use to check logs searching for something unique to them 
        and determine if the logfile applies to them"""
        return False
    
class PytestLogAnalyzer(BaseLogAnalyzer):
    def __init__(self, lines):
        super().__init__(lines)
        self.framework = "pytest"
        self.num_tests_xfailed = 0
        self.tests_xfailed = []
        self.num_tests_xpassed = 0
        self.tests_xpassed = []
        self.num_tests_deselected = 0
        self.short_summary = False
        self._seen_summaries = set()
        
    def is_applicable(self):
        return any(re.search(r'\bpytest\b', line, re.IGNORECASE) for line in self.lines)
    
    def get_int_from_match(self, match):
        return int(re.sub(r'\D', '', match)) if match else 0
    
    def analyze(self):
        pytest_pattern = re.compile(
            r"""=*\s*                                  # leading ===
                (?:(?P<failed>\d+)\s+failed,?\s*)?     # 2 failed,
                (?:(?P<passed>\d+)\s+passed,?\s*)?     # 12891 passed,
                (?:(?P<skipped>\d+)\s+skipped,?\s*)?   # 677 skipped,
                (?:(?P<deselected>\d+)\s+deselected,?\s*)? # 30 deselected,
                (?:(?P<xfail>\d+)\s+xfailed,?\s*)?     # 331 xfailed,
                (?:(?P<xpass>\d+)\s+xpassed,?\s*)?     # 3 xpassed,
                (?:(?P<warnings>\d+)\s+warning(?:s)?,?\s*)? # 4 warnings,
                (?:(?P<errors>\d+)\s+errors?,?\s*)?     # 26 errors,
                (?:\d+\s+rerun,?\s*)?                  # 41 rerun,
                (?:\d+\s+subtests?\s+passed,?\s*)?     # 265 subtests passed
                in\s+(?P<secs>[\d.]+)\s*(?:s|seconds)  # in 1159.87s
                (?:\s*\([\d:]+\))?                     # optional (0:19:19)
                \s*=*                                  # trailing ===
            """, re.IGNORECASE | re.VERBOSE,
        )
        # Multi-line summary: "Results (161.82s):" followed by indented count lines
        multiline_header_pattern = re.compile(
            r'^Results\s+\((?P<secs>[\d.]+)\s*(?:s|sec|seconds)?\):',
            re.IGNORECASE
        )
        multiline_count_pattern = re.compile(
            r'^\s*(?P<count>\d+)\s+(?P<label>passed|failed|skipped|xfailed|xpassed|error)\s*$',
            re.IGNORECASE
        )
        short_summary_pattern = re.compile(r"=+\s*short test summary info\s*=+", re.IGNORECASE)
        # FAILED path/file.py::Class::method  OR  FAILED path/file.py::method - error msg
        failed_test_pattern = re.compile(
            r"^(FAILED|ERROR)\s+([\w/.\-]+\.py)::(.*?)(?:\s+-\s+.*)?$"
        )

        in_multiline_summary = False

        for raw in self.lines:
            line = self.clean_line(raw)

            # Multi-line summary header: "Results (130.14s):"
            ml_header = multiline_header_pattern.search(line)
            if ml_header:
                in_multiline_summary = True
                self.test_duration += float(ml_header.group("secs"))
                continue

            # Multi-line count line: "  12229 passed", "  456 skipped", etc.
            # Triggered by an explicit Results header OR by a bare "N passed" line.
            ml_count = multiline_count_pattern.match(line)
            if not in_multiline_summary and ml_count and ml_count.group("label").lower() == "passed":
                in_multiline_summary = True  # bare count block, no Results header

            if in_multiline_summary:
                if ml_count:
                    count = int(ml_count.group("count"))
                    label = ml_count.group("label").lower()
                    if label == "passed":
                        self.num_tests_passed += count
                    elif label == "failed":
                        self.num_tests_failed += count
                    elif label == "skipped":
                        self.num_tests_skipped += count
                    elif label == "xfailed":
                        self.num_tests_xfailed += count
                    elif label == "xpassed":
                        self.num_tests_xpassed += count
                    self.num_tests_run += count
                    continue
                else:
                    in_multiline_summary = False

            short_summary = short_summary_pattern.search(line)
            if short_summary:
                self.short_summary = True
                continue

            if self.short_summary:
                failed_test = failed_test_pattern.search(line)
                if failed_test:
                    self.tests_failed.append(
                        {
                            "file": failed_test.group(2),
                            "function": failed_test.group(3).strip()
                        }
                    )

            pytest_pattern_ = pytest_pattern.search(line)

            if pytest_pattern_:
                self.short_summary = False
                failed_n   = int(pytest_pattern_.group("failed")   or 0)
                passed_n   = int(pytest_pattern_.group("passed")   or 0)
                skipped_n  = int(pytest_pattern_.group("skipped")  or 0)
                xfailed_n  = int(pytest_pattern_.group("xfail")    or 0)
                xpassed_n  = int(pytest_pattern_.group("xpass")    or 0)
                errors_n   = int(pytest_pattern_.group("errors")   or 0)

                # Skip zero-count summaries (regex false positives)
                if passed_n == 0 and failed_n == 0 and errors_n == 0:
                    continue

                # Deduplicate: skip exact retry (same passed+failed seen before)
                sig = (passed_n, failed_n + errors_n, skipped_n)
                if sig in self._seen_summaries:
                    continue
                self._seen_summaries.add(sig)

                self.num_tests_failed  += failed_n + errors_n
                self.num_tests_passed  += passed_n
                self.num_tests_skipped += skipped_n
                self.num_tests_xfailed += xfailed_n
                self.num_tests_xpassed += xpassed_n
                self.num_tests_run     += failed_n + errors_n + passed_n + skipped_n + xfailed_n + xpassed_n
                self.test_duration     += float(pytest_pattern_.group("secs"))
                
        return {
            "framework": self.framework,
            "num_tests_run": self.num_tests_run,
            "num_tests_failed": self.num_tests_failed,
            "num_tests_passed": self.num_tests_passed,
            "num_tests_skipped": self.num_tests_skipped,
            "num_tests_xfailed": self.num_tests_xfailed,
            "num_tests_xpassed": self.num_tests_xpassed,
            "tests_failed": self.tests_failed,
            "tests_skipped": self.tests_skipped,
            "test_duration": self.test_duration
        }
        
class UnitTestLogAnalyzer(BaseLogAnalyzer):
    def __init__(self, lines):
            super().__init__(lines)
            self.framework = "unittest"
            self.num_tests_xfailed = 0
            self.tests_xfailed = []
            self.num_tests_xpassed = 0
            self.tests_xpassed = []
            self.num_tests_deselected = 0
            self.short_summary = False
            
    def is_applicable(self):
        for raw in self.lines:
            line = self.clean_line(raw)
            if (
                "libregrtest" in line.lower()
                or "== tests result:" in line.lower()
                or line.startswith("Total tests:")
                or line.startswith("Total duration:")
                or line.startswith("running ")
                or re.match(r'^Ran \d+ tests? in [\d.]+s', line)
                or re.match(r'^(FAILED|OK)\s*(\(|$)', line)
            ):
                return True
        return False

    def analyze(self):
        passed_pattern = re.compile(r"(\d+)\s+tests\s+OK", re.IGNORECASE)
        # Total test files: run=498/497 failed=3 skipped=16 resource_denied=2 rerun=3
        # Total duration: 8 min 46 sec
        duration_pattern = re.compile(r"Total duration: (\d+\s*)(min)?\s*(\d+\s*)(sec)?", re.IGNORECASE)
        test_summary_pattern = re.compile(
            r"^Total\s+test\s+files:\s*"
            r"run=(?P<run>\d+)(?:/(?P<total>\d+))?\s*"
            r"(?:failed=(?P<failed>\d+)\s*)?"
            r"(?:skipped=(?P<skipped>\d+)\s*)?"
            r"(?:resource_denied=(?P<resdeny>\d+)\s*)?"
            r"(?:rerun=(?P<rerun>\d+)\s*)?",
            re.IGNORECASE
        )
        # "Ran 5481 tests in 759.463s"  or  "Ran 501 tests in 577.317 seconds"
        ran_pattern = re.compile(r'^Ran (?P<run>\d+) tests? in (?P<secs>[\d.]+)\s*s(?:econds?)?', re.IGNORECASE)
        # "FAILED (failures=2, errors=1, skipped=6)"  or  "FAILED (failures = 1)"  or  "OK"
        result_pattern = re.compile(
            r'^(?P<verdict>FAILED|OK)'
            r'(?:\s*\('
            r'(?:failures\s*=\s*(?P<failures>\d+),?\s*)?'
            r'(?:errors\s*=\s*(?P<errors>\d+),?\s*)?'
            r'(?:skipped\s*=\s*(?P<skipped>\d+),?\s*)?'
            r'\))?',
            re.IGNORECASE
        )
        # "FAIL: test_name (module.Class.method)"
        # "ERROR: test_name (module.Class.method)"
        failed_test_pattern = re.compile(r'^(?:FAIL|ERROR):\s+(\S+)\s+\(([^)]+)\)')
        for raw in self.lines:

            line = self.clean_line(raw)

            ran_m = ran_pattern.match(line)
            if ran_m:
                self.num_tests_run = int(ran_m.group("run"))
                self.test_duration = float(ran_m.group("secs"))
                continue

            result_m = result_pattern.match(line)
            if result_m:
                failures = int(result_m.group("failures") or 0)
                errors   = int(result_m.group("errors")   or 0)
                skipped  = int(result_m.group("skipped")  or 0)
                self.num_tests_failed  = failures + errors
                self.num_tests_skipped = skipped
                self.num_tests_passed  = max(0, self.num_tests_run - self.num_tests_failed - skipped)
                continue

            fail_m = failed_test_pattern.match(line)
            if fail_m:
                self.tests_failed.append({
                    "function": fail_m.group(1),
                    "file": fail_m.group(2),
                })
                continue

            passed_pattern_ = passed_pattern.search(line)
            if passed_pattern_:
                self.num_tests_passed = int(passed_pattern_.group(1))

            test_summary_pattern_ = test_summary_pattern.search(line)
            if test_summary_pattern_:
                self.num_tests_run = int(test_summary_pattern_.group("total"))
                failed_test_num = test_summary_pattern_.group("failed")
                if failed_test_num:
                    self.num_tests_failed = int(failed_test_num)
                skipped_tests_num = test_summary_pattern_.group("skipped")
                res_denied = test_summary_pattern_.group("resdeny")
                if skipped_tests_num or res_denied:
                    skipped = int(skipped_tests_num) if skipped_tests_num else 0
                    resource_denied = int(res_denied) if res_denied else 0
                    self.num_tests_skipped = skipped + resource_denied

            duration_pattern_ = duration_pattern.search(line)
            if duration_pattern_:
                minutes = float(duration_pattern_.group(1)) if duration_pattern_.group(1) else 0
                secs = float(duration_pattern_.group(3)) if duration_pattern_.group(3) else 0
                self.test_duration = (minutes * 60) + secs
                
                
                    
        return {
            "framework": self.framework,
            "num_tests_run": self.num_tests_run,
            "num_tests_failed": self.num_tests_failed,
            "num_tests_passed": self.num_tests_passed,
            "num_tests_skipped": self.num_tests_skipped,
            "num_tests_xfailed": self.num_tests_xfailed,
            "num_tests_xpassed": self.num_tests_xpassed,
            "tests_failed": self.tests_failed,
            "tests_skipped": self.tests_skipped,
            "test_duration": self.test_duration
        }    
                
            
        
             
# def detect_analyzer(log_lines):
#     analyzers = [
#         PytestLogAnalyzer,
#         UnitTestLogAnalyzer
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
                
                
