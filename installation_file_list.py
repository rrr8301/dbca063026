import re

JAVA_CONFIG_FILES = [
    "pom.xml", 
    "pom-test.xml", 
    "pom-release.xml", 
    "pom-dev.xml", 
    "pom-build.xml",
    "build-pom.xml",
    "alt-pom.xml", 
    "build.gradle", 
    "build.gradle.kts", 
    "build-dev.gradle"
    ]
python_installation_files = [
    # Dependency files
    "requirements.txt",
    "requirements-dev.txt",
    "requirements-test.txt",
    "requirements-prod.txt",
    "requirements-ci.txt",
    "build_requirements.txt",
    "test_requirements.txt"

    # Packaging configs
    "setup.py",
    "setup.cfg",
    "pyproject.toml",

    # Environment managers
    "Pipfile",
    "Pipfile.lock",
    "environment.yml",   # Conda

    # Testing / automation
    "tox.ini",
    "pytest.ini",

    # Linting / formatting configs
    ".flake8",
    ".pylintrc",
    "mypy.ini",

    # Optional build helpers
    "Makefile", 
    "uv",
    "uv.lock"
]

javascript_installation_files = [
    # Dependency managers
    "package.json",
    "package-lock.json",   # npm lock file
    "yarn.lock",           # Yarn lock file
    "pnpm-lock.yaml",      # pnpm lock file

    # Build / bundler configs
    "webpack.config.js",
    "rollup.config.js",
    "vite.config.js",
    "gulpfile.js",
    "gruntfile.js",

    # TypeScript config
    "tsconfig.json",
    "tsconfig.build.json",

    # Linting / formatting
    ".eslintrc.js",
    ".eslintrc.json",
    ".eslintrc.yml",
    ".prettierrc",
    ".prettierrc.js",
    ".prettierrc.json",

    # Testing
    "jest.config.js",
    "jest.config.ts",
    "mocha.opts",
    "karma.conf.js",

    # Environment / runtime
    ".nvmrc",        # Node version
    ".npmrc",        # npm config
    ".yarnrc.yml",   # yarn config

    # Other common project files
    "babel.config.js",
    "babel.config.json",
    "next.config.js",
    "nuxt.config.js"
]

go_installation_files = [
    # Dependency management
    "go.mod",        # Defines module path & dependencies
    "go.sum",        # Checksums for dependencies
    "Gopkg.toml",    # Old (dep tool)
    "Gopkg.lock",    # Old (dep tool)
    "glide.yaml",    # Very old (Glide)
    "glide.lock",    # Very old (Glide)

    # Build / tooling
    "Makefile",      # Often used for build/test commands
    "Dockerfile",    # Containerized builds/tests

    # Testing configs
    ".golangci.yml",    # golangci-lint config
    ".golangci.yaml",
    ".golangci.toml",
    ".golangci.json",

    # CI / task runners
    "Taskfile.yml",     # Task runner for Go
    "magefile.go",      # Mage (Make alternative in Go)

    # Environment
    ".go-version",      # Node-style version pinning, used by some tools
    ".tool-versions"    # asdf-vm version file (may include Go)
]

csharp_installation_files = [
    # Project / solution files
    "*.csproj",       # C# project file (defines dependencies, build settings)
    "*.vbproj",       # VB.NET project file
    "*.fsproj",       # F# project file
    "*.sln",          # Solution file (groups projects)

    # Package management
    "packages.config",  # Old NuGet dependency list
    "NuGet.config",     # NuGet sources/credentials
    "global.json",      # Pin SDK version
    "Directory.Packages.props",  # Central package version management
    "Directory.Build.props",     # Shared MSBuild properties
    "Directory.Build.targets",   # Shared MSBuild targets

    # .NET CLI / runtime
    ".dotnet-tools.json",   # Local dotnet tool manifest
    "dotnet-tools.json",    # Sometimes used interchangeably
    ".config/dotnet-tools.json",  # Alternate location

    # Build / automation
    "Cakefile",        # Cake (C# Makefile alternative)
    "build.cake",      # Cake build script
    "build.ps1",       # PowerShell build script
    "build.sh",        # Shell build script
    "Makefile",        # Sometimes used in cross-platform repos

    # Testing
    "xunit.runner.json",   # xUnit test config
    "nunit.config",        # NUnit config
    "mstest.runsettings",  # MSTest run settings

    # Editor / linting / analyzers
    ".editorconfig",       # Code style/linting
    "stylecop.json",       # StyleCop analyzer config
    "ruleset.json",        # Roslyn analyzer rules
    "sonar-project.properties"  # SonarQube config
]

