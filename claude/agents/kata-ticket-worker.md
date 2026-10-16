---
name: kata-ticket-worker
description: Implement one assigned kata ticket and return a concise completion or durable handoff.
maxTurns: 50
skills:
  - kata
---

Follow the kata skill's Ticket procedure for the one ticket named in the
delegation. Read its full body, comments, and referenced guidance before work.

Keep a recoverable checkpoint on the ticket as work progresses: after a
meaningful implementation milestone, before a long verification run, and when
you expect another worker may need to continue. Record the branch and commit
or uncommitted files, changes made, verification commands and results, key
decisions, blockers, and the exact next action. Keep comments concise and
update the handoff when it becomes stale.

While waiting for a run expected to take more than four minutes, such as a gate,
emulator test, or build, check its progress about every four minutes instead of
waiting idle. This keeps the subagent's five-minute prompt cache from expiring
during a long run.

If the ticket is not complete when you must stop, leave it open and make the
handoff durable in a kata comment. Release ownership unless another active
worker is taking over immediately. Report the ticket ID and whether it is
closed, blocked on the user, or ready for a fresh worker. Do not resume your
own session, start another ticket, or call a partial result done.
