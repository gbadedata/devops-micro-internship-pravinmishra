#!/usr/bin/env bash
# Read-only Kubernetes incident-triage script.

set -u
set -o pipefail

# All Kubernetes requests are bounded; this wrapper only runs read commands.
kubectl() { command kubectl --request-timeout=15s "$@"; }

# Replace these values with the Book Review App values discovered in Task 1.
full_name="Oluwagbade Odimayo"
namespace="book-review"
app_label="app=book-review,tier=backend"
service_name="backend"

base_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
report_dir="$base_dir/reports"
report_file="$report_dir/k8s-health-report.txt"
checks=(check_pod_status check_pod_ready check_restarts check_events check_service_endpoints)

pass_count=0
warning_count=0
failure_count=0
preflight_failed=false

mkdir -p "$report_dir"
: > "$report_file"

write_line() { echo "$1" | tee -a "$report_file"; }
mark_pass() { write_line "[PASS] $1"; pass_count=$((pass_count + 1)); }
mark_warning() { write_line "[WARN] $1"; warning_count=$((warning_count + 1)); }
mark_failure() { write_line "[FAIL] $1"; failure_count=$((failure_count + 1)); }

print_header() {
  write_line "========================================"
  write_line "Kubernetes Incident Triage Report"
  write_line "========================================"
  write_line "Full Name: $full_name"
  write_line "Timestamp: $(date -u '+%Y-%m-%dT%H:%M:%SZ')"
  write_line "Namespace: $namespace"
  write_line "App Label: $app_label"
  write_line "Service: $service_name"
  write_line ""
}

get_pods() {
  kubectl get pods -n "$namespace" -l "$app_label" -o wide
}

preflight() {
  local output pod_count
  if [ "$full_name" = "<Your Full Name>" ] || [ -z "$full_name" ]; then
    mark_failure "Set full_name to your name before running the script."
    preflight_failed=true
    return
  fi

  output=$(kubectl get namespace "$namespace" --request-timeout=10s 2>&1)
  if [ $? -ne 0 ]; then
    mark_failure "Cannot access namespace '$namespace'. Check kubectl context, namespace, and permissions."
    write_line "  $output"
    preflight_failed=true
    return
  fi

  output=$(kubectl get pods -n "$namespace" -l "$app_label" -o name 2>&1)
  if [ $? -ne 0 ]; then
    mark_failure "Cannot list pods using label '$app_label'."
    write_line "  $output"
    preflight_failed=true
    return
  fi

  pod_count=$(printf '%s\n' "$output" | sed '/^$/d' | wc -l | tr -d ' ')
  if [ "$pod_count" -eq 0 ]; then
    mark_failure "No pods match label '$app_label' in namespace '$namespace'. Verify the configuration values."
    preflight_failed=true
  else
    mark_pass "Cluster access, namespace, and matching pod selection verified ($pod_count pod(s))"
  fi
}

check_pod_status() {
  local output bad_pods
  write_line ""
  write_line "Pod status (kubectl get pods -o wide):"
  output=$(get_pods 2>&1)
  if [ $? -ne 0 ]; then
    mark_failure "Unable to retrieve pod status."
    write_line "  $output"
    return
  fi
  printf '%s\n' "$output" | sed 's/^/  /' | tee -a "$report_file"
  bad_pods=$(printf '%s\n' "$output" | awk '$3 ~ /CrashLoopBackOff|ImagePullBackOff|ErrImagePull|Pending|ContainerCreating|Error|Unknown/ {print $1, $3}')
  if [ -n "$bad_pods" ]; then
    mark_failure "One or more pods are in a bad state: $bad_pods"
  else
    mark_pass "No pods reporting CrashLoopBackOff, ImagePullBackOff, ErrImagePull, Pending, ContainerCreating, Error, or Unknown"
  fi
}

check_pod_ready() {
  local output not_ready
  output=$(kubectl get pods -n "$namespace" -l "$app_label" --no-headers 2>&1)
  if [ $? -ne 0 ]; then
    mark_failure "Unable to retrieve pod readiness."
    return
  fi
  not_ready=$(printf '%s\n' "$output" | awk -F'[ /]+' '{if ($2 != $3 || $3 == 0) print $1 " (READY " $2 "/" $3 ")"}')
  if [ -n "$not_ready" ]; then
    mark_failure "Pod(s) not passing readiness: $not_ready"
  else
    mark_pass "All matching pods report READY containers equal to desired containers"
  fi
}

