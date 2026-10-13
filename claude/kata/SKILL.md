---
name: kata
description: >-
  Manage software development work with kata, an agent-first ticket tracker. Use
  this whenever you start, plan, implement, or finish non-trivial software work
  in a kata-tracked workspace. SETUP: `/kata init` binds the workspace to a kata
  project (and loads this workflow). PLAN: decompose any feature request, bug report,
  or non-trivial task into kata tickets — top-level tickets are Mike Cohn user
  stories with Gherkin acceptance criteria; search existing tickets first.
  WORK: `/kata work ID [ID ...]` works explicit tickets in order.
  IMPLEMENT: `/kata goal` works the ready backlog, using a fresh worker per
  ticket by default; `--inline` keeps work in the current session. FINISH:
  commit (Conventional Commits)
  or merge, footer the kata ticket IDs, capture context as ticket comments, and
  file follow-up tickets for newly discovered work. Reach for this on essentially
  any non-trivial coding task.
---

# kata workflow

kata is a lightweight, agent-first issue tracker that acts as the shared issue
ledger for a workspace. This skill is the standard operating procedure for using
it across the full lifecycle of software work: **plan → implement → finish**.

Run `kata quickstart` any time you need a refresher on kata's own conventions;
the rules there (close asserts completion, search before create, eager closes,
typed evidence) always take precedence over anything summarized here.

Repository instructions and explicit user requests override this skill's generic
workflow, including its branch, commit, PR, merge, and verification defaults.

## Prerequisites (check once per workspace)

- **kata must be installed and initialized.** Run a cheap probe such as
  `kata list --limit 1`. If it reports something like
  `no .kata.toml ancestor and no git ancestor`, the workspace is not bound — run
  **Phase 0 setup** (below) or tell the user to. Never invent a project name and
  bind silently.
- **Run from the workspace.** kata resolves the project from the cwd; use
  `--workspace <path>` only to override. Add `--project <name>` for
  cross-project operations.
- **Use `--json` whenever you parse output.** Human output is for display only.
- The author is `$KATA_AUTHOR > $USER > git user.name`; check with `kata whoami`.
- Issue refs are short ids derived from a ULID (e.g. `abc4`); cross-project form
  is `kata#abc4`. Legacy numeric refs do not work.

---

## Phase 0 — Setup (`/kata init`)

When the user invokes **`/kata init`**, get this workspace ready to track work
with kata. Invoking it also pulls this whole skill into context, so it doubles
as "load the kata workflow for this session."

1. **Ensure a git repo exists.** The workflow bottoms out in git — `kata init`
   writes a *committed* `.kata.toml` and edits `.gitignore`, kata auto-names the
   project from a git remote, and Phase 3 finishes work with commits/branch
   merges. Check with `git rev-parse --is-inside-work-tree`:
   - **Already inside a repo** (including a parent directory) → leave it as is.
     If it has a remote, kata can auto-name the project from it.
   - **Not a repo** → confirm with the user, then `git init` at the workspace
     root. Never create a repo silently, and never nest a new repo inside an
     existing one. A fresh repo has no remote, so kata can't auto-derive a name —
     you'll pass `--project` in step 3.
2. **Check whether kata is already bound.** If a `.kata.toml` exists in the
   workspace (or `kata list --limit 1` succeeds), it's already initialized —
   report the current project (`kata projects list` / `kata whoami`) and stop.
   Do **not** re-bind unless the user explicitly asks to rebind, in which case
   use `kata init --replace` (or `--reassign` to move an existing alias).
3. **Initialize kata.** Run `kata init`. This writes a committed `.kata.toml` and
   adds `.kata.local.toml` to `.gitignore`.
   - kata derives the project name from a **git remote** when one exists.
   - If there's **no git remote** (or the user wants a specific name), pass it
     explicitly: `kata init --project <name>`. Confirm the name with the user
     rather than guessing when it can't be derived.
4. **Confirm.** Show the resulting binding and note that the kata workflow is now
   active — from here, planning/implementing/finishing follow Phases 1–3.

```bash
git rev-parse --is-inside-work-tree 2>/dev/null || git init   # only if no repo
kata init                       # auto-name from git remote
kata init --project my-service  # explicit name (no remote, or override)
```

