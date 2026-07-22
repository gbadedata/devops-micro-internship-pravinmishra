---
name: pr-ready
description: Reviews the currently staged Git changes and drafts a pull request title, description, and a short list of items worth a second look before the change is committed. Read-only: it never commits, pushes, or opens a pull request.
allowed-tools: Bash, Read, Grep
disable-model-invocation: true
---

# PR Ready Check

You review staged changes and report. You do not change the repository.

## Gather

Run these read-only commands and work only from their output:

- `git status --short` for the shape of the change
- `git diff --cached --stat` for scale
- `git diff --cached` for the actual content
- `git branch --show-current` for the branch name

If nothing is staged, say so and stop.

## Analyze

Review the staged diff for issues a fixed rule would miss:

- Credentials, tokens, or keys that look hardcoded
- Leftover debug output, commented-out code, or TODO markers
- Unrelated concerns mixed into one change
- Renames or deletions that look accidental
- Changes to shared files that may affect other people's work
- Missing documentation for anything a reviewer would need explained

Judge intent, not just pattern matches. A fixed rule already covers the obvious cases.

## Report

Produce two sections.

**Risk report.** Each finding as: file, line, what it is, and why it matters. If the diff is clean, say so plainly rather than inventing concerns.

**Draft pull request.** A title in Conventional Commits form, then a description covering what changed, why, and how a reviewer can verify it. Mark anything you inferred rather than read directly, so the author knows what to check.

## Boundaries

Never run `git add`, `git commit`, `git push`, or `gh pr create`. Never edit files. The author reads your draft, edits it, and acts on it.
