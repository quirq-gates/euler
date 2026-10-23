# quirq-ai/xo — local setup and orientation

As of 2026-10-23, `main` at `0546efd` (62 commits, version 0.1.0).

## Local setup (done)

| What | Where / how |
|---|---|
| Clone | `/home/coder/xo/xo` (a subfolder, because the project folder holds XO's `.xo/` and `AGENTS.md`) |
| Env | `xo/.venv` (Python 3.14.4, system); `pip install -e ".[test]"`. The only dependency is pytest: the package uses the standard library only |
| Tests | `cd xo && .venv/bin/python -m pytest -q` → **1085 passed, 1 skipped, 1 failed** in ~75 s |
| CLI | `xo/.venv/bin/xo --help`, `xo ops`, `xo status`, `xo ... --dry-run` all work offline |
| Server | `CLERK_SECRET_KEY=sk_test_placeholder CLERK_API_URL=http://127.0.0.1:9 XO_CORE_API_URL=http://127.0.0.1:9/api/core/v1 xo serve --port 8787` |

The one failing test is caused by this machine, not by the code. `test_one_login_covers_every_service`
asserts `"coder" not in err` (a check that the retired `coder` service is gone). Our OS user is also
called `coder`, so the pytest temp path (`/tmp/pytest-of-coder/...`) shows up in the output. It
passes with `--basetemp=/tmp/xo-pytest`. To fix it, the test should look for `coder` as a service
name rather than as any substring.

The local server returned 200 on `/`, `/healthz`, `/config`, `/status` and `/login`. `xo me` against
it returned `502 Clerk did not answer`, which is expected because Clerk points at a dead port. Real
`/me`, creates and metadata writes need either a real Clerk dev `CLERK_SECRET_KEY` plus an XO API
key, or the fake Clerk/XO in `tests/conftest.py`.

## What xo is

`xo` is the command line for **XO Cloud** (`dev.xo.builders`), which hosts agent "spaces"
(Claude Code, Codex, Antigravity, Hermes, OpenClaw, XO Cowork, Nebius OpenClaw). It is one Python
package with two halves:

1. **The CLI** (`xo`, on the user's machine) holds the user's XO API key in
   `~/.config/xo/credentials` and sends it to exactly one address: the xo server.
2. **The xo server** (`xo serve`; on Vercel at `xo.quirq.dev` through `app.py` → `wsgi_app()`) holds
   `CLERK_SECRET_KEY`. It answers `/me`, and it stores the user's **projects / spaces / shared
   invites** in Clerk private metadata. Space creates and `GET /spaces/{id}` go on to XO's core API
   with the user's key.

There is no database. All state lives in Clerk private metadata (capped at 6 KB of the 8 KB
bucket), plus `./S/.xo/state.json` on disk for each installed space. GitHub access goes through the
user's own `gh` and `git`; xo never reads a GitHub token.

```
xo CLI ──XO key──▶ xo server ──▶ Clerk (verify key, read/write metadata)
   │                    └──key──▶ XO core API (creates, GET /spaces/{id})
   ├─▶ gh  (login)
   └─▶ git (clone / push / sync over https only)
```

## Code map (`src/xo/`, ~7.5k lines; tests ~7.5k)

| Module | Lines | Role |
|---|---|---|
| `server.py` | 2233 | App, routes, Clerk client, Core forwarder, `/me` masking, the metadata write engine (`_change`, `_change_keys`: per-user lock, write, read back after 0.3 s, up to 3 writes), sharing, rate limits, browser OAuth login |
| `cli.py` | 1646 | argparse entry point and every built-in command (login, status, create, connect, list, share, accept, …) |
| `spacerepo.py` | 993 | `xo create space [NAME]` with no KIND: turns a folder of git repos into one GitHub repo, one branch per repo plus an index branch; git plumbing only; secret and size scanning |
| `client.py` | 415 | **the only CLI network code**: Bearer key, no redirects, redaction in every escaping |
| `workspace.py` | 368 | `install` / `update` / `sync` for spaces (three-way merge of refs, rev/base conflict checks) |
| `selfupdate.py` | 365 | optional daily auto-update via pip (qq-setup pins; Windows helper) |
| `spec.py`, `commands.py` | 346, 192 | load the bundled OpenAPI spec (`openapi.json`) and generate one command per operation, with flags |
| `gitops.py` | 249 | the user's git: https only, no submodules, no tokens in the environment |
| `weblogin.py` | 172 | browser login with a callback on 127.0.0.1:8976–8978 |
| `status_page.py` | 160 | public status page at `/`, CSP pinned by hash |
| `github.py` | 149 | gh login, status and logout |
| `names.py` | 131 | name and ref rules shared by CLI and server |
| `services.py/.json` | — | service list (`me`, `xo`), also served at `/config` |

The docs are good and kept current: `README.md`, `docs/architecture.md` (a sequence diagram per
command), `docs/guide.md`, `docs/server.md`, `docs/deploy-vercel.md`, `docs/quickstart.md`.

## Main features

- **Auth:** `xo login` (browser Clerk OAuth, or a pasted key), `xo logout`, `xo status`, `xo me`.
- **XO spaces:** `xo create space NAME KIND [flags]` creates the space on XO and records it.
  `xo spaces --space-id ID` returns connection URLs, which carry session tokens.
- **Folder spaces:** `xo create space [NAME]` with no KIND publishes a folder of repos to
  `github.com/OWNER/NAME` and records it, with nothing created on XO.
- **Projects:** `xo create project NAME|URL`, `xo projects [add]`, `xo connect P --repo URL`.
- **Composition:** `xo connect P S [--ref]` puts a project at a ref into a space (at most 10 per
  space); `xo connect S [--id]` adds a space entry.
- **Sharing:** `xo share`, `xo list shared`, `xo accept`, `xo reject` (invites go into the other
  user's `shared`).
- **Workspace sync:** `xo install | update | sync space:S | project:P`.
- **Low-level:** `xo ops`, `xo call OP`, `xo api METHOD PATH`, `--dry-run` everywhere.

## Rules of the repo (from its AGENTS.md)

- Every change is a PR against `main`. The required check is `xo-presubmit`. **A merge to main
  deploys production** (`xo.quirq.dev`, Vercel).
- Standard library only; a new dependency needs a reason in the PR.
- Network code stays in `client.py` (CLI) and `Clerk`/`Core` in `server.py` (server).
- Keys are never printed or logged, and tests assert this. Tests never reach XO.
- `openapi.json` changes together with the xo-swarm commit it follows. The repo is public: no
  secrets or internal hostnames.
- Open decisions are marked `TODO(suraj):`.
- Python versions differ: Vercel uses 3.12 (`.python-version`), CI uses 3.14, the package needs
  ≥3.11.

## Likely work areas (open issues, 13)

**Correctness bugs in project/space flows (small, self-contained, good first PRs):**
- #51 `create project URL` records the project before cloning, so a missing repo leaves a stale
  entry. Fix: `git ls-remote` first.
- #52 `connect --ref` saves a ref that doesn't exist and overwrites the working one. Fix: check
  with `ls-remote` (`gitops.resolve` already does this for install).
- #53 `install space` stops at the first failing project and writes no `.xo/state.json`.
- #54 `update space`: the "push it first" hint runs against a different checkout.
- #50 `update/sync space` fails when the space holds a repo you can't push to.
- #63 leftovers from #62 (connect adds new projects).

**Missing lifecycle features (#55):** spaces deleted on XO stay in `xo list spaces` and keep their
names, and there is no remove command for projects or spaces. `connect --id` saves no `kind`.
argparse errors exit 2 with two lines instead of the documented 1 and one line.

**Folder-spaces hardening (#67):** symlink path leaks, nested repos being dropped, `--owner`/`--yes`
silently ignored when a KIND is given, hash verification.

**Windows (#60, #61, #76):** reserved names (CON, NUL, …), text read without an explicit encoding
or BOM handling, and two auto-update helper races.

**Server production gate (#6, #2):** the Firewall check in the test script, the deadline-timer
test, `redact()` gaps, log escaping, the admin-key issuing decision.

**Open `TODO(suraj)` decisions:** a key scoped to one space for creates (`cli.py:373`; today each
new space gets a copy of the user's full key), renaming a project inside its spaces
(`server.py:1320`), the Docker base image digest, the Vercel key-check plan, and how admin keys are
issued.
