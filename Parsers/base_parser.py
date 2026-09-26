import re
import abc

# class BaseParser(abc.ABC):
#     def __init__(self, primary_language, lines, job_id):
#         self.primary_language = primary_language
#         self.job_id = job_id
#         self.lines = lines
#         self.test_lines = []
#         self.frameworks = []
#         self.tests_run = False
#         self.tests_failed = []
#         self.initialized_tests = False
#         self.err_msg = []
#         self.err_lines = []
#         self.connection_lines = []
        
#     def add_framework(self, framework):
#         if framework not in self.frameworks:
#             self.frameworks.append(framework)

#     # pre-init values so we can sum-up in case of aggregated test sessions (always use calc_ok_tests when you use this)
#     def init_tests(self):
#         if not self.initialized_tests:
#             self.test_duration = 0
#             self.num_tests_run = 0
#             self.num_tests_failed = 0
#             self.num_tests_ok = 0
#             self.num_tests_skipped = 0
#             self.initialized_tests = True
            
#     @staticmethod
#     def convert_plain_time_to_seconds(s):
#         match = re.search(r'(.+)s', s, re.M)
#         if match:
#             return round(float(match.group(1)), 2)
#         return 0
    
#     def uninit_ok_tests(self):
#         if hasattr(self, 'num_tests_run') and hasattr(self, 'num_tests_failed'):
#             self.num_tests_ok += self.num_tests_run - self.num_tests_failed


class BaseLogAnalyzer:
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

    def analyze(self):
        raise NotImplementedError("Subclasses should implement this method")
    
    def is_applicable(self):
        """Our Analyzers can override this and use to check logs searching for something unique to them 
        and determine if the logfile applies to them"""
        return False            
    