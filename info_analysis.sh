#!/usr/bin/env bash
set -euo pipefail

PR_REPO="${PR_REPO:-THIRD-EYE-DOME/Omega9}"
PR_NUMBER="${PR_NUMBER:-1}"
RUN_REPO="${RUN_REPO:-FISK-DIMENSION/Omega9}"
RUN_ID="${RUN_ID:-21902224487}"
WORKSPACE_ROOT="${WORKSPACE_ROOT:-$PWD}"
OUTPUT_PATH="${OUTPUT_PATH:-info_analysis_report.json}"

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

json_escape() {
  python3 -c 'import json,sys; print(json.dumps(sys.stdin.read()))'
}

write_report() {
  python3 - "$@" <<'PY'
import json
import sys
from pathlib import Path

output_path = Path(sys.argv[1])
payload = json.loads(sys.argv[2])
output_path.write_text(json.dumps(payload, indent=2) + "\n", encoding="utf-8")
print(f"wrote {output_path}")
PY
}

has_gh=false
if command -v gh >/dev/null 2>&1; then
  has_gh=true
fi

pr_data=""
pr_error=""
if [ "$has_gh" = true ]; then
  if gh pr view "$PR_NUMBER" --repo "$PR_REPO" --json number,title,body,headRefName,files > "$TMP_DIR/pr.json" 2> "$TMP_DIR/pr.err"; then
    pr_data="$(cat "$TMP_DIR/pr.json")"
  else
    pr_error="$(cat "$TMP_DIR/pr.err")"
  fi
else
  pr_error="gh CLI not installed"
fi

run_log_path="$TMP_DIR/run.log"
run_error=""
run_excerpt=""
if [ "$has_gh" = true ]; then
  if gh run view "$RUN_ID" --repo "$RUN_REPO" --log > "$run_log_path" 2> "$TMP_DIR/run.err"; then
    run_excerpt="$(tail -n 120 "$run_log_path")"
  else
    run_error="$(cat "$TMP_DIR/run.err")"
  fi
else
  run_error="gh CLI not installed"
fi

# Scan workflow files for likely trigger/job issues.
mapfile -t workflow_files < <(find "$WORKSPACE_ROOT" \( -type d -name node_modules -o -type d -name .git \) -prune -o -type f \( -path '*/.github/workflows/*.yml' -o -path '*/.github/workflows/*.yaml' \) -print 2>/dev/null | sort)

workflow_scan_json='[]'
if [ "${#workflow_files[@]}" -gt 0 ]; then
  workflow_scan_json="$(python3 - "$WORKSPACE_ROOT" "${workflow_files[@]}" <<'PY'
import json
import re
import sys
from pathlib import Path

workspace = Path(sys.argv[1]).resolve()
files = [Path(p) for p in sys.argv[2:]]
issues = []

for file_path in files:
    text = file_path.read_text(encoding='utf-8', errors='replace')
    rel = str(file_path.resolve().relative_to(workspace))
    lines = text.splitlines()

    has_on = bool(re.search(r'(?m)^\s*on\s*:', text))
    has_jobs = bool(re.search(r'(?m)^\s*jobs\s*:', text))

    if not has_on:
        issues.append({
            "file": rel,
            "severity": "error",
            "code": "missing_on",
            "message": "Workflow file has no top-level 'on:' trigger block."
        })

    if not has_jobs:
        issues.append({
            "file": rel,
            "severity": "error",
            "code": "missing_jobs",
            "message": "Workflow file has no top-level 'jobs:' block; this can produce 'No jobs were run'."
        })

    for i, line in enumerate(lines, start=1):
        if re.match(r'^\s*on\s*:\s*\{\s*\}\s*$', line):
            issues.append({
                "file": rel,
                "severity": "warning",
                "code": "empty_on",
                "line": i,
                "message": "Trigger block is explicitly empty (on: {}), so no events can start jobs."
            })

        if re.match(r'^\s*jobs\s*:\s*\{\s*\}\s*$', line):
            issues.append({
                "file": rel,
                "severity": "warning",
                "code": "empty_jobs",
                "line": i,
                "message": "Jobs block is explicitly empty (jobs: {}), so no jobs can run."
            })

print(json.dumps(issues))
PY
)"
fi

# Basic diagnostics from run logs (pattern-driven, no hard dependency on GH output format).
run_diagnostics='[]'
if [ -s "$run_log_path" ]; then
  run_diagnostics="$(python3 - "$run_log_path" <<'PY'
import json
import re
import sys
from pathlib import Path

log = Path(sys.argv[1]).read_text(encoding='utf-8', errors='replace')
diags = []

patterns = [
    (r'No jobs were run', 'no_jobs_ran', "GitHub Actions accepted the workflow but scheduled zero jobs; usually trigger mismatch or empty/missing jobs block."),
    (r'workflow .* is not valid', 'invalid_workflow_yaml', "Workflow syntax/validation error; inspect YAML structure and required keys."),
    (r'No event triggers defined in `on`', 'missing_trigger', "Workflow appears to be missing valid event triggers under 'on:'."),
    (r'The workflow is not valid\.', 'workflow_not_valid', "Workflow did not pass GitHub validation.")
]

for rx, code, msg in patterns:
    if re.search(rx, log, flags=re.IGNORECASE):
        diags.append({"code": code, "message": msg})

print(json.dumps(diags))
PY
)"
fi

python3 - "$OUTPUT_PATH" "$PR_REPO" "$PR_NUMBER" "$RUN_REPO" "$RUN_ID" "$has_gh" "$pr_data" "$pr_error" "$run_error" "$run_excerpt" "$workflow_scan_json" "$run_diagnostics" <<'PY'
import json
import sys
from datetime import datetime, timezone

(
    output_path,
    pr_repo,
    pr_number,
    run_repo,
    run_id,
    has_gh,
    pr_data,
    pr_error,
    run_error,
    run_excerpt,
    workflow_scan_json,
    run_diagnostics,
) = sys.argv[1:]

payload = {
    "generated_at": datetime.now(timezone.utc).isoformat(),
    "inputs": {
        "pr_repo": pr_repo,
        "pr_number": int(pr_number),
        "run_repo": run_repo,
        "run_id": int(run_id),
    },
    "environment": {
        "gh_installed": has_gh == "true",
    },
    "pr": {
        "fetched": bool(pr_data),
        "error": pr_error or None,
        "data": json.loads(pr_data) if pr_data else None,
    },
    "run": {
        "logs_fetched": run_error == "" and run_excerpt != "",
        "error": run_error or None,
        "log_excerpt_tail": run_excerpt or None,
        "diagnostics": json.loads(run_diagnostics),
    },
    "workflow_scan": {
        "issues": json.loads(workflow_scan_json),
    },
}

with open(output_path, "w", encoding="utf-8") as f:
    json.dump(payload, f, indent=2)
    f.write("\n")

print(f"wrote {output_path}")
PY
