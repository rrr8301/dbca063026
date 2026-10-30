"""GWA-v2: GWA-v1 plus Static Condition Resolution (SCR).

`if:` conditions are evaluated against the run's static context (event,
branch, matrix, runner, literal env); statically FALSE steps are pruned from
the slice. conditions="off" disables SCR.
"""
from .gwa import GraphWorkflowAnalyzer  # noqa: F401
