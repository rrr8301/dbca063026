import os
import sys
import json
import argparse

# Ensure LLM4Build root is on the path so Parsers/ can be imported
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

# Frameworks that are build systems, not test runners — excluded from all stats
BUILD_ONLY_FRAMEWORKS = {"Ninja", "ninja"}

from Parsers.javaParsers import JavaMavenLogAnalyser, JavaGradleLoganalyzer
from Parsers.pythonParser import PytestLogAnalyzer, UnitTestLogAnalyzer
from Parsers.rustParser import RustLogAnalyzer, NextTestLogAnalyzer
from Parsers.c_cpp_parser import (CTEST_LogAnalyzer, GTest_LogAnalyzer,
                                   GitTest_Loganalyzer, AutotoolsLogAnalyzer,
                                   ProveTAPLogAnalyzer, HardSoftErrorLogAnalyzer,
                                   BazelLogAnalyzer, Radare2LogAnalyzer,
                                   ShellTestLogAnalyzer, CatBoostLogAnalyzer,
                                   MesonLoganalyzer, MicroPythonLogAnalyzer,
                                   MRubyLogAnalyzer, PerlHarnessLogAnalyzer,
                                   ZstdTestLogAnalyzer,
                                   DuckDBLogAnalyzer, CCVLogAnalyzer,
                                   CapnProtoLogAnalyzer, MNNTestLogAnalyzer,
                                   UnityLogAnalyzer, LLVMLitLogAnalyzer,
                                   CsoundLogAnalyzer)
from Parsers.js_ts_parser import (JestLogAnalyzer, JasmineLogAnalyzer,
                                   MochaLogAnalyzer, TypeScriptLogAnalyzer,
                                   TAPLogAnalyzer, VitestLogAnalyzer,
                                   NodeTestLogAnalyzer, SummaryBlockLogAnalyzer,
                                   JTRLogAnalyzer, BunTestLogAnalyzer,
                                   PytestLogAnalyzer as JsPytestLogAnalyzer)
from Parsers.go_parser import GoLogAnalyzer, GoRaceLogAnalyzer, GotestfmtLogAnalyzer
from installation_file_list import has_tests_run


def detect_analyzer(log_lines):
    analyzers = [
        JavaMavenLogAnalyser,
        JavaGradleLoganalyzer,
        PytestLogAnalyzer,
        UnitTestLogAnalyzer,
        RustLogAnalyzer,
        NextTestLogAnalyzer,
        JasmineLogAnalyzer,
        JestLogAnalyzer,
        MochaLogAnalyzer,
        SummaryBlockLogAnalyzer,
        NodeTestLogAnalyzer,
        CTEST_LogAnalyzer,
        GTest_LogAnalyzer,
        GitTest_Loganalyzer,
        AutotoolsLogAnalyzer,
        MesonLoganalyzer,
        MRubyLogAnalyzer,
        MicroPythonLogAnalyzer,
        ProveTAPLogAnalyzer,
        HardSoftErrorLogAnalyzer,
        BazelLogAnalyzer,
        Radare2LogAnalyzer,
        ShellTestLogAnalyzer,
        ZstdTestLogAnalyzer,
        PerlHarnessLogAnalyzer,
        CatBoostLogAnalyzer,
        DuckDBLogAnalyzer,
        CCVLogAnalyzer,
        CapnProtoLogAnalyzer,
        MNNTestLogAnalyzer,
        VitestLogAnalyzer,
        BunTestLogAnalyzer,
        TAPLogAnalyzer,
        JTRLogAnalyzer,
        TypeScriptLogAnalyzer,
        GoLogAnalyzer,
        GoRaceLogAnalyzer,
        GotestfmtLogAnalyzer,
        JsPytestLogAnalyzer,
        UnityLogAnalyzer,
        LLVMLitLogAnalyzer,
        CsoundLogAnalyzer,
    ]
    applicable = []
    for AnalyzerClass in analyzers:
        analyzer = AnalyzerClass(log_lines)
        if analyzer.is_applicable():
            applicable.append(analyzer)
    return applicable if applicable else None


