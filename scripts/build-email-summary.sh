#!/usr/bin/env bash
# Builds a plain-text daily summary from log/dashboard.md for the given date,
# one track at a time, using only what's actually logged there so the email
# matches the dashboard exactly.
# Usage: build-email-summary.sh <dashboard-file> <YYYY-MM-DD>
set -euo pipefail

DASHBOARD="${1:-log/dashboard.md}"
DATE_STR="${2:-$(date -u +%Y-%m-%d)}"

if [[ ! -f "$DASHBOARD" ]]; then
  echo "build-email-summary: dashboard file not found: '$DASHBOARD'" >&2
  exit 1
fi

echo "Daily Project Builder summary for ${DATE_STR}"
echo

for TRACK in serious fun; do
  # Last matching row wins, in case a track was re-run more than once today.
  row=$(grep -F "| ${DATE_STR} | ${TRACK} |" "$DASHBOARD" | tail -n1 || true)
  track_label="$(echo "${TRACK:0:1}" | tr '[:lower:]' '[:upper:]')${TRACK:1}"

  echo "== ${track_label} track =="

  if [[ -z "$row" ]]; then
    echo "Status: NO DATA — no row logged for ${DATE_STR} (job likely failed before the logging step ran)."
    echo
    continue
  fi

  IFS='|' read -r _ _date _track repo_name repo_url tests secrets_check attribution pages notes _ <<< "$row"
  repo_name=$(echo "$repo_name" | xargs)
  repo_url=$(echo "$repo_url" | xargs)
  tests=$(echo "$tests" | xargs)
  secrets_check=$(echo "$secrets_check" | xargs)
  attribution=$(echo "$attribution" | xargs)
  pages=$(echo "$pages" | xargs)
  notes=$(echo "$notes" | xargs)

  if [[ "$repo_name" == "n/a" ]]; then
    echo "Status: FAILED — no repo published"
    failed_gates=""
    [[ "$tests" == "fail" ]] && failed_gates="${failed_gates}tests "
    [[ "$secrets_check" == "fail" ]] && failed_gates="${failed_gates}secret-scan "
    [[ "$attribution" == "fail" ]] && failed_gates="${failed_gates}attribution-scan "
    if [[ -n "$failed_gates" ]]; then
      echo "Failed gate(s): ${failed_gates}"
    fi
  else
    echo "Status: SUCCESS"
    latin_word=$(echo "$repo_name" | sed -E "s/-${DATE_STR}(-[0-9]+)?\$//")
    echo "Project (Latin word): ${latin_word}"
    echo "Repo: ${repo_url}"
    if [[ -n "$pages" ]]; then
      echo "Pages: ${pages}"
    fi
    echo "Tests: ${tests} | Secret scan: ${secrets_check} | Attribution scan: ${attribution}"
  fi

  if [[ -n "$notes" ]]; then
    echo "Notes: ${notes}"
  fi

  echo
done
