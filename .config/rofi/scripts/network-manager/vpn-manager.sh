#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENABLED_DIR="$SCRIPT_DIR/enabled"

STOP_ICON=$'\ueba5'
START_ICON=$'\ueba6'

if [ -n "$1" ]; then
  name="${1##* }"
  module="$ENABLED_DIR/$name.sh"
  if [ -x "$module" ]; then
    coproc ("$module" toggle >/dev/null 2>&1) &
  fi
  exit 0
fi

active=""
index=0

for module in "$ENABLED_DIR"/*.sh; do
  [ -x "$module" ] || continue
  name="$(basename "$module" .sh)"

  if "$module" status; then
    [ -n "$active" ] && active+=","
    active+="$index"
    printf '%s  Stop %s\n' "$STOP_ICON" "$name"
  else
    printf '%s  Start %s\n' "$START_ICON" "$name"
  fi
  ((index++))
done

printf '\0active\x1f%s\n' "$active"
