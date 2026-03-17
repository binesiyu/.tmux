#!/bin/bash
# Claude Code tmux 通知脚本
# 通过铃声和消息通知 tmux 窗口

MESSAGE="$1"
TYPE="${2:-info}"

# 如果是 Write hook，$ARGUMENTS 包含文件路径
if [[ "$TYPE" == "write" && -n "$ARGUMENTS" ]]; then
    # 从 JSON 中提取文件路径
    FILE_PATH=$(echo "$ARGUMENTS" | grep -o '"file_path"[[:space:]]*:[[:space:]]*"[^"]*"' | cut -d'"' -f4)
    if [[ -n "$FILE_PATH" ]]; then
        FILE_NAME=$(basename "$FILE_PATH")
        MESSAGE="✏️ 写入文件：$FILE_NAME"
    fi
fi

# 获取当前 tmux pane
if [[ -n "$TMUX_PANE" ]]; then
    # 触发 tmux bell（会在窗口状态栏显示活动标记）
    printf '\a'

    # 设置 pane 标题显示通知
    tmux select-pane -t "$TMUX_PANE" -T "🔔 Claude: $MESSAGE" 2>/dev/null

    # 显示浮动消息（如果 tmux 版本支持）
    tmux display-message -t "$TMUX_PANE" -E "[Claude] $MESSAGE" 2>/dev/null || \
    tmux display-message -t "$TMUX_PANE" "[Claude] $MESSAGE" 2>/dev/null

    exit 0
fi

# 降级方案：广播到所有窗口
tmux display-message -a "[Claude] $MESSAGE" 2>/dev/null || true
printf '\a'