check_restarts() {
  local output high_restart
  output=$(kubectl get pods -n "$namespace" -l "$app_label" --no-headers 2>&1)
  if [ $? -ne 0 ]; then
    mark_failure "Unable to retrieve restart counts."
    return
  fi
  high_restart=$(printf '%s\n' "$output" | awk '$4 + 0 >= 5 {print $1 " (" $4 " restarts)"}')
  if [ -n "$high_restart" ]; then
    mark_warning "Pod(s) with 5 or more restarts: $high_restart"
  else
    mark_pass "No pod has 5 or more restarts"
  fi
}

check_events() {
  local output warning_events
  write_line ""
  write_line "Recent namespace events (last 5, sorted by time):"
  output=$(kubectl get events -n "$namespace" --sort-by=.lastTimestamp --no-headers 2>&1)
  if [ $? -ne 0 ]; then
    mark_failure "Unable to retrieve namespace events."
    write_line "  $output"
    return
  fi
  printf '%s\n' "$output" | tail -n 5 | sed 's/^/  /' | tee -a "$report_file"
  warning_events=$(printf '%s\n' "$output" | awk '$2 == "Warning" {print}')
  if [ -n "$warning_events" ]; then
    mark_warning "Warning events are present (including historical events); confirm age and workload before attributing a cause."
  else
    mark_pass "No Warning-type events found in the namespace"
  fi
}

check_service_endpoints() {
  local output addresses
  if ! output=$(kubectl get service "$service_name" -n "$namespace" -o name 2>&1); then
    mark_failure "Unable to retrieve Service '$service_name'."
    write_line "  $output"
    return
  fi
  if output=$(kubectl get endpointslice -n "$namespace" -l "kubernetes.io/service-name=$service_name" -o jsonpath='{range .items[*]}{"Slice: "}{.metadata.name}{" Ports: "}{range .ports[*]}{.port}{" "}{end}{"\n"}{range .endpoints[*]}{.targetRef.name}{" ready="}{.conditions.ready}{" addresses="}{.addresses}{"\n"}{end}{end}' 2>&1); then
    write_line "Service EndpointSlice evidence:"
    write_line "$output"
    addresses=$(kubectl get endpointslice -n "$namespace" -l "kubernetes.io/service-name=$service_name" -o jsonpath='{range .items[*].endpoints[?(@.conditions.ready==true)]}{.addresses[0]}{"\n"}{end}' 2>&1)
    if [ $? -ne 0 ]; then
      mark_failure "Unable to retrieve ready Service backends."
      write_line "$addresses"
      return
    fi
  else
    write_line "EndpointSlice query failed; attempting Endpoints fallback:"
    write_line "$output"
    if ! addresses=$(kubectl get endpoints "$service_name" -n "$namespace" -o jsonpath='{range .subsets[*].addresses[*]}{.ip}{"\n"}{end}' 2>&1); then
      mark_failure "Unable to inspect Service backends using either API."
      write_line "$addresses"
      return
    fi
  fi
  if [ -z "$addresses" ]; then
    mark_failure "Service '$service_name' has no ready backends."
  else
    mark_pass "Service '$service_name' has ready backend(s): $addresses"
  fi
}

capture_recent_logs() {
  local crash_pod log_output
  write_line ""
  write_line "Previous-container logs for the first non-running pod (last 10 lines):"
  crash_pod=$(kubectl get pods -n "$namespace" -l "$app_label" --no-headers 2>/dev/null | awk '$3 != "Running" {print $1; exit}')
  if [ -z "$crash_pod" ]; then
    write_line "  All matching pods are Running — no previous-container logs to capture."
    return
  fi
  log_output=$(kubectl logs "$crash_pod" -n "$namespace" --previous --tail=10 2>&1 || true)
  if [ -n "$log_output" ]; then
    printf '%s\n' "$log_output" | sed 's/^/  /' | tee -a "$report_file"
  else
    write_line "  No previous-container logs available for $crash_pod."
  fi
}

print_summary() {
  local overall_status script_exit_code
  if [ "$failure_count" -gt 0 ]; then
    overall_status="FAIL"; script_exit_code=2
  elif [ "$warning_count" -gt 0 ]; then
    overall_status="WARN"; script_exit_code=1
  else
    overall_status="HEALTHY"; script_exit_code=0
  fi
  write_line ""
  write_line "Summary:"
  write_line "PASS: $pass_count"
  write_line "WARN: $warning_count"
  write_line "FAIL: $failure_count"
  write_line "Overall Status: $overall_status"
  write_line "Script Exit Code: $script_exit_code"
  write_line "Report File: $report_file"
  return "$script_exit_code"
}

print_header
preflight
if [ "$preflight_failed" = false ]; then
  for check_function in "${checks[@]}"; do "$check_function"; done
  capture_recent_logs
fi
print_summary
exit $?
