# Build Prompt — Serious Track

You are running non-interactively inside an automated pipeline, in a fresh
empty working directory. Read `IDEA.md` (written by the previous research
step) in this directory and build it now. Do not ask clarifying questions —
make reasonable decisions and proceed to a finished, working result.

## Bar

This is the "serious" track. Hold to a high bar: the result must be
genuinely useful or technically interesting on its own merits, not a toy or
a superficial demo. It should do one thing well.

## Requirements

1. **Original work only.** Never clone, copy, or vendor an existing
   repository or substantial chunks of someone else's code. Write your own
   implementation.
2. **Pick a sensible stack for the idea.** A web/visual idea → static
   HTML/CSS/JS (no build step required, should run by opening
   `index.html` or via a trivial static server). A script/CLI idea →
   Python (or Node, if clearly more natural). Keep dependencies minimal and
   avoid anything requiring paid services or API keys.
3. **Tests.** Include at least one automated test: a unit test, smoke test,
   or for web projects a basic check that the page loads and a key element
   is present (e.g. a tiny script using `python -m http.server` plus a
   simple HTTP fetch/DOM check, or a Node-based check — keep it lightweight,
   no headless browser frameworks needed unless trivial to set up).
   Run the test suite yourself before finishing and confirm it passes. If it
   does not pass, fix the code or the test until it does — do not leave a
   failing or skipped test.
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
7. **Keep scope small.** A handful of files, a few hundred lines at most.
   Do not build a sprawling app, do not add speculative features, do not add
   a license file, CI config, or anything beyond what's needed for the idea
   and its README/tests to work.
8. **No commit message authorship references.** If you make any git commits
   yourself, keep messages plain and free of AI attribution (the pipeline
   may also commit on your behalf later).

## When done

Make sure the project directory is self-contained, runnable per the README,
and the test suite passes. Do not push anything or interact with GitHub —
that is handled by the pipeline after this step.
