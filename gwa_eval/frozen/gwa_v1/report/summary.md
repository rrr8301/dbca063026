# GWA validation report (target_execution)

Cases: 74 (4 synthetic), analyzed: 74, errors: 0.

## Dependency preservation

2086 / 2086 mandatory dependencies of reproduced nodes are preserved (100.0%).

| dependency class | edges into reproduced nodes |
|---|---|
| artifact | 5 |
| data | 49 |
| environment | 1151 |
| manifest | 305 |
| order | 576 |

## Checks

| check | pass | warn | fail |
|---|---|---|---|
| target_resolution | 68 | 6 | 0 |
| matrix_rendering | 61 | 13 | 0 |
| reusable_workflow | 71 | 3 | 0 |
| conditions | 74 | 0 | 0 |
| artifacts | 74 | 0 | 0 |
| dependency_preservation | 74 | 0 | 0 |
| step_ordering | 74 | 0 | 0 |
| graph_spec_consistency | 74 | 0 | 0 |
| justification | 74 | 0 | 0 |
| dynamic_references | 71 | 3 | 0 |

Overall: 55 pass, 19 warn, 0 fail. Deterministic under PYTHONHASHSEED=1/4242: 74 / 74.

## Target resolution

| resolved by | cases |
|---|---|
| exact API name | 68 |
| name template | 4 |
| job key or base name | 1 |
| reusable-workflow job name | 1 |

## Strata

| stratum | cases |
|---|---|
| matrix | 52 |
| reusable_workflow | 2 |
| composite_action | 10 |
| cross_job_outputs | 13 |
| artifact_transfer | 4 |

## Retained predecessors

| role | jobs |
|---|---|
| data_predecessor | 13 |
| ordering_only | 9 |
| artifact_producer | 4 |
| call_site | 2 |

## Unresolved dependencies

| kind | occurrences |
|---|---|
| runner | 3 |
| matrix | 1 |
| env | 1 |
| job_resolution | 1 |
| runtime | 1 |

## Dynamic references left in specifications

| context | expressions |
|---|---|
| env | 76 |
| github | 54 |
| matrix | 54 |
| runner | 50 |
| steps | 34 |
| inputs | 24 |
| secrets | 16 |
| function_or_literal | 10 |
| needs | 5 |

## Failures and warnings

### fory_77650013374 — warn
- target_resolution (warn): resolved by job key or base name, not by the exact API name
- target_resolution (warn): the matrix is computed at runtime; the assignment is from the job config

### wasmtime_66124639023 — warn
- target_resolution (warn): resolved by name template, not by the exact API name
- target_resolution (warn): the matrix is computed at runtime; the assignment is unknown
- matrix_rendering (warn): job:test.runs_on: ${{ matrix.os }}
- matrix_rendering (warn): step:test:2.command: ${{ matrix.target }}
- matrix_rendering (warn): step:test:20.command: ${{ matrix.bucket }}
- matrix_rendering (warn): step:test:8.command: ${{ matrix.gcc_package }}
- matrix_rendering (warn): step:test:8.command: ${{ matrix.target }}
- matrix_rendering (warn): step:test:8.command: ${{ matrix.gcc }}
- matrix_rendering (warn): step:test:11.command: ${{ matrix.target }}
- matrix_rendering (warn): step:test:11.command: ${{ matrix.qemu }}
- matrix_rendering (warn): step:test:11.command: ${{ matrix.qemu_target }}
- matrix_rendering (warn): step:test:19.command: ${{ matrix.bucket }}
- matrix_rendering (warn): step:test:3.command: ${{ matrix.target }}
- matrix_rendering (warn): step:test:1.with_: ${{ matrix.rust }}
- matrix_rendering (warn): step:test:9.with_: ${{ matrix.target }}
- matrix_rendering (warn): step:test:17.condition: ${{ contains(matrix.name, 'MPK') }}
- matrix_rendering (warn): step:test:13.condition: ${{ contains(matrix.name, 'ASAN') }}
- reusable_workflow (warn): step:test:1: composite action inputs without a value: ['inputs.toolchain']
- dynamic_references (warn): test.1.expanded_steps: ${{ inputs.toolchain }} is not bound
- dynamic_references (warn): test.1.expanded_steps: ${{ inputs.toolchain }} is not bound
- dynamic_references (warn): test.1.expanded_steps: ${{ inputs.toolchain }} is not bound
- dynamic_references (warn): test.1.expanded_steps: ${{ inputs.toolchain }} is not bound
- dynamic_references (warn): test.1.expanded_steps: ${{ inputs.toolchain }} is not bound

