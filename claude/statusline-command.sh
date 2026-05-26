#!/bin/sh
input=$(cat)

# Git branch (green) + dirty indicator (red *)
cwd=$(echo "$input" | jq -r '.cwd')
if git -C "$cwd" rev-parse --git-dir > /dev/null 2>&1; then
  branch=$(git -C "$cwd" symbolic-ref --short HEAD 2>/dev/null \
           || git -C "$cwd" rev-parse --short HEAD 2>/dev/null)
  if [ -n "$branch" ]; then
    if git -C "$cwd" --no-optional-locks status --porcelain 2>/dev/null | grep -q .; then
      printf '\033[32m%s\033[31m*\033[0m' "$branch"
    else
      printf '\033[32m%s\033[0m' "$branch"
    fi
  fi
fi

# Context % (cyan)
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
if [ -n "$used_pct" ]; then
  printf ' \033[36mctx:%d%%\033[0m' "$(printf '%.0f' "$used_pct")"
fi

# 5h rate limit (yellow < 80%, red >= 80%)
five_pct=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
if [ -n "$five_pct" ]; then
  five_int=$(printf '%.0f' "$five_pct")
  if [ "$five_int" -ge 80 ]; then
    printf ' \033[31m5h:%d%%\033[0m' "$five_int"
  else
    printf ' \033[33m5h:%d%%\033[0m' "$five_int"
  fi
fi

# 7d rate limit with days-left (yellow < 80%, red >= 80%)
week_pct=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')
week_resets=$(echo "$input" | jq -r '.rate_limits.seven_day.resets_at // empty')
if [ -n "$week_pct" ]; then
  week_int=$(printf '%.0f' "$week_pct")
  days_left=""
  if [ -n "$week_resets" ]; then
    secs_left=$((week_resets - $(date +%s)))
    [ "$secs_left" -gt 0 ] && days_left=$(( (secs_left + 86399) / 86400 ))
  fi
  if [ "$week_int" -ge 80 ]; then
    color='\033[31m'
  else
    color='\033[33m'
  fi
  if [ -n "$days_left" ]; then
    printf " ${color}7d:%d%%(%dd left)\033[0m" "$week_int" "$days_left"
  else
    printf " ${color}7d:%d%%\033[0m" "$week_int"
  fi
fi
