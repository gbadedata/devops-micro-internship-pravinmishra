#!/bin/bash
#
# pipeline-triage.sh - read-only failure triage for the EpicBook dual pipelines in Azure DevOps.
#
# Based on the course-supplied pipeline-triage.sh. Extended to meet the Week 10 Assignment 5
# requirements (both pipelines, Build Logs REST API, eight categories, state handling,
# sanitisation, exit code 3). Every change from the supplied file is listed in CHANGES.md.
#
# Read-only by design: the only HTTP request this script can send is a GET (see ado_get).
# It never queues, retries, cancels, deletes or approves a run, and it stores no secrets.
#
# Exit codes: 0 HEALTHY | 1 WARN (queued, running, partial, canceled) | 2 FAIL | 3 ERROR
#             (configuration, authentication, API or log-retrieval problem)

set -u
set -o pipefail

# >>> STUDENT CONFIGURATION: replace these placeholders (non-secret values only) <<<
full_name="<your-full-name>"
ado_org="<organization-url>"            # e.g. https://dev.azure.com/your-organization
ado_project="<project-name>"
infra_pipeline_id="<infra-pipeline-id>" # numeric ID of the Infrastructure Pipeline
app_pipeline_id="<app-pipeline-id>"     # numeric ID of the Application Pipeline
# <<< END OF STUDENT CONFIGURATION >>>

api_version="7.1"
ado_resource_id="499b84ac-1321-427f-aa17-267ca6975798" # Azure DevOps, for Entra ID tokens
max_evidence_lines=5

base_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
report_dir="$base_dir/reports"
report_file="$report_dir/pipeline-health-report.txt"
infra_log_file="$report_dir/infra-last-run.log"
app_log_file="$report_dir/app-last-run.log"

pipelines=(infra app)
declare -A pipeline_label=([infra]="Infrastructure Pipeline" [app]="Application Pipeline")
declare -A pipeline_id=([infra]="$infra_pipeline_id" [app]="$app_pipeline_id")
declare -A raw_log_file=([infra]="$infra_log_file" [app]="$app_log_file")

# Checks run in this order for each pipeline. Specific categories come before general ones,
# so the first category that matches is reported as the most likely cause.
checks=(
  check_run_state
  check_dependency_failure
  check_test_failure
  check_build_failure
  check_auth_failure
  check_agent_failure
  check_terraform_failure
  check_deployment_failure
  check_unclassified_failure
)

pass_count=0
warning_count=0
failure_count=0
error_count=0

# Per-pipeline state, filled by fetch_pipeline
declare -A fetched run_id run_number run_name run_status run_result run_branch run_commit
declare -A run_finished run_reason failed_steps evidence_file matched_count primary_category
declare -A primary_action
for key in "${pipelines[@]}"; do
  fetched[$key]=0; run_id[$key]=""; run_number[$key]=""; run_name[$key]=""
  run_status[$key]=""; run_result[$key]=""; run_branch[$key]=""; run_commit[$key]=""
  run_finished[$key]=""; run_reason[$key]=""; failed_steps[$key]=""; evidence_file[$key]=""
  matched_count[$key]=0; primary_category[$key]=""; primary_action[$key]=""
done

auth_header=""
auth_method=""
api_error=""
work_dir="$(mktemp -d)"
trap 'auth_header=""; rm -rf "$work_dir"' EXIT

mkdir -p "$report_dir"
: > "$report_file"

write_line() {
  echo "$1" | tee -a "$report_file"
}

mark_pass() {
  write_line "[PASS] $1"
  pass_count=$((pass_count + 1))
}

mark_warning() {
  write_line "[WARN] $1"
  warning_count=$((warning_count + 1))
}

mark_failure() {
  write_line "[FAIL] $1"
  failure_count=$((failure_count + 1))
}

mark_error() {
  write_line "[ERROR] $1"
  error_count=$((error_count + 1))
}

