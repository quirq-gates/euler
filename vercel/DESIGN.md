# vercel-activity: design

A public portfolio of what this space ships on Vercel (team quirq-research,
deployed with the Vercel CLI as quirq-jobs). Live at
https://vercel-activity-delta.vercel.app, code in
https://github.com/quirq-gates/vercel-activity.

- **Static.** No token and no API call at runtime. `npm run snapshot` uses the
  local Vercel CLI login to write `src/data/snapshot.json` and screenshots;
  `src/data/showcase.json` picks the projects and blurbs.
- **Pages.** `/` has a gallery (screenshot, live link, source link, last
  shipped), a recently shipped feed and the domains. `/p/<name>` has a
  screenshot with a "Try it here" live embed and the deploy history.
- **Public fields.** Project name, blurb, framework, public URL, GitHub link
  (public repos only), deploy state, prod/preview, time, build time, branch,
  short SHA, commit title (public repos only), and domains.
- **Never shown.** Env vars, preview or team-slug URLs, IDs, usernames, emails,
  commit bodies.
- **Refresh.** Run the snapshot, commit, then `vercel deploy --prod --scope quirq-research`.