rust_installation_files = [
    # Dependency management & project metadata
    "Cargo.toml",          # Main Rust project manifest
    "Cargo.lock",          # Lock file for dependencies
    "rust-toolchain",      # Pin Rust version (rustup override file)
    "rust-toolchain.toml", # Advanced toolchain config
    ".cargo/config",       # Cargo config (deprecated form)
    ".cargo/config.toml",  # Cargo config (modern form)

    # Workspace / multi-crate setup
    "Cargo.workspace.toml", # Alternative workspace manifests
    "Cargo.nix",            # Nix-based Cargo integration

    # Build / automation
    "Makefile",             # Often wraps cargo build/test
    "Justfile",             # Just task runner
    "Taskfile.yml",         # Task runner configs
    "build.rs",             # Cargo build script
    "cross.toml",           # Cross-compilation config (cross-rs)
    "rust-project.json",    # rust-analyzer project definition
    "bazel.build",          # Some projects integrate with Bazel

    # Testing / coverage
    "Cargo.toml" ,          # Integration/unit tests defined here under [dev-dependencies]
    ".tarpaulin.toml",      # Tarpaulin coverage tool config
    ".grcov.yml",           # grcov coverage tool config
    ".nextest.toml",        # cargo-nextest test runner config
    ".proptest-regressions",# Proptest regression test outputs
    "fuzz/Cargo.toml",      # cargo-fuzz setup for fuzz testing

    # Linting / formatting
    "rustfmt.toml",         # rustfmt config
    ".rustfmt.toml",        # alt rustfmt config
    "Clippy.toml",          # clippy lint config (unofficial, supported by cargo-clippy)
    ".clippy.toml",         # alt clippy config

    # Environment / version managers
    ".rust-version",        # Rust version (alternative to rust-toolchain)
    ".tool-versions",       # asdf-vm toolchain version file (may include Rust)

    # CI / metadata
    "deny.toml",            # cargo-deny config (dependency audit)
    ".cargo-husky.toml",    # cargo-husky git hook configs
    ".audit.toml",          # cargo-audit config
    "audit.toml",           # sometimes not dotted
]

c_cpp_installation_files = [
    # Build systems
    "Makefile",              # Classic make build file
    "GNUmakefile",           # GNU Make convention
    "makefile",              # lowercase variant
    "CMakeLists.txt",        # CMake build definition
    "*.cmake",               # CMake modules/configs
    "meson.build",           # Meson build definition
    "meson_options.txt",     # Meson options
    "configure",             # Autotools configure script
    "configure.ac",          # Autoconf input
    "config.h.in",           # Autotools config header template
    "config.h",              # Generated config header
    "autogen.sh",            # Script to bootstrap autotools
    "bootstrap",             # Often used for autoconf bootstrap
    "SConstruct",            # SCons build script
    "SConscript",            # SCons sub-project script
    "wscript",               # Waf build script
    "BUILD",                 # Bazel build file
    "WORKSPACE",             # Bazel workspace
    "BUILD.bazel",           # Bazel build file (explicit extension)
    "*.bzl",                 # Bazel/Starlark extensions

    # Dependency management
    "conanfile.txt",         # Conan dependencies
    "conanfile.py",          # Conan recipes
    "vcpkg.json",            # vcpkg manifest mode
    "vcpkg-configuration.json", # vcpkg registries config
    "vcpkg-lock.json",       # vcpkg lock file
    "hunter.cmake",          # Hunter package manager for CMake
    "CPackConfig.cmake",     # Packaging config
    "CPackSourceConfig.cmake",

    # Testing
    "CTestTestfile.cmake",   # CTest test definitions
    ".cppunit.xml",          # CppUnit config
    "gtest.xml",             # GoogleTest report/config
    "CatchConfig.cmake",     # Catch2 CMake config

    # Toolchain / environment
    "toolchain.cmake",       # Toolchain file for cross-compilation
    ".clang-format",         # Code formatting
    ".clang-tidy",           # Linting / static analysis
    ".ccls",                 # ccls LSP config
    "compile_commands.json", # Compilation database
    ".codecov.yml",          # Code coverage
    ".gcov",                 # Gcov profiling configs
    ".lcovrc",               # Lcov configuration

    # IDE / project configs (commonly checked in)
    "*.pro",                 # Qt qmake project
    "*.pri",                 # Qt include project file
    "*.qbs",                 # Qt Qbs build
    ".project",              # Eclipse CDT project
    ".cproject",             # Eclipse CDT build
    "*.vcxproj",             # Visual Studio C++ project
    "*.vcxproj.filters",     # VS project filters
    "*.sln",                 # Visual Studio solution
    "*.dsp", "*.dsw",        # Old Visual Studio workspace/project
    "*.cbp",                 # Code::Blocks project
    "*.dev",                 # Dev-C++ project
    "*.kdev4", "*.kdevelop", # KDevelop project

    # Scripts for build/test automation
    "build.sh",
    "build.bat",
    "run_tests.sh",
    "test.sh"
]

