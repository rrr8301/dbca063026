import re

class BaseLogAnalyzer:
    _ANSI_RE    = re.compile(r'\x1B[@-_][0-?]*[ -/]*[@-~]', re.M)
    _TS_RE      = re.compile(r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d+Z\s+')
    _ACT_RE     = re.compile(r'^\[[\w/ ._-]+\]\s{2,}(?:\|\s?)?')
    # Flink-style internal timestamp: "Mar 12 16:41:00 16:41:00.778 "
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
    
class JavaMavenLogAnalyser(BaseLogAnalyzer):
    def __init__(self, lines):
        super().__init__(lines)
        self.framework = "Maven"
        
    def is_applicable(self):
        return any(re.search(r'\bMaven\b', line, re.IGNORECASE) for line in self.lines)
    
    def get_int_from_match(self, match):
        return int(re.sub(r'\D', '', match)) if match else 0
    
    def extract_failed_tests(self):
        cur_test_class = ''
        current_run_failed = []
        build_pattern = re.compile(r"^\[INFO\]\s*BUILD\s+(SUCCESS|FAILURE|FAILED)", re.IGNORECASE)
        for raw in self.lines:
            line = self.clean_line(raw)
            # Reset on new BUILD — keep only the last run's failed tests
            if build_pattern.search(line):
                if current_run_failed:
                    self.tests_failed = list(current_run_failed)
                current_run_failed = []
                cur_test_class = ''
                continue
            # Matches the likes of:
            # Tests run: 11, Failures: 2, Errors: 0, Skipped: 0, Time elapsed: 0.1 sec <<< FAILURE! - in path.to.TestCls
            match = re.search(r'<<< FAILURE! --? in ([\w\.]+)', line, re.M)
            if match:
                cur_test_class = match.group(1)
            elif match := re.match(r'(?:\[INFO\] )?Running ([\w\.]+)$', line, re.M):
                cur_test_class = match.group(1)
            elif re.search(r'(<<< FAILURE!?|<<< ERROR!?)\s*$', line, re.M):
                re_log_error = r'(?:(?:\d+ )?\[ERROR\] )'
                # Matches the path to the test class.
                # The [secure] part is an edge case; see test_maven_5 in the Travis analyzer tests.
                re_test_class = r'(?:[\w$]+(?:\.(?:[\w$]+|\[secure\]))*)'
                # Matches the test method's name.
                # EDGE CASE: Some artifacts (e.g. square-moshi-610576045) write their tests in Kotlin, which allows
                # spaces in method names.
                re_method_name = r'(?:[\w$ ]+)'
                # Matches parameterized test info. There are three variants depending on the test runner:
                # junit4: methodName[1], methodName[<arbitrary string>]
                # juint5: methodName(float, String)[1] or methodName{ArgumentsAccessor}[1]
                # testng: methodName[3.5, foo](1)
                re_method_params = r'(?:\[.+\]|(?:\([\w, ]*\)|\{ArgumentsAccessor\})\[\d+\]|\[.*\]\(\d+\))'
                re_time_elapsed = r'(?:(?:--)? Time elapsed:)'
                failedtest = None

                # Matches the likes of [ERROR] testMethod(path.to.testClass)  Time elapsed: 0.022 s  <<< ERROR!
                # Sets failedtest to 'testMethod(path.to.testClass)'
                regex = r'{}?({}{}?\({}\)) {}'.format(re_log_error, re_method_name,
                                                      re_method_params, re_test_class, re_time_elapsed)
                match = re.match(regex, line, re.M)
                if match:
                    failedtest = match.group(1)
                if failedtest is None:
                    # Matches the likes of [ERROR] testMethod  Time elapsed: 0.011 sec  <<< FAILURE!
                    # Assuming that cur_test_class == 'path.to.TestCls', sets failedtest = 'testMethod(path.to.TestCls)'
                    regex = r'{}?({}{}?) {}'.format(re_log_error, re_method_name, re_method_params, re_time_elapsed)
                    match = re.match(regex, line, re.M)
                    if match:
                        failedtest = match.group(1) + '(' + cur_test_class + ')'
                if failedtest is None and cur_test_class:
                    # Matches the likes of [ERROR] path.to.TestClass  Time elapsed: 0.011 sec  <<< FAILURE!
                    # Sets failedtest to (path.to.TestClass)
                    regex = r'{}?{} {}'.format(re_log_error, re.escape(cur_test_class), re_time_elapsed)
                    match = re.match(regex, line, re.M)
                    if match:
                        failedtest = '(' + cur_test_class + ')'
                if failedtest is None:
                    # Matches the likes of [ERROR] path.to.TestClass.testMethod  Time elapsed: 0.011 sec  <<< FAILURE!
                    # This sets failedtest to 'testMethod(path.to.TestClass)'
                    regex = r'{}?({})\.({}{}?) {}'.format(
                        re_log_error, re_test_class, re_method_name, re_method_params, re_time_elapsed
                    )
                    match = re.match(regex, line, re.M)
                    if match:
                        failedtest = match.group(2) + '(' + match.group(1) + ')'
                if failedtest is None:
                    # Matches the likes of [ERROR] path.to.TestClass  Time elapsed: 0.011 sec  <<< FAILURE!
                    # This condition is only reached if the name of the test method is not present in the log.
                    # This sets failedtest to '(path.to.TestClass)'
                    match = re.search(r'^(\[ERROR\] )?([\w.]+)( --)? Time elapsed:', line, re.M)
                    if match:
                        failedtest = '(' + match.group(2) + ')'
                if failedtest is not None:
                    current_run_failed.append(failedtest)
        # Flush any trailing run that had no BUILD marker
        if current_run_failed:
            self.tests_failed = current_run_failed
    
    def analyze(self):
        result_block_start = False
        result_block_pattern = re.compile(r"(\[INFO\])?\s*Results", re.IGNORECASE)
        # Summary line (after Results: block) — no trailing content
        result_pattern = re.compile(
            r"^(?:\[(?:INFO|WARNING|ERROR)\]\s*)?"
            r"Tests\s+run:\s*(?P<run>\d+),\s*"
            r"Failures:\s*(?P<failures>\d+),\s*"
            r"Errors:\s*(?P<errors>\d+),\s*"
            r"Skipped:\s*(?P<skipped>\d+)\s*$",
            re.IGNORECASE
        )
        # Per-class line (no Results block) — has Time elapsed + -- in ClassName
        perclass_pattern = re.compile(
            r"^(?:\[(?:INFO|WARNING|ERROR)\]\s*)?"
            r"Tests\s+run:\s*(?P<run>\d+),\s*"
            r"Failures:\s*(?P<failures>\d+),\s*"
            r"Errors:\s*(?P<errors>\d+),\s*"
            r"Skipped:\s*(?P<skipped>\d+),\s*"
            r"Time elapsed:.*--\s+in\s+",
            re.IGNORECASE
        )
        build_pattern = re.compile(
            r"^\[INFO\]\s*BUILD\s+(SUCCESS|FAILURE|FAILED)",
            re.IGNORECASE
        )
        duration_pattern = re.compile(
            r"^\[(?P<level>INFO|WARNING|ERROR)\]\s*"
            r"Total\s+time:\s*(?P<minutes>\d{1,2}):(?P<seconds>\d{2})\s*(min|hrs?)",
            re.IGNORECASE
        )

        compile_error_hdr = re.compile(r'\[ERROR\]\s+COMPILATION ERROR\s*:', re.IGNORECASE)
        compile_error_line = re.compile(r'\[ERROR\]\s+(/\S+\.java:\[[\d,]+\]\s+.+)',  re.IGNORECASE)
        compile_error_count= re.compile(r'\[INFO\]\s+(\d+)\s+errors?',               re.IGNORECASE)

        # Accumulate per-run then keep only the last complete run
        run_tests = run_failed = run_skipped = 0
        run_duration = 0.0
        # Track per-class counts since last Results: block to subtract when summary arrives
        module_tests = module_failed = module_skipped = 0
        in_compile_block = False
        compile_errors = []
        compile_count  = 0

        for raw in self.lines:
            line = self.clean_line(raw)

            # New BUILD marker → commit current run and reset for next run
            if build_pattern.search(line):
                if run_tests > 0:
                    self.num_tests_run = run_tests
                    self.num_tests_failed  = run_failed
                    self.num_tests_skipped = run_skipped
                    self.test_duration = run_duration
                # Commit compile errors for this run (used as fallback if no tests ran)
                self._last_compile_errors = list(compile_errors)
                self._last_compile_count  = compile_count
                run_tests = run_failed = run_skipped = 0
                run_duration = 0.0
                module_tests = module_failed = module_skipped = 0
                result_block_start = False
                in_compile_block = False
                compile_errors = []
                compile_count  = 0
                continue

            if compile_error_hdr.search(line):
                in_compile_block = True
                continue

            if in_compile_block:
                m = compile_error_line.search(line)
                if m:
                    compile_errors.append(m.group(1).strip())
                    continue
                m = compile_error_count.search(line)
                if m:
                    compile_count = int(m.group(1))
                    in_compile_block = False
                    continue

            if result_block_pattern.search(line):
                result_block_start = True
                continue

            if result_block_start:
                result = result_pattern.search(line)
                if result:
                    # Subtract per-class counts already added for this module,
                    # then add the authoritative Results: summary count instead
                    run_tests   = run_tests   - module_tests   + int(result.group("run"))
                    run_failed  = run_failed  - module_failed  + int(result.group("failures")) + int(result.group("errors"))
                    run_skipped = run_skipped - module_skipped + int(result.group("skipped"))
                    module_tests = module_failed = module_skipped = 0
                    result_block_start = False
            else:
                pc = perclass_pattern.search(line)
                if pc:
                    t = int(pc.group("run"))
                    f = int(pc.group("failures")) + int(pc.group("errors"))
                    s = int(pc.group("skipped"))
                    run_tests   += t
                    run_failed  += f
                    run_skipped += s
                    module_tests   += t
                    module_failed  += f
                    module_skipped += s

            duration = duration_pattern.search(line)
            if duration:
                mm = int(duration.group("minutes"))
                ss = int(duration.group("seconds"))
                run_duration = float(mm * 60 + ss)

        # If no BUILD line was seen, use whatever accumulated
        if run_tests > 0:
            self.num_tests_run = run_tests
            self.num_tests_failed = run_failed
            self.num_tests_skipped = run_skipped
            self.test_duration = run_duration

        # Use last committed compile errors if trailing run had no BUILD marker
        last_compile_errors = compile_errors or getattr(self, '_last_compile_errors', [])
        last_compile_count  = compile_count  or getattr(self, '_last_compile_count',  0)

        # Fall back to compilation errors when no tests ran
        has_compile_error   = bool(last_compile_errors or last_compile_count)
        num_compile_errors  = last_compile_count or len(last_compile_errors)
        compile_errors_list = last_compile_errors

        if self.num_tests_run == 0 and has_compile_error:
            self.num_tests_failed = num_compile_errors
            self.num_tests_run    = self.num_tests_failed
            self.tests_failed     = compile_errors_list
            self.did_tests_fail   = True

        self.num_tests_passed = self.num_tests_run - (self.num_tests_failed + self.num_tests_skipped)
        self.extract_failed_tests()

        return {
            "framework": self.framework,
            "num_tests_run": self.num_tests_run,
            "num_tests_failed": self.num_tests_failed,
            "num_tests_passed": self.num_tests_passed,
            "num_tests_skipped": self.num_tests_skipped,
            "tests_failed": self.tests_failed,
            "tests_skipped": self.tests_skipped,
            "test_duration": self.test_duration,
            "compilation_error": has_compile_error,
            "num_compilation_errors": num_compile_errors,
            "compilation_errors": compile_errors_list,
        }
        

class JavaGradleLoganalyzer(BaseLogAnalyzer):
    def __init__(self, lines):
        super().__init__(lines)
        self.framework = "Gradle"
        self.num_tasks_executed = 0
        self.num_tasks_uptodate = 0
        
    def is_applicable(self):
        return any(re.search(r'\bGradle\b', line, re.IGNORECASE) for line in self.lines) or \
               any(re.search(r'^BUILD\s+(SUCCESSFUL|FAILED)\s+in\s+', line, re.IGNORECASE) for line in self.lines)

    def convert_gradle_time_to_seconds(s):
        match = re.search(r'((\d+) mins)? (\d+)(\.\d+) secs', s, re.M)
        if match:
            # If we have minute, we add 60 * minutes to the seconds, final unit is seconds
            return int(match.group(3)) if match.group(2) is None else int(match.group(2)) * 60 + int(match.group(3))

        match = re.search(r'((\d+)m )?(\d+)s', s, re.M)
        if match:
            # If we have minute, we add 60 * minutes to the seconds, final unit is seconds
            # print(match)
            return int(match.group(3)) if match.group(2) is None else int(match.group(2)) * 60 + int(match.group(3))

        return 0
    
    def analyze(self):
        compile_error_hdr  = re.compile(r'\[ERROR\]\s+COMPILATION ERROR\s*:', re.IGNORECASE)
        compile_error_line = re.compile(r'\[ERROR\]\s+(/\S+\.java:\[[\d,]+\]\s+.+)',  re.IGNORECASE)
        compile_error_count= re.compile(r'\[INFO\]\s+(\d+)\s+errors?',               re.IGNORECASE)
        in_compile_block = False
        compile_errors = []
        compile_count  = 0

        # Counters for individual test result lines (fallback when no summary exists)
        indiv_passed  = 0
        indiv_failed  = 0
        indiv_skipped = 0
        indiv_pattern = re.compile(
            r'^([\w$.]+(?:\s*>\s*[^>]+?)*?)\s+(PASSED|FAILED|SKIPPED)\s*$',
            re.IGNORECASE
        )
        has_summary = False  # set True when a "N tests completed" summary line is seen

        for raw in self.lines:
            line = self.clean_line(raw)

            if compile_error_hdr.search(line):
                in_compile_block = True
                continue

            if in_compile_block:
                m = compile_error_line.search(line)
                if m:
                    compile_errors.append(m.group(1).strip())
                    continue
                m = compile_error_count.search(line)
                if m:
                    compile_count = int(m.group(1))
                    in_compile_block = False
                    continue

            match = re.search(r'(\d+) tests completed(, (\d+) failed)?(, (\d+) skipped)?', line, re.M)
            if match:
                run     = int(match.group(1))
                failed  = int(match.group(3)) if match.group(3) else 0
                skipped = int(match.group(5)) if match.group(5) else 0
                passed  = run - failed - skipped
                self.num_tests_run     += run
                self.num_tests_failed  += failed
                self.num_tests_skipped += skipped
                self.num_tests_passed  += passed
                if failed > 0:
                    self.did_tests_fail = True
                has_summary = True
                continue
            
            match = re.search(r'^Total tests run: (\d+), Failures: (\d+), Skips: (\d+)', line, re.M)
            if match:
                self.num_tests_run += int(match.group(1))
                self.num_tests_failed += int(match.group(2))
                self.num_tests_skipped += int(match.group(3))
                continue
            
            # Gradle Test Run :core:S3UnitTest > Gradle Test Executor 14 > EventTest > testCommitRequestCodec() PASSED
            # Gradle Test Run :core:S3UnitTest > Gradle Test Executor 14 > ElasticReplicaManagerTest > testReplicaNotAvailable() SKIPPED
            # BUILD SUCCESSFUL in 5m 25s
            match = re.search(r'^Gradle\s*Test\s*Run\s*:(.*) > (.*) > (.*) > (.*) (PASSED|SKIPPED|FAILED)', line, re.M)
            if match:
                test_class = match.group(3)
                test_function = match.group(4)
                p_s_f = match.group(5)
                if p_s_f == 'PASSED':
                    self.num_tests_passed += 1
                    self.num_tests_run += 1
                elif p_s_f == "SKIPPED":
                    self.num_tests_skipped += 1
                    self.num_tests_run += 1
                    self.tests_skipped.append(test_class + '.' + test_function)
                elif p_s_f == "FAILED":
                    self.num_tests_failed += 1
                    self.num_tests_run += 1
                    self.tests_failed.append(test_class + '.' + test_function)
                continue
            
            # ClassName > method PASSED/FAILED/SKIPPED  (e.g. selenide, ambry)
            # Collect names and counts — counts are used as fallback if no summary line exists
            indiv_m = indiv_pattern.search(line)
            if indiv_m:
                status = indiv_m.group(indiv_m.lastindex).upper()
                parts  = indiv_m.group(0).rsplit(None, 1)
                name   = parts[0].strip() if len(parts) > 1 else indiv_m.group(1).strip()
                # Extract class and method from "ClassName > method"
                segs = [s.strip() for s in name.split('>')]
                cls  = segs[0] if segs else name
                mth  = segs[-1] if len(segs) > 1 else ''
                if status == 'PASSED':
                    indiv_passed += 1
                elif status == 'FAILED':
                    indiv_failed += 1
                    entry = {"file": cls, "function": mth}
                    if entry not in self.tests_failed:
                        self.tests_failed.append(entry)
                elif status == 'SKIPPED':
                    indiv_skipped += 1
                    self.tests_skipped.append(f'{cls}.{mth}')
                continue

            # :module:submodule:test (SUCCESS): 76 tests, 4 skipped
            # :module:submodule:test (FAILED): 76 tests, 4 skipped, 2 failures
            match = re.search(
                r'^:\S+:test\s+\((SUCCESS|FAILED)\):\s+(\d+)\s+tests?'
                r'(?:,\s+(\d+)\s+skipped)?(?:,\s+(\d+)\s+failures?)?',
                line, re.M
            )
            if match:
                total   = int(match.group(2))
                skipped = int(match.group(3)) if match.group(3) else 0
                failed  = int(match.group(4)) if match.group(4) else 0
                passed  = total - skipped - failed
                self.num_tests_run     += total
                self.num_tests_skipped += skipped
                self.num_tests_failed  += failed
                self.num_tests_passed  += passed
                if failed > 0:
                    self.did_tests_fail = True
                continue

            # N actionable tasks: X executed, Y up-to-date
            match = re.search(r'(\d+)\s+actionable\s+tasks?:\s+(\d+)\s+executed', line, re.M)
            if match:
                self.num_tasks_executed = int(match.group(2))
                uptodate = re.search(r'(\d+)\s+up-to-date', line)
                self.num_tasks_uptodate = int(uptodate.group(1)) if uptodate else 0
                continue

            match = re.search(r'BUILD\s+(FAILED|SUCCESSFUL)\s+in\s+(.*)', line, re.M)
            if match:
                self.did_tests_fail = match.group(1).upper() == 'FAILED'
                self.test_duration += JavaGradleLoganalyzer.convert_gradle_time_to_seconds(match.group(2))
            # 2221 passing (2m 20s)
            # 73 pending
            match = re.search(r'^\s*(\d+)\s+passing\s*\(\s*(?:(\d+)m)?\s*(?:(\d+(?:\.\d+)?)s)?\s*\)\s*$', line, re.M)
            if match:
                self.num_tests_passed += int(match.group(1))
                self.num_tests_run += int(match.group(1))
                # hr = 0.0 if match.group(2) is None else float(match.group(2))
                mm = 0.0 if match.group(2) is None else float(match.group(2))
                sec = 0.0 if match.group(3) is None else float(match.group(3))
                self.test_duration += (mm*60) + sec
                
            match = re.search(r'\s*(\d+)\s*pending', line, re.M)
            if match:
                self.num_tests_skipped += int(match.group(1))
                self.num_tests_run += int(match.group(1))

        # If no summary line was seen, fall back to individual PASSED/FAILED/SKIPPED counts
        if not has_summary and (indiv_passed + indiv_failed + indiv_skipped) > 0:
            self.num_tests_passed  = indiv_passed
            self.num_tests_failed  = indiv_failed
            self.num_tests_skipped = indiv_skipped
            self.num_tests_run     = indiv_passed + indiv_failed + indiv_skipped
            if indiv_failed > 0:
                self.did_tests_fail = True

        # Fall back to compilation errors when no tests ran
        has_compile_error   = bool(compile_errors or compile_count)
        num_compile_errors  = compile_count or len(compile_errors)
        compile_errors_list = compile_errors

        if self.num_tests_run == 0 and has_compile_error:
            self.num_tests_failed = num_compile_errors
            self.num_tests_run    = self.num_tests_failed
            self.tests_failed     = compile_errors_list
            self.did_tests_fail   = True

        return {
            "framework":              self.framework,
            "num_tests_run":          self.num_tests_run,
            "num_tests_passed":       self.num_tests_passed,
            "num_tests_failed":       self.num_tests_failed,
            "num_tests_skipped":      self.num_tests_skipped,
            "tests_failed":           self.tests_failed,
            "tests_skipped":          self.tests_skipped,
            "test_duration":          self.test_duration,
            "compilation_error":      has_compile_error,
            "num_compilation_errors": num_compile_errors,
            "compilation_errors":     compile_errors_list,
            "num_tasks_executed":     self.num_tasks_executed,
            "num_tasks_uptodate":     self.num_tasks_uptodate,
            "did_tests_fail":         self.did_tests_fail,
        }
    
    
        
# def detect_analyzer(log_lines):
#     analyzers = [
#         JavaMavenLogAnalyser,
#         JavaGradleLoganalyzer
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

# log_lines = read_log_file("automq-55904790251.log")
    
# analyzer = detect_analyzer(log_lines)
    
# if analyzer:
#     results = analyzer.analyze()
#     print(results)
# else:
#     print("No applicable analyzer found for this log.")          