### egg_73220056264 — warn
- matrix_rendering (warn): step:test:4.condition: ${{ matrix.os == 'macos-latest' || matrix.os == 'ubuntu-latest' }}
- matrix_rendering (warn): step:test:2.condition: ${{ matrix.os == 'windows-latest' }}
- matrix_rendering (warn): step:test:10.condition: ${{ matrix.os != 'ubuntu-latest' || matrix.node != '24' }}
- matrix_rendering (warn): step:test:11.condition: ${{ matrix.os != 'windows-latest' }}
- matrix_rendering (warn): step:test:12.condition: ${{ matrix.os == 'ubuntu-latest' && matrix.node == '24' }}
- matrix_rendering (warn): step:test:3.condition: ${{ matrix.os == 'macos-latest' || matrix.os == 'ubuntu-latest' }}
- matrix_rendering (warn): step:test:5.condition: ${{ matrix.os == 'windows-latest' }}
- matrix_rendering (warn): step:test:1.condition: ${{ matrix.os == 'macos-latest' || matrix.os == 'ubuntu-latest' }}
- matrix_rendering (warn): step:test:9.condition: ${{ matrix.os == 'ubuntu-latest' && matrix.node == '24' }}

### express_69191907549 — warn
- matrix_rendering (warn): step:test:2.condition: ${{ matrix.npm-version != '' }}
- matrix_rendering (warn): step:test:4.condition: ${{ matrix.npm-i != '' }}

### lexical_72901152397 — warn
- target_resolution (warn): resolved by reusable-workflow job name, not by the exact API name

### metro_62930784333 — warn
- target_resolution (warn): resolved by name template, not by the exact API name
- reusable_workflow (warn): step:test/test:1: composite action inputs without a value: ["inputs.no-lockfile == 'false' && '--frozen-lockfile' || '--no-lockfile'", "inputs.no-lockfile == 'false' && 'yarn' || ''", "inputs.no-lockfile == 'false' && 'yarn.lock' || ''"]

### grpc-go_73344851873 — warn
- matrix_rendering (warn): job:tests.runs_on: ${{ matrix.runner || 'ubuntu-latest' }}

