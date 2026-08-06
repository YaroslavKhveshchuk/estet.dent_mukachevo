#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
GH="${GH:-$HOME/.local/bin/gh}"
REPO_NAME="${REPO_NAME:-estet-dent-muk}"

cd "$ROOT"

if ! "$GH" auth status >/dev/null 2>&1; then
  echo "Спочатку увійдіть у GitHub:"
  echo "  $GH auth login --hostname github.com --git-protocol https --web"
  exit 1
fi

if ! "$GH" repo view "$REPO_NAME" >/dev/null 2>&1; then
  "$GH" repo create "$REPO_NAME" --public --source=. --remote=origin --description "Estet Dent — landing page, Mukachevo"
else
  git remote get-url origin >/dev/null 2>&1 || "$GH" repo set-default "$REPO_NAME"
fi

git push -u origin main

"$GH" api repos/{owner}/"$REPO_NAME"/pages -X POST -f build_type=workflow >/dev/null 2>&1 || true

echo
echo "Репозиторій опубліковано. GitHub Pages збере сайт через 1–2 хвилини."
"$GH" repo view "$REPO_NAME" --web 2>/dev/null || true
echo "Сайт: https://$("$GH" api user --jq .login).github.io/$REPO_NAME/"
