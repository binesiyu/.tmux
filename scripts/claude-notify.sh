#!/bin/bash
# Claude Code tmux 通知脚本
# 通过铃声和消息通知 tmux 窗口

# 日志文件路径
LOG_FILE="${CLAUDE_NOTIFY_LOG_FILE:-$HOME/.tmux/claude-notify.log}"

# 调试日志开关，设为 0 启用日志
DEBUG="${CLAUDE_NOTIFY_DEBUG:-1}"

log_write() {
    [[ "$DEBUG" -eq 0 ]] && echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >> "$LOG_FILE"
}

log_info() {
    [[ "$DEBUG" -eq 0 ]] && log_write "$*"
}

MESSAGE="$1"
TYPE="${2:-info}"

# 确保日志目录存在
mkdir -p "$(dirname "$LOG_FILE")" 2>/dev/null

log_info "=========================================="
log_info "$MESSAGE"

# 检测是否在 tmux 会话中
is_in_tmux() {
    [[ -n "$TMUX" ]] && return 0
    tmux info &>/dev/null
}

if ! is_in_tmux; then
    echo "[Claude] $MESSAGE"
    exit 0
fi

if [[ -n "$TMUX_PANE" ]]; then
    ACTIVE_PANE=$(tmux list-panes -F '#{pane_active} #{pane_id}' 2>/dev/null | grep '^1' | awk '{print $2}')
    ACTIVE_PANE_NORMALIZED=$(echo "$ACTIVE_PANE" | tr -d '%')
    TMUX_PANE_NORMALIZED=$(echo "$TMUX_PANE" | tr -d '%')

    if [[ "$TMUX_PANE_NORMALIZED" == "$ACTIVE_PANE_NORMALIZED" ]]; then
        exit 0
    fi

    log_info "pane $TMUX_PANE: $MESSAGE"

    PANE_TTY=$(tmux display-message -p -t "$TMUX_PANE" -F '#{pane_tty}' 2>/dev/null)
    [[ -n "$PANE_TTY" && -w "$PANE_TTY" ]] && printf '\a' > "$PANE_TTY" 2>/dev/null

    tmux display-message -t "$TMUX_PANE" "[Claude] $MESSAGE" 2>/dev/null
fi

exit 0
