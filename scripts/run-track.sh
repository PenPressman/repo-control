#!/usr/bin/env bash
# Orchestrates one track (serious or fun) of the daily build:
# research -> build -> gate checks -> publish -> dashboard update.
#
# Expects to run from the root of the control repo checkout, with:
#   TRACK         = "serious" or "fun"
#   PROMPT_FILE   = path (relative to repo root) to the build prompt to use
#   CLAUDE_MAX_TURNS, ANTHROPIC_API_KEY, GH_TOKEN set in the environment
set -euo pipefail

REPO_ROOT="$(pwd)"
TRACK="${TRACK:?TRACK must be set}"
PROMPT_FILE="${PROMPT_FILE:?PROMPT_FILE must be set}"
CLAUDE_MAX_TURNS="${CLAUDE_MAX_TURNS:-30}"
DATE_STR=$(date -u +%Y-%m-%d)

WORK_DIR="/tmp/daily-build-${TRACK}"
rm -rf "$WORK_DIR"
mkdir -p "$WORK_DIR"
cp "$REPO_ROOT/data/latin-glossary.json" "$WORK_DIR/latin-glossary.json"

append_dashboard_row() {
  local repo_name="$1" repo_url="$2" tests="$3" secrets_check="$4" attribution="$5" pages_url="$6" notes="$7"
  cd "$REPO_ROOT"
  for attempt in 1 2 3 4 5; do
    git fetch origin "${GITHUB_REF_NAME:-main}" >/dev/null 2>&1 || true
    git pull --rebase origin "${GITHUB_REF_NAME:-main}" >/dev/null 2>&1 || true
    echo "| ${DATE_STR} | ${TRACK} | ${repo_name} | ${repo_url} | ${tests} | ${secrets_check} | ${attribution} | ${pages_url} | ${notes} |" >> log/dashboard.md
    git add log/dashboard.md
    git -c user.name="daily-project-builder" -c user.email="actions@users.noreply.github.com" \
      commit -q -m "Log ${TRACK} build result for ${DATE_STR}" || return 0
    if git push origin "HEAD:${GITHUB_REF_NAME:-main}"; then
      return 0
    fi
    echo "run-track: push conflict, retrying (attempt ${attempt})..." >&2
    git reset --hard "origin/${GITHUB_REF_NAME:-main}" >/dev/null 2>&1 || true
    sleep $((attempt * 3))
  done
  echo "run-track: failed to push dashboard update after retries" >&2
  return 1
}

# --- Research step ---
cd "$WORK_DIR"
echo "run-track: running research step for track=${TRACK}"
TRACK="$TRACK" claude -p "$(cat "$REPO_ROOT/prompts/research.md")" \
  --max-turns "$CLAUDE_MAX_TURNS" \
  --permission-mode bypassPermissions \
  --output-format text

if [[ ! -f "$WORK_DIR/IDEA.md" ]]; then
  echo "run-track: research step did not produce IDEA.md" >&2
  append_dashboard_row "n/a" "n/a" "n/a" "n/a" "n/a" "n/a" "FAILED: research step produced no IDEA.md"
  exit 1
fi

LATIN_WORD=$(grep -m1 '^\*\*Latin word:\*\*' "$WORK_DIR/IDEA.md" | sed 's/^\*\*Latin word:\*\* *//' | tr -d '\r')
if [[ -z "$LATIN_WORD" ]]; then
  LATIN_WORD="${TRACK}-project"
fi

# --- Build step ---
echo "run-track: running build step for track=${TRACK}, idea: $(head -n3 "$WORK_DIR/IDEA.md" | tail -n1)"
claude -p "$(cat "$REPO_ROOT/$PROMPT_FILE")" \
  --max-turns "$CLAUDE_MAX_TURNS" \
  --permission-mode bypassPermissions \
  --output-format text

# --- Gate checks ---
TESTS_RESULT="fail"
SECRETS_RESULT="fail"
ATTRIBUTION_RESULT="fail"
GATE_FAILED=0
NOTES=""

if bash "$REPO_ROOT/scripts/verify-success.sh" "$WORK_DIR"; then
  TESTS_RESULT="pass"
else
  GATE_FAILED=1
  NOTES="${NOTES}verify-success failed. "
fi

if bash "$REPO_ROOT/scripts/secret-scan.sh" "$WORK_DIR"; then
  SECRETS_RESULT="pass"
else
  GATE_FAILED=1
  NOTES="${NOTES}secret-scan failed. "
fi

if bash "$REPO_ROOT/scripts/attribution-scan.sh" "$WORK_DIR"; then
  ATTRIBUTION_RESULT="pass"
else
  GATE_FAILED=1
  NOTES="${NOTES}attribution-scan failed. "
fi

if [[ "$GATE_FAILED" -eq 1 ]]; then
  echo "run-track: one or more gates failed, aborting publish" >&2
  append_dashboard_row "n/a" "n/a" "$TESTS_RESULT" "$SECRETS_RESULT" "$ATTRIBUTION_RESULT" "n/a" "${NOTES}No repo created."
  exit 1
fi

# --- Publish ---
echo "run-track: all gates passed, publishing"
PUBLISH_OUTPUT=$(bash "$REPO_ROOT/scripts/create-and-push-repo.sh" "$WORK_DIR" "$LATIN_WORD" "$TRACK")
echo "$PUBLISH_OUTPUT"

REPO_URL=$(echo "$PUBLISH_OUTPUT" | grep '^REPO_URL=' | cut -d= -f2-)
PAGES_URL=$(echo "$PUBLISH_OUTPUT" | grep '^PAGES_URL=' | cut -d= -f2-)
REPO_NAME=$(basename "$REPO_URL")

append_dashboard_row "$REPO_NAME" "$REPO_URL" "$TESTS_RESULT" "$SECRETS_RESULT" "$ATTRIBUTION_RESULT" "$PAGES_URL" "OK"

echo "run-track: done. Repo: $REPO_URL"
