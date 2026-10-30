# GWA manual audit sample

Stratified by matrix, reusable_workflow, composite_action, cross_job_outputs, artifact_transfer: up to 3 cases each (seed 0). A case sampled for one stratum counts for every stratum it belongs to. Record verdicts in audit_sample.csv.

## lexical_72901152397

- **Sampled for:** matrix (strata: matrix)
- **Job:** [core-tests / unit (22.x)](https://github.com/facebook/lexical/actions/runs/24896085183/job/72901152397)
- **Workflow at the job's commit:** [.github/workflows/call-core-tests.yml](https://github.com/facebook/lexical/blob/a6081bb1608ca8b9a4cd533ffedd9805d395fdc2/.github/workflows/call-core-tests.yml)
- **Target:** `unit`, matrix `{"node-version": "22.x"}`, resolved by reusable-workflow job name; matrix keys rendered empty (absent from the combination): `override-react-version`
- **Validation:** warn; dependency preservation 14/14

| job | role | execution | steps kept | why (path to the target) |
|---|---|---|---|---|
| `unit` | target | execute_all_steps | all except statically false [4] | `target` |

**Check**

- [ ] Is the target the job that ran (job name, workflow file)?
- [ ] Is every retained predecessor needed, for the reason given?
- [ ] Is any job, step, output or artifact the target needs missing from the slice?
- [ ] Are the unresolved dependencies really undeterminable statically?
- [ ] Is the matrix assignment the combination the job ran with (job page, log header)?

## librosa_79302893434

- **Sampled for:** matrix (strata: matrix)
- **Job:** [Python 3.12 on ubuntu-latest](https://github.com/librosa/librosa/actions/runs/26887254458/job/79302893434)
- **Workflow at the job's commit:** [.github/workflows/ci.yml](https://github.com/librosa/librosa/blob/6cd0fa57fd84daad863ea13405438ee48bd24d76/.github/workflows/ci.yml)
- **Target:** `test`, matrix `{"os": "ubuntu-latest", "python-version": "3.12", "envfile": ".github/environment-minimal.yml", "channel-priority": "strict", "variant": "minimal"}`, resolved by name template
- **Validation:** warn; dependency preservation 30/30

| job | role | execution | steps kept | why (path to the target) |
|---|---|---|---|---|
| `test` | target | execute_all_steps | all except statically false [1, 2] | `target` |

**Unresolved**

- job_resolution: 2 jobs match 'Python 3.12 on ubuntu-latest' (name template); took job:test

**Check**

- [ ] Is the target the job that ran (job name, workflow file)?
- [ ] Is every retained predecessor needed, for the reason given?
- [ ] Is any job, step, output or artifact the target needs missing from the slice?
- [ ] Are the unresolved dependencies really undeterminable statically?
- [ ] Is the matrix assignment the combination the job ran with (job page, log header)?

## yaml-cpp_69165369940

- **Sampled for:** matrix (strata: matrix)
- **Job:** [cmake-build (ubuntu-latest, 11, static, build, Default Generator)](https://github.com/jbeder/yaml-cpp/actions/runs/23740455643/job/69165369940)
- **Workflow at the job's commit:** [.github/workflows/build.yml](https://github.com/jbeder/yaml-cpp/blob/8069ce95da92474ce66911451def0a7b555615e2/.github/workflows/build.yml)
- **Target:** `cmake-build`, matrix `{"os": "ubuntu-latest", "cxx_standard": 11, "build": "static", "googletest": "build", "generator": "Default Generator"}`, resolved by exact API name
- **Validation:** warn; dependency preservation 25/25

| job | role | execution | steps kept | why (path to the target) |
|---|---|---|---|---|
| `cmake-build` | target | execute_all_steps | all | `target` |

**Check**

- [ ] Is the target the job that ran (job name, workflow file)?
- [ ] Is every retained predecessor needed, for the reason given?
- [ ] Is any job, step, output or artifact the target needs missing from the slice?
- [ ] Are the unresolved dependencies really undeterminable statically?
- [ ] Is the matrix assignment the combination the job ran with (job page, log header)?

## metro_62930784333

- **Sampled for:** reusable_workflow (strata: reusable_workflow, composite_action)
- **Job:** [test (ubuntu-latest, 20.19.4, true) / Tests [Node.js 20.19.4, ubuntu-latest, Ignoring yarn.lock]](https://github.com/react/metro/actions/runs/21813637858/job/62930784333)
- **Workflow at the job's commit:** [.github/workflows/nightly-tests.yml](https://github.com/facebook/metro/blob/d15e0c6ed82082131b53299074bde3ad48173420/.github/workflows/nightly-tests.yml)
- **Target:** `test` in `test/`, matrix `{}`, resolved by name template
- **Validation:** warn; dependency preservation 15/15

| job | role | execution | steps kept | why (path to the target) |
|---|---|---|---|---|
| `test` | call_site | resolve_inputs_only | none | `job:test -CALLS-> workflow:test/.github/workflows/test.yml -CONTAINS-> job:test/test` |
| `test/test` | target | execute_all_steps | all | `target` |

**Check**

- [ ] Is the target the job that ran (job name, workflow file)?
- [ ] Is every retained predecessor needed, for the reason given?
- [ ] Is any job, step, output or artifact the target needs missing from the slice?
- [ ] Are the unresolved dependencies really undeterminable statically?
- [ ] Is the call site right, and are the inputs it passes bound correctly?
- [ ] Are the composite action's steps expanded and its inputs bound correctly?

## numpy_69224795205

- **Sampled for:** composite_action (strata: matrix, composite_action)
- **Job:** [smoke_test (3.12)](https://github.com/numpy/numpy/actions/runs/23760033358/job/69224795205)
- **Workflow at the job's commit:** [.github/workflows/linux.yml](https://github.com/numpy/numpy/blob/7ab949e370a253601426f8f05dbd910a872a14a7/.github/workflows/linux.yml)
- **Target:** `smoke_test`, matrix `{"version": "3.12"}`, resolved by exact API name
- **Validation:** pass; dependency preservation 9/9

| job | role | execution | steps kept | why (path to the target) |
|---|---|---|---|---|
| `smoke_test` | target | execute_all_steps | all | `target` |

**Check**

- [ ] Is the target the job that ran (job name, workflow file)?
- [ ] Is every retained predecessor needed, for the reason given?
- [ ] Is any job, step, output or artifact the target needs missing from the slice?
- [ ] Are the unresolved dependencies really undeterminable statically?
- [ ] Is the matrix assignment the combination the job ran with (job page, log header)?
- [ ] Are the composite action's steps expanded and its inputs bound correctly?

## react-native_67316636441

- **Sampled for:** composite_action (strata: matrix, composite_action, cross_job_outputs)
- **Job:** [test_js (22)](https://github.com/react/react-native/actions/runs/23169066207/job/67316636441)
- **Workflow at the job's commit:** [.github/workflows/test-all.yml](https://github.com/facebook/react-native/blob/ceb1e883fb61056929b73adb1575b3ba00bc8a96/.github/workflows/test-all.yml)
- **Target:** `test_js`, matrix `{"node-version": "22"}`, resolved by exact API name
- **Validation:** pass; dependency preservation 8/8

| job | role | execution | steps kept | why (path to the target) |
|---|---|---|---|---|
| `check_code_changes` | data_predecessor | execute_until_producer | 0-1 | `step:check_code_changes:1 -PRODUCES-> resource:output:check_code_changes.any_code_change -CONSUMES-> job:test_js` |
| `lint` | ordering_only | record_constraint_only | none | `job:lint -NEEDS-> job:test_js` |
| `test_js` | target | execute_all_steps | all | `target` |

**Required outputs**

- `output:check_code_changes.any_code_change`: step:check_code_changes:1 → job:test_js

**Ordering constraints**

- check_code_changes → test_js (requires_success=True, reproduced=True)
- lint → test_js (requires_success=True, reproduced=False)

**Check**

- [ ] Is the target the job that ran (job name, workflow file)?
- [ ] Is every retained predecessor needed, for the reason given?
- [ ] Is any job, step, output or artifact the target needs missing from the slice?
- [ ] Are the unresolved dependencies really undeterminable statically?
- [ ] Is the matrix assignment the combination the job ran with (job page, log header)?
- [ ] Are the composite action's steps expanded and its inputs bound correctly?
- [ ] Does the producer step set the output the target reads, and are the steps kept before it enough to compute it?

## strapi_74592890720

- **Sampled for:** composite_action (strata: matrix, composite_action, cross_job_outputs)
- **Job:** [unit_back (node: 22)](https://github.com/strapi/strapi/actions/runs/25429558316/job/74592890720)
- **Workflow at the job's commit:** [.github/workflows/tests.yml](https://github.com/strapi/strapi/blob/c5bc749feeb5b7b4f3d845b52da41277100465a8/.github/workflows/tests.yml)
- **Target:** `unit_back`, matrix `{"node": 22}`, resolved by exact API name
- **Validation:** warn; dependency preservation 22/22

| job | role | execution | steps kept | why (path to the target) |
|---|---|---|---|---|
| `build` | ordering_only | record_constraint_only | none | `job:build -NEEDS-> job:unit_back` |
| `conditions` | data_predecessor | execute_until_producer | 0-1 | `step:conditions:1 -PRODUCES-> resource:output:conditions.global -CONSUMES-> job:unit_back` |
| `unit_back` | target | execute_all_steps | all except statically false [6] | `target` |

**Required outputs**

- `output:conditions.backend`: step:conditions:1 → job:unit_back
- `output:conditions.global`: step:conditions:1 → job:unit_back

**Ordering constraints**

- build → unit_back (requires_success=True, reproduced=False)
- conditions → unit_back (requires_success=True, reproduced=True)

**Check**

- [ ] Is the target the job that ran (job name, workflow file)?
- [ ] Is every retained predecessor needed, for the reason given?
- [ ] Is any job, step, output or artifact the target needs missing from the slice?
- [ ] Are the unresolved dependencies really undeterminable statically?
- [ ] Is the matrix assignment the combination the job ran with (job page, log header)?
- [ ] Are the composite action's steps expanded and its inputs bound correctly?
- [ ] Does the producer step set the output the target reads, and are the steps kept before it enough to compute it?

## fory_77650013374

- **Sampled for:** cross_job_outputs (strata: matrix, cross_job_outputs)
- **Job:** [Java CI (8)](https://github.com/apache/fory/actions/runs/26380987511/job/77650013374)
- **Workflow at the job's commit:** [.github/workflows/ci.yml](https://github.com/apache/fory/blob/90dddb010c7ab87b4b9c6250d3d7f2ccaa9053aa/.github/workflows/ci.yml)
- **Target:** `java`, matrix `{"java-version": "8"}`, resolved by job key or base name
- **Validation:** warn; dependency preservation 22/22

| job | role | execution | steps kept | why (path to the target) |
|---|---|---|---|---|
| `changes` | data_predecessor | execute_until_producer | 0-1 | `step:changes:1 -PRODUCES-> resource:output:changes.java_code -CONSUMES-> job:java` |
| `java` | target | execute_all_steps | all | `target` |

**Required outputs**

- `output:changes.java_code`: step:changes:1 → job:java

**Ordering constraints**

- changes → java (requires_success=True, reproduced=True)

**Check**

- [ ] Is the target the job that ran (job name, workflow file)?
- [ ] Is every retained predecessor needed, for the reason given?
- [ ] Is any job, step, output or artifact the target needs missing from the slice?
- [ ] Are the unresolved dependencies really undeterminable statically?
- [ ] Is the matrix assignment the combination the job ran with (job page, log header)?
- [ ] Does the producer step set the output the target reads, and are the steps kept before it enough to compute it?

## git_65741608537

- **Sampled for:** cross_job_outputs (strata: matrix, cross_job_outputs)
- **Job:** [linux-meson (ubuntu:rolling)](https://github.com/git/git/actions/runs/22678401145/job/65741608537)
- **Workflow at the job's commit:** [.github/workflows/main.yml](https://github.com/git/git/blob/594ee25b394494a917163aebde882cd5309e2b63/.github/workflows/main.yml)
- **Target:** `dockerized`, matrix `{"vector": {"jobname": "linux-meson", "image": "ubuntu:rolling", "cc": "gcc"}}`, resolved by exact API name
- **Validation:** pass; dependency preservation 24/24

| job | role | execution | steps kept | why (path to the target) |
|---|---|---|---|---|
| `ci-config` | data_predecessor | execute_until_producer | 0-2 | `step:ci-config:1 -PRODUCES-> resource:output:ci-config.enabled -CONSUMES-> job:dockerized` |
| `dockerized` | target | execute_all_steps | all except statically false [0] | `target` |

**Required outputs**

- `output:ci-config.enabled`: step:ci-config:1 → job:dockerized
- `output:ci-config.enabled`: step:ci-config:2 → job:dockerized

**Ordering constraints**

- ci-config → dockerized (requires_success=True, reproduced=True)

**Check**

- [ ] Is the target the job that ran (job name, workflow file)?
- [ ] Is every retained predecessor needed, for the reason given?
- [ ] Is any job, step, output or artifact the target needs missing from the slice?
- [ ] Are the unresolved dependencies really undeterminable statically?
- [ ] Is the matrix assignment the combination the job ran with (job page, log header)?
- [ ] Does the producer step set the output the target reads, and are the steps kept before it enough to compute it?

## wasmtime_66124639023

- **Sampled for:** cross_job_outputs (strata: composite_action, cross_job_outputs)
- **Job:** [Test Linux x86_64 (2/6)](https://github.com/bytecodealliance/wasmtime/actions/runs/22793606887/job/66124639023)
- **Workflow at the job's commit:** [.github/workflows/main.yml](https://github.com/bytecodealliance/wasmtime/blob/8d7ec9881c94ffc27e324b886f0a05c08125475c/.github/workflows/main.yml)
- **Target:** `test`, matrix `{}`, resolved by name template
- **Validation:** warn; dependency preservation 100/100

| job | role | execution | steps kept | why (path to the target) |
|---|---|---|---|---|
| `determine` | data_predecessor | execute_until_producer | 0-1 | `step:determine:1 -PRODUCES-> resource:output:determine.test-matrix -CONSUMES-> job:test` |
| `test` | target | execute_all_steps | all except statically false [15, 16, 19] | `target` |

**Required outputs**

- `output:determine.test-matrix`: step:determine:1 → job:test

**Ordering constraints**

- determine → test (requires_success=True, reproduced=True)

**Unresolved**

- matrix: the job's matrix could not be expanded and no assignment was supplied
- runner: runs-on '${{ matrix.os }}' is an unresolved expression

**Check**

- [ ] Is the target the job that ran (job name, workflow file)?
- [ ] Is every retained predecessor needed, for the reason given?
- [ ] Is any job, step, output or artifact the target needs missing from the slice?
- [ ] Are the unresolved dependencies really undeterminable statically?
- [ ] Are the composite action's steps expanded and its inputs bound correctly?
- [ ] Does the producer step set the output the target reads, and are the steps kept before it enough to compute it?

## babel_73097014101

- **Sampled for:** artifact_transfer (strata: matrix, artifact_transfer)
- **Job:** [Test on Node.js 24](https://github.com/babel/babel/actions/runs/24964523333/job/73097014101)
- **Workflow at the job's commit:** [.github/workflows/ci.yml](https://github.com/babel/babel/blob/7cfd69f13d6bcd2006c10e0e76f78f8ee1eaef43/.github/workflows/ci.yml)
- **Target:** `test`, matrix `{"node-version": 24}`, resolved by exact API name
- **Validation:** pass; dependency preservation 36/36

| job | role | execution | steps kept | why (path to the target) |
|---|---|---|---|---|
| `prepare-yarn-cache` | ordering_only | record_constraint_only | none | `job:prepare-yarn-cache -NEEDS-> job:build -NEEDS-> job:test` |
| `build` | artifact_producer | execute_until_producer | 0-8 | `step:build:8 -PRODUCES-> resource:artifact:babel-artifact -CONSUMES-> step:test:3` |
| `test` | target | execute_all_steps | all | `target` |

**Required artifacts**

- `artifact:babel-artifact`: step:build:8 → step:test:3

**Ordering constraints**

- prepare-yarn-cache → build (requires_success=True, reproduced=False)
- build → test (requires_success=True, reproduced=True)

**Check**

- [ ] Is the target the job that ran (job name, workflow file)?
- [ ] Is every retained predecessor needed, for the reason given?
- [ ] Is any job, step, output or artifact the target needs missing from the slice?
- [ ] Are the unresolved dependencies really undeterminable statically?
- [ ] Is the matrix assignment the combination the job ran with (job page, log header)?
- [ ] Is the uploaded artifact the one the target downloads, and are the steps kept before the upload enough to build it?

## dash_73803999053

- **Sampled for:** artifact_transfer (strata: matrix, artifact_transfer)
- **Job:** [Lint & Unit Tests (Python 3.12)](https://github.com/plotly/dash/actions/runs/25174699412/job/73803999053)
- **Workflow at the job's commit:** [.github/workflows/testing.yml](https://github.com/plotly/dash/blob/9cc99590e01c32e83bf545047965f427e09984d6/.github/workflows/testing.yml)
- **Target:** `lint-unit`, matrix `{"python-version": "3.12"}`, resolved by exact API name
- **Validation:** warn; dependency preservation 64/64

| job | role | execution | steps kept | why (path to the target) |
|---|---|---|---|---|
| `build` | artifact_producer | execute_until_producer | 0-8 | `step:build:7 -PRODUCES-> resource:artifact:dash-packages -CONSUMES-> step:lint-unit:4` |
| `lint-unit` | target | execute_all_steps | all | `target` |

**Required artifacts**

- `artifact:dash-components`: step:build:8 → step:lint-unit:5
- `artifact:dash-packages`: step:build:7 → step:lint-unit:4

**Ordering constraints**

- build → lint-unit (requires_success=True, reproduced=True)

**Check**

- [ ] Is the target the job that ran (job name, workflow file)?
- [ ] Is every retained predecessor needed, for the reason given?
- [ ] Is any job, step, output or artifact the target needs missing from the slice?
- [ ] Are the unresolved dependencies really undeterminable statically?
- [ ] Is the matrix assignment the combination the job ran with (job page, log header)?
- [ ] Is the uploaded artifact the one the target downloads, and are the steps kept before the upload enough to build it?

