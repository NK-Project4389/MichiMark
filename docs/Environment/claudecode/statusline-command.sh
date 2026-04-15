#!/bin/sh
input=$(cat)

# ---- Extract values ----
model=$(echo "$input" | jq -r '.model.display_name // empty')
five_pct=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
week_pct=$(echo "$input"       | jq -r '.rate_limits.seven_day.used_percentage // empty')
five_reset=$(echo "$input"     | jq -r '.rate_limits.five_hour.resets_at // empty')
week_reset=$(echo "$input"     | jq -r '.rate_limits.seven_day.resets_at // empty')
in_tok=$(echo "$input"   | jq -r '.context_window.current_usage.input_tokens            // empty')
out_tok=$(echo "$input"  | jq -r '.context_window.current_usage.output_tokens           // empty')
cache_r=$(echo "$input"  | jq -r '.context_window.current_usage.cache_read_input_tokens // empty')

# ---- ANSI colors ----
ESC=$(printf '\033')
RESET="${ESC}[0m"
BOLD="${ESC}[1m"
DIM="${ESC}[2m"
GREEN="${ESC}[32m"
YELLOW="${ESC}[33m"
RED="${ESC}[31m"
CYAN="${ESC}[36m"
WHITE="${ESC}[37m"

# ---- Format time remaining until reset ----
fmt_reset() {
  reset_at="$1"
  [ -z "$reset_at" ] && return
  now=$(date +%s)
  diff=$(( reset_at - now ))
  [ "$diff" -le 0 ] && printf "0h" && return
  hrs=$(( diff / 3600 ))
  mins=$(( (diff % 3600) / 60 ))
  if [ "$hrs" -gt 0 ]; then
    printf "%dh%02dm" "$hrs" "$mins"
  else
    printf "%dm" "$mins"
  fi
}


# ---- Format token count (K / M) ----
fmt_tok() {
  n="$1"
  if [ -z "$n" ] || [ "$n" = "null" ]; then
    printf "--"
    return
  fi
  awk "BEGIN {
    n = $n
    if (n >= 1000000) { printf \"%.2fM\", n/1000000 }
    else if (n >= 1000) { printf \"%.1fK\", n/1000 }
    else { printf \"%d\", n }
  }"
}

# ---- Color by percentage ----
pct_color() {
  pct="$1"
  if awk "BEGIN { exit !($pct >= 90) }"; then
    printf "$RED"
  elif awk "BEGIN { exit !($pct >= 70) }"; then
    printf "$YELLOW"
  else
    printf "$GREEN"
  fi
}

# ---- Build output line ----
pct_part=""
if [ -n "$five_pct" ]; then
  five_int=$(printf '%.0f' "$five_pct")
  color=$(pct_color "$five_pct")
  five_eta=$(fmt_reset "$five_reset")
  if [ -n "$five_eta" ]; then
    pct_part="${DIM}5h:${RESET}${color}${BOLD}${five_int}%${RESET}${DIM}(${five_eta})${RESET}"
  else
    pct_part="${DIM}5h:${RESET}${color}${BOLD}${five_int}%${RESET}"
  fi
fi

week_part=""
if [ -n "$week_pct" ]; then
  week_int=$(printf '%.0f' "$week_pct")
  color=$(pct_color "$week_pct")
  # Calculate days remaining until weekly reset
  week_days_part=""
  if [ -n "$week_reset" ]; then
    now=$(date +%s)
    diff=$(( week_reset - now ))
    if [ "$diff" -gt 0 ]; then
      days_left=$(( diff / 86400 ))
      hrs_left=$(( (diff % 86400) / 3600 ))
      if [ "$days_left" -ge 1 ]; then
        week_days_part=" ${DIM}残${RESET}${BOLD}${days_left}d${RESET}"
      else
        week_days_part=" ${DIM}残${RESET}${BOLD}${hrs_left}h${RESET}"
      fi
    else
      week_days_part=" ${DIM}まもなく更新${RESET}"
    fi
  fi
  week_part="${DIM}7d:${RESET}${color}${BOLD}${week_int}%${RESET}${week_days_part}"
fi

if [ -n "$pct_part" ] && [ -n "$week_part" ]; then
  pct_part="${pct_part}  ${week_part}"
elif [ -n "$week_part" ]; then
  pct_part="$week_part"
fi

model_part=""
[ -n "$model" ] && model_part="${BOLD}${CYAN}${model}${RESET}"

tok_part=""
if [ -n "$in_tok" ]; then
  i_fmt=$(fmt_tok "$in_tok")
  o_fmt=$(fmt_tok "$out_tok")
  cr_fmt=$(fmt_tok "$cache_r")
  tok_part="${DIM}in:${RESET}${WHITE}${i_fmt}${RESET} ${DIM}out:${RESET}${WHITE}${o_fmt}${RESET} ${DIM}cache:${RESET}${WHITE}${cr_fmt}${RESET}"
fi

# ---- Combine parts with separator ----
out=""
for part in "$model_part" "$pct_part" "$tok_part"; do
  [ -z "$part" ] && continue
  [ -z "$out" ] && out="$part" || out="${out}  ${part}"
done

# ---- Output (single line) ----
printf '%s\n' "$out"
