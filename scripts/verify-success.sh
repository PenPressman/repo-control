#!/usr/bin/env bash
# Verifies a generated project meets the baseline "working" success metric.
# Usage: verify-success.sh <project-dir>
set -uo pipefail

PROJECT_DIR="${1:-}"

if [[ -z "$PROJECT_DIR" || ! -d "$PROJECT_DIR" ]]; then
  echo "verify-success: missing or invalid project directory: '$PROJECT_DIR'" >&2
  exit 1
fi

fail() {
  echo "verify-success: FAIL — $1" >&2
  exit 1
}

# 1. README exists and is non-empty
README=""
for candidate in "$PROJECT_DIR/README.md" "$PROJECT_DIR/readme.md" "$PROJECT_DIR/Readme.md"; do
  if [[ -f "$candidate" ]]; then
    README="$candidate"
    break
  fi
done
[[ -n "$README" ]] || fail "no README.md found in project directory"
[[ -s "$README" ]] || fail "README.md is empty"

# 2. At least one test file exists
TEST_FILES=$(find "$PROJECT_DIR" -type f \
  \( -iname "*test*" -o -iname "*spec*" \) \
  -not -path "*/node_modules/*" -not -path "*/.git/*" 2>/dev/null)
[[ -n "$TEST_FILES" ]] || fail "no test file found (expected a file matching *test* or *spec*)"

# 3. Run the test suite and confirm it exits 0.
# Try common runners in order; the build prompt is responsible for making one
# of these work and for confirming locally before finishing, so this should
# rarely fail here — it's a final independent confirmation.
cd "$PROJECT_DIR"

run_tests() {
  if [[ -f "package.json" ]]; then
    if command -v npm >/dev/null 2>&1 && grep -q '"test"' package.json; then
      npm test --silent && return 0
    fi
  fi
  if command -v pytest >/dev/null 2>&1 && find . -iname "*test*.py" -not -path "*/.git/*" | grep -q .; then
    pytest -q && return 0
  fi
  if command -v python3 >/dev/null 2>&1; then
    py_test_files=$(find . -iname "test_*.py" -o -iname "*_test.py" | grep -v "/.git/")
    if [[ -n "$py_test_files" ]]; then
      local all_ok=0
      for f in $py_test_files; do
        python3 "$f" || all_ok=1
      done
      return $all_ok
    fi
  fi
  if command -v node >/dev/null 2>&1; then
    js_test_files=$(find . -iname "*test*.js" -o -iname "*spec*.js" | grep -v "/.git/" | grep -v "/node_modules/")
    if [[ -n "$js_test_files" ]]; then
      local all_ok=0
      for f in $js_test_files; do
        node "$f" || all_ok=1
      done
      return $all_ok
    fi
  fi
  echo "verify-success: no recognized test runner/test files could be executed" >&2
  return 1
}

run_tests || fail "test suite did not pass"

# 4. Entry point check depending on project shape
if find . -iname "index.html" -not -path "./node_modules/*" | grep -q .; then
  : # static web project — index.html present, good.
elif find . -iname "*.py" -not -name "*test*" -not -path "*/.git/*" | grep -q .; then
  MAIN_PY=$(find . -iname "main.py" -o -iname "app.py" -o -iname "cli.py" | grep -v test | head -n1)
  if [[ -n "$MAIN_PY" ]]; then
    python3 "$MAIN_PY" --help >/dev/null 2>&1 || python3 "$MAIN_PY" >/dev/null 2>&1
    # Non-zero exit here is tolerated for scripts requiring args; presence +
    # successful test run above is the primary signal for CLI projects.
  fi
elif find . -iname "*.js" -not -path "*/node_modules/*" -not -path "*/.git/*" -not -iname "*test*" | grep -q .; then
  : # node script present
else
  fail "no recognizable entry point found (expected index.html, a Python script, or a JS script)"
fi

echo "verify-success: PASS — README, tests, and entry point all present and tests pass"
exit 0
