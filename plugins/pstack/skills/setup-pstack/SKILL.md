---
name: setup-pstack
description: Configure which models pstack uses per role. Detects your available models and writes a config file that pstack's SessionStart hook loads into every session, overriding the skill defaults. Use for /setup-pstack, "configure pstack models", or changing pstack's model choices.
allowed-tools: Read(/${CLAUDE_PLUGIN_ROOT}/**)
---

# Setup pstack

Write `~/.claude/pstack-models.md` (under `$CLAUDE_CONFIG_DIR` instead of `~/.claude` when that is set). pstack's SessionStart hook prints it into context at the start of every session, after `/clear`, and after compaction, so it acts as an always-applied rule. The skills fall back to their inline defaults when a line is absent, so this is an override layer, not a requirement.

## Steps

### 1. Detect available models

Read the allowed values of the `Agent` tool's `model` parameter in this session; that is the dependable source, because it is exactly what a pstack skill can pass per call (typically `opus`, `sonnet`, `haiku`, and any newer alias the session lists). Never write a value you have not confirmed is in that set.

### 2. Load current state

The default role-to-model mapping is the file shape shown in step 5 below. If the config file already exists, read it and treat its values as the current choices. Otherwise start from those defaults.

### 3. Map and confirm

Show every role with its current model, marking any whose model is not in the detected set as needing a choice. Ask whether to accept as-is or change specific roles, offering the detected models as the options. Prefer `AskUserQuestion` over free text. For panel roles (how critics, arena runners, architect runners, interrogate reviewers) the value is a list, and one subagent runs per entry, so the list length sets the count. A model may repeat in a list; each entry is an independent sample.

Panels get their adversarial signal from diversity. With one model family, mixing tiers (`opus`, `sonnet`, `haiku`) gives more varied blind spots than repeating the top tier. Say so when the user collapses a panel to one model.

### 4. Validate

Every value written must be in the detected set. If a chosen value is not available, stop and ask again. A config pointing at a model the session cannot spawn breaks every delegation that reads it.

### 5. Write the config

Write the file with one line per role, using the same labels poteto-mode uses. Overwrite the whole file so re-runs stay idempotent. Shape:

```
# pstack model configuration. One line per role. Delete a line to fall back to the skill default.
feature, refactoring: sonnet
bug-fix, perf-issue: opus
judgment and prose: opus
how explorer: sonnet
how explainer: opus
how critics: opus, sonnet, haiku
why investigators: sonnet
why synthesizer: opus
reflect tooling: sonnet
reflect judgment, divergent, synthesizer: opus
arena runners: opus, sonnet, haiku
architect runners: opus, sonnet, haiku
interrogate reviewers: opus, sonnet, haiku
```

### 6. Confirm

Tell the user the file was written and that it loads in new sessions, or in this one after `/clear`. Re-running this skill updates it. Where hooks don't run (claude.ai chat), the skill defaults apply.
