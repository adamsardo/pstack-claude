# pstack for Claude

A Claude Code and Claude (Cowork) plugin marketplace with one plugin, [pstack](plugins/pstack/), ported from [poteto's Cursor plugin](https://github.com/poteto/plugins/tree/main/pstack).

## Install

In Claude Code:

```bash
/plugin marketplace add adamsardo/pstack-claude
/plugin install pstack@pstack
```

In the Claude desktop app (Cowork), add `adamsardo/pstack-claude` as a plugin marketplace.

See [plugins/pstack/README.md](plugins/pstack/README.md) for the full usage and for what changed in the port.

## When and why to use each part

This section tells you when to use each part of pstack. It also tells you why each part is necessary. The text uses ASD-STE100 Simplified Technical English.

All commands start with a slash. If a different plugin uses the same name, add the `pstack:` prefix. For example, use `/pstack:how`.

### The main commands

| Command | When to use it | Why to use it |
|---|---|---|
| `/poteto-mode` | Use it at the start of each task that has more than one or two steps. | It finds the correct playbook for your task. A playbook is a fixed list of steps. The agent does all the steps in the list. If the agent does not do a step, it must write the reason. |
| `/figure-it-out` | Use it for a large task, for example a migration across many files. Also use it when no playbook is correct for your task. | It makes a new playbook for your task before it writes code. It keeps a record of each decision. You can read this record when you return. |

### The playbooks

`/poteto-mode` selects one of these playbooks for you. You do not start a playbook directly.

| Playbook | When the agent uses it | What the agent does |
|---|---|---|
| Investigation | You ask a question about the code. | It finds the answer and gives the sources. It does not change files. |
| Bug fix | You report a defect. | It makes the defect occur again. It finds the root cause. Then it repairs the defect and does a test on the same surface. |
| Perf issue | An operation is too slow. | It measures the operation before and after the change. |
| Runtime forensics | A program that runs has a problem, for example a memory leak. | It finds the cause. It does not repair the problem. |
| Trace forensics | You give the agent a profile or a trace file. | It finds the cause in the file. It does not repair the problem. |
| Feature | You want new behavior. | It names the data shape before it writes code. |
| Refactoring | You want to change the structure of the code, but not its behavior. | It makes small changes. After each change, the tests must pass. |
| Prototype | A decision needs a fast test. | It makes a temporary version. Then it uses the result to make the decision. |
| Visual parity | Two user interfaces must look exactly the same. | It compares screenshots until no pixels are different. |
| Authoring a skill | You write or change a `SKILL.md` file. | It follows the rules for skill files. |
| Eval | You want to know if a change to a skill or a prompt changes agent behavior. | It does a blind test of the old and new versions. |
| Autonomous run | You want the agent to continue without you, for example at night. | It writes a condition for "done". It continues until the condition is true. It stops if two loops make no progress. |
| Session pickup | An agent must continue the work of a prior session. | It reads the prior work. It does not do that work again. |
| Pause safely | You must stop the work and continue later. | It saves the work and writes a note. A new session can continue from that note. |
| Multi-phase plan | The work has many phases or many pull requests. | It divides the work into small parts. Each part has a test. |
| Opening a PR | Each other playbook uses it at the end. | It makes small commits and small pull requests. |

### Commands to understand code

| Command | When to use it | Why to use it |
|---|---|---|
| `/how` | Use it when you must know how a part of the code works. Use it before you change code that you do not know. | Agents read the code at the same time. One agent writes one clear explanation. If you ask for a critique, three models also review the design. |
| `/why` | Use it when you must know why the code has its current shape. | It searches the git history and the pull requests. It also searches each connected tool, for example tickets, documents, chat, monitors, and error logs. It gives a source for each claim. It tells you what it does not know. |

### Commands to design code

| Command | When to use it | Why to use it |
|---|---|---|
| `/architect` | Use it before you write code that other functions will call. | It writes the types and the function signatures first. Then it writes the code. A bad shape is difficult to change later. This step prevents a bad shape. |
| `/arena` | Use it when one attempt can give the wrong result. | Three agents do the same task at the same time. You get the best attempt. The best parts of the other attempts are added to it. |

### Commands to review

| Command | When to use it | Why to use it |
|---|---|---|
| `/interrogate` | Use it before you ship a change. Also use it when people do not agree about a design. | Three models review the diff. Each model finds different problems. The lead agent puts each problem in one group: act on, consider, noted, or dismissed. It does not change the code. |
| `/deslop` | Use it before each commit. | It removes code that is not necessary, for example extra comments and extra error checks. AI agents often add this type of code. |
| `/unslop` | The agent uses it for all text that it writes. You can also use it for your own text. | It removes words and patterns that show that an AI wrote the text. |

### Commands to build and test

| Command | When to use it | Why to use it |
|---|---|---|
| `/tdd` | Use it for a bug fix when a local test is fast and easy to write. | It writes a test that fails first. Then it writes the fix. The git history shows the problem first and the repair second. |
| `/typescript-best-practices` | The agent uses it automatically when it reads or edits a `.ts` or `.tsx` file. | It applies strict type rules. For example, it does not use `any` or `as` casts. |
| `/control-cli` | Use it when the agent must operate a command-line tool to find or verify a problem. | The agent must see the problem on the real surface. A unit test alone does not prove that a bug is gone. |
| `/control-ui` | Use it when the agent must operate a browser, web, or Electron interface. | The agent must see the problem on the real surface. Screenshots give evidence of the result. |

### Commands to ship

| Command | When to use it | Why to use it |
|---|---|---|
| `/babysit` | Use it after you open a pull request. | It monitors CI. It repairs real failures, replies to review comments, and resolves merge conflicts. It does not merge unless you tell it to merge. |
| `/show-me-your-work` | Use it for long work or for work that you will review later. | It writes each decision to a TSV file. Each row has the decision, the reason, the evidence, and the result. |

### Commands to improve pstack

| Command | When to use it | Why to use it |
|---|---|---|
| `/reflect` | Use it after a long task, when the agent learned something new. | Three agents read the session transcript. They find lessons and propose changes to the skills. Nothing changes until you approve it. |
| `/automate-me` | Use it when you want your own mode, for example `jane-mode`. | It reads your recent sessions and asks you some questions. Then it writes a skill that follows your preferences. |
| `/setup-pstack` | Use it when you want to change the models that pstack uses. | It writes the file `~/.claude/pstack-models.md`. Each new session loads this file. |

### The agents

You do not start these agents directly. The skills start them for you.

| Agent | When the skills use it | Why the skills use it |
|---|---|---|
| `pstack:poteto-agent` | For subagents that write code or do general work. | It reads all the poteto-mode rules before it starts. A general-purpose agent does not read these rules. |
| `pstack:readonly-agent` | For agents that read and review, for example in `/how`, `/interrogate`, and `/arena`. | It cannot edit files. Because of this, a reviewer cannot change the code that it reviews. |
| `general-purpose` (built in) | For the agents in `/why` and `/reflect`. | These agents must use MCP tools, for example a ticket tracker or chat. The read-only agent cannot use MCP tools. |

### The principles

pstack has 20 principle skills, for example `principle-prove-it-works`. Each principle is one rule. `/poteto-mode` reads the principles at the start of each task. You can also start one directly. Do this when you want the agent to apply that one rule.

## Validate

Do this check before you publish a change:

```bash
claude plugin validate .
```
