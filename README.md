# repo-control

This is a **control repo** for an automated system that, every day, dreams up
and builds two small original projects and publishes each one to its own new
GitHub repo — no manual work required once it's set up.

It does not contain a "real" app of its own. It contains the automation
(GitHub Actions workflow, prompts, and gate-keeping scripts) that drives
Claude Code to do the research and building, and a running log of what it
produced.

## What happens every day

A scheduled GitHub Actions workflow (`.github/workflows/daily-build.yml`)
runs two parallel jobs, `build-serious` and `build-fun`. Each job:

1. **Researches a trend.** Claude Code is run headlessly with
   `prompts/research.md`, which asks it to identify one current trend
   (technical, for the serious track; consumer/social, for the fun track)
   and write up a small, concrete project idea, including a fitting Latin
   word for naming (see `data/latin-glossary.json`).
2. **Builds the project.** Claude Code is run again, headlessly, with
   `prompts/build-serious.md` or `prompts/build-fun.md`, in a fresh empty
   temp directory. It builds a small original project with at least one
   passing test and its own README.
3. **Gates the result.** Three scripts run against the generated project
   directory before anything is published:
   - `scripts/verify-success.sh` — README exists, a test file exists, the
     test suite actually passes, and a recognizable entry point exists.
   - `scripts/secret-scan.sh` — runs `gitleaks` to make sure no secrets
     snuck into the generated files.
   - `scripts/attribution-scan.sh` — makes sure nothing mentions
     "Claude", "Anthropic", "AI-generated", "GPT", etc.

   If any check fails, nothing is pushed anywhere. A failure row is logged
   to `log/dashboard.md` in this repo and the job stops there.
4. **Publishes.** If every check passes, `scripts/create-and-push-repo.sh`
   creates a brand-new public GitHub repo named `<latin-word>-<date>`
   (e.g. `lucerna-2026-06-26`), pushes the project to it, and — if it looks
   like a static web project (has an `index.html`) — enables GitHub Pages
   on it.
5. **Logs the result.** A row is appended to `log/dashboard.md` in this
   repo with the date, track, repo name/URL, pass/fail per check, and the
   Pages URL if any. That commit is pushed back to this control repo.

The orchestration logic that ties research → build → gates → publish →
log together for a single track lives in `scripts/run-track.sh`; the
workflow YAML just installs tools, authenticates, and calls it once per
track.

## Where to check on it

Open `log/dashboard.md` in this repo. Every day you should see one or two
new rows (one per track, fewer if a track failed its gates that day).
Failed runs show up as rows with `repo name = n/a` and notes explaining
which check failed — check the linked GitHub Actions run for that day for
full logs.

## Required secrets

This repo needs two repository secrets (Settings → Secrets and variables →
Actions → New repository secret):

- **`GH_PAT`** — a GitHub Personal Access Token used by `gh` to create new
  repositories on your behalf and enable Pages on them, and to push the
  dashboard commits back to this repo.
- **`ANTHROPIC_API_KEY`** — an Anthropic API key used to run Claude Code
  headlessly for the research and build steps.

See the setup walkthrough (shared separately / in the PR description for
this scaffold) for exact scopes and step-by-step instructions.

## Cost and safety guardrails

- Every Claude Code invocation is bounded by `--max-turns` (see
  `CLAUDE_MAX_TURNS` in the workflow) to keep spend predictable.
- Generated projects are explicitly scoped to be small (a handful of
  files).
- Any gate failure fails that track's job safely — it logs and stops,
  it does not retry indefinitely or push anything broken, and it does not
  prevent the next day's run.