---

## Phase 1 — Planning & ticket creation

Trigger this for **every feature request, bug report, or other non-trivial
task.** Trivial one-liners don't need a ticket; anything you'd want a future
session to understand does.

**Clarify before you write tickets.** When a feature's requirements are
ambiguous or underspecified, ask clarifying questions rather than guessing at
anything that affects ticket scope or acceptance criteria. Two rules:

- **One question at a time.** Don't batch a list of questions — ask the single
  most decision-relevant one, incorporate the answer, then ask the next only if
  still needed.
- **Always include a recommendation.** Pair each question with your suggested
  answer (and a one-line why), so the user can simply confirm or redirect.

### 1. Decompose into work items

Think about what work items must be completed to satisfy the request. Size each
one so it maps to roughly:

- **one git commit** for a small item, or
- **one feature branch** for a larger feature.

If a work item is usefully broken down further, track the smaller pieces as
**child tickets** (`--parent <ref>`) rather than inflating the parent.

### Verification design

**Ticket boundaries are not test-suite boundaries.** Do not create a test file,
end-to-end scenario, or full-suite gate merely because a ticket needs closure
evidence. Acceptance criteria describe behavior; Gherkin does not prescribe a
test layer or require every precondition to be established through UI gestures.

Before finalizing a non-trivial ticket's verification plan:

- Map its claims to existing coverage; identify the distinct gap before adding
  tests. Extend or consolidate existing scenarios when they cover the same
  behavior. Existing relevant tests can provide closure evidence without a new
  test dedicated to the ticket.
- Choose the lowest layer that proves each claim. Keep real integration checks
  where the claim depends on control wiring, rendering, lifecycle, persistence,
  or external effects. A model assertion alone does not prove a user flow or
  actual output works. Follow repository-specific evidence requirements.
- Distinguish prerequisites from interactions under test. Prepare unrelated
  state directly with deterministic, isolated fixtures; drive the real controls
  or external boundary when that interaction is the subject of the test. For
  persistence claims, verify durable state without reseeding it on relaunch.
- Specify affected checks, broader regression triggers, and expected cost when
  material. Use repository-defined smoke, feature, and full-regression gates.
  If none exist, select checks from the change's risks; do not make every ticket
  run the full suite by default. Honor explicit required gates; propose changes
  to an expensive policy rather than silently bypassing it.

Keep this proportional: a short verification note usually suffices. Do not add
planning ceremonies, fixed runtime budgets, or another approval step. More test
execution is not automatically stronger evidence.

### 2. Search before creating

Always search existing tickets first — both to avoid duplicates and to recover
context that previous implementation cycles left behind:

```bash
kata search "login race" --json
kata search --project foo "auth refactor" --json
```

Read promising hits with `kata show <ref> --json`. Prefer updating an existing
ticket (comment, label, edit relationships) over creating a near-duplicate.

### 3. Create one ticket per work item

```bash
kata create "<title>" \
  --body-file <file>  `# or --body "..."` \
  --idempotency-key "<stable-unique-key>" \
  --json
```

- Always pass a stable `--idempotency-key` so retries are safe (e.g.
  `auth-login-race-2026-06-16`).
- Set `--priority 0..4` (0 = highest) when it matters; `--label` for taxonomy;
  `--owner` if known.

**Top-level tickets are feature-oriented user stories, not dev tasks.** Each
top-level ticket body uses a Mike Cohn user story plus Gherkin acceptance
criteria (see template below). Development/implementation tasks belong **either**
as child tickets **or** inside the ticket body — never as the top-level story
itself.

### 4. Use relationships deliberately

Relationships are flags on `create`/`edit`, framed from the operating issue's POV:

- `--parent <ref>` — this issue is a sub-task of `<ref>`.
- `--blocks <ref>` — this must finish before `<ref>` can proceed.
- `--blocked-by <ref>` — `<ref>` must finish before this can proceed.
- `--related <ref>` — useful context, no ordering.

`kata ready` depends on `blocked-by` being accurate, so wire up dependencies as
you create tickets.

### 5. Write tickets that onboard a fresh session

Every ticket must contain enough context that a brand-new session can pick it up
cold: the why, the relevant files/components, constraints, and how "done" is
verified. Use this body template for top-level tickets:

```markdown
## User story
As a <role>, I want <action>, so that <business value>.