# Redact anything that looks like a credential before it reaches a log file or the report.
sanitize() {
  sed -E \
    -e '/-----BEGIN [A-Z ]*PRIVATE KEY-----/,/-----END [A-Z ]*PRIVATE KEY-----/c\[REDACTED: private key material removed]' \
    -e 's/(authorization:[[:space:]]*)(bearer|basic)[[:space:]]+[^[:space:]"]+/\1\2 [REDACTED]/Ig' \
    -e 's/(bearer[[:space:]]+)[A-Za-z0-9._~+\/=-]{8,}/\1[REDACTED]/Ig' \
    -e 's/eyJ[A-Za-z0-9_-]{8,}\.[A-Za-z0-9_-]{8,}\.[A-Za-z0-9_-]{8,}/[REDACTED-JWT]/g' \
    -e 's#([a-z][a-z0-9+.-]*://[^:/@[:space:]]+:)[^@[:space:]]+@#\1[REDACTED]@#Ig' \
    -e "s/((password|passwd|pwd|secret|client_secret|token|api[_-]?key|access[_-]?key|accountkey|sig)[[:space:]]*[=:][[:space:]]*)(\"[^\"]*\"|'[^']*'|[^[:space:],;&]+)/\1[REDACTED]/Ig" \
    -e 's/[A-Za-z0-9+_]{52,}={0,2}/[REDACTED-LONG-TOKEN]/g'
}

# Azure DevOps prefixes each log line with a timestamp, and the first line may carry a BOM.
strip_log_prefix() {
  sed -E -e 's/^\xEF\xBB\xBF//' -e 's/^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9:.]+Z //'
}

print_header() {
  write_line "========================================"
  write_line "CI/CD Pipeline Failure Triage Report"
  write_line "EpicBook dual pipelines (Azure DevOps)"
  write_line "========================================"
  write_line "Full Name: $full_name"
  write_line "Timestamp: $(date -u '+%Y-%m-%dT%H:%M:%SZ')"
  write_line "Organization: $ado_org"
  write_line "Project: $ado_project"
  write_line "Mode: read-only (HTTP GET requests only)"
  write_line ""
}

validate_config() {
  local ok=1
  local name value
  for name in full_name ado_org ado_project infra_pipeline_id app_pipeline_id; do
    value="${!name}"
    if [ -z "$value" ] || [[ "$value" == *"<"*">"* ]]; then
      mark_error "Configuration: '$name' still holds a placeholder or is empty; edit the STUDENT CONFIGURATION block"
      ok=0
    fi
  done
  for name in infra_pipeline_id app_pipeline_id; do
    value="${!name}"
    if [[ ! "$value" =~ ^[0-9]+$ ]] && [[ "$value" != *"<"*">"* ]] && [ -n "$value" ]; then
      mark_error "Configuration: '$name' must be the numeric pipeline ID, not '$value'"
      ok=0
    fi
  done
  if [[ "$ado_org" != *"<"*">"* ]] && [[ ! "$ado_org" =~ ^https?://[^[:space:]]+$ ]]; then
    mark_error "Configuration: 'ado_org' must be the organization URL, e.g. https://dev.azure.com/your-organization"
    ok=0
  fi
  local tool
  for tool in curl jq sed base64; do
    if ! command -v "$tool" > /dev/null 2>&1; then
      mark_error "Configuration: required tool '$tool' is not installed"
      ok=0
    fi
  done
  ado_org="${ado_org%/}"
  [ "$ok" -eq 1 ]
}

# Authentication. The credential lives only in this process's memory and is passed to curl
# on stdin, so it never appears in the report, a file, the command line or the process list.
setup_auth() {
  if [ -n "${AZURE_DEVOPS_EXT_PAT:-}" ]; then
    auth_method="Personal Access Token from the AZURE_DEVOPS_EXT_PAT environment variable"
    auth_header="Authorization: Basic $(printf ':%s' "$AZURE_DEVOPS_EXT_PAT" | base64 | tr -d '\n')"
    return 0
  fi
  if ! command -v az > /dev/null 2>&1; then
    mark_error "Authentication: no AZURE_DEVOPS_EXT_PAT is set and the Azure CLI is not installed"
    return 1
  fi
  local token
  token="$(az account get-access-token --resource "$ado_resource_id" --query accessToken -o tsv 2> /dev/null)" || token=""
  if [ -z "$token" ]; then
    mark_error "Authentication: could not get an Entra ID token; run 'az login', or export AZURE_DEVOPS_EXT_PAT (Build: Read scope) in this shell"
    return 1
  fi
  auth_method="Microsoft Entra ID token from the signed-in Azure CLI account"
  auth_header="Authorization: Bearer $token"
  token=""
  return 0
}

# The only function that talks to Azure DevOps. GET is hard-coded and no body is ever sent.
# Returns 0 on success, 10 for an authentication problem, 11 for not found, 12 for other errors.
ado_get() {
  local url="$1" out="$2" accept="${3:-application/json}"
  local code
  code="$(printf '%s\n' "$auth_header" | curl --silent --show-error --request GET \
    --header @- --header "Accept: $accept" --max-time 60 --retry 2 \
    --output "$out" --write-out '%{http_code}' "$url" 2> "$work_dir/curl.err")" || code="000"
  case "$code" in
    200)
      if [ "$accept" = "application/json" ] && ! jq empty "$out" > /dev/null 2>&1; then
        api_error="HTTP 200 but the response was not JSON (often a sign-in page): $url"
        return 10
      fi
      return 0
      ;;
    203 | 302 | 401 | 403)
      api_error="HTTP $code from Azure DevOps: authentication failed or the identity lacks read access"
      return 10
      ;;
    404)
      api_error="HTTP 404: not found (check the organization, project and pipeline ID): $url"
      return 11
      ;;
    000)
      api_error="Could not reach Azure DevOps: $(head -c 200 "$work_dir/curl.err" | tr '\n' ' ')"
      return 12
      ;;
    *)
      api_error="HTTP $code from Azure DevOps for $url"
      return 12
      ;;
  esac
}

