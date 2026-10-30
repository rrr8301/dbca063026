"""GWA-v3: GWA-v2 plus Shell-Aware Dependency Analysis (gwa_shell.py).

`run:` scripts are parsed (tree-sitter-bash; lexical PowerShell and cmd) into
a Shell Command IR, and the files, checkouts and package environments the
commands read, write or install become graph edges with provenance and a
confidence. The slicing policy is GWA-v2's: no step is removed for shell
reasons; the dependency graph is what gets more precise.
"""
from .gwa import GraphWorkflowAnalyzer  # noqa: F401
