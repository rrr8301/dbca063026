"""GWA-v1: Graph Workflow Analyzer, the conservative baseline.

Every step of the target job is kept; conditions are recorded but not
evaluated. This is the code frozen as gwa_eval/frozen/gwa_v1 (tag
gwa-v1-baseline); only its imports were made package-relative.
"""
from .gwa import GraphWorkflowAnalyzer  # noqa: F401