report_api_error() {
  local label="$1" what="$2" rc="$3"
  case "$rc" in
    10) mark_error "$label: authentication error while reading $what. $api_error" ;;
    11) mark_error "$label: configuration error while reading $what. $api_error" ;;
    *) mark_error "$label: API error while reading $what. $api_error" ;;
  esac
}

# Retrieve the latest run's metadata (Build API) and its step logs (Build Logs REST API).
fetch_pipeline() {
  local key="$1"
  local label="${pipeline_label[$key]}"
  local id="${pipeline_id[$key]}"
  local project_enc
  project_enc="$(jq -rn --arg p "$ado_project" '$p|@uri')"
  local base="$ado_org/$project_enc/_apis/build/builds"
  local builds_json="$work_dir/$key-builds.json"
  local rc

  ado_get "$base?definitions=$id&queryOrder=queueTimeDescending&\$top=1&api-version=$api_version" "$builds_json"
  rc=$?
  if [ "$rc" -ne 0 ]; then
    report_api_error "$label" "run metadata" "$rc"
    return
  fi
  if [ "$(jq -r '.value | length' "$builds_json")" = "0" ]; then
    mark_error "$label: no run found for pipeline ID $id (check the ID, or run the pipeline once)"
    return
  fi

  run_id[$key]="$(jq -r '.value[0].id' "$builds_json")"
  run_number[$key]="$(jq -r '.value[0].buildNumber // ""' "$builds_json")"
  run_name[$key]="$(jq -r '.value[0].definition.name // ""' "$builds_json")"
  run_status[$key]="$(jq -r '.value[0].status // "unknown"' "$builds_json")"
  run_result[$key]="$(jq -r '.value[0].result // "none"' "$builds_json")"
  run_branch[$key]="$(jq -r '(.value[0].sourceBranch // "") | sub("^refs/heads/"; "")' "$builds_json")"
  run_commit[$key]="$(jq -r '(.value[0].sourceVersion // "")[0:8]' "$builds_json")"
  run_finished[$key]="$(jq -r '.value[0].finishTime // "not finished"' "$builds_json")"
  run_reason[$key]="$(jq -r '.value[0].reason // ""' "$builds_json")"
  fetched[$key]=1

  local log_out="${raw_log_file[$key]}"
  local scope="$work_dir/$key-evidence.txt"
  evidence_file[$key]="$scope"
  : > "$scope"
  {
    echo "Raw step logs (sanitized) for the $label"
    echo "Pipeline: ${run_name[$key]} (ID $id)  Run: ${run_number[$key]} (run ID ${run_id[$key]})"
    echo "Status: ${run_status[$key]}  Result: ${run_result[$key]}  Branch: ${run_branch[$key]}"
    echo
  } > "$log_out"

  # Build validation errors (for example a missing secure file) have no step log at all.
  jq -r '.value[0].validationResults[]? | select(.result == "error") | "Pipeline validation | " + .message' \
    "$builds_json" | sanitize >> "$scope"

  if [ "${run_status[$key]}" != "completed" ]; then
    echo "The run is ${run_status[$key]}; logs are not final, so they were not downloaded." >> "$log_out"
    return
  fi
  if [ -s "$scope" ]; then
    echo "The run failed pipeline validation before any step ran, so it has no step logs." >> "$log_out"
    cat "$scope" >> "$log_out"
    return
  fi

  # Timeline: step names, results, log IDs and error messages.
  local timeline="$work_dir/$key-timeline.json"
  ado_get "$base/${run_id[$key]}/timeline?api-version=$api_version" "$timeline"
  rc=$?
  if [ "$rc" -ne 0 ]; then
    report_api_error "$label" "the run timeline" "$rc"
    return
  fi
  failed_steps[$key]="$(jq -r '[.records[]? | select(.type == "Task" and (.result == "failed" or .result == "succeededWithIssues")) | .name] | join(", ")' "$timeline")"

  # Build Logs REST API: list the logs, then download each one as plain text.
  local logs_json="$work_dir/$key-logs.json"
  ado_get "$base/${run_id[$key]}/logs?api-version=$api_version" "$logs_json"
  rc=$?
  if [ "$rc" -ne 0 ]; then
    report_api_error "$label" "the log list" "$rc"
    return
  fi
  local log_ids log_id step_name
  log_ids="$(jq -r '.value[]?.id' "$logs_json")"
  if [ -z "$log_ids" ]; then
    mark_error "$label: the run has no downloadable logs (log-retrieval error)"
    return
  fi
  for log_id in $log_ids; do
    ado_get "$base/${run_id[$key]}/logs/$log_id?api-version=$api_version" "$work_dir/$key-log-$log_id.txt" "text/plain"
    rc=$?
    if [ "$rc" -ne 0 ]; then
      report_api_error "$label" "log $log_id" "$rc"
      return
    fi
    step_name="$(jq -r --argjson l "$log_id" 'first(.records[]? | select(.log.id? == $l) | .name) // "Log \($l)"' "$timeline")"
    {
      echo "===== Log $log_id: $step_name ====="
      strip_log_prefix < "$work_dir/$key-log-$log_id.txt" | sanitize
      echo
    } >> "$log_out"
  done

  # Evidence scope: only the failed steps' logs and error messages, so successful steps
  # (which legitimately print words like "error" or "failed=0") cannot cause false matches.
  local failed_log_ids
  failed_log_ids="$(jq -r '.records[]? | select(.type == "Task" and (.result == "failed" or .result == "succeededWithIssues") and .log != null) | .log.id' "$timeline")"
  for log_id in $failed_log_ids; do
    step_name="$(jq -r --argjson l "$log_id" 'first(.records[]? | select(.log.id? == $l) | .name)' "$timeline")"
    strip_log_prefix < "$work_dir/$key-log-$log_id.txt" | sanitize | awk -v p="$step_name | " '{ print p $0 }' >> "$scope"
  done
  jq -r '.records[]? | select(.result == "failed") | .name as $n | .issues[]? | select(.type == "error") | $n + " | [issue] " + .message' \
    "$timeline" | sanitize >> "$scope"
  if [ ! -s "$scope" ] && [ "${run_result[$key]}" != "succeeded" ]; then
    for log_id in $log_ids; do
      strip_log_prefix < "$work_dir/$key-log-$log_id.txt" | sanitize | awk -v p="Log $log_id | " '{ print p $0 }' >> "$scope"
    done
  fi
}

