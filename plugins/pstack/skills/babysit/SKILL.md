---
name: babysit
description: Drive an open PR to mergeable. Watch CI, fix real failures at the root, triage review comments (fix, dismiss, or ask), and resolve conflicts. Use for /babysit, "babysit this PR", or right after opening a PR.
allowed-tools: Read(/${CLAUDE_PLUGIN_ROOT}/**)
---

# Babysit

Own the PR until it is mergeable: checks green, no merge conflicts, every review thread answered. Do not merge unless the user asked.

If the Claude desktop app's Auto-fix is already watching this PR, let it own CI and comments. Don't run a second loop on top of it.

## Loop

1. Snapshot state. `gh pr view <number> --json number,headRefName,baseRefName,mergeable,reviewDecision,statusCheckRollup`.
2. Wait on CI with `gh pr checks <number> --watch --fail-fast` as a background Bash command (`run_in_background: true`). The harness wakes you when it exits. Don't poll with sleeps.
3. On a failing check, read the failing log (`gh run view <run-id> --log-failed`). Classify it.
   - Caused by this PR. Reproduce locally, fix the root cause (the **principle-fix-root-causes** skill), push.
   - Flaky or infra. Rerun once with `gh run rerun <run-id> --failed`. A second failure of the same shape is not a flake; treat it as real.
   - Pre-existing on the base branch. Confirm on the base, note it in the PR, don't fix it here.
4. Read review comments, including bots: `gh api repos/{owner}/{repo}/pulls/<number>/comments` and `gh pr view <number> --comments`. Triage each on its merits.
   - Fix. A real bug or a clear improvement in scope. Fix it and reply with the commit.
   - Dismiss. A non-issue, nitpick, or misread. Reply with the concrete reason. Don't churn code to placate a bot.
   - Ask. A product or preference call only the human can make. Surface it to the user.
5. On a merge conflict, rebase on the base branch, resolve, rerun the local checks, push with `--force-with-lease`. Never plain force-push a shared branch.
6. Repeat from step 2 until the exit condition holds or two consecutive rounds make no progress. Then stop and report.

## Guardrails

- Push back when feedback drifts from the PR's intent. Out-of-scope requests become follow-ups, not more diff.
- Every push re-runs the **deslop** skill over the new changes.
- Report what changed each round: checks fixed, comments fixed, comments dismissed with reasons, questions waiting on the user.
