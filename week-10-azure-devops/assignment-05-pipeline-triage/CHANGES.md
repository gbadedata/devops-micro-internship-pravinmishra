# Changes from the supplied resource files

The Udemy resource ZIP for this assignment (files dated 12 September 2026) contains an earlier,
single-pipeline version of `pipeline-triage.sh` and `SKILL.md`. Filling in only their
placeholders cannot meet the current Assignment 5 requirements, and the files cannot pass the
Task 3 syntax check as downloaded. I asked the mentors whether an updated version was coming and
received no reply, so I extended the supplied files and recorded every change here.

The files exactly as downloaded are preserved in this folder's Git history (the first commit),
so each change below can be checked with `git diff` against them.

## pipeline-triage.sh

| # | Supplied file | Requirement it failed | Change |
|---|---|---|---|
| 1 | Windows (CRLF) line endings | `bash -n` must pass (Task 3) | Converted to LF. `bash -n` now passes. |
| 2 | `base_dir` resolved to the parent of the script's folder | Reports must be in the assignment's `reports/` folder (Task 3) | `base_dir` is now the script's own folder. |
| 3 | One `ado_pipeline_id`, plus GitHub Actions support | Both pipelines; GitHub Actions not required | Separate `infra_pipeline_id` and `app_pipeline_id`; GitHub Actions code removed. |
| 4 | Only `az pipelines runs show` metadata; its own comment says it cannot get step logs | Actual console logs through the Build Logs REST API (Task 3) | Metadata from the Build API; logs listed and downloaded through the Build Logs REST API, one log at a time, as text. |
| 5 | One `pipeline-last-run.log` | `infra-last-run.log` and `app-last-run.log` | One raw log per pipeline, each section labelled with its step name. |
| 6 | Five categories | Eight required categories | Added Terraform, Ansible/Nginx/deployment, and unclassified failure. Ordered from specific to general. |
| 7 | Not configured reported HEALTHY with exit 0 | Configuration, authentication and API errors must never be healthy | Placeholder, ID, tool and URL validation; HTTP status handling (203/401/403 auth, 404 not found); `ERROR` state with exit code 3. |
| 8 | No handling of queued, running, canceled, partial or missing runs | Required state handling | `check_run_state` handles each; incomplete states are WARN (exit 1); no run found is ERROR (exit 3). |
| 9 | No sanitisation | Evidence must be sanitised | `sanitize` redacts authorization headers, Bearer tokens, JWTs, long token strings, `key=value` secrets, passwords inside connection URLs, and private-key blocks, before anything is written. |
| 10 | Patterns searched the whole log | Avoid false matches | Categories are matched only against the failed steps' logs and error messages. Successful steps print words like `failed=0` that would otherwise match. |
| 11 | `npm ERR!` only | npm 10 prints `npm error` | Both forms matched. |
| 12 | Report had no run details | Report must show name, ID, run ID, branch, status, result, completion time | Added, plus the failed step names and a recommended human action. |

Kept from the supplied file: the variable names (`full_name`, `base_dir`, `report_dir`,
`report_file`, the three counters), `write_line`, `mark_pass`, `mark_warning`, `mark_failure`,
`print_header`, the `checks=( ... )` array and the loop that runs it, and `print_summary` with the
same exit-code meaning for 0, 1 and 2.

Read-only guarantees: `ado_get` is the only function that contacts Azure DevOps, and it sends
`GET` with no request body. The credential is held only in memory and passed to `curl` on standard
input, so it never appears in a file, the report, the command line or the process list.

## SKILL.md

| # | Supplied file | Requirement it failed | Change |
|---|---|---|---|
| 1 | `allowed-tools: Bash, Read, Grep` | No broad Bash approval (Task 5) | Pre-approves only `Bash(./pipeline-triage.sh)`, plus `Read` and `Grep`. |
| 2 | No tool restriction | File-editing tools must be restricted (Task 5) | `disallowed-tools: Edit, Write, NotebookEdit`. |
| 3 | `bash pipeline-triage.sh \|\| true` | The exit code must be visible | Runs `./pipeline-triage.sh`; the report prints `Script Exit Code`. |
| 4 | Read `pipeline-last-run.log` | Two raw logs | Reads `infra-last-run.log` or `app-last-run.log`. |
| 5 | Output list | Output must match CLAUDE.md's Output Rules | Same nine items, in the same order. |

Kept: the name, `disable-model-invocation: true`, and the structure and wording of the nine steps.

## Added

- `CLAUDE.md`, created from Task 2 of the lesson.
- `.claude/settings.json`, project deny rules for file edits, pipeline and cloud commands,
  `curl`, `git push`, shell wrappers, environment dumps, and reads of credential folders. The
  skill's `allowed-tools` cannot override these.
