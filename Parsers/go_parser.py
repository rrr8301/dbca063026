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

        
class GoLogAnalyzer(BaseLogAnalyzer):
    def __init__(self, lines):
        super().__init__(lines)
        self.framework = "Go"
        
    def is_applicable(self):
        # Require Go-specific signals to avoid false positives on JS/TS/Vitest output.
        # Vitest also emits "FAIL path/to/file.js [...]" which matches the generic pattern,
        # but Go import paths never end with a JS/TS file extension.
        js_ts_ext = re.compile(r'\.(js|ts|jsx|tsx|mjs|cjs|mts|cts)\b', re.IGNORECASE)
        go_markers = re.compile(r'=== RUN\b|--- PASS:\s|--- FAIL:\s|\bgo test\b', re.IGNORECASE)
        go_pkg_re  = re.compile(r'^\s*(?:ok|FAIL)\s+(\S+)(?:\s+\d+(?:\.\d+)?s\b|\s+\[(?:no test files|build failed|setup failed)\])', re.IGNORECASE)

        for raw in self.lines:
            line = self.clean_line(raw)
            if go_markers.search(line):
                return True
            m = go_pkg_re.match(line)
            # Go package paths never start with '[' — that's a nextest timing block
            if m and not js_ts_ext.search(m.group(1)) and not m.group(1).startswith('['):
                return True
        return False
    
    
    def get_int_from_match(self, match):
        return int(re.sub(r'\D', '', match)) if match else 0
    
    def count_go_tests(self, pattern):
        names = []
        for raw in self.lines:
            line = self.clean_line(raw)
            m = pattern.search(line)
            if m:
                names.append(m.group("name"))

        names_set = set(names)

        # 2. Count only those names that are NOT parents of another test
        leaf_names = []
        for name in names_set:
            is_parent = any(
                other != name and other.startswith(name + "/")
                for other in names_set
            )
            if not is_parent:
                leaf_names.append(name)

        return len(leaf_names)
    
    def analyze(self):
        go_run_tests       = re.compile(r'^=== RUN\s+(?P<name>\S+)', re.IGNORECASE)
        go_pass_tests      = re.compile(r'^\s*---\s+PASS:\s+(?P<name>\S+)\s+\((?P<secs>\d+(?:\.\d+)?)s\)', re.IGNORECASE)
        go_fail_ind_tests  = re.compile(r'^\s*---\s+FAIL:\s+(?P<name>\S+)\s+\((?P<secs>\d+(?:\.\d+)?)s\)', re.IGNORECASE)
        go_skip_tests      = re.compile(r'^\s*---\s+SKIP:\s+(?P<name>\S+)\s+\((?P<secs>\d+(?:\.\d+)?)s\)', re.IGNORECASE)
        # Exclude "FAIL Package ." (gotestsum format) — name must contain "/" or look like an import path
        go_fail_tests      = re.compile(r'^\s*FAIL\s+(?P<name>(?!\bPackage\b)\S+)\s+(.*)', re.IGNORECASE)
        go_pkg_result      = re.compile(r'^\s*(ok|FAIL)\s+(\S+)(?:\s+(\d+(?:\.\d+)?)s)?', re.IGNORECASE)

        gorace = GoRaceLogAnalyzer(self.lines)
        self.num_tests_run     += self.count_go_tests(go_run_tests)
        self.num_tests_passed  += self.count_go_tests(go_pass_tests)
        self.num_tests_failed  += self.count_go_tests(go_fail_ind_tests)
        # Only count --- SKIP: lines when GoRace is not present (else GoRace owns them)
        if not gorace.is_applicable():
            self.num_tests_skipped += self.count_go_tests(go_skip_tests)

        pkg_passed = 0
        pkg_failed = 0
        for raw in self.lines:
            line = self.clean_line(raw)

            m = go_pkg_result.match(line)
            if m and not m.group(2).startswith('['):
                if m.group(3) is not None:
                    self.test_duration += float(m.group(3))
                if m.group(1).lower() == "ok":
                    pkg_passed += 1
                else:
                    pkg_failed += 1

            m_ind = go_fail_ind_tests.search(line)
            if m_ind:
                self.tests_failed.append(m_ind.group('name'))
            elif go_fail_tests.search(line):
                self.tests_failed.append(go_fail_tests.search(line).group('name'))

        # Fall back to package-level counts when no individual =RUN= lines exist
        if self.num_tests_run == 0 and (pkg_passed + pkg_failed) > 0:
            self.num_tests_run    = pkg_passed + pkg_failed
            self.num_tests_passed = pkg_passed
            self.num_tests_failed = pkg_failed
        else:
            # Add package-level failures (build/setup failures with no === RUN lines) to counts.
            # Only count entries that look like import paths (contain "/") — individual test names don't.
            pkg_names = [t for t in self.tests_failed if '/' in t or t == '.']
            pkg_only_failures = max(0, len(pkg_names) - self.num_tests_failed)
            if pkg_only_failures > 0:
                self.num_tests_run    += pkg_only_failures
                self.num_tests_failed += pkg_only_failures
            # Ensure run >= failed + skipped (can happen when --- FAIL: exists but no === RUN)
            min_run = self.num_tests_failed + self.num_tests_skipped
            if self.num_tests_run < min_run:
                self.num_tests_run = min_run
            self.num_tests_passed = max(0, self.num_tests_run - self.num_tests_failed - self.num_tests_skipped)

        return {
            "framework":         self.framework,
            "num_tests_run":     self.num_tests_run,
            "num_tests_failed":  self.num_tests_failed,
            "num_tests_passed":  self.num_tests_passed,
            "num_tests_skipped": self.num_tests_skipped,
            "tests_failed":      self.tests_failed,
            "tests_skipped":     self.tests_skipped,
            "test_duration":     self.test_duration
        }
        
