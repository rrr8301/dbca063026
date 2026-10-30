# GWA vs. the YAML Reducer

Cases: 70 dataset jobs. GWA-v1: the frozen baseline (every step of the target). GWA-v2: GWA-v1 plus Static Condition Resolution. Reducer: original prompt and settings, 1 run(s) per model; tables use run 0.

- **Mode A** (`reducer:`): the deployed pipeline. The reducer is given the run's completed steps (rebuilt from its CI log) and told to keep only the target job; GWA is given neither.
- **Mode B** (`reducer_B:`): input-controlled. Neither method gets completed steps or logs; both get the workflow, the repository and the matrix assignment.

Graph-relative metrics are measured against GWA-v1's conservative slice (GWA-v1 meets them by construction; GWA-v2's pruned steps count as dropped there). Observed metrics use the steps the original run executed or skipped, recovered from its CI log: they cover the 61 jobs whose log aligns with the workflow unambiguously, and are reconstructed labels, not a complete execution trace.

| metric | gwa_v1 | gwa_v2 | reducer:claude-haiku-4-5-20251001 | reducer_B:claude-haiku-4-5-20251001 |
|---|---|---|---|---|
| required-step recall (graph-relative) | 635/635 (100.0%) | 572/635 (90.1%) | 495/635 (78.0%) | 536/635 (84.4%) |
| required-job recall (graph-relative) | 12/12 (100.0%) | 12/12 (100.0%) | 1/12 (8.3%) | 2/12 (16.7%) |
| mandatory dependency recall (graph-relative) | 811/811 (100.0%) | 675/811 (83.2%) | 530/811 (65.4%) | 567/811 (69.9%) |
| dependency closure of retained steps (graph-relative) | 811/811 (100.0%) | 675/714 (94.5%) | 530/604 (87.7%) | 567/649 (87.4%) |
| observed executed-step recall | 385/385 (100.0%) | 385/385 (100.0%) | 379/385 (98.4%) | 376/385 (97.7%) |
| observed skipped-step retention (lower is better) | 73/73 (100.0%) | 29/73 (39.7%) | 5/73 (6.8%) | 46/73 (63.0%) |
| retained-step ratio (of all workflow steps) | 635/2859 (22.2%) | 572/2859 (20.0%) | 495/2859 (17.3%) | 536/2859 (18.7%) |
| step modification rate (of aligned steps) | 0/635 (0.0%) | 0/572 (0.0%) | 69/495 (13.9%) | 76/536 (14.2%) |
| added steps: setup / other | 0 / 0 | 0 / 0 | 1 / 1 | 0 / 0 |
| ambiguous step mappings | 0 | 0 | 5 | 7 |
| broken dependencies: producer ran / did not run / no ground truth | 0 | 0 / 34 / 5 | 0 / 34 / 40 | 0 / 34 / 48 |
| modifications by kind | — | — | condition_removed 37, command 18, with 7, env 7, condition 4, shell 1 | condition_removed 43, command 18, with 8, env 7, condition 4, shell 1 |

## Matrix assignment

| outcome | gwa_v1 | gwa_v2 | reducer:claude-haiku-4-5-20251001 | reducer_B:claude-haiku-4-5-20251001 |
|---|---|---|---|---|
| correct | 46 | 46 | 41 | 42 |
| incorrect | 0 | 0 | 1 | 1 |
| unresolved | 0 | 0 | 0 | 0 |
| unverified | 4 | 4 | 0 | 0 |
| not_observable | 0 | 0 | 8 | 7 |
| n/a | 20 | 20 | 20 | 20 |

## Cost