def find_original_log(out_dir):
    for fname in os.listdir(out_dir):
        if fname.endswith(".log") and fname != "log.txt":
            return os.path.join(out_dir, fname)
    return None


def count_attempts(project_dir):
    """Count run_N subdirectories in project_dir as the attempt number."""
    try:
        return sum(1 for e in os.listdir(project_dir)
                   if e.startswith("run_") and os.path.isdir(os.path.join(project_dir, e)))
    except OSError:
        return 0


def process_project(project_dir, build_status="passed", language=None, remaker=False, act=False, claude_code=False):
    out_dir = os.path.join(project_dir, "out")
    if not os.path.isdir(out_dir):
        return None, "no out/ directory"

    attempt_number = count_attempts(project_dir)

    # --- claude-code mode: same as remaker but if log.txt absent → ER=TR=FR=False ---
    if claude_code:
        llm_log_path = os.path.join(out_dir, "log.txt")
        log_txt_present = os.path.isfile(llm_log_path) and os.path.getsize(llm_log_path) > 0

        # If log.txt is absent or empty → all False, no parsing needed
        if not log_txt_present:
            out = {
                "ER": False, "TR": False, "FR": False,
                "attempt_number": attempt_number,
                "original_log_stats": [],
                "llm_log_stats": [],
            }
            if build_status == "failed":
                out.update({"Existence": False, "Number": False, "Name": False, "Status": False})
            out_path = os.path.join(out_dir, "summary.json")
            with open(out_path, "w") as f:
                json.dump(out, f, indent=2)
            return out_path, None

        # log.txt present → ER=True, parse like remaker
        return process_project(project_dir, build_status=build_status, language=language,
                               remaker=True, act=False, claude_code=False)

    # --- act mode: ER always False, TR based on log.txt, FR always False ---
    if act:
        llm_log_path = os.path.join(out_dir, "log.txt")
        llm_lines = []
        llm_log_stats = []
        original_log_stats = []

        log_txt_nonempty = os.path.isfile(llm_log_path) and os.path.getsize(llm_log_path) > 0
        if log_txt_nonempty:
            with open(llm_log_path, errors="replace") as f:
                llm_lines = f.readlines()
            llm_analyzers = detect_analyzer(llm_lines)
            if llm_analyzers:
                for a in llm_analyzers:
                    llm_log_stats.append(a.analyze())

        # Parse original log if present
        orig_log_path = find_original_log(out_dir)
        if orig_log_path:
            with open(orig_log_path, errors="replace") as f:
                orig_lines = f.readlines()
            orig_analyzers = detect_analyzer(orig_lines)
            if orig_analyzers:
                for a in orig_analyzers:
                    original_log_stats.append(a.analyze())

        tr = has_tests_run(llm_lines) if log_txt_nonempty else False
        if not log_txt_nonempty or not llm_log_stats:
            tr = False

        # Compute FR: same logic as main mode
        fr = False
        if llm_log_stats and original_log_stats:
            llm_by_fw  = {x.get("framework"): x for x in llm_log_stats
                          if x.get("framework") not in BUILD_ONLY_FRAMEWORKS}
            orig_by_fw = {x.get("framework"): x for x in original_log_stats
                          if x.get("framework") not in BUILD_ONLY_FRAMEWORKS}
            fw_fr = []
            for fw, orig_entry in orig_by_fw.items():
                llm_entry = llm_by_fw.get(fw, {})
                llm_run    = llm_entry.get("num_tests_run", 0)
                llm_failed = llm_entry.get("num_tests_failed", 0)
                orig_run   = orig_entry.get("num_tests_run", 0)
                orig_failed = orig_entry.get("num_tests_failed", 0)
                if build_status == "passed":
                    fw_fr.append(llm_run > 0 and llm_failed == 0 and llm_run == orig_run)
                else:
                    if orig_failed == 0 and llm_failed == 0:
                        fw_fr.append(True)
                    else:
                        fw_ex  = llm_failed > 0
                        fw_num = (llm_failed == orig_failed) and fw_ex
                        fw_fr.append(fw_num and llm_run == orig_run)
            fr = all(fw_fr) if fw_fr else False
        fr = fr and tr

        out = {
            "ER": False, "TR": tr, "FR": fr,
            "attempt_number": attempt_number,
            "original_log_stats": original_log_stats,
            "llm_log_stats": llm_log_stats,
        }

        # For failed builds, compute Existence/Number/Name/Status breakdown
        if build_status == "failed":
            def _failed_names_act(entries):
                names = set()
                for e in entries:
                    if isinstance(e, dict):
                        failures = e.get("failures", [])
                        if failures:
                            for f in failures:
                                names.add(f.get("name", ""))
                        # empty failures → no specific test name to compare
                    elif isinstance(e, str):
                        names.add(e)
                return names

            existence = number = name = status = False
            if llm_log_stats and original_log_stats:
                llm_by_fw  = {x.get("framework"): x for x in llm_log_stats
                              if x.get("framework") not in BUILD_ONLY_FRAMEWORKS}
                orig_by_fw = {x.get("framework"): x for x in original_log_stats
                              if x.get("framework") not in BUILD_ONLY_FRAMEWORKS}
                ex_list = []; num_list = []; nm_list = []; st_list = []
                for fw, orig_e in orig_by_fw.items():
                    llm_e = llm_by_fw.get(fw, {})
                    llm_f = llm_e.get("num_tests_failed", 0)
                    orig_f = orig_e.get("num_tests_failed", 0)
                    llm_suits  = llm_e.get("num_test_suits_failed", 0)
                    orig_suits = orig_e.get("num_test_suits_failed", 0)
                    if orig_f == 0 and llm_f == 0:
                        if language in ("JS", "TS") and (orig_suits > 0 or llm_suits > 0):
                            pass
                        else:
                            continue
                    if language in ("JS", "TS"):
                        fw_ex  = (llm_f > 0) or (llm_suits > 0)
                        fw_num = fw_ex and (llm_f == orig_f) and (llm_suits == orig_suits)
                    else:
                        fw_ex  = llm_f > 0
                        fw_num = fw_ex and (llm_f == orig_f)
                    fw_nm  = fw_num and (
                        _failed_names_act(llm_e.get("tests_failed", [])) ==
                        _failed_names_act(orig_e.get("tests_failed", []))
                    )
                    fw_st  = fw_nm
                    ex_list.append(fw_ex); num_list.append(fw_num)
                    nm_list.append(fw_nm); st_list.append(fw_st)
                existence = all(ex_list)  if ex_list  else False
                number    = all(num_list) if num_list else False
                name      = all(nm_list)  if nm_list  else False
                status    = all(st_list)  if st_list  else False
            out["Existence"] = existence
            out["Number"]    = number
            out["Name"]      = name
            out["Status"]    = status

        out_path = os.path.join(out_dir, "summary.json")
        with open(out_path, "w") as f:
            json.dump(out, f, indent=2)
        return out_path, None

    log_path = find_original_log(out_dir)
    if log_path is None:
        return None, "no original log file"

    with open(log_path, errors="replace") as f:
        lines = f.readlines()

    def _dedup_stats(stats):
        best = {}
        for s in stats:
            fw = s.get("framework")
            if fw in BUILD_ONLY_FRAMEWORKS:
                continue
            if fw not in best or s.get("num_tests_run", 0) > best[fw].get("num_tests_run", 0):
                best[fw] = s
        result = [s for s in best.values()
                  if s.get("num_tests_run", 0) > 0 or s.get("num_tasks_executed", 0) > 0 or s.get("num_tests_failed", 0) > 0]

        # Safety net: if nexttest and cargo both survived, and cargo's count is ≤ nexttest's,
        # cargo results are still nextest sub-runs that slipped through — drop cargo.
        # (Primary filtering happens in RustLogAnalyzer by skipping indented lines.)
        fw_map = {s["framework"]: s for s in result}
        if "nexttest" in fw_map and "cargo" in fw_map:
            if fw_map["nexttest"].get("num_tests_run", 0) >= fw_map["cargo"].get("num_tests_run", 0):
                result = [s for s in result if s["framework"] != "cargo"]
                fw_map.pop("cargo", None)

        # Priority: if CTest present, drop other C/C++ sub-frameworks that are subsumed by it
        _CTEST_SUBFRAMEWORKS = {"GTest", "GitTest", "Meson", "Autotools", "TAP", "ProveTAP",
                                "HardSoftError", "shell-tests", "mruby", "micropython"}
        if "CTest" in fw_map:
            ctest_run = fw_map["CTest"].get("num_tests_run", 0)
            result = [s for s in result
                      if s["framework"] not in _CTEST_SUBFRAMEWORKS
                      or s.get("num_tests_run", 0) > ctest_run]

        # Remove entries that are exact duplicates of another (same run/failed/passed counts)
        seen_signatures = set()
        deduped = []
        for s in result:
            sig = (s.get("num_tests_run"), s.get("num_tests_failed"), s.get("num_tests_passed"))
            if sig not in seen_signatures:
                seen_signatures.add(sig)
                deduped.append(s)
        return deduped

    # llm4build early exit: if log.txt is empty or starts with "Error from docker build"
    # → ER=TR=FR=False immediately, no parsing needed
    llm_log_path = os.path.join(out_dir, "log.txt")
    if not remaker and not act:
        llm_log_empty = not os.path.isfile(llm_log_path) or os.path.getsize(llm_log_path) == 0
        if not llm_log_empty:
            with open(llm_log_path, "r", errors="replace") as _f:
                _first_line = _f.readline().strip()
            llm_log_empty = _first_line.startswith("Error from docker build")
        if llm_log_empty:
            out = {
                "ER": False, "TR": False, "FR": False,
                "attempt_number": attempt_number,
                "original_log_stats": [],
                "llm_log_stats": [],
            }
            if build_status == "failed":
                out.update({"Existence": False, "Number": False, "Name": False, "Status": False})
            out_path = os.path.join(out_dir, "summary.json")
            with open(out_path, "w") as f:
                json.dump(out, f, indent=2)
            return out_path, None

    analyzers = detect_analyzer(lines)
    original_log_stats = []
    if analyzers:
        for a in analyzers:
            original_log_stats.append(a.analyze())
    original_log_stats = _dedup_stats(original_log_stats)

    # Parse log.txt (LLM-generated run log)
    llm_log_stats = []
    llm_lines = []
    if os.path.isfile(llm_log_path):
        with open(llm_log_path, errors="replace") as f:
            llm_lines = f.readlines()
        llm_analyzers = detect_analyzer(llm_lines)
        if llm_analyzers:
            for a in llm_analyzers:
                llm_log_stats.append(a.analyze())
    llm_log_stats = _dedup_stats(llm_log_stats)

    if not original_log_stats and not llm_log_stats:
        if remaker:
            log_txt_nonempty = os.path.isfile(llm_log_path) and os.path.getsize(llm_log_path) > 0
            er_val = log_txt_nonempty  # ER=True if log ran, False if empty
            out = {
                "ER": er_val, "TR": False, "FR": False,
                "attempt_number": attempt_number,
                "original_log_stats": [],
                "llm_log_stats": [],
                "Existence": False, "Number": False, "Name": False, "Status": False,
            }
            out_path = os.path.join(out_dir, "summary.json")
            with open(out_path, "w") as f:
                json.dump(out, f, indent=2)
            return out_path, None
        if not remaker and not act:
            # log.txt ran (passed early exit) but no parser matched → ER=True, TR=FR=False
            out = {
                "ER": True, "TR": False, "FR": False,
                "attempt_number": attempt_number,
                "original_log_stats": [],
                "llm_log_stats": [],
            }
            if build_status == "failed":
                out.update({"Existence": False, "Number": False, "Name": False, "Status": False})
            out_path = os.path.join(out_dir, "summary.json")
            with open(out_path, "w") as f:
                json.dump(out, f, indent=2)
            return out_path, None
        return None, "no matching parser"

    # ER: for remaker, log.txt non-empty means reproduction was attempted; otherwise out.json presence
    log_txt_nonempty = os.path.isfile(llm_log_path) and os.path.getsize(llm_log_path) > 0

    if remaker:
        # Empty log.txt → everything is False, no need for original log
        if not log_txt_nonempty:
            out = {
                "ER": False, "TR": False, "FR": False,
                "attempt_number": attempt_number,
                "original_log_stats": [],
                "llm_log_stats": [],
                "Existence": False, "Number": False, "Name": False, "Status": False,
            }
            out_path = os.path.join(out_dir, "summary.json")
            with open(out_path, "w") as f:
                json.dump(out, f, indent=2)
            return out_path, None
        er = True
    else:
        # llm4build: ER=False if log.txt empty or starts with "Error from docker build"
        if not log_txt_nonempty:
            er = False
        else:
            with open(llm_log_path, "r", errors="replace") as _f:
                _first = _f.readline().strip()
            er = not _first.startswith("Error from docker build")

    tr = has_tests_run(llm_lines) if log_txt_nonempty else False

    if tr:
        er = True

    def _norm_path(p):
        for prefix in ("/home/runner/work/", "/workspace/", "/app/", "/home/runner/"):
            if p.startswith(prefix):
                parts = p[len(prefix):].split("/", 1)
                return parts[-1] if len(parts) > 1 else p[len(prefix):]
        return p

    def _failed_names(entries):
        result = set()
        for e in entries:
            if isinstance(e, dict):
                failures = e.get("failures", [])
                if failures:
                    for f in failures:
                        result.add(f.get("name", ""))
                else:
                    result.add(_norm_path(e.get("file", "")) + "::" + e.get("function", ""))
            elif isinstance(e, str):
                result.add(e)
        return result

    # If LLM log produced no parseable test results (pattern not matched) → TR=FR=false
    if llm_log_stats == []:
        er = er  # keep ER as-is (log ran but no tests detected)
        tr = False

    # FR: depends on build status
    fr = False
    existence = number = name = status = False

    if llm_log_stats and original_log_stats:
        llm_by_fw  = {x.get("framework"): x for x in llm_log_stats
                      if x.get("framework") not in BUILD_ONLY_FRAMEWORKS}
        orig_by_fw = {x.get("framework"): x for x in original_log_stats
                      if x.get("framework") not in BUILD_ONLY_FRAMEWORKS}

        fw_fr        = []
        fw_existence = []
        fw_number    = []
        fw_name      = []
        fw_status    = []

        llm_total_failed = sum(x.get("num_tests_failed", 0) for x in llm_log_stats
                               if x.get("framework") not in BUILD_ONLY_FRAMEWORKS)
        llm_total_run    = sum(x.get("num_tests_run", 0) for x in llm_log_stats
                               if x.get("framework") not in BUILD_ONLY_FRAMEWORKS)

        for fw, orig_entry in orig_by_fw.items():
            llm_entry = llm_by_fw.get(fw)
            if llm_entry is None:
                # framework not in LLM output — compare numbers across all LLM frameworks
                llm_run    = llm_total_run
                llm_failed = llm_total_failed
            else:
                llm_run    = llm_entry.get("num_tests_run", 0)
                llm_failed = llm_entry.get("num_tests_failed", 0)
            orig_run = orig_entry.get("num_tests_run", 0)
            orig_failed = orig_entry.get("num_tests_failed", 0)

            if build_status == "passed":
                if orig_run == 0 and llm_run == 0:
                    # No test counts — check task execution (e.g. Gradle build-only steps)
                    orig_tasks = orig_entry.get("num_tasks_executed", 0)
                    llm_tasks  = llm_entry.get("num_tasks_executed", 0)
                    fw_fr.append(
                        orig_tasks > 0 and orig_tasks == llm_tasks
                        and not orig_entry.get("did_tests_fail")
                        and not llm_entry.get("did_tests_fail")
                    )
                else:
                    fw_fr.append(llm_run > 0 and llm_failed == 0 and llm_run == orig_run)
            else:
                llm_suits  = llm_entry.get("num_test_suits_failed", 0) if llm_entry else 0
                orig_suits = orig_entry.get("num_test_suits_failed", 0)
                # Skip frameworks where both original and LLM agree on 0 failures —
                # these are non-failing sub-components (e.g. Ninja build steps, or a
                # secondary parser like JS tap matching a C TAP log with no failures).
                if orig_failed == 0 and llm_failed == 0:
                    if language in ("JS", "TS") and (orig_suits > 0 or llm_suits > 0):
                        pass  # fall through to JS/TS suite-level check below
                    else:
                        fw_fr.append(llm_run == orig_run)
                        continue
                if language in ("JS", "TS"):
                    fw_ex  = (llm_failed > 0) or (llm_suits > 0)
                    fw_num = fw_ex and (llm_failed == orig_failed) and (llm_suits == orig_suits)
                else:
                    fw_ex  = (llm_failed > 0)
                    fw_num = (llm_failed == orig_failed) and fw_ex
                llm_tests_failed = llm_entry.get("tests_failed", []) if llm_entry else []
                fw_nm  = (_failed_names(llm_tests_failed) ==
                          _failed_names(orig_entry.get("tests_failed", []))) and fw_ex and fw_num
                fw_st  = fw_ex and fw_num and fw_nm
                fw_fr.append(fw_st and llm_run == orig_run)
                fw_existence.append(fw_ex)
                fw_number.append(fw_num)
                fw_name.append(fw_nm)
                fw_status.append(fw_st)

        fr = all(fw_fr) if fw_fr else False

        if build_status == "failed":
            existence = all(fw_existence) if fw_existence else False
            number = all(fw_number) if fw_number else False
            name = all(fw_name) if fw_name else False
            status = all(fw_status) if fw_status else False

    fr = fr and tr

    # Fallback FR for Gradle: if no test counts in original log, compare num_tasks_executed + build status
    if not fr and not tr and original_log_stats and llm_log_stats:
        orig_gradle = next((x for x in original_log_stats if x.get("framework") == "Gradle"), None)
        llm_gradle  = next((x for x in llm_log_stats  if x.get("framework") == "Gradle"), None)
        if orig_gradle and llm_gradle:
            orig_tasks    = orig_gradle.get("num_tasks_executed", 0)
            llm_tasks     = llm_gradle.get("num_tasks_executed", 0)
            orig_uptodate = orig_gradle.get("num_tasks_uptodate", 0)
            llm_uptodate  = llm_gradle.get("num_tasks_uptodate", 0)
            orig_failed   = orig_gradle.get("did_tests_fail", False)
            llm_failed    = llm_gradle.get("did_tests_fail", False)
            if (orig_tasks > 0 and orig_tasks == llm_tasks
                    and orig_uptodate == llm_uptodate
                    and orig_failed == llm_failed):
                fr = True

    output = {
        "ER": er,
        "TR": tr,
        "FR": fr,
        "attempt_number": attempt_number,
        "original_log_stats": original_log_stats,
        "llm_log_stats": llm_log_stats,
    }

    if build_status == "failed":
        output["Existence"] = existence
        output["Number"] = number
        output["Name"] = name
        output["Status"] = status

    if language == "Java":
        llm_has_compile  = any(s.get("compilation_error", False) for s in llm_log_stats)
        orig_has_compile = any(s.get("compilation_error", False) for s in original_log_stats)

        output["Compilation Error"] = llm_has_compile

        if llm_has_compile and build_status == "failed":
            llm_n  = max((s.get("num_compilation_errors", 0) for s in llm_log_stats),  default=0)
            orig_n = max((s.get("num_compilation_errors", 0) for s in original_log_stats), default=0)

            llm_ce  = [e for s in llm_log_stats  if s.get("compilation_error") for e in s.get("compilation_errors", [])]
            orig_ce = [e for s in original_log_stats if s.get("compilation_error") for e in s.get("compilation_errors", [])]

            def _norm_ce(err):
                # Normalize to a common relative path starting from src/
                # so paths like /home/runner/work/repo/repo/src/... and
                # /workspace/src/... or /app/src/... all compare equal
                idx = err.find("/src/")
                if idx != -1:
                    return err[idx + 1:]  # keep "src/..."
                # Fallback: strip known container prefixes
                for prefix in ("/app/", "/workspace/"):
                    if err.startswith(prefix):
                        return err[len(prefix):]
                return err

            llm_ce_norm  = set(_norm_ce(e) for e in llm_ce)
            orig_ce_norm = set(_norm_ce(e) for e in orig_ce)

            existence = llm_has_compile and orig_has_compile
            number = existence and (llm_n == orig_n)
            name = existence and number and all(
                any(o.endswith(le) for o in orig_ce_norm)
                for le in llm_ce_norm
            ) and len(llm_ce_norm) == len(orig_ce_norm)
            status = existence and number and name

            output["Existence"] = existence
            output["Number"] = number
            output["Name"] = name
            output["Status"] = status
            output["FR"] = status

    out_path = os.path.join(out_dir, "summary.json")
    with open(out_path, "w") as f:
        json.dump(output, f, indent=2)

    return out_path, None


