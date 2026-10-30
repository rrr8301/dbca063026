# Reducer disagreements

37 of 70 cases have a disagreement other than dropping skipped steps or adding setup steps; 7 agreeing cases are sampled too.

## Activiti_64321172862

- [job](https://github.com/Activiti/Activiti/actions/runs/22234072893/job/64321172862) — target `build`, matrix `{}`; ground truth: matched (5/13 steps executed)
- **reducer:claude-haiku-4-5-20251001**: matrix n/a; required steps 0/13; modified 0; added {'setup': 0, 'other': 0}
  - `no_output` reduced YAML has no jobs or steps
- **reducer_B:claude-haiku-4-5-20251001**: matrix n/a; required steps 13/13; modified 0; added {'setup': 0, 'other': 0}

## BehaviorTree.CPP_75439109321

- [job](https://github.com/BehaviorTree/BehaviorTree.CPP/actions/runs/25694491929/job/75439109321) — target `build`, matrix `{"os": "ubuntu-22.04"}`; ground truth: matched (8/8 steps executed)
- **reducer:claude-haiku-4-5-20251001**: matrix not_observable; required steps 8/8; modified 2; added {'setup': 0, 'other': 0}
  - `modified` step:build:5: command (original run: executed)
    ```diff
    -cmake --preset conan-${{ env.BUILD_TYPE_LOWERCASE }}
    +cmake --preset conan-release
    ```
  - `modified` step:build:6: command (original run: executed)
    ```diff
    -cmake --build --preset conan-${{ env.BUILD_TYPE_LOWERCASE }}
    +cmake --build --preset conan-release
    ```
- **reducer_B:claude-haiku-4-5-20251001**: matrix not_observable; required steps 8/8; modified 2; added {'setup': 0, 'other': 0}
  - `modified` step:build:5: command (original run: executed)
    ```diff
    -cmake --preset conan-${{ env.BUILD_TYPE_LOWERCASE }}
    +cmake --preset conan-release
    ```
  - `modified` step:build:6: command (original run: executed)
    ```diff
    -cmake --build --preset conan-${{ env.BUILD_TYPE_LOWERCASE }}
    +cmake --build --preset conan-release
    ```

## STC_72967914244

- [job](https://github.com/stclib/STC/actions/runs/24915950140/job/72967914244) — target `meson-build-and-tests`, matrix `{"flavor": "debug", "mode": {"name": "clang", "args": "-Dtests=enabled", "extra_envs": {"CC": "clang", "CXX": "clang++"}}, "platform": "ubuntu-22.04"}`; ground truth: matched (6/7 steps executed)
- **reducer:claude-haiku-4-5-20251001**: matrix correct; required steps 6/7; modified 2; added {'setup': 0, 'other': 0}
  - `conditional_step` step removed: Activate MSVC and Configure (original run: not_executed)
  - `modified` step:meson-build-and-tests:3: env, condition_removed (if: "${{ matrix.platform != 'windows-2022' }}" -> 'None') (original run: executed)
  - `modified` step:meson-build-and-tests:5: env (original run: executed)
- **reducer_B:claude-haiku-4-5-20251001**: matrix correct; required steps 6/7; modified 2; added {'setup': 0, 'other': 0}
  - `conditional_step` step removed: Activate MSVC and Configure (original run: not_executed)
  - `modified` step:meson-build-and-tests:3: env, condition_removed (if: "${{ matrix.platform != 'windows-2022' }}" -> 'None') (original run: executed)
  - `modified` step:meson-build-and-tests:5: env (original run: executed)

## axios_74125145265

- [job](https://github.com/axios/axios/actions/runs/25283861796/job/74125145265) — target `ci`, matrix `{"node-version": "14.x"}`; ground truth: matched (5/6 steps executed)
- **reducer:claude-haiku-4-5-20251001**: matrix correct; required steps 5/6; modified 0; added {'setup': 0, 'other': 0}
  - `conditional_step` step removed: Dependency Review (original run: not_executed)
- **reducer_B:claude-haiku-4-5-20251001**: matrix correct; required steps 6/6; modified 1; added {'setup': 0, 'other': 0}
  - `modified` step:ci:5: condition (if: "matrix.node-version == '24.x'" -> 'False') (original run: not_executed)

## babel_73097014101

- [job](https://github.com/babel/babel/actions/runs/24964523333/job/73097014101) — target `test`, matrix `{"node-version": 24}`; ground truth: matched (7/7 steps executed)
- **reducer:claude-haiku-4-5-20251001**: matrix correct; required steps 7/16; modified 0; added {'setup': 0, 'other': 0}
  - `artifacts` required job build removed
  - `setup_prefix` step removed: Use Node.js latest
  - `setup_prefix` step removed: Cleanup fixtures
  - `setup_prefix` step removed: Build babel artifacts
  - `setup_prefix` step removed: Checkout code
  - `setup_prefix` step removed: Ensure cwd does not contain uncommitted changes
  - `artifacts` step removed: actions/upload-artifact@v7
  - `setup_prefix` step removed: Generate .npmignore
  - `setup_prefix` step removed: Build Makefile.js
  - `setup_prefix` step removed: Generate readmes
- **reducer_B:claude-haiku-4-5-20251001**: matrix correct; required steps 7/16; modified 0; added {'setup': 0, 'other': 0}
  - `artifacts` required job build removed
  - `setup_prefix` step removed: Use Node.js latest
  - `setup_prefix` step removed: Cleanup fixtures
  - `setup_prefix` step removed: Build babel artifacts
  - `setup_prefix` step removed: Checkout code
  - `setup_prefix` step removed: Ensure cwd does not contain uncommitted changes
  - `artifacts` step removed: actions/upload-artifact@v7
  - `setup_prefix` step removed: Generate .npmignore
  - `setup_prefix` step removed: Build Makefile.js
  - `setup_prefix` step removed: Generate readmes

## bsl-language-server_78491250051

- [job](https://github.com/1c-syntax/bsl-language-server/actions/runs/26634491607/job/78491250051) — target `build`, matrix `{"java_version": "21", "os": "ubuntu-latest"}`; ground truth: uncertain: header 'actions/upload-artifact@v7' fits steps 3 and 4 equally
- **reducer:claude-haiku-4-5-20251001**: matrix correct; required steps 5/7; modified 0; added {'setup': 0, 'other': 0}
  - `outputs` required job check-pr-exists removed
  - `setup_prefix` step removed: actions/checkout@v6
  - `outputs` step removed: Check if PR exists for this branch
- **reducer_B:claude-haiku-4-5-20251001**: matrix correct; required steps 5/7; modified 0; added {'setup': 0, 'other': 0}
  - `outputs` required job check-pr-exists removed
  - `setup_prefix` step removed: actions/checkout@v6
  - `outputs` step removed: Check if PR exists for this branch

## dash_73803999053

- [job](https://github.com/plotly/dash/actions/runs/25174699412/job/73803999053) — target `lint-unit`, matrix `{"python-version": "3.12"}`; ground truth: matched (11/11 steps executed)
- **reducer:claude-haiku-4-5-20251001**: matrix correct; required steps 20/20; modified 1; added {'setup': 0, 'other': 0}
  - `modified` step:lint-unit:9: env (original run: executed)
- **reducer_B:claude-haiku-4-5-20251001**: matrix correct; required steps 20/20; modified 1; added {'setup': 0, 'other': 0}
  - `modified` step:lint-unit:9: env (original run: executed)

## echo_74064579249

- [job](https://github.com/labstack/echo/actions/runs/25259598770/job/74064579249) — target `test`, matrix `{"os": "ubuntu-latest", "go": "1.26"}`; ground truth: matched (4/4 steps executed)
- **reducer:claude-haiku-4-5-20251001**: matrix correct; required steps 4/4; modified 1; added {'setup': 0, 'other': 0}
  - `modified` step:test:3: condition (if: "success() && matrix.go == env.LATEST_GO_VERSION && matrix.os == 'ubuntu-latest'" -> 'success() && "1.26" == env.LATEST_GO_VERSION && \'ubuntu-latest\' == \'ubuntu-lates') (original run: executed)
- **reducer_B:claude-haiku-4-5-20251001**: matrix correct; required steps 4/4; modified 1; added {'setup': 0, 'other': 0}
  - `modified` step:test:3: condition (if: "success() && matrix.go == env.LATEST_GO_VERSION && matrix.os == 'ubuntu-latest'" -> "success() && 1.26 == env.LATEST_GO_VERSION && ubuntu-latest == 'ubuntu-latest'") (original run: executed)

## egg_73220056264

- [job](https://github.com/eggjs/egg/actions/runs/24976646552/job/73220056264) — target `test`, matrix `{"os": "ubuntu-latest", "node": "24"}`; ground truth: matched (10/13 steps executed)
- **reducer:claude-haiku-4-5-20251001**: matrix correct; required steps 10/13; modified 6; added {'setup': 0, 'other': 0}
  - `conditional_step` step removed: Start Redis (Windows via Memurai) (original run: not_executed)
  - `conditional_step` step removed: Start MySQL (Windows) (original run: not_executed)
  - `conditional_step` step removed: Run tests (original run: not_executed)
  - `modified` step:test:1: condition_removed (if: "${{ matrix.os == 'macos-latest' || matrix.os == 'ubuntu-latest' }}" -> 'None') (original run: executed)
  - `modified` step:test:3: condition_removed (if: "${{ matrix.os == 'macos-latest' || matrix.os == 'ubuntu-latest' }}" -> 'None') (original run: executed)
  - `modified` step:test:4: condition_removed (if: "${{ matrix.os == 'macos-latest' || matrix.os == 'ubuntu-latest' }}" -> 'None') (original run: executed)
  - `modified` step:test:9: condition_removed (if: "${{ matrix.os == 'ubuntu-latest' && matrix.node == '24' }}" -> 'None') (original run: executed)
  - `modified` step:test:11: condition_removed (if: "${{ matrix.os != 'windows-latest' }}" -> 'None') (original run: executed)
  - `modified` step:test:12: condition_removed (if: "${{ matrix.os == 'ubuntu-latest' && matrix.node == '24' }}" -> 'None') (original run: executed)
- **reducer_B:claude-haiku-4-5-20251001**: matrix correct; required steps 10/13; modified 6; added {'setup': 0, 'other': 0}
  - `conditional_step` step removed: Start Redis (Windows via Memurai) (original run: not_executed)
  - `conditional_step` step removed: Start MySQL (Windows) (original run: not_executed)
  - `conditional_step` step removed: Run tests (original run: not_executed)
  - `modified` step:test:1: condition_removed (if: "${{ matrix.os == 'macos-latest' || matrix.os == 'ubuntu-latest' }}" -> 'None') (original run: executed)
  - `modified` step:test:3: condition_removed (if: "${{ matrix.os == 'macos-latest' || matrix.os == 'ubuntu-latest' }}" -> 'None') (original run: executed)
  - `modified` step:test:4: condition_removed (if: "${{ matrix.os == 'macos-latest' || matrix.os == 'ubuntu-latest' }}" -> 'None') (original run: executed)
  - `modified` step:test:9: condition_removed (if: "${{ matrix.os == 'ubuntu-latest' && matrix.node == '24' }}" -> 'None') (original run: executed)
  - `modified` step:test:11: condition_removed (if: "${{ matrix.os != 'windows-latest' }}" -> 'None') (original run: executed)
  - `modified` step:test:12: condition_removed (if: "${{ matrix.os == 'ubuntu-latest' && matrix.node == '24' }}" -> 'None') (original run: executed)

## fastapi_71003515000

- [job](https://github.com/fastapi/fastapi/actions/runs/24319718336/job/71003515000) — target `test`, matrix `{"os": "macos-latest", "python-version": "3.10", "coverage": "coverage", "uv-resolution": "lowest-direct"}`; ground truth: matched (9/10 steps executed)
- **reducer:claude-haiku-4-5-20251001**: matrix correct; required steps 9/12; modified 3; added {'setup': 0, 'other': 0}
  - `outputs` required job changes removed
  - `setup_prefix` step removed: actions/checkout@v6
  - `outputs` step removed: dorny/paths-filter@v4
  - `conditional_step` step removed: Install Starlette from source (original run: not_executed)
  - `modified` step:test:5: condition_removed (if: "matrix.uv-resolution == 'lowest-direct'" -> 'None') (original run: executed)
  - `modified` step:test:8: env (original run: executed)
  - `modified` step:test:9: with, condition_removed (if: "matrix.coverage == 'coverage'" -> 'None') (original run: executed)
- **reducer_B:claude-haiku-4-5-20251001**: matrix correct; required steps 9/12; modified 3; added {'setup': 0, 'other': 0}
  - `outputs` required job changes removed
  - `setup_prefix` step removed: actions/checkout@v6
  - `outputs` step removed: dorny/paths-filter@v4
  - `conditional_step` step removed: Install Starlette from source (original run: not_executed)
  - `modified` step:test:5: condition_removed (if: "matrix.uv-resolution == 'lowest-direct'" -> 'None') (original run: executed)
  - `modified` step:test:8: env (original run: executed)
  - `modified` step:test:9: with, condition_removed (if: "matrix.coverage == 'coverage'" -> 'None') (original run: executed)

## formatjs_74489692796

- [job](https://github.com/formatjs/formatjs/actions/runs/25397962161/job/74489692796) — target `test`, matrix `{"os": "ubuntu-latest", "bazel-config": "ci"}`; ground truth: matched (4/4 steps executed)
- **reducer:claude-haiku-4-5-20251001**: matrix correct; required steps 4/4; modified 2; added {'setup': 0, 'other': 0}
  - `modified` step:test:2: condition (if: "matrix.os != 'macos-latest' || github.event_name != 'pull_request'" -> "github.event_name != 'pull_request'") (original run: executed)
  - `modified` step:test:3: condition (if: "matrix.os != 'macos-latest' || github.event_name != 'pull_request'" -> "github.event_name != 'pull_request'") (original run: executed)
- **reducer_B:claude-haiku-4-5-20251001**: matrix correct; required steps 4/4; modified 2; added {'setup': 0, 'other': 0}
  - `modified` step:test:2: condition (if: "matrix.os != 'macos-latest' || github.event_name != 'pull_request'" -> "github.event_name != 'pull_request'") (original run: executed)
  - `modified` step:test:3: condition (if: "matrix.os != 'macos-latest' || github.event_name != 'pull_request'" -> "github.event_name != 'pull_request'") (original run: executed)

## fory_77650013374

- [job](https://github.com/apache/fory/actions/runs/26380987511/job/77650013374) — target `java`, matrix `{"java-version": "8"}`; ground truth: matched (6/6 steps executed)
- **reducer:claude-haiku-4-5-20251001**: matrix correct; required steps 6/8; modified 1; added {'setup': 0, 'other': 0}
  - `outputs` required job changes removed
  - `outputs` step removed: Detect changed paths
  - `setup_prefix` step removed: actions/checkout@v5
  - `modified` step:java:5: with (original run: executed)
- **reducer_B:claude-haiku-4-5-20251001**: matrix correct; required steps 6/8; modified 1; added {'setup': 0, 'other': 0}
  - `outputs` required job changes removed
  - `outputs` step removed: Detect changed paths
  - `setup_prefix` step removed: actions/checkout@v5
  - `modified` step:java:5: with (original run: executed)

## geany_58662163283

- [job](https://github.com/geany/geany/actions/runs/20417024821/job/58662163283) — target `linux`, matrix `{"binreloc": "no"}`; ground truth: uncertain: header 'cd _build' fits steps 6 and 8 equally
- **reducer:claude-haiku-4-5-20251001**: matrix not_observable; required steps 10/10; modified 1; added {'setup': 0, 'other': 0}
  - `modified` step:linux:2: with
- **reducer_B:claude-haiku-4-5-20251001**: matrix not_observable; required steps 10/10; modified 1; added {'setup': 0, 'other': 0}
  - `modified` step:linux:2: with

## git_65741608537

- [job](https://github.com/git/git/actions/runs/22678401145/job/65741608537) — target `dockerized`, matrix `{"vector": {"jobname": "linux-meson", "image": "ubuntu:rolling", "cc": "gcc"}}`; ground truth: matched (8/9 steps executed)
- **reducer:claude-haiku-4-5-20251001**: matrix not_observable; required steps 8/12; modified 0; added {'setup': 0, 'other': 0}
  - `outputs` required job ci-config removed
  - `outputs` step removed: skip if the commit or tree was already tested
  - `outputs` step removed: check whether CI is enabled for ref
  - `setup_prefix` step removed: try to clone ci-config branch
  - `conditional_step` step removed: prepare libc6 for actions (original run: not_executed)
- **reducer_B:claude-haiku-4-5-20251001**: matrix not_observable; required steps 11/12; modified 1; added {'setup': 0, 'other': 0}
  - `conditional_step` step removed: prepare libc6 for actions (original run: not_executed)
  - `modified` step:ci-config:2: with

## grpc-go_73344851873

- [job](https://github.com/grpc/grpc-go/actions/runs/25041269333/job/73344851873) — target `tests`, matrix `{"type": "tests", "goversion": "1.26", "display_name": "tests (latest)"}`; ground truth: matched (3/7 steps executed)
- **reducer:claude-haiku-4-5-20251001**: matrix correct; required steps 3/7; modified 1; added {'setup': 0, 'other': 0}
  - `conditional_step` step removed: Setup GOARCH (original run: not_executed)
  - `conditional_step` step removed: Setup GRPC environment (original run: not_executed)
  - `conditional_step` step removed: Run vet.sh (original run: not_executed)
  - `conditional_step` step removed: Run extras tests (original run: not_executed)
  - `modified` step:tests:5: condition_removed (if: "matrix.type == 'tests'" -> 'None') (original run: executed)
- **reducer_B:claude-haiku-4-5-20251001**: matrix correct; required steps 3/7; modified 1; added {'setup': 0, 'other': 0}
  - `conditional_step` step removed: Setup GOARCH (original run: not_executed)
  - `conditional_step` step removed: Setup GRPC environment (original run: not_executed)
  - `conditional_step` step removed: Run vet.sh (original run: not_executed)
  - `conditional_step` step removed: Run extras tests (original run: not_executed)
  - `modified` step:tests:5: condition_removed (if: "matrix.type == 'tests'" -> 'None') (original run: executed)

## httpcomponents-core_64658584619

- [job](https://github.com/apache/httpcomponents-core/actions/runs/22345395374/job/64658584619) — target `build`, matrix `{"os": "ubuntu-latest", "java": 21}`; ground truth: matched (4/4 steps executed)
- **reducer:claude-haiku-4-5-20251001**: matrix correct; required steps 4/4; modified 0; added {'setup': 0, 'other': 0}
- **reducer_B:claude-haiku-4-5-20251001**: matrix correct; required steps 4/4; modified 1; added {'setup': 0, 'other': 0}
  - `modified` step:build:1: with (original run: executed)

## hugo_78255153205

- [job](https://github.com/gohugoio/hugo/actions/runs/26564380697/job/78255153205) — target `test`, matrix `{"go-version": "1.25.x", "os": "ubuntu-latest"}`; ground truth: uncertain: header 'echo "Install Dart Sass version ${SASS_VERSION} ..."' fits steps 16 and 17 equally
- **reducer:claude-haiku-4-5-20251001**: matrix correct; required steps 19/25; modified 8; added {'setup': 0, 'other': 0}
  - `shell_or_setup` step removed: brew install pandoc
  - `shell_or_setup` step removed: choco install pandoc
  - `shell_or_setup` step removed: choco install mingw
  - `environment` step removed: Install dart-sass MacOS
  - `shell_or_setup` step removed: Install dart-sass Windows
  - `shell_or_setup` step removed: Test
  - `modified` step:test:0: condition_removed (if: "matrix.os == 'ubuntu-latest'" -> 'None')
  - `modified` step:test:11: condition_removed (if: "matrix.os == 'ubuntu-latest'" -> 'None')
  - `modified` step:test:16: condition_removed (if: "matrix.os == 'ubuntu-latest'" -> 'None')
  - `modified` step:test:19: condition_removed (if: "matrix.os == 'ubuntu-latest'" -> 'None')
  - `modified` step:test:20: condition_removed (if: "matrix.os == 'ubuntu-latest'" -> 'None')
  - `modified` step:test:21: condition_removed (if: "matrix.os == 'ubuntu-latest'" -> 'None')
  - `modified` step:test:22: condition_removed (if: "matrix.os != 'windows-latest'" -> 'None')
  - `modified` step:test:24: condition_removed (if: "matrix.os == 'ubuntu-latest'" -> 'None')
- **reducer_B:claude-haiku-4-5-20251001**: matrix correct; required steps 19/25; modified 8; added {'setup': 0, 'other': 0}
  - `shell_or_setup` step removed: brew install pandoc
  - `shell_or_setup` step removed: choco install pandoc
  - `shell_or_setup` step removed: choco install mingw
  - `environment` step removed: Install dart-sass MacOS
  - `shell_or_setup` step removed: Install dart-sass Windows
  - `shell_or_setup` step removed: Test
  - `modified` step:test:0: condition_removed (if: "matrix.os == 'ubuntu-latest'" -> 'None')
  - `modified` step:test:11: condition_removed (if: "matrix.os == 'ubuntu-latest'" -> 'None')
  - `modified` step:test:16: condition_removed (if: "matrix.os == 'ubuntu-latest'" -> 'None')
  - `modified` step:test:19: condition_removed (if: "matrix.os == 'ubuntu-latest'" -> 'None')
  - `modified` step:test:20: condition_removed (if: "matrix.os == 'ubuntu-latest'" -> 'None')
  - `modified` step:test:21: condition_removed (if: "matrix.os == 'ubuntu-latest'" -> 'None')
  - `modified` step:test:22: condition_removed (if: "matrix.os != 'windows-latest'" -> 'None')
  - `modified` step:test:24: condition_removed (if: "matrix.os == 'ubuntu-latest'" -> 'None')

## libgit2_75529566960

- [job](https://github.com/libgit2/libgit2/actions/runs/25723295327/job/75529566960) — target `build`, matrix `{"platform": {"name": "Linux (Noble, GCC, OpenSSL, libssh2)", "id": "noble-gcc-openssl", "os": "ubuntu-latest", "container": {"name": "noble"}, "env": {"CC": "gcc", "CMAKE_GENERATOR": "Ninja", "CMAKE_OPTIONS": "-DUSE_HTTPS=OpenSSL -DREGEX_BACKEND=builtin -DDEBUG_LEAK_CHECKER=valgrind -DUSE_GSSAPI=ON -DUSE_SSH=libssh2 -DDEBUG_STRICT_ALLOC=ON -DDEBUG_STRICT_OPEN=ON"}}}`; ground truth: matched (6/8 steps executed)
- **reducer:claude-haiku-4-5-20251001**: matrix correct; required steps 6/8; modified 0; added {'setup': 0, 'other': 0}
  - `conditional_step` step removed: Set up build environment (original run: not_executed)
  - `conditional_step` step removed: Setup QEMU (original run: not_executed)
- **reducer_B:claude-haiku-4-5-20251001**: matrix correct; required steps 8/8; modified 0; added {'setup': 0, 'other': 0}

## librosa_79302893434

- [job](https://github.com/librosa/librosa/actions/runs/26887254458/job/79302893434) — target `test`, matrix `{"os": "ubuntu-latest", "python-version": "3.12", "envfile": ".github/environment-minimal.yml", "channel-priority": "strict", "variant": "minimal"}`; ground truth: matched (10/13 steps executed)
- **reducer:claude-haiku-4-5-20251001**: matrix incorrect; required steps 10/13; modified 2; added {'setup': 0, 'other': 0}
  - `conditional_step` step removed: Create short temp directory (Windows only) (original run: not_executed)
  - `conditional_step` step removed: Set environment variables (Windows only) (original run: not_executed)
  - `conditional_step` step removed: Upload image comparison failures if any (original run: not_executed)
  - `matrix` incorrect: envfile: another combination's value in step:test:7
  - `modified` step:test:6: with (original run: executed)
  - `modified` step:test:7: command (original run: executed)
    ```diff
    -mamba env update -n test -f .github/environment-minimal.yml
    +mamba env update -n test -f .github/environment-ci.yml
    ```
- **reducer_B:claude-haiku-4-5-20251001**: matrix incorrect; required steps 11/13; modified 2; added {'setup': 0, 'other': 0}
  - `conditional_step` step removed: Create short temp directory (Windows only) (original run: not_executed)
  - `conditional_step` step removed: Set environment variables (Windows only) (original run: not_executed)
  - `matrix` incorrect: envfile: another combination's value in step:test:7
  - `modified` step:test:6: with (original run: executed)
  - `modified` step:test:7: command (original run: executed)
    ```diff
    -mamba env update -n test -f .github/environment-minimal.yml
    +mamba env update -n test -f .github/environment-ci.yml
    ```

## libunwind_78113445933

- [job](https://github.com/libunwind/libunwind/actions/runs/26521478739/job/78113445933) — target `build-gnu-cross`, matrix `{"config": {"target": "arm", "host": "arm-linux-gnueabi", "qemu": "arm", "gccver": 14, "container": "ubuntu:26.04"}}`; ground truth: matched (7/8 steps executed)
- **reducer:claude-haiku-4-5-20251001**: matrix not_observable; required steps 8/8; modified 4; added {'setup': 0, 'other': 0}
  - `modified` step:build-gnu-cross:2: command (original run: executed)
    ```diff
    -                   ${{ matrix.config.packages || format('g++-{0}-{1}', matrix.config.gccver, matrix.config.host) }} \
    +                   g++-14-arm-linux-gnueabi \
    ```
  - `modified` step:build-gnu-cross:3: env (original run: executed)
  - `modified` step:build-gnu-cross:5: command (original run: executed)
    ```diff
    -case arm in
    -aarch64|riscv*|s390x|x86*)
    -    make -C build/src abi-check
    -    ;;
    -*)
    -    srcdir=$(pwd)
    -    cd build/tests
    -    ./check-namespace.sh
    ... 5 more
    ```
  - `modified` step:build-gnu-cross:6: command, env (original run: executed)
    ```diff
    -make check -j$(nproc) LOG_DRIVER_FLAGS="--qemu-arch arm${{ matrix.config.qemu_skip && format(' --qemu-skip={0}', matrix.config.qemu_skip) || '' }}" \
    -           QEMU_LD_PREFIX="$CROSS_LIB" \
    -           LDFLAGS="-L$CROSS_LIB/lib"
    +make check -j$(nproc) LOG_DRIVER_FLAGS="--qemu-arch arm" \
    +           QEMU_LD_PREFIX="/usr/arm-linux-gnueabi" \
    +           LDFLAGS="-L/usr/arm-linux-gnueabi/lib"
    ```
- **reducer_B:claude-haiku-4-5-20251001**: matrix not_observable; required steps 8/8; modified 4; added {'setup': 0, 'other': 0}
  - `modified` step:build-gnu-cross:2: command (original run: executed)
    ```diff
    -                   ${{ matrix.config.packages || format('g++-{0}-{1}', matrix.config.gccver, matrix.config.host) }} \
    +                   g++-14-arm-linux-gnueabi \
    ```
  - `modified` step:build-gnu-cross:3: env (original run: executed)
  - `modified` step:build-gnu-cross:5: command (original run: executed)
    ```diff
    -case arm in
    -aarch64|riscv*|s390x|x86*)
    -    make -C build/src abi-check
    -    ;;
    -*)
    -    srcdir=$(pwd)
    -    cd build/tests
    -    ./check-namespace.sh
    ... 5 more
    ```
  - `modified` step:build-gnu-cross:6: command, env (original run: executed)
    ```diff
    -make check -j$(nproc) LOG_DRIVER_FLAGS="--qemu-arch arm${{ matrix.config.qemu_skip && format(' --qemu-skip={0}', matrix.config.qemu_skip) || '' }}" \
    +make check -j$(nproc) LOG_DRIVER_FLAGS="--qemu-arch arm" \
    ```

## libvips_75052905094

- [job](https://github.com/libvips/libvips/actions/runs/25567011656/job/75052905094) — target `CI`, matrix `{"name": "Linux x64 (Ubuntu 24.04) - GCC 14", "os": "ubuntu-24.04", "build": {"cc": "gcc-14", "cxx": "g++-14", "linker": "ld", "docs": true}}`; ground truth: matched (9/15 steps executed)
- **reducer:claude-haiku-4-5-20251001**: matrix not_observable; required steps 9/15; modified 5; added {'setup': 0, 'other': 0}
  - `conditional_step` step removed: Install macOS dependencies (original run: not_executed)
  - `conditional_step` step removed: Install Clang 19 (original run: not_executed)
  - `conditional_step` step removed: Prepare macOS environment (original run: not_executed)
  - `conditional_step` step removed: Prepare sanitizers environment (original run: not_executed)
  - `conditional_step` step removed: Prepare ASan/UBSan (original run: not_executed)
  - `conditional_step` step removed: Prepare TSan (original run: not_executed)
  - `modified` step:CI:1: condition_removed (if: "runner.os == 'Linux'" -> 'None') (original run: executed)
  - `modified` step:CI:8: command (original run: executed)
    ```diff
    -meson setup build -Ddebug=true -Ddeprecated=false -Dmagick=disabled -Ddocs=${{ matrix.build.docs || 'false' }} -Dintrospection=${{ matrix.build.docs && 'enable
    +meson setup build -Ddebug=true -Ddeprecated=false -Dmagick=disabled -Ddocs=true -Dintrospection=enabled -Db_sanitize=none -Db_lundef=true || (cat build/meson-l
    ```
  - `modified` step:CI:10: command (original run: executed)
    ```diff
    -meson test -C build --timeout-multiplier=${{ matrix.build.sanitize == 'thread' && '0' || '1' }} || (cat build/meson-logs/testlog.txt && exit 1)
    +meson test -C build --timeout-multiplier=1 || (cat build/meson-logs/testlog.txt && exit 1)
    ```
  - `modified` step:CI:12: condition_removed (if: "runner.os == 'Linux'" -> 'None') (original run: executed)
  - `modified` step:CI:14: env (original run: executed)
- **reducer_B:claude-haiku-4-5-20251001**: matrix not_observable; required steps 9/15; modified 5; added {'setup': 0, 'other': 0}
  - `conditional_step` step removed: Install macOS dependencies (original run: not_executed)
  - `conditional_step` step removed: Install Clang 19 (original run: not_executed)
  - `conditional_step` step removed: Prepare macOS environment (original run: not_executed)
  - `conditional_step` step removed: Prepare sanitizers environment (original run: not_executed)
  - `conditional_step` step removed: Prepare ASan/UBSan (original run: not_executed)
  - `conditional_step` step removed: Prepare TSan (original run: not_executed)
  - `modified` step:CI:1: condition_removed (if: "runner.os == 'Linux'" -> 'None') (original run: executed)
  - `modified` step:CI:8: command (original run: executed)
    ```diff
    -meson setup build -Ddebug=true -Ddeprecated=false -Dmagick=disabled -Ddocs=${{ matrix.build.docs || 'false' }} -Dintrospection=${{ matrix.build.docs && 'enable
    +meson setup build \
    +  -Ddebug=true \
    +  -Ddeprecated=false \
    +  -Dmagick=disabled \
    +  -Ddocs=true \
    +  -Dintrospection=enabled \
    +  -Db_sanitize=none \
    ... 2 more
    ```
  - `modified` step:CI:10: command (original run: executed)
    ```diff
    -meson test -C build --timeout-multiplier=${{ matrix.build.sanitize == 'thread' && '0' || '1' }} || (cat build/meson-logs/testlog.txt && exit 1)
    +meson test -C build --timeout-multiplier=1 \
    +|| (cat build/meson-logs/testlog.txt && exit 1)
    ```
  - `modified` step:CI:12: condition_removed (if: "runner.os == 'Linux'" -> 'None') (original run: executed)
  - `modified` step:CI:14: env (original run: executed)

## livekit_69988794904

- [job](https://github.com/livekit/livekit/actions/runs/23997818858/job/69988794904) — target `test`, matrix `{}`; ground truth: matched (10/10 steps executed)
- **reducer:claude-haiku-4-5-20251001**: matrix n/a; required steps 10/10; modified 0; added {'setup': 0, 'other': 0}
- **reducer_B:claude-haiku-4-5-20251001**: matrix n/a; required steps 10/10; modified 0; added {'setup': 0, 'other': 0}

## metro_62930784333

- [job](https://github.com/react/metro/actions/runs/21813637858/job/62930784333) — target `test`, matrix `{}`; ground truth: matched (3/3 steps executed)
- **reducer:claude-haiku-4-5-20251001**: matrix n/a; required steps 2/3; modified 1; added {'setup': 1, 'other': 1}
  - `reusable_workflow` required job test removed
  - `shell_or_setup` step removed: Run Jest Tests (original run: executed)
  - `added_setup` test[1]: actions/setup-node@v4
  - `modified` step:test/test:1: with (original run: executed)
  - `invented` test[3]: yarn test
- **reducer_B:claude-haiku-4-5-20251001**: matrix n/a; required steps 0/3; modified 0; added {'setup': 0, 'other': 0}
  - `reusable_workflow` required job test removed
  - `shell_or_setup` step removed: actions/checkout@v6 (original run: executed)
  - `shell_or_setup` step removed: Run Jest Tests (original run: executed)
  - `environment` step removed: ./.github/actions/yarn-install (original run: executed)

## minimizer-webpack-plugin_74315927769

- [job](https://github.com/webpack/minimizer-webpack-plugin/actions/runs/25346307338/job/74315927769) — target `test`, matrix `{"os": "ubuntu-latest", "node-version": "14.x", "webpack-version": "latest"}`; ground truth: no original log
- **reducer:claude-haiku-4-5-20251001**: matrix correct; required steps 7/11; modified 3; added {'setup': 0, 'other': 0}
  - `shell_or_setup` step removed: Setup Git
  - `shell_or_setup` step removed: Install dependencies
  - `shell_or_setup` step removed: Install older cssnano (Node 10/12)
  - `shell_or_setup` step removed: Install webpack latest
  - `modified` step:test:2: with
  - `modified` step:test:4: condition_removed (if: "matrix.node-version == '10.x' || matrix.node-version == '12.x' || matrix.node-ve" -> 'None')
  - `modified` step:test:7: condition_removed (if: "matrix.node-version == '14.x' || matrix.node-version == '16.x'" -> 'None')
- **reducer_B:claude-haiku-4-5-20251001**: matrix correct; required steps 7/11; modified 3; added {'setup': 0, 'other': 0}
  - `shell_or_setup` step removed: Setup Git
  - `shell_or_setup` step removed: Install dependencies
  - `shell_or_setup` step removed: Install older cssnano (Node 10/12)
  - `shell_or_setup` step removed: Install webpack latest
  - `modified` step:test:2: with
  - `modified` step:test:4: condition_removed (if: "matrix.node-version == '10.x' || matrix.node-version == '12.x' || matrix.node-ve" -> 'None')
  - `modified` step:test:7: condition_removed (if: "matrix.node-version == '14.x' || matrix.node-version == '16.x'" -> 'None')

## mockito_61079113276

- [job](https://github.com/mockito/mockito/actions/runs/21227761801/job/61079113276) — target `java`, matrix `{"java": 11, "entry": {"mock-maker": "mock-maker-subclass", "member-accessor": "member-accessor-reflection"}}`; ground truth: matched (3/8 steps executed)
- **reducer:claude-haiku-4-5-20251001**: matrix correct; required steps 3/8; modified 0; added {'setup': 0, 'other': 0}
  - `conditional_step` step removed: 7. Generate coverage report (original run: not_executed)
  - `conditional_step` step removed: 4. Build and check reproducibility of artifacts (single job only) (original run: not_executed)
  - `conditional_step` step removed: 5. Spotless check (single job only). Run './gradlew spotlessApply' locally if th (original run: not_executed)
  - `conditional_step` step removed: 3. Validate Gradle wrapper (original run: not_executed)
  - `conditional_step` step removed: 8. Upload coverage report (original run: not_executed)
- **reducer_B:claude-haiku-4-5-20251001**: matrix correct; required steps 8/8; modified 3; added {'setup': 0, 'other': 0}
  - `modified` step:java:2: condition_removed (if: "matrix.java == 11 && matrix.entry.mock-maker == 'mock-maker-default'" -> 'None') (original run: not_executed)
  - `modified` step:java:3: condition_removed (if: "matrix.java == 11 && matrix.entry.mock-maker == 'mock-maker-default'" -> 'None') (original run: not_executed)
  - `modified` step:java:4: condition_removed (if: "matrix.java == 11 && matrix.entry.mock-maker == 'mock-maker-default'" -> 'None') (original run: not_executed)

## mockito_67468732165

- [job](https://github.com/mockito/mockito/actions/runs/23213652081/job/67468732165) — target `java`, matrix `{"java": 11, "entry": {"mock-maker": "mock-maker-inline", "member-accessor": "member-accessor-module"}}`; ground truth: matched (5/8 steps executed)
- **reducer:claude-haiku-4-5-20251001**: matrix correct; required steps 5/8; modified 0; added {'setup': 0, 'other': 0}
  - `conditional_step` step removed: 4. Build and check reproducibility of artifacts (single job only) (original run: not_executed)
  - `conditional_step` step removed: 5. Spotless check (single job only). Run './gradlew spotlessApply' locally if th (original run: not_executed)
  - `conditional_step` step removed: 3. Validate Gradle wrapper (original run: not_executed)
- **reducer_B:claude-haiku-4-5-20251001**: matrix correct; required steps 8/8; modified 3; added {'setup': 0, 'other': 0}
  - `modified` step:java:2: condition_removed (if: "matrix.java == 11 && matrix.entry.mock-maker == 'mock-maker-default'" -> 'None') (original run: not_executed)
  - `modified` step:java:3: condition_removed (if: "matrix.java == 11 && matrix.entry.mock-maker == 'mock-maker-default'" -> 'None') (original run: not_executed)
  - `modified` step:java:4: condition_removed (if: "matrix.java == 11 && matrix.entry.mock-maker == 'mock-maker-default'" -> 'None') (original run: not_executed)

## notify_72052084636

- [job](https://github.com/notify-rs/notify/actions/runs/24643626017/job/72052084636) — target `test`, matrix `{"os": "ubuntu-latest", "rust": "nightly"}`; ground truth: matched (7/10 steps executed)
- **reducer:claude-haiku-4-5-20251001**: matrix correct; required steps 7/10; modified 0; added {'setup': 0, 'other': 0}
  - `conditional_step` step removed: Remove rust-toolchain.toml (Windows) (original run: not_executed)
  - `conditional_step` step removed: Run tests with tokio (original run: not_executed)
  - `conditional_step` step removed: Run tests with futures (original run: not_executed)
- **reducer_B:claude-haiku-4-5-20251001**: matrix correct; required steps 7/10; modified 1; added {'setup': 0, 'other': 0}
  - `conditional_step` step removed: Remove rust-toolchain.toml (Windows) (original run: not_executed)
  - `conditional_step` step removed: Run tests with tokio (original run: not_executed)
  - `conditional_step` step removed: Run tests with futures (original run: not_executed)
  - `modified` step:test:1: condition_removed (if: "runner.os != 'Windows'" -> 'None') (original run: executed)

## oauth2-proxy_68156636395

- [job](https://github.com/oauth2-proxy/oauth2-proxy/actions/runs/23430855554/job/68156636395) — target `build`, matrix `{}`; ground truth: matched (8/13 steps executed)
- **reducer:claude-haiku-4-5-20251001**: matrix n/a; required steps 8/13; modified 0; added {'setup': 0, 'other': 0}
  - `conditional_step` step removed: Build All (original run: not_executed)
  - `conditional_step` step removed: Generate Coverage Report (original run: not_executed)
  - `conditional_step` step removed: Upload Coverage Report (original run: not_executed)
  - `conditional_step` step removed: Run Trivy vulnerability scanner (original run: not_executed)
  - `conditional_step` step removed: Upload Trivy scan results (original run: not_executed)
- **reducer_B:claude-haiku-4-5-20251001**: matrix n/a; required steps 13/13; modified 0; added {'setup': 0, 'other': 0}

## ollama_70708388185

- [job](https://github.com/ollama/ollama/actions/runs/24219762283/job/70708388185) — target `test`, matrix `{"os": "windows-latest"}`; ground truth: matched (7/9 steps executed)
- **reducer:claude-haiku-4-5-20251001**: matrix correct; required steps 7/9; modified 1; added {'setup': 0, 'other': 0}
  - `conditional_step` step removed: Run UI tests (original run: not_executed)
  - `conditional_step` step removed: golangci/golangci-lint-action@v9 (original run: not_executed)
  - `modified` step:test:7: condition_removed (if: 'always()' -> 'None') (original run: executed)
- **reducer_B:claude-haiku-4-5-20251001**: matrix correct; required steps 8/9; modified 0; added {'setup': 0, 'other': 0}
  - `conditional_step` step removed: Run UI tests (original run: not_executed)

## openvpn_71968198030

- [job](https://github.com/OpenVPN/openvpn/actions/runs/24612109122/job/71968198030) — target `mbedtls4`, matrix `{"os": "ubuntu-24.04", "ssllib": "mbedtls4", "build": "normal", "cflags": "-O2 -g", "ldflags": "", "cc": "gcc"}`; ground truth: matched (14/14 steps executed)
- **reducer:claude-haiku-4-5-20251001**: matrix correct; required steps 14/14; modified 1; added {'setup': 0, 'other': 0}
  - `modified` step:mbedtls4:4: command (original run: executed)
    ```diff
    -cmake -B build -DCMAKE_INSTALL_PREFIX=${{ env.MBEDTLS_INSTAL }}
    +cmake -B build -DCMAKE_INSTALL_PREFIX=/opt/mbedtls4
    ```
- **reducer_B:claude-haiku-4-5-20251001**: matrix correct; required steps 14/14; modified 1; added {'setup': 0, 'other': 0}
  - `modified` step:mbedtls4:4: command (original run: executed)
    ```diff
    -cmake -B build -DCMAKE_INSTALL_PREFIX=${{ env.MBEDTLS_INSTAL }}
    +cmake -B build -DCMAKE_INSTALL_PREFIX=/opt/mbedtls4
    ```

## pycsw_72003735814

- [job](https://github.com/geopython/pycsw/actions/runs/24625527470/job/72003735814) — target `main`, matrix `{"python-version": "3.12", "toxenv": "py312-sqlite"}`; ground truth: matched (6/6 steps executed)
- **reducer:claude-haiku-4-5-20251001**: matrix correct; required steps 6/6; modified 0; added {'setup': 0, 'other': 0}
- **reducer_B:claude-haiku-4-5-20251001**: matrix correct; required steps 6/6; modified 0; added {'setup': 0, 'other': 0}

## pyinstaller_60034109922

- [job](https://github.com/pyinstaller/pyinstaller/actions/runs/20895794852/job/60034109922) — target `tests`, matrix `{"python-version": "3.11", "os": "ubuntu-24.04"}`; ground truth: uncertain: header 'import os' fits steps 23 and 26 equally
- **reducer:claude-haiku-4-5-20251001**: matrix correct; required steps 27/28; modified 9; added {'setup': 0, 'other': 0}
  - `shell_or_setup` step removed: Check if bootloader is buildable for Windows ARM
  - `modified` step:tests:2: condition_removed (if: "startsWith(matrix.os, 'ubuntu')" -> 'None')
  - `modified` step:tests:3: condition_removed (if: "startsWith(matrix.os, 'ubuntu')" -> 'None')
  - `modified` step:tests:4: condition_removed (if: "startsWith(matrix.os, 'ubuntu')" -> 'None')
  - `modified` step:tests:7: condition_removed (if: "startsWith(matrix.os, 'ubuntu')" -> 'None')
  - `modified` step:tests:8: condition_removed (if: "startsWith(matrix.os, 'ubuntu')" -> 'None')
  - `modified` step:tests:9: condition_removed (if: "startsWith(matrix.os, 'ubuntu')" -> 'None')
  - `modified` step:tests:18: condition_removed (if: "${{ !endsWith(matrix.python-version, '-dev') && matrix.python-version != '3.13t'" -> 'None')
  - `modified` step:tests:19: command
    ```diff
    -  spec = None  # setuptools or setuptools._vendor does not exist
    +  spec = None
    ```
  - `modified` step:tests:20: condition_removed (if: "startsWith(matrix.os, 'ubuntu')" -> 'None')
- **reducer_B:claude-haiku-4-5-20251001**: matrix correct; required steps 27/28; modified 9; added {'setup': 0, 'other': 0}
  - `shell_or_setup` step removed: Check if bootloader is buildable for Windows ARM
  - `modified` step:tests:2: condition_removed (if: "startsWith(matrix.os, 'ubuntu')" -> 'None')
  - `modified` step:tests:3: condition_removed (if: "startsWith(matrix.os, 'ubuntu')" -> 'None')
  - `modified` step:tests:4: condition_removed (if: "startsWith(matrix.os, 'ubuntu')" -> 'None')
  - `modified` step:tests:7: condition_removed (if: "startsWith(matrix.os, 'ubuntu')" -> 'None')
  - `modified` step:tests:8: condition_removed (if: "startsWith(matrix.os, 'ubuntu')" -> 'None')
  - `modified` step:tests:9: condition_removed (if: "startsWith(matrix.os, 'ubuntu')" -> 'None')
  - `modified` step:tests:18: condition_removed (if: "${{ !endsWith(matrix.python-version, '-dev') && matrix.python-version != '3.13t'" -> 'None')
  - `modified` step:tests:19: command
    ```diff
    -  spec = None  # setuptools or setuptools._vendor does not exist
    +  spec = None
    ```
  - `modified` step:tests:20: condition_removed (if: "startsWith(matrix.os, 'ubuntu')" -> 'None')

## re2c_63318868213

- [job](https://github.com/skvadrik/re2c/actions/runs/21926098992/job/63318868213) — target `build-and-test`, matrix `{"name": "linux-gcc-ubsan-ootree", "os": "ubuntu-latest"}`; ground truth: uncertain: header 'actions/cache@v5' fits steps 1 and 2 equally
- **reducer:claude-haiku-4-5-20251001**: matrix correct; required steps 15/18; modified 3; added {'setup': 0, 'other': 0}
  - `shell_or_setup` step removed: Setup chocolatey Cache (Windows)
  - `shell_or_setup` step removed: Run Skeleton Tests
  - `shell_or_setup` step removed: Run Valgrind Tests
  - `modified` step:build-and-test:2: condition_removed (if: "startsWith(runner.os, 'Linux')" -> 'None')
  - `modified` step:build-and-test:3: command
    ```diff
    -    sudo apt install gcc-multilib g++-multilib  # for -m32
    +    sudo apt install gcc-multilib g++-multilib
    -  macOS*)
    -    sudo xcode-select -switch /Applications/Xcode.app
    -    echo "SDKROOT=$(xcodebuild -version -sdk macosx Path)" >> $GITHUB_ENV
    -    echo "$(xcodebuild -version -sdk macosx Path)" >> $GITHUB_PATH
    -    brew install coreutils  # for `nproc`
    -    ;;
    ... 4 more
    ```
  - `modified` step:build-and-test:11: command
    ```diff
    -if echo "linux-gcc-ubsan-ootree" | grep -q "ootree"; then
    -  BUILD_DIR="${{ github.workspace }}/.build/linux-gcc-ubsan-ootree-full"
    -else
    -  BUILD_DIR="${{ github.workspace }}"
    -fi
    +BUILD_DIR="${{ github.workspace }}/.build/linux-gcc-ubsan-ootree-full"
    ```
- **reducer_B:claude-haiku-4-5-20251001**: matrix correct; required steps 15/18; modified 3; added {'setup': 0, 'other': 0}
  - `shell_or_setup` step removed: Setup chocolatey Cache (Windows)
  - `shell_or_setup` step removed: Run Skeleton Tests
  - `shell_or_setup` step removed: Run Valgrind Tests
  - `modified` step:build-and-test:2: condition_removed (if: "startsWith(runner.os, 'Linux')" -> 'None')
  - `modified` step:build-and-test:3: command
    ```diff
    -    sudo apt install gcc-multilib g++-multilib  # for -m32
    +    sudo apt install gcc-multilib g++-multilib
    -  macOS*)
    -    sudo xcode-select -switch /Applications/Xcode.app
    -    echo "SDKROOT=$(xcodebuild -version -sdk macosx Path)" >> $GITHUB_ENV
    -    echo "$(xcodebuild -version -sdk macosx Path)" >> $GITHUB_PATH
    -    brew install coreutils  # for `nproc`
    -    ;;
    ... 4 more
    ```
  - `modified` step:build-and-test:11: command
    ```diff
    -if echo "linux-gcc-ubsan-ootree" | grep -q "ootree"; then
    -  BUILD_DIR="${{ github.workspace }}/.build/linux-gcc-ubsan-ootree-full"
    -else
    -  BUILD_DIR="${{ github.workspace }}"
    -fi
    +BUILD_DIR="${{ github.workspace }}/.build/linux-gcc-ubsan-ootree-full"
    ```

## react-native_67316636441

- [job](https://github.com/react/react-native/actions/runs/23169066207/job/67316636441) — target `test_js`, matrix `{"node-version": "22"}`; ground truth: matched (2/2 steps executed)
- **reducer:claude-haiku-4-5-20251001**: matrix correct; required steps 2/4; modified 0; added {'setup': 0, 'other': 0}
  - `outputs` required job check_code_changes removed
  - `outputs` step removed: Check for code changes (exclusion patterns)
  - `setup_prefix` step removed: Checkout
- **reducer_B:claude-haiku-4-5-20251001**: matrix correct; required steps 2/4; modified 0; added {'setup': 0, 'other': 0}
  - `outputs` required job check_code_changes removed
  - `outputs` step removed: Check for code changes (exclusion patterns)
  - `setup_prefix` step removed: Checkout

## rocketmq_66917153122

- [job](https://github.com/apache/rocketmq/actions/runs/23038823731/job/66917153122) — target `java_build`, matrix `{"os": "ubuntu-latest", "jdk": 8}`; ground truth: matched (3/5 steps executed)
- **reducer:claude-haiku-4-5-20251001**: matrix correct; required steps 3/5; modified 0; added {'setup': 0, 'other': 0}
  - `conditional_step` step removed: Upload Auth JVM crash logs (original run: not_executed)
  - `conditional_step` step removed: Upload broker JVM crash logs (original run: not_executed)
- **reducer_B:claude-haiku-4-5-20251001**: matrix correct; required steps 5/5; modified 0; added {'setup': 0, 'other': 0}

## rtabmap_78550683778

- [job](https://github.com/introlab/rtabmap/actions/runs/26651473075/job/78550683778) — target `build`, matrix `{"build_name": "ubuntu-22.04", "os": "ubuntu-22.04", "extra_deps": "libunwind-dev libceres-dev", "extra_cmake_def": "-DWITH_CERES=ON -DWITH_PYTHON=ON"}`; ground truth: matched (9/10 steps executed)
- **reducer:claude-haiku-4-5-20251001**: matrix correct; required steps 10/10; modified 0; added {'setup': 0, 'other': 0}
- **reducer_B:claude-haiku-4-5-20251001**: matrix correct; required steps 10/10; modified 0; added {'setup': 0, 'other': 0}

## ruff_78920018102

- [job](https://github.com/astral-sh/ruff/actions/runs/26773803563/job/78920018102) — target `cargo-test-linux`, matrix `{}`; ground truth: matched (14/15 steps executed)
- **reducer:claude-haiku-4-5-20251001**: matrix n/a; required steps 15/26; modified 1; added {'setup': 0, 'other': 0}
  - `outputs` required job determine_changes removed
  - `outputs` step removed: Check if the formatter code changed
  - `outputs` step removed: Check if there was any playground related change
  - `outputs` step removed: Check if there was any code related change
  - `outputs` step removed: Check if the ty code changed
  - `outputs` step removed: Check if the py-fuzzer code changed
  - `outputs` step removed: Check if the fuzzer code changed
  - `outputs` step removed: Check if the parser code changed
  - `outputs` step removed: Determine merge base
  - `setup_prefix` step removed: actions/checkout@de0fac2e4500dabe0009e67214ff5f5447ce83dd
  - `setup_prefix` step removed: Fetch full history without tags
  - `outputs` step removed: Check if the linter code changed
  - `modified` step:cargo-test-linux:7: condition_removed (if: "${{ needs.determine_changes.outputs.ty == 'true' }}" -> 'None') (original run: not_executed)
- **reducer_B:claude-haiku-4-5-20251001**: matrix n/a; required steps 15/26; modified 0; added {'setup': 0, 'other': 0}
  - `outputs` required job determine_changes removed
  - `outputs` step removed: Check if the formatter code changed
  - `outputs` step removed: Check if there was any playground related change
  - `outputs` step removed: Check if there was any code related change
  - `outputs` step removed: Check if the ty code changed
  - `outputs` step removed: Check if the py-fuzzer code changed
  - `outputs` step removed: Check if the fuzzer code changed
  - `outputs` step removed: Check if the parser code changed
  - `outputs` step removed: Determine merge base
  - `setup_prefix` step removed: actions/checkout@de0fac2e4500dabe0009e67214ff5f5447ce83dd
  - `setup_prefix` step removed: Fetch full history without tags
  - `outputs` step removed: Check if the linter code changed

## rust-bitcoin_65941302388

- [job](https://github.com/rust-bitcoin/rust-bitcoin/actions/runs/22737121618/job/65941302388) — target `Arch32bit`, matrix `{}`; ground truth: matched (6/6 steps executed)
- **reducer:claude-haiku-4-5-20251001**: matrix n/a; required steps 6/6; modified 0; added {'setup': 0, 'other': 0}
- **reducer_B:claude-haiku-4-5-20251001**: matrix n/a; required steps 0/6; modified 0; added {'setup': 0, 'other': 0}
  - `no_output` reduced YAML has no jobs or steps

## rxdb_74518048225

- [job](https://github.com/pubkey/rxdb/actions/runs/25406340710/job/74518048225) — target `test-others-replications`, matrix `{}`; ground truth: matched (5/12 steps executed)
- **reducer:claude-haiku-4-5-20251001**: matrix n/a; required steps 5/12; modified 0; added {'setup': 0, 'other': 0}
  - `conditional_step` step removed: npm run test:replication-microsoft-onedrive (original run: not_executed)
  - `conditional_step` step removed: firestore replication (original run: not_executed)
  - `conditional_step` step removed: npm run test:replication-couchdb (original run: not_executed)
  - `conditional_step` step removed: nats replication (original run: not_executed)
  - `conditional_step` step removed: npm run supabase:stop (original run: not_executed)
  - `conditional_step` step removed: timeout 30m bash -c 'until npm run test:replication-supabase; do sleep 5; done' (original run: not_executed)
  - `conditional_step` step removed: npm run supabase:start (original run: not_executed)
- **reducer_B:claude-haiku-4-5-20251001**: matrix n/a; required steps 12/12; modified 0; added {'setup': 0, 'other': 0}

## strapi_74592890720

- [job](https://github.com/strapi/strapi/actions/runs/25429558316/job/74592890720) — target `unit_back`, matrix `{"node": 22}`; ground truth: matched (6/7 steps executed)
- **reducer:claude-haiku-4-5-20251001**: matrix correct; required steps 7/9; modified 1; added {'setup': 0, 'other': 0}
  - `outputs` required job conditions removed
  - `setup_prefix` step removed: actions/checkout@v6
  - `outputs` step removed: dorny/paths-filter@v3
  - `modified` step:unit_back:6: condition (if: 'matrix.node == 24' -> 'True') (original run: not_executed)
- **reducer_B:claude-haiku-4-5-20251001**: matrix correct; required steps 7/9; modified 1; added {'setup': 0, 'other': 0}
  - `outputs` required job conditions removed
  - `setup_prefix` step removed: actions/checkout@v6
  - `outputs` step removed: dorny/paths-filter@v3
  - `modified` step:unit_back:6: condition_removed (if: 'matrix.node == 24' -> 'None') (original run: not_executed)

## vitest_69622163223

- [job](https://github.com/vitest-dev/vitest/actions/runs/23877041911/job/69622163223) — target `test`, matrix `{"os": "ubuntu-latest", "node_version": 24}`; ground truth: matched (9/9 steps executed)
- **reducer:claude-haiku-4-5-20251001**: matrix correct; required steps 9/11; modified 0; added {'setup': 0, 'other': 0}
  - `outputs` required job changed removed
  - `setup_prefix` step removed: actions/checkout@v6
  - `outputs` step removed: Get changed files
- **reducer_B:claude-haiku-4-5-20251001**: matrix correct; required steps 9/11; modified 0; added {'setup': 0, 'other': 0}
  - `outputs` required job changed removed
  - `setup_prefix` step removed: actions/checkout@v6
  - `outputs` step removed: Get changed files

## wasmtime_66124639023

- [job](https://github.com/bytecodealliance/wasmtime/actions/runs/22793606887/job/66124639023) — target `test`, matrix `{}`; ground truth: uncertain: header 'python3 ./ci/run-tests.py --locked --exclude cranelift-tools' fits steps 20 and 19 equally
- **reducer:claude-haiku-4-5-20251001**: matrix n/a; required steps 6/23; modified 4; added {'setup': 0, 'other': 0}
  - `outputs` required job determine removed
  - `shell_or_setup` step removed: python3 ./ci/run-tests.py --locked ${{ matrix.bucket }}
  - `environment` step removed: Install qemu
  - `shell_or_setup` step removed: C:/msys64/usr/bin/pacman.exe -S --needed mingw-w64-x86_64-gcc --noconfirm
  - `environment` step removed: Configure ASAN
  - `shell_or_setup` step removed: actions/cache@v4
  - `environment` step removed: echo CARGO_BUILD_TARGET=${{ matrix.target }} >> $GITHUB_ENV
  - `environment` step removed: Install cross-compilation tools
  - `shell_or_setup` step removed: echo "C:\msys64\mingw64\bin" >> $Env:GITHUB_PATH
  - `environment` step removed: Install Intel SDE
  - `environment` step removed: Force-run with MPK enabled, if available
  - `environment` step removed: echo CFLAGS=-g0 >> $GITHUB_ENV
  - `outputs` step removed: touch commits.log names.log
  - `shell_or_setup` step removed: Install VTune
  - `setup_prefix` step removed: actions/checkout@v4
  - `shell_or_setup` step removed: CPU information
  - `shell_or_setup` step removed: actions/cache@v4
  - `shell_or_setup` step removed: CPU information
  - `modified` step:test:1: with
  - `modified` step:test:2: command
    ```diff
    -rustup target add wasm32-wasip1 wasm32-unknown-unknown ${{ matrix.target }}
    +rustup target add wasm32-wasip1 wasm32-unknown-unknown
    ```
  - `modified` step:test:14: condition_removed (if: "runner.os == 'Linux'" -> 'None')
  - `modified` step:test:19: command, condition_removed, shell (if: "runner.os == 'Windows'" -> 'None')
    ```diff
    -python3 ./ci/run-tests.py --locked ${{ matrix.bucket }}
    +python3 ./ci/run-tests.py --locked
    ```
- **reducer_B:claude-haiku-4-5-20251001**: matrix n/a; required steps 6/23; modified 4; added {'setup': 0, 'other': 0}
  - `outputs` required job determine removed
  - `shell_or_setup` step removed: python3 ./ci/run-tests.py --locked ${{ matrix.bucket }}
  - `environment` step removed: Install qemu
  - `shell_or_setup` step removed: C:/msys64/usr/bin/pacman.exe -S --needed mingw-w64-x86_64-gcc --noconfirm
  - `environment` step removed: Configure ASAN
  - `shell_or_setup` step removed: actions/cache@v4
  - `environment` step removed: echo CARGO_BUILD_TARGET=${{ matrix.target }} >> $GITHUB_ENV
  - `environment` step removed: Install cross-compilation tools
  - `shell_or_setup` step removed: echo "C:\msys64\mingw64\bin" >> $Env:GITHUB_PATH
  - `environment` step removed: Install Intel SDE
  - `environment` step removed: Force-run with MPK enabled, if available
  - `environment` step removed: echo CFLAGS=-g0 >> $GITHUB_ENV
  - `outputs` step removed: touch commits.log names.log
  - `shell_or_setup` step removed: Install VTune
  - `setup_prefix` step removed: actions/checkout@v4
  - `shell_or_setup` step removed: CPU information
  - `shell_or_setup` step removed: actions/cache@v4
  - `shell_or_setup` step removed: CPU information
  - `modified` step:test:1: with
  - `modified` step:test:2: command
    ```diff
    -rustup target add wasm32-wasip1 wasm32-unknown-unknown ${{ matrix.target }}
    +rustup target add wasm32-wasip1 wasm32-unknown-unknown
    ```
  - `modified` step:test:14: condition_removed (if: "runner.os == 'Linux'" -> 'None')
  - `modified` step:test:19: command, condition_removed, shell (if: "runner.os == 'Windows'" -> 'None')
    ```diff
    -python3 ./ci/run-tests.py --locked ${{ matrix.bucket }}
    +python3 ./ci/run-tests.py --locked
    ```

## yaml-cpp_69165369940

- [job](https://github.com/jbeder/yaml-cpp/actions/runs/23740455643/job/69165369940) — target `cmake-build`, matrix `{"os": "ubuntu-latest", "cxx_standard": 11, "build": "static", "googletest": "build", "generator": "Default Generator"}`; ground truth: uncertain: header 'cmake \\' fits steps 2 and 6 equally
- **reducer:claude-haiku-4-5-20251001**: matrix correct; required steps 8/8; modified 3; added {'setup': 0, 'other': 0}
  - `modified` step:cmake-build:0: condition_removed (if: "matrix.os == 'ubuntu-latest'" -> 'None')
  - `modified` step:cmake-build:2: command
    ```diff
    -  ${{ env.CMAKE_GENERATOR }} \
    +  \
    -  -D CMAKE_BUILD_TYPE=${{ env.CMAKE_BUILD_TYPE }} \
    -  -D CMAKE_CXX_FLAGS_DEBUG="${{ env.CMAKE_CXX_FLAGS_DEBUG }}" \
    -  -D YAML_BUILD_SHARED_LIBS=${{ env.YAML_BUILD_SHARED_LIBS }} \
    -  -D YAML_USE_SYSTEM_GTEST=${{ env.YAML_USE_SYSTEM_GTEST }} \
    +  -D CMAKE_BUILD_TYPE=Debug \
    +  -D CMAKE_CXX_FLAGS_DEBUG="-g -D_GLIBCXX_DEBUG -D_GLIBCXX_DEBUG_PEDANTIC" \
    ... 2 more
    ```
  - `modified` step:cmake-build:6: command
    ```diff
    -  ${{ env.CMAKE_GENERATOR }} \
    +  \
    -  -D CMAKE_BUILD_TYPE=${{ env.CMAKE_BUILD_TYPE }} \
    +  -D CMAKE_BUILD_TYPE=Debug \
    ```
- **reducer_B:claude-haiku-4-5-20251001**: matrix correct; required steps 8/8; modified 3; added {'setup': 0, 'other': 0}
  - `modified` step:cmake-build:0: condition_removed (if: "matrix.os == 'ubuntu-latest'" -> 'None')
  - `modified` step:cmake-build:2: command
    ```diff
    -  ${{ env.CMAKE_GENERATOR }} \
    +  \
    -  -D CMAKE_BUILD_TYPE=${{ env.CMAKE_BUILD_TYPE }} \
    -  -D CMAKE_CXX_FLAGS_DEBUG="${{ env.CMAKE_CXX_FLAGS_DEBUG }}" \
    -  -D YAML_BUILD_SHARED_LIBS=${{ env.YAML_BUILD_SHARED_LIBS }} \
    -  -D YAML_USE_SYSTEM_GTEST=${{ env.YAML_USE_SYSTEM_GTEST }} \
    +  -D CMAKE_BUILD_TYPE=Debug \
    +  -D CMAKE_CXX_FLAGS_DEBUG="-g -D_GLIBCXX_DEBUG -D_GLIBCXX_DEBUG_PEDANTIC" \
    ... 2 more
    ```
  - `modified` step:cmake-build:6: command
    ```diff
    -  ${{ env.CMAKE_GENERATOR }} \
    +  \
    -  -D CMAKE_BUILD_TYPE=${{ env.CMAKE_BUILD_TYPE }} \
    +  -D CMAKE_BUILD_TYPE=Debug \
    ```

## yaml-cpp_70411487906

- [job](https://github.com/jbeder/yaml-cpp/actions/runs/24132251019/job/70411487906) — target `cmake-build`, matrix `{"os": "ubuntu-latest", "cxx_standard": 11, "build": "static", "googletest": "build", "generator": "Default Generator"}`; ground truth: matched (8/8 steps executed)
- **reducer:claude-haiku-4-5-20251001**: matrix correct; required steps 8/8; modified 3; added {'setup': 0, 'other': 0}
  - `modified` step:cmake-build:0: condition_removed (if: "matrix.os == 'ubuntu-latest'" -> 'None') (original run: executed)
  - `modified` step:cmake-build:2: command (original run: executed)
    ```diff
    -  ${{ env.CMAKE_GENERATOR }} \
    +  \
    -  -D CMAKE_BUILD_TYPE=${{ env.CMAKE_BUILD_TYPE }} \
    -  -D CMAKE_CXX_FLAGS_DEBUG="${{ env.CMAKE_CXX_FLAGS_DEBUG }}" \
    -  -D YAML_BUILD_SHARED_LIBS=${{ env.YAML_BUILD_SHARED_LIBS }} \
    -  -D YAML_USE_SYSTEM_GTEST=${{ env.YAML_USE_SYSTEM_GTEST }} \
    +  -D CMAKE_BUILD_TYPE=Debug \
    +  -D CMAKE_CXX_FLAGS_DEBUG="-g -D_GLIBCXX_DEBUG -D_GLIBCXX_DEBUG_PEDANTIC" \
    ... 2 more
    ```
  - `modified` step:cmake-build:6: command (original run: executed)
    ```diff
    -  ${{ env.CMAKE_GENERATOR }} \
    +  \
    -  -D CMAKE_BUILD_TYPE=${{ env.CMAKE_BUILD_TYPE }} \
    +  -D CMAKE_BUILD_TYPE=Debug \
    ```
- **reducer_B:claude-haiku-4-5-20251001**: matrix correct; required steps 8/8; modified 3; added {'setup': 0, 'other': 0}
  - `modified` step:cmake-build:0: condition_removed (if: "matrix.os == 'ubuntu-latest'" -> 'None') (original run: executed)
  - `modified` step:cmake-build:2: command (original run: executed)
    ```diff
    -  ${{ env.CMAKE_GENERATOR }} \
    +  \
    -  -D CMAKE_BUILD_TYPE=${{ env.CMAKE_BUILD_TYPE }} \
    -  -D CMAKE_CXX_FLAGS_DEBUG="${{ env.CMAKE_CXX_FLAGS_DEBUG }}" \
    -  -D YAML_BUILD_SHARED_LIBS=${{ env.YAML_BUILD_SHARED_LIBS }} \
    -  -D YAML_USE_SYSTEM_GTEST=${{ env.YAML_USE_SYSTEM_GTEST }} \
    +  -D CMAKE_BUILD_TYPE=Debug \
    +  -D CMAKE_CXX_FLAGS_DEBUG="-g -D_GLIBCXX_DEBUG -D_GLIBCXX_DEBUG_PEDANTIC" \
    ... 2 more
    ```
  - `modified` step:cmake-build:6: command (original run: executed)
    ```diff
    -  ${{ env.CMAKE_GENERATOR }} \
    +  \
    -  -D CMAKE_BUILD_TYPE=${{ env.CMAKE_BUILD_TYPE }} \
    +  -D CMAKE_BUILD_TYPE=Debug \
    ```