## Acceptance criteria
Scenario: <short name>
  Given <preconditions>
  When <event that triggers the action>
  Then <expected outcome>

(add more Scenario blocks as needed)

## Verification plan
<existing coverage and distinct gaps; affected checks and relevant real flows;
triggers for broader regression, with expected cost when material>

## Context / notes for implementers
<key files, components, prior decisions, links to related tickets [kata#ref],
gotchas, and any out-of-scope notes>

## Dev tasks (optional)
- [ ] <task>   (or split these out as child tickets)
```

### 6. Large context → a spec file

When a ticket needs more context than fits comfortably in its body, write a spec
file and reference it from the ticket body instead of inlining everything.

- **Location:** `./design/specs/` (create it with `mkdir -p ./design/specs` if
  missing).
- **Filename:** `YYYYMMDD_SCOPE-###_DESCRIPTION.md`
  - `YYYYMMDD` — today's date.
  - `SCOPE` — the work area / component in UPPERCASE (e.g. `BACKEND`, `API`,
    or the kata project name). It is *not* a kata ticket ref.
  - `###` — a per-day sequence number that **resets to `001` each day**. Pick
    the next value by listing `./design/specs/<YYYYMMDD>_*` and incrementing the
    highest (zero-padded to 3 digits).
  - `DESCRIPTION` — short kebab-case summary.
  - Examples: `./design/specs/20260616_BACKEND-001_db-refactor.md`, then
    `./design/specs/20260616_API-002_token-rotation.md` for that day's 2nd spec.
- In the ticket body, link the spec: `See ./design/specs/<file>.md for details.`

---

## Phase 2 — Implementing tickets

`--inline` is a skill option, not a kata CLI flag. With it, perform ticket work
in the current conversation. Without it, use a fresh subagent for each ticket.
The ticket procedure and completion rules are the same in both modes.

### Explicit tickets (`/kata work <ref> [<ref> ...] [--inline]`)

When the user invokes **`/kata work <ref> [<ref> ...] [--inline]`**, work only
the named tickets, in the order given. This is an instruction through the skill,
not a `kata work` CLI subcommand. Accept short IDs or qualified references such
as `kata#abc4`; accept `--inline` anywhere among the arguments. Do not start a
`/goal` loop or select additional work from `kata ready`. If no reference is
given, ask which ticket to work.

By default, dispatch each ticket to a fresh foreground general-purpose
subagent and wait before starting the next. Give it the ticket reference and
workspace path; tell it to load the kata skill and follow the **Ticket procedure**
below. Do not pass previous workers' transcripts. With `--inline`, follow that
procedure yourself, one ticket at a time. After each ticket, check its recorded
state. If blocked, report it and proceed to the next explicit reference. Stop
after the last reference.

### Ticket procedure (one assigned reference)

This procedure applies in a dispatched worker or the current conversation when
`--inline` is selected. Work only the assigned ticket before returning to the
caller or moving to the next explicit reference. Do not dispatch again from
inside a worker.

1. Read `kata show <ref> --json`, including the full body, comments,
   relationships, referenced guidance, and repository instructions. If already
   closed, report its status rather than reopening it automatically. If it is
   a parent with open children, report that it is not yet ready for parent
   completion; do not expand the assignment to its children.
2. Check dependencies and ownership, then claim the ticket with `kata assign
   <ref> <actor>` using the actor from `kata whoami`. Do not take over another
   agent's active work or implement prerequisite tickets implicitly. Follow
   repository branch/PR rules wherever they override Phase 3's defaults.
3. Complete the implementation and the ticket's verification plan. Favor simple
   designs, remove superseded code and tests while preserving still-required
   assertions, and avoid unrelated changes. Verify actual behavior at the
   appropriate layer; a test of the suspected cause alone does not establish
   that the user's reported flow works. Reuse relevant evidence and broaden
   testing only as required by the ticket, repository, or changed risks.
4. Before declaring a blocker, finish all implementation and verification that
   can proceed independently of the missing input. If hardware verification,
   user acceptance, or another prerequisite remains, leave the ticket open,
   record completed work and evidence plus exactly what remains, and mark it
   blocked and release ownership with `kata unassign` when appropriate. Do not
   claim an unverified outcome or stop useful independent work merely because
   final acceptance requires the user.
5. Otherwise, finish the repository's delivery workflow and close with typed
   evidence per Phase 3. Record a concise outcome with the ticket reference,
   status, changes, verification, PR or commit reference, and anything requiring
   the user's attention. Follow-up tickets may capture discoveries per Phase 3,
   but are not authorization to implement additional work.

Example user message:

```text
/kata work 9dff 7b2a
/kata work 9dff 7b2a --inline
```

### Backlog loop (`/kata goal [--inline]`)

When the user invokes **`/kata goal [--inline]`**, work the ready backlog to
completion. This is an instruction through the skill, not a `kata goal` CLI
subcommand. The `/goal` continuation runs in the parent. By default, the parent
dispatches each ticket to a fresh worker; with `--inline`, it performs the
ticket procedure itself.

An agent cannot set `/goal` mid-turn. Present the command below for the user
to run after substituting the selected mode. Once active, Claude iterates until
its goal evaluator confirms the condition.

**Command to present to the user (replace `[MODE]` with the selected mode):**

```
/goal Work the kata backlog to empty. Each turn, run `kata ready --json` and choose one actionable ticket, descending to a ready child when a parent has open children. [MODE] After the ticket, inspect its recorded state and repeat with the latest `kata ready --json`. Stop when the list is empty or every remaining ready ticket is blocked pending an action from me. Print the final `kata ready --json` output.

For each ticket, read its full body, comments, referenced guidance, and repository instructions; follow the kata skill's Ticket procedure, satisfy acceptance criteria, verify, and close with typed evidence. If my input is needed, complete independent work first, record exactly what remains, label the ticket blocked, and release ownership. Do not treat a worker summary alone as proof of completion.
```

Use one of these exact substitutions for `[MODE]`:

- Default: `Dispatch it to a fresh foreground general-purpose subagent with no inherited conversation history. Pass the reference and workspace path, have it load the kata skill, and wait for its concise result. Keep implementation and test logs in the worker's context.`
- `--inline`: `Follow the kata skill's Ticket procedure for this ticket in the current conversation. Do not dispatch a subagent.`

**Backlog iteration:**

1. `kata ready --json` — list open tickets with no open blockers. In the default
   mode, keep only selection fields in the parent transcript until the final audit.
2. Select the top actionable ticket. In the default mode, filter `kata show <ref>
   --json` before it reaches the parent transcript, retaining only status and
   child references needed for selection; leave full context to the worker.
3. **If it's a parent with open children, descend — don't implement the parent.**
   `kata ready` lists a parent story whenever it has no blockers of its own, even
   though its actual work lives in child tickets. Inspect the `children` array
   from `kata show <ref> --json`: if any child is still open, leave the parent
   and work a ready child instead (children surface in `kata ready` as their own
   blockers clear). Only close the parent once **all** its children are closed —
   the daemon refuses a parent-close while open children remain. Closing the last
   child makes the parent the natural next pick. At parent completion, the
   ticket implementer reviews child evidence against the combined behavior and
   verifies remaining integration risks. It reruns checks when later changes
   invalidate evidence or a required gate calls for it.
4. In default mode, dispatch the selected ticket to a new foreground
   general-purpose subagent; give it the reference and workspace path, and tell
   it to load this skill and follow **Ticket procedure**. Wait for its result
   before dispatching another worker. With `--inline`, follow **Ticket
   procedure** in this conversation. Workers sharing a checkout must not edit
   in parallel.
5. Check the recorded status with `kata show <ref> --json`, filtered in default
   mode. If work stopped unexpectedly or left an actionable ticket open, inspect
   what remains and retry only when there is a concrete path forward. Do not
   repeatedly dispatch a failing ticket or claim goal completion with it still
   actionable. Keep only a short outcome in the parent transcript. Re-run
   `kata ready --json` rather than assuming the backlog has not changed.
6. Stop when `kata ready` yields only blocked-on-user tickets (or parents whose
   only open children are themselves blocked on you), or is empty.

> The user's original framing for this loop: *"Iterate over new kata tickets
> ready for work using `kata ready` and perform work necessary to close them
> according to their acceptance criteria. Continue to do this until all tickets
> are either completed or have been blocked on actions that require actions from
> me."*

---

## Phase 3 — Finishing tickets

Do this as each ticket's work is verified — **close eagerly, not in one batch at
the end**. In kata 0.18.0, sibling-close burst throttling is disabled by
default. A daemon operator can enable it with `[close.throttle] enabled = true`;
the default burst window is then 60 seconds. Check the daemon's configuration
if a close is refused for throttling. The parent-completeness, substantive
message, and evidence requirements still apply.

### 1. Land the code

Pick the unit of delivery by the ticket's size:

- **Small standalone ticket → a single commit on the default branch.**
- **Larger feature (a top-level story, usually one with child tickets) → a
  feature branch.** Create it off the default branch *before* starting the
  feature's first child, land each child's commit on it, and merge it back only
  once the feature is done and **all its children are closed**:

  ```bash
  git switch -c feat/<parent-ref>-<short-slug>   # e.g. feat/96p3-moving-snake
  # ... land each child's commit on this branch ...
  git switch <default-branch>
  git merge --no-ff feat/<parent-ref>-<short-slug>
  git branch -d feat/<parent-ref>-<short-slug>
  ```

- Either way, use **Conventional Commits** (`feat:`, `fix:`, `refactor:`,
  `docs:`, …) with the relevant kata ticket IDs in the **commit footer**:

  ```
  feat(auth): guard against Safari double-submit on login

  <body explaining what and why>

  Refs: kata#abc4, kata#d4ex
  ```

### 2. Close the ticket with evidence

Closing asserts the work is complete. Only close work you've completed and
verified. Report what ran, its result, which claims it proves, and material
limits (including destination or external environment when relevant). Explain
non-obvious test selection briefly; never imply an unrun full suite passed.
Evidence from existing checks is valid when applicable to the delivered change;
reuse earlier results only when intervening changes have not invalidated them
and required gates allow it. Eager closure means closing once sufficient
verification is complete, not inventing a fresh full-regression gate per ticket.

```bash
kata close <ref> --done \
  --message "<substantive prose: scope + how it was verified>" \
  --commit <sha>          # or --pr <url>, --test "<cmd>", --reviewed <path>
```

If the work is **not** done, do not close — label and comment instead:

```bash
kata edit <ref> --label needs-review
kata comment <ref> --body "what was attempted, what remains"
```

### 3. Capture context

If the work surfaced important context worth preserving (decisions, gotchas,
follow-on implications), add it as a **comment on the relevant closed ticket**:

```bash
kata comment <ref> --body "<context for future sessions>"
```

### 4. File follow-up tickets

If the work uncovered **other major work outside this work item**, create new
tickets for it (go back to Phase 1 for those). Link them with `--related <ref>`
to the ticket that surfaced them. Don't silently scope-creep the current ticket.

---

## Command cheat sheet

| Need | Command |
| --- | --- |
| Refresh kata's own rules | `kata quickstart` |
| Bind a workspace (`/kata init`) | `kata init` · `kata init --project <name>` |
| Confirm init / actor | `kata list --limit 1` · `kata whoami` |
| Find prior work/context | `kata search "<query>" --json` |
| Read a ticket | `kata show <ref> --json` |
| Create a ticket | `kata create "<title>" --body-file <f> --idempotency-key <k> --json` |
| Next actionable work | `kata ready --json` |
| Claim a ticket | `kata assign <ref> <your-actor>` |
| Add context | `kata comment <ref> --body "..."` |
| Relationships / labels / priority | `kata edit <ref> --blocked-by <ref> --label <l> --priority <0-4>` |
| Close (done) | `kata close <ref> --done --message "..." --commit <sha>` |
| Block + release | `kata edit <ref> --label blocked` · `kata unassign <ref> --comment "blocked on: ..."` |
