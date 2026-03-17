#!/bin/bash
# Claude Code tmux 通知脚本
# 通过铃声和消息通知 tmux 窗口

# 日志文件路径
LOG_FILE="${CLAUDE_NOTIFY_LOG_FILE:-$HOME/.tmux/claude-notify.log}"

# 调试日志开关，设为 1 启用详细日志
DEBUG="${CLAUDE_NOTIFY_DEBUG:-1}"

log_write() {
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] $*" >> "$LOG_FILE"
}

log_debug() {
    if [[ "$DEBUG" -eq 1 ]]; then
        log_write "[DEBUG] $*"
    fi
}

log_info() {
    log_write "[INFO] $*"
}

log_error() {
    log_write "[ERROR] $*"
}

MESSAGE="$1"
TYPE="${2:-info}"

# 确保日志目录存在
mkdir -p "$(dirname "$LOG_FILE")" 2>/dev/null

log_write "=========================================="
log_debug "MESSAGE=$MESSAGE, TYPE=$TYPE, TMUX_PANE=$TMUX_PANE, TMUX=$TMUX"

# 检测是否在 tmux 会话中
is_in_tmux() {
    # 方法 1: 检查 TMUX 环境变量
    if [[ -n "$TMUX" ]]; then
        log_debug "检测到 TMUX 环境变量：$TMUX"
        return 0
    fi
    # 方法 2: 检查是否在 tmux 服务器中
    if tmux info &>/dev/null; then
        log_debug "tmux info 命令执行成功，确认在 tmux 中"
        return 0
    fi
    log_debug "未在 tmux 会话中"
    return 1
}

# 检测是否在 tmux 会话中
if ! is_in_tmux; then
    log_info "不在 tmux 中，输出到 stdout: $MESSAGE"
    # 不在 tmux 中，仅输出消息到 stdout
    echo "[Claude] $MESSAGE"
    printf '\a'
    exit 0
fi

log_debug "在 tmux 会话中，TMUX_PANE=$TMUX_PANE"

# 获取当前 tmux pane
if [[ -n "$TMUX_PANE" ]]; then
    # 检查当前 pane 所在窗口是否为激活窗口
    # 如果窗口已激活，则跳过通知（用户已经在关注这个窗口）
    ACTIVE_PANE=$(tmux list-panes -F '#{pane_active} #{pane_id}' 2>/dev/null | grep '^1' | awk '{print $2}')
    log_debug "ACTIVE_PANE=$ACTIVE_PANE, 当前 TMUX_PANE=$TMUX_PANE"

    # pane ID 可能带有或不带 % 前缀，需要统一比较
    ACTIVE_PANE_NORMALIZED=$(echo "$ACTIVE_PANE" | tr -d '%')
    TMUX_PANE_NORMALIZED=$(echo "$TMUX_PANE" | tr -d '%')
    log_debug "归一化后：ACTIVE_PANE=$ACTIVE_PANE_NORMALIZED, TMUX_PANE=$TMUX_PANE_NORMALIZED"

    if [[ "$TMUX_PANE_NORMALIZED" == "$ACTIVE_PANE_NORMALIZED" ]]; then
        # 当前 pane 是激活状态，不进行通知
        log_debug "当前 pane 是激活状态，跳过通知"
        exit 0
    fi

    log_info "发送通知到 pane $TMUX_PANE: $MESSAGE"

    # 直接写入 pane 的 tty 设备
    PANE_TTY=$(tmux display-message -p -t "$TMUX_PANE" -F '#{pane_tty}' 2>/dev/null)
    if [[ -n "$PANE_TTY" && -w "$PANE_TTY" ]]; then
        printf '\a' > "$PANE_TTY" 2>/dev/null
        log_debug "已写入 tty: $PANE_TTY"
    fi

    # 显示浮动消息
    if tmux display-message -t "$TMUX_PANE" "[Claude] $MESSAGE" 2>/dev/null; then
        log_debug "已显示浮动消息（普通模式）"
    else
        log_debug "浮动消息显示失败"
    fi

    exit 0
fi

log_info "降级方案：不在tmux会话中,忽略"
