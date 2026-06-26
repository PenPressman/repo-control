#!/usr/bin/env bash
# Creates a new public GitHub repo named "<latin-word>-<YYYY-MM-DD>" (with a
# numeric suffix on collision), pushes the given project directory to it, and
# enables GitHub Pages if it looks like a static web project.
#
# Usage: create-and-push-repo.sh <project-dir> <latin-word> <track>
#
# Requires: gh CLI authenticated (GH_PAT), git.
# Prints two lines to stdout on success:
#   REPO_URL=<url>
#   PAGES_URL=<url-or-empty>
set -euo pipefail

PROJECT_DIR="${1:-}"
LATIN_WORD="${2:-}"
TRACK="${3:-}"

if [[ -z "$PROJECT_DIR" || ! -d "$PROJECT_DIR" ]]; then
  echo "create-and-push-repo: missing or invalid project directory: '$PROJECT_DIR'" >&2
  exit 1
fi
if [[ -z "$LATIN_WORD" ]]; then
  echo "create-and-push-repo: missing latin word argument" >&2
  exit 1
fi

# Normalize the latin word into a safe repo-name slug.
SLUG=$(echo "$LATIN_WORD" | tr '[:upper:]' '[:lower:]' | tr -cs 'a-z0-9' '-' | sed 's/^-*//;s/-*$//')
DATE_STR=$(date -u +%Y-%m-%d)
BASE_NAME="${SLUG}-${DATE_STR}"

GH_USER=$(gh api user --jq .login)

REPO_NAME="$BASE_NAME"
SUFFIX=1
while gh repo view "${GH_USER}/${REPO_NAME}" >/dev/null 2>&1; do
  SUFFIX=$((SUFFIX + 1))
  REPO_NAME="${BASE_NAME}-${SUFFIX}"
done

echo "create-and-push-repo: creating repo '${REPO_NAME}' (track: ${TRACK})" >&2

cd "$PROJECT_DIR"

git init -q
git add -A
git -c user.name="daily-project-builder" -c user.email="actions@users.noreply.github.com" \
  commit -q -m "Initial commit: ${REPO_NAME}"
git branch -M main

gh repo create "${GH_USER}/${REPO_NAME}" --public --source=. --remote=origin --push

REPO_URL="https://github.com/${GH_USER}/${REPO_NAME}"
PAGES_URL=""

if find . -iname "index.html" -not -path "./node_modules/*" -not -path "./.git/*" | grep -q .; then
  echo "create-and-push-repo: static project detected, enabling GitHub Pages" >&2
  if gh api -X POST "repos/${GH_USER}/${REPO_NAME}/pages" \
       -f "source[branch]=main" -f "source[path]=/" >/dev/null 2>&1; then
    PAGES_URL="https://${GH_USER}.github.io/${REPO_NAME}/"
  else
    echo "create-and-push-repo: warning — failed to enable Pages via API" >&2
  fi
fi

echo "REPO_URL=${REPO_URL}"
echo "PAGES_URL=${PAGES_URL}"
