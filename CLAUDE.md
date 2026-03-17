# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a fork of [gpakosz/.tmux](https://github.com/gpakosz/.tmux) - a self-contained tmux configuration with custom plugins and extensions.

## Architecture

```
~/.tmux/
├── .tmux.conf          # Main configuration (do not modify)
├── .tmux.conf.local    # Custom overrides (user modifications go here)
├── plugins/
│   ├── tpm/            # Tmux Plugin Manager
│   └── tmux-resurrect/ # Session persistence plugin
├── scripts/
│   └── claude-notify.sh # Claude Code notification script
└── resurrect/          # Saved tmux sessions
```

## Key Components

### Oh My Tmux (gpakosz/.tmux)
- Main configuration framework with theme support
- Uses `set -g @plugin` syntax in `.tmux.conf.local` to enable plugins
- Configuration is split: `.tmux.conf` (core) + `.tmux.conf.local` (customization)

### Tmux Resurrect
- Saves and restores tmux environments
- Save: `prefix + Ctrl-s`
- Restore: `prefix + Ctrl-r`

### Claude Notify (`scripts/claude-notify.sh`)
- Notification script for Claude Code hooks
- Logs to `~/.tmux/claude-notify.log`
- Debug mode: `CLAUDE_NOTIFY_DEBUG=1`
- Only notifies when target pane is NOT the active pane
- Features: pane title updates, floating messages, bell sounds

## Commands

### Reloading Configuration
```bash
# In tmux: prefix + r (or bind r)
# Or manually:
tmux source-file ~/.tmux/.tmux.conf
```

### Plugin Management (TPM)
```bash
# Install plugins: prefix + I
# Update plugins: prefix + U
# Clean plugins: prefix + Alt + o
```

### Tmux Resurrect
```bash
# Save session: prefix + Ctrl-s
# Restore session: prefix + Ctrl-r
# Saved sessions stored in ~/.tmux/resurrect/
```

### Viewing Logs
```bash
tail -f ~/.tmux/claude-notify.log  # Claude notify logs
tail -f plugins/tpm/tpm_log.txt    # TPM logs
```

## Configuration Notes

- Prefix key: `Ctrl-s` (also `Ctrl-z` as secondary prefix)
- Window numbering starts at 1
- Monitor activity and bell enabled
- 24-bit color auto-detected via COLORTERM
- Custom window status format with emoji indicators (🔔 bell, 🔍 zoomed)

## Important Files

- `.tmux.conf.local` - User customizations, theme settings, plugin declarations
- `.claude/settings.local.json` - Claude Code permissions for tmux commands
- `scripts/claude-notify.sh` - Notification script with logging

## Core Configuration (.tmux.conf)

### Prefix Keys
- Primary: `Ctrl-s`
- Secondary: `Ctrl-z` (GNU-Screen compatible)

### Key Bindings
- `Prefix + e` - Edit `.tmux.conf.local` in editor
- `Prefix + r` - Reload configuration
- `Prefix + C-c` - Create new session
- `Prefix + C-f` - Switch to session by name
- `Prefix + C-h/C-l` - Navigate windows
- `Prefix + -/_` - Split pane horizontally/vertically
- `Prefix + h/j/k/l` - Navigate panes (Vim style)
- `Prefix + m` - Toggle mouse mode

### Terminal Settings
- `default-terminal: screen-256color`
- `history-limit: 15000`
- `escape-time: 10` (faster command sequences)
- `focus-events: on`
- `allow-passthrough: on` (for iTerm2 escape sequences)

### Bell & Activity
- `bell-action: any` - Monitor bells from all panes
- `monitor-bell: on` - Enable bell notifications
- `monitor-activity: on` - Monitor window activity
- `visual-activity: off` - No visual activity indicator

### Pane & Window Behavior
- `base-index: 1` - Windows start at 1
- `pane-base-index: 1` - Panes start at 1
- `automatic-rename: off` - Don't auto-rename windows
- `allow-rename: off` - Don't allow programs to rename
- `renumber-windows: on` - Renumber when windows close
