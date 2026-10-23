# vercel-activity — design proposal

A small public page that shows the activity of the projects our workspace
deploys to Vercel (team quirq-research, deployed with the Vercel CLI as
quirq-jobs): which projects exist, their latest deployments, and whether
they're healthy. An `/account` page shows the account and its domains.

## Stack

- Next.js (App Router, TypeScript), deployed on Vercel.
- Data: Vercel REST API, called **only on the server** with a read token in the
  env var `VERCEL_TOKEN` (plus `VERCEL_TEAM_ID`). The token never reaches the
  browser; the page receives an already-filtered JSON shape.
- Caching: the server fetch is cached for 5 minutes (ISR / `revalidate = 300`),
  so public traffic never hammers the Vercel API or the rate limit.
- Code lives in `quirq-gates/vercel-activity`, deployed to the Vercel project
  `vercel-activity` in quirq-research.

## Page

1. Header: totals — projects shown, deploys in the last 7 days, success rate,
   currently building/failed.
2. Activity chart: deployments per day over the last 30 days (ready vs error).
3. Projects grid: one card per project — name, framework, last deploy state and
   time, production domain link, deploys in last 30 days.
4. Live feed: the latest ~50 deployments across projects — project, state,
   prod/preview, branch, short commit SHA, commit title, duration, time ago.

## Fields shown publicly (allowlist — everything else is dropped server-side)

| Shown | Field |
|---|---|
| ✓ | Project name, framework |
| ✓ | Deployment state (READY / ERROR / BUILDING / CANCELED), target (production / preview) |
| ✓ | Created time, build duration |
| ✓ | Git branch name, short commit SHA (7 chars) |
| ✓ | Commit message **first line only** |
| ✓ | Production domain (the public URL the project is already served on) |
| ✓ | Link to the GitHub repo **only if that repo is public** |

## Never shown

- Environment variables or any secret
- Preview / per-deployment `*.vercel.app` URLs and Vercel inspector/dashboard links
- Team ID, team slug, account IDs, user IDs
- Deployment creator username, commit author name/email
- Private repo names/orgs, full commit message bodies
- Build logs, runtime logs