class GoRaceLogAnalyzer(BaseLogAnalyzer):
    def __init__(self, lines):
        super().__init__(lines)
        self.framework = "GoRace"
        
    def is_applicable(self):
        pattern = re.compile(
            r'^DONE\s+(?P<tests>\d+)\s+tests'
            r'(?:,\s+(?P<skipped>\d+)\s+skipped)?'
            r'(?:,\s+(?P<failed>\d+)\s+failures?)?'
            r'(?:,\s+(?P<errors>\d+)\s+errors?)?'
            r'\s+in\s+(?P<secs>\d+(?:\.\d+)?)s$', re.IGNORECASE
        )
        for raw in self.lines:
            if pattern.search(self.clean_line(raw)):
                return True
        return False
        
    
    def get_int_from_match(self, match):
        return int(re.sub(r'\D', '', match)) if match else 0
    
    def analyze(self):
        go_test_pattern = re.compile(
            r'^DONE\s+(?P<tests>\d+)\s+tests'
            r'(?:,\s+(?P<skipped>\d+)\s+skipped)?'
            r'(?:,\s+(?P<failed>\d+)\s+failures?)?'
            r'(?:,\s+(?P<errors>\d+)\s+errors?)?'
            r'\s+in\s+(?P<secs>\d+(?:\.\d+)?)s$', re.IGNORECASE
        )

        go_skip_tests = re.compile(r'^===\s+SKIP:\s+(?P<pkg>\S+)\s+(?P<test>\S+)\s+\((?P<secs>\d+(?:\.\d+)?)s\)$', re.IGNORECASE)
        go_fail_tests = re.compile(r'^===\s+FAIL:\s+(?P<pkg>\S+)\s+(?P<test>\S+)\s+\((?P<secs>\d+(?:\.\d+)?)s\)$', re.IGNORECASE)
        
        for raw in self.lines:
            line = self.clean_line(raw)
            go_test_line = go_test_pattern.search(line)
            if go_test_line:
                self.num_tests_run = int(go_test_line.group('tests'))
                if go_test_line.group('skipped'):
                    self.num_tests_skipped = int(go_test_line.group('skipped'))
                if go_test_line.group('failed'):
                    self.num_tests_failed = int(go_test_line.group('failed'))
                if go_test_line.group('errors'):
                    self.num_tests_failed += int(go_test_line.group('errors'))
                if go_test_line.group('secs'):
                    self.test_duration = float(go_test_line.group('secs'))
                    
            go_failed_line = go_fail_tests.search(line)
            if go_failed_line:
                self.tests_failed.append({
                    "file": go_failed_line.group("pkg"),
                    "test": go_failed_line.group("test")
                })
            go_skip_line = go_skip_tests.search(line)
            if go_skip_line:
                self.tests_skipped.append({
                    "file": go_skip_line.group("pkg"),
                    "test": go_skip_line.group("test")
                })
        
        self.num_tests_passed = max(0, self.num_tests_run - (self.num_tests_failed + self.num_tests_skipped))
                
        return {
            "framework": self.framework,
            "num_tests_run": self.num_tests_run,
            "num_tests_failed": self.num_tests_failed ,
            "num_tests_passed": self.num_tests_passed,
            "num_tests_skipped": self.num_tests_skipped,
            "tests_failed": self.tests_failed,
            "tests_skipped": self.tests_skipped,
            "test_duration": self.test_duration
        }    
    
        
