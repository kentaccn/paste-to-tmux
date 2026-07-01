# Contributing to paste-to-tmux

Guidance for AI coding agents (and humans) contributing to `paste-to-tmux`.

## What this is

A single POSIX-ish bash script (`paste-to-tmux`) that copies files from your
laptop to a remote host over `ssh`/`scp` and types the remote path into a tmux
pane with `tmux send-keys`. No daemon, no remote install, no dependencies beyond
`ssh`/`scp`/`tmux` (plus optional `pngpaste` on macOS).

## Ground rules

- **Keep it one file, zero deps.** The whole value is that it's client-only and
  installs in one place. Don't add a runtime, a package manager, or a remote
  component.
- **Security first.** Anything derived from a filename, path, or tmux target is
  attacker-influenced. Shell-quote it (`shq`) and send it literally
  (`send-keys -l`). Never `eval` user input; never build a remote command by
  string-concatenating an unquoted path.
- **Both agents and their code get reviewed.** Every change is run past Codex
  (`codex review`) before it lands. AI writes the diff; a human decides whether
  it's the right diff. That split is the point — the tool exists because a person
  knew the problem was worth solving, not because a model volunteered it.
- Match the existing style; test `setup`, a clipboard send, and a dragged-file
  send on a real remote before committing.

## Layout

- `paste-to-tmux` — the tool.
- `install.sh` — copies it onto your `PATH`.
- `Formula/` — Homebrew formula.
- `docs/demo.gif` — the demo, tracked so the README renders on GitHub. Its VHS
  build sources (`demo.tape`, `*-pane.sh`, `demo.tmux.conf`, `RECORDING.md`) are
  gitignored and kept locally; regenerate the GIF with `vhs docs/demo.tape`.


