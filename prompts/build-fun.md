# Build Prompt — Fun Track

You are running non-interactively inside an automated pipeline, in a fresh
empty working directory. Read `IDEA.md` (written by the previous research
step) in this directory and build it now. Do not ask clarifying questions —
make reasonable decisions and proceed to a finished, working result.

## Bar

This is the "fun" track. Lower effort and smaller scope are fine — this
should be lighthearted and quick to build — but it must still run/function
correctly, end to end, with no errors. Favor something that makes someone
smile. Avoid anything that could be read as mocking a real person, group,
brand, or current event in bad taste; keep it good-natured.

## Requirements

1. **Original work only.** Never clone, copy, or vendor an existing
   repository or use any trademarked names, characters, or branding. Build
   your own small, original take inspired by the trend's theme or mechanic.
2. **Pick a sensible stack for the idea.** A web/visual/game idea → static
   HTML/CSS/JS (no build step, should run by opening `index.html`). A
   script idea → Python (or Node if more natural). Keep dependencies
   minimal and avoid anything requiring paid services or API keys.
3. **Tests.** Include at least one automated test: a unit test, smoke test,
   or for web projects a basic check that the page loads and a key element
   is present. Run it yourself before finishing and confirm it passes. Fix
   anything that fails — don't leave a failing or skipped test.
4. **README.md for the project** (not for this control repo) including:
   - What it is
   - How to run it (exact commands)
   - What "working correctly" looks like — the concrete success metric a
     person could check
5. **No secrets, no personal data.** Never write API keys, tokens,
   passwords, personal data, or credentials of any kind into any file.
6. **No AI attribution, anywhere.** Do not mention "Claude", "Anthropic",
   "AI-generated", "generated with AI", "GPT", "OpenAI", "co-authored by an
   AI", or any similar phrase in any code, comment, README, file name, or
   anywhere else in the project. Write the README and code as if a human
   wrote them, with no reference to how they were produced.
7. **Keep scope small.** A handful of files at most. Do not add a license
   file, CI config, or anything beyond what's needed for the idea and its
   README/tests to work.

## When done

Make sure the project directory is self-contained, runnable per the README,
and the test suite passes. Do not push anything or interact with GitHub —
that is handled by the pipeline after this step.
