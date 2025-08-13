#!/bin/bash
set -euo pipefail

BRANCH="$1"
REPO_URL="$2"
REPO_DIR="$3"

if [ -z "$BRANCH" ] || [ -z "$REPO_URL" ] || [ -z "$REPO_DIR" ]; then
  echo "Usage: $0 <branch> <repo_url> <repo_dir>"
  exit 1
fi

if [ ! -d "$REPO_DIR/.git" ]; then
  echo "Cloning from $REPO_URL..."
  git clone "$REPO_URL" "$REPO_DIR"
fi

cd "$REPO_DIR" || exit 1
git checkout "$BRANCH"
git pull origin "$BRANCH"
