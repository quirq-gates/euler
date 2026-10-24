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
# euler is public: refuse to commit anything that looks like a secret.
secret_re='gh[opsu]_[A-Za-z0-9]{20,}|github[_]pat_|sk-[A-Za-z0-9_-]{20,}|sk_live[_]|sk_test_[A-Za-z0-9]{16,}|AKIA[0-9A-Z]{16}|BEGIN [A-Z ]*PRIVATE KEY|xox[abp]-[A-Za-z0-9-]{10,}|vercel_[A-Za-z0-9]{20,}|ak_[A-Za-z0-9]{16,}|eyJ[A-Za-z0-9_-]{20,}\.[A-Za-z0-9_-]{20,}'
if git diff --cached -U0 | grep '^+' | grep -qE "$secret_re"; then
  files=$(git diff --cached -U0 | awk '/^\+\+\+ b\//{f=substr($0,7)} /^\+/ && !/^\+\+\+/{print f "\t" $0}' | grep -E "$secret_re" | cut -f1 | sort -u | tr '\n' ' ')
  git reset -q
  echo "$(date -u +%FT%TZ) STOPPED: possible secret in: $files; nothing committed" >&2
  exit 1
fi
git commit -q -m "Hourly snapshot $(date -u '+%F %H:%M UTC')"
git push -q
echo "$(date -u +%FT%TZ) pushed $(git rev-parse --short HEAD)"
