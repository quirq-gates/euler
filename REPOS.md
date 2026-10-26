# Repos in /home/coder

Every git repo under this folder, with its GitHub location and the commit
it is checked out at. Each one is ignored by this top-level repo.
Rebuilt by `update-index.sh`.

| Path | GitHub | Branch | Commit |
|------|--------|--------|--------|
| `github/github-activity` | https://github.com/quirq-gates/github-activity | `main` | `94bef5f` |
| `qq-tools/depot` | https://github.com/quirq-ai/qq | `main` | `af16f39` |
| `quirqy` | https://github.com/quirq-ai/quirqy | `quirq` | `262ff7d` |
| `space-hub` | https://github.com/quirq-ai/space-hub | `main` | `be3706b` |
| `vercel/vercel-activity` | https://github.com/quirq-gates/vercel-activity | `main` | `faada8f` |
| `xo-coworker` | https://github.com/sharmasuraj0123/xo-coworker | `main` | `69021ff` |
| `xo/xo` | https://github.com/quirq-ai/xo | `main` | `0546efd` |

## github/github-activity

github-activity is a static public portfolio of this space's GitHub work: a card per project with what it is, its live links, latest commits and merged pull requests, plus commits per week and a recent-activity feed. portfolio.json picks the public repos shown. No token or GitHub calls at runtime: `npm run snapshot` uses the local gh login to write src/data/snapshot.json, and the site reads only that. Built with Next.js, deployed on Vercel; sibling of the Vercel portfolio.

- GitHub: https://github.com/quirq-gates/github-activity
- Branch: `main`
- Commit: `94bef5f40f9f312d62aab34a336d6364f27e38ce` (2026-10-26: Hourly snapshot 2026-10-26 12:00 UTC)

```sh
git clone -b main https://github.com/quirq-gates/github-activity.git github/github-activity
git -C github/github-activity checkout 94bef5f40f9f312d62aab34a336d6364f27e38ce
```

## qq-tools/depot

qq is the quirq infra command line, modeled on Chromium's depot_tools. It wraps git and gh, and every quirq repo pins the qq version it runs in its manifest (infra/repo.toml), so qq installs and runs exactly that version and updates itself when the pin moves. It fetches repos, syncs manifests, sets up toolchains, and runs builds and tests through recipes; other repos can add subcommands. Long-running commands return a run ID at once and report the verdict later, so agents never block on a build.

- GitHub: https://github.com/quirq-ai/qq
- Branch: `main`
- Commit: `af16f390a8b88ed7f4aa2dd50f1b683d2bc8c749` (2026-10-22: Auto-update qq to qq-setup's reviewed commit, when setup turned it on (#35))

```sh
git clone -b main https://github.com/quirq-ai/qq.git qq-tools/depot
git -C qq-tools/depot checkout af16f390a8b88ed7f4aa2dd50f1b683d2bc8c749
```

## quirqy

Quirqy is a browser app for exploring a GitHub repository, its history and the people around it in interactive 3D. Data Lab shows files and commit history; Activity Lab shows pull requests, issues, reviews, comments, forks and contributors, each with a timeline you can play and scrub. It loads any public repo by URL with no backend, token or account. Built with Vite on Observatory's shared 3D engine; work happens on the quirq branch.

- GitHub: https://github.com/quirq-ai/quirqy
- Branch: `quirq`
- Commit: `262ff7d284b91f6a76dc22114ce5e3ec4f92ca71` (2026-10-20: Render Data Lab and Activity Lab on demand (#1))

```sh
git clone -b quirq https://github.com/quirq-ai/quirqy.git quirqy
git -C quirqy checkout 262ff7d284b91f6a76dc22114ce5e3ec4f92ca71
```

## space-hub

spacehub is git hosting for agents, stored in SpacetimeDB. Agents own spaces (agent/space, like GitHub's owner/repo) and push to them; builders record who wrote the code. The server is a Docker image running a SpacetimeDB module with a web UI; the client is the gh-style spacehub CLI plus git-remote-quirq, so plain git can push and pull quirq:// URLs. Its main job is keeping the git trees of different machines, sandboxes and agents in sync, live.

- GitHub: https://github.com/quirq-ai/space-hub
- Branch: `main`
- Commit: `be3706baa17da56b3ecd9e702d4082e890cb9029` (2026-10-23: quirq remote and the xo store (#1))

```sh
git clone -b main https://github.com/quirq-ai/space-hub.git space-hub
git -C space-hub checkout be3706baa17da56b3ecd9e702d4082e890cb9029
```

## vercel/vercel-activity

vercel-activity is a static public portfolio of what this space ships on Vercel (team quirq-research): a gallery of live projects with screenshots, a page per project with a "Try it here" live embed and deploy history, a recently-shipped feed and the team's domains. No token or API calls at runtime: `npm run snapshot` uses the local Vercel CLI login to write src/data/snapshot.json and screenshots, and showcase.json picks the projects. Built with Next.js and deployed with the Vercel CLI.

- GitHub: https://github.com/quirq-gates/vercel-activity
- Branch: `main`
- Commit: `faada8fcdd56842be1e030220822338502ce5c11` (2026-10-26: Hourly snapshot 2026-10-26 06:00 UTC)

```sh
git clone -b main https://github.com/quirq-gates/vercel-activity.git vercel/vercel-activity
git -C vercel/vercel-activity checkout faada8fcdd56842be1e030220822338502ce5c11
```

## xo-coworker

xo-coworker (codename xo-swim) is XO Space's web UI for the projects-chat backend, built to protect the person's attention. Home ranks what is worth your time across projects; a Needs-you panel shows one decision at a time; projects, threads and the workspace coordinator each have their own view, with file uploads and live updates over SSE. Plain HTML, CSS and ES modules with no build step; serve.py serves it and safely proxies /api/* to the XO Space API. Sending a message starts real agents.

- GitHub: https://github.com/sharmasuraj0123/xo-coworker
- Branch: `main`
- Commit: `69021ff616ba29512d62c38c2dac0aaf10716142` (2026-10-22: Merge pull request #33 from sharmasuraj0123/rework)

```sh
git clone -b main https://github.com/sharmasuraj0123/xo-coworker.git xo-coworker
git -C xo-coworker checkout 69021ff616ba29512d62c38c2dac0aaf10716142
```

## xo/xo

xo is the command line for the XO Cloud API: every endpoint is a command, and it sends your XO API key without ever printing it. It creates spaces (Codex, Claude Code or OpenClaw agents) with their settings, turns a folder of git repos into one GitHub repo, creates projects from an empty or existing repo, and lists connection details for spaces you own. Python standard library only, installed with pip as quirq-xo.

- GitHub: https://github.com/quirq-ai/xo
- Branch: `main`
- Commit: `0546efd2f6f0839496ba5c64e9785fdd6c55d7c8` (2026-10-22: Quickstart: install xo at 520c0a0 (#77))

```sh
git clone -b main https://github.com/quirq-ai/xo.git xo/xo
git -C xo/xo checkout 0546efd2f6f0839496ba5c64e9785fdd6c55d7c8
```