print_metadata() {
  local key="$1"
  write_line "Pipeline name: ${run_name[$key]}"
  write_line "Pipeline ID: ${pipeline_id[$key]}"
  write_line "Run: ${run_number[$key]} (run ID ${run_id[$key]})"
  write_line "Branch: ${run_branch[$key]} (commit ${run_commit[$key]})"
  write_line "Trigger: ${run_reason[$key]}"
  write_line "Status: ${run_status[$key]}"
  write_line "Result: ${run_result[$key]}"
  write_line "Completion time: ${run_finished[$key]}"
  write_line "Failed step(s): ${failed_steps[$key]:-none}"
  write_line "Raw log file: ${raw_log_file[$key]#"$base_dir"/}"
}

# Shared logic for the category checks. Case-insensitive extended regular expressions.
check_category() {
  local key="$1" category="$2" pattern="$3" action="$4"
  local label="${pipeline_label[$key]}"
  local result="${run_result[$key]}"
  if [ "$result" != "failed" ] && [ "$result" != "partiallySucceeded" ]; then
    mark_pass "$label: no $category detected"
    return
  fi
  local matches
  matches="$(grep -iE -- "$pattern" "${evidence_file[$key]}" 2> /dev/null | head -n "$max_evidence_lines")"
  if [ -z "$matches" ]; then
    mark_pass "$label: no $category detected"
    return
  fi
  if [ "$result" = "failed" ]; then
    mark_failure "$label: $category detected"
  else
    mark_warning "$label: $category detected in a partially successful run"
  fi
  write_line "    Evidence (sanitized):"
  local line
  while IFS= read -r line; do
    write_line "      $line"
  done <<< "$matches"
  matched_count[$key]=$((matched_count[$key] + 1))
  if [ -z "${primary_category[$key]}" ]; then
    primary_category[$key]="$category"
    primary_action[$key]="$action"
  fi
}