def main():
    p = argparse.ArgumentParser(description="Extract test stats from original CI logs")
    p.add_argument("folder", help="Single project folder (has out/) or parent folder of many projects")
    p.add_argument("--remaker",     action="store_true", help="Use action-remaker ER logic (log.txt non-empty = ER true)")
    p.add_argument("--act",         action="store_true", help="Use act logic (ER=False, TR=has_tests_run, FR=False)")
    p.add_argument("--claude-code", action="store_true", dest="claude_code",
                   help="Use claude-code logic (ER=False if log.txt absent, else ER=True like remaker)")
    args = p.parse_args()

    def has_summary(project_dir):
        # Always skip projects that already have a summary.json — only
        # generate the missing ones. Delete summary.json to force a rebuild.
        return os.path.isfile(os.path.join(project_dir, "out", "summary.json"))

    folder = args.folder.rstrip("/")
    if not os.path.isdir(folder):
        print(f"Error: '{folder}' is not a directory.", file=sys.stderr)
        sys.exit(1)

    parts = folder.replace("\\", "/").split("/")
    build_status = "passed" if "passed" in parts else "failed"
    language = next((p for p in parts if p in ("Java", "Python", "JS", "TS", "C", "C++", "Rust", "Go")), None)

    # Single project folder: has an out/ subdirectory directly
    if os.path.isdir(os.path.join(folder, "out")):
        project = os.path.basename(folder)
        if has_summary(folder):
            print(f"  [SKIP] {project}: summary.json already exists")
            return
        out_path, err = process_project(folder, build_status, language,
                                         remaker=args.remaker, act=args.act, claude_code=args.claude_code)
        if err:
            print(f"  [SKIP] {project}: {err}")
        else:
            print(f"  [OK]   {project} -> {out_path}")
        return

    # Parent folder: iterate over project subfolders
    ok = skipped = existing = 0
    for project in sorted(os.listdir(folder)):
        project_dir = os.path.join(folder, project)
        if not os.path.isdir(project_dir):
            continue
        if has_summary(project_dir):
            existing += 1
            continue
        out_path, err = process_project(project_dir, build_status, language,
                                        remaker=args.remaker, act=args.act, claude_code=args.claude_code)
        if err:
            print(f"  [SKIP] {project}: {err}")
            skipped += 1
        else:
            print(f"  [OK]   {project} -> {out_path}")
            ok += 1

    print(f"\nDone: {ok} written, {skipped} skipped, {existing} already had summary.json")


if __name__ == "__main__":
    main()
