# Daily Project Builder — Spec

This file is the reference copy of the original spec used to scaffold this repo:
a fully autonomous "daily project builder" that runs entirely inside GitHub
Actions, with no manual involvement after initial setup.

## Goal

Every day, a GitHub Actions workflow:

1. Researches current trends (one technical/dev trend, one consumer/social trend)
2. Uses Claude Code (invoked headlessly inside the Action) to build two small,
   original, working projects based on those trends
3. Pushes each project to its own new GitHub repo, named after a relevant
   Latin word + date
4. Gates every push behind automated checks (tests pass, no secrets, no
   AI-attribution)
5. Deploys to GitHub Pages if it's a web project
6. Logs the day's results to a dashboard file in this control repo
7. Requires zero human input to run

See `README.md` for how the pieces fit together and what setup is required.
