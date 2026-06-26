# Research Prompt

You are running non-interactively inside an automated pipeline. Produce exactly
one output file: `IDEA.md` in the current working directory. Do not ask
clarifying questions — make reasonable decisions yourself and proceed.

## Track

You will be told which track to research via the environment variable
`TRACK`, which is either `serious` or `fun`. Research only that track.

### serious track

Identify one concrete, current developer/technical trend by considering
things like: GitHub Trending repositories, Hacker News front page topics,
recent developer tooling discussions, new language/framework features, or
broadly-discussed technical patterns. Pick ONE specific, narrow, buildable
idea — a small tool, CLI utility, library pattern, or data visualization —
that reflects this trend. It must be small enough to implement well within a
single short session (well under an hour of focused work, a few hundred
lines of code at most).

### fun track

Identify one trending lighthearted consumer/social topic (an app category,
a meme format, a cultural moment, a popular casual game mechanic, etc.).
Pick ONE small, buildable idea *inspired by* the theme or mechanic of that
trend — never a clone, never using any trademarked names, characters, or
branding. The idea should be original and avoid mocking any real person,
group, brand, or current event in poor taste.

## Output format

Write `IDEA.md` with exactly this structure:

```markdown
# Idea

**Name:** <short project name, plain English>
**One-line description:** <single sentence>
**Why it's interesting:** <1-3 sentences tying it to the trend you found>
**Track:** serious|fun
**Suggested stack:** <e.g. "Python CLI", "static HTML/JS page", "Node script">
**Latin word:** <a single Latin word or short phrase fitting the theme>
**Latin meaning:** <its English meaning>
```

For the Latin word: read `data/latin-glossary.json` in this repo for
inspiration first. Use an entry from it if a good fit exists; otherwise it is
fine to choose a different, accurate Latin word/phrase that better matches
the theme. Do not invent fake Latin — use a real word.

Keep the whole idea small in scope. This is a gate before building, so be
decisive and do not produce multiple options — pick one and commit to it.