check_run_state() {
  local key="$1"
  local label="${pipeline_label[$key]}"
  local where="run ${run_number[$key]} (run ID ${run_id[$key]}) on ${run_branch[$key]}"
  case "${run_status[$key]}:${run_result[$key]}" in
    completed:succeeded) mark_pass "$label: $where succeeded" ;;
    completed:failed) mark_failure "$label: $where failed" ;;
    completed:partiallySucceeded) mark_warning "$label: $where partially succeeded, so it is not fully healthy" ;;
    completed:canceled) mark_warning "$label: $where was canceled; its final result is unknown, so it is not healthy" ;;
    inProgress:* | notStarted:* | postponed:* | cancelling:*)
      mark_warning "$label: $where is ${run_status[$key]}; the final result is not known yet, so it is not reported as healthy" ;;
    *) mark_warning "$label: $where has an unexpected state (${run_status[$key]}/${run_result[$key]})" ;;
  esac
}

check_dependency_failure() {
  check_category "$1" "dependency installation failure" \
    'npm (ERR!|error)|ERESOLVE|ETARGET|E404|is not in this registry|No matching version found|Cannot find module|ModuleNotFoundError|No matching distribution found|ResolutionImpossible|Unable to locate package|has no installation candidate' \
    "Fix the package name or version shown in the evidence (package.json and package-lock.json), commit it, then queue the pipeline again yourself."
}

check_test_failure() {
  check_category "$1" "test failure" \
    'Tests?:[[:space:]]+[0-9]+ failed|Test Suites:[[:space:]]+[0-9]+ failed|[0-9]+ failing|AssertionError|expect\(received\)|FAIL[[:space:]]+[^[:space:]]+\.(test|spec)\.' \
    "Read the failing assertion in the evidence and correct the code or the test, then queue the pipeline again yourself."
}

check_build_failure() {
  check_category "$1" "build or compilation failure" \
    'Failed to compile|Compilation failed|Module build failed|error TS[0-9]{4}|SyntaxError|webpack.*(failed|error)|build failed|[0-9]+ problems? \([0-9]+ errors?' \
    "Fix the source error at the file and line shown in the evidence, then queue the pipeline again yourself."
}

check_auth_failure() {
  check_category "$1" "authentication, authorization or SSH failure" \
    '401 Unauthorized|403 Forbidden|TF400813|TF401019|AADSTS[0-9]+|invalid_grant|token (has )?expired|Authentication failed|AuthorizationFailed|does not have authorization|has not been authorized|Permission denied \(publickey|Host key verification failed|Access denied for user|Cannot parse privateKey' \
    "Check the service connection, secure file or credential named in the evidence and its pipeline permissions, without pasting any secret into a chat, then queue the pipeline again yourself."
}

check_agent_failure() {
  check_category "$1" "agent availability, timeout or queue failure" \
    'No agent found in pool|could not find a pool|agent .*(went offline|is offline|lost communication)|timed out waiting for an agent|ran longer than the maximum time|exceeded the maximum execution time|The agent request is not running|The job was abandoned' \
    "Check that the self-hosted agent is Online in its pool and that its service is running, then queue the pipeline again yourself."
}

