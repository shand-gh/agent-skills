# Agent skills

Personal skills for Codex and Claude Code. This repository is the source of
truth: the installer links each harness to its own skill directory, so an edit
or `git pull` updates the installed skill without copying it elsewhere.

## Available skills

| Skill | Purpose |
| --- | --- |
| kata: [Codex](codex/kata/SKILL.md) · [Claude Code](claude/kata/SKILL.md) | Plan, implement, verify, and close software work with the kata ticket tracker. `work` accepts one or more ticket IDs; `goal` works the ready backlog. Both use a fresh worker per ticket by default or the current session with `--inline`. |

The kata skill contains agent instructions, not the kata executable. Install and
configure the kata CLI separately; `kata quickstart` describes its workflow.
Repository-specific instructions and your explicit requests still govern work.

## Install locally

Requires Bash and standard macOS/Linux utilities. No package manager or runtime
dependencies are needed for the installer.

```sh
git clone git@github.com:shand-gh/agent-skills.git ~/Developer/agent-skills
cd ~/Developer/agent-skills
./install.sh --dry-run
./install.sh
```

The installer discovers skill directories under `codex/` and `claude/` and
creates links such as:

```text
~/.codex/skills/kata  -> /absolute/path/to/agent-skills/codex/kata
~/.claude/skills/kata -> /absolute/path/to/agent-skills/claude/kata
```

It works from any working directory and leaves unrelated skills alone. Running
it again leaves correct links unchanged. Links made by the previous installer
to the top-level `kata/` directory are replaced automatically.

### Replace existing copies

By default, an existing directory, file, or different symlink is a conflict. All
destinations are checked before installation, so a known conflict stops the run
before any links are created. To migrate existing skill copies:

```sh
./install.sh --dry-run --backup
./install.sh --backup
```

`--backup` moves conflicting entries into a unique directory beneath
`${XDG_STATE_HOME:-$HOME/.local/state}/agent-skills/backups`, then installs the
links. Backups live outside skill discovery directories and are never deleted
by the installer. The script prints each backup's path. Review local differences
before replacing copies: they may contain edits not yet in this repository.

`--dry-run` performs no writes and returns nonzero for conflicts unless
`--backup` is also supplied. Filesystem errors during installation can leave
earlier links installed; after fixing the error, rerun the script. If creating a
link fails immediately after backing up that entry, the script attempts to
restore it.

## Which installation path is idiomatic?

Both harnesses support symlinked skill directories, so a Git checkout plus
symlinks is a straightforward fit for personal skills you edit locally.

- **Codex:** current documentation lists `~/.agents/skills` for user skills and
  explicitly supports symlinked skill folders. This script defaults to
  `~/.codex/skills` to preserve the author's existing installation layout. For
  the currently documented location, use the override below. See
  [Codex skill discovery](https://learn.chatgpt.com/docs/build-skills).
- **Claude Code:** `~/.claude/skills/<name>/SKILL.md` is the documented personal
  location; symlinked folders are supported. See
  [Claude Code skills](https://code.claude.com/docs/en/skills).

```sh
./install.sh --codex-dir "$HOME/.agents/skills" --dry-run
./install.sh --codex-dir "$HOME/.agents/skills"
```

Choose one Codex location; the installer does not migrate or remove skills in
the other location.

For custom configuration locations, specify either or both directories:

```sh
./install.sh --codex-dir /path/to/codex/skills --claude-dir /path/to/claude/skills
```

The script does not infer custom harness homes from environment variables.
`./install.sh --help` lists its options. Plugins are another distribution option
when sharing packaged capabilities beyond a personal checkout; they add
packaging and lifecycle work that this small repository does not need.
