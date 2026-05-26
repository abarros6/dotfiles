#!/bin/sh
# Claude Code statusLine
input=$(cat)

# 1. Current directory (short name, green)
cwd=$(echo "$input" | jq -r '.cwd')
short_dir=$(basename "$cwd")
printf '\033[32m%s\033[0m' "$short_dir"

# 2+3. Git branch (yellow) + dirty indicator (red *)
if git -C "$cwd" rev-parse --git-dir > /dev/null 2>&1; then
  branch=$(git -C "$cwd" symbolic-ref --short HEAD 2>/dev/null \
           || git -C "$cwd" rev-parse --short HEAD 2>/dev/null)
  if [ -n "$branch" ]; then
    # Check for uncommitted changes (staged or unstaged), skipping optional locks
    if git -C "$cwd" --no-optional-locks status --porcelain 2>/dev/null | grep -q .; then
      dirty='\033[31m*\033[0m'
    else
      dirty=''
    fi
    printf ' \033[33m(%s\033[0m%b\033[33m)\033[0m' "$branch" "$dirty"
  fi
fi

# 4. Context % used (cyan)
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
if [ -n "$used_pct" ]; then
  used_pct_int=$(printf '%.0f' "$used_pct")
  printf ' \033[36mctx:%s%%\033[0m' "$used_pct_int"
fi

# 5. Token counts — compact k notation, white/default
ctx=$(echo "$input" | jq -r '.context_window.current_usage.input_tokens // empty')
total=$(echo "$input" | jq -r '.context_window.context_window_size // empty')
if [ -n "$ctx" ] && [ -n "$total" ]; then
  fmt_k() {
    val=$1
    if [ "$val" -ge 1000 ]; then
      printf '%dk' "$(( val / 1000 ))"
    else
      printf '%d' "$val"
    fi
  }
  printf ' %s/%s' "$(fmt_k "$ctx")" "$(fmt_k "$total")"
fi

# 6. Model name (magenta) — strip "Claude " prefix and date suffix (e.g. " 20241022")
model=$(echo "$input" | jq -r '.model.display_name // empty')
if [ -n "$model" ]; then
  # Remove leading "Claude " (case-insensitive)
  model=$(echo "$model" | sed 's/^[Cc]laude //; s/ [0-9]\{8\}$//')
  printf ' \033[35m%s\033[0m' "$model"
fi

# 7. Rate limits (5h and 7d usage) — yellow when under 80%, red when at or above 80%
five_pct=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
week_pct=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')
if [ -n "$five_pct" ] || [ -n "$week_pct" ]; then
  printf ' |'
  if [ -n "$five_pct" ]; then
    five_int=$(printf '%.0f' "$five_pct")
    if [ "$five_int" -ge 80 ]; then
      printf ' \033[31m5h:%d%%\033[0m' "$five_int"
    else
      printf ' \033[33m5h:%d%%\033[0m' "$five_int"
    fi
  fi
  if [ -n "$week_pct" ]; then
    week_int=$(printf '%.0f' "$week_pct")
    if [ "$week_int" -ge 80 ]; then
      printf ' \033[31m7d:%d%%\033[0m' "$week_int"
    else
      printf ' \033[33m7d:%d%%\033[0m' "$week_int"
    fi
  fi
fi
