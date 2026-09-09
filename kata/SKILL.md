---
name: kata
description: >-
  Manage software development work with kata, an agent-first ticket tracker. Use
  this whenever you start, plan, implement, or finish non-trivial software work
  in a kata-tracked workspace. SETUP: `/kata init` binds the workspace to a kata
  project (and loads this workflow). PLAN: decompose any feature request, bug report,
  or non-trivial task into kata tickets — top-level tickets are Mike Cohn user
  stories with Gherkin acceptance criteria; search existing tickets first.
  IMPLEMENT: `/kata implement` starts a /goal loop that works `kata ready` tickets
  to completion. FINISH: commit (Conventional Commits) or merge, footer the kata
  ticket IDs, capture context as ticket comments, and file follow-up tickets for
  newly discovered work. Reach for this on essentially any non-trivial coding task.
---

# kata workflow

kata is a lightweight, agent-first issue tracker that acts as the shared issue
ledger for a workspace. This skill is the standard operating procedure for using
it across the full lifecycle of software work: **plan → implement → finish**.

Run `kata quickstart` any time you need a refresher on kata's own conventions;
the rules there (close asserts completion, search before create, eager closes,
typed evidence) always take precedence over anything summarized here.

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

## Phase 2 — Implementing tickets (`/kata implement`)

When the user invokes **`/kata implement`**, kick off a `/goal` loop that drives
the ready backlog to completion.

`/goal` is set by the user (an agent can't set it mid-turn), so **present the
exact command below for the user to run.** Once the goal is active, every turn
Claude runs the per-iteration loop until the evaluator confirms the condition.

**Command to surface to the user:**

```
/goal Work the kata backlog to empty. Each turn: run `kata ready --json`, take the top ready ticket, do the work required to satisfy its acceptance criteria, verify it, then close it with typed evidence. If a ticket cannot proceed without input from me, comment what is blocking it and label it blocked, then move on. The condition is met when `kata ready` returns no tickets that are actionable without my input — i.e. every remaining ready ticket is labeled blocked pending an action from me, or the list is empty. Print the `kata ready` output each turn so completion can be verified.
```

**Per-iteration loop (what each goal turn does):**

1. `kata ready --json` — list open tickets with no open blockers.
2. Pick the top ticket and `kata show <ref> --json` to load full context (and
   any referenced `./design/specs/` file).
3. **If it's a parent with open children, descend — don't implement the parent.**
   `kata ready` lists a parent story whenever it has no blockers of its own, even
   though its actual work lives in child tickets. Inspect the `children` array
   from `kata show <ref> --json`: if any child is still open, leave the parent
   and work a ready child instead (children surface in `kata ready` as their own
   blockers clear). Only close the parent once **all** its children are closed —
   the daemon refuses a parent-close while open children remain. Closing the last
   child makes the parent the natural next pick. At parent completion, review
   child evidence against the combined behavior and verify remaining integration
   risks. Do not repeat every child's checks solely to close the parent; rerun
   when later changes invalidate evidence or a required gate calls for it.
4. **Claim the ticket you'll actually work** (the one resolved after the descend
   check) so concurrent agents don't double-work it: `kata assign <ref>
   <your-actor>` — your actor is what `kata whoami` reports.
5. **Get on the right branch (see Phase 3 §1).** For a top-level feature story
   (one with children), create or switch to its feature branch before working
   its children; a small standalone ticket can stay on the default branch.
6. Do the work needed to satisfy the ticket's acceptance criteria. Update tests
   superseded by changed behavior and consolidate overlapping coverage touched
   by the change; this is part of maintaining the feature. Preserve each distinct
   assertion in retained coverage or explain why the requirement is retired.
   Keep unrelated suite redesign as follow-up work.
7. Run the selected verification checks and required gates; the proof must land
   in the transcript so the `/goal` evaluator can see it. While debugging, rerun
   the affected case first. Broaden or repeat passing checks when new changes,
   failures, integration risks, or explicit gates justify it, not automatically
   after every edit. Evaluate material added runtime and fixture reliability
   before retaining a new expensive scenario. Keep scenarios independently
   diagnosable; do not combine them into one fragile, state-sharing mega-test.
8. **Finish the ticket** per Phase 3.
9. If the ticket can't proceed without the user, block it **and release it back
   to the unowned pool** so it doesn't sit owned by you: `kata edit <ref> --label
   blocked` then `kata unassign <ref> --comment "blocked on: <what you need>"`.
   Continue to the next ready ticket.
10. Stop when `kata ready` yields only blocked-on-user tickets (or parents whose
    only open children are themselves blocked on you), or is empty.

> The user's original framing for this loop: *"Iterate over new kata tickets
> ready for work using `kata ready` and perform work necessary to close them
> according to their acceptance criteria. Continue to do this until all tickets
> are either completed or have been blocked on actions that require actions from
> me."*

---

## Phase 3 — Finishing tickets

Do this as each ticket's work is verified — **close eagerly, not in one batch at
the end** (the daemon throttles >3 sibling closes by one actor under one parent
within 5 minutes).

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