check_terraform_failure() {
  check_category "$1" "Terraform infrastructure or provisioning failure" \
    '│ Error:|Error: (creating|updating|deleting|reading|retrieving|building|Invalid|Unsupported|Missing required|Reference to undeclared|Failed to)|Error acquiring the state lock|Planning failed|terraform (init|plan|apply|validate) .*fail' \
    "Read the Terraform error and the resource it names, correct the configuration in epicbook-infra, review a new plan, then approve the apply yourself."
}

check_deployment_failure() {
  check_category "$1" "Ansible, Nginx or application deployment failure" \
    'fatal: \[|FAILED! =>|UNREACHABLE!|failed=[1-9]|unreachable=[1-9]|ERROR! |nginx: \[emerg\]|Job for [^ ]+ failed|FAIL: the backend application port|curl: \(7\)' \
    "Read the failing Ansible task and host in the evidence, correct the role or variable in epicbook-app, then queue the pipeline again yourself."
}

check_unclassified_failure() {
  local key="$1"
  local label="${pipeline_label[$key]}"
  if [ "${run_result[$key]}" = "failed" ] && [ "${matched_count[$key]}" -eq 0 ]; then
    mark_failure "$label: unclassified pipeline failure (Azure DevOps reports 'failed' but no known pattern matched)"
    local first
    first="$(grep -iE 'error|fail' "${evidence_file[$key]}" 2> /dev/null | head -n "$max_evidence_lines")"
    write_line "    Evidence (sanitized):"
    if [ -n "$first" ]; then
      local line
      while IFS= read -r line; do
        write_line "      $line"
      done <<< "$first"
    else
      write_line "      No error line could be extracted safely; open the failed step in the portal."
    fi
    primary_category[$key]="unclassified pipeline failure"
    primary_action[$key]="Open the failed step (${failed_steps[$key]:-see the run}) in the portal, identify the error, and add a pattern for it if it recurs."
  else
    mark_pass "$label: no unclassified failure"
  fi
}

print_verdict() {
  local key="$1"
  local verdict
  case "${run_status[$key]}:${run_result[$key]}" in
    completed:succeeded) verdict="HEALTHY" ;;
    completed:failed) verdict="FAILED" ;;
    *) verdict="NOT HEALTHY (${run_status[$key]}/${run_result[$key]})" ;;
  esac
  write_line "Pipeline verdict: $verdict"
  if [ -n "${primary_category[$key]}" ]; then
    write_line "Most likely failure category: ${primary_category[$key]}"
    write_line "Recommended human action: ${primary_action[$key]}"
  fi
}

print_summary() {
  local overall_status
  local script_exit_code

  if [ "$error_count" -gt 0 ]; then
    overall_status="ERROR"
    script_exit_code=3
  elif [ "$failure_count" -gt 0 ]; then
    overall_status="FAIL"
    script_exit_code=2
  elif [ "$warning_count" -gt 0 ]; then
    overall_status="WARN"
    script_exit_code=1
  else
    overall_status="HEALTHY"
    script_exit_code=0
  fi

  write_line ""
  write_line "Summary:"
  write_line "PASS: $pass_count"
  write_line "WARN: $warning_count"
  write_line "FAIL: $failure_count"
  write_line "ERROR: $error_count"
  write_line "Overall Status: $overall_status"
  write_line "Script Exit Code: $script_exit_code"
  write_line "Report File: ${report_file#"$base_dir"/}"
  write_line "Raw Log Files: ${infra_log_file#"$base_dir"/}, ${app_log_file#"$base_dir"/}"

  return "$script_exit_code"
}

print_header

if validate_config && setup_auth; then
  write_line "Authentication: $auth_method"
  write_line ""
  for key in "${pipelines[@]}"; do
    write_line "---------------- ${pipeline_label[$key]} ----------------"
    fetch_pipeline "$key"
    if [ "${fetched[$key]}" -eq 1 ]; then
      print_metadata "$key"
      write_line ""
      for check_function in "${checks[@]}"; do
        "$check_function" "$key"
      done
      write_line ""
      print_verdict "$key"
    else
      write_line "Checks were not run for this pipeline because its run could not be retrieved."
    fi
    write_line ""
  done
fi

print_summary
exit $?
