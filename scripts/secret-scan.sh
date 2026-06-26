#!/usr/bin/env bash
# Scans a generated project directory for secrets using gitleaks.
# Usage: secret-scan.sh <project-dir>
set -euo pipefail

PROJECT_DIR="${1:-}"

if [[ -z "$PROJECT_DIR" || ! -d "$PROJECT_DIR" ]]; then
  echo "secret-scan: missing or invalid project directory: '$PROJECT_DIR'" >&2
  exit 1
fi

if ! command -v gitleaks >/dev/null 2>&1; then
  echo "secret-scan: gitleaks is not installed/available on PATH" >&2
  exit 1
fi

echo "secret-scan: scanning '$PROJECT_DIR' with gitleaks..."

if gitleaks detect --no-git --source "$PROJECT_DIR" --redact -v; then
  echo "secret-scan: PASS — no secrets detected"
  exit 0
else
  echo "secret-scan: FAIL — gitleaks flagged potential secrets" >&2
  exit 1
fi
