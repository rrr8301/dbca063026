import re

from ...utils.common import log
from ..base_parser import BaseParser

class JavaMavenParser(BaseParser):
    def __init__(self, primary_language, lines, job_id):
        super().__init__(primary_language, lines, job_id)
        self.reactor_lines = []
        self.tests_failed_lines = []
        self.parser = 'java-maven'
        self.build_system = 'Maven'
        
        
    def extract_tests(self):
        test_selection_started = False
        reactor_started = False
        line_marker = 0
        
        for line in self.lines:
            if line[:7] == '[ERROR]':
                self.err_lines.append(line[8:])
            if '-------------------------------------------------------' in line and line_marker == 0:
                line_marker = 1
            elif re.search(r'\[INFO\] Reactor Summary(:| for)', line, re.M):
                reactor_started = True
                test_selection_started = False
            elif reactor_started and not re.search(r'\[.*\]', line, re.M):
                reactor_started = False
            elif re.search(r' T E S T S', line, re.M) and line_marker == 1:
                line_marker = 2
            elif line_marker == 1:
                match = re.search(r'Building ([^ ]*)', line, re.M)
                if match:
                    if match.group(1) and len(match.group(1).strip()) > 0:
                        pass
                line_marker = 0
            elif '-------------------------------------------------------' in line and line_marker == 2:
                line_marker = 3
                test_section_started = True
            elif '-------------------------------------------------------' in line and line_marker == 3:
                line_marker = 0
                test_section_started = False
            else:
                line_marker = 0

            if test_section_started:
                self.test_lines.append(line)
            elif reactor_started:
                self.reactor_lines.append(line)
                
    @staticmethod
    def convert_maven_time_to_seconds(string):
        match = re.search(r'((\d+)(\.\d*)?) s', string, re.M)
        if match:
            return round(float(match.group(1)), 2)
        match = re.search(r'(\d+):(\d+) min', string, re.M)
        if match:
            return int(match.group(1)) * 60 + int(match.group(2))
        return 0
    
    def analyze_reactor(self):
        # Same with Gradle and Ant. Only use the last build to calculate pure_build_duration
        reactor_time = 0
        for line in self.reactor_lines:
            match = re.search(r'\[INFO\] .*test.*? (\w+) \[ (.+)\]', line, re.I)
            if match:
                reactor_time += JavaMavenParser.convert_maven_time_to_seconds(match.group(2))
            match = re.search(r'Total time: (.+)', line, re.I)
            if match:
                self.pure_build_duration = JavaMavenParser.convert_maven_time_to_seconds(match.group(1))
        if not hasattr(self, 'test_duration') or (reactor_time > self.test_duration):
            # Search inside the reactor summary: if the subproject's name contains 'test', add its time to reactor_time
            self.test_duration = reactor_time
            
    @staticmethod
    def extract_test_method_name(string):
        # Matches line: testAcceptFileWithMaxSize on instance
        # testAcceptFileWithMaxSize(org.apache.struts2.interceptor.FileUploadInterceptorTest)
        # (org.apache.struts2.interceptor.FileUploadInterceptorTest)
        # Extracts test as: testAcceptFileWithMaxSize(org.apache.struts2.interceptor.FileUploadInterceptorTest)
        match = re.search(r'(\w+(\[.+\])?\([\w.$\[\]]+\))', string)
        if match:
            return match.group(1)

        # Matches line: TutorialSnippetsTestCase.testModularizationWithAtomicDecomposition:642 [...]
        # Also matches TestClass>BaseTestClass.testMethodInBaseClass:38
        # Extracts test as: testModularizationWithAtomicDecomposition(TutorialSnippetsTestCase)
        match = re.match(r'\s*([\w.>$]+)\.(\w+):', string)
        if match:
            return '{}({})'.format(match.group(2), match.group(1))
        return None

        
    def analyze_tests(self):
        failed_tests_started = False
        running_test = False
        curr_test = ''

        for line in self.test_lines:
            if re.search(r'(Failed tests:)|(Tests in error:)', line, re.M):
                failed_tests_started = True
            if failed_tests_started:
                self.tests_failed_lines.append(line)
                if 'tests run' in line.lower():
                    failed_tests_started = False

            match = re.search(r'Tests run: .*? Time elapsed: (.* s(ec)?)', line, re.M)
            if match:
                self.init_tests()
                self.tests_run = True
                self.add_framework('JUnit')
                self.test_duration += JavaMavenParser.convert_maven_time_to_seconds(match.group(1))
                continue

            # To calculate num_tests_run, num_tests_failed, num_tests_skipped,
            # We ignore lines like Tests run: %d, Failures: %d, Errors: %d, Skipped: %d, Time elapsed: %f s - in ...
            # We only match summary lines like
            # Results :
            # ...
            # Tests run: %d, Failures: %d, Errors: %d, Skipped: %d
            match = re.search(r'Tests run: (\d*), Failures: (\d*), Errors: (\d*)(, Skipped: (\d*))?', line, re.M)
            if match:
                running_test = False
                self.init_tests()
                self.add_framework('JUnit')
                self.tests_run = True
                self.num_tests_run += int(match.group(1))
                self.num_tests_failed += (int(match.group(2)) + int(match.group(3)))
                if match.group(4):
                    self.num_tests_skipped += int(match.group(5))
                continue

            # Added a space after Total tests run:, this differs from
            # TravisTorrent's original implementation. The observed output
            # of testng has a space. Consider updating the regex if we observe
            # a testng version that outputs whitespace differently.
            match = re.search(r'^Total tests run: (\d+), Failures: (\d+), Skips: (\d+)', line, re.M)
            if match:
                self.init_tests()
                self.add_framework('testng')
                self.tests_run = True
                self.num_tests_run += int(match.group(1))
                self.num_tests_failed += int(match.group(2))
                self.num_tests_skipped += int(match.group(3))
                continue

            if line[:8] == 'Running ':
                running_test = True
                curr_test = line[8:]

            if running_test and '(See full trace by running task with --trace)' in line:
                self.tests_failed.append(curr_test)

            # Adding cucumber testing framework.
            if 'exec rake cucumber' in line:
                self.add_framework('cucumber')

            match = re.search(r'cucumber (.*) # Scenario:', line, re.M)
            if match:
                self.tests_failed.append(match.group(1))
                continue
        self.uninit_ok_tests()
        
    def clean_err_msg(self):
        self.err_msg = [line for line in self.err_msg if len(line) >= 2 and line != '-> [Help 1]']
        
    def bool_tests_failed(self):
        if hasattr(self, 'tests_failed') and self.tests_failed:
            return True
        if hasattr(self, 'num_tests_failed') and self.num_tests_failed > 0:
            return True
        return False
    
    def extract_err_msg(self):
        new_arr = self.err_msg
        for line in self.err_lines:
            if len(line) > 49 and 'To see the full stack trace of the errors' in line:
                break
            else:
                new_arr.append(line)
        self.err_msg = new_arr
        self.clean_err_msg()
        
    def extract_failed_tests_from_tests_lines(self):
        cur_test_class = ''
        for line in self.test_lines:
            # Matches the likes of:
            # Tests run: 11, Failures: 2, Errors: 0, Skipped: 0, Time elapsed: 0.1 sec <<< FAILURE! - in path.to.TestCls
            match = re.search(r'<<< FAILURE! --? in ([\w\.]+)', line, re.M)
            if match:
                cur_test_class = match.group(1)
            elif match := re.match(r'(?:\[INFO\] )?Running ([\w\.]+)$', line, re.M):
                cur_test_class = match.group(1)
            elif re.search(r'(<<< FAILURE!|<<< ERROR!)\s*$', line, re.M):
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
                    self.tests_failed.append(failedtest)