class GotestfmtLogAnalyzer(BaseLogAnalyzer):
    """gotestfmt pretty-printer output for go test -json:

        ##[group]✅ TestFoo (1.2s)
        ##[group]❌ TestBar (0.5s)
        📦 github.com/foo/bar/pkg
        🛑 no test files
    """
    _PASS = re.compile(r'✅\s+(\S+)\s*\(([0-9.]+)(ms|s)\)')
    _FAIL = re.compile(r'❌\s+(\S+)\s*\(([0-9.]+)(ms|s)\)')
    _ANSI = re.compile(r'\x1B[@-_][0-?]*[ -/]*[@-~]', re.M)
    _TS   = re.compile(r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d+Z\s+')

    def __init__(self, lines):
        super().__init__(lines)
        self.framework = "gotestfmt"

    def _clean(self, line):
        return self.clean_line(line)

    def is_applicable(self):
        return any(self._PASS.search(self._clean(l)) or self._FAIL.search(self._clean(l)) for l in self.lines)

    def _duration_secs(self, val, unit):
        return float(val) / 1000 if unit == 'ms' else float(val)

    def analyze(self):
        seen_pass = set()
        seen_fail = set()
        for raw in self.lines:
            line = self._clean(raw)
            m = self._PASS.search(line)
            if m:
                name, val, unit = m.group(1), m.group(2), m.group(3)
                seen_pass.add(name)
                self.test_duration += self._duration_secs(val, unit)
                continue
            m = self._FAIL.search(line)
            if m:
                name, val, unit = m.group(1), m.group(2), m.group(3)
                seen_fail.add(name)
                self.tests_failed.append(name)
                self.test_duration += self._duration_secs(val, unit)

        # Only count leaf tests (not parents of subtests)
        all_names = seen_pass | seen_fail
        def is_leaf(name):
            return not any(other != name and other.startswith(name + '/') for other in all_names)

        self.num_tests_passed = sum(1 for n in seen_pass if is_leaf(n))
        self.num_tests_failed = sum(1 for n in seen_fail if is_leaf(n))
        self.num_tests_run    = self.num_tests_passed + self.num_tests_failed
        self.did_tests_fail   = self.num_tests_failed > 0
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
#         GoLogAnalyzer,
#         GoRaceLogAnalyzer
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

# log_lines = read_log_file("akvorado-56521597784.log")
    
# analyzer = detect_analyzer(log_lines)
    
# if analyzer:
#     results = analyzer.analyze()
#     print(results)
# else:
#     print("No applicable analyzer found for this log.")  