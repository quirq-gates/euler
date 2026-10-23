#!/usr/bin/env bash
# Rebuild REPOS.md, then commit and push everything in /home/coder that
# changed. Does nothing when there are no changes. Run hourly.
set -euo pipefail

root=/home/coder
cd "$root"

"$root/update-index.sh"
git add -A
if git diff --cached --quiet; then
  echo "$(date -u +%FT%TZ) no changes"
  exit 0
fi
git commit -q -m "Hourly snapshot $(date -u '+%F %H:%M UTC')"
git push -q
echo "$(date -u +%FT%TZ) pushed $(git rev-parse --short HEAD)"