| method | input tokens | output tokens | USD (list price) | USD (pipeline's table) | seconds (total) | unparsable outputs |
|---|---|---|---|---|---|---|
| gwa_v1 | 0 | 0 | 0.0000 | 0.0000 | 3.7 | 0 |
| gwa_v2 | 0 | 0 | 0.0000 | 0.0000 | 2.9 | 0 |
| reducer:claude-haiku-4-5-20251001 | 232213 | 33004 | 0.3972 | 0.3178 | 291.9 | 1 |
| reducer_B:claude-haiku-4-5-20251001 | 229107 | 36202 | 0.4101 | 0.3281 | 320.0 | 1 |

## Static Condition Resolution (GWA-v2, target-job steps with an `if:`)

151 conditional steps: TRUE 49, FALSE 63, UNKNOWN 39 — decision coverage 74.2%.

| decision | observed executed | observed not executed |
|---|---|---|
| TRUE | 23 | 3 |
| FALSE | 0 | 44 |
| UNKNOWN | 12 | 11 |

FALSE decisions confirmed by the run: 44/44 (100.0%). **False pruning (FALSE but executed): 0**.
A TRUE step that did not run is expected: TRUE is about the expression, and earlier failures or an implicit `success()` can still prevent the step.

## Per-job means with 95% bootstrap intervals

Each job counts once (10,000 resamples of jobs).

| metric | gwa_v1 | gwa_v2 | reducer:claude-haiku-4-5-20251001 | reducer_B:claude-haiku-4-5-20251001 |
|---|---|---|---|---|
| observed executed-step recall | 1.000 [1.000, 1.000] (n=61) | 1.000 [1.000, 1.000] (n=61) | 0.978 [0.940, 1.000] (n=61) | 0.967 [0.918, 1.000] (n=61) |
| observed skipped-step retention | 1.000 [1.000, 1.000] (n=27) | 0.388 [0.228, 0.552] (n=27) | 0.185 [0.037, 0.333] (n=27) | 0.599 [0.420, 0.772] (n=27) |
| required-step recall (graph-relative) | 1.000 [1.000, 1.000] (n=70) | 0.918 [0.886, 0.948] (n=70) | 0.826 [0.773, 0.874] (n=70) | 0.873 [0.817, 0.921] (n=70) |
| retained-step ratio | 0.511 [0.429, 0.594] (n=70) | 0.462 [0.384, 0.540] (n=70) | 0.426 [0.350, 0.503] (n=70) | 0.458 [0.378, 0.540] (n=70) |

## Paired per-job differences (first minus second), 95% bootstrap intervals

| metric | gwa_v2 − gwa_v1 | gwa_v2 − reducer:claude-haiku-4-5-20251001 | gwa_v2 − reducer_B:claude-haiku-4-5-20251001 | reducer:claude-haiku-4-5-20251001 − reducer_B:claude-haiku-4-5-20251001 |
|---|---|---|---|---|
| observed executed-step recall | +0.000 [+0.000, +0.000] (n=61) | +0.022 [+0.000, +0.060] (n=61) | +0.033 [+0.000, +0.082] (n=61) | +0.011 [-0.038, +0.060] (n=61) |
| observed skipped-step retention | -0.612 [-0.772, -0.448] (n=27) | +0.202 [+0.042, +0.362] (n=27) | -0.211 [-0.359, -0.078] (n=27) | -0.414 [-0.593, -0.241] (n=27) |
| required-step recall (graph-relative) | -0.082 [-0.114, -0.052] (n=70) | +0.092 [+0.052, +0.136] (n=70) | +0.045 [-0.004, +0.103] (n=70) | -0.047 [-0.100, +0.007] (n=70) |
| retained-step ratio | -0.049 [-0.071, -0.029] (n=70) | +0.036 [+0.016, +0.061] (n=70) | +0.004 [-0.018, +0.032] (n=70) | -0.032 [-0.065, -0.002] (n=70) |

## Disagreement categories (reducer vs. GWA-v1)

| category | reducer:claude-haiku-4-5-20251001 | reducer_B:claude-haiku-4-5-20251001 | cases |
|---|---|---|---|
| added_setup | 1 | 0 | 1 |
| artifacts | 2 | 2 | 1 |
| conditional_step | 60 | 27 | 21 |
| environment | 8 | 9 | 3 |
| invented | 1 | 0 | 1 |
| matrix | 1 | 1 | 1 |
| modified | 69 | 76 | 31 |
| no_output | 1 | 1 | 2 |
| outputs | 27 | 24 | 9 |
| reusable_workflow | 1 | 1 | 1 |
| setup_prefix | 18 | 17 | 10 |
| shell_or_setup | 22 | 23 | 6 |
