#!/usr/bin/env bash
# Link repository skills into personal harness directories. Bash 3.2 compatible.
set -euo pipefail

usage() {
    cat <<'EOF'
Usage: ./install.sh [options]

Link skills from codex/ and claude/, plus Claude agents, into their harnesses.

  --dry-run          Preview without changing files
  --backup           Move conflicting entries outside skill discovery paths
  --codex-dir DIR    Codex skills directory (default: ~/.codex/skills)
  --claude-dir DIR   Claude skills directory (default: ~/.claude/skills)
  --claude-agent-dir DIR  Claude agents directory (default: ~/.claude/agents)
  -h, --help         Show this help

For Codex's currently documented personal location:
  ./install.sh --codex-dir "$HOME/.agents/skills"

Backups: ${XDG_STATE_HOME:-$HOME/.local/state}/agent-skills/backups/<unique-run>/
Correct links are unchanged. Conflicts fail unless --backup is given.
EOF
}

die() { printf 'Error: %s\n' "$*" >&2; exit 1; }

dry_run=false
backup=false
codex_dir="$HOME/.codex/skills"
claude_dir="$HOME/.claude/skills"
claude_agent_dir="$HOME/.claude/agents"
while [ "$#" -gt 0 ]; do
    case "$1" in
        --dry-run) dry_run=true; shift ;;
        --backup) backup=true; shift ;;
        --codex-dir|--claude-dir|--claude-agent-dir)
            [ "$#" -ge 2 ] && [ -n "$2" ] || die "$1 needs a directory"
            case "$2" in --*) die "$1 needs a directory" ;; esac
            case "$1" in
                --codex-dir) codex_dir=$2 ;;
                --claude-dir) claude_dir=$2 ;;
                --claude-agent-dir) claude_agent_dir=$2 ;;
            esac
            shift 2 ;;
        -h|--help) usage; exit 0 ;;
        *) die "Unknown option: $1 (use --help)" ;;
    esac
done

repo_dir=$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
# Absolute destinations keep leading dashes safe and make reports unambiguous.
case "$codex_dir" in /*) ;; *) codex_dir="$PWD/$codex_dir" ;; esac
case "$claude_dir" in /*) ;; *) claude_dir="$PWD/$claude_dir" ;; esac
case "$claude_agent_dir" in /*) ;; *) claude_agent_dir="$PWD/$claude_agent_dir" ;; esac
destinations=("$codex_dir" "$claude_dir")
harnesses=(codex claude)
shopt -s nullglob
for harness in "${harnesses[@]}"; do
    skills=("$repo_dir/$harness"/*/SKILL.md)
    [ "${#skills[@]}" -gt 0 ] || die "No $harness skills found in $repo_dir/$harness"
done

correct_link() {
    [ -L "$2" ] && [ "$(readlink "$2")" = "$1" ]
}

legacy_link() {
    # The previous installer linked both harnesses to a top-level skill.
    [ -L "$2" ] && [ "$(readlink "$2")" = "$repo_dir/$1" ]
}

# Preflight every destination before writing anything.
conflicts=false
for index in 0 1; do
    root=${destinations[$index]}
    if { [ -e "$root" ] || [ -L "$root" ]; } && [ ! -d "$root" ]; then
        die "Skills directory is not a directory: $root"
    fi
    skills=("$repo_dir/${harnesses[$index]}"/*/SKILL.md)
    for entry in "${skills[@]}"; do
        source_dir=${entry%/SKILL.md}
        name=${source_dir##*/}
        target="$root/$name"
        if correct_link "$source_dir" "$target" || legacy_link "$name" "$target"; then
            continue
        fi
        if { [ -e "$target" ] || [ -L "$target" ]; } && ! "$backup"; then
            printf 'Conflict: %s (use --backup to preserve and replace it)\n' "$target" >&2
            conflicts=true
        fi
    done
done
if { [ -e "$claude_agent_dir" ] || [ -L "$claude_agent_dir" ]; } && [ ! -d "$claude_agent_dir" ]; then
    die "Claude agents directory is not a directory: $claude_agent_dir"
