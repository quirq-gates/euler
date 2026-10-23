#!/usr/bin/env bash
# Rebuild REPOS.md: every git repo under /home/coder (outside dot-folders),
# with its GitHub location, branch, current commit and how to clone it.
set -euo pipefail

root=/home/coder
out="$root/REPOS.md"

# Skip node_modules and dot-folders at any depth (caches, XO worktrees).
repos=$(cd "$root" && find . -mindepth 2 \( -name node_modules -o -name '.?*' ! -name .git \) -prune \
  -o -name .git -print | sed 's|^\./||; s|/\.git$||' | sort)

web_url() {
  # git@github.com:org/repo.git and https://github.com/org/repo.git -> https://github.com/org/repo
  sed -E 's|^git@([^:]+):|https://\1/|; s|\.git$||' <<<"$1"
}

{
  echo "# Repos in /home/coder"
  echo
  echo "Every git repo under this folder, with its GitHub location and the commit"
  echo "it is checked out at. Each one is ignored by this top-level repo."
  echo "Rebuilt by \`update-index.sh\`."
  echo
  echo "| Path | GitHub | Branch | Commit |"
  echo "|------|--------|--------|--------|"
  for r in $repos; do
    url=$(web_url "$(git -C "$root/$r" remote get-url origin 2>/dev/null || echo none)")
    branch=$(git -C "$root/$r" branch --show-current)
    sha=$(git -C "$root/$r" rev-parse --short HEAD)
    echo "| \`$r\` | $url | \`${branch:-detached}\` | \`$sha\` |"
  done
  for r in $repos; do
    url=$(web_url "$(git -C "$root/$r" remote get-url origin 2>/dev/null || echo none)")
    branch=$(git -C "$root/$r" branch --show-current)
    sha=$(git -C "$root/$r" rev-parse HEAD)
    echo
    echo "## $r"
    echo
    echo "- GitHub: $url"
    echo "- Branch: \`${branch:-detached}\`"
    echo "- Commit: \`$sha\` ($(git -C "$root/$r" log -1 --format='%cs: %s'))"
    if [ -z "$(git -C "$root/$r" branch -r --contains HEAD 2>/dev/null)" ]; then
      echo "- **Warning:** this commit is not pushed to the remote yet; cloning will not get it."
    fi
    echo
    echo '```sh'
    echo "git clone ${branch:+-b $branch }$url.git $r"
    echo "git -C $r checkout $sha"
    echo '```'
  done
} >"$out"