### yaml-cpp_69165369940 — warn
- matrix_rendering (warn): job:cmake-build.env: ${{ matrix.build == 'shared' && 'ON' || 'OFF' }}
- matrix_rendering (warn): job:cmake-build.env: ${{ matrix.googletest == 'system' && 'ON' || 'OFF' }}
- matrix_rendering (warn): job:cmake-build.env: ${{ format(matrix.generator != 'Default Generator' && '-G "{0}"' || '', matrix.gener }}
- matrix_rendering (warn): job:cmake-build.env: ${{ matrix.googletest == 'build' && '-g -D_GLIBCXX_DEBUG -D_GLIBCXX_DEBUG_PEDANTIC'  }}

### yaml-cpp_70411487906 — warn
- matrix_rendering (warn): job:cmake-build.env: ${{ matrix.build == 'shared' && 'ON' || 'OFF' }}
- matrix_rendering (warn): job:cmake-build.env: ${{ matrix.googletest == 'system' && 'ON' || 'OFF' }}
- matrix_rendering (warn): job:cmake-build.env: ${{ format(matrix.generator != 'Default Generator' && '-G "{0}"' || '', matrix.gener }}
- matrix_rendering (warn): job:cmake-build.env: ${{ matrix.googletest == 'build' && '-g -D_GLIBCXX_DEBUG -D_GLIBCXX_DEBUG_PEDANTIC'  }}

### libgit2_75529566960 — warn
- reusable_workflow (warn): step:build:3: composite action inputs without a value: ['inputs.base', 'inputs.config-path', 'inputs.github_token', 'inputs.registry']
- reusable_workflow (warn): step:build:5: composite action inputs without a value: ['inputs.container-version', "inputs.shell != '' && inputs.shell || 'bash'"]
- reusable_workflow (warn): step:build:6: composite action inputs without a value: ['inputs.cmake-global-options', 'inputs.container-version', "inputs.shell != '' && inputs.shell || 'bash'"]
- dynamic_references (warn): build.3.expanded_steps: ${{ inputs.registry }} is not bound
- dynamic_references (warn): build.3.expanded_steps: ${{ inputs.config-path }} is not bound
- dynamic_references (warn): build.3.expanded_steps: ${{ inputs.github_token }} is not bound
- dynamic_references (warn): build.3.expanded_steps: ${{ inputs.base }} is not bound
- dynamic_references (warn): build.3.expanded_steps: ${{ inputs.base }} is not bound
- dynamic_references (warn): build.3.expanded_steps: ${{ inputs.config-path }} is not bound
- dynamic_references (warn): build.5.expanded_steps: ${{ inputs.container-version }} is not bound
- dynamic_references (warn): build.5.expanded_steps: ${{ inputs.shell != '' && inputs.shell || 'bash' }} is not bound
- dynamic_references (warn): build.6.expanded_steps: ${{ inputs.cmake-global-options }} is not bound
- dynamic_references (warn): build.6.expanded_steps: ${{ inputs.container-version }} is not bound
- dynamic_references (warn): build.6.expanded_steps: ${{ inputs.shell != '' && inputs.shell || 'bash' }} is not bound

### librosa_79302893434 — warn
- target_resolution (warn): resolved by name template, not by the exact API name
- matrix_rendering (warn): step:test:6.with_: ${{ hashFiles( matrix.envfile ) }}

### libunwind_78113445933 — warn
- matrix_rendering (warn): step:build-gnu-cross:2.command: ${{ matrix.config.packages || format('g++-{0}-{1}', matrix.config.gccver, matrix.con }}
- matrix_rendering (warn): step:build-gnu-cross:3.env: ${{ matrix.config.cc || format('{0}-gcc-{1}', matrix.config.host, matrix.config.gccv }}
- matrix_rendering (warn): step:build-gnu-cross:3.env: ${{ matrix.config.cxx || format('{0}-g++-{1}', matrix.config.host, matrix.config.gcc }}
- matrix_rendering (warn): step:build-gnu-cross:6.command: ${{ matrix.config.qemu_skip && format(' --qemu-skip={0}', matrix.config.qemu_skip) | }}
- matrix_rendering (warn): step:build-gnu-cross:6.env: ${{ matrix.config.cross_lib || format('/usr/{0}', matrix.config.host) }}

### libvips_75052905094 — warn
- matrix_rendering (warn): step:CI:8.command: ${{ matrix.build.docs || 'false' }}
- matrix_rendering (warn): step:CI:8.command: ${{ matrix.build.docs && 'enabled' || 'disabled' }}
- matrix_rendering (warn): step:CI:8.command: ${{ matrix.build.sanitize || 'none' }}
- matrix_rendering (warn): step:CI:8.command: ${{ matrix.build.sanitize && 'false' || 'true' }}
- matrix_rendering (warn): step:CI:10.command: ${{ matrix.build.sanitize == 'thread' && '0' || '1' }}

### notify_72052084636 — warn
- target_resolution (warn): resolved by name template, not by the exact API name

### ollama_70708388185 — warn
- matrix_rendering (warn): step:test:5.condition: ${{ startsWith(matrix.os, 'ubuntu') }}

### dash_73803999053 — warn
- matrix_rendering (warn): step:lint-unit:9.env: ${{ matrix.python-version == '3.8' && '--ignored-modules=mcp' || '' }}

### pyinstaller_60034109922 — warn
- matrix_rendering (warn): step:tests:18.condition: ${{ !endsWith(matrix.python-version, '-dev') && matrix.python-version != '3.13t' }}

### STC_72967914244 — warn
- matrix_rendering (warn): step:meson-build-and-tests:2.condition: ${{ matrix.platform == 'windows-2022' }}
- matrix_rendering (warn): step:meson-build-and-tests:3.condition: ${{ matrix.platform != 'windows-2022' }}

### strapi_74592890720 — warn
- dynamic_references (warn): unit_back.3.expanded_steps: ${{ hashFiles(format('{0}/yarn.lock', inputs.cwd), format('{0}/. }} is not bound
- dynamic_references (warn): unit_back.3.expanded_steps: ${{ hashFiles(format('{0}/yarn.lock', inputs.cwd), format('{0}/. }} is not bound
- dynamic_references (warn): unit_back.3.expanded_steps: ${{ hashFiles(format('{0}/yarn.lock', inputs.cwd), format('{0}/. }} is not bound
- dynamic_references (warn): unit_back.3.expanded_steps: ${{ hashFiles(format('{0}/yarn.lock', inputs.cwd), format('{0}/. }} is not bound