GRADLE_BUILD_PATTERN = re.compile(r'^BUILD\s+(SUCCESSFUL|FAILED)\s+in\s+', re.IGNORECASE)
GRADLE_TASK_TEST_PATTERN = re.compile(r'^:\S+:test\s+\((SUCCESS|FAILED)\):\s+\d+\s+tests?', re.IGNORECASE)

JAVA_MAVEN_PATTERN = re.compile(
    r"^(?:\[(?:INFO|WARNING|ERROR)\]\s*)?"
    r"Tests\s+run:\s*(?P<run>\d+),\s*"
    r"Failures:\s*(?P<failures>\d+),\s*"
    r"Errors:\s*(?P<errors>\d+),\s*"
    r"Skipped:\s*(?P<skipped>\d+)",
    re.IGNORECASE
)

NODE_TEST_PATTERN = re.compile(r'tests\s+\d+', re.IGNORECASE)

PYTEST_MULTILINE_HEADER = re.compile(
    r'^Results\s+\([\d.]+\s*(?:s|sec|seconds|min.*?s)?\):',
    re.IGNORECASE
)

PYTEST_PATTERN = re.compile(
    r"""=+\s*                              # leading ===
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

UNITTEST_PATTERN = re.compile(
    r"^Total\s+test\s+files:\s*"
    r"run=(?P<run>\d+)(?:/(?P<total>\d+))?\s*"
    r"(?:failed=(?P<failed>\d+)\s*)?"
    r"(?:skipped=(?P<skipped>\d+)\s*)?"
    r"(?:resource_denied=(?P<resdeny>\d+)\s*)?"
    r"(?:rerun=(?P<rerun>\d+)\s*)?",
    re.IGNORECASE
)

RUST_PATTERN = re.compile(r'test result:\s+(ok|FAILED). (\d+) passed; (\d+) failed; (\d+) ignored; (\d+) measured; (\d+) filtered out; finished in (\d+\.?\d*)\s?s', re.IGNORECASE)
NEXTEST_SUMMARY_PATTERN = re.compile(r'^\s*Summary\s*\[\s*\d+(?:\.\d+)?s\]\s*\d+\s+tests\s+run:', re.IGNORECASE)

mruby_pattern        = re.compile(r'^\s*KO:\s*\d+',               re.IGNORECASE)
micropython_pattern  = re.compile(r'^\d+\s+tests?\s+performed',   re.IGNORECASE)
meson_ok_pattern     = re.compile(r'^\s*Ok:\s*\d+',               re.IGNORECASE)

c_tap_all_passed = re.compile(r'^#\s+All\s+\d+\s+tests?\s+passed', re.IGNORECASE)
c_tap_some_failed = re.compile(r'^#\s+\d+\s+of\s+\d+\s+tests?\s+failed', re.IGNORECASE)
c_autotools_pattern = re.compile(r'^Testsuite summary for\b', re.IGNORECASE)
c_hard_soft_error_pattern = re.compile(r'^(?:Hard|Soft)\s+errors:\s+\d+', re.IGNORECASE)
c_mnn_pattern = re.compile(
    r'TEST_CASE_AMOUNT_\w+:\s*\{"blocked"\s*:\s*\d+\s*,\s*"failed"\s*:\s*\d+\s*,\s*"passed"\s*:\s*\d+\s*,\s*"skipped"\s*:\s*\d+\s*\}',
    re.IGNORECASE
)
c_capnproto_pattern = re.compile(r'^\d+\s+tests?\(s\)?\s+passed', re.IGNORECASE)
c_ccv_pattern = re.compile(r'^\[\d+/\d+\]\s+\[(PASS|FAIL|RUN)\]', re.IGNORECASE)
c_duckdb_pattern = re.compile(r'^all\s+tests?\s+passed\s+in\s+[\d.]+s', re.IGNORECASE)

c_ctest_pattern = re.compile(
    r"^\s*(?P<pct>\d+(?:\.\d+)?)%\s*tests?\s*passed,\s*"
    r"(?P<failed>\d+)\s*tests?\s*failed\s*out\s*of\s*(?P<total>\d+)\s*$",
    re.IGNORECASE
)

perl_harness_pattern = re.compile(r'Files=\d+,\s*Tests=\d+,',                    re.IGNORECASE)
perl_result_pattern  = re.compile(r'^Result:\s+(PASS|FAIL)',                      re.IGNORECASE)

zstd_pass_pattern   = re.compile(r'[✓✔]?\s*Test\s+\d+\s+PASSED[:\s]',          re.IGNORECASE)
zstd_fail_pattern   = re.compile(r'[✗✘×]?\s*Test\s+\d+\s+FAILED[:\s]',         re.IGNORECASE)
zstd_all_passed     = re.compile(r'All\s+tests\s+completed\s+successfully',      re.IGNORECASE)
shell_test_summary  = re.compile(r'(FAILED|PASSED)\s+\d+\s*/\s*\d+\s+tests?',   re.IGNORECASE)

c_gtest_pattern = re.compile(
    r"\[\=+\]\s*"
    r"(?P<tests>\d+)\s+tests?\s+from\s+(?P<cases>\d+)\s+test\s+(?:cases?|suites?)\s+ran\.\s*"
    r"\((?P<time>[\d.]+)\s*ms\s*total\)",
    re.IGNORECASE
)

c_gtest_suite_pattern = re.compile(
    r"\[\-+\]\s*(?P<tests>\d+)\s+tests?\s+from\s+(?P<suite>\S+)\s+\((?P<time>[\d.]+)\s*ms\s*total\)",
    re.IGNORECASE
)

tap_result_result_pattern = re.compile(r'^(?:.*?\s)?(ok|not ok) \d+', re.IGNORECASE)

jasmine_result_summary = re.compile(r'Executed (\d+) out of (\d+) tests?: (\d+) tests? pass[es]? and (\d+) fails? remotely.$', re.IGNORECASE)
jasmine_npm_summary = re.compile(r'\d+\s+specs?,\s+\d+\s+failures?', re.IGNORECASE)
karma_result_summary = re.compile(r'Executed\s+\d+\s+out\s+of\s+\d+\s+tests?:.*tests?\s+pass', re.IGNORECASE)
summary_block_total = re.compile(r'Total\s+number\s+of\s+tests\s*:\s*\d+', re.IGNORECASE)

jest_result_summary = re.compile(r'Tests:\s+(\d+ failed, )?(\d+ skipped, )?(\d+ passed, )?(\d+ total)', re.IGNORECASE)

vitest_result_summary = re.compile(r'^\s*Tests\s+\d+.*\(\s*\d+\s*\)', re.IGNORECASE)
vitest_test_files_pattern = re.compile(r'^\s*Test\s+Files\s+\d+', re.IGNORECASE)

bun_test_summary = re.compile(r'^Ran\s+\d+\s+tests\s+across\s+\d+\s+files', re.IGNORECASE)

unity_summary  = re.compile(r'^\d+\s+Tests\s+\d+\s+Failures\s+\d+\s+Ignored\s*$')
llvm_lit_total  = re.compile(r'Total Discovered Tests:\s*\d+')
csound_summary  = re.compile(r'^Tests Passed:\s*\d+', re.IGNORECASE)

# Standard Python unittest runner: "Ran N tests in X.Xs" or "Ran N tests in X.X seconds"
unittest_ran_pattern = re.compile(r'Ran\s+\d+\s+tests?\s+in\s+[\d.]+\s*s', re.IGNORECASE)
# CLibTAP / libuv-style TAP: "ok N - name" or "not ok N - name"
clib_tap_pattern = re.compile(r'^(?:not\s+)?ok\s+\d+\s+-\s+\S', re.IGNORECASE)

TS_result_summary = re.compile(r'^\s*(\d+)\s+passing\s+\((\d+)(ms|s|m)\)', re.IGNORECASE)

# === RUN   TestMonadLaws
GO_result_summary = re.compile(r'===\s*RUN\s*(.*)')

go_test_pattern = re.compile(
            r'^DONE\s+(?P<tests>\d+)\s+tests'
            r'(?:,\s+(?P<skipped>\d+)\s+skipped)?'
            r'(?:,\s+(?P<failed>\d+)\s+failures?)?'
            r'(?:,\s+\d+\s+errors?)?'
            r'\s+in\s+(?P<secs>\d+(?:\.\d+)?)s$', re.IGNORECASE
        )

# ok  	github.com/foo/bar	1.037s  OR  FAIL	github.com/foo/bar	0.038s
go_pkg_result_pattern = re.compile(r'^\s*(ok|FAIL)\s+\S+(?:\s+\d+(?:\.\d+)?s)?', re.IGNORECASE)
go_gotestfmt_pattern  = re.compile(r'[✅❌]\s+\S+\s*\(\d+(?:\.\d+)?(?:ms|s)\)')


_ANSI_RE        = re.compile(r'\x1B[@-_][0-?]*[ -/]*[@-~]', re.M)
_TS_RE          = re.compile(r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d+Z\s+')
_ACT_RE         = re.compile(r'^\[[\w/ ._-]+\]\s{2,}(?:\|\s?)?')
_TASK_PREFIX_RE = re.compile(r'^[\w][\w-]*:[\w][\w-]*:\s+')

def _clean(line):
    line = _ANSI_RE.sub('', line)
    line = _TS_RE.sub('', line)
    line = _ACT_RE.sub('', line)
    line = _TASK_PREFIX_RE.sub('', line)
    return line

def has_tests_run(log_lines):
    tests_run = False
    for raw in log_lines:
        line = _clean(raw)
        
        if JAVA_MAVEN_PATTERN.search(line) or GRADLE_BUILD_PATTERN.search(line) or GRADLE_TASK_TEST_PATTERN.search(line):
            tests_run = True
            break
        
        if PYTEST_PATTERN.search(line) or UNITTEST_PATTERN.search(line) or PYTEST_MULTILINE_HEADER.search(line):
            tests_run = True
            break
            
        if jasmine_result_summary.search(line) or jasmine_npm_summary.search(line) or karma_result_summary.search(line) or summary_block_total.search(line) or tap_result_result_pattern.search(line) or vitest_result_summary.search(line) or vitest_test_files_pattern.search(line) or jest_result_summary.search(line) or bun_test_summary.search(line) or NODE_TEST_PATTERN.search(re.sub(r'\x1B[@-_][0-?]*[ -/]*[@-~]', '', re.sub(r'[^\x00-\x7F]+', '', line))):
            tests_run = True
            break
        
        if TS_result_summary.search(line):
            tests_run = True
            break
        
        if RUST_PATTERN.search(line) or NEXTEST_SUMMARY_PATTERN.search(line):
            tests_run = True
            break
        
        if c_ctest_pattern.search(line) or c_gtest_pattern.search(line) or c_gtest_suite_pattern.search(line) or c_tap_all_passed.search(line) or c_tap_some_failed.search(line) or c_autotools_pattern.search(line) or c_hard_soft_error_pattern.search(line) or c_mnn_pattern.search(line) or c_capnproto_pattern.search(line) or c_ccv_pattern.search(line) or c_duckdb_pattern.search(line):
            tests_run = True
            break

        if zstd_pass_pattern.search(line) or zstd_fail_pattern.search(line) or zstd_all_passed.search(line) or shell_test_summary.search(line):
            tests_run = True
            break

        if perl_harness_pattern.search(line) or perl_result_pattern.match(line):
            tests_run = True
            break

        if mruby_pattern.search(line) or micropython_pattern.search(line) or meson_ok_pattern.search(line):
            tests_run = True
            break
        
        if GO_result_summary.search(line) or go_test_pattern.search(line) or go_pkg_result_pattern.search(line) or go_gotestfmt_pattern.search(line):
            tests_run = True
            break

        if unity_summary.search(line):
            tests_run = True
            break

        if llvm_lit_total.search(line):
            tests_run = True
            break

        if csound_summary.match(line):
            tests_run = True
            break

        if unittest_ran_pattern.search(line):
            tests_run = True
            break

        if clib_tap_pattern.match(line):
            tests_run = True
            break

    return tests_run