fi
agents=("$repo_dir/claude/agents/"*.md)
for entry in "${agents[@]}"; do
    target="$claude_agent_dir/${entry##*/}"
    if correct_link "$entry" "$target"; then
        continue
    fi
    if { [ -e "$target" ] || [ -L "$target" ]; } && ! "$backup"; then
        printf 'Conflict: %s (use --backup to preserve and replace it)\n' "$target" >&2
        conflicts=true
    fi
done
! "$conflicts" || exit 1

backup_run=''
for index in 0 1; do
    root=${destinations[$index]}
    skills=("$repo_dir/${harnesses[$index]}"/*/SKILL.md)
    for entry in "${skills[@]}"; do
        source_dir=${entry%/SKILL.md}
        name=${source_dir##*/}
        target="$root/$name"
        if correct_link "$source_dir" "$target"; then
            printf 'Unchanged: %s\n' "$target"
            continue
        fi
        saved=''
        old_link=''
        if legacy_link "$name" "$target"; then
            old_link=$(readlink "$target")
            if "$dry_run"; then
                printf 'Would replace old link: %s\n' "$target"
            else
                unlink "$target"
            fi
        elif [ -e "$target" ] || [ -L "$target" ]; then
            # Recheck in case something changed after preflight.
            "$backup" || die "Destination appeared during installation: $target"
            if "$dry_run"; then
                printf 'Would back up: %s\n' "$target"
            else
                if [ -z "$backup_run" ]; then
                    backup_base="${XDG_STATE_HOME:-$HOME/.local/state}/agent-skills/backups"
                    mkdir -p -- "$backup_base"
                    backup_run=$(mktemp -d "$backup_base/install.XXXXXX")
                fi
                mkdir -p -- "$backup_run/${harnesses[$index]}"
                saved="$backup_run/${harnesses[$index]}/$name"
                mv -- "$target" "$saved"
                printf 'Backup: %s -> %s\n' "$target" "$saved"
            fi
        fi
        if "$dry_run"; then
            printf 'Would link: %s -> %s\n' "$target" "$source_dir"
        else
            mkdir -p -- "$root"
            if ! ln -s -- "$source_dir" "$target"; then
                if [ -n "$saved" ] && [ ! -e "$target" ] && [ ! -L "$target" ]; then
                    mv -- "$saved" "$target"
                elif [ -n "$old_link" ] && [ ! -e "$target" ] && [ ! -L "$target" ]; then
                    ln -s -- "$old_link" "$target"
                fi
                die "Could not create link: $target"
            fi
            printf 'Linked: %s -> %s\n' "$target" "$source_dir"
        fi
    done
done
for entry in "${agents[@]}"; do
    target="$claude_agent_dir/${entry##*/}"
    if correct_link "$entry" "$target"; then
        printf 'Unchanged: %s\n' "$target"
        continue
    fi
    saved=''
    if [ -e "$target" ] || [ -L "$target" ]; then
        "$backup" || die "Destination appeared during installation: $target"
        if "$dry_run"; then
            printf 'Would back up: %s\n' "$target"
        else
            if [ -z "$backup_run" ]; then
                backup_base="${XDG_STATE_HOME:-$HOME/.local/state}/agent-skills/backups"
                mkdir -p -- "$backup_base"
                backup_run=$(mktemp -d "$backup_base/install.XXXXXX")
            fi
            mkdir -p -- "$backup_run/claude-agents"
            saved="$backup_run/claude-agents/${entry##*/}"
            mv -- "$target" "$saved"
            printf 'Backup: %s -> %s\n' "$target" "$saved"
        fi
    fi
    if "$dry_run"; then
        printf 'Would link: %s -> %s\n' "$target" "$entry"
    else
        mkdir -p -- "$claude_agent_dir"
        if ! ln -s -- "$entry" "$target"; then
            if [ -n "$saved" ] && [ ! -e "$target" ] && [ ! -L "$target" ]; then
                mv -- "$saved" "$target"
            fi
            die "Could not create link: $target"
        fi
        printf 'Linked: %s -> %s\n' "$target" "$entry"
    fi
done
