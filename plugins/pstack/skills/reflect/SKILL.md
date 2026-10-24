---
name: reflect
description: Spawn three parallel review subagents over the active transcript, surface learnings, and route each to a concrete edit on an existing skill. Use when the user says reflect.
disable-model-invocation: true
allowed-tools: Read(/${CLAUDE_PLUGIN_ROOT}/**)
---

# Reflect

Mine the current conversation for durable learnings, then route them into skill edits.

## When to invoke

- The user said "reflect" or "/reflect".
- A complex task (5+ tool calls) just landed cleanly and the recipe is worth keeping.
- The agent hit dead ends, found the working path, and the path generalizes.
- The user corrected the agent's approach mid-task.
- A non-trivial workflow emerged that isn't captured anywhere.

Skip when the conversation is trivial, off-topic, or already covered by an existing skill the parent followed correctly. One-offs are not learnings.

## Process

### 1. Locate the active transcript

The parent finds its own transcript file before fanning out. The active transcript is `~/.claude/projects/<project>/${CLAUDE_SESSION_ID}.jsonl`, where `<project>` is the working directory's absolute path with every non-alphanumeric character replaced by `-`. Use only that project directory. Do not glob across `~/.claude/projects/*/`. That crosses project boundaries and reads private chats from unrelated projects.

```bash
ls -t ~/.claude/projects/<project>/*.jsonl ~/.claude/projects/<project>/*/subagents/*.jsonl 2>/dev/null | head -10
```

Two transcript layouts: the session (`<session-id>.jsonl`) and its subagents (`<session-id>/subagents/agent-<id>.jsonl`).

Prefer the `${CLAUDE_SESSION_ID}` path. If it doesn't exist, search the candidates for the conversation's opening user prompt (`grep -l`) and take the match. If no path resolves (for example in Cowork or claude.ai, where transcripts aren't on disk), write a tight digest of the session and pass that instead.

### 2. Spawn three reviewers in parallel

One message, three `Agent` calls, `subagent_type: general-purpose`, explicit `model` on each. Not `pstack:readonly-agent`: reviewers need MCP access for context lookups (tickets, chat threads, observability traces referenced in the transcript), and its allowlist strips MCPs. The prompt forbids file writes; the parent applies edits.

| Lens | `model` | Prompt template |
|---|---|---|
| Judgment | your configured reflect-judgment model (default `opus`) | `references/judgment-reviewer.md` |
| Tooling | your configured reflect-tooling model (default `sonnet`) | `references/tooling-reviewer.md` |
| Divergent | your configured reflect-judgment model (default `opus`) | `references/divergent-reviewer.md` |

Pass each template verbatim, substituting the transcript path or digest where marked. Reviewers return findings in the `Agent` result.

### 3. Synthesize

One `Agent` call, `subagent_type: general-purpose`, using your configured reflect-judgment model (default `opus`). The synthesizer's quality check includes spot-verifying citations, which can require MCP access; `pstack:readonly-agent` strips MCPs. Use `references/synthesizer.md` verbatim, with each reviewer's full output inlined where marked. The synthesizer returns a structured Accepted / Rejected / Backlog list.

### 4. Structural enforcement check

Sanity-check the synthesizer's Accepted list. For any item that would be enforced more reliably by a lint rule, script, metadata flag, or runtime check, move it from Accepted to Backlog. The synthesizer already applies this criterion; this is a final pass before edits land. See the **encode-lessons-in-structure** principle skill.

### 5. Apply

Before applying any Accepted edit, present the synthesizer's full Accepted/Rejected/Backlog output to the user and wait for explicit approval. The user picks which subset to apply and may redirect routings. Skill changes affect every future agent in the org; do not auto-apply.

Backlog items file to whatever devex / backlog tracker your team uses automatically. Those are tracker submissions, not skill edits. Only the Accepted list waits for approval.

For each approved Accepted item, follow the Routing field exactly:

- Trivial existing-skill edit (a one-line bullet, a tightened sentence, a stale fact corrected): parent does directly.
- Substantive existing-skill edit (a new section, a new pattern table, more than ~10 lines): hand to the **skill-creator** skill and run its draft / test / iterate loop. Without it installed, follow the poteto-mode `playbooks/authoring-a-skill.md` playbook.
- `tune description: <skill path>` (the skill exists but didn't trigger when it should have): hand to `skill-creator` and run its description-optimization loop.
- `new skill via skill-creator: <kebab-name>`: hand creation to `skill-creator`. Do not invent the shape ad hoc.

Run `claude plugin validate <dir>` on every touched plugin or skills directory before declaring done. Skip this step outside Claude Code.

### 6. Summarize for the user

Short list, no preamble:

- Edits applied: `<skill path>`. What changed, one line each.
- New skills created: `<skill path>`. One line each (rare).
- Backlog filed to the devex tracker: `<issue title>` (`<tags>`). One line each.
- Dropped: one line per rejected finding + reason from the synthesizer.
