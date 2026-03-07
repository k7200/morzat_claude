#!/bin/sh
# Claude Code status line
# Layout:  ~/路径 <分支>  模型 | tokens | ctx%

input=$(cat)

cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // empty')
model=$(echo "$input" | jq -r '.model.display_name // empty')
used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
input_tokens=$(echo "$input" | jq -r '.context_window.total_input_tokens // 0')
output_tokens=$(echo "$input" | jq -r '.context_window.total_output_tokens // 0')

# Shorten home directory to ~
home="$HOME"
short_dir="${cwd/#$home/~}"

# ANSI colors
yellow='\033[1;33m'
green='\033[1;32m'
cyan='\033[1;36m'
reset='\033[0m'

# Git branch
git_part=""
branch=$(GIT_OPTIONAL_LOCKS=0 git -C "$cwd" symbolic-ref --short HEAD 2>/dev/null \
         || GIT_OPTIONAL_LOCKS=0 git -C "$cwd" rev-parse --short HEAD 2>/dev/null)
if [ -n "$branch" ]; then
    git_part=" ${green}<${branch}>${reset}"
fi

# Total tokens = input + output
total_tokens=$((input_tokens + output_tokens))

# Format tokens: <1000 -> raw, >=1000 -> k, >=1000000 -> m
tokens_part=""
if [ "$total_tokens" -gt 0 ] 2>/dev/null; then
    if [ "$total_tokens" -ge 1000000 ]; then
        tokens_part=$(awk "BEGIN{printf \"%.1fm\", $total_tokens/1000000}")
    elif [ "$total_tokens" -ge 1000 ]; then
        tokens_part=$(awk "BEGIN{printf \"%.1fk\", $total_tokens/1000}")
    else
        tokens_part="${total_tokens}"
    fi
fi

# Context percentage
ctx_part=""
if [ -n "$used" ] && [ "$used" != "null" ]; then
    used_int=$(printf "%.0f" "$used")
    ctx_part="${used_int}%"
fi

# Left: path + branch
left="${yellow}${short_dir}${reset}${git_part}"

# Right: model | tokens | ctx%
right=""
if [ -n "$model" ] && [ "$model" != "null" ]; then
    right="${cyan}${model}${reset}"
fi
if [ -n "$tokens_part" ]; then
    [ -n "$right" ] && right="${right} ${cyan}|${reset} "
    right="${right}${cyan}${tokens_part}${reset}"
fi
if [ -n "$ctx_part" ]; then
    [ -n "$right" ] && right="${right} ${cyan}|${reset} "
    right="${right}${cyan}${ctx_part}${reset}"
fi

printf "%b  %b\n" "$left" "$right"
